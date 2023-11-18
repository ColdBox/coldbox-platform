/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * An appender that leverages the OS file system
 *
 * Properties:
 * - filepath     : The location of where to store the log file.
 * - autoExpand   : Whether to expand the file path or not. Defaults to true.
 * - filename     : The name of the file, if not defined, then it will use the name of this appender. Do not append an extension to it. We will append a .log to it.
 * - fileEncoding : The file encoding to use, by default we use ISO-8859-1;
 **/
component accessors="true" extends="coldbox.system.logging.AbstractAppender" {

	/**
	 * The log file location
	 */
	property name="logFullpath";

	/**
	 * Constructor
	 *
	 * @name       The unique name for this appender.
	 * @properties A map of configuration properties for the appender"
	 * @layout     The layout class to use in this appender for custom message rendering.
	 * @levelMin   The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN
	 * @levelMax   The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARN
	 *
	 * @throws FileAppender.PropertyNotFound
	 */
	function init(
		required name,
		struct properties = {},
		layout            = "",
		levelMin          = 0,
		levelMax          = 4
	){
		super.init( argumentCollection = arguments );

		// Setup Properties
		if ( NOT propertyExists( "filepath" ) ) {
			throw( message = "Filepath property not defined", type = "FileAppender.PropertyNotFound" );
		}
		if ( NOT propertyExists( "autoExpand" ) ) {
			setProperty( "autoExpand", true );
		}
		if ( NOT propertyExists( "filename" ) ) {
			setProperty( "filename", getName() );
		}
		if ( NOT propertyExists( "fileEncoding" ) ) {
			setProperty( "fileEncoding", "ISO-8859-1" );
		}
		// Cleanup File Names
		setProperty(
			"filename",
			reReplaceNoCase(
				getProperty( "filename" ),
				"[^0-9a-z]",
				"",
				"ALL"
			)
		);

		// Setup the log file full path
		variables.logFullpath = getProperty( "filePath" );
		// Clean ending slash
		variables.logFullPath = reReplaceNoCase( variables.logFullPath, "[/\\]$", "" );
		// Concatenate Full Log path
		variables.logFullPath = variables.logFullpath & "/" & getProperty( "filename" ) & ".log";

		// Do we expand the path?
		if ( getProperty( "autoExpand" ) ) {
			variables.logFullPath = expandPath( variables.logFullpath );
		}

		return this;
	}

	/**
	 * Called upon registration
	 */
	FileAppender function onRegistration(){
		// Init the log location
		initLogLocation();

		return this;
	}

	/**
	 * Write an entry into the appender. You must implement this method yourself.
	 *
	 * @logEvent The logging event to log
	 */
	function logMessage( required coldbox.system.logging.LogEvent logEvent ){
		var timestamp = arguments.logEvent.getTimestamp();
		var message   = arguments.logEvent.getMessage();
		var entry     = "";

		// Message Layout
		if ( hasCustomLayout() ) {
			entry = getCustomLayout().format( arguments.logEvent );
		} else {
			if ( len( arguments.logEvent.getExtraInfoAsString() ) ) {
				message &= " | ExtraInfo:" & arguments.logEvent.getExtraInfoAsString();
			}
			message = replace( message, """", """""", "all" );
			message = replace( message, "#chr( 13 )##chr( 10 )#", "  ", "all" );
			message = replace( message, chr( 13 ), "  ", "all" );

			// Entry string
			entry = """#severityToString( logEvent.getSeverity() )#"",""#getname()#"",""#dateFormat( timestamp, "mm/dd/yyyy" )#"",""#timeFormat( timestamp, "HH:mm:ss" )#"",""#arguments.logEvent.getCategory()#"",""#message#""";
		}

		// Queue it up
		queueMessage( entry );

		return this;
	}

	/**
	 * Remove the log file for this appender
	 * Synchronized
	 */
	FileAppender function removeLogFile(){
		if ( fileExists( variables.logFullPath ) ) {
			variables.lock( () => {
				if ( fileExists( variables.logFullPath ) ) {
					fileDelete( variables.logFullPath );
				}
				// end double lock race condition
			} );
		}
		// end if

		return this;
	}

	/**
	 * Initialize the file log location if it does not exist. Please note that if exceptions are detected, then we log them in the CF facilities
	 * Synchronized
	 */
	FileAppender function initLogLocation(){
		if ( !fileExists( variables.logFullPath ) ) {
			variables.lock( () => {
				if ( !fileExists( variables.logFullPath ) ) {
					try {
						// Default Log Directory
						ensureDefaultLogDirectory();
						// Create log file
						fileWrite(
							variables.logFullPath,
							"""Severity"",""Appender"",""Date"",""Time"",""Category"",""Message""#chr( 13 )##chr( 10 )#"
						);
					} catch ( Any e ) {
						$log(
							"ERROR",
							"Cannot create appender's: #getName()# log file. File #variables.logFullpath#. #e.message# #e.detail#"
						);
					}
				}
				// end double lock race condition
			} );
		}

		return this;
	}

	/**
	 *  Fired before the queue is processed within the log listener thread.
	 *
	 * We do this here instead of processing the queue one by one since we can accelerate it
	 * via toList() operations and fileWriteLine() operations.
	 *
	 * @queue        The queue itself
	 * @queueContext A struct of data attached to this processing queue thread
	 */
	function preProcessQueue( required queue, required struct queueContext ){
		if ( arguments.queue.len() ) {
			variables.lock( () => {
				if ( queue.len() ) {
					var oFile = fileOpen(
						variables.logFullPath,
						"append",
						this.getProperty( "fileEncoding" )
					);
					try {
						fileWriteLine( oFile, queue.toList( chr( 13 ) & chr( 10 ) ) );
					} finally {
						fileClose( oFile );
						queue.clear();
					}
				}
			} );
		}
	}

	/**
	 * Fired once the listener starts queue processing. This only runs
	 * once per listener thread.  Remember that the listener thread is
	 * created, then destroyed after the queue is empty or after a timeout.
	 *
	 * @queueContext A struct of data attached to this processing queue thread
	 */
	function onLogListenerStart( required struct queueContext ){
		// Make sure the log location exists
		initLogLocation();
	}


	/************************************ PRIVATE ************************************/

	/**
	 * Ensures the log directory.
	 */
	private function ensureDefaultLogDirectory(){
		var dirPath = getDirectoryFromPath( variables.logFullpath );

		if ( !directoryExists( dirPath ) ) {
			directoryCreate( dirPath );
		}

		return this;
	}

}
