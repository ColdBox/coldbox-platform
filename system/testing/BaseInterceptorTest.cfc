<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	  : Luis Majano
Date        : 06/20/2009
Description :
 Base Test case for Interceptors
---------------------------------------------------------------------->
<cfcomponent output="false" extends="coldbox.system.testing.BaseTestCase" hint="A base test for testing interceptors">

	<cfscript>
		this.loadColdbox = false;	
	</cfscript>

	<!--- setupTest --->
    <cffunction name="setup" output="false" access="public" returntype="void" hint="Prepare for testing">
    	<cfscript>
    		var md 		= getMetadata(this);
			var mockBox = getMockBox();
			
			// Check for plugin else throw exception
			if( NOT structKeyExists(md, "interceptor") ){
				$throw("interceptor annotation not found on component tag","Please declare a 'interceptor=path' annotation","BaseInterceptorTest.InvalidStateException");
			}
			
			// Check if user setup interceptor properties on scope
			if( NOT structKeyExists(variables,"configProperties") ){
				variables.configProperties = structnew();
			}
			
			// Create interceptor with Mocking capabilities
			variables.interceptor = mockBox.createMock(md.interceptor);
			
			// Create Mock Objects
			variables.mockController 	 = mockBox.createEmptyMock("coldbox.system.testing.mock.web.MockController");
			variables.mockRequestContext = getMockRequestContext();
			variables.mockRequestService = mockBox.createEmptyMock("coldbox.system.web.services.RequestService").$("getContext", variables.mockRequestContext);
			variables.mockLogBox	 	 = mockBox.createEmptyMock("coldbox.system.logging.LogBox");
			variables.mockLogger	 	 = mockBox.createEmptyMock("coldbox.system.logging.Logger");
			variables.mockFlash		 	 = mockBox.createMock("coldbox.system.web.flash.MockFlash").init(mockController);
			variables.mockCacheBox   	 = mockBox.createEmptyMock("coldbox.system.cache.CacheFactory");
			variables.mockWireBox		 = mockBox.createEmptyMock("coldbox.system.ioc.Injector");
			
			// Mock Plugin Dependencies
			variables.mockController.$("getLogBox",variables.mockLogBox)
				.$("getCacheBox",variables.mockCacheBox)
				.$("getWireBox",variables.mockWireBox)
				.$("getRequestService",variables.mockRequestService);
			variables.mockRequestService.$("getFlashScope",variables.mockFlash);
			variables.mockLogBox.$("getLogger",variables.mockLogger);
			
			// Decorate interceptor?
			if( NOT getUtil().isFamilyType("interceptor",variables.interceptor) ){
				getUtil().convertToColdBox( "interceptor", variables.interceptor );	
				// Check if doing cbInit()
				if( structKeyExists(variables.interceptor, "$cbInit") ){ variables.interceptor.$cbInit( mockController, configProperties ); }
			}
			else{
				variables.interceptor.init( mockController, configProperties );
			}
    	</cfscript>
    </cffunction>

</cfcomponent>