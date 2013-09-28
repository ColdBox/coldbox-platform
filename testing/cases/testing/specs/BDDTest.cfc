/**
* This tests the BDD functionality in TestBox. This is CF10+, Railo4+
*/
component{

/*********************************** LIFE CYCLE Methods ***********************************/

	beforeAll = function(){
		application.salvador = 1;
	}

	afterAll = function(){
		structClear( application );	
	}

/*********************************** BDD SUITES ***********************************/

	suites = function(){

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
			it("is just a closure, so it can contain code", function(){
				expect( coldbox ).toBe( 1 );
			});
			
			// more than 1 expectation
			it("can have more than one expectation test", function(){
				coldbox = coldbox * 8;
				expect( coldbox ).toBeNumeric();
				expect( coldbox ).toBeCloseTo( expected=10, delta=2 );
			});
			
			// xit() skips
			xit("can have tests that can be skipped easily", function(){
				fail( "xit() this should skip" );	
			});
			
			// label specs
			it("can have tests that execute if the right label is applied", function(){
				expect( server ).toHaveKeys( "railo" );
			}, "railo");
			
			// specs with a skip closure
			it(title="can have a skip that is executed at runtime",function(){
				fail( "Skipped programmatically, this should fail" );
			},skip=function(){ return true; })
		
		});
		
		// Label attached suites
		describe(title="A railo only suite", body=function(){
			it("should only execute for railo", function(){
				expect( server ).toHaveKeys( "railo" );	
			});
		}, labels="railo");
		
		// xdescribe() skips the entire suite
		xdescribe("A suite that is skipped", body=function(){
			it("will never execute this", function(){
				fail( "This should not have executed" );
			})	
		});

		describe("A calculator", function(){
			
			it("Can have no beforeEach if needed", function(){
				c = new Calculator();
				expect( c ).toBeObject();
			});
			
			it("can add correctly", function(){
				c = new Calculator();
				var r = c.add( 2, 2 );
				expect( r ).toBe( 4 );
			});
			
			it("cannot divide by zero", function(){
				c = new Calculator();
				expect( function(){
					c.divide( 3, 0 );
				}).toThrow( "DivideByZero" );
			});
			
			it("can use a mocked stub", function(){
				c = createStub().$("getData", 4);
				r = new Calculator().add( 4, c.getData() );
				expect( r ).toBe( 8 );
				expect( c.$once( "getData") ).toBeTrue();
			});
			
		});

	}

}