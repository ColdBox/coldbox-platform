/**
*********************************************************************************
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* Standalone base test case for handlers
*/
component extends="coldbox.system.testing.BaseTestCase"{

	this.loadColdbox = false;

	function setup(){
		var md 					= getMetadata( this );
		var mockBox 			= getMockBox();
		var applicationHelper  	= [];

		// Check for handler path else throw exception
		if( NOT structKeyExists( md, "handler" ) ){
			throw( "handler annotation not found on component tag","Please declare a 'handler=path' annotation","BaseHandlerTest.InvalidStateException" );
		}
		// Check for applicationHelper
		if( structKeyExists( md, "applicationHelper" ) ){
			// inflate it, since it can't be an array in metadata
			applicationHelper = listToArray( md.applicationHelper );
		}

		// Create handler with Mocking capabilities
		variables.handler = mockBox.createMock(md.handler);

		// Create Mock Objects
		variables.mockController 	 = mockBox.createMock( "coldbox.system.testing.mock.web.MockController" );
		variables.mockRequestContext = getMockRequestContext();
		variables.mockRequestService = mockBox.createEmptyMock( "coldbox.system.web.services.RequestService" ).$( "getContext", variables.mockRequestContext);
		variables.mockLogBox	 	 = mockBox.createEmptyMock( "coldbox.system.logging.LogBox" );
		variables.mockLogger	 	 = mockBox.createEmptyMock( "coldbox.system.logging.Logger" );
		variables.mockFlash		 	 = mockBox.createMock( "coldbox.system.web.flash.MockFlash" ).init(mockController);
		variables.mockCacheBox   	 = mockBox.createEmptyMock( "coldbox.system.cache.CacheFactory" );
		variables.mockWireBox		 = mockBox.createEmptyMock( "coldbox.system.ioc.Injector" );

		// Mock Handler Dependencies
		variables.mockController
			.$( "getLogBox",variables.mockLogBox)
			.$( "getRequestService",variables.mockRequestService)
			.$( "getSetting" ).$args( "applicationHelper" ).$results( applicationHelper )
			.$( "getSetting" ).$args( "AppMapping" ).$results( "/" );
		
		mockController.setLogBox( mockLogBox );
		mockController.setWireBox( mockWireBox );
		mockController.setCacheBox( mockCacheBox );

		variables.mockRequestService.$( "getFlashScope",variables.mockFlash);
		variables.mockLogBox.$( "getLogger",variables.mockLogger);

		// Decorate handler?
		if( NOT getUtil().isFamilyType( "handler", variables.handler) ){
			getUtil().convertToColdBox( "handler", variables.handler );
			// Check if doing cbInit()
			if( structKeyExists(variables.handler, "$cbInit" ) ){ variables.handler.$cbInit( mockController ); }
		}
	}
}