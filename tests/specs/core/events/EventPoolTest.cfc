<cfcomponent extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.core.events.EventPool">
	<cfscript>
	function setup(){
		super.setup();
		pool = model;
		pool.init( "onTest" );
	}
	function testEventPool(){
		target = createObject( "component", "tests.resources.Event" );
		pool.register( "myEvent", target );

		assertTrue( pool.exists( "myEvent" ) );
		assertTrue( pool.exists( "MYEVENT" ) );
		assertEquals( pool.getObject( "myEvent" ), target );

		assertFalse( pool.exists( "yes" ) );
		pool.unregister( "myEvent" );
		assertFalse( pool.exists( "myEvent" ) );
	}
	function testProcessEventPool(){
		target = createObject( "component", "tests.resources.Event" );
		pool.register( "myEvent", target );
		data = { hello : "Luis Majano", from : "#createUUID()#" };

		assertequals( arrayLen( target.logs ), 0 );
		pool.process( data );

		assertTrue( arrayLen( target.logs ) );
		// debug(target.logs);
	}
	</cfscript>
</cfcomponent>
