/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Base testing component to intergrate TestBox with ColdBox
 */
component extends="testbox.system.compat.framework.TestCase" accessors="true" {

	/**
	 * The application mapping this test links to
	 */
	property name="appMapping";

	/**
	 * The web mapping this test links to
	 */
	property name="webMapping";

	/**
	 * The configuration location this test links to
	 */
	property name="configMapping";

	/**
	 * The ColdBox controller this test links to
	 */
	property name="controller";

	/**
	 * If in integration mode, you can tag for your tests to be automatically autowired with dependencies
	 * by WireBox
	 */
	property
		name   ="autowire"
		type   ="boolean"
		default="false";

	/**
	 * The test case metadata
	 */
	property name="metadata" type="struct";

	// Public Switch Properties
	// TODO: Remove by ColdBox 4.2+ and move to variables scope.
	this.loadColdbox   = true;
	this.unLoadColdBox = true;

	// Internal Properties
	variables.appMapping    = "";
	variables.webMapping    = "";
	variables.configMapping = "";
	variables.controller    = "";
	variables.autowire      = false;
	variables.metadata      = {};

	/********************************************* LIFE-CYCLE METHODS *********************************************/

	/**
	 * Inspect test case for ColdBox loading annotations and autowiring
	 *
	 * @return BaseTestCase
	 */
	function metadataInspection(){
		variables.metadata = new coldbox.system.core.util.Util().getInheritedMetadata( this );
		// Inspect for appMapping annotation
		if ( structKeyExists( variables.metadata, "appMapping" ) ) {
			variables.appMapping = variables.metadata.appMapping;
		}
		// Inspect for webMapping annotation
		if ( structKeyExists( variables.metadata, "webMapping" ) ) {
			variables.webMapping = variables.metadata.webMapping;
		}
		// Configuration File mapping
		if ( structKeyExists( variables.metadata, "configMapping" ) ) {
			variables.configMapping = variables.metadata.configMapping;
		}
		// Load coldBox annotation
		if ( structKeyExists( variables.metadata, "loadColdbox" ) ) {
			this.loadColdbox = variables.metadata.loadColdbox;
		}
		// unLoad coldBox annotation
		if ( structKeyExists( variables.metadata, "unLoadColdbox" ) ) {
			this.unLoadColdbox = variables.metadata.unLoadColdbox;
		}
		// autowire
		if ( structKeyExists( variables.metadata, "autowire" ) ) {
			variables.autowire = ( !len( variables.metadata.autowire ) ? true : variables.metadata.autowire );
		}
		return this;
	}

	/**
	 * Get or construct a ColdBox Virtual Application
	 */
	function getColdBoxVirtualApp(){
		if ( isNull( request.coldBoxVirtualApp ) ) {
			request.coldBoxVirtualApp = new coldbox.system.testing.VirtualApp(
				appMapping = variables.appMapping,
				configPath = variables.configMapping,
				webMapping = variables.webMapping
			);
		}
		return request.coldBoxVirtualApp;
	}

	/**
	 * The main setup method for running ColdBox Integration enabled tests
	 */
	function beforeTests(){
		// metadataInspection
		metadataInspection();

		// Load ColdBox Application for testing?
		if ( this.loadColdbox ) {
			// Startit up!
			variables.controller = getColdBoxVirtualApp().startup();
			// Auto registration of test as interceptor
			variables.controller.getInterceptorService().registerInterceptor( interceptorObject = this );
			// Do we need to autowire this test?
			if ( variables.autowire ) {
				variables.controller.getWireBox().autowire( target: this, targetId: variables.metadata.path );
			}
		}

		// Let's add the ColdBox Custom Matchers
		addMatchers( "coldbox.system.testing.CustomMatchers" );
	}

	/**
	 * This executes before any test method for integration tests
	 */
	function setup(){
		// Are we doing integration tests
		if ( this.loadColdbox ) {
			if ( !getColdBoxVirtualApp().isRunning() ) {
				beforeTests();
			}
			// remove context + reset headers
			variables.controller.getRequestService().removeContext();
			getPageContextResponse().reset();
			structDelete( request, "_lastInvalidEvent" );
		}
	}

	/**
	 * xUnit: The main teardown for ColdBox enabled applications after all tests execute
	 */
	function afterTests(){
		if ( this.unLoadColdbox ) {
			getColdBoxVirtualApp().shutdown();
		}
	}

	/**
	 * BDD: The main setup method for running ColdBox Integration enabled tests
	 */
	function beforeAll(){
		if ( isNull( variables._ranBeforeAll ) ) {
			beforeTests();
			variables._ranBeforeAll = true;
		}
	}

	/**
	 * BDD: The main teardown for ColdBox enabled applications after all tests execute
	 */
	function afterAll(){
		if ( isNull( variables._ranAfterAll ) ) {
			afterTests();
			variables._ranAfterAll = true;
		}
	}

	/**
	 * Reset the persistence of the unit test coldbox app, basically removes the controller from application scope
	 *
	 * @orm         Reload ORM or not
	 * @wipeRequest Wipe the request scope
	 *
	 * @return BaseTestCase
	 */
	function reset( boolean orm = false, boolean wipeRequest = true ){
		// Shutdown gracefully ColdBox
		getColdBoxVirtualApp().shutdown();

		// Lucee Cleanups
		if ( server.keyExists( "lucee" ) ) {
			pagePoolClear();
		}

		// ORM
		if ( arguments.orm ) {
			ormReload();
		}

		// Wipe out request scope.
		if ( arguments.wipeRequest && !structIsEmpty( request ) ) {
			lock type="exclusive" scope="request" timeout=10 {
				if ( !structIsEmpty( request ) ) {
					structClear( request );
				}
			}
		}

		return this;
	}

	/********************************************* MOCKING METHODS *********************************************/

	/**
	 * I will return a mock controller object
	 *
	 * @return coldbox.system.testing.mock.web.MockController
	 */
	function getMockController(){
		return prepareMock( new coldbox.system.testing.mock.web.MockController( "/unittest", "unitTest" ) );
	}

	/**
	 * Builds an empty functioning request context mocked with methods via MockBox.  You can also optionally wipe all methods on it
	 *
	 * @clearMethods Clear methods on the object
	 * @decorator    The class path to the decorator to build into the mock request context
	 *
	 * @return coldbox.system.web.context.RequestContext
	 */
	function getMockRequestContext( boolean clearMethods = false, decorator ){
		var mockRC         = "";
		var mockController = "";
		var rcProps        = structNew();

		if ( arguments.clearMethods ) {
			if ( structKeyExists( arguments, "decorator" ) ) {
				return getMockBox().createEmptyMock( arguments.decorator );
			}
			return getMockBox().createEmptyMock( "coldbox.system.web.context.RequestContext" );
		}

		// Create functioning request context
		mockRC         = getMockBox().createMock( "coldbox.system.web.context.RequestContext" );
		mockController = createObject( "component", "coldbox.system.testing.mock.web.MockController" ).init(
			"/unittest",
			"unitTest"
		);

		// Create mock properties
		rcProps.defaultLayout     = "";
		rcProps.defaultView       = "";
		rcProps.sesBaseURL        = "http://localhost";
		rcProps.eventName         = "event";
		rcProps.viewLayouts       = structNew();
		rcProps.folderLayouts     = structNew();
		rcProps.registeredLayouts = structNew();
		rcProps.modules           = structNew();
		mockRC.init( properties = rcProps, controller = mockController );

		// return decorator context
		if ( structKeyExists( arguments, "decorator" ) ) {
			return getMockBox().createMock( arguments.decorator ).init( mockRC, mockController );
		}

		// return normal RC
		return mockRC;
	}

	/**
	 * ColdBox must be loaded for this to work. Get a mock model object by convention. You can optional clear all the methods on the model object if you wanted to. The object is created but not initiated, that would be your job.
	 *
	 * @name         The name of the model to mock and return back
	 * @clearMethods Clear methods on the object
	 */
	function getMockModel( required name, boolean clearMethods = false ){
		var mockLocation = getController().getWireBox().locateInstance( arguments.name );

		if ( len( mockLocation ) ) {
			return getMockBox().createMock( className = mockLocation, clearMethods = arguments.clearMethods );
		} else {
			throw(
				message = "Model object #arguments.name# could not be located.",
				type    = "ModelNotFoundException"
			);
		}
	}

	/********************************************* APP RETRIEVAL METHODS *********************************************/

	/**
	 * Get the WireBox reference from the running application
	 *
	 * @return coldbox.system.ioc.Injector
	 */
	function getWireBox(){
		return variables.controller.getwireBox();
	}

	/**
	 * Get the CacheBox reference from the running application
	 *
	 * @return coldbox.system.cache.CacheFactory
	 */
	function getCacheBox(){
		return variables.controller.getCacheBox();
	}

	/**
	 * Get the CacheBox reference from the running application
	 *
	 * @cacheName The cache name to retrieve or returns the 'default' cache by default.
	 *
	 * @return coldbox.system.cache.providers.ICacheProvider
	 */
	function getCache( required cacheName = "default" ){
		return variables.controller.getCache( arguments.cacheName );
	}

	/**
	 * Get the LogBox reference from the running application
	 *
	 * @return coldbox.system.logging.LogBox
	 */
	function getLogBox(){
		return variables.controller.getLogBox();
	}

	/**
	 * Get the RequestContext reference from the running application
	 *
	 * @return coldbox.system.web.context.RequestContext
	 */
	function getRequestContext(){
		return variables.controller
			.getRequestService()
			.getContext( "coldbox.system.testing.mock.web.context.MockRequestContext" );
	}

	/**
	 * Get the RequestContext reference from the running application
	 *
	 * @return coldbox.system.web.Flash.AbstractFlashScope
	 */
	function getFlashScope(){
		return variables.controller.getRequestService().getFlashScope();
	}

	/********************************************* APPLICATION EXECUTION METHODS *********************************************/

	/**
	 * Setup an initial request capture.  I basically look at the FORM/URL scopes and create the request collection out of them.
	 *
	 * @event The event to setup the request context with, simulates the URL/FORM.event
	 *
	 * @return BaseTestCase
	 */
	function setupRequest( required event ){
		var eventName     = variables.controller.getSetting( "eventName" );
		// Setup the incoming event
		URL[ eventName ]  = arguments.event;
		FORM[ eventName ] = arguments.event;
		// Capture the request
		variables.controller.getRequestService().requestCapture( arguments.event );
		return this;
	}

	/**
	 * Executes a framework lifecycle by executing an event.
	 * This method returns a request context object that is decorated and can be used for assertions.
	 *
	 * @event                 The event to execute (e.g. 'main.index')
	 * @route                 The route to execute (e.g. '/login' which may route to 'sessions.new')
	 * @private               Call a private event or not.
	 * @prePostExempt         If true, pre/post handlers will not be fired.
	 * @eventArguments        A collection of arguments to passthrough to the calling event handler method.
	 * @renderResults         If true, then it will try to do the normal rendering procedures and store the rendered content in the RC as cbox_rendered_content.
	 * @withExceptionHandling If true, then ColdBox will process any errors through the exception handling framework instead of just throwing the error. Default: false.
	 * @domain                Override the domain of execution of the request. Default is to use the cgi.server_name variable.
	 *
	 * @return coldbox.system.context.RequestContext
	 */
	function execute(
		string event                  = "",
		string route                  = "",
		string queryString            = "",
		boolean private               = false,
		boolean prePostExempt         = false,
		struct eventArguments         = {},
		boolean renderResults         = false,
		boolean withExceptionHandling = false,
		domain                        = cgi.SERVER_NAME
	){
		var handlerResults  = "";
		var requestContext  = getRequestContext();
		var relocationTypes = "TestController.relocate";
		var cbController    = getController();
		var requestService  = cbController.getRequestService();
		var routingService  = cbController.getRoutingService();
		var renderData      = "";
		var renderedContent = "";
		var iData           = {};

		if ( arguments.event == "" && arguments.route == "" ) {
			throw( "Must provide either an event or a route to the execute() method." );
		}

		try {
			// Make sure our routing service can be manipulated
			prepareMock( routingService )
				.$( "getCGIElement" )
				.$args( "script_name", requestContext )
				.$results( "" )
				.$( "getCGIElement" )
				.$args( "server_name", requestContext )
				.$results( arguments.domain );

			// If the route is for the home page, use the default event in the config/ColdBox.cfc
			if ( arguments.route == "/" ) {
				// Set the default app event
				arguments.event = getController().getSetting( "defaultEvent" );
				requestContext.setValue( requestContext.getEventName(), arguments.event );
				// Prepare all mocking data for simulating routing request
				routingService
					.$( "getCGIElement" )
					.$args( "path_info", requestContext )
					.$results( arguments.route );
				// No route, it's the route
				arguments.route = "";
				// Capture the route request
				controller.getRequestService().requestCapture();
			}
			// if we were passed a route, parse it and prepare the SES interceptor for routing.
			else if ( arguments.route.len() ) {
				// enable the SES interceptor
				// getInstance( "router@coldbox" ).setEnabled( true );
				// separate the route into the route and the query string
				var routeParts = explodeRoute( arguments.route );
				// add the query string parameters from the route to the request context
				requestContext.collectionAppend( routeParts.queryStringCollection );
				// mock the cleaned paths so SES routes will be recognized
				prepareMock( routingService )
					.$( "getCGIElement" )
					.$args( "path_info", requestContext )
					.$results( routeParts.route );
				// Capture the route request
				controller.getRequestService().requestCapture();
			} else {
				// If we were passed just an event, remove routing since we don't need it
				// getInstance( "router@coldbox" ).setEnabled( false );
				// Capture the request using our passed in event to execute
				controller.getRequestService().requestCapture( arguments.event );
				routingService
					.$( "getCGIElement" )
					.$args( "path_info", requestContext )
					.$results( "" );
			}

			// add the query string parameters from the route to the request context
			requestContext.collectionAppend( parseQueryString( arguments.queryString ) );

			// Setup the request Context with setup FORM/URL variables set in the unit test.
			requestService.setContext( requestContext );
			// setupRequest( arguments.event );

			// App Start Handler
			if ( len( cbController.getSetting( "ApplicationStartHandler" ) ) ) {
				cbController.runEvent( cbController.getSetting( "ApplicationStartHandler" ), true );
			}

			// preProcess
			cbController.getInterceptorService().announce( "preProcess" );

			// Request Start Handler
			if ( len( cbController.getSetting( "RequestStartHandler" ) ) ) {
				cbController.runEvent( cbController.getSetting( "RequestStartHandler" ), true );
			}

			// grab the latest event in the context, in case overrides occur
			requestContext  = getRequestContext();
			arguments.event = requestContext.getCurrentEvent();

			// TEST EVENT EXECUTION
			if ( NOT requestContext.getIsNoExecution() ) {
				// execute the event
				handlerResults = cbController.runEvent(
					event          = arguments.event,
					private        = arguments.private,
					prepostExempt  = arguments.prepostExempt,
					eventArguments = arguments.eventArguments,
					defaultEvent   = true
				);

				// Are we doing rendering procedures?
				if ( arguments.renderResults ) {
					// preLayout
					cbController.getInterceptorService().announce( "preLayout" );

					// Render Data?
					renderData = requestContext.getRenderData();
					if ( isStruct( renderData ) and NOT structIsEmpty( renderData ) ) {
						requestContext.setValue( "cbox_render_data", renderData );
						requestContext.setValue( "cbox_statusCode", renderData.statusCode );
						renderedContent = cbController
							.getDataMarshaller()
							.marshallData( argumentCollection = renderData );
					}
					// If we have handler results save them in our context for assertions
					else if ( !isNull( local.handlerResults ) ) {
						// Store raw results
						requestContext.setValue( "cbox_handler_results", handlerResults );
						requestContext.setValue( "cbox_statusCode", getNativeStatusCode() );
						if ( isSimpleValue( handlerResults ) ) {
							renderedContent = handlerResults;
						} else {
							renderedContent = serializeJSON( handlerResults );
						}
					}
					// render layout/view pair
					else {
						requestContext.setValue( "cbox_statusCode", getNativeStatusCode() );
						renderedContent = cbcontroller
							.getRenderer()
							.renderLayout(
								module     = requestContext.getCurrentLayoutModule(),
								viewModule = requestContext.getCurrentViewModule()
							);
					}

					// Pre Render
					iData = { renderedContent : renderedContent };
					cbController.getInterceptorService().announce( "preRender", iData );
					renderedContent = iData.renderedContent;

					// Store in collection for assertions
					requestContext.setValue( "cbox_rendered_content", renderedContent );

					// postRender
					cbController.getInterceptorService().announce( "postRender" );
				}
			}

			// Request End Handler
			if ( len( cbController.getSetting( "RequestEndHandler" ) ) ) {
				cbController.runEvent( cbController.getSetting( "RequestEndHandler" ), true );
			}

			// postProcess
			cbController.getInterceptorService().announce( "postProcess" );
		} catch ( "InterceptorService.InterceptorNotFound" e ) {
			// In either case, if the interceptor doesn't exists, just ignore it.
		} catch ( any e1 ) {
			// Are we doing exception handling?
			if ( arguments.withExceptionHandling ) {
				try {
					processException( cbController, e1 );
				} catch ( any e2 ) {
					// Exclude relocations so they can be asserted.
					if ( NOT listFindNoCase( relocationTypes, e2.type ) ) {
						rethrow;
					}
				}
				// Exclude relocations so they can be asserted.
			} else if ( NOT listFindNoCase( relocationTypes, e1.type ) ) {
				rethrow;
			}
		}

		// Return the correct event context.
		requestContext = getRequestContext();

		// Add in the test helpers for convenience
		requestContext.getRenderedContent = variables.getRenderedContent;
		requestContext.getHandlerResults  = variables.getHandlerResults;
		requestContext.getRenderData      = variables.getRenderData;
		requestContext.getStatusCode      = variables.getStatusCode;
		return requestContext;
	}

	/**
	 * Shortcut method to making a request through the framework.
	 *
	 * @route                 The route to execute.
	 * @params                Params to pass to the `rc` scope.
	 * @headers               Custom headers to pass as from the request
	 * @method                The method type to execute.  Defaults to GET.
	 * @renderResults         If true, then it will try to do the normal rendering procedures and store the rendered content in the RC as cbox_rendered_content
	 * @withExceptionHandling If true, then ColdBox will process any errors through the exception handling framework instead of just throwing the error. Default: false.
	 * @domain                Override the domain of execution of the request. Default is to use the cgi.server_name variable.
	 */
	function request(
		string route                  = "",
		struct params                 = {},
		struct headers                = {},
		string method                 = "GET",
		boolean renderResults         = true,
		boolean withExceptionHandling = false,
		domain                        = cgi.SERVER_NAME
	){
		var mockedEvent = prepareMock( getRequestContext() ).$( "getHTTPMethod", uCase( arguments.method ) );
		arguments.params
			.keyArray()
			.each( function( name ){
				mockedEvent.setValue( arguments.name, params[ arguments.name ] );
			} );
		arguments.headers
			.keyArray()
			.each( function( name ){
				mockedEvent
					.$( "getHTTPHeader" )
					.$args( arguments.name )
					.$results( headers[ arguments.name ] );
			} );
		return this.execute( argumentCollection = arguments );
	}

	/**
	 * Shortcut method to making a GET request through the framework.
	 *
	 * @route                 The route to execute.
	 * @params                Params to pass to the `rc` scope.
	 * @headers               Custom headers to pass as from the request
	 * @renderResults         If true, then it will try to do the normal rendering procedures and store the rendered content in the RC as cbox_rendered_content
	 * @withExceptionHandling If true, then ColdBox will process any errors through the exception handling framework instead of just throwing the error. Default: false.
	 * @domain                Override the domain of execution of the request. Default is to use the cgi.server_name variable.
	 */
	function get(
		string route                  = "",
		struct params                 = {},
		struct headers                = {},
		boolean renderResults         = true,
		boolean withExceptionHandling = false,
		domain                        = cgi.SERVER_NAME
	){
		arguments.method = "GET";
		return variables.request( argumentCollection = arguments );
	}

	/**
	 * Shortcut method to making a POST request through the framework.
	 *
	 * @route                 The route to execute.
	 * @params                Params to pass to the `rc` scope.
	 * @headers               Custom headers to pass as from the request
	 * @renderResults         If true, then it will try to do the normal rendering procedures and store the rendered content in the RC as cbox_rendered_content
	 * @withExceptionHandling If true, then ColdBox will process any errors through the exception handling framework instead of just throwing the error. Default: false.
	 * @domain                Override the domain of execution of the request. Default is to use the cgi.server_name variable.
	 */
	function post(
		string route                  = "",
		struct params                 = {},
		struct headers                = {},
		boolean renderResults         = true,
		boolean withExceptionHandling = false,
		domain                        = cgi.SERVER_NAME
	){
		arguments.method = "POST";
		return variables.request( argumentCollection = arguments );
	}

	/**
	 * Shortcut method to making a PUT request through the framework.
	 *
	 * @route                 The route to execute.
	 * @params                Params to pass to the `rc` scope.
	 * @headers               Custom headers to pass as from the request
	 * @renderResults         If true, then it will try to do the normal rendering procedures and store the rendered content in the RC as cbox_rendered_content
	 * @withExceptionHandling If true, then ColdBox will process any errors through the exception handling framework instead of just throwing the error. Default: false.
	 * @domain                Override the domain of execution of the request. Default is to use the cgi.server_name variable.
	 */
	function put(
		string route                  = "",
		struct params                 = {},
		struct headers                = {},
		boolean renderResults         = true,
		boolean withExceptionHandling = false,
		domain                        = cgi.SERVER_NAME
	){
		arguments.method = "PUT";
		return variables.request( argumentCollection = arguments );
	}

	/**
	 * Shortcut method to making a PATCH request through the framework.
	 *
	 * @route                 The route to execute.
	 * @params                Params to pass to the `rc` scope.
	 * @headers               Custom headers to pass as from the request
	 * @renderResults         If true, then it will try to do the normal rendering procedures and store the rendered content in the RC as cbox_rendered_content
	 * @withExceptionHandling If true, then ColdBox will process any errors through the exception handling framework instead of just throwing the error. Default: false.
	 * @domain                Override the domain of execution of the request. Default is to use the cgi.server_name variable.
	 */
	function patch(
		string route                  = "",
		struct params                 = {},
		struct headers                = {},
		boolean renderResults         = true,
		boolean withExceptionHandling = false,
		domain                        = cgi.SERVER_NAME
	){
		arguments.method = "PATCH";
		return variables.request( argumentCollection = arguments );
	}

	/**
	 * Shortcut method to making a DELETE request through the framework.
	 *
	 * @route                 The route to execute.
	 * @params                Params to pass to the `rc` scope.
	 * @headers               Custom headers to pass as from the request
	 * @renderResults         If true, then it will try to do the normal rendering procedures and store the rendered content in the RC as cbox_rendered_content
	 * @withExceptionHandling If true, then ColdBox will process any errors through the exception handling framework instead of just throwing the error. Default: false.
	 * @domain                Override the domain of execution of the request. Default is to use the cgi.server_name variable.
	 */
	function delete(
		string route                  = "",
		struct params                 = {},
		struct headers                = {},
		boolean renderResults         = true,
		boolean withExceptionHandling = false,
		domain                        = cgi.SERVER_NAME
	){
		arguments.method = "DELETE";
		return variables.request( argumentCollection = arguments );
	}

	/**
	 * Get the rendered content from a ColdBox integration test
	 *
	 * @return cbox_rendered_content or an empty string
	 */
	function getRenderedContent(){
		return getValue( "cbox_rendered_content", "" );
	}

	/**
	 * Get the results from a handler execution if any
	 *
	 * @return The handler results or an empty string
	 */
	function getHandlerResults(){
		return getValue( "cbox_handler_results", "" );
	}

	/**
	 * Get the render data struct for a ColdBox integration test
	 *
	 * @return cbox_render_data or an empty struct
	 */
	function getRenderData(){
		return getPrivateValue( name = "cbox_renderdata", defaultValue = structNew() );
	}

	/**
	 * Get the status code for a ColdBox integration test
	 *
	 * @return cbox_statusCode or 200
	 */
	function getStatusCode(){
		return getValue( "relocate_STATUSCODE", getValue( "cbox_statusCode", 200 ) );
	}

	/**
	 * Get the status code set in the CFML engine.
	 *
	 * @return The CFML status code.
	 */
	function getNativeStatusCode(){
		return getPageContextResponse().getStatus();
	}

	/**
	 * Announce an interception
	 *
	 * @state            The interception state to announce
	 * @data             A data structure used to pass intercepted information.
	 * @async            If true, the entire interception chain will be ran in a separate thread.
	 * @asyncAll         If true, each interceptor in the interception chain will be ran in a separate thread and then joined together at the end.
	 * @asyncAllJoin     If true, each interceptor in the interception chain will be ran in a separate thread and joined together at the end by default.  If you set this flag to false then there will be no joining and waiting for the threads to finalize.
	 * @asyncPriority    The thread priority to be used. Either LOW, NORMAL or HIGH. The default value is NORMAL
	 * @asyncJoinTimeout The timeout in milliseconds for the join thread to wait for interceptor threads to finish.  By default there is no timeout.
	 *
	 * @return struct of thread information or void
	 */
	function announce(
		required state,
		struct data              = {},
		boolean async            = false,
		boolean asyncAll         = false,
		boolean asyncAllJoin     = true,
		asyncPriority            = "NORMAL",
		numeric asyncJoinTimeout = 0
	){
		// Backwards Compat: Remove by ColdBox 7
		if ( !isNull( arguments.interceptData ) ) {
			arguments.data = arguments.interceptData;
		}
		return getController().getInterceptorService().announce( argumentCollection = arguments );
	}

	/**
	 * @deprecated Please use `announce()` instead
	 */
	function announceInterception(
		required state,
		struct interceptData     = {},
		boolean async            = false,
		boolean asyncAll         = false,
		boolean asyncAllJoin     = true,
		asyncPriority            = "NORMAL",
		numeric asyncJoinTimeout = 0
	){
		arguments.data = arguments.interceptData;
		return announce( argumentCollection = arguments );
	}

	/**
	 * Get an interceptor reference
	 *
	 * @interceptorName The name of the interceptor to retrieve
	 *
	 * @return Interceptor
	 */
	function getInterceptor( required interceptorName ){
		return getController().getInterceptorService().getInterceptor( argumentCollection = arguments );
	}

	/**
	 * @deprecated
	 */
	function getModel(){
		throw(
			message = "getModel() is now fully deprecated in favor of getInstance().",
			type    = "DeprecationException"
		);
	}

	/**
	 * Locates, Creates, Injects and Configures an object model instance
	 *
	 * @name          The mapping name or CFC instance path to try to build up
	 * @initArguments The constructor structure of arguments to passthrough when initializing the instance
	 * @dsl           The dsl string to use to retrieve the instance model object, mutually exclusive with 'name
	 * @targetObject  The object requesting the dependency, usually only used by DSL lookups
	 * @injector      The child injector to use when retrieving the instance
	 *
	 * @return The requested instance
	 *
	 * @throws InstanceNotFoundException - When the requested instance cannot be found
	 * @throws InvalidChildInjector      - When you request an instance from an invalid child injector name
	 **/
	function getInstance(
		name,
		struct initArguments = {},
		dsl,
		targetObject = "",
		injector
	){
		return getController().getWireBox().getInstance( argumentCollection = arguments );
	}

	/**
	 * Get the ColdBox global utility class
	 *
	 * @return coldbox.system.core.util.Util
	 */
	function getUtil(){
		return new coldbox.system.core.util.Util();
	}

	/**
	 * Separate a route into two parts: the base route, and a query string collection
	 *
	 * @route a string containing the route with an optional query string (e.g. '/posts?recent=true')
	 *
	 * @return a struct containing the base route and a struct of query string parameters
	 */
	private struct function explodeRoute( required string route ){
		var routeParts = listToArray( urlDecode( arguments.route ), "?" );

		var queryParams = {};
		if ( arrayLen( routeParts ) > 1 ) {
			queryParams = parseQueryString( routeParts[ 2 ] );
		}

		return {
			route                 : routeParts[ 1 ],
			queryStringCollection : queryParams
		};
	}

	/**
	 * Parses a query string into a struct
	 *
	 * @queryString a query string from a URI
	 *
	 * @return a struct of query string parameters
	 */
	private struct function parseQueryString( required string queryString ){
		var queryParams = {};

		queryString
			.listToArray( "&" )
			.each( function( item ){
				queryParams[ urlDecode( item.getToken( 1, "=" ) ) ] = urlDecode( item.getToken( 2, "=" ) );
			} );

		return queryParams;
	}

	/**
	 * Process an exception and returns a rendered bug report
	 *
	 * @controller The ColdBox Controller
	 * @exception  The ColdFusion exception
	 */
	private string function processException( required controller, required exception ){
		// prepare exception facade object + app logger
		var oException = new coldbox.system.web.context.ExceptionBean( arguments.exception );
		var appLogger  = arguments.controller.getLogBox().getLogger( this );
		var event      = arguments.controller.getRequestService().getContext();
		var rc         = event.getCollection();
		var prc        = event.getPrivateCollection();

		// Announce interception
		arguments.controller.getInterceptorService().announce( "onException", { exception : arguments.exception } );

		// Store exception in private context
		event.setPrivateValue( "exception", oException );

		// Set Exception Header
		getPageContextResponse().setStatus( 500, "Internal Server Error" );

		// Run custom Exception handler if Found, else run default exception routines
		if ( len( arguments.controller.getSetting( "ExceptionHandler" ) ) ) {
			try {
				arguments.controller.runEvent( arguments.controller.getSetting( "Exceptionhandler" ) );
			} catch ( Any e ) {
				// Log Original Error First
				appLogger.error(
					"Original Error: #arguments.exception.message# #arguments.exception.detail# ",
					arguments.exception
				);
				// Log Exception Handler Error
				appLogger.error(
					"Error running exception handler: #arguments.controller.getSetting( "ExceptionHandler" )# #e.message# #e.detail#",
					e
				);
				// rethrow error
				rethrow;
			}
		} else {
			// Log Error
			appLogger.error(
				"Error: #arguments.exception.message# #arguments.exception.detail# ",
				arguments.exception
			);
		}

		// Render out error via CustomErrorTemplate or Core
		var customErrorTemplate = arguments.controller.getSetting( "CustomErrorTemplate" );
		if ( len( customErrorTemplate ) ) {
			// Get app location path
			var appLocation = "/";
			if ( len( arguments.controller.getSetting( "AppMapping" ) ) ) {
				appLocation = appLocation & arguments.controller.getSetting( "AppMapping" ) & "/";
			}
			var bugReportRelativePath = appLocation & reReplace( customErrorTemplate, "^/", "" );
			var bugReportAbsolutePath = customErrorTemplate;

			// Show Bug Report
			savecontent variable="local.exceptionReport" {
				// Do we have right path already, test by expanding
				if ( fileExists( expandPath( bugReportRelativePath ) ) ) {
					include "#bugReportRelativePath#";
				} else {
					include "#bugReportAbsolutePath#";
				}
			}
		} else {
			// Default ColdBox Error Template
			savecontent variable="local.exceptionReport" {
				include "/coldbox/system/exceptions/BugReport-Public.cfm";
			}
		}

		return local.exceptionReport;
	}

	/**
	 * Helper method to deal with ACF2016's overload of the page context response, come on Adobe, get your act together!
	 **/
	private function getPageContextResponse(){
		if ( structKeyExists( server, "lucee" ) ) {
			return getPageContext().getResponse();
		} else {
			return getPageContext().getResponse().getResponse();
		}
	}

}
