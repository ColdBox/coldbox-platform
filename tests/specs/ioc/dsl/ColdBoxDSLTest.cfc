<cfcomponent extends="coldbox.system.testing.BaseModelTest">
<cfscript>

	function setup(){
		mockLogger = getMockBox().createEmptyMock("coldbox.system.logging.Logger").$("canDebug",true).$("debug").$("error").$("canWarn",true).$("warn");
		mockLogBox = getMockBox().createEmptyMock("coldbox.system.logging.LogBox")
			.$("getLogger", mockLogger);
		mockCacheBox = getMockBox().createEmptyMock("coldbox.system.cache.CacheFactory");
		mockColdBox = getMockBox().createEmptyMock("coldbox.system.web.Controller");

		mockInjector = getMockBox().createEmptyMock("coldbox.system.ioc.Injector")
			.$("getLogBox", mockLogBox )
			.$("getCacheBox", mockCacheBox)
			.$("getColdBox", mockColdBox);

		builder = getMockBox().createMock("coldbox.system.ioc.dsl.ColdBoxDSL").init( mockInjector );
	}

	function testProcess(){
		// Mock spies
		builder
			.$("getEntityServiceDSL",true)
			.$("getColdboxDSL",true);

		def = {dsl="coldbox"};
		builder.process(def);
		assertTrue( builder.$once("getColdboxDSL") );
	}

	function testInvalidDSL(){
		makePublic( builder, "getColdboxDSL" );
		try{
			c = builder.getColdBoxDSL( { name="coldbox", dsl="coldbox:foobar" } );
			c = builder.getColdBoxDSL( { name="coldbox", dsl="coldbox:foobar:testss" } );
			c = builder.getColdBoxDSL( { name="coldbox", dsl="coldbox:foobar:testss:invalid:invliad" } );

			fail( "Invalid Throw Type for DSL" );

		} catch( "ColdBoxDSL.InvalidDSL" e ){
			// The right catch
		} catch( any e ){
			fail( "Invalid Throw Type for DSL" );
		}
	}

	function testgetColdboxDSLStage1AndStage2(){
		makePublic(builder, "getColdboxDSL");

		// coldbox
		def = {name="coldbox", dsl="coldbox"};
		c = builder.getColdBoxDSL(def);
		assertEquals(mockColdbox, c);

		// stage 2
		mockColdbox.$("getLoaderService",this);
		def = {name="configBean", dsl="coldbox:loaderService"};
		c = builder.getColdBoxDSL(def);
		assertEquals( this, c);

		mockColdbox.$("getRequestService",this);
		def = {name="configBean", dsl="coldbox:requestService"};
		c = builder.getColdBoxDSL(def);
		assertEquals( this, c);

		mockFlash = getMockBox().createEmptyMock("coldbox.system.web.flash.SessionFlash");
		mockColdbox.$("getRequestService", getMockBox().createStub().$("getFlashScope", mockFlash) );
		def = {name="flash", dsl="coldbox:flash"};
		c = builder.getColdBoxDSL(def);
		assertEquals( mockFlash, c);

		mockEvent = getMockBox().createEmptyMock("coldbox.system.web.context.RequestContext");
		mockColdbox.$("getRequestService", getMockBox().createStub().$("getContext", mockEvent) );
		def = {name="event", dsl="coldbox:requestContext"};
		c = builder.getColdBoxDSL(def);
		assertEquals( mockEvent, c);

		mockColdbox.$("getHandlerService",this);
		def = {name="configBean", dsl="coldbox:handlerService"};
		c = builder.getColdBoxDSL(def);
		assertEquals( this, c);

		mockColdbox.$("getInterceptorService",this);
		def = {name="configBean", dsl="coldbox:interceptorService"};
		c = builder.getColdBoxDSL(def);
		assertEquals( this, c);

		mockColdbox.$("getModuleService",this);
		def = {name="configBean", dsl="coldbox:moduleService"};
		c = builder.getColdBoxDSL(def);
		assertEquals( this, c);

		mockRenderer = createEmptyMock( "coldbox.system.web.Renderer" );
		mockColdbox.$("getRenderer",  mockrenderer);
		def = {name="renderer", dsl="coldbox:renderer"};
		c = builder.getColdBoxDSL(def);
		assertEquals( mockrenderer, c);

		mockMarshaller = createEmptyMock( "coldbox.system.core.conversion.DataMarshaller" );
		mockColdbox.$("getDataMarshaller",  mockMarshaller);
		def = {name="marshaller", dsl="coldbox:dataMarshaller"};
		c = builder.getColdBoxDSL(def);
		assertEquals( mockMarshaller, c);


	}

	function testgetColdboxDSLStage3(){
		makePublic(builder, "getColdboxDSL");

		// setting
		def = {name="mySetting", dsl="coldbox:setting"};
		mockColdBox.$("getSetting").$args("mySetting").$results("UnitTest");
		c = builder.getColdBoxDSL(def);
		assertEquals("unitTest", c);
		// setting@module
		def = {name="mySetting", dsl="coldbox:setting:mySetting@myModule"};
		modSettings = {
			myModule={
				settings={ mySetting="unitTest" }
			}
		};
		mockColdBox.$("getSetting").$args("modules").$results( modSettings );
		c = builder.getColdBoxDSL(def);
		assertEquals("unitTest", c);

		// modulesettings
		def = {name="mySetting", dsl="coldbox:moduleSettings:myModule"};
		modSettings = {
			myModule={
				moduleMapping = "/modules/MyModule",
				settings={ mySetting="unitTest" }
			}
		};
		mockColdBox.$("getSetting").$args("modules").$results( modSettings );
		c = builder.getColdBoxDSL(def);
		assertEquals( modSettings.myModule.settings , c);

		// moduleConfig
		def = {name="mySetting", dsl="coldbox:moduleConfig:myModule"};
		modSettings = {
			myModule={
				moduleMapping = "/modules/MyModule",
				settings={ mySetting="unitTest" }
			}
		};
		mockColdBox.$("getSetting").$args("modules").$results( modSettings );
		c = builder.getColdBoxDSL(def);
		assertEquals( modSettings.myModule , c);

		// rc
		var rc = { event = "main.index", format = "html" };
		var mockEvent = getMockBox().createEmptyMock("coldbox.system.web.context.RequestContext");
		mockEvent.$( "getCollection", rc );
		mockColdbox.$( "getRequestService", getMockBox().createStub().$( "getContext", mockEvent ) );
		def = {name="rc", dsl="coldbox:requestContext:rc"};
		c = builder.getColdBoxDSL(def);
		assertEquals( rc , c);

		// prc
		var prc = { cbox_incomingContextHash = "E421429442BAC5178C6BE0CB3C9796E1" };
		var mockEvent = getMockBox().createEmptyMock("coldbox.system.web.context.RequestContext");
		mockEvent.$( "getPrivateCollection", prc );
		mockColdbox.$( "getRequestService", getMockBox().createStub().$( "getContext", mockEvent ) );
		def = { name = "prc", dsl = "coldbox:requestContext:prc" };
		c = builder.getColdBoxDSL( def );
		assertEquals( prc , c );

		// fwsetting
		def = {name="mySetting", dsl="coldbox:fwSetting"};
		mockColdBox.$("getSetting").$args("mySetting",true).$results("UnitTest");
		c = builder.getColdBoxDSL(def);
		assertEquals("unitTest", c);

		// interceptor
		def = {name="ds", dsl="coldbox:interceptor:coolAlias"};
		mockIS = getMockBox().createStub().$("getInterceptor").$args("coolAlias",true).$results( this );
		mockColdbox.$("getInterceptorService", mockIS);
		c = builder.getColdBoxDSL(def);
		assertEquals(this, c);
	}

</cfscript>
</cfcomponent>