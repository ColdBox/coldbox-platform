<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	
	function setup(){
		// init with defaults
		injector = getMockBox().createMock("coldbox.system.ioc.Injector");
		
		// init factory
		injector.init(binder="coldbox.testing.cases.ioc.config.listeners.Config");	
	}
	
	function testRegisterListeners(){
		eventContainers = injector.getEventManager().getEventPoolContainer();
		
		assertEquals( true, structKeyExists(eventContainers,"afterInjectorConfiguration") );
		assertEquals( true, structKeyExists(eventContainers,"afterInstanceCreation") );
		assertEquals( true, structKeyExists(eventContainers,"beforeInstanceCreation") );
		
		
	}
	
</cfscript>
</cfcomponent>