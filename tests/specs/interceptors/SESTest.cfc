component extends="coldbox.system.testing.BaseInterceptorTest" interceptor="coldbox.system.interceptors.SES"{
	
	function beforeAll() {
		super.setup();
		variables.ses = variables.interceptor;
	}

	function run() {
		describe( "URL Routing", function(){

			it( "can be configured on startup", function(){
				
				// mocks
				mockController
					.$("getSetting")
						.$args("HandlersPath")
						.$results( expandPath("/coldbox/test-harness/handlers") )
					.$("getSetting")
						.$args("HandlersExternalLocationPath")
						.$results("")
					.$("getSetting")
						.$args("Modules")
						.$results( {} )
					.$("getSetting")
						.$args("EventName")
						.$results( 'event' )
					.$("getSetting")
						.$args("DefaultEvent")
						.$results( 'index' );

				ses.$("getSetting")
					.$args("AppMapping")
					.$results("/coldbox/test-harness")
					.$("importConfiguration")
					.$("setSetting");
				
				ses.setBaseURL( "http://localhost" );
				ses.configure();
				
				expect( ses.$atLeast( 2, "setSetting" ) ).toBeTrue();
			} );

			it( "can add namespace routing", function(){
				ses.$property("namespaceroutingtable","variables",{})
					.$("addRoute");
	
				ses.addNamespace( pattern="/luis", namespace="luis" );
		
				expect( "luis" ).toBe( ses.$callLog().addRoute[ 1 ].namespaceRouting );
				expect( "/luis" ).toBe( ses.$callLog().addRoute[ 1 ].pattern );
			} );

			it( "can clean incoming pathing", function(){

				makePublic( ses, "getCleanedPaths", "getCleanedPaths" );
				
				var rc = {
					someURLvar = 1,
					index = "hello"
				};

				//test folder with index.cfm
				var path_info = "/somefolder/index.cfm?somrURLVar=yes";
				ses.$('getCGIElement').$results(path_info,'');
				var results = ses.getCleanedPaths(rc,'event');
				expect( "/someFolder/index.cfm" ).toBe( results.pathInfo );
		
				//test folder with leading index.cfm
				path_info = "/index.cfm/somefolder/index.cfm?somrURLVar=yes";
				ses.$('getCGIElement').$results(path_info,'');
				results = ses.getCleanedPaths(rc,'event');
				expect( "/someFolder/index.cfm" ).toBe( results.pathInfo );
		
				//test folder wwith other .cfm
				path_info = "/somefolder/test.cfm?somrURLVar=yes";
				ses.$('getCGIElement').$results(path_info,'');
				results = ses.getCleanedPaths(rc,'event');
				expect( "/someFolder/test.cfm" ).toBe( results.pathInfo );
		
				//test regular SES route
				path_info = "/somefolder/test";
				ses.$('getCGIElement').$results(path_info,'');
				results = ses.getCleanedPaths(rc,'event');
				expect( "/somefolder/test" ).toBe( results.pathInfo );
		
				//test regular SES route with index
				path_info = "/somefolder/index";
				ses.$('getCGIElement').$results(path_info,'');
				results = ses.getCleanedPaths(rc,'event');
				expect( "/somefolder/index" ).toBe( results.pathInfo );
			} );

			describe( "Can have different format detections", function(){

				beforeEach( function(){
					var mockLog = createStub().$( "canDebug", false );
					ses.$property( propertyName = "log", mock = mockLog );
					ses.$("getSetting").$args("AppMapping").$results("/coldbox/test-harness")
						.$("getSetting").$args("eventName").$results("event")
						.$("importConfiguration")
						.$("setSetting");
					ses.setBaseURL("http://localhost");
					ses.configure();
					
					// Mocks
					mockController = createMock( "coldbox.system.web.Controller" );
					mockEvent = createMock( "coldbox.system.web.context.RequestContext" ).init( controller = mockController, properties = {
							defaultLayout = "Main.cfm",
							defaultView = "",
							eventName = "event",
							modules = {}
						} );
					mockInterceptData = {};
				} );

				it( "can detect default formats", function(){
					// default format
					ses.$( "getCleanedPaths", {
						pathInfo = "/Main/index",
						scriptName = ""
					} );
					ses.onRequestCapture( mockEvent, mockInterceptData );
					expect( mockEvent.valueExists( "format" ) ).toBeFalse();
				} );

				it( "can do extension detection", function(){
					// extension detection
					ses.$( "getCleanedPaths", {
						pathInfo = "/Main/index.xml",
						scriptName = ""
					} );
					ses.onRequestCapture( mockEvent, mockInterceptData );
					expect( mockEvent.valueExists( "format" ) ).toBeTrue();
					expect( mockEvent.getValue( "format" ) ).toBe( "xml" );
					mockEvent.removeValue( "format" );
				} );

				it( "can do accept header detection", function(){
					// Accept header parsing
					mockEvent.$( "getHTTPHeader" ).$args( "Accept" ).$results( "application/json" );
					ses.$( "getCleanedPaths", {
						pathInfo = "/Main/index",
						scriptName = ""
					} );
					ses.onRequestCapture( mockEvent, mockInterceptData );
					expect( mockEvent.valueExists( "format" ) ).toBeTrue();
					expect( mockEvent.getValue( "format" ) ).toBe( "json" );
					mockEvent.removeValue( "format" );
				} );

				it( "can detect extension over headers", function(){
					// uses extension over Accept header
					mockEvent.$( "getHTTPHeader" ).$args( "Accept" ).$results( "application/json" );
					ses.$( "getCleanedPaths", {
						pathInfo = "/Main/index.xml",
						scriptName = ""
					} );
					ses.onRequestCapture( mockEvent, mockInterceptData );
					expect( mockEvent.valueExists( "format" ) ).toBeTrue();
					expect( mockEvent.getValue( "format" ) ).toBe( "xml" );
					mockEvent.removeValue( "format" );
				} );
				
			} );
		} );
	}
}