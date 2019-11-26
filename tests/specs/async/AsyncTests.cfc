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
		describe( "ColdBox Async Programming", function(){

			beforeEach(function( currentSpec ){
				asyncManager = new coldbox.system.async.AsyncManager();
			});

			it( "can run a closure with a ColdBox Future", function(){

				var f = asyncManager.run( function(){
					var message = "hello from in closure land";
					createObject( "java", "java.lang.System" ).out.println( message );
					debug( "Hello debugger" );

					sleep( 1000 );

					return "Luis";
				} )
				.then( function( result ){
					return result & " majano";
				} )
				.then( function( result ){
					return result & " loves threads, NOT!";
				} );

				expect( f.get(), "Luis majano loves threads, NOT!" );
			});

		});
	}

}
