<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	
	function setup(){
		// init with defaults
		injector = getMockBox().createMock("coldbox.system.ioc.Injector");
		
		// init injector
		injector.init();
	}
	
	function testGetConfig(){
		debug( injector.getConfig() );
	}
	function testgetVersion(){
		debug( injector.getVersion() );
	}
	function testGetInjectorID(){
		debug( injector.getInjectorID() );
		assertEquals( createObject('java','java.lang.System').identityHashCode(injector), injector.getInjectorID() );
	}
	
	function testconfigureLogBox(){
		makePublic(injector,"configureLogBox");
		injector.configureLogBox();
		
		assertTrue( isObject(injector.getLogBox()) );
	}
	
	function testConfigureEventManager(){
		makePublic(injector,"configureEventManager");
		injector.configureEventManager();
		
		assertTrue( isObject(injector.getEventManager()) );
	}
	
	
</cfscript>
</cfcomponent>