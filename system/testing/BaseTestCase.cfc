/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* Base testing component to intergrate TestBox with ColdBox
*/
component extends="testbox.system.compat.framework.TestCase"  accessors="true"{

	/**
	* The application mapping this test links to
	*/
	property name="appMapping";
	/**
	* The configuration location this test links to
	*/
	property name="configMapping";
	/**
	* The ColdBox controller this test links to
	*/
	property name="controller";
	/**
	* The application key for the ColdBox applicatin this test links to
	*/
	property name="coldboxAppKey";

	// Public Switch Properties
	// TODO: Remove by ColdBox 4.2+ and move to variables scope.
	this.loadColdbox 	= true;
	this.unLoadColdBox 	= true;

	// Internal Properties
	variables.appMapping 	= "";
	variables.configMapping = "";
	variables.controller 	= "";
	variables.coldboxAppKey = "cbController";

	/********************************************* LIFE-CYCLE METHODS *********************************************/

	/**
	* Inspect test case for annotations
	* @return BaseTestCase
	*/
	function metadataInspection(){
		var md = new coldbox.system.core.util.Util().getInheritedMetadata( this );
		// Inspect for appMapping annotation
		if( structKeyExists( md, "appMapping" ) ){
			variables.appMapping = md.appMapping;
		}
		// Configuration File mapping
		if( structKeyExists( md, "configMapping" ) ){
			variables.configMapping = md.configMapping;
		}
		// ColdBox App Key
		if( structKeyExists( md, "coldboxAppKey" ) ){
			variables.coldboxAppKey = md.coldboxAppKey;
		}
		// Load coldBox annotation
		if( structKeyExists( md, "loadColdbox" ) ){
			this.loadColdbox = md.loadColdbox;
		}
		// unLoad coldBox annotation
		if( structKeyExists( md, "unLoadColdbox" ) ){
			this.unLoadColdbox = md.unLoadColdbox;
		}
		return this;
	}

	/**
	* The main setup method for running ColdBox Integration enabled tests
	*/
	function beforeTests(){
		var appRootPath = "";
		var context		= "";

		// metadataInspection
		metadataInspection();

		// Load ColdBox Application for testing?
		if( this.loadColdbox ){
			// Check on Scope First
			if( structKeyExists( application, getColdboxAppKey() ) ){
				variables.controller = application[ getColdboxAppKey() ];
			} else {
				// Verify App Root Path
				if( NOT len( variables.appMapping ) ){ variables.appMapping = "/"; }
				appRootPath = expandPath( variables.appMapping );
				// Clean the path for nice root path.
				if( NOT reFind( "(/|\\)$", appRootPath ) ){
					appRootPath = appRootPath & "/";
				}
				// Setup Coldbox configuration by convention
				if(NOT len( variables.configMapping ) ){
					if( len( variables.appMapping ) ){
						variables.configMapping = variables.appMapping & ".config.Coldbox";
					}
					else{
						variables.configMapping = "config.Coldbox";
					}
				}
				//Initialize mock Controller
				variables.controller = new coldbox.system.testing.mock.web.MockController( appRootPath=appRootPath, appKey=variables.coldboxAppKey );
				// persist for mock testing in right name
				application[ getColdboxAppKey() ] = variables.controller;
				// Setup
				variables.controller.getLoaderService().loadApplication( variables.configMapping, variables.appMapping );
			}
			// Load Module CF Mappings so modules can work properly
			variables.controller.getModuleService().loadMappings();
			// Auto registration of test as interceptor
			variables.controller.getInterceptorService().registerInterceptor(interceptorObject=this);
		}
	}

	/**
	* This executes before any test method for integration tests
	*/
	function setup(){
		// Are we doing integration tests
		if( this.loadColdbox ){
			// verify ColdBox still exists, else load it again:
			if( !structKeyExists( application, getColdboxAppKey() ) ){
				beforeTests();
			} else {
				variables.controller = application[ getColdBoxAppKey() ];
			}
			// remove context + reset headers
			getController().getRequestService().removeContext();
			getPageContextResponse().reset();
		}
	}

	/**
	* xUnit: The main teardown for ColdBox enabled applications after all tests execute
	*/
	function afterTests(){
		if( this.unLoadColdbox ){
			structDelete( application, getColdboxAppKey() );
		}
	}

	/**
	* BDD: The main setup method for running ColdBox Integration enabled tests
	*/
	function beforeAll(){
		if( isNull( variables._ranBeforeAll ) ){
			beforeTests();
			variables._ranBeforeAll = true;
		}
	}

	/**
	* BDD: The main teardown for ColdBox enabled applications after all tests execute
	*/
	function afterAll(){
		if( isNull( variables._ranAfterAll ) ){
			afterTests();
			variables._ranAfterAll = true;
		}
	}

	/**
	* Reset the persistence of the unit test coldbox app, basically removes the controller from application scope
	* @return BaseTestCase
	*/
	function reset( boolean clearMethods=false, decorator ){
		structDelete( application, getColdboxAppKey() );

		if( !structIsEmpty( request ) ){
			lock type="exclusive" scope="request" timeout=10{
				if( !structIsEmpty( request ) ){
					structClear( request );
				}
			}
		}

		return this;
	}

	/********************************************* MOCKING METHODS *********************************************/

	/**
	* I will return a mock controller object
	* @return coldbox.system.testing.mock.web.MockController
	*/
	function getMockController(){
		return prepareMock( new coldbox.system.testing.mock.web.MockController( '/unittest', 'unitTest' ) );
	}

	/**
	* Builds an empty functioning request context mocked with methods via MockBox.  You can also optionally wipe all methods on it
	* @clearMethods Clear methods on the object
	* @decorator The class path to the decorator to build into the mock request context
	*
	* @return coldbox.system.web.context.RequestContext
	*/
	function getMockRequestContext( boolean clearMethods=false, decorator ){
		var mockRC 			= "";
		var mockController 	= "";
		var rcProps 		= structnew();

		if( arguments.clearMethods ){
			if( structKeyExists(arguments,"decorator" ) ){
				return getMockBox().createEmptyMock(arguments.decorator);
			}
			return getMockBox().createEmptyMock( "coldbox.system.web.context.RequestContext" );
		}

		// Create functioning request context
		mockRC 			= getMockBox().createMock( "coldbox.system.web.context.RequestContext" );
		mockController = CreateObject( "component", "coldbox.system.testing.mock.web.MockController" ).init('/unittest','unitTest');

		// Create mock properties
		rcProps.DefaultLayout = "";
		rcProps.DefaultView = "";
		rcProps.isSES = false;
		rcProps.sesBaseURL = "";
		rcProps.eventName = "event";
		rcProps.ViewLayouts = structnew();
		rcProps.FolderLayouts = structnew();
		rcProps.RegisteredLayouts = structnew();
		rcProps.modules = structnew();
		mockRC.init( properties=rcProps, controller=mockController );

		// return decorator context
		if( structKeyExists(arguments,"decorator" ) ){
			return getMockBox().createMock(arguments.decorator).init(mockRC, mockController);
		}

		// return normal RC
		return mockRC;
	}

	/**
	* ColdBox must be loaded for this to work. Get a mock model object by convention. You can optional clear all the methods on the model object if you wanted to. The object is created but not initiated, that would be your job.
	* @name The name of the model to mock and return back
	* @clearMethods Clear methods on the object
	*/
	function getMockModel( required name, boolean clearMethods=false ){
		var mockLocation = getController().getWireBox().locateInstance( arguments.name );

		if( len( mockLocation ) ){
			return getMockBox().createMock( className=mockLocation, clearMethods=arguments.clearMethods );
		}
		else{
			throw( message="Model object #arguments.name# could not be located.", type="ModelNotFoundException" );
		}
	}

	/********************************************* APP RETRIEVAL METHODS *********************************************/

	/**
	* Get the WireBox reference from the running application
	* @return coldbox.system.ioc.Injector
	*/
	function getWireBox(){
		return variables.controller.getwireBox();
	}

	/**
	* Get the CacheBox reference from the running application
	* @return coldbox.system.cache.CacheFactory
	*/
	function getCacheBox(){
		return variables.controller.getCacheBox();
	}

	/**
	* Get the CacheBox reference from the running application
	* @cacheName The cache name to retrieve or returns the 'default' cache by default.
	*
	* @return coldbox.system.cache.ICacheProvider
	*/
	function getCache( required cacheName="default" ){
		return getController().getCache( arguments.cacheName );
	}

	/**
	* Get the LogBox reference from the running application
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
		return getController().getRequestService().getContext(
            "coldbox.system.testing.mock.web.context.MockRequestContext"
        );
	}

	/**
	* Get the RequestContext reference from the running application
	*
	* @return coldbox.system.web.Flash.AbstractFlashScope
	*/
	function getFlashScope(){
		return getController().getRequestService().getFlashScope();
	}

	/********************************************* APPLICATION EXECUTION METHODS *********************************************/

	/**
	* Setup an initial request capture.  I basically look at the FORM/URL scopes and create the request collection out of them.
	* @event The event to setup the request context with, simulates the URL/FORM.event
	*
	* @return BaseTestCase
	*/
	function setupRequest( required event ){
		// Setup the incoming event
		URL[ getController().getSetting( "EventName" ) ] = arguments.event;
		// Capture the request
		getController().getRequestService().requestCapture();
		return this;
	}

	/**
    * Executes a framework lifecycle by executing an event.
    * This method returns a request context object that
    * is decorated and can be used for assertions.
    *
	* @event                 The event to execute (e.g. 'main.index')
    * @route                 The route to execute
    *                        (e.g. '/login' which may route to 'sessions.new')
	* @private               Call a private event or not.
	* @prePostExempt         If true, pre/post handlers will not be fired.
    * @eventArguments        A collection of arguments to passthrough to the
    *                        calling event handler method.
    * @renderResults         If true, then it will try to do the normal
    *                        rendering procedures and store the rendered content
    *                        in the RC as cbox_rendered_content.
    * @withExceptionHandling If true, then ColdBox will process any errors
    *                        through the exception handling framework instead
    *                        of just throwing the error. Default: false.
	*
	* @return                coldbox.system.context.RequestContext
	*/
	function execute(
		string event = "",
        string route = "",
        string queryString = "",
		boolean private=false,
		boolean prePostExempt=false,
		struct eventArguments={},
        boolean renderResults=false,
        boolean withExceptionHandling = false
	){
		var handlerResults  = "";
		var requestContext  = getRequestContext();
		var relocationTypes = "TestController.relocate";
		var cbController    = getController();
		var renderData		= "";
		var renderedContent = "";
		var iData			= {};

        if ( arguments.event == "" && arguments.route == "" ){
            throw( "Must provide either an event or a route to the execute() method." );
        }

        try{

        	// If the route is for the home page, use the default event in the config/ColdBox.cfc
        	if ( arguments.route == "/" ){
        		arguments.event = getController().getSetting( "defaultEvent" );
				requestContext.setValue( requestContext.getEventName(), arguments.event );
				prepareMock( getController().getRoutingService() )
					.$( "getCGIElement" ).$args( "path_info", requestContext ).$results( arguments.route )
					.$( "getCGIElement" ).$args( "script_name", requestContext ).$results( "" )
					.$( "getCGIElement" ).$args( "domain", requestContext ).$results( cgi.server_name );
				arguments.route = "";
        	}
            // if we were passed a route, parse it and prepare the SES interceptor for routing.
            else if ( arguments.route.len() ){
            	// enable the SES interceptor
            	getInstance( "router@coldbox" ).setEnabled( true );
                // separate the route into the route and the query string
				var routeParts = explodeRoute( arguments.route );
                // add the query string parameters from the route to the request context
                requestContext.collectionAppend( routeParts.queryStringCollection )
                	.collectionAppend( parseQueryString( arguments.queryString ) );

                // mock the cleaned paths so SES routes will be recognized
				prepareMock( getController().getRoutingService() )
					.$( "getCGIElement" ).$args( "path_info", requestContext ).$results( routeParts.route )
					.$( "getCGIElement" ).$args( "script_name", requestContext ).$results( "" )
					.$( "getCGIElement" ).$args( "domain", requestContext ).$results( cgi.server_name );
            }
            else{
                // If we were passed just an event, remove routing since we don't need it
				getInstance( "router@coldbox" ).setEnabled( false );
			}

			// Setup the request Context with setup FORM/URL variables set in the unit test.
			cbController.getRequestService().setContext( requestContext );
			setupRequest( arguments.event );

			// App Start Handler
			if ( len( cbController.getSetting( "ApplicationStartHandler" ) ) ){
				cbController.runEvent( cbController.getSetting( "ApplicationStartHandler" ), true );
			}

			// preProcess
			cbController.getInterceptorService().processState( "preProcess" );

			// Request Start Handler
			if ( len( cbController.getSetting( "RequestStartHandler" ) ) ){
				cbController.runEvent( cbController.getSetting( "RequestStartHandler" ), true );
			}

            // grab the latest event in the context, in case overrides occur
            requestContext  = getRequestContext();
			arguments.event = requestContext.getCurrentEvent();

			// TEST EVENT EXECUTION
			if( NOT requestContext.getIsNoExecution() ){
				// execute the event
				handlerResults = cbController.runEvent(
					event 			= arguments.event,
					private 		= arguments.private,
					prepostExempt	= arguments.prepostExempt,
					eventArguments 	= arguments.eventArguments,
					defaultEvent 	= true
				);

				// Are we doing rendering procedures?
				if( arguments.renderResults ){
					// preLayout
					cbController.getInterceptorService().processState( "preLayout" );

					// Render Data?
					renderData = requestContext.getRenderData();
					if( isStruct( renderData ) and NOT structIsEmpty( renderData ) ){
                        requestContext.setValue( "cbox_render_data", renderData );
                        requestContext.setValue( "cbox_statusCode", renderData.statusCode );
						renderedContent = cbController.getDataMarshaller().marshallData(argumentCollection=renderData);
					}
					// If we have handler results save them in our context for assertions
					else if (
						!isNull( handlerResults )
					){
                        // Store raw results
                        requestContext.setValue( "cbox_handler_results", handlerResults );
                        requestContext.setValue( "cbox_statusCode", getNativeStatusCode() );
						if( isSimpleValue( handlerResults ) ){
							renderedContent = handlerResults;
						} else {
							renderedContent = serializeJSON( handlerResults );
						}
					}
					// render layout/view pair
					else{
                        requestContext.setValue( "cbox_statusCode", getNativeStatusCode() );
						renderedContent = cbcontroller.getRenderer()
							.renderLayout(module=requestContext.getCurrentLayoutModule(),
									     viewModule=requestContext.getCurrentViewModule());
					}

					// Pre Render
					iData = { renderedContent = renderedContent };
					cbController.getInterceptorService().processState( "preRender", iData);
					renderedContent = iData.renderedContent;

					// Store in collection for assertions
					requestContext.setValue( "cbox_rendered_content", renderedContent );

					// postRender
					cbController.getInterceptorService().processState( "postRender" );
				}
			}

			// Request End Handler
			if ( len(cbController.getSetting( "RequestEndHandler" )) ){
				cbController.runEvent( cbController.getSetting( "RequestEndHandler" ), true );
			}

			// postProcess
			cbController.getInterceptorService().processState( "postProcess" );

		} catch( "InterceptorService.InterceptorNotFound" e ) {
        	// In either case, if the interceptor doesn't exists, just ignore it.
        } catch( Any e ) {
			// Are we doing exception handling?
            if ( withExceptionHandling ) {
                processException( cbController, e );
            }
			// Exclude relocations so they can be asserted.
			if( NOT listFindNoCase( relocationTypes, e.type ) ){
				rethrow;
			}
		}

		// Return the correct event context.
		requestContext = getRequestContext();

        // Add in the test helpers for convenience
        requestContext.getRenderedContent = variables.getRenderedContent;
        requestContext.getRenderData      = variables.getRenderData;
        requestContext.getStatusCode      = variables.getStatusCode;

		return requestContext;
    }

    /**
     * Shortcut method to making a request through the framework.
     *
     * @route The route to execute.
     * @params Params to pass to the `rc` scope.
     * @headers Custom headers to pass as from the request
     * @method The method type to execute.  Defaults to GET.
     * @renderResults If true, then it will try to do the normal rendering procedures and store the rendered content in the RC as cbox_rendered_content
     */
    function request(
        string route = "",
        struct params = {},
        struct headers = {},
        string method = "GET",
        boolean renderResults = true
    ) {
        var mockedEvent = prepareMock( getRequestContext() ).$( "getHTTPMethod", ucase( method ) );
        params.keyArray().each( function( name ) {
            mockedEvent.setValue( name, params[ name ] );
        } );
        headers.keyArray().each( function( name ) {
            mockedEvent.$( "getHTTPHeader" ).$args( name ).$results( headers[ name ] );
        } );
        return execute( argumentCollection = arguments );
    }

    /**
     * Shortcut method to making a GET request through the framework.
     *
     * @route The route to execute.
     * @params Params to pass to the `rc` scope.
     * @headers Custom headers to pass as from the request
     * @renderResults If true, then it will try to do the normal rendering procedures and store the rendered content in the RC as cbox_rendered_content
     */
    function get(
        string route = "",
        struct params = {},
        struct headers = {},
        boolean renderResults = true
    ) {
        arguments.method = "GET";
        return request( argumentCollection = arguments );
    }

    /**
    * Shortcut method to making a POST request through the framework.
    *
    * @route The route to execute.
    * @params Params to pass to the `rc` scope.
    * @headers Custom headers to pass as from the request
    * @renderResults If true, then it will try to do the normal rendering procedures and store the rendered content in the RC as cbox_rendered_content
    */
    function post(
        string route = "",
        struct params = {},
        struct headers = {},
        boolean renderResults=true
    ) {
        arguments.method = "POST";
        return request( argumentCollection = arguments );
    }

    /**
    * Shortcut method to making a PUT request through the framework.
    *
    * @route The route to execute.
    * @params Params to pass to the `rc` scope.
    * @headers Custom headers to pass as from the request
    * @renderResults If true, then it will try to do the normal rendering procedures and store the rendered content in the RC as cbox_rendered_content
    */
    function put(
        string route = "",
        struct params = {},
        struct headers = {},
        boolean renderResults=true
    ) {
        arguments.method = "PUT";
        return request( argumentCollection = arguments );
    }

    /**
    * Shortcut method to making a PATCH request through the framework.
    *
    * @route The route to execute.
    * @params Params to pass to the `rc` scope.
    * @headers Custom headers to pass as from the request
    * @renderResults If true, then it will try to do the normal rendering procedures and store the rendered content in the RC as cbox_rendered_content
    */
    function patch(
        string route = "",
        struct params = {},
        struct headers = {},
        boolean renderResults=true
    ) {
        arguments.method = "PATCH";
        return request( argumentCollection = arguments );
    }

    /**
    * Shortcut method to making a DELETE request through the framework.
    *
    * @route The route to execute.
    * @params Params to pass to the `rc` scope.
    * @headers Custom headers to pass as from the request
    * @renderResults If true, then it will try to do the normal rendering procedures and store the rendered content in the RC as cbox_rendered_content
    */
    function delete(
        string route = "",
        struct params = {},
        struct headers = {},
        boolean renderResults=true
    ) {
        arguments.method = "DELETE";
        return request( argumentCollection = arguments );
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
    * Get the render data struct for a ColdBox integration test
    *
    * @return cbox_render_data or an empty struct
    */
    function getRenderData(){
		return getPrivateValue( name="cbox_renderdata", defaultValue=structnew() );
    }

    /**
    * Get the status code for a ColdBox integration test
    *
    * @return cbox_statusCode or 200
    */
    function getStatusCode(){
        return getValue( "cbox_statusCode", 200 );
    }

    /**
    * Get the status code set in the CFML engine.
    *
    * @return The CFML status code.
    */
    function getNativeStatusCode() {
        return getPageContextResponse().getStatus();
    }

	/**
	* Announce an interception to the system. If you use the asynchronous facilities, you will get a thread structure report as a result.
	* @state The event to announce
	* @interceptData A data structure used to pass intercepted information.
	* @async If true, the entire interception chain will be ran in a separate thread.
	* @asyncAll If true, each interceptor in the interception chain will be ran in a separate thread and then joined together at the end.
	* @asyncAllJoin If true, each interceptor in the interception chain will be ran in a separate thread and joined together at the end by default.  If you set this flag to false then there will be no joining and waiting for the threads to finalize.
	* @asyncPriority The thread priority to be used. Either LOW, NORMAL or HIGH. The default value is NORMAL
	* @asyncJoinTimeout The timeout in milliseconds for the join thread to wait for interceptor threads to finish.  By default there is no timeout.
	*
	* @return struct of thread information or void
	*/
	function announceInterception(
		required state,
		struct interceptData={},
		boolean async=false,
		boolean asyncAll=false,
		boolean asyncAllJoin=true,
		asyncPriority="NORMAL",
		numeric asyncJoinTimeout=0
	){
		return getController().getInterceptorService().processState( argumentCollection=arguments );
	}

	/**
	* Get an interceptor reference
	* @interceptorName The name of the interceptor to retrieve
	*
	* @return Interceptor
	*/
	function getInterceptor( required interceptorName ){
		return getController().getInterceptorService().getInterceptor( argumentCollection=arguments );
	}

	/**
	* Get a model object
	* @name The mapping name or CFC path to retrieve
	* @dsl The DSL string to use to retrieve an instance
	* @initArguments The constructor structure of arguments to passthrough when initializing the instance
	*/
	function getModel( name, dsl, initArguments={} ){
		return getInstance( argumentCollection=arguments );
	}

	/**
	* Get a instance object from WireBox
	* @name The mapping name or CFC path to retrieve
	* @dsl The DSL string to use to retrieve an instance
	* @initArguments The constructor structure of arguments to passthrough when initializing the instance
	*/
	function getInstance( name, dsl, initArguments={} ){
		return getController().getWireBox().getInstance( argumentCollection=arguments );
	}

	/**
	 * Get the ColdBox global utility class
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
        var routeParts = ListToArray( URLDecode( arguments.route ), '?' );

        var queryParams = {};
        if ( ArrayLen( routeParts ) > 1 ){
            queryParams = parseQueryString( routeParts[ 2 ] );
        }

        return { route = routeParts[ 1 ], queryStringCollection = queryParams };
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

		queryString.listToArray( "&" )
			.each( function( item ){
				queryParams[ UrlDecode( item.getToken( 1, "=" ) ) ] = UrlDecode( item.getToken( 2, "=" ) );
			} );

        return queryParams;
    }

    /**
	* Process an exception and returns a rendered bug report
	* @controller The ColdBox Controller
	* @exception The ColdFusion exception
	*/
	private string function processException( required controller, required exception ){
        // prepare exception facade object + app logger
		var oException	= new coldbox.system.web.context.ExceptionBean( arguments.exception );
		var appLogger  	= arguments.controller.getLogBox().getLogger( this );
		var event		= arguments.controller.getRequestService().getContext();
		var rc 			= event.getCollection();
		var prc 		= event.getPrivateCollection();

		// Announce interception
		arguments.controller.getInterceptorService()
        	.processState( "onException", { exception = arguments.exception } );

		// Store exception in private context
		event.setPrivateValue( "exception", oException );

		// Set Exception Header
		getPageContextResponse().setStatus( 500, "Internal Server Error" );

		// Run custom Exception handler if Found, else run default exception routines
		if ( len( arguments.controller.getSetting( "ExceptionHandler" ) ) ){
            try{
                arguments.controller.runEvent( arguments.controller.getSetting( "Exceptionhandler" ) );
			} catch( Any e ) {
                // Log Original Error First
				appLogger.error( "Original Error: #arguments.exception.message# #arguments.exception.detail# ", arguments.exception );
				// Log Exception Handler Error
				appLogger.error( "Error running exception handler: #arguments.controller.getSetting( "ExceptionHandler" )# #e.message# #e.detail#", e );
				// rethrow error
				rethrow;
			}
		} else {
            // Log Error
			appLogger.error( "Error: #arguments.exception.message# #arguments.exception.detail# ", arguments.exception );
		}

		// Render out error via CustomErrorTemplate or Core
		var customErrorTemplate = arguments.controller.getSetting( "CustomErrorTemplate" );
		if( len( customErrorTemplate ) ){
			// Get app location path
			var appLocation 			= "/";
			if( len( arguments.controller.getSetting( "AppMapping" ) ) ){
				appLocation = appLocation & arguments.controller.getSetting( "AppMapping" ) & "/";
			}
			var bugReportRelativePath 	= appLocation & reReplace( customErrorTemplate, "^/", "" );
			var bugReportAbsolutePath 	= customErrorTemplate;

			// Show Bug Report
			savecontent variable="local.exceptionReport"{
				// Do we have right path already, test by expanding
				if( fileExists( expandPath( bugReportRelativePath ) ) ){
					include "#bugReportRelativePath#";
				} else {
					include "#bugReportAbsolutePath#";
				}
			}

		} else {
			// Default ColdBox Error Template
			savecontent variable="local.exceptionReport"{
				include "/coldbox/system/includes/BugReport-Public.cfm";
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
