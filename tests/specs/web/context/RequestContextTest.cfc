component extends="coldbox.system.testing.BaseModelTest" {

	function setUp(){
		/* Properties */
		props.defaultLayout     = "Main.cfm";
		props.defaultView       = "";
		props.folderLayouts     = structNew();
		props.viewLayouts       = structNew();
		props.eventName         = "event";
		props.sesBaseURL        = "http://jfetmac/applications/coldbox/test-harness/index.cfm";
		props.registeredLayouts = structNew();
		props.modules           = {
			test1 : {
				mapping             : "/coldbox/test-harness",
				inheritedEntryPoint : "test1"
			}
		};

		/* Init it */
		mockController = getMockController()
			.$( "getSetting" )
			.$args( "modules" )
			.$results( props.modules )
			.$( "getSetting" )
			.$args( "AppMapping" )
			.$results( "" );
		prepareMock( mockController.getInterceptorService() );
		prepareMock( mockController.getWireBox() );

		oRC = new coldbox.system.web.context.RequestContext( props, mockController );
	}

	function getRequestContext(){
		return prepareMock( oRC );
	}

	function testGetResponseWhenNull(){
		var r = getRequestContext().getResponse();
		expect( r.getData() ).toBeEmpty();
	}

	function testGetResponseWhenItExists(){
		getRequestContext()
			.setPrivateValue( "response", getRequestContext().getResponse() )
			.getResponse()
			.setData( { name : "luis" } );

		var r = getRequestContext().getResponse();
		expect( r.getData().name ).toBe( "luis" );
	}

	function testValidRoutes(){
		// Mocks
		var mockRouter = createStub().$( "getRoutes", [ { name : "contactus", pattern : "contactus/" } ] );
		mockController.getWireBox().$( "getInstance", mockRouter );

		var event = getRequestContext();
		var r     = event.route( "contactus" );
		// debug( r );
		expect( r ).toBe( "http://jfetmac/applications/coldbox/test-harness/index.cfm/contactus/" );
	}

	function testNamedRoutesWithBuildLink(){
		// Mocks
		var mockRouter = createStub().$( "getRoutes", [ { name : "contactus", pattern : "contactus/" } ] );
		mockController.getWireBox().$( "getInstance", mockRouter );

		var event = getRequestContext();
		var r     = event.buildLink( { name : "contactus" } );

		// debug( r );
		expect( r ).toBe( "http://jfetmac/applications/coldbox/test-harness/index.cfm/contactus/" );
	}

	function testNamedRoutesWithParamsWithBuildLink(){
		// Mocks
		var mockRouter = createStub().$( "getRoutes", [ { name : "contactus", pattern : "contactus/:id" } ] );
		mockController.getWireBox().$( "getInstance", mockRouter );

		var event = getRequestContext();
		var r     = event.buildLink( { name : "contactus", params : { id : 3 } } );

		// debug( r );
		expect( r ).toBe( "http://jfetmac/applications/coldbox/test-harness/index.cfm/contactus/3" );
	}

	function testGetModuleEntryPoint(){
		var event = getRequestContext().$property(
			"modules",
			"variables",
			{ myModule : { inheritedEntryPoint : "mymodule/" } }
		);
		var r = event.getModuleEntryPoint( "myModule" );
		expect( r ).toBe( "mymodule/" );
	}

	function testValidModuleRoutes(){
		// Mocks
		var mockRouter = createStub()
			.$( "getModuleRoutes", [ { name : "home", pattern : "home/" } ] )
			.$( "getRoutes", [] );
		mockController.getWireBox().$( "getInstance", mockRouter );

		var event = getRequestContext().$property(
			"modules",
			"variables",
			{ myModule : { inheritedEntryPoint : "mymodule/" } }
		);
		var r = event.route( "home@mymodule" );
		// debug( r );
		expect( r ).toBe( "http://jfetmac/applications/coldbox/test-harness/index.cfm/mymodule/home/" );
	}

	function testInvalidRoute(){
		// Mocks
		var mockSES = createStub().$( "getRoutes", [] );
		mockController.getInterceptorService().$( "getInterceptor", mockSES );

		var event = getRequestContext();
		expect( function(){
			event.route( "invalid" );
		} ).toThrow();
	}

	function testGetHTMLBaseURL(){
		var event = getRequestContext();
		event.$( "isSSL", false );
		expect( event.getHTMLBaseURL() ).toinclude( "http://jfetmac/applications/coldbox/test-harness" );

		event.$( "isSSL", true );
		expect( event.getHTMLBaseURL() ).toinclude( "https://jfetmac/applications/coldbox/test-harness" );
	}

	function testgetCollection(){
		var event = getRequestContext();

		assertTrue( isStruct( event.getCollection() ) );
	}

	function testclearCollection(){
		var event = getRequestContext();
		var test  = { today : now() };

		event.collectionAppend( test );
		event.clearCollection();

		assertEquals( structNew(), event.getCollection() );
	}

	function testcollectionAppend(){
		var event  = getRequestContext();
		var test   = structNew();
		test.today = now();

		event.clearCollection();
		event.collectionAppend( test );

		assertEquals( test, event.getCollection() );
	}

	function testgetSize(){
		var event  = getRequestContext();
		var test   = structNew();
		test.today = now();

		event.clearCollection();
		event.collectionAppend( test );

		assertEquals( 1, event.getSize() );
	}

	function testgetValue(){
		var event  = getRequestContext();
		var test   = structNew();
		test.today = now();

		event.clearCollection();
		event.collectionAppend( test );

		assertEquals( test.today, event.getValue( "today" ) );

		assertEquals( "null", event.getValue( "invalidVar", "null" ) );
	}

	function testsetValue(){
		var event  = getRequestContext();
		var test   = structNew();
		test.today = now();

		event.clearCollection();

		event.setValue( "test", test.today );

		assertEquals( test.today, event.getValue( "test" ) );
	}

	function testremoveValue(){
		var event  = getRequestContext();
		var test   = structNew();
		test.today = now();

		event.clearCollection();

		event.setValue( "test", test.today );
		assertEquals( test.today, event.getValue( "test" ) );

		event.removeValue( "test" );
		assertEquals( false, event.getValue( "test", false ) );
	}

	function testvalueExists(){
		var event  = getRequestContext();
		var test   = structNew();
		test.today = now();

		event.clearCollection();

		event.setValue( "test", test.today );
		assertTrue( event.valueExists( "test" ) );

		event.removeValue( "test" );
		assertFalse( event.valueExists( "test" ) );
	}

	function testparamValue(){
		var event  = getRequestContext();
		var test   = structNew();
		test.today = now();

		event.clearCollection();

		assertFalse( event.valueExists( "test" ) );

		event.paramValue( "test", test.today );

		assertTrue( event.valueExists( "test" ) );
	}

	function testCurrentView(){
		var event = getRequestContext();
		var view  = "vwHome";

		event.clearCollection();

		event.setView( view = view );
		assertEquals( view, event.getCurrentView() );

		event.clearCollection();

		event.setView( view = view, cache = true );
		assertEquals( view, event.getCurrentView() );
		assertEquals( "Main.cfm", event.getCurrentLayout() );

		// set view with caching
		event.setView(
			view                   = "home",
			cache                  = "True",
			cacheProvider          = "luis",
			cacheTimeout           = "20",
			cacheLastAccessTimeout = "1",
			cacheSuffix            = "test"
		);
		r = event.getViewCacheableEntry();
		// debug( r );

		assertEquals( "home", r.view );
		assertEquals( "20", r.timeout );
		assertEquals( "1", r.lastAccessTimeout );
		assertEquals( "test", r.cacheSuffix );
		assertEquals( "luis", r.cacheProvider );
	}

	function testCurrentLayout(){
		var event  = getRequestContext();
		var layout = "layout.pdf";

		event.clearCollection();

		event.setLayout( layout );
		assertEquals( layout & ".cfm", event.getCurrentLayout() );
	}

	function testGetCurrentHandlerWithModule(){
		var event        = getRequestContext();
		var defaultEvent = "myModule:test.doSomething";

		event.setValue( "event", defaultEvent );

		expect( event.getCurrentModule() ).toBe( "myModule" );
		expect( event.getCurrentHandler() ).toBe( "test" );
		expect( event.getCurrentAction() ).toBe( "doSomething" );
	}

	function testgetCurrentEventHandlerAction(){
		var event        = getRequestContext();
		var defaultEvent = "ehTest.doSomething";

		event.setValue( "event", defaultEvent );

		assertEquals( defaultEvent, event.getCurrentEvent() );
		assertEquals( "ehTest", event.getCurrentHandler() );
		assertEquals( "doSomething", event.getCurrentAction() );

		defaultEvent = "blog.content.doSomething";

		event.setValue( "event", defaultEvent );

		assertEquals( defaultEvent, event.getCurrentEvent() );
		assertEquals( "content", event.getCurrentHandler() );
		assertEquals( "doSomething", event.getCurrentAction() );

		defaultEvent = "blog.content.security.doSomething";

		event.setValue( "event", defaultEvent );

		assertEquals( defaultEvent, event.getCurrentEvent() );
		assertEquals( "security", event.getCurrentHandler() );
		assertEquals( "doSomething", event.getCurrentAction() );
	}

	function testoverrideEvent(){
		var event    = getRequestContext();
		var newEvent = "pio.yea";

		event.clearCollection();
		event.setValue( "event", "blog.dspEntries" );
		event.overrideEvent( newEvent );

		assertEquals( newEvent, event.getCurrentEvent() );
	}

	function testProxyRequest(){
		var event = getRequestContext();

		assertFalse( event.isProxyRequest() );

		event.setProxyRequest();
		assertTrue( event.isProxyRequest() );
	}

	function testNoRender(){
		var event = getRequestContext();

		event.NoRender( remove = true );
		assertFalse( event.isNoRender() );

		event.NoRender( remove = false );
		assertTrue( event.isNoRender() );
	}

	function testgetEventName(){
		var event = getRequestContext();
		var test  = props.eventName;

		assertEquals( test, event.getEventName() );
	}

	function testgetSelf(){
		var event = getRequestContext();
		var test  = props.eventname;

		assertEquals( "index.cfm?#test#=", event.getSelf() );
	}

	function testEventCacheableEntry(){
		var event  = getRequestContext();
		var centry = structNew();

		assertFalse( event.isEventCacheable(), "event cacheable" );

		centry.cacheable = true;
		centry.test      = true;

		event.setEventCacheableEntry( centry );
		assertTrue( event.isEventCacheable(), "event cacheable 2" );
		assertEquals( centry, event.getEventCacheableEntry() );
	}

	function testViewCacheableEntry(){
		var event  = getRequestContext();
		var centry = structNew();

		assertFalse( event.isViewCacheable(), "view cacheable" );

		centry.cacheable = true;
		centry.test      = true;

		event.setViewCacheableEntry( centry );
		assertTrue( event.isViewCacheable(), "view cacheable 2" );
		assertEquals( centry, event.getViewCacheableEntry() );
	}

	function testRoutedStruct(){
		var event        = getRequestContext();
		var routedStruct = structNew();

		routedStruct.page = "aboutus";
		routedStruct.day  = "13";

		event.setRoutedStruct( routedStruct );

		assertEquals( event.getRoutedStruct(), routedStruct );
	}

	function testSES(){
		var event = getRequestContext();
		base      = "http://www.luismajano.com/index.cfm";

		event.setsesBaseURL( base );
		assertEquals( event.getsesBaseURL(), base );

		assertEquals( event.isSES(), true );
	}

	function testInvalidHTTPMethod(){
		var event = getRequestContext();
		assertEquals( event.isInvalidHTTPMethod(), false );

		event.setIsInvalidHTTPMethod( true );
		assertEquals( event.isInvalidHTTPMethod(), true );

		event.setIsInvalidHTTPMethod( false );
		assertEquals( event.isInvalidHTTPMethod(), false );
	}

	function testBuildLink(){
		var event   = getRequestContext();
		var base    = "http://www.luismajano.com";
		var basessl = "https://www.luismajano.com";

		/* simple setup */
		event.setsesBaseURL( "/" );
		testurl = event.buildLink( "general.index" );
		assertEquals( testurl, "/general/index" );

		/* simple qs */
		testurl = event.buildLink( to = "general.index", queryString = "page=2" );
		assertEquals( testurl, "/general/index/page/2" );

		/* empty qs */
		testurl = event.buildLink( to = "general.index", queryString = "" );
		assertEquals( testurl, "/general/index" );

		/* ses test */
		event.setsesBaseURL( base );
		testurl = event.buildLink( to = "general/index", ssl = false );
		assertEquals( testurl, base & "/general/index" );

		/* query string transformation */
		event.setsesBaseURL( base );
		testurl = event.buildLink(
			to          = "general/index",
			queryString = "page=2&tests=4",
			ssl         = false
		);
		assertEquals( testurl, base & "/general/index/page/2/tests/4" );

		/* query string as struct transformation */
		event.setsesBaseURL( base );
		testurl = event.buildLink(
			to          = "general/index",
			queryString = { page : 2, tests : 4 },
			ssl         = false
		);
		expect( testurl ).toInclude( "tests/4" );
		expect( testurl ).toInclude( "page/2" );

		/* ssl test */
		event.setsesBaseURL( base );
		testurl = event.buildLink( to = "general/index", ssl = true );
		assertEquals( testurl, basessl & "/general/index" );

		// SSL OFF
		event.setsesBaseURL( basessl );
		testurl = event.buildLink(
			to          = "general/index",
			ssl         = false,
			queryString = "name=luis&cool=false"
		);
		assertEquals( testurl, base & "/general/index/name/luis/cool/false" );

		/* translate */
		event.setsesBaseURL( base );
		testurl = event.buildLink(
			to        = "general.index",
			translate = false,
			ssl       = false
		);
		assertEquals( testurl, base & "/general.index" );

		/* translate with query string */
		event.setsesBaseURL( base );
		testurl = event.buildLink(
			to          = "general.index",
			queryString = "name=luis&cool=false",
			translate   = false,
			ssl         = false
		);
		assertEquals( testurl, base & "/general.index?name=luis&cool=false" );

		// SES Module Translations
		event.setsesBaseURL( base );
		var testUrl = event.buildLink( to = "test1:main.index", translate = true );
		expect( testurl ).toBe( "http://www.luismajano.com/test1/main/index" );
	}

	function testRenderData(){
		var event = getRequestContext();

		assertEquals( event.getRenderData(), structNew() );

		// Test JSON
		event.renderData( type = "JSON", data = "[1,2,3,4]" );
		rd = event.getRenderData();
		assertEquals( rd.contenttype, "application/json" );
		assertEquals( rd.type, "json" );
		assertEquals( rd.jsonQueryFormat, true );
		assertEquals( rd.statusCode, "200" );
		assertEquals( rd.statusText, "" );


		event.renderData(
			type            = "JSON",
			data            = "[1,2,3,4]",
			jsonQueryFormat = "array",
			jsonCase        = "upper"
		);
		rd = event.getRenderData();
		assertEquals( rd.jsonQueryFormat, false );

		// JSONP
		event.renderData(
			type         = "JSONP",
			data         = "[1,2,3,4]",
			jsonCallback = "testCallback"
		);
		rd = event.getRenderData();
		assertEquals( rd.type, "jsonp" );
		assertEquals( rd.jsonCallback, "testCallback" );

		// Test WDDX
		event.renderData( type = "WDDX", data = arrayNew( 1 ) );
		rd = event.getRenderData();
		assertEquals( rd.contenttype, "text/xml" );
		assertEquals( rd.type, "wddx" );

		// Test PLAIN
		event.renderData( data = "Hello" );
		rd = event.getRenderData();
		assertEquals( rd.type, "html" );
		assertEquals( rd.contenttype, "text/html" );

		// Test XML
		event.renderData( data = structNew(), type = "xml" );
		rd = event.getRenderData();
		assertEquals( rd.type, "xml" );
		assertEquals( rd.contenttype, "text/xml" );
		assertEquals( rd.xmlListDelimiter, "," );
		assertEquals( rd.xmlColumnList, "" );

		// Test contenttype
		event.renderData( data = "Hello", contentType = "application/ms-excel" );
		rd = event.getRenderData();
		assertEquals( rd.type, "html" );
		assertEquals( rd.contenttype, "application/ms-excel" );

		// Test StatusCodes
		event.renderData(
			data       = "hello",
			statusCode = "400",
			statusText = "Invalid Call!"
		);
		rd = event.getRenderData();
		assertEquals( rd.statusCode, "400" );
		assertEquals( rd.statusText, "Invalid Call!" );
	}

	function testNoExecution(){
		var event = getRequestContext();
		expect( event.getIsNoExecution() ).toBeFalse();

		event.noExecution();
		expect( event.getIsNoExecution() ).toBeTrue();
	}

	function testCurrentModule(){
		var event = getRequestContext();

		event.setValue( "event", "myModule:test.home" );

		// debug(event.getCurrentEVent());
		assertEquals( "myModule", event.getCurrentModule() );

		event.setValue( "event", "test.home" );
		assertEquals( "", event.getCurrentModule() );
	}


	function testModuleRoot(){
		var event = getRequestContext();


		// debug(event.getCurrentEVent());
		assertEquals( "", event.getmoduleRoot() );
		event.setValue( "event", "test1:test.home" );
		assertEquals( props.modules.test1.mapping, event.getmoduleRoot() );
	}


	function testsetHTTPHeader(){
		var event = getRequestContext();

		event.setHTTPHeader( statusCode = "200", statusText = "Hello" );

		event.setHTTPHeader( name = "expires", value = "#now()#" );
	}

	function testGetHTTPContent(){
		var event = getRequestContext();

		test = event.getHTTPContent();

		assertTrue( isSimpleValue( test ) );
	}

	function testNoLayout(){
		var event = getRequestContext();

		event.noLayout().setView( "test" );

		// debug( event.getCollection(private=true) );
		assertEquals( true, event.getValue( "layoutOverride", false, true ) );
	}

	function testDoubleSlashInBuildLink(){
		var event = getRequestContext();

		link = event.buildLink( to = "my/event/handler/", queryString = "one=1&two=2" );
		expect( link ).toInclude( "test-harness/index.cfm/my/event/handler/one/1/two/2" );

		// debug( link );
	}

	function testOnlyArray(){
		var event = getRequestContext();
		event.setValue( "name", "John" );
		event.setValue( "email", "john@example.com" );
		event.setValue( "hackedField", "hacked!" );

		expect( event.getOnly( [ "name", "email", "field-that-does-not-exist" ] ) ).toBe( { "name" : "John", "email" : "john@example.com" } );
	}

	function testOnlyList(){
		var event = getRequestContext();
		event.setValue( "name", "John" );
		event.setValue( "email", "john@example.com" );
		event.setValue( "hackedField", "hacked!" );

		expect( event.getOnly( "name,email,field-that-does-not-exist" ) ).toBe( { "name" : "John", "email" : "john@example.com" } );
	}

	function testPrivateOnlyFlag(){
		var event = getRequestContext();
		event.setValue( "name", "John" );
		event.setValue( "hackedField", "hacked!" );
		event.setValue( "name", "Jane", true );
		event.setValue( "hackedField", "hacked as well!", true );

		expect( event.getOnly( keys = "name,field-that-does-not-exist", private = true ) ).toBe( { "name" : "Jane" } );
	}

	function testPrivateOnlyMethod(){
		var event = getRequestContext();
		event.setValue( "name", "John" );
		event.setValue( "hackedField", "hacked!" );
		event.setValue( "name", "Jane", true );
		event.setValue( "hackedField", "hacked as well!", true );

		expect( event.getPrivateOnly( [ "name", "field-that-does-not-exist" ] ) ).toBe( { "name" : "Jane" } );
	}

	function testExceptArray(){
		var event = getRequestContext();
		event.setValue( "name", "John" );
		event.setValue( "email", "john@example.com" );
		event.setValue( "hackedField", "hacked!" );

		expect( event.getExcept( [ "hackedField", "field-that-does-not-exist" ] ) ).toBe( { "name" : "John", "email" : "john@example.com" } );
	}

	function testExceptList(){
		var event = getRequestContext();
		event.setValue( "name", "John" );
		event.setValue( "email", "john@example.com" );
		event.setValue( "hackedField", "hacked!" );

		expect( event.getExcept( "hackedField,field-that-does-not-exist" ) ).toBe( { "name" : "John", "email" : "john@example.com" } );
	}

	function testPrivateExceptFlag(){
		var event = getRequestContext();
		event.setValue( "name", "John" );
		event.setValue( "hackedField", "hacked!" );
		event.setValue( "name", "Jane", true );
		event.setValue( "hackedField", "hacked as well!", true );

		expect( event.getExcept( keys = "hackedField,key-that-does-not-exist", private = true ) ).toBe( { "name" : "Jane" } );
	}

	function testPrivateExceptMethod(){
		var event = getRequestContext();
		event.setValue( "name", "John" );
		event.setValue( "hackedField", "hacked!" );
		event.setValue( "name", "Jane", true );
		event.setValue( "hackedField", "hacked as well!", true );

		expect( event.getPrivateExcept( [ "hackedField", "key-that-does-not-exist" ] ) ).toBe( { "name" : "Jane" } );
	}

	function testGetFullUrl(){
		var event = getRequestContext();
		debug( event.getFullUrl() );
		expect( event.getFullUrl() ).toBeTypeOf( "url", "Not an URL" );
		var javaUrl = createObject( "java", "java.net.URL" ).init( event.getFullUrl() );
	}

	function testGetFullUrlWithAppMapping(){
		mockController
			.$( "getSetting" )
			.$args( "AppMapping" )
			.$results( "test-harness" );

		var event = getRequestContext();

		debug( event.getFullUrl() );
		expect( event.getFullUrl() ).toBeTypeOf( "url" );

		var javaUrl = createObject( "java", "java.net.URL" ).init( event.getFullUrl() );
	}

	function testUrlMatches(){
		var event = getRequestContext();
		event.setPrivateValue( "currentRoutedURL", "/foo/bar/baz" );
		expect( event.getCurrentRoutedURL() ).toBe( "/foo/bar/baz" );
		expect( event.urlMatches( "/foo/bar/baz" ) ).toBeTrue();
		expect( event.urlMatches( "/foo/baz/bar" ) ).toBeFalse();
		expect( event.urlMatches( "/bar/baz" ) ).toBeFalse();
		expect( event.urlMatches( "/foo/bar" ) ).toBeTrue();
		expect( event.urlMatches( "/foo" ) ).toBeTrue();
		expect( event.urlMatches( "/" ) ).toBeTrue();
		expect( event.urlMatches( path = "/foo/bar", exact = true ) ).toBeFalse();
		expect( event.urlMatchesExact( "/foo/bar" ) ).toBeFalse();
	}

}
