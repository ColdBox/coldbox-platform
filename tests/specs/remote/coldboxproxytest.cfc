component extends="tests.resources.BaseIntegrationTest" {

	function setup(){
		super.setup();
		proxy = createObject( "component", "cbtestharness.remote.MyProxy" );
	}

	function teardown(){
		structDelete( application, "testApp" );
	}

	function testRemotingUtil(){
		makePublic( proxy, "getRemotingUtil" );
		util = proxy.getRemotingUtil();
		assertTrue( isObject( util ) );
	}

	function testNoEvent(){
		// Test With default ProxyReturnCollection = false
		expectException( "ColdBoxProxy.NoEventDetected" );
		makePublic( proxy, "process" );
		results = proxy.process();
	}

	function testProxyNoCollection(){
		var results = "";

		// Test With default ProxyReturnCollection = false
		makePublic( proxy, "process" );
		results = proxy.process( event = "proxy.getIntroArrays" );
		assertTrue( isArray( results ), "Getting Array" );

		// test other process
		results = proxy.process( event = "proxy.getIntroStructure" );
		assertTrue( isStruct( results ), "Getting Structure" );
	}

	function testProxyWithCollection(){
		var results = "";

		// Set return setting
		application.cbController.setSetting( "ProxyReturnCollection", true );

		// Test With default ProxyReturnCollection = false
		makePublic( proxy, "process" );
		results = proxy.process( event = "proxy.getIntroArraysCollection" );
		assertTrue( isStruct( results ), "Collection Test" );
		assertTrue( isArray( results.myArray ), "Getting Array From Collection" );

		application.cbController.setSetting( "ProxyReturnCollection", false );
	}

	function testProxyInterceptions(){
		var results = "";

		// Announce interception
		makePublic( proxy, "announce" );
		results = proxy.announce( state = "onLog" );
		assertTrue( results, "onLog intercepted" );
	}

	function testVerifyColdBox(){
		makePublic( proxy, "verifyColdBox" );
		assertTrue( proxy.verifyColdBox() );
		structDelete( application, "cbController" );
		expectException( "ColdBoxProxy.ControllerIllegalState" );
		proxy.verifyColdBox();
	}

	function testGetCacheBox(){
		makePublic( proxy, "getCacheBox" );
		assertTrue( isObject( proxy.getCacheBox() ) );
	}

	function testGetWireBox(){
		makePublic( proxy, "getWireBox" );
		assertTrue( isObject( proxy.getWireBox() ) );
	}

	function testGetInstance(){
		makePublic( proxy, "getInstance" );
		assertTrue( isObject( proxy.getInstance( "testModel" ) ) );
	}

	function testProxyAppLoading(){
		local.load                = structNew();
		local.load.appMapping     = "/cbTestHarness";
		local.load.configLocation = "cbTestHarness.config.Coldbox";
		local.load.reloadApp      = true;
		local.load.appKey         = "testApp";

		makePublic( proxy, "loadColdBox" );
		proxy.loadColdBox( argumentCollection = local.load );
	}

	function testLogBox(){
		makePublic( proxy, "getLogBox" );
		makePublic( proxy, "getRootLogger" );
		makePublic( proxy, "getLogger" );
		assertEquals( getController().getLogBox(), proxy.getLogBox() );
		assertEquals( getController().getLogBox().getRootLogger(), proxy.getRootLogger() );
		assertEquals( getController().getLogBox().getLogger( "unittest" ), proxy.getLogger( "unittest" ) );
	}

	function testGetInterceptor(){
		makePublic( proxy, "getInterceptor" );
		assertTrue( isObject( proxy.getInterceptor( "test1" ) ) );
	}

	function testGetCache(){
		makePublic( proxy, "getCache" );
		assertTrue( isObject( proxy.getCache() ) );
		assertTrue( isObject( proxy.getCache( "template" ) ) );
	}

}
