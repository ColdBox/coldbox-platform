<cfcomponent extends="coldbox.system.testing.BaseModelTest">
	<cfscript>
	function setup(){
		mockLogger = createEmptyMock( "coldbox.system.logging.Logger" )
			.$( "canDebug", true )
			.$( "debug" )
			.$( "error" )
			.$( "canWarn", true )
			.$( "warn" );
		mockLogBox   = createEmptyMock( "coldbox.system.logging.LogBox" ).$( "getLogger", mockLogger );
		mockCacheBox = createEmptyMock( "coldbox.system.cache.CacheFactory" );
		mockColdBox  = createEmptyMock( "coldbox.system.web.Controller" );

		mockInjector = createMock( "coldbox.system.ioc.Injector" )
			.setLogBox( mockLogBox )
			.setCacheBox( mockCacheBox )
			.setColdBox( mockColdBox );

		builder = createMock( "coldbox.system.ioc.dsl.ColdBoxDSL" ).init( mockInjector );
	}

	function testProcess(){
		// Mock spies
		builder.$( "getEntityServiceDSL", true ).$( "getColdboxDSL", true );

		def = { dsl : "coldbox" };
		builder.process( def );
		assertTrue( builder.$once( "getColdboxDSL" ) );
	}

	function testInvalidDSL(){
		makePublic( builder, "getColdboxDSL" );
		try {
			c = builder.getColdBoxDSL( { name : "coldbox", dsl : "coldbox:foobar" } );
			c = builder.getColdBoxDSL( { name : "coldbox", dsl : "coldbox:foobar:testss" } );
			c = builder.getColdBoxDSL( {
				name : "coldbox",
				dsl  : "coldbox:foobar:testss:invalid:invliad"
			} );

			fail( "Invalid Throw Type for DSL" );
		} catch ( "ColdBoxDSL.InvalidDSL" e ) {
			// The right catch
		} catch ( any e ) {
			fail( "Invalid Throw Type for DSL" );
		}
	}

	function testgetColdboxDSLStage1AndStage2(){
		makePublic( builder, "getColdboxDSL" );

		// coldbox
		def = { name : "coldbox", dsl : "coldbox" };
		c   = builder.getColdBoxDSL( def );
		assertEquals( mockColdbox, c );

		// stage 2
		mockColdbox.$( "getLoaderService", this );
		def = { name : "configBean", dsl : "coldbox:loaderService" };
		c   = builder.getColdBoxDSL( def );
		assertEquals( this, c );

		mockColdbox.$( "getRequestService", this );
		def = { name : "configBean", dsl : "coldbox:requestService" };
		c   = builder.getColdBoxDSL( def );
		assertEquals( this, c );

		mockFlash = createEmptyMock( "coldbox.system.web.flash.SessionFlash" );
		mockColdbox.$( "getRequestService", createStub().$( "getFlashScope", mockFlash ) );
		def = { name : "flash", dsl : "coldbox:flash" };
		c   = builder.getColdBoxDSL( def );
		assertEquals( mockFlash, c );

		mockEvent = createEmptyMock( "coldbox.system.web.context.RequestContext" );
		mockColdbox.$( "getRequestService", createStub().$( "getContext", mockEvent ) );
		def = { name : "event", dsl : "coldbox:requestContext" };
		c   = builder.getColdBoxDSL( def );
		assertEquals( mockEvent, c );

		mockColdbox.$( "getHandlerService", this );
		def = { name : "configBean", dsl : "coldbox:handlerService" };
		c   = builder.getColdBoxDSL( def );
		assertEquals( this, c );

		mockColdbox.$( "getInterceptorService", this );
		def = { name : "configBean", dsl : "coldbox:interceptorService" };
		c   = builder.getColdBoxDSL( def );
		assertEquals( this, c );

		mockColdbox.$( "getModuleService", this );
		def = { name : "configBean", dsl : "coldbox:moduleService" };
		c   = builder.getColdBoxDSL( def );
		assertEquals( this, c );

		mockRenderer = createEmptyMock( "coldbox.system.web.Renderer" );
		mockColdbox.$( "getRenderer", mockrenderer );
		def = { name : "renderer", dsl : "coldbox:renderer" };
		c   = builder.getColdBoxDSL( def );
		assertEquals( mockrenderer, c );

		mockMarshaller = createEmptyMock( "coldbox.system.core.conversion.DataMarshaller" );
		mockColdbox.$( "getDataMarshaller", mockMarshaller );
		def = { name : "marshaller", dsl : "coldbox:dataMarshaller" };
		c   = builder.getColdBoxDSL( def );
		assertEquals( mockMarshaller, c );
	}

	function testgetColdboxDSLStage3(){
		makePublic( builder, "getColdboxDSL" );

		// setting
		def = { name : "mySetting", dsl : "coldbox:setting" };
		mockColdBox
			.$( "getSetting" )
			.$args( "mySetting" )
			.$results( "UnitTest" );
		c = builder.getColdBoxDSL( def );
		assertEquals( "unitTest", c );
		// setting@module
		def = {
			name : "mySetting",
			dsl  : "coldbox:setting:mySetting@myModule"
		};
		modSettings = { myModule : { settings : { mySetting : "unitTest" } } };
		mockColdBox
			.$( "getSetting" )
			.$args( "modules" )
			.$results( modSettings );
		c = builder.getColdBoxDSL( def );
		assertEquals( "unitTest", c );

		// modulesettings
		def = {
			name : "mySetting",
			dsl  : "coldbox:moduleSettings:myModule"
		};
		modSettings = {
			myModule : {
				moduleMapping : "/modules/MyModule",
				settings      : { mySetting : "unitTest" }
			}
		};
		mockColdBox
			.$( "getSetting" )
			.$args( "modules" )
			.$results( modSettings );
		c = builder.getColdBoxDSL( def );
		assertEquals( modSettings.myModule.settings, c );

		// moduleConfig
		def = {
			name : "mySetting",
			dsl  : "coldbox:moduleConfig:myModule"
		};
		modSettings = {
			myModule : {
				moduleMapping : "/modules/MyModule",
				settings      : { mySetting : "unitTest" }
			}
		};
		mockColdBox
			.$( "getSetting" )
			.$args( "modules" )
			.$results( modSettings );
		c = builder.getColdBoxDSL( def );
		assertEquals( modSettings.myModule, c );

		// fwsetting
		def = { name : "mySetting", dsl : "coldbox:fwSetting" };
		mockColdBox
			.$( "getColdBoxSetting" )
			.$args( "mySetting" )
			.$results( "UnitTest" );
		c = builder.getColdBoxDSL( def );
		assertEquals( "unitTest", c );

		// interceptor
		def    = { name : "ds", dsl : "coldbox:interceptor:coolAlias" };
		mockIS = createStub()
			.$( "getInterceptor" )
			.$args( "coolAlias", true )
			.$results( this );
		mockColdbox.$( "getInterceptorService", mockIS );
		c = builder.getColdBoxDSL( def );
		assertEquals( this, c );
	}
	</cfscript>
</cfcomponent>
