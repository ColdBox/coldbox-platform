<cfcomponent extends="coldbox.system.testing.BaseModelTest">
	<cfscript>
	function setup(){
		// init with defaults
		injector = createMock( "coldbox.system.ioc.Injector" );

		// init factory
		injector.init( binder = "coldbox.tests.specs.ioc.config.listeners.Config" );
	}

	function testRegisterListeners(){
		eventContainers = injector.getEventManager().getEventPoolContainer();

		assertEquals( true, structKeyExists( eventContainers, "afterInjectorConfiguration" ) );
		assertEquals( true, structKeyExists( eventContainers, "afterInstanceCreation" ) );
		assertEquals( true, structKeyExists( eventContainers, "beforeInstanceCreation" ) );
	}
	</cfscript>
</cfcomponent>
