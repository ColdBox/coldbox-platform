component extends="tests.resources.BaseIntegrationTest" {

	this.loadColdBox = false;

	function setup(){
		// mocks
		mockLogger = createEmptyMock( "coldbox.system.logging.Logger" ).$( "canDebug", true ).$( "debug" );
		mockLogBox = createEmptyMock( "coldbox.system.logging.LogBox" ).$( "getLogger", mockLogger );
		mockBinder = createMock( "coldbox.system.ioc.config.Binder" );

		mockInjector = createMock( "coldbox.system.ioc.Injector" ).setLogBox( mockLogBox ).setBinder( mockBinder );

		// mixer
		mixer = createMock( "coldbox.system.aop.Mixer" ).configure( mockInjector, {} );
	}

	function testafterInstanceAutowire(){
		// mocks
		mockMapping = getMockBox()
			.createMock( "coldbox.system.ioc.config.Mapping" )
			.init( "unitTest" )
			.$( "getName", "unitTest" );
		mockTarget = createStub();
		// intercept data
		data       = { mapping : mockMapping, target : mockTarget };
		mixer.$( "buildAspectDictionary" );

		// 1: target already mixed
		mockTarget.$wbAOPMixed = true;
		mixer.afterInstanceAutowire( data );
		assertTrue( mixer.$never( "buildAspectDictionary" ) );

		// 2: target NOT mixed and we need dictionary and nothing matched
		structDelete( mockTarget, "$wbAOPMixed" );
		var dictionary = { "unittest" : [] };
		mixer
			.$( "AOPBuilder" )
			.$( "buildClassMatchDictionary" )
			.$property(
				"classMatchDictionary",
				"variables",
				dictionary
			);
		mixer.afterInstanceAutowire( data );
		assertTrue( mixer.$never( "AOPBuilder" ) );

		// 3: target NOT mixed and we need dictionary and it matches with methods
		dictionary = { "unitTest" : [ { classes : "", methods : "", aspects : "1,2" } ] };
		mixer
			.$( "AOPBuilder" )
			.$( "buildClassMatchDictionary" )
			.$property(
				"classMatchDictionary",
				"variables",
				dictionary
			);
		mixer.afterInstanceAutowire( data );
		assertTrue( mixer.$once( "AOPBuilder" ) );
		assertTrue( mixer.$never( "buildClassMatchDictionary" ) );
	}

	function testdecorateAOPTarget(){
		makePublic( mixer, "decorateAOPTarget" );
		mockLogger.$( "canDebug", false );
		mockMapping = createMock( "coldbox.system.ioc.config.Mapping" ).$( "getName", "unitTest" );
		mixer.decorateAOPTarget( this, mockMapping );

		assertTrue( structKeyExists( this, "$wbAOPTargets" ) );
		assertTrue( structKeyExists( this, "$wbAOPInclude" ) );
		assertTrue( structKeyExists( this, "$wbAOPStoreJointPoint" ) );
		assertTrue( structKeyExists( this, "$wbAOPInvokeProxy" ) );
		assertTrue( structKeyExists( this, "$wbAOPRemove" ) );
	}

	function testBuildInterceptors(){
		makePublic( mixer, "buildInterceptors" );
		// mocks
		mockInjector.$( "getInstance" ).$results( createStub(), createStub() );

		objs = mixer.buildInterceptors( [ "aspect1", "aspect2" ] );

		assertEquals( 2, arrayLen( objs ) );
	}

	function testAOPBuilder(){
		makePublic( mixer, "AOPBuilder" );
	}

	function testBuildClassMatchDictionary(){
		var aspects = [
			{
				classes : createMock( "coldbox.system.aop.Matcher" ).init().$( "matchClass", true ),
				methods : createMock( "coldbox.system.aop.Matcher" ).init(),
				aspects : "Transaction"
			}
		];
		mockBinder.setAspectBindings( aspects );
		mockMapping = createMock( "coldbox.system.ioc.config.Mapping" ).$( "getName", "unitTest" );

		makePublic( mixer, "buildClassMatchDictionary" );
		mixer.buildClassMatchDictionary( this, mockMapping, "123" );
		r = mixer.getclassMatchDictionary();
		assertTrue( arrayLen( r[ "unittest" ] ) );
	}


	function testprocessTargetMethods(){
		mockMapping = createMock( "coldbox.system.ioc.config.Mapping" ).$( "getName", "unitTest" );
		md          = { functions : [ { name : "testMethod" } ] };
		dictionary  = [
			{
				classes : "",
				methods : createEmptyMock( "coldbox.system.aop.Matcher" ).$( "matchMethod", true ),
				aspects : [ "Transaction" ]
			}
		];

		makePublic( mixer, "processTargetMethods" );

		// proxied already
		this.$wbAOPTargets = { "testMethod" : true };
		mixer.$( "weaveAdvice" );
		mixer.processTargetMethods( this, mockMapping, md, dictionary );
		assertTrue( mixer.$never( "weaveAdvice" ) );

		// proxy methods
		this.$wbAOPTargets = {};
		mixer.$( "weaveAdvice" );
		mixer.processTargetMethods( this, mockMapping, md, dictionary );
		assertTrue( mixer.$once( "weaveAdvice" ) );
		// debug( mixer.$callLog().weaveAdvice[1] );

		assertEquals( mixer.$callLog().weaveAdvice[ 1 ].target, this );
		assertEquals( mixer.$callLog().weaveAdvice[ 1 ].jointpoint, "testMethod" );
		assertEquals( mixer.$callLog().weaveAdvice[ 1 ].aspects, [ "Transaction" ] );

		// proxy methods
		this.$wbAOPTargets = {};
		dictionary         = [
			{
				classes : "",
				methods : createEmptyMock( "coldbox.system.aop.Matcher" ).$( "matchMethod", false ),
				aspects : "Transaction"
			}
		];
		mixer.$( "weaveAdvice" );
		mixer.processTargetMethods( this, mockMapping, md, dictionary );
		assertTrue( mixer.$never( "weaveAdvice" ) );
		// debug( mixer.$callLog().weaveAdvice[1] );
	}

}
