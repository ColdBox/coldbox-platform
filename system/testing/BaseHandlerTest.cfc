<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	  : Luis Majano
Date        : 06/20/2009
Description :
 Base Test case for Handlers Standalone
---------------------------------------------------------------------->
<cfcomponent output="false" extends="coldbox.system.testing.BaseTestCase" hint="A base test for unit testing event handlers">

	<cfscript>
		this.loadColdbox = false;	
	</cfscript>

	<!--- setupTest --->
    <cffunction name="setup" output="false" access="public" returntype="void" hint="Prepare for testing">
    	<cfscript>
    		var md 			= getMetadata(this);
			var mockBox 	= getMockBox();
			var UDFLibrary  = "";
			
			// Check for handler path else throw exception
			if( NOT structKeyExists(md, "handler") ){
				$throw("handler annotation not found on component tag","Please declare a 'handler=path' annotation","BaseHandlerTest.InvalidStateException");
			}
			// Check for UDF Library File
			if( structKeyExists(md, "UDFLibraryFile") ){
				// inflate it, since it can't be an array in metadata
				UDFLibrary = listToArray( md.UDFLibraryFile );
			}
			
			// Create handler with Mocking capabilities
			variables.handler = mockBox.createMock(md.handler);
			
			// Create Mock Objects
			variables.mockController 	 = mockBox.createEmptyMock("coldbox.system.testing.mock.web.MockController");
			variables.mockRequestContext = getMockRequestContext();
			variables.mockRequestService = mockBox.createEmptyMock("coldbox.system.web.services.RequestService").$("getContext", variables.mockRequestContext);
			variables.mockLogBox	 	 = mockBox.createEmptyMock("coldbox.system.logging.LogBox");
			variables.mockLogger	 	 = mockBox.createEmptyMock("coldbox.system.logging.Logger");
			variables.mockFlash		 	 = mockBox.createMock("coldbox.system.web.flash.MockFlash").init(mockController);
			variables.mockCacheBox   	 = mockBox.createEmptyMock("coldbox.system.cache.CacheFactory");
			variables.mockWireBox		 = mockBox.createEmptyMock("coldbox.system.ioc.Injector");
			
			// Mock Handler Dependencies
			variables.mockController.$("getLogBox",variables.mockLogBox)
				.$("getCacheBox",variables.mockCacheBox)
				.$("getWireBox",variables.mockWireBox)
				.$("getRequestService",variables.mockRequestService)
				.$("getSetting").$args("UDFLibraryFile").$results(UDFLibrary)
				.$("getSetting").$args("AppMapping").$results("/");
			variables.mockRequestService.$("getFlashScope",variables.mockFlash);
			variables.mockLogBox.$("getLogger",variables.mockLogger);
			
			// Decorate handler?
			if( NOT getUtil().isFamilyType("handler",variables.handler) ){
				getUtil().convertToColdBox( "handler", variables.handler );	
				// Check if doing cbInit()
				if( structKeyExists(variables.handler, "$cbInit") ){ variables.handler.$cbInit( mockController ); }
			}
    	</cfscript>
    </cffunction>

</cfcomponent>