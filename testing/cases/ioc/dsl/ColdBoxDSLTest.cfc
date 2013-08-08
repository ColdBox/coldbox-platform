<cfcomponent extends="coldbox.system.testing.BaseTestCase">
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
		builder.$("getIOCDSL",true)
			.$("getOCMDSL",true)
			.$("getWebserviceDSL",true)
			.$("getJavaLoaderDSL",true)
			.$("getEntityServiceDSL",true)
			.$("getColdboxDSL",true);
		
		// Test dsl namespaces
		def = {dsl="ioc"};
		builder.process(def);
		assertTrue( builder.$once("getIOCDSL") );
		
		def = {dsl="ocm"};
		builder.process(def);
		assertTrue( builder.$once("getOCMDSL") );
		
		def = {dsl="webservice"};
		builder.process(def);
		assertTrue( builder.$once("getWebserviceDSL") );
		
		def = {dsl="javaloader"};
		builder.process(def);
		assertTrue( builder.$once("getJavaLoaderDSL") );
		
		def = {dsl="coldbox"};
		builder.process(def);
		assertTrue( builder.$once("getColdboxDSL") );
	}
	
	function testGetDatasource(){
		data = {test={name='test',dbtype='mysql'}};
		mockColdBox.$("getSetting", data);
		makePublic(builder,"getDatasource");
		
		d = builder.getDatasource('test');
		assertEquals( "test", d.getName() );
		assertEquals( "mysql", d.getDBType() );
	}
	
	function testGetWebserviceDSL(){
		// name from property
		def = {name="propTest", dsl="webservice"};
		
		mockPlugin = getMockBox().createEmptyMock("coldbox.system.plugins.WebServices")
			.$("getWSObj", getMockBox().createStub() );
		mockColdBox.$("getPlugin", mockPlugin );
		makePublic(builder,"getWebserviceDSL");
		
		d = builder.getWebserviceDSL(def);
		assertTrue( mockPlugin.$once("getWSobj") );
		assertEquals("propTest", mockPlugin.$callLog().getWSObj[1][1] );
		
		// full dsl
		def = {name="propTest", dsl="webservice:myWeb"};
		d = builder.getWebserviceDSL(def);
		assertTrue( mockPlugin.$times(2,"getWSobj") );
		assertEquals("myWeb", mockPlugin.$callLog().getWSObj[2][1] );
	}
	
	function testGetJavaLoaderDSL(){
		mockJavaLoader = getMockBox().createEmptyMock("coldbox.system.plugins.JavaLoader")
			.$("create", true);
		mockColdBox.$("getPlugin", mockJavaLoader );
		makePublic(builder, "getJavaLoaderDSL");
		def = {dsl="javaloader:java.lang.StringBuffer"};
		builder.getJavaLoaderDSL(def);
		assertTrue( mockJavaLoader.$once("create") );
		assertEquals( "java.lang.StringBuffer", mockJavaLoader.$callLog().create[1][1] );	
	}
		
	function testgetIOCDSl(){
		mockFactory = getMockBox().createStub();
		mockIOC = getMockBox().createEmptyMock("coldbox.system.plugins.IOC")
			.$("getIOCFactory", mockFactory);
		mockColdBox.$("getPlugin", mockIOC );
		makePublic(builder, "getIOCDSL");
		
		// ioc only
		mockFactory.$("containsBean",true);
		mockIOC.$("getBean", this);
		def = {name="testBean",dsl="ioc"};
		t = builder.getIOCDSL(def);
		assertEquals(this, t);
		
		// ioc only not found
		mockFactory.$("containsBean",false);
		def = {name="testBean",dsl="ioc"};
		t = builder.getIOCDSL(def);
		assertTrue( mockIOC.$once("getBean") );
		assertTrue( mockLogger.$once("canDebug") );
		
		// ioc:bean
		mockFactory.$("containsBean",true);
		mockIOC.$("getBean", this);
		def = {name="testBean",dsl="ioc:coolBean"};
		t = builder.getIOCDSL(def);
		assertEquals(this, t);
		assertEquals( "coolBean", mockIOC.$callLog().getBean[1][1]);
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
		mockColdbox.$("getColdboxSettings", {});
		def = {name="configBean", dsl="coldbox:fwConfigBean"};
		c = builder.getColdBoxDSL(def);
		assertTrue( isInstanceOf(c, "coldbox.system.core.collections.ConfigBean") );
		
		mockColdbox.$("getConfigSettings", {});
		def = {name="configBean", dsl="coldbox:configBean"};
		c = builder.getColdBoxDSL(def);
		assertTrue( isInstanceOf(c, "coldbox.system.core.collections.ConfigBean") );
		
		mockColdbox.$("getSetting","MailStuff");
		def = {name="configBean", dsl="coldbox:mailSettingsBean"};
		c = builder.getColdBoxDSL(def);
		assertTrue( isInstanceOf(c, "coldbox.system.core.mail.MailSettingsBean") );
		
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
		
		mockColdbox.$("getDebuggerService",this);
		def = {name="configBean", dsl="coldbox:debuggerService"};
		c = builder.getColdBoxDSL(def);
		assertEquals( this, c);
		
		mockColdbox.$("getPluginService",this);
		def = {name="configBean", dsl="coldbox:pluginService"};
		c = builder.getColdBoxDSL(def);
		assertEquals( this, c);
		
		mockColdbox.$("getHandlerService",this);
		def = {name="configBean", dsl="coldbox:handlerService"};
		c = builder.getColdBoxDSL(def);
		assertEquals( this, c);
		
		mockColdbox.$("getInterceptorService",this);
		def = {name="configBean", dsl="coldbox:interceptorService"};
		c = builder.getColdBoxDSL(def);
		assertEquals( this, c);
		
		mockColdbox.$("getColdBoxOCM",this);
		def = {name="configBean", dsl="coldbox:cacheManager"};
		c = builder.getColdBoxDSL(def);
		assertEquals( this, c);
		
		mockColdbox.$("getModuleService",this);
		def = {name="configBean", dsl="coldbox:moduleService"};
		c = builder.getColdBoxDSL(def);
		assertEquals( this, c);
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
		
		// plugin
		def = {name="myPlugin", dsl="coldbox:plugin"};
		mockColdBox.$("getPlugin").$args("myPlugin").$results(this);
		c = builder.getColdBoxDSL(def);
		assertEquals(this, c);
		
		// myplugin
		def = {name="myPlugin", dsl="coldbox:myplugin"};
		mockColdBox.$("getPlugin").$args(plugin="myPlugin",customPlugin=true).$results(this);
		c = builder.getColdBoxDSL(def);
		assertEquals(this, c);
		
		// myplugin@module
		def = {name="myPlugin", dsl="coldbox:myplugin:myPlugin@testModule"};
		mockColdBox.$("getPlugin").$args(plugin="myPlugin",customPlugin=true,module="testModule").$results(this);
		c = builder.getColdBoxDSL(def);
		assertEquals(this, c);
		
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