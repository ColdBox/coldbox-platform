component extends="coldbox.system.testing.BaseInterceptorTest" interceptor="coldbox.system.interceptors.SES"{

	function setup(){
		super.setup();
		ses = interceptor;
	}

	function testConfigure(){
		// mocks
		mockController.$("getSetting").$args("HandlersPath").$results( expandPath("/coldbox/test-harness/handlers") )
			.$("getSetting").$args("HandlersExternalLocationPath").$results("")
			.$("getSetting").$args("Modules").$results( {} )
			.$("getSetting").$args("EventName").$results( 'event' )
			.$("getSetting").$args("DefaultEvent").$results( 'index' );
		ses.$("getSetting").$args("AppMapping").$results("/coldbox/test-harness")
			.$("importConfiguration")
			.$("setSetting");
		ses.setBaseURL("http://localhost");
		ses.configure();
		assertTrue( ses.$atLeast(2,"setSetting") );
	}

	function testAddNamespaceRoutes(){
		ses.$property("namespaceroutingtable","variables",{})
			.$("addRoute");

		ses.addNamespace(pattern="/luis",namespace="luis");

		assertEquals( "luis", ses.$callLog().addRoute[1].namespaceRouting );
		assertEquals( "/luis", ses.$callLog().addRoute[1].pattern );
	}

	function testGetCleanedPaths(){
		makePublic(ses,"getCleanedPaths","getCleanedPaths");

		var rc = {
			someURLvar = 1,
			index = "hello"
		};
		//test folder with index.cfm
		var path_info = "/somefolder/index.cfm?somrURLVar=yes";
		ses.$('getCGIElement').$results(path_info,'');
		var results = ses.getCleanedPaths(rc,'event');
		assertEquals( "/someFolder/index.cfm",  results.pathInfo);

		//test folder with leading index.cfm
		path_info = "/index.cfm/somefolder/index.cfm?somrURLVar=yes";
		ses.$('getCGIElement').$results(path_info,'');
		results = ses.getCleanedPaths(rc,'event');
		assertEquals( "/someFolder/index.cfm",  results.pathInfo);

		//test folder wwith other .cfm
		path_info = "/somefolder/test.cfm?somrURLVar=yes";
		ses.$('getCGIElement').$results(path_info,'');
		results = ses.getCleanedPaths(rc,'event');
		assertEquals( "/someFolder/test.cfm",  results.pathInfo);

		//test regular SES route
		path_info = "/somefolder/test";
		ses.$('getCGIElement').$results(path_info,'');
		results = ses.getCleanedPaths(rc,'event');
		assertEquals( "/somefolder/test",  results.pathInfo);

		//test regular SES route with index
		path_info = "/somefolder/index";
		ses.$('getCGIElement').$results(path_info,'');
		results = ses.getCleanedPaths(rc,'event');
		assertEquals( "/somefolder/index",  results.pathInfo);
	}

	function testDetectFormat() {
		var mockLog = getMockBox().createStub().$( "canDebug", false );
		ses.$property( propertyName = "log", mock = mockLog );
		ses.$("getSetting").$args("AppMapping").$results("/coldbox/test-harness")
			.$("getSetting").$args("eventName").$results("event")
			.$("importConfiguration")
			.$("setSetting");
		ses.setBaseURL("http://localhost");
		ses.configure();
		var mockController = getMockBox().createMock( "coldbox.system.web.Controller" );
		var mockEvent = getMockBox().createMock( "coldbox.system.web.context.RequestContext" ).init( controller = mockController, properties = {
				defaultLayout = "Main.cfm",
				defaultView = "",
				eventName = "event",
				modules = {}
			} );
		var mockInterceptData = {};

		// default format
		ses.$( "getCleanedPaths", {
			pathInfo = "/Main/index",
			scriptName = ""
		} );
		ses.onRequestCapture( mockEvent, mockInterceptData );
		expect( mockEvent.valueExists( "format" ) ).toBeTrue();
		expect( mockEvent.getValue( "format" ) ).toBe( "html" );
		mockEvent.removeValue( "format" );

		// extension detection
		ses.$( "getCleanedPaths", {
			pathInfo = "/Main/index.xml",
			scriptName = ""
		} );
		ses.onRequestCapture( mockEvent, mockInterceptData );
		expect( mockEvent.valueExists( "format" ) ).toBeTrue();
		expect( mockEvent.getValue( "format" ) ).toBe( "xml" );
		mockEvent.removeValue( "format" );

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
	}

}