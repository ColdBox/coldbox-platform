/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Console Appender
 */
component accessors="true" extends="coldbox.system.logging.AbstractAppender" {

	/**
	 * The default lock name
	 */
	property name="lockName";

	/**
	 * The default lock timeout
	 */
	property
		name   ="lockTimeout"
		default="25"
		type   ="numeric";

	/**
	 * Log Listener Queue
	 */
	property name="logListener" type="struct";

	/**
	 * Constructor
	 *
	 * @name The unique name for this appender.
	 * @properties A map of configuration properties for the appender"
	 * @layout The layout class to use in this appender for custom message rendering.
	 * @levelMin The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN
	 * @levelMax The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARN
	 */
	function init(
		required name,
		struct properties = {},
		layout            = "",
		levelMin          = 0,
		levelMax          = 4
	){
		super.init( argumentCollection = arguments );

		// Output Streams
		variables.out   = createObject( "java", "java.lang.System" ).out;
		variables.error = createObject( "java", "java.lang.System" ).err;

		// lock information
		variables.lockName    = getHash() & getName() & "logOperation";
		variables.lockTimeout = 25;

		// Activate Log Listener Queue
		variables.logListener = { active : false, queue : [] };

		return this;
	}


	/**
	 * Write an entry into the appender.
	 *
	 * @logEvent The logging event to log
	 */
	function logMessage( required coldbox.system.logging.LogEvent logEvent ){
		var loge      = arguments.logEvent;
		var timestamp = loge.getTimestamp();
		var message   = loge.getMessage();
		var entry     = "";

		// Message Layout
		if ( hasCustomLayout() ) {
			entry = getCustomLayout().format( loge );
		} else {
			// Cleanup main message
			if ( len( loge.getExtraInfoAsString() ) ) {
				message &= " ExtraInfo: " & loge.getExtraInfoAsString();
			}

			// Entry string
			entry = "#dateFormat( timestamp, "yyyy-mm-dd" )# #timeFormat( timestamp, "HH:MM:SS" )# #loge.getCategory()# #message#";
		}

		// Log it
		switch ( logEvent.getSeverity() ) {
			// Fatal + Error go to error stream
			case "0":
			case "1": {
				// log message
				append( message = entry, isError = true );
				break;
			}
			// Warning and above go to info stream
			default: {
				// log message
				append( message = entry, isError = false );
				break;
			}
		}

		return this;
	}

	/**
	 * Start the log listener so we can queue up the logging
	 */
	function startLogListener(){
		// Double lock to ensure thread isn't already requested
		var isActive = variables.lock( "readonly", function(){
			return variables.logListener.active;
		} );

		// if no thread is active, enter exclusive lock and start one.
		if ( !isActive ) {
			variables.lock( "exclusive", function(){
				if ( !variables.logListener.active ) {
					this.out( "ConsoleAppender ScheduleTask needs to be started..." );
					variables.logListener.active = true;
					// Create the runnable Log Listener, Start it up baby!
					variables.logBox
						.getTaskScheduler()
						.schedule(
							task           = this,
							method         = "runLogListener",
							loadAppContext = false
						);
					this.out( "ConsoleAppender ScheduleTask started" );
				}
			} );
		}
	}

	/**
	 * This function runs the log listener implementation, usually called async via a runnable class
	 */
	function runLogListener(){
		try {
			var lastRun       = getTickCount();
			var start         = lastRun;
			var maxIdle       = 15000; // 15 seconds is how long the threads can live for.
			var sleepInterval = 25;
			var count         = 0;
			var hasMessages   = false;

			this.out( "Starting #getName()# runnable", true );

			while ( variables.logListener.queue.len() || lastRun + maxIdle > getTickCount() ) {
				// this.out( "len: #variables.logListener.queue.len()# last run: #lastRun# idle: #maxIdle#" );

				if ( variables.logListener.queue.len() ) {
					// pop and dequeue
					var thisMessage = variables.logListener.queue[ 1 ];
					variables.logListener.queue.deleteAt( 1 );

					this.out( "writing #thisMessage.toString()#" );

					if ( thisMessage.isError ) {
						variables.error.println( thisMessage.message );
					} else {
						variables.out.println( thisMessage.message );
					}

					// Mark the last run
					lastRun = getTickCount();
				}

				// this.out( "Sleeping: lastRun #lastRun + maxIdle#" );

				sleep( sleepInterval ); // take a nap
			}
		} catch ( Any e ) {
			$log( "ERROR", "Error processing log listener: #e.message# #e.detail# #e.stacktrace#" );
			this.err( "Error with listener thread for #getName()#" & e.message & e.detail );
			this.err( e.stackTrace );
		} finally {
			this.out(
				"Stopping ConsoleAppender listener thread for #getName()#, it ran for #getTickCount() - start#ms!"
			);

			// Stop log listener
			variables.lock(
				body = function(){
					variables.logListener.active = false;
				}
			);
		}
	}

	/************************************ PRIVATE ************************************/

	/**
	 * Append a message to the log file
	 *
	 * @message The target message
	 * @isError Does this go to the error stream?
	 */
	private ConsoleAppender function append( required message, required isError ){
		// Ensure log listener
		startLogListener();

		// queue message up
		variables.logListener.queue.append( {
			message : arguments.message,
			isError : arguments.isError
		} );

		return this;
	}

}
