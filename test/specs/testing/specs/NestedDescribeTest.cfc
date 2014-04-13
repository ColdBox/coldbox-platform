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
		describe( "Outer describe", function(){
			describe( "Inner describe", function(){			
				it( "Tests are ONLY in inner it()", function(){				
					expect( true ).toBe( true );
				});
			});
		});
	}
	
}