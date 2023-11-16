/**
 * This tests the struct literal construction of LogBox
 */
import coldbox.system.cache.*;

component extends="testbox.system.BaseSpec" {

	this.loadColdbox = false;

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Load CacheBox with different configuration strategies", function(){
			afterEach( function(){
				structDelete( application, "cacheBox" );
			} );

			it( "can load with the default config", function(){
				var cacheBox = new CacheFactory();
				expect( cacheBox ).toBeInstanceOf( "CacheFactory" );
				expect( cachebox.getDefaultCache() ).toBeComponent();
				expect( cachebox.getDefaultCache().getConfiguration().objectStore ).toBe(
					"ConcurrentSoftReferenceStore"
				);
			} );

			it( "can load with the default config given an empty config string", function(){
				var cacheBox = new CacheFactory( config: "" );
				expect( cacheBox ).toBeInstanceOf( "CacheFactory" );
				expect( cachebox.getDefaultCache() ).toBeComponent();
				expect( cachebox.getDefaultCache().getConfiguration().objectStore ).toBe(
					"ConcurrentSoftReferenceStore"
				);
			} );

			it( "can load with a custom config cfc path", function(){
				var cacheBox = new CacheFactory( config: "coldbox.system.cache.config.samples.SampleCacheBox" );
				expect( cacheBox ).toBeInstanceOf( "CacheFactory" );
				expect( cachebox.getDefaultCache() ).toBeComponent();
				expect( cachebox.getDefaultCache().getConfiguration().objectStore ).toBe( "ConcurrentStore" );
				expect( cachebox.getCache( "sampleCache1" ) ).toBeComponent();
				expect( cachebox.getCache( "sampleCache2" ) ).toBeComponent();
			} );

			it( "can load with a custom struct CacheBox DSL literal", function(){
				var cacheBox = new CacheFactory( {
					// Scope registration, automatically register the cachebox factory instance on any CF scope
					// By default it registers itself on server scope
					scopeRegistration : {
						enabled : false,
						scope   : "server", // server, session
						key     : "cacheBox"
					},
					// The defaultCache has an implicit name "default" which is a reserved cache name
					// It also has a default provider of cachebox which cannot be changed.
					// All timeouts are in minutes
					defaultCache : {
						objectDefaultTimeout           : 60,
						objectDefaultLastAccessTimeout : 30,
						useLastAccessTimeouts          : true,
						reapFrequency                  : 2,
						freeMemoryPercentageThreshold  : 0,
						evictionPolicy                 : "LRU",
						evictCount                     : 1,
						maxObjects                     : 200,
						objectStore                    : "ConcurrentStore"
					},
					// Register all the custom named caches you like here
					caches : {
						sampleCache1 : {
							provider   : "coldbox.system.cache.providers.CacheBoxProvider",
							properties : {
								objectDefaultTimeout  : "20",
								useLastAccessTimeouts : "false",
								reapFrequency         : "1",
								evictionPolicy        : "LFU",
								evictCount            : "1",
								maxObjects            : "100",
								objectStore           : "ConcurrentSoftReferenceStore"
							}
						},
						sampleCache2 : {
							provider   : "coldbox.system.cache.providers.CacheBoxProvider",
							properties : { maxObjects : 100, evictionPolicy : "FIFO" }
						}
					}
				} );
				expect( cacheBox ).toBeInstanceOf( "CacheFactory" );
				expect( cachebox.getDefaultCache() ).toBeComponent();
				expect( cachebox.getDefaultCache().getConfiguration().objectStore ).toBe( "ConcurrentStore" );
				expect( cachebox.getCache( "sampleCache1" ) ).toBeComponent();
				expect( cachebox.getCache( "sampleCache2" ) ).toBeComponent();
			} );
		} );
	}

}
