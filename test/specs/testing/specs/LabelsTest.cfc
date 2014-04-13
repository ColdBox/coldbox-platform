/**
* My BDD Test
*/
component extends="coldbox.system.testing.BaseSpec"{
	
/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
	}

/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( title="Suite with a label", labels="luis", body=function(){
			it( "should execute", function(){
			
			});
			it( "should execute as well", function(){
			
			});
			describe( "Nested Suite", function(){
				it( "should execute as well, as nested suite is inside a label suite", function(){
			
				});
			});
		});

		describe( "Suites with no labels", function(){
			it( "should not execute", function(){
			
			});
			it( "should not execute", function(){
			
			});		
		});
	}
	
}