/**
* This tests the BDD functionality in TestBox. This is CF10+, Railo4+
*/
component extends="coldbox.system.testing.BaseSpec"{

/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		coldbox = 0;
	}

	function afterAll(){
	}

/*********************************** BDD SUITES ***********************************/

	function run(){

		describe( "A suite", function(){
		
			// before each spec in THIS suite group
			beforeEach(function(){
				coldbox++;
				debug( "beforeEach suite: coldbox = #coldbox#" );
			});
			
			// after each spec in THIS suite group
			afterEach(function(){
				debug( "afterEach suite: coldbox = #coldbox#" );
			});
			
			it("before should be 1", function(){
				expect( coldbox ).toBe( 1 );
			});

			describe( "A nested suite", function(){
				
				it( "before should be 2", function(){
					expect(	coldbox ).toBe( 2 );
				});

				it( "before should be 3", function(){
					expect(	coldbox ).toBe( 3 );
				});
			
			});
			
			
		});

		

	}

}