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
		builder.$("getOCMDSL",true)
			.$("getEntityServiceDSL",true)
			.$("getColdboxDSL",true);

		def = {dsl="ocm"};
		builder.process(def);
		assertTrue( builder.$once("getOCMDSL") );

		def = {dsl="coldbox"};
		builder.process(def);
		assertTrue( builder.$once("getColdboxDSL") );
	}

	function testGetDatasource(){
		data = {test={name='test',dbtype='mysql'}};
		mockColdBox.$("getSetting", data);
		makePublic(builder,"getDatasource");

		d = builder.getDatasource('test');
		assertEquals( "test", d.name );
		assertEquals( "mysql", d.dbtype );
	}

	function testGetOCMDSL(){
		mockCache = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider");
		mockCacheBox.$("getCache", mockCache);
		makePublic(builder, "getOCMDSL");

		//ocm only
		def = {name="key", dsl="ocm"};
		mockCache.$("get",this);
		e = builder.getOCMDSL(def);
		assertEquals( this, e);

		//ocm only
		mockCache.$("get", javaCast("null",""));
		results.e = builder.getOCMDSL(def);
		assertFalse( structKeyExists(results,"e")  );

		// ocm:MyKey
		def = {name="key", dsl="ocm:myKey"};
		mockCache.$("get",this);
		e = builder.getOCMDSL(def);
		assertEquals( this, e);
		assertEquals( "myKey", mockCache.$callLog().get[1][1] );
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

		mockColdbox.$("getrequestService",this);
		def = {name="configBean", dsl="coldbox:requestService"};
		c = builder.getColdBoxDSL(def);
		assertEquals( this, c);

		mockFlash = getMockBox().createEmptyMock("coldbox.system.web.flash.SessionFlash");
		mockColdbox.$("getrequestService", getMockBox().createStub().$("getFlashScope", mockFlash) );
		def = {name="flash", dsl="coldbox:flash"};
		c = builder.getColdBoxDSL(def);
		assertEquals( mockFlash, c);

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

		// fwsetting
		def = {name="mySetting", dsl="coldbox:fwSetting"};
		mockColdBox.$("getSetting").$args("mySetting",true).$results("UnitTest");
		c = builder.getColdBoxDSL(def);
		assertEquals("unitTest", c);

		// datasource
		def = {name="ds", dsl="coldbox:datasource:coolAlias"};
		builder.$("getDatasource").$args("coolAlias").$results( this );
		c = builder.getColdBoxDSL(def);
		assertEquals(this, c);

		// interceptor
		def = {name="ds", dsl="coldbox:interceptor:coolAlias"};
		mockIS = getMockBox().createStub().$("getInterceptor").$args("coolAlias",true).$results( this );
		mockColdbox.$("getInterceptorService", mockIS);
		c = builder.getColdBoxDSL(def);
		assertEquals(this, c);
	}

</cfscript>
</cfcomponent>