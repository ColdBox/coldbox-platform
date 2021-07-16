component extends="tests.resources.BaseIntegrationTest" {

	function beforeAll(){
		super.setup();
		routingService = prepareMock( getController().getRoutingService() );
	}

	function afterAll(){
		// Cleanup due to mods!

		// Graceful shutdown
		if ( structKeyExists( application, getColdboxAppKey() ) ) {
			application[ getColdboxAppKey() ].getLoaderService().processShutdown();
		}
		// Wipe app scopes
		structDelete( application, getColdboxAppKey() );
		structDelete( application, "wirebox" );
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
		} );
	}

}
