/**
* My BDD Test
*/
component extends="coldbox.system.testing.BaseSpec"{
	
/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		variables.startDate = dateAdd("m",-1,Now());
		variables.endDate = Now();

		addAssertions( "coldbox.test.specs.testing.resources.CustomAsserts" );
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
	}

/*********************************** BDD SUITES ***********************************/

	function run(){
		// all your suites go here.
		describe( "Custom Assertions", function(){
		
			it( "awesome works", function(){
				$assert.assertIsAwesome( true, true );
			});

			it( "funky works", function(){
				$assert.assertIsFunky( 200 );
			});
		
		});
	}
	
}