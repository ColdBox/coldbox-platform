<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	
	function setup(){
		//mocks
		mockLogger   = getMockBox().createEmptyMock("coldbox.system.logging.Logger").$("canDebug",true).$("debug");
		mockLogBox   = getMockBox().createEmptyMock("coldbox.system.logging.LogBox")
			.$("getLogger", mockLogger);
		mockBinder   = getMockBox().createMock("coldbox.system.ioc.config.Binder");
		mockInjector = getMockBox().createEmptyMock("coldbox.system.ioc.Injector")
			.$("getLogBox", mockLogBox)
			.$("getBinder", mockBinder);
		
		// mixer
		mixer = getMockBox().createMock("coldbox.system.aop.Mixer").configure(mockInjector,{});
	}
	
	function testafterInstanceAutowire(){
		// mocks
		mockMapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init('unitTest')
			.$("getName","unitTest");
		// intercept data
		data = {
			mapping = mockMapping,
			target = this
		};
		mixer.$("buildAspectDictionary");
		
		// 1: target already mixed
		this.$wbAOPMixed = true;
		mixer.afterInstanceAutowire(data);
		assertTrue( mixer.$never("buildAspectDictionary") );
		
		// 2: target NOT mixed and we need dictionary and nothing matched
		structDelete(this, "$wbAOPMixed");
		dictionary = { "unittest" = [] };
		mixer.$("AOPBuilder").$("buildClassMatchDictionary").$property("classMatchDictionary","instance",dictionary);
		mixer.afterInstanceAutowire(data);
		assertTrue( mixer.$never("AOPBuilder") );
		
		// 3: target NOT mixed and we need dictionary and it matches with methods
		dictionary = { "unitTest" = [{classes="",methods="",aspects="1,2"}] };
		mixer.$("AOPBuilder").$("buildClassMatchDictionary").$property("classMatchDictionary","instance",dictionary);
		mixer.afterInstanceAutowire(data);
		assertTrue( mixer.$once("AOPBuilder") );
		assertTrue( mixer.$never("buildClassMatchDictionary") );
	}
	
	function testdecorateAOPTarget(){
		makePublic(mixer,"decorateAOPTarget");
		mockLogger.$("canDebug",false);
		mockMapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping")
			.$("getName","unitTest");
		mixer.decorateAOPTarget(this, mockMapping);
		
		assertTrue( structKeyExists(this,"$wbAOPTargets") );
		assertTrue( structKeyExists(this,"$wbAOPInclude") );
		assertTrue( structKeyExists(this,"$wbAOPStoreJointPoint") );
		assertTrue( structKeyExists(this,"$wbAOPInvokeProxy") );
		assertTrue( structKeyExists(this,"$wbAOPRemove") );
		
	}
	
	function testBuildInterceptors(){
		makePublic(mixer, "buildInterceptors");
		//mocks
		mockInjector.$("getInstance").$results( getMockBox().createStub(), getMockBox().createStub() );
		
		objs = mixer.buildInterceptors(["aspect1","aspect2"]);
		
		assertEquals( 2, arrayLen( objs ));
		
	}
	
	function testAOPBuilder(){
		makePublic(mixer, "AOPBuilder");		
		
	}
	
	function testBuildClassMatchDictionary(){
		aspects = [
			{classes=getMockBox().createMock("coldbox.system.aop.Matcher").init().$("matchClass",true), 
			 methods=getMockBox().createMock("coldbox.system.aop.Matcher").init(),
			 aspects="Transaction"}
		];
		mockBinder.$("getAspectBindings", aspects);
		mockMapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping")
			.$("getName","unitTest");
		
		makePublic(mixer, "buildClassMatchDictionary");
		mixer.buildClassMatchDictionary(this, mockMapping, '123');
		r = mixer.getclassMatchDictionary();
		assertTrue( arrayLen(r["unittest"]) );
	}
	
	
	function testprocessTargetMethods(){
		mockMapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping")
			.$("getName","unitTest");
		md = {
			functions = [
				{name="testMethod"}
			]
		};
		dictionary = [
			{classes="", methods=getMockBox().createEmptyMock("coldbox.system.aop.Matcher").$("matchMethod",true), aspects=["Transaction"]}
		];
		
		makePublic(mixer,"processTargetMethods");
		
		// proxied already
		this.$wbAOPTargets = { "testMethod" = true };
		mixer.$("weaveAdvice");
		mixer.processTargetMethods(this, mockMapping, md, dictionary);
		assertTrue( mixer.$never("weaveAdvice") );
		
		// proxy methods
		this.$wbAOPTargets = {};
		mixer.$("weaveAdvice");
		mixer.processTargetMethods(this, mockMapping, md, dictionary);
		assertTrue( mixer.$once("weaveAdvice") );
		//debug( mixer.$callLog().weaveAdvice[1] );
		
		assertEquals( mixer.$callLog().weaveAdvice[1].target, this);
		assertEquals( mixer.$callLog().weaveAdvice[1].jointpoint, "testMethod");
		assertEquals( mixer.$callLog().weaveAdvice[1].aspects, ["Transaction"]);
		
		// proxy methods
		this.$wbAOPTargets = {};
		dictionary = [
			{classes="", methods=getMockBox().createEmptyMock("coldbox.system.aop.Matcher").$("matchMethod",false), aspects="Transaction"}
		];
		mixer.$("weaveAdvice");
		mixer.processTargetMethods(this, mockMapping, md, dictionary);
		assertTrue( mixer.$never("weaveAdvice") );
		//debug( mixer.$callLog().weaveAdvice[1] );
		
	}
	
</cfscript>
</cfcomponent>