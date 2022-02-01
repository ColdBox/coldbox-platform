/**
 * My BDD Test
 */
component extends="testbox.system.BaseSpec" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "CacheBox Standalone", function(){
			it( "can be configured with a standalone configuration object", function(){
				cacheBox = new coldbox.system.cache.CacheFactory(
					config = "tests.resources.StandaloneCacheBoxConfig"
				);
				expect( cachebox.getCache( "standalone" ) ).toBeComponent();
			} );

			it( "can be configured with a LogBox Config object", function(){
				cacheBox = new coldbox.system.cache.CacheFactory(
					config = "tests.resources.StandaloneCacheBoxConfig"
				);
				var appenders = cacheBox
					.getLogBox()
					.getConfig()
					.getAllAppenders();
				expect( appenders ).toHaveKey( "Scope" );
			} );

			it( "can be configured with a Sample Configuration", function(){
				cacheBox = new coldbox.system.cache.CacheFactory( config = "tests.resources.SampleCacheBox" );
				expect( cacheBox.cacheExists( "sampleCache1" ) ).toBeTrue();
				expect( cacheBox.cacheExists( "sampleCache2" ) ).toBeTrue();
			} );
		} );
	}

}
