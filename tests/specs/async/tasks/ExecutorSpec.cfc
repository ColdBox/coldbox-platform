/**
 * My BDD Test
 */
component extends="tests.specs.async.BaseAsyncSpec"{

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "ColdBox Executor Spec", function(){

			beforeEach( function( currentSpec ){
				asyncManager = new coldbox.system.async.AsyncManager();
			} );

			story( "Ability to process stats for different executors", function(){
				it( "can get status for a fixed executor", function(){
					var executor = asyncManager.newExecutor( "unitTest" );
					expect( executor.getStats() ).toBeStruct();
				});
				it( "can get status for a single executor", function(){
					var executor = asyncManager.newExecutor( name:"unitTest", type: "single" );
					expect( executor.getStats() ).toBeStruct();
				});
				it( "can get status for a cached executor", function(){
					var executor = asyncManager.newExecutor( name:"unitTest", type: "cached" );
					expect( executor.getStats() ).toBeStruct();
				});
				it( "can get status for a scheduled executor", function(){
					var executor = asyncManager.newExecutor( name:"unitTest", type: "scheduled" );
					expect( executor.getStats() ).toBeStruct();
				});

			} );

		} );
	}

}
