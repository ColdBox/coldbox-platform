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
component accessors="true" extends="coldbox.system.logging.AbstractAppender"{

	/**
	 * The log file location
	 */
	property name="logFullpath";

	/**
	 * The default lock name
	 */
	property name="lockName";

	/**
	 * The default lock timeout
	 */
	property name="lockTimeout" default="25" type="numeric";
    
    /**
	 * Constructor
	 * 
	 * @name The unique name for this appender.
	 * @properties A map of configuration properties for the appender"
	 * @layout The layout class to use in this appender for custom message rendering.
	 * @levelMin The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN
	 * @levelMax The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARN
	 * 
	 * @throws FileAppender.PropertyNotFound
	 */
	function init(
		required name,
		struct properties={},
		layout="",
		levelMin=0,
		levelMax=4
	){
		super.init( argumentCollection=arguments );

		// Setup Properties
		if( NOT propertyExists( "filepath" ) ){
			throw(
				message = "Filepath property not defined",
				type    = "FileAppender.PropertyNotFound" 
			);
		}
		if( NOT propertyExists( "autoExpand" ) ){
			setProperty( "autoExpand", true );
		}
		if( NOT propertyExists( "filename" ) ){
			setProperty( "filename", getName() );
		}
		if( NOT propertyExists( "fileEncoding" ) ){
			setProperty( "fileEncoding", "ISO-8859-1" );
		}
		// Cleanup File Names
		setProperty( "filename", REreplacenocase( getProperty( "filename" ), "[^0-9a-z]", "", "ALL" ) );

		// Setup the log file full path
		variables.logFullpath = getProperty( "filePath" );
		// Clean ending slash
		variables.logFullPath = reReplacenocase( variables.logFullPath, "[/\\]$", "" );
		// Concatenate Full Log path
		variables.logFullPath = variables.logFullpath & "/" & getProperty( "filename" ) & ".log";

		// Do we expand the path?
		if( getProperty( "autoExpand" ) ){
			variables.logFullPath = expandPath( variables.logFullpath );
		}

		// lock information
		variables.lockName 		= getHash() & getname() & "logOperation";
		variables.lockTimeout 	= 25;

		return this;
    }

    /**
	 * Write an entry into the appender. You must implement this method yourself.
	 * 
	 * @logEvent The logging event to log
	 */
	function logMessage( required coldbox.system.logging.LogEvent logEvent ){
		var loge      = arguments.logEvent;
		var timestamp = loge.getTimestamp();
		var message   = loge.getMessage();
		var entry     = "";

		// Ensure Log File
		initLogLocation();

		// Message Layout
		if( hasCustomLayout() ){
			entry = getCustomLayout().format( loge );
		} else {
			// Cleanup main message
			if( len( loge.getExtraInfoAsString() ) ){
				message = message & " " & loge.getExtraInfoAsString();
			}
			message = replace( message, '"', '""', "all" );
			message = replace( message, "#chr(13)##chr(10)#", '  ', "all" );
			message = replace( message, chr(13), '  ', "all" );
			
			// Entry string
			entry = '"#severityToString( logEvent.getSeverity() )#","#getname()#","#dateformat( timestamp, "MM/DD/YYYY" )#","#timeformat( timestamp, "HH:MM:SS" )#","#loge.getCategory()#","#message#"';
		}

		// Setup the real entry
		append( entry );

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
	 * Remove the log file for this appender
	 */
	FileAppender function removeLogFile(){
		if( fileExists( variables.logFullPath ) ){

			lock 	name="#variables.lockName#"
					type="exclusive"
					timeout="#variables.lockTimeout#"
					throwOnTimeout=true{
				
				if( fileExists( variables.logFullPath ) ){
					fileDelete( variables.logFullPath );
				} // end double lock race condition

			} // end lock

		} // end if

		return this;
	}

	/**
	 * Initialize the file log location if it does not exist. Please note that if exceptions are detected, then we log them in the CF facilities
	 */
	FileAppender function initLogLocation(){
		if( !fileExists( variables.logFullPath ) ){

			lock 	name="#variables.lockName#"
					type="exclusive"
					timeout="#variables.lockTimeout#"
					throwOnTimeout=true{
				
				if( !fileExists( variables.logFullPath ) ){
					try{
						// Default Log Directory
						ensureDefaultLogDirectory();
						// Create log file
						append( '"Severity","Appender","Date","Time","Category","Message"' );
					} catch( Any e ) {
						$log( "ERROR", "Cannot create appender's: #getName()# log file. File #variables.logFullpath#. #e.message# #e.detail#" );
					}
				} // end double lock race condition

			} // end lock

		}

		return this;
	}
	
	/************************************ PRIVATE ************************************/

	/**
	 * Append a message to the log file
	 *
	 * @message The target message
	 */
	private FileAppender function append( required message ){
		lock 	name="#variables.lockName#"
				type="exclusive"
				timeout="#variables.lockTimeout#"
				throwOnTimeout=true{
			
			cffile( 
				action     = "append",
				file 	   = variables.logFullPath,
				output 	   = arguments.message,
				addNewLine = true,
				charset    = getProperty( "fileEncoding" ),
				fixnewline = true
			);

		}

		return this;
	}

	/**
	 * Ensures the log directory.
	 */
	private function ensureDefaultLogDirectory(){
		var dirPath = getDirectoryFrompath( variables.logFullpath );

		if( !directoryExists( dirPath ) ){
			directoryCreate( dirPath );
		}

		return this;
	}

}