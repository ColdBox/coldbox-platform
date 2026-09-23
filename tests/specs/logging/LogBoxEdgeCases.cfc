/**
 * My BDD Test
 */
component extends="testbox.system.BaseSpec" {

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "LogBox edge cases", function(){
			story( "I want to load LogBox with no appenders", function(){
				given( "No appenders", function(){
					then( "I can start LogBox", function(){
						var config = new coldbox.system.logging.config.LogBoxConfig();
						var logbox = new coldbox.system.logging.LogBox( config );

						var logger = logBox.getLogger( "MyCat" );
						expect( logger ).toBeComponent();
						// if we run then we are ok, we can log with no appenders
						logger.info( "Test" );
					} );
				} );
			} );

			story( "I want to verify LogBox survives appender constructor triggering logger access during configure", function(){
				given( "A custom appender whose onRegistration() calls getRootLogger()", function(){
					then( "it should construct without KeyNotFoundException", function(){
						var config = {
							appenders : {
								sentinelAppender : {
									class      : "tests.specs.logging.appenders.SentinelTestAppender",
									properties : {},
									levelMin   : 0,
									levelMax   : 4
								}
							},
							root : { levelMax : "INFO", appenders : "sentinelAppender" }
						};

						// This constructor calls configure() which triggers registerAppender,
						// which chains onRegistration() which calls getRootLogger().
						// Without the sentinel fix, this throws KeyNotFoundException.
						var logBox = new coldbox.system.logging.LogBox( config );

						// Verify getRootLogger returns a real Logger after construction
						var root = logBox.getRootLogger();
						expect( root ).toBeComponent();
						expect( root.getCategory() ).toBe( "ROOT" );

						// Verify the sentinel appender captured a non-null root logger
						var appender = logBox.getAppenderRegistry()[ "sentinelAppender" ];
						expect( appender.getCapturedRootLogger() ).toBeComponent();
					} );
				} );
			} );

			story( "I want to re-configure LogBox and verify getRootLogger never returns empty", function(){
				given( "An already-constructed LogBox", function(){
					then( "calling configure() again should not break getRootLogger()", function(){
						var config = {
							appenders : {
								consoleAppender : {
									class      : "ConsoleAppender",
									properties : {},
									levelMin   : 0,
									levelMax   : 4
								}
							},
							root : { levelMax : "INFO", appenders : "consoleAppender" }
						};

						var logBox = new coldbox.system.logging.LogBox( config );
						expect( logBox.getRootLogger() ).toBeComponent();

						// Re-configure: this resets registries and re-runs the appender loop.
						// The sentinel root must be in place during the entire re-configure.
						logBox.configure( config );

						expect( logBox.getRootLogger() ).toBeComponent();
						expect( logBox.getRootLogger().getCategory() ).toBe( "ROOT" );
					} );
				} );
			} );

			story( "I want getRootLogger() to have a defensive fallback when registry is empty", function(){
				given( "A LogBox with the ROOT key manually removed from its loggerRegistry", function(){
					then( "it should return a transient Logger instead of throwing", function(){
						var config = new coldbox.system.logging.config.LogBoxConfig();
						var logBox = new coldbox.system.logging.LogBox( config );

						// Simulate a corrupt/empty registry state (extreme edge case)
						structDelete( logBox.getLoggerRegistry(), "ROOT" );

						// Should return a Logger, not throw KeyNotFoundException
						var root = logBox.getRootLogger();
						expect( root ).toBeComponent();
						expect( root.getCategory() ).toBe( "ROOT" );
					} );
				} );
			} );
		} );
	}

}
