/**
 * Event pool tests
 */
component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.core.events.EventPool" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	/**
	 * executes before all suites+specs in the run() method
	 */
	function beforeAll(){
	}

	/**
	 * executes after all suites+specs in the run() method
	 */
	function afterAll(){
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Event Pool Suites", function(){
			beforeEach( function( currentSpec ){
				setup();
				pool = model.init( "onTest" );
			} );

			it( "can register objects", function(){
				target = createObject( "component", "tests.resources.Event" );
				pool.register( "myEvent", target );

				assertTrue( pool.exists( "myEvent" ) );
				assertTrue( pool.exists( "MYEVENT" ) );
				assertEquals( pool.getObject( "myEvent" ), target );

				assertFalse( pool.exists( "yes" ) );
				pool.unregister( "myEvent" );
				assertFalse( pool.exists( "myEvent" ) );
			} );

			it( "can get objects from the pool", function(){
				target = createObject( "component", "tests.resources.Event" );
				pool.register( "myEvent", target );
				expect( pool.getObject( "myEvent" ) ).toBe( target );
			} );

			it( "can get invalid objects from the pool", function(){
				expect( pool.getObject( "bogus" ) ).toBeStruct().toBeEmpty();
			} );

			it( "can unregister objects", function(){
				target = createObject( "component", "tests.resources.Event" );
				pool.register( "myEvent", target );

				expect( pool.exists( "myevent" ) ).toBeTrue();
				pool.unregister( "myevent" );
				expect( pool.exists( "myevent" ) ).toBeFalse();
			} );

			it( "can process event pools", function(){
				target = createObject( "component", "tests.resources.Event" );
				pool.register( "myEvent", target );
				data = { hello : "Luis Majano", from : "#createUUID()#" };

				assertequals( arrayLen( target.logs ), 0 );
				pool.process( data );

				assertTrue( arrayLen( target.logs ) );
			} );
		} );
	}

}
