<cfcomponent extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.web.services.InterceptorService">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		super.setup();
		// Create Mock Objects
		mockbox = getMockBox();
		mockController 	 	= mockBox.createEmptyMock("coldbox.system.testing.mock.web.MockController");
		mockRequestContext 	= getMockRequestContext();
		mockRequestService 	= mockBox.createEmptyMock("coldbox.system.web.services.RequestService").$("getContext", mockRequestContext);
		mockLogBox	 	 	= mockBox.createEmptyMock("coldbox.system.logging.LogBox");
		mockLogger	 	 	= mockBox.createEmptyMock("coldbox.system.logging.Logger");
		mockFlash		 	= mockBox.createMock("coldbox.system.web.flash.MockFlash").init(mockController);
		mockCacheBox   	 	= mockBox.createEmptyMock("coldbox.system.cache.CacheFactory");
		mockWireBox		 	= mockBox.createEmptyMock("coldbox.system.ioc.Injector");
		
		// Mock Plugin Dependencies
		mockController.$("getLogBox",variables.mockLogBox)
			.$("getCacheBox",variables.mockCacheBox)
			.$("getWireBox",variables.mockWireBox)
			.$("getRequestService",variables.mockRequestService);
		mockRequestService.$("getFlashScope",variables.mockFlash);
		mockLogBox.$("getLogger",variables.mockLogger);
		
		iService = model.init(mockController);
		
		</cfscript>
	</cffunction>
	
	<cffunction name="testonConfigurationLoad" output="false">
		<cfscript>
			mockController.$("getSetting").$args("InterceptorConfig").$results( {} )
				.$("getSetting").$args("coldboxConfig").$results( mockBox.createStub() );
			iService.$("registerInterceptor").$("registerInterceptors");
			iService.onConfigurationLoad();
			
			assertTrue( iService.$once("registerInterceptor") );
			assertTrue( iService.$once("registerInterceptors") );
		</cfscript>
	</cffunction>
	
	
	<cffunction name="testgetrequestBuffer" output="false">
		<cfscript>
			AssertTrue( isObject(iService.getRequestBuffer()));
		</cfscript>
	</cffunction>
	
	<cffunction name="testInterceptionPoints" access="public" returntype="void" output="false">
		<cfscript>
		
		//test registration again
		AssertTrue( listLen(iService.getInterceptionPoints()) gt 0 );
		
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetStateContainer" access="public" returntype="void" output="false">
		<cfscript>
		
		state = iService.getStateContainer('nothing');
		
		AssertFalse( isObject(state) );
		
		state = iService.getStateContainer('preProcess');
		
		AssertTrue( isObject(state) );
				
		</cfscript>
	</cffunction>
	
	<cffunction name="testUnregister" access="public" returntype="void" output="false">
		<cfscript>
		
		state = iService.getStateContainer('preProcess');
		
		iService.unregister('coldbox.system.interceptors.SES','preProcess');
		
		interceptor = state.getInterceptor('SES');
		
		AssertFalse( isObject(interceptor) );	
		
		</cfscript>
	</cffunction>
	
	
	<cffunction name="testregisterInterceptors" access="public" returntype="void" output="false">
		<cfscript>
		var states = "";
		
		//test registration again
		makePublic(iService,"createInterceptionStates","_createInterceptionStates");
		iService._createInterceptionStates();
		AssertTrue( structIsEmpty(iService.getInterceptionStates()));
		
		/* Register */
		iService.registerInterceptors();
		states = iService.getinterceptionStates();
		
		AssertFalse( structIsEmpty(states) );
		</cfscript>
	</cffunction>
	
	<cffunction name="testAppendInterceptionPoints" access="public" returntype="void" output="false">
		<cfscript>
		var points = iService.getINterceptionPoints();
		
		iService.appendInterceptionPoints('unitTest');
		
		AssertTrue( listLen(iService.getINterceptionPoints()), listLen(points)+1);
		
		iService.appendInterceptionPoints('unitTest');
		AssertTrue( listLen(iService.getINterceptionPoints()), listLen(points)+1);
		
		</cfscript>
	</cffunction>
	
	<cffunction name="testSimpleProcessInterception" access="public" returntype="void" output="false">
		<cfscript>
		
		iService.processState("preProcess");
		
		</cfscript>
	</cffunction>
	
	<cffunction name="testProcessInterception" access="public" returntype="void" output="false">
		<cfscript>
		var md = structnew();
		
		md.test = "UNIT TESTING";
		md.today = now();
		
		iService.processState("preProcess",md);
		
		iService.getRequestBuffer().append('luis');
		
		iService.processState("preProcess",md);
		</cfscript>
	</cffunction>
	
	<cffunction name="testProcessInterceptionWithBuffer" access="public" returntype="void" output="false">
		<cfscript>
		var md = structnew();
		
		md.test = "UNIT TESTING";
		md.today = now();
			
		iService.getRequestBuffer().append('luis');
		
		iService.processState("preProcess",md);
		
		
		</cfscript>
	</cffunction>
	
	<cffunction name="testProcessInvalidInterception" access="public" returntype="void" output="false">
		<cfscript>
		var md = structnew();
		
		try{
			iService.processState("nada loco",md);
		}
		catch("Framework.InterceptorService.InvalidInterceptionState" e){
			AssertTrue(true);
		}
		catch(Any e){
			fail(e.message & e.detail);
		}
		</cfscript>
	</cffunction>
	
	<cffunction name="testManualRegistration" access="public" returntype="void" output="false">
		<cfscript>
			iService.appendInterceptionPoints('unitTest');
			iService.registerInterceptor(interceptorClass='coldbox.testing.testinterceptors.mock');
			
			AssertTrue( isObject(iService.getStateContainer('unittest')) );
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testManualObjectRegistration" access="public" returntype="void" output="false">
		<cfscript>
			var obj = CreateObject("component","coldbox.testing.testinterceptors.mock");
			
			iService.appendInterceptionPoints('unitTest');
			iService.registerInterceptor(interceptorObject=obj);
			
			AssertTrue( isObject(iService.getStateContainer('unittest')) );
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testManualObjectRegistration2" access="public" returntype="void" output="false">
		<cfscript>
			var obj = CreateObject("component","coldbox.testing.testinterceptors.mock");
			
			iService.registerInterceptor(interceptorObject=obj,customPoints='unitTest');
			
			AssertTrue( isObject(iService.getStateContainer('unittest')) );
			
		</cfscript>
	</cffunction>
	
</cfcomponent>