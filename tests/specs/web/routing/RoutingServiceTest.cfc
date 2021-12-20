component extends="tests.resources.BaseIntegrationTest" {

	function beforeAll(){
		super.setup();
		routingService = prepareMock( getController().getRoutingService() );
	}

	function afterAll(){
		shutdownColdBox();
	}

	function run(){
		describe( "Routing Services", function(){
			it( "can clean incoming pathing", function(){
				makePublic(
					routingService,
					"getCleanedPaths",
					"getCleanedPaths"
				);

				var rc = { someURLvar : 1, index : "hello" };

				// test folder with index.cfm
				var path_info = "/somefolder/index.cfm?somrURLVar=yes";
				routingService.$( "getCGIElement" ).$results( path_info, "", "localhost" );
				var results = routingService.getCleanedPaths( rc, "event" );
				expect( "/someFolder/index.cfm" ).toBe( results.pathInfo );

				// test folder with leading index.cfm
				path_info = "/index.cfm/somefolder/index.cfm?somrURLVar=yes";
				routingService.$( "getCGIElement" ).$results( path_info, "", "localhost" );
				results = routingService.getCleanedPaths( rc, "event" );
				expect( "/someFolder/index.cfm" ).toBe( results.pathInfo );

				// test folder wwith other .cfm
				path_info = "/somefolder/test.cfm?somrURLVar=yes";
				routingService.$( "getCGIElement" ).$results( path_info, "", "localhost" );
				results = routingService.getCleanedPaths( rc, "event" );
				expect( "/someFolder/test.cfm" ).toBe( results.pathInfo );

				// test regular SES route
				path_info = "/somefolder/test";
				routingService.$( "getCGIElement" ).$results( path_info, "", "localhost" );
				results = routingService.getCleanedPaths( rc, "event" );
				expect( "/somefolder/test" ).toBe( results.pathInfo );

				// test regular SES route with index
				path_info = "/somefolder/index";
				routingService.$( "getCGIElement" ).$results( path_info, "", "localhost" );
				results = routingService.getCleanedPaths( rc, "event" );
				expect( "/somefolder/index" ).toBe( results.pathInfo );
			} );

			describe( "Can have different format detections", function(){
				beforeEach( function(){
					// Mocks
					mockEvent = createMock( "coldbox.system.web.context.RequestContext" ).init(
						controller = getController(),
						properties = {
							defaultLayout : "Main.cfm",
							defaultView   : "",
							eventName     : "event",
							modules       : {}
						}
					);
					mockInterceptData = {};
				} );

				it( "can detect default formats", function(){
					// default format
					routingService.$(
						"getCleanedPaths",
						{
							pathInfo   : "/Main/index",
							scriptName : "",
							domain     : "localhost"
						}
					);
					routingService.requestCapture( mockEvent );
					expect( mockEvent.valueExists( "format" ) ).toBeFalse();
				} );

				it( "can do extension detection", function(){
					// extension detection
					routingService.$(
						"getCleanedPaths",
						{
							pathInfo   : "/Main/index.xml",
							scriptName : "",
							domain     : "localhost"
						}
					);
					routingService.requestCapture( mockEvent );
					expect( mockEvent.valueExists( "format" ) ).toBeTrue();
					expect( mockEvent.getValue( "format" ) ).toBe( "xml" );
					mockEvent.removeValue( "format" );
				} );

				it( "can do accept header detection", function(){
					// Accept header parsing
					mockEvent
						.$( "getHTTPHeader" )
						.$args( "Accept" )
						.$results( "application/json" );
					routingService.$(
						"getCleanedPaths",
						{
							pathInfo   : "/Main/index",
							scriptName : "",
							domain     : "localhost"
						}
					);
					routingService.requestCapture( mockEvent );
					expect( mockEvent.valueExists( "format" ) ).toBeTrue();
					expect( mockEvent.getValue( "format" ) ).toBe( "json" );
					mockEvent.removeValue( "format" );
				} );

				it( "can detect extension over headers", function(){
					// uses extension over Accept header
					mockEvent
						.$( "getHTTPHeader" )
						.$args( "Accept" )
						.$results( "application/json" );
					routingService.$(
						"getCleanedPaths",
						{
							pathInfo   : "/Main/index.xml",
							scriptName : "",
							domain     : "localhost"
						}
					);
					routingService.requestCapture( mockEvent );
					expect( mockEvent.valueExists( "format" ) ).toBeTrue();
					expect( mockEvent.getValue( "format" ) ).toBe( "xml" );
					mockEvent.removeValue( "format" );
				} );
			} );

			it( "can use a full event from the action block if no event or handler is defined", function(){
				var mockEvent = createMock( "coldbox.system.web.context.RequestContext" ).init(
					controller = getController(),
					properties = {
						defaultLayout : "Main.cfm",
						defaultView   : "",
						eventName     : "event",
						modules       : {}
					}
				);

				var routeResults = {
					"route" : initRouteDefinition(
						overrides = {
							"handler" : "",
							"event"   : "",
							"action"  : {
								"GET"  : "MyHandler.index",
								"POST" : "MyOtherHandler.create"
							}
						}
					),
					"params" : {}
				};

				var discoveredEventGET = variables.routingService.processRoute(
					routeResults = routeResults,
					event        = mockEvent,
					rc           = mockEvent.getCollection(),
					prc          = mockEvent.getPrivateCollection()
				);

				expect( discoveredEventGET ).toBe( "MyHandler.index" );

				mockEvent.$( "getHTTPMethod", "POST" );

				var discoveredEventPOST = variables.routingService.processRoute(
					routeResults = routeResults,
					event        = mockEvent,
					rc           = mockEvent.getCollection(),
					prc          = mockEvent.getPrivateCollection()
				);

				expect( discoveredEventPOST ).toBe( "MyOtherHandler.create" );
			} );

			it( "appends a handler from a route definition if it exists", function(){
				var mockEvent = createMock( "coldbox.system.web.context.RequestContext" ).init(
					controller = getController(),
					properties = {
						defaultLayout : "Main.cfm",
						defaultView   : "",
						eventName     : "event",
						modules       : {}
					}
				);

				var routeResults = {
					"route" : initRouteDefinition(
						overrides = {
							"handler" : "MyHandler",
							"event"   : "",
							"action"  : { "GET" : "index", "POST" : "create", "PUT" : "update" }
						}
					),
					"params" : {}
				};

				var discoveredEventGET = variables.routingService.processRoute(
					routeResults = routeResults,
					event        = mockEvent,
					rc           = mockEvent.getCollection(),
					prc          = mockEvent.getPrivateCollection()
				);

				expect( discoveredEventGET ).toBe( "MyHandler.index" );

				mockEvent.$( "getHTTPMethod", "PUT" );

				var discoveredEventPOST = variables.routingService.processRoute(
					routeResults = routeResults,
					event        = mockEvent,
					rc           = mockEvent.getCollection(),
					prc          = mockEvent.getPrivateCollection()
				);

				expect( discoveredEventPOST ).toBe( "MyHandler.update" );
			} );
		} );
	}

	/**
	 * Returns a new route definition
	 */
	private struct function initRouteDefinition( struct overrides = {} ){
		structAppend(
			arguments.overrides,
			{
				"action"                : "", // The action to execute
				"append"                : true, // Was this route appended or pre/prended
				"condition"             : "", // The condition closure which must be true for the route to match
				// TODO: Consider deprecating this since now we have a `-regex()` placeholder
				"constraints"           : {}, // If we have any regex constraints on placeholders.
				"domain"                : "", // The domain attached to the route
				"event"                 : "", // The full event syntax to execute
				"handler"               : "", // The handler to execute
				"headers"               : {}, // The HTTP response headers to respond with
				"layout"                : "", // The layout to proxy to
				"layoutModule"          : "", // If the layout comes from a module
				"meta"                  : {}, // Route metadata if any
				"module"                : "", // The module event we must execute
				"moduleRouting"         : "", // This routes to a module
				"name"                  : "", // The named route
				"namespace"             : "", // The namespace this route belongs to
				"namespaceRouting"      : "", // This routes to a namespace
				"packageResolverExempt" : false, // If true, it does not resolve packages by convention, by default we do
				"pattern"               : "", // The regex pattern used for matching
				"prc"                   : {}, // The PRC params to add incorporate if matched
				"rc"                    : {}, // The RC params to add incorporate if matched
				"redirect"              : "", // The redirection location
				"response"              : "", // Do we have an inline response closure
				"ssl"                   : false, // Are we forcing SSL
				"statusCode"            : 200, // The response status code
				"statusText"            : "Ok", // The response status text
				"valuePairTranslation"  : true, // If we translate name-value pairs in the URL by convention
				"verbs"                 : "", // The HTTP Verbs allowed
				"view"                  : "", // The view to proxy to
				"viewModule"            : "", // If the view comes from a module
				"viewNoLayout"          : false // If we use a layout or not
			},
			false
		);
		return arguments.overrides;
	}

}
