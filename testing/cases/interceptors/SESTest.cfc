<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseInterceptorTest" interceptor="coldbox.system.interceptors.SES">
<cfscript>

	function setup(){
		super.setup();
		ses = interceptor;
	}
	
	function testConfigure(){
		// mocks
		mockController.$("getSetting").$args("HandlersPath").$results( expandPath("/coldbox/testharness/handlers") )
			.$("getSetting").$args("HandlersExternalLocationPath").$results("")
			.$("getSetting").$args("Modules").$results( {} )
			.$("getSetting").$args("EventName").$results( 'event' )
			.$("getSetting").$args("DefaultEvent").$results( 'index' );
		ses.$("getSetting").$args("AppMapping").$results("/coldbox/testharness")
			.$("importConfiguration")
			.$("setSetting");
		ses.setBaseURL("http://localhost");
		ses.configure();		
		assertTrue( ses.$atLeast(2,"setSetting") );
	}
	
	function testAddNamespaceRoutes(){
		ses.$property("namespaceroutingtable","instance",{})
			.$("addRoute");
		
		ses.addNamespace(pattern="/luis",namespace="luis");
		
		assertEquals( "luis", ses.$callLog().addRoute[1].namespaceRouting );
		assertEquals( "/luis", ses.$callLog().addRoute[1].pattern );
	}

</cfscript>
</cfcomponent>

