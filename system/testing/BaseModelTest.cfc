﻿/**
*********************************************************************************
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
* Standalone base test case for model objects
*/
component extends="coldbox.system.testing.BaseTestCase"{
	
	this.loadColdbox = false;	
	
	function setup(){
		if( this.loadColdbox ) {
			super.setup();
		}

		var md 		= getMetadata(this);
		var mockBox = getMockBox();
		
		// Check for model path annotation, and use it if declared.
		if( structKeyExists(md, "model") ){
			// Create model with Mocking capabilities
			variables.model = mockBox.createMock(md.model);				
		}	
		
		// Create Mock Objects
		variables.mockLogBox	 = mockBox.createEmptyMock("coldbox.system.logging.LogBox");
		variables.mockLogger	 = mockBox.createEmptyMock("coldbox.system.logging.Logger");
		variables.mockCacheBox   = mockBox.createEmptyMock("coldbox.system.cache.CacheFactory");
		variables.mockWireBox	 = mockBox.createMock("coldbox.system.ioc.Injector").init();
				
	}
}
