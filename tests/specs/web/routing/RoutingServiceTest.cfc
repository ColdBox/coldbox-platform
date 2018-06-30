component extends="coldbox.system.testing.BaseTestCase" appMapping="/cbTestHarness"{

	function beforeAll() {
		super.setup();
		routingService = prepareMock( getController().getRoutingService() );
	}

	function run() {
		describe( "Routing Services", function(){

			it( "can clean incoming pathing", function(){

				makePublic( routingService, "getCleanedPaths", "getCleanedPaths" );

				var rc = {
					someURLvar = 1,
					index = "hello"
				};

				//test folder with index.cfm
				var path_info = "/somefolder/index.cfm?somrURLVar=yes";
				routingService.$( "getCGIElement" ).$results( path_info, '', 'localhost' );
				var results = routingService.getCleanedPaths(rc,'event');
				expect( "/someFolder/index.cfm" ).toBe( results.pathInfo );

				//test folder with leading index.cfm
				path_info = "/index.cfm/somefolder/index.cfm?somrURLVar=yes";
				routingService.$( "getCGIElement" ).$results( path_info, '', 'localhost' );
				results = routingService.getCleanedPaths(rc,'event');
				expect( "/someFolder/index.cfm" ).toBe( results.pathInfo );

				//test folder wwith other .cfm
				path_info = "/somefolder/test.cfm?somrURLVar=yes";
				routingService.$( "getCGIElement" ).$results( path_info, '', 'localhost' );
				results = routingService.getCleanedPaths(rc,'event');
				expect( "/someFolder/test.cfm" ).toBe( results.pathInfo );

				//test regular SES route
				path_info = "/somefolder/test";
				routingService.$( "getCGIElement" ).$results( path_info, '', 'localhost' );
				results = routingService.getCleanedPaths(rc,'event');
				expect( "/somefolder/test" ).toBe( results.pathInfo );

				//test regular SES route with index
				path_info = "/somefolder/index";
				routingService.$( "getCGIElement" ).$results( path_info, '', 'localhost' );
				results = routingService.getCleanedPaths(rc,'event');
				expect( "/somefolder/index" ).toBe( results.pathInfo );
			} );

			describe( "Can have different format detections", function(){

				beforeEach( function(){
					// Mocks
					mockEvent = createMock( "coldbox.system.web.context.RequestContext" )
						.init(
							controller = getController(),
							properties = {
								defaultLayout 	= "Main.cfm",
								defaultView 	= "",
								eventName 		= "event",
								modules 		= {}
							}
						);
					mockInterceptData = {};
				} );

				it( "can detect default formats", function(){
					// default format
					routingService.$( "getCleanedPaths", {
						pathInfo   = "/Main/index",
						scriptName = "",
						domain     = "localhost"
					} );
					routingService.onRequestCapture( mockEvent, mockInterceptData, mockEvent.getCollection(), mockEvent.getPrivateCollection() );
					expect( mockEvent.valueExists( "format" ) ).toBeFalse();
				} );

				it( "can do extension detection", function(){
					// extension detection
					routingService.$( "getCleanedPaths", {
						pathInfo   = "/Main/index.xml",
						scriptName = "",
						domain     = "localhost"
					} );
					routingService.onRequestCapture( mockEvent, mockInterceptData, mockEvent.getCollection(), mockEvent.getPrivateCollection() );
					expect( mockEvent.valueExists( "format" ) ).toBeTrue();
					expect( mockEvent.getValue( "format" ) ).toBe( "xml" );
					mockEvent.removeValue( "format" );
				} );

				it( "can do accept header detection", function(){
					// Accept header parsing
					mockEvent.$( "getHTTPHeader" ).$args( "Accept" ).$results( "application/json" );
					routingService.$( "getCleanedPaths", {
						pathInfo   = "/Main/index",
						scriptName = "",
						domain     = "localhost"
					} );
					routingService.onRequestCapture( mockEvent, mockInterceptData, mockEvent.getCollection(), mockEvent.getPrivateCollection() );
					expect( mockEvent.valueExists( "format" ) ).toBeTrue();
					expect( mockEvent.getValue( "format" ) ).toBe( "json" );
					mockEvent.removeValue( "format" );
				} );

				it( "can detect extension over headers", function(){
					// uses extension over Accept header
					mockEvent.$( "getHTTPHeader" ).$args( "Accept" ).$results( "application/json" );
					routingService.$( "getCleanedPaths", {
						pathInfo   = "/Main/index.xml",
						scriptName = "",
						domain     = "localhost"
					} );
					routingService.onRequestCapture( mockEvent, mockInterceptData, mockEvent.getCollection(), mockEvent.getPrivateCollection() );
					expect( mockEvent.valueExists( "format" ) ).toBeTrue();
					expect( mockEvent.getValue( "format" ) ).toBe( "xml" );
					mockEvent.removeValue( "format" );
				} );

			} );

			describe( "Can accurately process a request capture with routing params", function(){


				beforeEach( function(){
					// Mocks
					mockEvent = createMock( "coldbox.system.web.context.RequestContext" )
						.init(
							controller = getController(),
							properties = {
								defaultLayout 	= "Main.cfm",
								defaultView 	= "",
								eventName 		= "event",
								modules 		= {}
							}
						);
					mockInterceptData = {};
				} );
				
				it( "Tests that route rc/prc params will be applied on request capture", function(){
					
					//test regular SES route
					path_info = "/somefolder/test";

					// We need a clean mock so we can mock one of the routing methods
					var routingService = prepareMock( getController().getRoutingService() );
					routingService.$( "getCGIElement" ).$results( path_info, '', 'localhost' );

					routingService.$( "findRoute" ).$callback( function(){
						return {
							"params" : {},
							"route" : {
								"rc" : {
									"name" : "jon"
								},
								"prc" : {
									"foo" : "bar"
								},
								"redirect" : "",
								"ssl" : false,
								"event" : "",
								"handler" : "",
								"action" : "",
								"view" : "",
								"headers" : [],
								"response" : ""
							}
						}
					} );

					routingService.onRequestCapture( mockEvent, mockInterceptData, mockEvent.getCollection(), mockEvent.getPrivateCollection() );
					expect( mockEvent.getValue( "name" ) ).toBe( "jon" );
					expect( mockEvent.getPrivateValue( "foo" ) ).toBe( "bar" );

				} );
				
				it( "Tests that route params will not overwrite pre-existing rc values", function(){
					
					//test regular SES route
					path_info = "/somefolder/test";

					mockEvent.setValue( "name", "luis" );
					mockEvent.setPrivateValue( "foo", "bar" );

					// We need a clean mock so we can mock one of the routing methods
					var routingService = prepareMock( getController().getRoutingService() );
					routingService.$( "getCGIElement" ).$results( path_info, '', 'localhost' );

					routingService.$( "findRoute" ).$callback( function(){
						return {
							"params" : {},
							"route" : {
								"rc" : {
									"name" : "jon"
								},
								"prc" : {
									"foo" : "baz"
								},
								"redirect" : "",
								"ssl" : false,
								"event" : "",
								"handler" : "",
								"action" : "",
								"view" : "",
								"headers" : [],
								"response" : ""
							}
						}
					} );

					routingService.onRequestCapture( mockEvent, mockInterceptData, mockEvent.getCollection(), mockEvent.getPrivateCollection() );
					expect( mockEvent.getValue( "name" ) ).toBe( "luis" );
					expect( mockEvent.getPrivateValue( "foo" ) ).toBe( "bar" );

				} );
			} );
		} );
	}
}