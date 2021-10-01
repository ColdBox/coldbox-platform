/**
 * My BDD Test
 */
component extends="coldbox.system.testing.BaseModelTest" {

	function run( testResults, testBox ){
		describe( "LogBox Service", function(){
			beforeEach( function( currentSpec ){
				logbox = createMock( "coldbox.system.logging.LogBox" );

				config = new coldbox.system.logging.config.LogBoxConfig();

				// Appenders
				config
					.appender( name = "luis", class = "coldbox.system.logging.appenders.ConsoleAppender" )
					.appender( name = "luis2", class = "coldbox.system.logging.appenders.ConsoleAppender" )
					.root( appenders = "luis,luis2" )
					// Sample categories
					.OFF( "coldbox.system" )
					.debug( "coldbox.system.async" );

				// init logBox
				logBox.init( config );

				// add this configuration after the fact to test another code path
				config.category( name = "coldbox.system.web", appenders = "*" );
			} );

			it( "can add new appenders after config has been registered", function(){
				var config = logBox.getConfig();

				config.appender(
					name : "postInitAppender",
					class= "coldbox.system.logging.appenders.ConsoleAppender"
				);
				config.category( name: "postInitLogger", appenders: "postInitAppender" );

				logBox.getLogger( "postInitLogger" ).info( "My Test" ); // Fails if appender was not added to internal registry
			} );

			describe( "can retrieve loggers with different category names", function(){
				given( "A valid category inheritance trail that is turned off", function(){
					then( "it will retrieve the inherited category", function(){
						var logger = logBox.getLogger( "coldbox.system.core" );
						expect( logger.getRootLogger().getCategory() ).toBe( "coldbox.system" );
						expect( logger.getLevelMin() ).toBe( logger.logLevels.OFF );
					} );
				} );

				given( "Non registered category", function(){
					then( "it will retrieve the root logger", function(){
						var logger = logBox.getLogger( "MyCat" );
						logger.debug( "My Test" );
						expect( logger.getRootLogger().getCategory() ).toBe( "ROOT" );
					} );
				} );

				given( "A valid category inheritance trail", function(){
					then( "it will retrieve the inherited category", function(){
						var logger = logBox.getLogger( "coldbox.system.async.AsyncManager" );
						expect( logger.getLevelMax() ).toBe( logger.logLevels.DEBUG );
						expect( logger.getRootLogger().getCategory() ).toBe( "coldbox.system.async" );
					} );
				} );
			} );

			it( "can get the root logger", function(){
				var logger = logbox.getRootLogger();
				logger.info( "test" );
			} );

			it( "can locate category parent loggers", function(){
				makePublic( logbox, "locateCategoryParentLogger" );
				// 1: root logger
				expect( logBox.locateCategoryParentLogger( "invalid" ) ).toBe( logBox.getRootLogger() );

				// 2: Expecting a logger with debug levels only
				var logger = logBox.locateCategoryParentLogger( "coldbox.system.async.AsyncManager" );
				expect( logger.getLevelMax(), logger.logLevels.DEBUG );

				// 3: Expecting an OFF logger
				var logger = logBox.locateCategoryParentLogger( "coldbox.system.core" );
				expect( logger.getLevelMin(), logger.logLevels.OFF );

				// 4: Expecting all appenders
				var logger = logBox.locateCategoryParentLogger( "coldbox.system.web.Controller" );
				expect( logger.getAppenders().count(), 2 );
			} );
		} );
	}

}
