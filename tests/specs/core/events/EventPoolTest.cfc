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
				variables.pool = model.init( "onTest" );
			} );

			it( "can register objects", function(){
				var target = createObject( "component", "tests.resources.Event" );
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
				var data = { hello : "Luis Majano", from : "#createUUID()#" };

				assertequals( arrayLen( target.logs ), 0 );
				pool.process( data );

				assertTrue( arrayLen( target.logs ) );
			} );

			it( "builds listener chain on register", function(){
				expect( pool.getListenerChain() ).toBeArray().toBeEmpty();

				var target1 = createObject( "component", "tests.resources.Event" );
				var target2 = createObject( "component", "tests.resources.Event" );

				pool.register( "event1", target1 );
				expect( pool.getListenerChain() ).toHaveLength( 1 );
				expect( pool.getListenerChain()[ 1 ].key ).toBe( "event1" );
				expect( pool.getListenerChain()[ 1 ].target ).toBe( target1 );

				pool.register( "event2", target2 );
				expect( pool.getListenerChain() ).toHaveLength( 2 );
				expect( pool.getListenerChain()[ 2 ].key ).toBe( "event2" );
				expect( pool.getListenerChain()[ 2 ].target ).toBe( target2 );
			} );

			it( "rebuilds listener chain on unregister", function(){
				var target1 = createObject( "component", "tests.resources.Event" );
				var target2 = createObject( "component", "tests.resources.Event" );

				pool.register( "event1", target1 );
				pool.register( "event2", target2 );
				expect( pool.getListenerChain() ).toHaveLength( 2 );

				pool.unregister( "event1" );
				expect( pool.getListenerChain() ).toHaveLength( 1 );
				expect( pool.getListenerChain()[ 1 ].key ).toBe( "event2" );
			} );

			it( "processes listeners in registration order", function(){
				var callOrder = [];

				var target1 = createObject( "component", "tests.resources.Event" );
				var target2 = createObject( "component", "tests.resources.Event" );
				var target3 = createObject( "component", "tests.resources.Event" );

				// Override the onTest method to track call order
				target1.onTest = function( event, data, interceptData ){
					callOrder.append( "first" );
				};
				target2.onTest = function( event, data, interceptData ){
					callOrder.append( "second" );
				};
				target3.onTest = function( event, data, interceptData ){
					callOrder.append( "third" );
				};

				pool.register( "first", target1 );
				pool.register( "second", target2 );
				pool.register( "third", target3 );

				pool.process( {} );

				expect( callOrder ).toBe( [ "first", "second", "third" ] );
			} );

			it( "stops chain when invoker returns true", function(){
				var callOrder = [];

				var target1 = createObject( "component", "tests.resources.Event" );
				var target2 = createObject( "component", "tests.resources.Event" );
				var target3 = createObject( "component", "tests.resources.Event" );

				target1.onTest = function( event, data, interceptData ){
					callOrder.append( "first" );
					return false;
				};
				target2.onTest = function( event, data, interceptData ){
					callOrder.append( "second" );
					return true; // Stop the chain
				};
				target3.onTest = function( event, data, interceptData ){
					callOrder.append( "third" );
				};

				pool.register( "first", target1 );
				pool.register( "second", target2 );
				pool.register( "third", target3 );

				pool.process( {} );

				expect( callOrder ).toBe( [ "first", "second" ] );
			} );
		} );
	}

}
