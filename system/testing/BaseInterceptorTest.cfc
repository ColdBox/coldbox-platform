/**
*********************************************************************************
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* Standalone base test case for interceptors
*/
component extends="coldbox.system.testing.BaseTestCase"{

	this.loadColdbox = false;

	/**
	* Setup an interceptor to test
	*/
	function setup(){
		var md 					= getMetadata( this );
		var mockBox 			= getMockBox();
		var applicationHelper  	= [];

		// Load ColdBox?
		if( this.loadColdBox ){ super.setup(); }

		// Check for interceptor else throw exception
		if( NOT structKeyExists( md, "interceptor" ) ){
			throw( "interceptor annotation not found on component tag", "Please declare a 'interceptor=path' annotation", "BaseInterceptorTest.InvalidStateException" );
		}
		// Check for application helper
		if( structKeyExists( md, "applicationHelper" ) ){
			// inflate it, since it can't be an array in metadata
			applicationHelper = listToArray( md.applicationHelper );
		}
		// Check if user setup interceptor properties on scope
		if( NOT structKeyExists( variables, "configProperties" ) ){
			variables.configProperties = structnew();
		}

		// Create interceptor with Mocking capabilities
		variables.interceptor = mockBox.createMock(md.interceptor);

		// Create Mock Objects
		variables.mockController 	 		= mockBox.createMock( "coldbox.system.testing.mock.web.MockController" );
		variables.mockInterceptorService 	= mockbox.createEmptyMock( "coldbox.system.web.services.InterceptorService" );
		variables.mockRequestContext 		= getMockRequestContext();
		variables.mockRequestService 		= mockBox.createEmptyMock( "coldbox.system.web.services.RequestService" ).$( "getContext", variables.mockRequestContext);
		variables.mockLogBox	 	 		= mockBox.createEmptyMock( "coldbox.system.logging.LogBox" );
		variables.mockLogger	 	 		= mockBox.createEmptyMock( "coldbox.system.logging.Logger" );
		variables.mockFlash		 	 		= mockBox.createMock( "coldbox.system.web.flash.MockFlash" ).init(mockController);
		variables.mockCacheBox   	 		= mockBox.createEmptyMock( "coldbox.system.cache.CacheFactory" );
		variables.mockWireBox		 		= mockBox.createEmptyMock( "coldbox.system.ioc.Injector" );

		// Mock interceptor Dependencies
		variables.mockController
			.$( "getSetting" ).$args( "applicationHelper" ).$results( applicationHelper )
			.$( "getRequestService",variables.mockRequestService )
			.$( "getInterceptorService", variables.mockInterceptorService );
		
		mockController.setLogBox( mockLogBox );
		mockController.setWireBox( mockWireBox );
		mockController.setCacheBox( mockCacheBox );

		variables.mockRequestService.$( "getFlashScope", variables.mockFlash );
		variables.mockLogBox.$( "getLogger", variables.mockLogger );

		// Decorate interceptor?
		if( NOT getUtil().isFamilyType( "interceptor", variables.interceptor ) ){
			getUtil().convertToColdBox( "interceptor", variables.interceptor );
			// Check if doing cbInit()
			if( structKeyExists( variables.interceptor, "$cbInit" ) ){
				variables.interceptor.$cbInit( mockController, configProperties );
			}
		} else {
			variables.interceptor.init( mockController, configProperties );
		}
	}
}