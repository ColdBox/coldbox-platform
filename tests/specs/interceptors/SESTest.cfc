component extends="coldbox.system.testing.BaseInterceptorTest" interceptor="coldbox.system.interceptors.SES"{
	
	function beforeAll() {
		super.setup();
		variables.ses = variables.interceptor;

		// mocks
		ses.$( "getSetting" )
				.$args( "AppMapping" )
				.$results( "/coldbox/test-harness" )
			.$( "getSetting" )
				.$args( "DefaultEvent" )
				.$results( 'index' )
			.$( "getSetting" )
				.$args( "EventName" )
				.$results( 'event' )
			.$( "getSetting" )
				.$args( "HandlersPath" )
				.$results( expandPath( "/coldbox/test-harness/handlers" ) )
			.$( "getSetting" )
				.$args( "HandlersExternalLocationPath" )
				.$results( "" )
			.$( "getSetting" )
				.$args( "Modules" )
				.$results( {
					myModule = {
						routes = [
							{ pattern="/", handler="home", action="index", name="home" }
						],
						resources = [ { resource="photos" } ]
					}
				} )
			.$( "importConfiguration" )
			.setBaseURL( "http://localhost" )
			.setProperty( 'configFile', '/coldbox/test-harness/config/Routes.cfm' )
			.configure();
	}

	function run() {
		describe( "URL Routing", function(){

			it( "can add namespace routing", function(){
				ses.addNamespace( pattern="/luis", namespace="luis" );
				expect( ses.getNamespaceRoutingTable() ).toHaveKey( "luis" );
				expect( ses.getRoutes().filter( function( item ){
					return ( item.pattern == "luis/" ? true : false );
				} ) ).notToBeEmpty();
			} );

			it( "can add module routing", function(){
				ses.addModuleRoutes( pattern="/myModule", module="myModule" );
				expect( ses.getModuleRoutingTable() ).toHaveKey( "myModule" );
				expect( ses.getRoutes().filter( function( item ){
					return ( item.pattern == "myModule/" ? true : false );
				} ) ).notToBeEmpty();
			} );

			it( "can add named routes", function(){
				ses.addRoute( pattern="/luis", name="luis" );
				expect( ses.getRoutes().filter( function( item ){
					return ( item.name == "luis" ? true : false );
				} ) ).notToBeEmpty();
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
					ses.$( "getSetting" ).$args("AppMapping" ).$results("/coldbox/test-harness" )
						.$("getSetting" ).$args("eventName" ).$results("event" )
						.$("importConfiguration" )
						.$("setSetting" );
					ses.setBaseURL("http://localhost" );
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