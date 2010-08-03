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
<cfcomponent output="false" extends="coldbox.system.testing.BaseTestCase" hint="A base test for testing plugins">

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
				UDFLibrary = md.UDFLibraryFile;
			}
			
			// Create handler with Mocking capabilities
			variables.handler = mockBox.createMock(md.handler);
			
			// Create Mock Objects
			variables.mockController = mockBox.createEmptyMock("coldbox.system.testing.mock.web.MockController");
			variables.mockRequestService = mockBox.createEmptyMock("coldbox.system.services.RequestService");
			variables.mockLogBox	 = mockBox.createEmptyMock("coldbox.system.logging.LogBox");
			variables.mockLogger	 = mockBox.createEmptyMock("coldbox.system.logging.Logger");
			variables.mockFlash		 = mockBox.createMock("coldbox.system.web.flash.MockFlash").init(mockController);
			variables.mockCacheBox   = mockBox.createEmptyMock("coldbox.system.cache.CacheFactory");
			
			// Mock Handler Dependencies
			variables.mockController.$("getLogBox",variables.mockLogBox);
			variables.mockController.$("getCacheBox",variables.mockCacheBox);
			variables.mockController.$("getRequestService",variables.mockRequestService);
			variables.mockController.$("getSetting").$args("UDFLibraryFile").$returns(UDFLibrary);
			variables.mockController.$("getSetting").$args("AppMapping").$returns("/");
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