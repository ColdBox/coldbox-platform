/**
 * Flow specs
 */
component extends="testbox.system.BaseSpec" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	/**
	 * executes before all suites+specs in the run() method
	 */
	function beforeAll(){
		flow = createMock( "coldbox.system.core.delegates.Flow" );
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Flow spec", function(){
			story( "can support fluent when() constructs", function(){
				it( "can do when statements with no failures", function(){
					var result = false;
					flow.when( true, function(){
						result = true;
					} );
					expect( result ).toBeTrue();
				} );
				it( "can do when statements with failures", function(){
					var result = true;
					flow.when(
						false,
						function(){
							result = true;
						},
						function(){
							result = false;
						}
					);
					expect( result ).toBeFalse();
				} );
			} );

			story( "can support fluent unless() constructs", function(){
				it( "can do when statements with no failures", function(){
					var result = false;
					flow.unless( false, function(){
						result = true;
					} );
					expect( result ).toBeTrue();
				} );
				it( "can do when statements with failures", function(){
					var result = true;
					flow.unless(
						true,
						function(){
							result = true;
						},
						function(){
							result = false;
						}
					);
					expect( result ).toBeFalse();
				} );
			} );

			story( "can support fluen throwIf() constructs", function(){
				given( "only the type", function(){
					then( "it will throw that exception type ", function(){
						expect( function(){
							flow.throwIf( true, "MyCustomType" );
						} ).toThrow( "MyCustomType" );
					} );
				} );
				given( "the type and message", function(){
					then( "it will throw that exception type and message ", function(){
						expect( function(){
							flow.throwIf( true, "MyCustomType", "Unit Test" );
						} ).toThrow( "MyCustomType", "Unit Test" );
					} );
				} );
			} );

			story( "can support fluen throwUnless() constructs", function(){
				given( "only the type", function(){
					then( "it will throw that exception type ", function(){
						expect( function(){
							flow.throwUnless( false, "MyCustomType" );
						} ).toThrow( "MyCustomType" );
					} );
				} );
				given( "the type and message", function(){
					then( "it will throw that exception type and message ", function(){
						expect( function(){
							flow.throwUnless( false, "MyCustomType", "Unit Test" );
						} ).toThrow( "MyCustomType", "Unit Test" );
					} );
				} );
			} );

			story( "can support fluen ifNull() constructs", function(){
				given( "a null value", function(){
					then( "it will execute the success closure", function(){
						var results = false;
						flow.ifNull( javacast( "null", "" ), function(){
							results = true;
						} );
						expect( results ).toBeTrue();
					} );
				} );
				given( "a non-null value and a success closure", function(){
					then( "it will not execute the success closure and ignore the result", function(){
						var results = false;
						flow.ifNull( true, function(){
							results = true;
						} );
						expect( results ).toBeFalse();
					} );
				} );
				given( "a non-null value and a success and failure closure", function(){
					then( "it will execute the failure closure", function(){
						var results = false;
						flow.ifNull(
							true,
							function(){
							},
							function(){
								results = true;
							}
						);
						expect( results ).toBeTrue();
					} );
				} );
			} );

			story( "can support fluen ifPresent() constructs", function(){
				given( "a non null value", function(){
					then( "it will execute the success closure", function(){
						var results = false;
						flow.ifPresent( now(), function(){
							results = true;
						} );
						expect( results ).toBeTrue();
					} );
				} );
				given( "a null value and a success closure", function(){
					then( "it will not execute the success closure and ignore the result", function(){
						var results = false;
						flow.ifPresent( javacast( "null", "" ), function(){
							results = true;
						} );
						expect( results ).toBeFalse();
					} );
				} );
				given( "a null value and a success and failure closure", function(){
					then( "it will execute the failure closure", function(){
						var results = false;
						flow.ifPresent(
							javacast( "null", "" ),
							function(){
							},
							function(){
								results = true;
							}
						);
						expect( results ).toBeTrue();
					} );
				} );
			} );
		} );
	}

}
