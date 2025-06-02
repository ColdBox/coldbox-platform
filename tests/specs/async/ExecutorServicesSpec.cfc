/**
 * My BDD Test
 */
component extends="BaseAsyncSpec" {

	variables.javaMajorVersion = createObject( "java", "java.lang.System" ).getProperty( "java.version" ).listFirst( "." )

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "ColdBox Async Executor Services", function(){
			beforeEach( function( currentSpec ){
				asyncManager = new coldbox.system.async.AsyncManager();
			} );

			story( "Ability to create different types of executors", function(){
				it( "can create the default fixed executor", function(){
					var executor = asyncManager.newExecutor( "unitTest" );
					expect( executor.getName() ).toBe( "unitTest" );
					expect( executor.getCorePoolSize() ).toBe( 20 );
					debug( executor.getStats() );
					expect( executor.getStats() ).toBeStruct();
				} );
				it( "can create the default fixed executor with custom threads", function(){
					var executor = asyncManager.newExecutor( name: "unitTest", threads: 100 );
					expect( executor.getName() ).toBe( "unitTest" );
					expect( executor.getCorePoolSize() ).toBe( 100 );
					debug( executor.getStats() );
					expect( executor.getStats() ).toBeStruct();
				} );
				it( "can create the a single executor", function(){
					var executor = asyncManager.newExecutor( name: "unitTest", type: "single" );
					expect( executor.getName() ).toBe( "unitTest" );
					expect( executor.getCorePoolSize() ).toBe( 1 );
					debug( executor.getStats() );
					expect( executor.getStats() ).toBeStruct();
				} );
				it( "can create the a cached executor", function(){
					var executor = asyncManager.newExecutor( name: "unitTest", type: "cached" );
					expect( executor.getName() ).toBe( "unitTest" );
					expect( executor.getPoolSize() ).toBe( 0 );
					debug( executor.getStats() );
					expect( executor.getStats() ).toBeStruct();
				} );
				it( "can create a fork_join executor", function(){
					var executor = asyncManager.newExecutor( name: "fork_join", type: "fork_join" );
					expect( executor.getName() ).toBe( "fork_join" );
					expect( executor.getPoolSize() ).toBe( 0 );
					debug( executor.getStats() );
					expect( executor.getStats() ).toBeStruct();
				} );
				it( "can create a work_stealing executor", function(){
					var executor = asyncManager.newExecutor( name: "work_stealing", type: "work_stealing" );
					expect( executor.getName() ).toBe( "work_stealing" );
					expect( executor.getPoolSize() ).toBe( 0 );
					debug( executor.getStats() );
					expect( executor.getStats() ).toBeStruct();
				} );
				it( "can create a scheduled executor", function(){
					var executor = asyncManager.newExecutor( name: "unitTest", type: "scheduled" );
					expect( executor.getName() ).toBe( "unitTest" );
					expect( executor.getCorePoolSize() ).toBe( 20 );
					expect( executor.getNative().toString() ).toInclude( "ScheduledThreadPoolExecutor" );
					debug( executor.getStats() );
					expect( executor.getStats() ).toBeStruct();
				} );
				// Skip on Adobe as their dumb reflection does not support virtual threads
				it(
					title: "can create a virtual thread executor",
					skip : (
						( server.keyExists( "coldfusion" ) && server.coldfusion.productName.findNoCase( "ColdFusion" ) ) ||
						( variables.javaMajorVersion < 21 )
					),
					body: function(){
						var executor = asyncManager.newExecutor( name: "virtual", type: "virtual" );
						expect( executor.getName() ).toBe( "virtual" );
						expect( executor.getPoolSize() ).toBe( 0 );
						debug( executor.getStats() );
						expect( executor.getStats() ).toBeStruct();
					}
				);
				it( "can throw an exception if the wrong type is passed", function(){
					expect( function(){
						asyncManager.newExecutor( name: "unitTest", type: "bogus" );
					} ).toThrow();
				} );
				it( "can return the same executor if already built", function(){
					var executor  = asyncManager.newExecutor( "unitTest" );
					var executor2 = asyncManager.newExecutor( "unitTest" );
					expect( executor ).toBe( executor2 );
				} );
			} );

			story( "Ability to retrieve registered executors", function(){
				it( "can retrieve a created executor", function(){
					var executor = asyncManager.newExecutor( "unitTest" );
					expect( asyncManager.getExecutor( "unitTest" ) ).toBeComponent();
				} );
				it( "will throw an exception when getting an invalid executor", function(){
					expect( function(){
						asyncManager.getExecutor( "bogus" );
					} ).toThrow( type = "ExecutorNotFoundException" );
				} );
				it( "can retrieve the executor key names", function(){
					expect( asyncManager.getExecutorNames() ).toBeEmpty();
					var executor = asyncManager.newExecutor( "unitTest" );
					expect( asyncManager.getExecutorNames() ).toInclude( "unitTest" );
				} );
				it( "can verify if a executorr exists", function(){
					expect( asyncManager.hasExecutor( "bogus" ) ).toBeFalse();
					var executor = asyncManager.newExecutor( "unitTest" );
					expect( asyncManager.hasExecutor( "unitTest" ) ).toBeTrue();
				} );
			} );

			story( "Ability to delete executors", function(){
				it( "can delete an existing executor", function(){
					var executor = asyncManager.newExecutor( "unitTest" );
					asyncManager.deleteExecutor( "unitTest" );
					expect( asyncManager.hasExecutor( "unitTest" ) ).toBeFalse();
				} );
				it( "can delete a non-existing executor", function(){
					asyncManager.deleteExecutor( "bogusTest" );
				} );
			} );

			story( "Ability to shutdown executors", function(){
				it( "can shutdown a valid executor", function(){
					var executor1 = asyncManager.newExecutor( "unitTest1" );
					asyncManager.shutdownExecutor( "unitTest1" );
					expect( executor1.isShutdown() ).toBeTrue();
				} );
				it( "can shutdown an invalid executor", function(){
					asyncManager.shutdownExecutor( "bogus" );
				} );
				it( "can shutdown all executors", function(){
					var executor1 = asyncManager.newExecutor( "unitTest1" );
					var executor2 = asyncManager.newExecutor( "unitTest2" );

					asyncManager.shutdownAllExecutors();

					expect( executor1.isShutdown() ).toBeTrue();
					expect( executor2.isShutdown() ).toBeTrue();
				} );
			} );

			story( "Ability to get status from the executors", function(){
				it( "can retrieve the executor status map", function(){
					var executor1 = asyncManager.newExecutor( "unitTest1" );
					var executor2 = asyncManager.newExecutor( "unitTest2" );

					var statusMap = asyncManager.getExecutorStatusMap();

					// debug( statusMap );
					expect( statusMap ).toHaveKey( "unitTest1" ).toHaveKey( "unitTest2" );
				} );

				it( "can retrieve the stats from a single executor", function(){
					var executor1 = asyncManager.newExecutor( "unitTest1" );
					var statusMap = asyncManager.getExecutorStatusMap( "unitTest1" );

					debug( statusMap );
					expect( statusMap.isShutdown ).toBeFalse();
				} );
			} );
		} );
	}

}
