<cfcomponent name="cfmlengine" output="false" extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		pool = getMockBox().createMock("coldbox.system.core.events.EventPool");
		pool.init('onTest');
	}
	function testEventPool(){
		target = createObject("component","coldbox.testing.cases.core.events.Event");
		pool.register("myEvent",target);
		
		assertTrue( pool.exists("myEvent") );
		assertTrue( pool.exists("MYEVENT") );
		assertEquals( pool.getObject("myEvent"), target);
		
		assertFalse( pool.exists("yes") );
		pool.unregister("myEvent");
		assertFalse( pool.exists("myEvent") );
	}
	function testProcessEventPool(){
		target = createObject("component","coldbox.testing.cases.core.events.Event");
		pool.register("myEvent",target);
		data = {hello="Luis Majano", from="#createUUID()#"};
		
		assertequals(arrayLen(target.logs), 0);
		pool.process(data);
		
		assertTrue( arrayLen(target.logs) );
		debug(target.logs);
	}

</cfscript>

</cfcomponent>