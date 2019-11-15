/**
* My BDD Test
*/
component extends="testbox.system.BaseSpec"{

/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){

	}

	// executes after all suites+specs in the run() method
	function afterAll(){

	}

/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "ColdBox Runnables", function(){

			beforeEach(function( currentSpec ){
				asyncManager = new coldbox.system.core.async.AsyncManager();
			});

			it( "can run a closure with a future", function(){
				var f = asyncManager.run( function(){
					var message = "hello from in closure land";
					createObject( "java", "java.lang.System" ).out.println( message );
					debug( "Hello debugger" );

					sleep( 1000 );

					return "Luis";
				} )
				.setPriority( "high" )
				.then( function( result ){
					return result & " majano";
				} )
				.then( function( result ){
					return result & " loves threads, NOT!";
				} )
				.onError( function( t, e ){
					createObject( "java", "java.lang.System" ).out.println( e.stackTrace );
					writeDump( var=e.message );abort;
				} )
				.start();

				expect( f.getName() ).toInclude( "cbasync" );
				expect( f.getState() ).notToBeEmpty();
				expect( f.getId() ).toBeNumeric();
				expect( f.getPriority() ).toBe( 5 );
				expect( f.getPriorityValue() ).toBe( "normal" );
				//expect( f.isAlive() ).toBeTrue();
				//expect( f.isDone() ).toBeFalse();
				expect( f.isInterrupted() ).toBeFalse();
				expect( f.getStackTrace() ).toBeArray();

				writeDump( var=f.get() );
			});

		});
	}

}
