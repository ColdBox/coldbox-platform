﻿<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		dataConfigPath = "coldbox.testing.cases.ioc.config.samples.SampleWireBox";
		// Available WireBox public scopes
		this.SCOPES = createObject("component","coldbox.system.ioc.Scopes");
		// Available WireBox public types
		this.TYPES = createObject("component","coldbox.system.ioc.Types");
		mockInjector = getMockBox().createEmptyMock("coldbox.system.ioc.Injector")
			.$("getColdBox", getMockBox().createStub().$("getSetting","coldbox.testing") );
		config = createObject("component","coldbox.system.ioc.config.Binder").init(injector=mockInjector,config=dataConfigPath);
	}

	function testBinderStandalone(){
		config = createObject("component","coldbox.system.ioc.config.Binder").init(mockInjector);
		memento = config.getMemento();
		debug(memento);
	}

	function testBinderWithConfigInstance(){
		// My Data Object
		dataConfig = createObject("component",dataConfigPath);
		config = createObject("component","coldbox.system.ioc.config.Binder").init(injector=mockInjector,config=dataConfig);

		memento = config.getMemento();
		debug(memento);

		// assert Defaults
		assertTrue( arrayLen(memento.listeners) );
		assertEquals("coldbox.system.ioc.config.LogBox", memento.logBoxConfig);
		assertEquals(config.getDefaults().cacheBox, memento.cacheBox );
		assertEquals(config.getDefaults().scopeRegistration, config.getScopeRegistration() );
		assertEquals( "", config.getParentInjector() );
		assertEquals( 0, structCount(config.getCustomScopes()) );
		assertEquals( 0, structCount(config.getCustomDSL()) );
		assertEquals( 2, structCount(config.getMappings()) );
		assertEquals( 1, structCount(config.getScanLocations()) );
	}

	function testBinderWithConfigPath(){
		// My Data Object
		config = createObject("component","coldbox.system.ioc.config.Binder").init(injector=mockInjector,config=dataConfigPath);

		memento = config.getMemento();
		debug(memento);

		// assert Defaults
		assertTrue( arrayLen(memento.listeners) );
		assertEquals("coldbox.system.ioc.config.LogBox", memento.logBoxConfig);
		assertEquals(config.getDefaults().cacheBox, memento.cacheBox );
		assertEquals(config.getDefaults().scopeRegistration, config.getScopeRegistration() );
		assertEquals( "", config.getParentInjector() );
		assertEquals( 0, structCount(config.getCustomScopes()) );
		assertEquals( 0, structCount(config.getCustomDSL()) );
		assertEquals( 2, structCount(config.getMappings()) );
		assertEquals( 1, structCount(config.getScanLocations()) );
	}

	// BINDER PROPERTIES
	function testProperties(){
		prop = config.getProperties();
		assertTrue( structIsEmpty(prop) );
		assertEquals(false, config.propertyExists("bogus"));
		config.setProperty("woot","yeaa!");
		assertEquals("yeaa!", config.getProperty("woot"));
		assertEquals(false, config.getProperty("bogus",false));

	}

	function testParentInjector(){
		config.parentInjector( this );
		assertEquals( this, config.getParentInjector() );
	}

	// MAPPING Tests
	function testMappings(){
		mappings = config.getMappings();
		assertEquals(false, config.mappingExists("xx") );
		mappings["test"] = this;
		assertEquals( this, config.getMapping("test"));
	}

	function testMap(){
		config.map("MyService");
		mapping = config.getMapping("MyService");
		assertTrue( isObject(mapping) );
		assertEquals( "MyService", mapping.getName() );

		config.map("MyService,TestService");
		mapping1 = config.getMapping("TestService");
		mapping2 = config.getMapping("MyService");
		assertEquals(mapping1, mapping2);
		assertEquals(2, arrayLen(mapping1.getAlias()));

		config.map(["MyService","TestService"]);
		mapping1 = config.getMapping("TestService");
		mapping2 = config.getMapping("MyService");
		assertEquals(mapping1, mapping2);
		assertEquals(2, arrayLen(mapping1.getAlias()));
	}

	function testTo(){
		config.map("Test").to("model.TestService");
		mapping = config.getMapping("Test");
		assertEquals( this.TYPES.CFC, mapping.getType() );
		assertEquals( "model.TestService", mapping.getPath() );
	}

	function testParent(){

		//
		// create "dependency" beans to be injected
		//

		// alpha and bravo are in the abstract service
		config.map("someAlphaDAO").to("model.parent.SomeAlphaDAO");
		config.map("someBravoDAO").to("model.parent.SomeBravoDAO");

		// charlie and delta are in the concrete service only that also inherits from  abstract service
		config.map("someCharlieDAO").to("model.parent.SomeCharlieDAO");
		config.map("someDeltaDAO").to("model.parent.SomeDeltaDAO");

		// define abstract parent service with required dependencies (alpha and bravo)
		config.map("abstractService").to("model.parent.AbstractService")
			.property(name:"someAlphaDAO", ref:"someAlphaDAO")
			.property(name:"someBravoDAO", ref:"someBravoDAO");

		// define concrete service that inherits the abstract parent service dependencies via the parent method
		config.map("concreteService").to("model.parent.ConcreteService")
			.parent("abstractService")
			.property(name:"someCharlieDAO", ref:"someCharlieDAO")
			.property(name:"someDeltaDAO", ref:"someDeltaDAO");

		// test that both mappings still have their respective names and paths (processMemento excludes worked)
		assertEquals( "model.parent.AbstractService", config.getMapping("abstractService").getPath() );
		assertEquals( "model.parent.ConcreteService", config.getMapping("concreteService").getPath() );

		// test that concrete service now containstest that concrete service now containstest that concrete service now contains
		// all 4 properties (alpha, bravo, charlie and delta) exists
		concreteProperties = config.getMapping("concreteService").getDIProperties();
		foundProperties = [];
		for(i = 1; i <= arrayLen(concreteProperties); i++){
			arrayAppend(foundProperties, concreteProperties[i].name);
		}
		assertEquals(4, arrayLen(concreteProperties) );
		assertNotEquals(0, arrayFindNoCase(foundProperties, "someAlphaDAO") );
		assertNotEquals(0, arrayFindNoCase(foundProperties, "someBravoDAO") );
		assertNotEquals(0, arrayFindNoCase(foundProperties, "someCharlieDAO") );
		assertNotEquals(0, arrayFindNoCase(foundProperties, "someDeltaDAO") );
	}

	function testMapPath(){
		config.mapPath("model.TestService");
		mapping = config.getMapping("TestService");
		assertEquals( "TestService", mapping.getName() );
		assertEquals( this.TYPES.CFC, mapping.getType() );
		assertEquals( "model.TestService", mapping.getPath() );
	}

	function testToJava(){
		config.map("Test").toJava("java.lang.StringBuffer");
		mapping = config.getMapping("Test");
		assertEquals( this.TYPES.java, mapping.getType() );
		assertEquals( "java.lang.StringBuffer", mapping.getPath() );
	}

	function testToWebservice(){
		config.map("Test").toWebservice("http://coldbox.jfetmac/distribution/test.cfc?wsdl");
		mapping = config.getMapping("Test");
		assertEquals( this.TYPES.WEBSERVICE, mapping.getType() );
		assertEquals( "http://coldbox.jfetmac/distribution/test.cfc?wsdl", mapping.getPath() );
	}

	function testToRSS(){
		config.map("Test").toRSS("http://www.coldbox.org/rss");
		mapping = config.getMapping("Test");
		assertEquals( this.TYPES.RSS, mapping.getType() );
		assertEquals( "http://www.coldbox.org/rss", mapping.getPath() );
	}

	function testToValue(){
		config.map("Const").toValue("const");
		mapping = config.getMapping("Const");
		assertEquals( this.TYPES.CONSTANT, mapping.getType() );
		assertEquals( "const", mapping.getValue() );
	}

	function testToDSL(){
		config.map("Test").toDSL("provider:user");
		mapping = config.getMapping("Test");
		assertEquals( this.TYPES.DSL, mapping.getType() );
		assertEquals( "provider:user", mapping.getDSL() );
	}

	function testSetConstructor(){
		config.mapPath("Test").constructor("init2");
		mapping = config.getMapping("Test");
		assertEquals( "init2", mapping.getConstructor() );

		config.mapPath("Test");
		mapping = config.getMapping("Test");
		assertEquals( "init", mapping.getConstructor() );
	}

	function testInitWith(){
		config.mapPath("Test").initWith("luis","hola");
		mapping = config.getMapping("Test");
		args = mapping.getDIConstructorArguments();
		assertEquals(2, arrayLen(args));
	}

	function testNoInit(){
		config.mapPath("Test");
		mapping = config.getMapping("Test");
		assertEquals( true, mapping.isAutoInit() );

		config.mapPath("Test").noInit();
		mapping = config.getMapping("Test");
		assertEquals( false, mapping.isAutoInit() );
	}

	function testEagerInit(){
		config.mapPath("Test");
		mapping = config.getMapping("Test");
		assertEquals( '', mapping.isEagerInit() );

		config.mapPath("Test").asEagerInit();
		mapping = config.getMapping("Test");
		assertEquals( true, mapping.isEagerInit() );
	}

	function testNoAutowire(){
		config.mapPath("Test");
		mapping = config.getMapping("Test");
		assertEquals( '', mapping.isAutowire() );

		config.mapPath("Test").noAutowire();
		mapping = config.getMapping("Test");
		assertEquals( false, mapping.isAutowire() );
	}

	function testWith(){
		try{
			config.with("Bogus");
		}
		catch("Binder.InvalidMappingStateException" e){}
		catch(Any e){ fail(e); }

		config.mapPath("Test");
		mapping = config.getMapping("Test");
		config.with("Test");
		assertEquals( mapping, config.getCurrentMapping() );
	}

	function testInitArg(){
		config.mapPath("Test")
			.initArg(name="binding",value="2")
			.initArg(name="obj2",ref="obj2")
			.initArg(name="obj3", dsl="provider:obj3");
		mapping = config.getMapping("Test");
		args = mapping.getDIConstructorArguments();
		assertEquals( 3, arrayLen(args));
	}

	function testSetter(){
		config.mapPath("Test")
			.setter(name="binding",value="2")
			.setter(name="obj2",ref="obj2")
			.setter(name="obj3", dsl="provider:obj3");
		mapping = config.getMapping("Test");
		setters = mapping.getDISetters();
		assertEquals( 3, arrayLen(setters));
	}

	function testProperty(){
		config.mapPath("Test")
			.property(name="binding",value="2")
			.property(name="obj2",ref="obj2")
			.property(name="obj3", dsl="provider:obj3",scope="instance");
		mapping = config.getMapping("Test");
		properties = mapping.getDIProperties();
		assertEquals( 3, arrayLen(properties));
	}

	function testOnDIComplete(){
		config.mapPath("Test")
			.onDIComplete("fnc1,fnc2");
		mapping = config.getMapping("Test");
		completeMethods = mapping.getOnDIComplete();
		assertEquals( 2, arrayLen(completeMethods));

		config.mapPath("Test")
			.onDIComplete(["fnc1","fnc2","fnc3"]);
		mapping = config.getMapping("Test");
		completeMethods = mapping.getOnDIComplete();
		assertEquals( 3, arrayLen(completeMethods));
	}

	function testStopRecursions(){
		config.stopRecursions(["coldbox.system.Interceptor","coldbox.system.EventHandler"]);
		rec = config.getStopRecursions();
		assertEquals( 2, arrayLen(rec));
		assertEquals( "coldbox.system.Interceptor", rec[1]);
	}

	function testScopeRegistration(){
		config.scopeRegistration(true,"server","woot");
		reg = config.getScopeRegistration();
		assertEquals( true, reg.enabled);
		assertEquals( "server", reg.scope);
		assertEquals( "woot", reg.key);
	}

	function testScanLocations(){
		// array
		locs = ["coldbox","mxunit","coldbox.system.plugins"];
		config.scanLocations(locs);

		assertEquals(4, structCount(config.getScanLocations() ) );
		locations = config.getScanLocations();
		assertEquals( expandPath("/coldbox/")  , locations["coldbox"]);
		assertEquals( expandPath("/mxunit/")  , locations["mxunit"]);
		assertEquals( expandPath("/coldbox/system/plugins/")  , locations["coldbox.system.plugins"]);

		// Try with a list now
		config.reset();
		locs = "coldbox,mxunit,coldbox.system.plugins";
		config.scanLocations(locs);
		assertEquals(3, structCount(config.getScanLocations() ) );
		locations = config.getScanLocations();
		assertEquals( expandPath("/coldbox/")  , locations["coldbox"]);
		assertEquals( expandPath("/mxunit/")  , locations["mxunit"]);
		assertEquals( expandPath("/coldbox/system/plugins/")  , locations["coldbox.system.plugins"]);

	}

	function testRemoveScanLocations(){
		// array
		locs = ["coldbox","mxunit","coldbox.system.plugins"];
		config.scanLocations(locs);

		assertEquals(4, structCount(config.getScanLocations() ) );
		config.removeScanLocations("mxunit");
		assertEquals(3, structCount(config.getScanLocations() ) );
		assertFalse( structKeyExists( config.getScanLocations(), "mxunit") );
	}

	function testCacheBoxIntegration(){
		// activate cachebox
		config.cacheBox(configFile="my.path.CacheBox");
		cbconfig = config.getCacheBoxConfig();
		assertEquals( true, cbconfig.enabled);
		assertEquals( "my.path.CacheBox", cbconfig.configFile);
		assertEquals( "coldbox.system.cache", cbconfig.classNamespace);
		debug(cbconfig);

		// test mapping into cachebox
		config.mapPath("Test").inCacheBox(timeout=30);
		mapping = config.getMapping("Test");
		cp = mapping.getCacheProperties();
		assertEquals("wirebox-Test", cp.key );
		assertEquals(30, cp.timeout );
		assertEquals('default', cp.provider );

		config.mapPath("Test").inCacheBox(key="TestIt",timeout=30,provider='myCache');
		mapping = config.getMapping("Test");
		cp = mapping.getCacheProperties();
		assertEquals("TestIt", cp.key );
		assertEquals(30, cp.timeout );
		assertEquals('myCache', cp.provider );
	}

	function testDSLs(){
		dsls = config.getCustomDSL();
		debug(dsls);
		assertEquals( true, structIsEmpty(dsls));
		config.mapDSL("FunkyScope","my.scope.FunkyTown");
		assertEquals( false, structIsEmpty(dsls));
		debug(dsls);
	}

	function testScopes(){
		scopes = config.getCustomScopes();
		assertEquals( true, structIsEmpty(scopes));
		config.mapScope("FunkyScope","my.scope.FunkyTown");
		assertEquals( false, structIsEmpty(scopes));
		debug(scopes);
	}

	function testLogBoxConfig(){
		lc = config.getLogBoxConfig();
		debug(lc);
		assertEquals("coldbox.system.ioc.config.LogBox", lc);
		config.logBoxConfig("mypath.logbox.Config");
		assertEquals("mypath.logbox.Config",config.getLogBoxConfig());
	}

	function testListenerMethods(){
		debug( config.getListeners() );
		assertEquals(1, arrayLen(config.getListeners()));

		config.listener("model.listener",{},"configListner");
		assertEquals(2, arrayLen(config.getListeners()));
		listeners = config.getListeners();
		assertEquals( "configListner", listeners[2].name);

		config.listener("model.FunkyTown");
		assertEquals(3, arrayLen(config.getListeners()));
		listeners = config.getListeners();
		assertEquals( "FunkyTown", listeners[3].name);

	}

	function testLoadDataDSL(){
		raw = {
			logBoxConfig = "test.logbox",
			scopeRegistration = {
				enabled = true, scope = "application"
			},
			cacheBox = {enabled=true},
			customDSL = {
				myNamespace = "my.namespace"
			},
			customScopes = {
				AwesomeScope = "my.awesome.scope"
			},
			scanLocations = ["coldbox.system"],
			stopRecursions = ["coldbox.system.EventHandler"],
			listeners = [
				{class="my.listener",properties={}}
			],
			mappings = {
				obj1 = {path="my.model.path",eagerInit=true},
				groovyLib = {path="groovy.path.lib",dsl="groovy"}
			}
		};
		config.loadDataDSL( raw );
	}

	function testInto(){
		config.mapPath("Test").into(config.SCOPES.SINGLETON);
		mapping = config.getMapping("Test");
		assertEquals(config.scopes.singleton, mapping.getScope());

		config.mapPath("Test").into(config.SCOPES.REQUEST);
		mapping = config.getMapping("Test");
		assertEquals(config.scopes.REQUEST, mapping.getScope());
	}

	function testAsSingleton(){
		config.mapPath("Test").asSingleton();
		mapping = config.getMapping("Test");
		assertEquals(config.scopes.singleton, mapping.getScope());
	}

	function testMapDirectory(){
		config.mapDirectory("coldbox.testing.testModel");
		assertTrue( structCount(config.getMappings()) gte 18 );

		config.reset();

		config.mapDirectory(packagePath="coldbox.testing.testModel",include="ioc.*");
		assertTrue( structCount(config.getMappings) gte 10 );

		config.reset();

		config.mapDirectory(packagePath="coldbox.testing.testModel",exclude="ioc.*");
		//debug( config.getMappings() );
		assertTrue( structCount(config.getMappings()) lte 8 );

	}

	function testMapFactoryMethod(){
		config.mapPath("MyFactory").into(config.SCOPES.SINGLETON);
		config.map("MyFactoryBean").toFactoryMethod("MyFactory","getBean");
		mapping = config.getMapping("MyFactoryBean");
		assertEquals( "MyFactory", mapping.getPath() );
		assertEquals( "getBean", mapping.getMethod() );

		// with arguments
		config.map("MyFactoryBean").toFactoryMethod("MyFactory","getPlugin")
			.methodArg(name="plugin",value="Logger")
			.methodArg(name="myRef",ref="BeanRef")
			.methodArg(name="hello",dsl="provider:cookoo");
		mapping = config.getMapping("MyFactoryBean");

		assertEquals( "MyFactory", mapping.getPath() );
		assertEquals( "getPlugin", mapping.getMethod() );
		DIMethodArgs = mapping.getDIMethodArguments();
		assertTrue( 3, arrayLen(DIMethodArgs) );
		debug( DIMethodArgs );
	}

	function testToProvider(){
		config.map("MyProviderObject").toProvider("MyProvider");
		mapping = config.getMapping("MyProviderObject");
		assertEquals( "MyProvider", mapping.getPath() );
		assertEquals( "provider", mapping.getType() );
	}

	function testMapAspect(){
		config.mapAspect("Transaction").to("model.Transactional");
		mapping = config.getMapping("Transaction");
		assertEquals( true, mapping.isAspect() );
		assertEquals( "singleton", mapping.getScope() );
		assertEquals( true, mapping.isEagerInit() );
		assertEquals( "model.Transactional", mapping.getPath() );
		assertEquals( true, mapping.isAspectAutoBinding() );

		config.mapAspect("Transaction",false).to("model.Transactional");
		mapping = config.getMapping("Transaction");
		assertEquals( false, mapping.isAspectAutoBinding() );

	}

	function testBindAspect(){
		config.bindAspect(classes=config.match().any(),methods=config.match().any(),aspects="luis");
		b = config.getAspectBindings();

		assertTrue( arrayLen(b) );

	}

	function testMatch(){
		r = config.match();
		assertTrue( isObject(r) );
	}

	function testVirtualInheritance(){
		config.mapAspect("MyPlugin").to("plugin.path").virtualInheritance("coldbox.system.Plugin");
		mapping = config.getMapping("MyPlugin");
		b = mapping.getvirtualInheritance();

		assertEquals("coldbox.system.Plugin", b );

	}

	function testExtraAttributes(){
		var data = {plugin=true,path="hello.path"};
		config.mapAspect("MyPlugin").to("plugin.path").virtualInheritance("coldbox.system.Plugin").extraAttributes(data);
		mapping = config.getMapping("MyPlugin");
		b = mapping.getExtraAttributes();

		assertEquals( data, b);

	}

	function testMixins(){
		config.map("MyObject").to("path.obj").mixins("/includes/helpers/AppHelper.cfm");
		mapping = config.getMapping("MyObject");
		b = mapping.getMixins();

		assertEquals( ["/includes/helpers/AppHelper.cfm"], b);

		config.map("MyObject").to("path.obj").mixins("/includes/helpers/AppHelper.cfm,/includes/helpers/AppHelper2.cfm");
		mapping = config.getMapping("MyObject");
		b = mapping.getMixins();

		assertEquals( ["/includes/helpers/AppHelper.cfm","/includes/helpers/AppHelper2.cfm"], b);

		config.map("MyObject").to("path.obj").mixins( ["/includes/helpers/AppHelper.cfm","/includes/helpers/AppHelper2.cfm"] );
		mapping = config.getMapping("MyObject");
		b = mapping.getMixins();

		assertEquals( ["/includes/helpers/AppHelper.cfm","/includes/helpers/AppHelper2.cfm"], b);

	}
</cfscript>
</cfcomponent>