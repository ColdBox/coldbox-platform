component extends="coldbox.system.testing.BaseTestCase" appMapping="/cbTestHarness"{

/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		super.beforeAll();
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
		super.afterAll();
	}

/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "Framework Super Type", function(){

			beforeEach(function( currentSpec ){
				setup();
			});

			describe( "Can do population", function(){
				
				it( "from the request collection", function(){
					var rc = getRequestContext().getCollection();
					rc.fname = "luis";
					rc.lname = "majano";

					var target = getInterceptor( "ses" );
					var oBean = target.populateModel( "formBean" );
					expect(	oBean.getFname() ).toBe( 'luis' );
					expect(	oBean.getLname() ).toBe( 'majano' );
				});

				it( "from inline structs", function(){
					var test = {
						fname = "luis",
						lname = "majano"
					};

					var target = getInterceptor( "ses" );
					var oBean = target.populateModel( model="formBean", memento=test );
					expect(	oBean.getFname() ).toBe( 'luis' );
					expect(	oBean.getLname() ).toBe( 'majano' );
				});
			
			});

		});
	}

}