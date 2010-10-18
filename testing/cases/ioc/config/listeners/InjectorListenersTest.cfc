<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	
	function setup(){
		// init with defaults
		injector = getMockBox().createMock("coldbox.system.ioc.Injector");
		
		config = createObject("component","coldbox.system.ioc.config.WireBoxConfig").init(CFCConfigPath="coldbox.testing.cases.ioc.listeners.Config");
		
		// init factory
		injector.init(config=config);	
	}
	
	function testRegisterListeners(){
		eventContainers = injector.getEventManager().getEventPoolContainer();
		
		assertEquals( true, structKeyExists(eventContainers,"afterInjectorConfiguration") );
		assertEquals( true, structKeyExists(eventContainers,"beforeObjectCreation") );
		assertEquals( true, structKeyExists(eventContainers,"afterObjectCreation") );
		
		
	}
	
</cfscript>
</cfcomponent>