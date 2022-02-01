/**
 * My BDD Test
 */
component extends="coldbox.system.testing.BaseModelTest" {

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

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Rolling File Appender", function(){
			beforeEach( function( currentSpec ){
				logBox = new coldbox.system.logging.LogBox();
				props  = {
					filePath        : expandPath( "/tests/logs" ),
					autoExpand      : false,
					fileMaxArchives : 1,
					fileMaxSize     : 3
				};

				// debug(props);
				fileappender = createMock( "coldbox.system.logging.appenders.RollingFileAppender" ).setLogBox(
					logBox
				);

				// mock LogBox
				logBox              = createMock( classname = "coldbox.system.logging.LogBox", clearMethod = true );
				fileAppender.logBox = logBox;

				fileappender.init( "MyFileAppender", props );

				loge = createMock( "coldbox.system.logging.LogEvent" );
				loge.init( "Unit Test Sample", 0, "", "UnitTest" );
			} );

			it( "can call registration", function(){
				fileAppender.onRegistration();
			} );

			it( "can log messages", function(){
				// Log 50 messages to trigger rotation
				for ( var x = 0; x lte 100; x++ ) {
					loge.setSeverity( x );
					loge.setCategory( "coldbox.system.testing" );
					fileappender.logMessage( loge );
				}
				var files = directoryList( props.filePath, false, "query" );
				debug( files );
				expect( files ).notToBeEmpty();
			} );
		} );
	}

}
