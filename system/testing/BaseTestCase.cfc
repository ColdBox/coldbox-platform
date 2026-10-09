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
	this.loadColdbox   = true;
	this.unLoadColdBox = false;

	// Internal Properties
	variables.appMapping    = "";
	variables.webMapping    = "";
	variables.configMapping = "";
	variables.controller    = application.keyExists( "cbController" ) ? application.cbController : "";
	variables.autowire      = false;
	variables.metadata      = {};

	/********************************************* LIFE-CYCLE METHODS *********************************************/

	/**
	 * Inspect test case for ColdBox loading annotations and autowiring
	 *
	 * @return BaseTestCase
	 */
	function metadataInspection(){
		variables.metadata = getUtil().getInheritedMetadata( this );
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

			// Reset the buffer if not committed
			if ( !getPageContextResponse().isCommitted() ) {
				getPageContextResponse().reset();
			}

			structDelete( request, "_lastInvalidEvent" );
		}
	}

	/**
	 * xUnit: The main teardown for ColdBox enabled applications after all tests execute
	 */
	function afterTests(){
		if ( this.unLoadColdbox ) {
			reset( wipeRequest: true );
		}
	}

	/**
	 * BDD: The main setup method for running ColdBox Integration enabled tests
	 */
	function beforeAll(){
		if ( !structKeyExists( variables, "_ranBeforeAll" ) || isNull( variables._ranBeforeAll ) ) {
			beforeTests();
			variables._ranBeforeAll = true;
		}
	}

	/**
	 * BDD: The main teardown for ColdBox enabled applications after all tests execute
	 */
	function afterAll(){
		if ( !structKeyExists( variables, "_ranAfterAll" ) || isNull( variables._ranAfterAll ) ) {
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
		getColdBoxVirtualApp().shutdown( force: true );

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
			if ( !isNull( arguments.decorator ) ) {
				return getMockBox().createEmptyMock( arguments.decorator );
			}
			return getMockBox().createEmptyMock( "coldbox.system.web.context.RequestContext" );
		}

		// Create functioning request context
		mockRC         = getMockBox().createMock( "coldbox.system.web.context.RequestContext" );
		mockController = !isSimpleValue( variables.controller ) ? prepareMock( variables.controller ) : getMockController();

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
		if ( !isNull( arguments.decorator ) ) {
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
		return variables.controller.getWireBox();
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
		string domain                 = cgi.SERVER_NAME
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
				.$args( "path_info", requestContext )
				.$results( "" )
				.$( "getCGIElement" )
				.$args( "script_name", requestContext )
				.$results( "" )
				.$( "getCGIElement" )
				.$args( "server_name", requestContext )
				.$results( arguments.domain );

			// If the route is for the home page, use the default event in the config/ColdBox
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
					.$results( "" )
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
			// Route-scoped middleware runs after the global preProcess chain, just like the Bootstrap does
			routingService.runRouteMiddleware( getRequestContext(), "preProcess" );

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
						requestContext.setStatusCode( renderData.statusCode );
						renderedContent = cbController
							.getDataMarshaller()
							.marshallData( argumentCollection = renderData );
					}
					// If we have handler results save them in our context for assertions
					else if ( !isNull( local.handlerResults ) ) {
						// Store raw results
						requestContext.setValue( "cbox_handler_results", handlerResults );
						if ( isSimpleValue( handlerResults ) ) {
							renderedContent = handlerResults;
						} else {
							renderedContent = getUtil().toJson( handlerResults );
						}
					}
					// Skip rendering if event.noRender is set
					else if ( requestContext.getPrivateValue( "coldbox_norender", false ) ) {
						renderedContent = "";
					}
					// render layout/view pair
					else {
						renderedContent = cbcontroller
							.getRenderer()
							.layout(
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

			// Route-scoped middleware runs before the global postProcess chain, just like the Bootstrap does
			routingService.runRouteMiddleware( getRequestContext(), "postProcess" );
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
	 * @body                  The body content to be passed in the request, useful for POST/PUT/PATCH requests.
	 */
	function request(
		string route                  = "",
		struct params                 = {},
		struct headers                = {},
		string method                 = "GET",
		boolean renderResults         = true,
		boolean withExceptionHandling = false,
		string domain                 = cgi.SERVER_NAME,
		any body                      = ""
	){
		// Mock the event context
		var mockedEvent = prepareMock( getRequestContext() )
			// Mock the HTTP method
			.$( "getHTTPMethod", uCase( arguments.method ) )
			// Mock the body content
			.$( "getHttpContent", arguments.body )

		// Add params to the request collection
		arguments.params
			.keyArray()
			.each( ( name ) => {
				mockedEvent.setValue( arguments.name, params[ arguments.name ] )
			} )

		// Add headers to the request collection
		arguments.headers
			.keyArray()
			.each( ( name ) => {
				mockedEvent
					.$( "getHTTPHeader" )
					.$args( arguments.name )
					.$results( headers[ arguments.name ] )
			} )

		// Funnel through the main execute method
		return this.execute( argumentCollection: arguments )
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
	 * @body                  The body content to be passed in the request, useful for PUT/PATCH requests.
	 */
	function get(
		string route                  = "",
		struct params                 = {},
		struct headers                = {},
		boolean renderResults         = true,
		boolean withExceptionHandling = false,
		string domain                 = cgi.SERVER_NAME,
		any body                      = ""
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
	 * @body                  The body content to be passed in the request, useful for POST/PUT/PATCH requests.
	 */
	function post(
		string route                  = "",
		struct params                 = {},
		struct headers                = {},
		boolean renderResults         = true,
		boolean withExceptionHandling = false,
		string domain                 = cgi.SERVER_NAME,
		any body                      = ""
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
	 * @body                  The body content to be passed in the request, useful for POST/PUT/PATCH requests.
	 */
	function put(
		string route                  = "",
		struct params                 = {},
		struct headers                = {},
		boolean renderResults         = true,
		boolean withExceptionHandling = false,
		string domain                 = cgi.SERVER_NAME,
		any body                      = ""
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
	 * @body                  The body content to be passed in the request, useful for POST/PUT/PATCH requests.
	 */
	function patch(
		string route                  = "",
		struct params                 = {},
		struct headers                = {},
		boolean renderResults         = true,
		boolean withExceptionHandling = false,
		string domain                 = cgi.SERVER_NAME,
		any body                      = ""
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
	 * @body                  The body content to be passed in the request, useful for POST/PUT/PATCH requests.
	 */
	function delete(
		string route                  = "",
		struct params                 = {},
		struct headers                = {},
		boolean renderResults         = true,
		boolean withExceptionHandling = false,
		string domain                 = cgi.SERVER_NAME,
		any body                      = ""
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
		if ( structKeyExists( arguments, "interceptData" ) && !isNull( arguments.interceptData ) ) {
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
		if ( !structKeyExists( variables, "cbUtil" ) || isNull( variables.cbUtil ) ) {
			variables.cbUtil = new coldbox.system.core.util.Util();
		}
		return variables.cbUtil;
	}

	/**
	 * Get the ColdBox Env Class
	 *
	 * @return coldbox.system.core.delegates.Env
	 */
	function getEnv(){
		if ( !structKeyExists( variables, "env" ) || isNull( variables.env ) ) {
			variables.env = new coldbox.system.core.delegates.Env();
		}
		return variables.env;
	}

	/********************************************* BROWSER TESTING ROUTE HELPERS *********************************************/

	/**
	 * The path of a named route, without scheme and host, built by ColdBox's own event.route(), so it carries
	 * the routing app mapping and, for module routes (`name@module` or `module:name`), the module entry point.
	 * Use it with TestBox browser specs: annotate the test with `@browser`, `@browserProfile` or `@baseURL`.
	 *
	 * <pre>
	 * routeURL( "users.show", { id : 5 } )   // /users/5/
	 * routeURL( "home@blog" )                // /blog/home/
	 * </pre>
	 *
	 * @name   The route name, `name@module` or `module:name` for module routes
	 * @params The route placeholder values, for example { id : 5 }
	 *
	 * @return The route path, with the query string when the link has one
	 *
	 * @throws InvalidArgumentException When the named route does not exist
	 */
	string function routeURL( required string name, struct params = {} ){
		return routeLinkPath( getRequestContext().route( arguments.name, arguments.params ) )
	}

	/**
	 * Visit a named route with a bx-playwright page: page.visit( routeURL( name, params ) ). Relative routes
	 * resolve against the browser spec `baseURL`.
	 *
	 * @page   The bx-playwright page, from browse()
	 * @name   The route name, `name@module` or `module:name` for module routes
	 * @params The route placeholder values, for example { id : 5 }
	 *
	 * @return The page
	 */
	function visitRoute(
		required page,
		required string name,
		struct params = {}
	){
		arguments.page.visit( routeURL( arguments.name, arguments.params ) )
		return arguments.page
	}

	/**
	 * Assert that a bx-playwright page is on a named route. With params, the page path must be the path of
	 * routeURL( name, params ). Without params, the page path must match the route pattern, so any value of
	 * its placeholders passes. Like ColdBox routing, the match ignores case and the trailing slash, and the
	 * query string and hash are ignored. It waits for the page URL with bx-playwright's waitForUrl(), up to the
	 * bx-playwright assertion timeout (the `timeouts.assertion` setting).
	 *
	 * <pre>
	 * assertRouteIs( page, "users.show" )               // any user
	 * assertRouteIs( page, "users.show", { id : 5 } )   // user 5
	 * </pre>
	 *
	 * @page   The bx-playwright page, from browse()
	 * @name   The route name, `name@module` or `module:name` for module routes
	 * @params The route placeholder values, empty to match any value of the placeholders
	 *
	 * @return The page
	 *
	 * @throws TestBox.AssertionFailed When the page path does not match the route before the assertion timeout
	 */
	function assertRouteIs(
		required page,
		required string name,
		struct params = {}
	){
		var expected  = "route [#arguments.name#]"
		var pathRegex = ""
		if ( arguments.params.isEmpty() ) {
			pathRegex = routePathRegex( arguments.name )
		} else {
			expected  = "route [#arguments.name#] with params #serializeJSON( arguments.params )#"
			pathRegex = quoteRouteRegex(
				reReplace(
					routeLinkPath( routeURL( arguments.name, arguments.params ), false ),
					"/+$",
					""
				)
			)
		}
		var urlRegex = "^[a-zA-Z][a-zA-Z0-9+.-]*://[^/]*" & pathRegex & "/?(\?.*)?(##.*)?$"
		var timeout  = arguments.page.getConfig().timeouts.assertion ?: 5000
		try {
			arguments.page.waitForUrl( arguments.page.regex( urlRegex, "i" ), timeout )
		} catch ( any e ) {
			if ( !listFindNoCase( "Playwright.Timeout,Playwright.AssertionFailed", e.type ) ) {
				throw( object = e )
			}
			throw(
				type    = "TestBox.AssertionFailed",
				message = "Expected the page to be on #expected#, but the path is [#routeLinkPath( arguments.page.url() )#]",
				detail  = "The page URL must match the regex [#urlRegex#]. #e.message#"
			)
		}
		return arguments.page
	}

	/**
	 * The path of a URL, without scheme and host.
	 *
	 * @link      An absolute or relative URL
	 * @withQuery Keep the query string
	 *
	 * @return The raw path, plus the raw query string when there is one and withQuery is true
	 */
	private string function routeLinkPath( required string link, boolean withQuery = true ){
		var uri   = createObject( "java", "java.net.URI" ).create( arguments.link )
		var path  = uri.getRawPath() ?: ""
		var query = uri.getRawQuery() ?: ""
		if ( !len( path ) ) {
			path = "/"
		}
		return arguments.withQuery && len( query ) ? path & "?" & query : path
	}

	/**
	 * The regex a page path must match to be on a named route, any value of its placeholders included: the
	 * routing path of the application, the module entry point and the route's own regex, which ColdBox
	 * builds from the route pattern and its constraints. Every route registered with the name counts, so a
	 * route with optional placeholders matches with and without them. Not anchored, and without the trailing slash.
	 *
	 * @name The route name, `name@module` or `module:name` for module routes
	 *
	 * @return The path regex
	 *
	 * @throws InvalidArgumentException When the named route does not exist
	 */
	private string function routePathRegex( required string name ){
		var router    = getController().getWireBox().getInstance( "router@coldbox" )
		var routes    = router.getRoutes()
		var routeName = arguments.name
		if ( find( "@", arguments.name ) ) {
			routes    = router.getModuleRoutes( getToken( arguments.name, 2, "@" ) )
			routeName = getToken( arguments.name, 1, "@" )
		} else if ( find( ":", arguments.name ) ) {
			routes    = router.getModuleRoutes( getToken( arguments.name, 1, ":" ) )
			routeName = getToken( arguments.name, 2, ":" )
		}
		// A route with optional placeholders, such as /posts/:id?, is registered as several routes with the same
		// name (/posts/:id, then /posts): the page may be on any of them
		var variants = []
		var matched  = false
		for ( var route in routes ) {
			if ( route.name == routeName ) {
				matched     = true
				var variant = reReplace( route.regexPattern ?: "", "^/+|/+$", "", "all" )
				if ( !variants.findNoCase( variant ) ) {
					variants.append( variant )
				}
			}
		}
		if ( !matched ) {
			throw(
				type    = "InvalidArgumentException",
				message = "The named route '#arguments.name#' does not exist"
			)
		}
		var regex = quoteRouteRegex(
			reReplace(
				routeLinkPath( getRequestContext().getSESBaseURL(), false ),
				"/+$",
				""
			)
		)
		var entryPoint = reReplace(
			routeModuleEntryPoint( arguments.name ),
			"^/+|/+$",
			"",
			"all"
		)
		if ( len( entryPoint ) ) {
			regex &= "/" & quoteRouteRegex( entryPoint )
		}
		var paths = variants.filter( function( variant ){
			return len( variant )
		} )
		if ( paths.len() ) {
			var alternatives = "/(?:" & paths.toList( "|" ) & ")"
			// An empty variant (the route is the root of the app or module) matches without a path
			regex &= paths.len() < variants.len() ? "(?:" & alternatives & ")?" : alternatives
		}
		return regex
	}

	/**
	 * The inherited entry point of the module of a route name (`name@module` or `module:name`).
	 *
	 * @name The route name
	 *
	 * @return The module entry point, or an empty string for application routes
	 */
	private string function routeModuleEntryPoint( required string name ){
		var module = ""
		if ( find( "@", arguments.name ) ) {
			module = getToken( arguments.name, 2, "@" )
		}
		if ( find( ":", arguments.name ) ) {
			module = getToken( arguments.name, 1, ":" )
		}
		if ( !len( module ) ) {
			return ""
		}
		var modules = getController().getSetting( "modules" )
		return modules.keyExists( module ) ? modules[ module ].inheritedEntryPoint : ""
	}

	/**
	 * Escape regex special characters. Playwright runs URL regexes in the browser, so Java's \Q...\E quoting cannot be used.
	 *
	 * @text The literal text
	 *
	 * @return The text with regex special characters escaped
	 */
	private string function quoteRouteRegex( required string text ){
		return reReplace(
			arguments.text,
			"([.*+?^$\{\}()|\[\]\\/])",
			"\\\1",
			"all"
		)
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
		event.setStatusCode( 500 );

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
	 * Helper method to deal with ACF's overload of the page context response, come on Adobe, get your act together!
	 */
	private function getPageContextResponse(){
		return server.keyExists( "lucee" ) || server.keyExists( "boxlang" ) ? getPageContext().getResponse() : getPageContext()
			.getResponse()
			.getResponse();
	}

}
