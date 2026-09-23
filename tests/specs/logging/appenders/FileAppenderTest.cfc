/**
 * My BDD Test
 */
component extends="coldbox.system.testing.BaseModelTest" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		super.beforeAll();

		var dirPath = expandPath( "/tests/logs" )
		if ( directoryExists( dirPath ) ) {
			try {
				directoryDelete( dirPath, true )
			} catch ( any e ) {
				// If deletion fails, attempt to delete individual files first
				try {
					var files = directoryList( dirPath, false, "query" )
					for ( var file in files ) {
						if ( file.type == "File" ) {
							fileDelete( dirPath & "/" & file.name )
						}
					}
					// Retry directory deletion
					directoryDelete( dirPath, true )
				} catch ( any retry ) {
					writeDump(
						var    = "Warning: Could not fully clean test logs directory: #retry.message#",
						output = "console"
					);
				}
			}
		}

		variables.props = {
			filePath   : expandPath( "/tests/logs" ),
			autoExpand : false
		}
		// debug(props);
		variables.logBox       = new coldbox.system.logging.LogBox()
		variables.fileappender = createMock( "coldbox.system.logging.appenders.FileAppender" ).setLogBox( logBox )

		variables.fileappender.init( "MyFileAppender", props )

		variables.loge = createMock( "coldbox.system.logging.LogEvent" )
		variables.loge.init( "Unit Test Sample", 0, "", "UnitTest" )
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
				writeDump( var = "Sleeping for 5 seconds waiting for log file...", output = "console" );
				sleep( 5000 );

				var content = fileRead( fileAppender.getLogFullPath() );
				expect( content ).toInclude( "Unit Test Sample" );
			} );
		} );
	}

}
