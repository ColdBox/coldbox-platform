<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	September 3, 2007
Description :
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		mockController = getMockBox().createMock(className="coldbox.system.web.Controller",clearMethods=true);
		mockInterceptorService = getMockBox().createMock(className="coldbox.system.web.services.InterceptorService",clearMethods=true);
		mockEngine     = getMockBox().createEmptyMock(className="coldbox.system.core.cf.CFMLEngine");
		
		mockController.$("getInterceptorService",mockInterceptorService);
		mockController.$("getCFMLEngine",mockEngine);
		
		handlerService = getMockBox().createMock(classname="coldbox.system.web.services.HandlerService");
		handlerService.init(mockController);
	}
	
	function testRegisterHandlers(){
		// Mocks
		mockController.$("getSetting").$args("HandlersPath").$results(expandPath('/coldbox/testharness/handlers'));
		mockController.$("getSetting").$args("HandlersExternalLocationPath").$results(expandPath('/coldbox/testing/testhandlers'));
		mockController.$("setSetting");
		handlers = ["ehGeneral","blog"];
		handlerService.$("gethandlerListing",handlers);
		
		handlerService.registerHandlers();
		//debug(mockController.$callLog().setSetting[1]);
		assertEquals( mockController.$callLog().setSetting[1].value, arrayToList(handlers));
		assertEquals( mockController.$callLog().setSetting[2].value, arrayToList(handlers));
	}
	
	function testRecurseListing(){
		path = expandPath("/coldbox/testharness/handlers");
		makePublic(handlerService,"getHandlerListing");
		
		files = handlerService.getHandlerListing(path);
		//debug(files);
		assertTrue( arrayLen(files) );
	}
</cfscript>
</cfcomponent>
