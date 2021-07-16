/**
 * My BDD Test
 */
component extends="coldbox.system.testing.BaseModelTest" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		super.beforeAll();

		dirPath = expandPath( "/tests/logs" );
		if ( directoryExists( dirPath ) ) {
			directoryDelete( expandPath( "/tests/logs" ), true );
		}

		props = {
			filePath   : expandPath( "/tests/logs" ),
			autoExpand : false
		};
		// debug(props);
		logBox       = new coldbox.system.logging.LogBox();
		fileappender = createMock( "coldbox.system.logging.appenders.FileAppender" ).setLogBox( logBox );

		// mock LogBox
		logBox              = createMock( classname = "coldbox.system.logging.LogBox", clearMethod = true );
		fileAppender.logBox = logBox;

		fileappender.init( "MyFileAppender", props );

		loge = createMock( "coldbox.system.logging.LogEvent" );
		loge.init( "Unit Test Sample", 0, "", "UnitTest" );
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "File Appender", function(){
			it( "can call registration", function(){
				fileAppender.onRegistration();
			} );

			it( "can log messages", function(){
				// Log 50 messages to trigger rotation
				for ( var x = 0; x lte 5; x++ ) {
					loge.setSeverity( x );
					loge.setCategory( "coldbox.system.testing" );
					fileappender.logMessage( loge );
				}

				// sleep to let threads write to disk.
				sleep( 5000 );

				var content = fileRead( fileAppender.getLogFullPath() );
				expect( content ).toInclude( "Unit Test Sample" );
			} );
		} );
	}

}
