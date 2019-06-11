/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* Console Appender
*/
component accessors="true" extends="coldbox.system.logging.AbstractAppender"{

	/**
	 * The default lock name
	 */
	property name="lockName";

	/**
	 * The default lock timeout
	 */
	property name="lockTimeout" default="25" type="numeric";

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
		struct properties={},
		layout="",
		levelMin=0,
		levelMax=4
	){
		super.init( argumentCollection=arguments );

		// Output Streams
		variables.out 	= createObject( "java", "java.lang.System" ).out;
		variables.error = createObject( "java", "java.lang.System" ).err;

		// lock information
		variables.lockName 		= getHash() & getName() & "logOperation";
		variables.lockTimeout 	= 25;

		// Activate Log Listener Queue
		variables.logListener = {
			active 	= false,
			queue 	= []
		};

		// Declare locking construct
		variables.lock = function( type="exclusive", body ){
			lock 	name="#getHash() & getName()#-logListener"
					type=arguments.type
					timeout="#variables.lockTimeout#"
					throwOnTimeout=true{

				return arguments.body();

			}
		};

		return this;
    }

    /**
	 * Write an entry into the appender.
	 *
	 * @logEvent The logging event to log
	 */
	function logMessage( required logEvent ){
		var loge      = arguments.logEvent;
		var timestamp = loge.getTimestamp();
		var message   = loge.getMessage();
		var entry     = "";

		// Message Layout
		if( hasCustomLayout() ){
			entry = getCustomLayout().format( loge );
		} else {
			// Cleanup main message
			if( len( loge.getExtraInfoAsString() ) ){
				message &= " ExtraInfo: " & loge.getExtraInfoAsString();
			}

			// Entry string
			entry = '#dateformat( timestamp, "yyyy-mm-dd" )# #timeformat( timestamp, "HH:MM:SS" )# #loge.getCategory()# #message#';
		}

		// Log it
		switch( logEvent.getSeverity() ){
			// Fatal + Error go to error stream
			case "0" : case "1" : {
				// log message
				append( message=entry, isError=true );
				break;
			}
			// Warning and above go to info stream
			default : {
				// log message
				append( message=entry, isError=false );
				break;
			}
		}

		return this;
	}

	/**
	 * Start the log listener so we can queue up the logging to alleviate for disk operations
	 */
	function startLogListener(){

		// Verify if listener has started.
		var isActive = variables.lock( "readonly", function(){
			return variables.logListener.active;
		} );

		if( isActive ){
			//out( "Listener already active exiting startup..." );
			return;
		} else {
			//out( "Listener needs to startup" );
		}

		thread  action="run" name="#variables.lockName#-#hash( createUUID() )#"{
			// Activate listener
			var isActivating = variables.lock( body=function(){
				if( !variables.logListener.active ){
					//out( "listener #getHash()# min: #getLevelMin()# max: #getLevelMax()# marked as active" );
					variables.logListener.active = true;
					return true;
				} else {
					//out( "listener was just marked as active, just existing lock" );
					return false;
				}
			} );

			if( !isActivating ){ return; }

			var lastRun       = getTickCount();
			var start         = lastRun;
			var maxIdle       = 15000; // 15 seconds is how long the threads can live for.
			var sleepInterval = 25;
			var count         = 0;
			var hasMessages   = false;

			try{
				//out( "Starting #getName()# thread", true );

				// Execute only if there are messages in the queue or the internal has been crossed
				while(
					variables.logListener.queue.len() || lastRun + maxIdle > getTickCount()
				){

					//out( "len: #variables.logListener.queue.len()# last run: #lastRun# idle: #maxIdle#" );

					if( variables.logListener.queue.len() ){
						// pop and dequeue
						var thisMessage = variables.logListener.queue[ 1 ];
						variables.logListener.queue.deleteAt( 1 );

						//out( "writing #thisMessage.toString()#" );

						if( thisMessage.isError ){
							variables.error.println( thisMessage.message );
						} else {
							variables.out.println( thisMessage.message );
						}

						// Mark the last run
						lastRun = getTickCount();
					}

					//out( "Sleeping: lastRun #lastRun + maxIdle#" );

					sleep( sleepInterval ); // take a nap
				}

			} catch( Any e ){
				$log( "ERROR", "Error processing log listener: #e.message# #e.detail# #e.stacktrace#" );
				//out( "Error with listener thread for #getName()#" & e.message & e.detail );
			} finally {
				//out( "Stopping listener thread for #getName()#, we have done our job" );

				// Stop log listener
				variables.lock( body=function(){
					variables.logListener.active = false;
				} );
			}

		} // end threading
	}

	/************************************ PRIVATE ************************************/

	/**
	 * Append a message to the log file
	 *
	 * @message The target message
	 * @isError Does this go to the error stream?
	 */
	private ConsoleAppender function append( required message, required isError ){
		// If we are not in a thread, then start the log listener, else queue it
		if( !getUtil().inThread() ){
			// Ensure log listener
			startLogListener();
		}

		// queue message up
		variables.logListener.queue.append( {
			message 	= arguments.message,
			isError 	= arguments.isError
		} );

		return this;
	}

}