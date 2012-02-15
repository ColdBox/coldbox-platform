<cfcomponent extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.web.services.InterceptorService">
	<cfscript>

	function setup(){
		super.setup();
		// Create Mock Objects
		mockbox = getMockBox();
		mockController 	 	= mockBox.createEmptyMock("coldbox.system.testing.mock.web.MockController");
		mockDebugger		= mockBox.createEmptyMock("coldbox.system.web.services.DebuggerService").$("timerStart",0).$("timerEnd");
		mockRequestContext 	= getMockRequestContext();
		mockRequestService 	= mockBox.createEmptyMock("coldbox.system.web.services.RequestService").$("getContext", mockRequestContext);
		mockLogBox	 	 	= mockBox.createEmptyMock("coldbox.system.logging.LogBox");
		mockLogger	 	 	= mockBox.createEmptyMock("coldbox.system.logging.Logger");
		mockFlash		 	= mockBox.createMock("coldbox.system.web.flash.MockFlash").init(mockController);
		mockCacheBox   	 	= mockBox.createEmptyMock("coldbox.system.cache.CacheFactory");
		mockCache   	 	= mockBox.createEmptyMock("coldbox.system.cache.providers.CacheBoxColdBoxProvider");
		mockWireBox		 	= mockBox.createEmptyMock("coldbox.system.ioc.Injector");
		
		// Mock Plugin Dependencies
		mockController.$("getLogBox",mockLogBox)
			.$("getCacheBox",mockCacheBox)
			.$("getWireBox",mockWireBox)
			.$("getRequestService",mockRequestService)
			.$("getDebuggerService", mockDebugger);
		mockRequestService.$("getFlashScope",mockFlash);
		mockLogBox.$("getLogger",mockLogger);
		
		iService = model.init(mockController).$("getColdboxOCM", mockCache);
		
	}
	
	function testonConfigurationLoad(){
			mockController.$("getSetting").$args("InterceptorConfig").$results( {} )
				.$("getSetting").$args("coldboxConfig").$results( mockBox.createStub() );
			iService.$("registerInterceptor").$("registerInterceptors");
			iService.onConfigurationLoad();
			
			assertTrue( iService.$once("registerInterceptor") );
			assertTrue( iService.$once("registerInterceptors") );
	}
	
	function testregisterInterceptors(){
		var states = "";
		mockConfig = {
			customInterceptionPoints = ["myCustom"],
			interceptors = [
				{class="coldbox.system.interceptors.SES", properties = {}, name="MySES"},
				{class="coldbox.system.interceptors.Custom", properties = {n=1}, name="Custom"}
			]
		};
		iService.$property("interceptorConfig","instance", mockConfig)
			.$("registerInterceptor");
		mockLogger.$("canDebug",false);
		iService.registerInterceptors();
		
		assertTrue( iService.$count(2,"registerInterceptor") );
	}
	
	function testgetrequestBuffer(){
			AssertTrue( isObject(iService.getRequestBuffer()));
	}
	
	function testInterceptionPoints(){
		//test registration again
		AssertTrue( arrayLen(iService.getInterceptionPoints()) gt 0 );
	}
	
	function testgetStateContainer(){
		
		state = iService.getStateContainer('nothing');
		
		AssertFalse( isObject(state) );
		
		mockState = getMockBox().createStub().$("process");
		iService.$property("preProcess","instance.interceptionStates",mockState);
		state = iService.getStateContainer('preProcess');
		
		AssertTrue( isObject(state) );
				
	}
	
	function testUnregister(){
		
		// mocks
		mockCache.INTERCEPTOR_CACHEKEY_PREFIX = "sample";
		mockState = mockBox.createStub().$("unregister");
		iService.$property("preProcess","instance.interceptionStates",mockState);
		mockState2 = mockBox.createStub().$("unregister");
		iService.$property("preProcess2","instance.interceptionStates",mockState2);
		
		// 1: From All States
		iService.unregister("Luis");
		assertTrue( mockState.$once("unregister") );
		assertTrue( mockState2.$once("unregister") );
		
		// 2: From Specific State
		iService.unregister("Luis","preProcess2");
		assertTrue( mockState.$once("unregister") );
		assertTrue( mockState2.$count(2,"unregister") );
	}
	
	function testAppendInterceptionPoints(){
		var aLen  	= arrayLen( iService.getInterceptionPoints() );
		
		// test 1: nothing
		iService.appendInterceptionPoints('');
		assertEquals( aLen, arrayLen( iService.getInterceptionPoints() ) );
		
		// test 2: add points
		aLen = arrayLen( iService.getInterceptionPoints() );
		iService.appendInterceptionPoints('onTest,onLuis');
		assertEquals( aLen + 2 , arrayLen( iService.getInterceptionPoints() ) );
		
		// test 3: add points with duplicates
		aLen = arrayLen( iService.getInterceptionPoints() );
		iService.appendInterceptionPoints( [ "on1","on2","on1" ] );
		assertEquals( (aLen + 2) , arrayLen( iService.getInterceptionPoints() ) );
	}
	
	function testSimpleProcessInterception(){
		// 1: not inited
		mockController.$("getColdboxInitiated",false);
		iService.processState("preProcess");
		
		// 2: inited with throw enabled but not throw
		mockController.$("getColdboxInitiated",true);
		iService.$property("throwOnInvalidStates","instance.interceptorConfig",true);
		iService.processState("preProcess");
		
		// 3: inited with throw enabled but with throw
		mockController.$("getColdboxInitiated",true);
		iService.$property("throwOnInvalidStates","instance.interceptorConfig",true);
		try{		
			iService.processState("junk");
		}
		catch("InterceptorService.InvalidInterceptionState" e){}
		catch(any e){ fail(e); }
		
		// 4: process a mock state
		mockController.$("getColdboxInitiated",true);
		iService.$property("throwOnInvalidStates","instance.interceptorConfig",false);
		mockState = getMockBox().createStub().$("process");
		iService.$property("preProcess","instance.interceptionStates",mockState);
		debug( iService.getInterceptionStates() );
		iService.processState("badState");
		assertTrue( mockState.$never("process") );
		
		// 5: real mock state
		mockController.$("getColdboxInitiated",true);
		iService.$property("throwOnInvalidStates","instance.interceptorConfig",false);
		mockState = getMockBox().createStub().$("process");
		iService.$property("preProcess","instance.interceptionStates",mockState);
		debug( iService.getInterceptionStates() );
		iService.processState("preProcess");
		assertTrue( mockState.$once("process") );
		
	}
	
	function testProcessInterceptionWithBuffer(){
		var md = structnew();
		
		md.test = "UNIT TESTING";
		md.today = now();
		
		// mocks
		mockController.$("getColdboxInitiated",true);
		iService.$property("throwOnInvalidStates","instance.interceptorConfig",false);
		mockState = getMockBox().createStub().$("process");
		iService.$property("preProcess","instance.interceptionStates",mockState);
		mockBox.prepareMock( iService.getRequestBuffer() ).$("clear");
		
		
		// Append To Buffer
		iService.getRequestBuffer().append('luis');
		iService.processState("preProcess",md);
		assertTrue( iService.getRequestBuffer().$once("clear") );
		
	}
	
	function testManualRegistration(){
			// mocks
			mockCache.INTERCEPTOR_CACHEKEY_PREFIX = "sample";
			mockCache.$("set",true);
			mockLogger.$("canDebug",false);
			mockController.$("getAspectsInitiated", false);
			
			iService.appendInterceptionPoints('unitTest');
			iService.registerInterceptor(interceptorClass='coldbox.testing.testinterceptors.mock');
			
			assertTrue( mockCache.$once("set") );
			AssertTrue( isObject(iService.getStateContainer('unittest')) );
	}
	
	function testManualObjectRegistration(){
			// mocks
			var obj = CreateObject("component","coldbox.testing.testinterceptors.mock");
			mockCache.INTERCEPTOR_CACHEKEY_PREFIX = "sample";
			mockLogger.$("canDebug",false);
			mockController.$("getAspectsInitiated",false);
			
			iService.appendInterceptionPoints('unitTest');
			iService.registerInterceptor(interceptorObject=obj);
			
			AssertTrue( isObject(iService.getStateContainer('unittest')) );
	}
	
	function testManualObjectRegistration2(){
			// mocks
			var obj = CreateObject("component","coldbox.testing.testinterceptors.mock");
			mockCache.INTERCEPTOR_CACHEKEY_PREFIX = "sample";
			mockLogger.$("canDebug",false);
			mockController.$("getAspectsInitiated",false);
			
			iService.registerInterceptor(interceptorObject=obj,customPoints='unitTest');
			
			AssertTrue( isObject(iService.getStateContainer('unittest')) );
			
	}	
</cfscript>
</cfcomponent>