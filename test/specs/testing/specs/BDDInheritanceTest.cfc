/**
* This tests the BDD functionality in TestBox. This is CF10+, Railo4+
*/
component extends="coldbox.system.testing.BaseSpec"{

/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		application.salvador = 1;
	}

	function afterAll(){
		structClear( application );	
	}

/*********************************** BDD SUITES ***********************************/

	function run(){

		/** 
		* describe() starts a suite group of spec tests.
		* Arguments:
		* @title The title of the suite, Usually how you want to name the desired behavior
		* @body A closure that will resemble the tests to execute.
		* @labels The list or array of labels this suite group belongs to
		* @asyncAll If you want to parallelize the execution of the defined specs in this suite group.
		* @skip A flag that tells TestBox to skip this suite group from testing if true
		*/
		describe( "A spec", function(){
		
			// before each spec in THIS suite group
			beforeEach(function(){
				coldbox = 0;
				coldbox++;
			});
			
			// after each spec in THIS suite group
			afterEach(function(){
				foo = 0;
			});
			
			/** 
			* it() describes a spec to test. Usually the title is prefixed with the suite name to create an expression.
			* Arguments:
			* @title The title of the spec
			* @spec A closure that represents the test to execute
			* @labels The list or array of labels this spec belongs to
			* @skip A flag that tells TestBox to skip this spec from testing if true
			*/
			it("is just a closure so it can contain code", function(){
				expect( coldbox ).toBe( 1 );
			});
			
			// more than 1 expectation
			it("can have more than one expectation test", function(){
				coldbox = coldbox * 8;
				// type checks
				expect( coldbox ).toBeTypeOf( 'numeric' );
				// dynamic type methods
				expect( coldbox ).toBeNumeric();
				// delta ranges
				expect( coldbox ).toBeCloseTo( expected=10, delta=2 );
				// negations
				expect( coldbox ).notToBe( 4 );
			});

			// negations
			it("can have negative expectations", function(){
				coldbox = coldbox * 8;
				// type checks
				expect( coldbox ).notToBeTypeOf( 'usdate' );
				// dynamic type methods
				expect( coldbox ).notToBeArray();
				// delta ranges
				expect( coldbox ).notToBeCloseTo( expected=10, delta=2 );
			});
			
			// xit() skips
			xit("can have tests that can be skipped easily like this one", function(){
				fail( "xit() this should skip" );	
			});
			
			// acf dynamic skips
			it( title="can have tests that execute if the right environment exists (railo only)", body=function(){
				expect( server ).toHaveKey( "railo" );
			}, skip=( !isRailo() ));

			// railo dynamic skips
			it( title="can have tests that execute if the right environment exists (acf only)", body=function(){
				expect( server ).notToHaveKey( "railo" );
			}, skip=( isRailo() ));
			
			// specs with a random skip closure
			it(title="can have a skip that is executed at runtime", body=function(){
				fail( "Skipped programmatically, this should fail" );
			},skip=function(){ return true; });
		
		});


	}

	private function isRailo(){
		return ( structKeyExists( server, "railo" ) );
	}

}