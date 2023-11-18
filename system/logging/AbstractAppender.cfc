/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This component is used as a base for creating LogBox appenders
 */
component accessors="true" {

	/**
	 * Min logging level
	 */
	property name="levelMin" type="numeric";

	/**
	 * Max logging level
	 */
	property name="levelMax" type="numeric";

	/**
	 * Appender properties
	 */
	property name="properties" type="struct";

	/**
	 * Appender name
	 */
	property name="name" default="";

	/**
	 * Appender initialized flag
	 */
	property
		name   ="initialized"
		type   ="boolean"
		default="false";

	/**
	 * Appender customLayout for rendering messages
	 */
	property name="customLayout";

	/**
	 * ColdBox Controller Linkage, empty if in standalone mode.
	 */
	property name="coldbox";

	/**
	 * WireBox Linkage, empty if in standalone mode.
	 */
	property name="wirebox";

	/**
	 * Reference back to the running LogBox instance
	 */
	property name="logBox";

	/**
	 * Default lock timeout if using the base `lock()` method
	 */
	property
		name   ="lockTimeout"
		default="25"
		type   ="numeric";

	/**
	 * A base Log Listener Queue
	 */
	property name="logListener" type="struct";

	/****************************************************************
	 * Static Variables *
	 ****************************************************************/

	// The log levels enum as a public property
	this.logLevels   = new coldbox.system.logging.LogLevels();
	// Java System
	variables.system = createObject( "java", "java.lang.System" );

	/****************************************************************
	 * Methods *
	 ****************************************************************/

	/**
	 * Constructor
	 *
	 * @name       The unique name for this appender.
	 * @properties A map of configuration properties for the appender"
	 * @layout     The layout class to use in this appender for custom message rendering.
	 * @levelMin   The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN
	 * @levelMax   The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARN
	 */
	function init(
		required name,
		struct properties = {},
		layout            = "",
		levelMin          = 0,
		levelMax          = 4
	){
		// Appender Unique ID */
		variables._hash        = createUUID();
		// Flag denoting if the appender is inited or not. This will be set by LogBox upon successful creation and registration.
		variables.initialized  = false;
		// Appender's Name
		variables.name         = reReplaceNoCase( arguments.name, "[^0-9a-z]", "", "ALL" );
		// Set internal properties
		variables.properties   = arguments.properties;
		// Custom Renderer For Messages
		variables.customLayout = "";
		if ( len( trim( arguments.layout ) ) ) {
			variables.customLayout = createObject( "component", arguments.layout ).init( this );
		}

		// Levels
		variables.levelMin = arguments.levelMin;
		variables.levelMax = arguments.levelMax;

		// lock information
		variables.lockTimeout = 25;

		// Activate Log Listener Queue
		variables.logListener = { "active" : false, "queue" : [] };

		return this;
	}

	/**
	 * --------------------------------------------------------------------------
	 * Apender Life-Cycle Methods
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Runs after the appender has been created and registered. Implemented by Concrete appenders ONLY
	 */
	AbstractAppender function onRegistration(){
		return this;
	}

	/**
	 * Runs before the appender is unregistered from LogBox. Implemented by Concrete appenders ONLY
	 */
	AbstractAppender function onUnRegistration(){
		return this;
	}

	/**
	 * Each appender can shut itself down if needed. This callback is done by the LogBox engine during reinits or shutdowns
	 */
	AbstractAppender function shutdown(){
		return this;
	}

	/**
	 * --------------------------------------------------------------------------
	 * Log Methods
	 * --------------------------------------------------------------------------
	 * These methods are the ones that are called by the LogBox engine to log messages
	 */

	/**
	 * Write an entry into the appender. You must implement this method yourself.
	 *
	 * @logEvent The logging event to log
	 *
	 * @return AbstractAppender
	 */
	AbstractAppender function logMessage( required coldbox.system.logging.LogEvent logEvent ){
		return this;
	}

	/**
	 * Checks wether a log can be made on this appender using a passed in level
	 *
	 * @level The level to check
	 *
	 * @return If the log can be made using the passed in level
	 */
	boolean function canLog( required numeric level ){
		return ( arguments.level GTE getLevelMin() AND arguments.level LTE getLevelMax() );
	}

	/**
	 * --------------------------------------------------------------------------
	 * Utility Methods
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Setter for level min
	 *
	 * @levelMin The minimum level to log
	 *
	 * @throws AbstractAppender.InvalidLogLevelException
	 */
	AbstractAppender function setLevelMin( required levelMin ){
		// Verify level
		if ( this.logLevels.isLevelValid( arguments.levelMin ) AND arguments.levelMin lte getLevelMax() ) {
			variables.levelMin = arguments.levelMin;
			return this;
		} else {
			throw(
				message = "Invalid Log Level",
				detail  = "The log level #arguments.levelMin# is invalid or greater than the levelMax (#getLevelMax()#). Valid log levels are from 0 to 5",
				type    = "AbstractAppender.InvalidLogLevelException"
			);
		}
	}

	/**
	 * Setter for level max
	 *
	 * @levelMax The maximum level to log
	 *
	 * @throws AbstractAppender.InvalidLogLevelException
	 */
	AbstractAppender function setLevelMax( required levelMax ){
		// Verify level
		if ( this.logLevels.isLevelValid( arguments.levelMax ) AND arguments.levelMax gte getLevelMin() ) {
			variables.levelMax = arguments.levelMax;
			return this;
		} else {
			throw(
				message = "Invalid Log Level",
				detail  = "The log level #arguments.levelMax# is invalid or less than the levelMin (#getLevelMin()#). Valid log levels are from 0 to 5",
				type    = "AbstractAppender.InvalidLogLevelException"
			);
		}
	}

	/**
	 * Verify if we have a custom layout object linked
	 */
	boolean function hasCustomLayout(){
		return isObject( variables.customLayout );
	}

	/**
	 * convert a severity to a string
	 *
	 * @severity The severity to convert to a string
	 *
	 * @return The string representation of the severity
	 */
	function severityToString( required numeric severity ){
		return this.logLevels.lookup( arguments.severity );
	}

	/**
	 * Get internal hash id for this appender
	 */
	function getHash(){
		return variables._hash;
	}

	/**
	 * Is appender initialized
	 */
	boolean function isInitialized(){
		return variables.initialized;
	}

	/**
	 * Get a property from the `properties` struct
	 *
	 * @property     The property key
	 * @defaultValue The default value to use if not found.
	 */
	function getProperty( required property, defaultValue ){
		if ( variables.properties.keyExists( arguments.property ) ) {
			return variables.properties[ arguments.property ];
		} else if ( !isNull( arguments.defaultValue ) ) {
			return arguments.defaultValue;
		}
	}

	/**
	 * Set a property from the `properties` struct
	 *
	 * @property The property key
	 * @value    The value of the property
	 */
	AbstractAppender function setProperty( required property, required value ){
		variables.properties[ arguments.property ] = arguments.value;
		return this;
	}

	/**
	 * Validate a property from the `properties` struct
	 *
	 * @property The property key
	 */
	boolean function propertyExists( required property ){
		return structKeyExists( variables.properties, arguments.property );
	}

	/**
	 * --------------------------------------------------------------------------
	 * Log Listener and Processing Queues
	 * --------------------------------------------------------------------------
	 * We have a concept of a global log listener that sends messages
	 * to messaging queue which is processed by the appender asynchronously.
	 */

	/**
	 * Start the log listener so we can queue up the logging
	 */
	function startLogListener(){
		// Double lock to ensure thread isn't already requested
		var isActive = variables.lock( function(){
			return variables.logListener.active;
		}, "readonly" );

		// if no thread is active, enter exclusive lock and start one.
		if ( !isActive ) {
			variables.lock( function(){
				if ( !variables.logListener.active ) {
					// Create the runnable Log Listener, Start it up baby!
					try {
						variables.logBox
							.getTaskScheduler()
							.schedule(
								task           = this,
								method         = "runLogListener",
								loadAppContext = false
							);

						// Mark listener as activated
						// out( "(#getName()#) ScheduleTask needs to be started..." );
						variables.logListener.active = true;
					} catch ( any e ) {
						// Just in case it doesn't start, just skip it for now and let another thread
						// kick start it.  We will just log the exception just in case
						// Usually these exceptions can be on shutdowns or when the scheduler cannot take
						// any more tasks.
						out( "Error scheduling log listener: #e.message# #e.detail#" );
					}

					// out( "(#getName()#) ScheduleTask started" );
				}
			} );
		}
	}

	/**
	 * Executed by our schedule tasks to move the queue elements into the appender's implemented
	 * destination
	 *
	 * @force This forces a flush with no waiting, usually called synchronously by a shutdown
	 */
	function runLogListener( force = false ){
		try {
			// Create a queue context for queue processing data
			var queueContext = {
				"lastRun"       : getTickCount(),
				"start"         : getTickCount(),
				"maxIdle"       : 10000, // 10 seconds of idle time
				"sleepInterval" : 25, // 25ms of sleep time
				"count"         : 0,
				"force"         : arguments.force
			};

			// Init Message
			// out( "- Starting (#getName()#) log listener with max life of #queueContext.maxIdle#ms", true );

			// Start Advice
			onLogListenerStart( queueContext );

			// Keep running :
			// - Are forcing the run
			// - We have messages in the queue
			// - We have been not been idle for more than maxIdle
			while (
				arguments.force ||
				variables.logListener.queue.len() ||
				queueContext.lastRun + queueContext.maxIdle > getTickCount()
			) {
				// out( "len: #variables.logListener.queue.len()# last run: #lastRun# idle: #queueContext.maxIdle#" );

				preProcessQueue( variables.logListener.queue, queueContext );

				// Process the queue if we have any messages
				if ( variables.logListener.queue.len() ) {
					// pop and dequeue
					var thisData = variables.logListener.queue.first();
					variables.logListener.queue.deleteAt( 1 );

					// out( "=============> processing #thisData.toString()#" );

					processQueueElement(
						thisData,
						queueContext,
						variables.logListener.queue
					);

					// Mark the last run
					queueContext.lastRun = getTickCount();
				}

				// out( "Sleeping (#getName()#): lastRun #queueContext.lastRun + queueContext.maxIdle#" );

				// Advice we are about to go to sleep
				onLogListenerSleep( queueContext );

				// Only take a nap if we've nothing to do and we are not in force mode
				// So we can wait for more messages
				if ( !arguments.force && !variables.logListener.queue.len() ) {
					sleep( queueContext.sleepInterval ); // take a nap
				}

				postProcessQueue( variables.logListener.queue, queueContext );
			}
		} catch ( Any e ) {
			if ( e.message contains "interrupted" ) {
				// Ignore interruptions, it's just the thread pool being shutdown cleanly
			} else {
				// send to CF logging
				$log( "ERROR", "Error processing log listener: #e.message# #e.detail# #e.stacktrace#" );
				// send to standard error out
				variables.err( "Error with log listener thread for #getName()#: " & e.message & e.detail );
				variables.err( e.stackTrace );
			}
		} finally {
			// End Advice
			onLogListenerEnd( queueContext );

			// Advice
			// out( "Stopping Log listener task for (#getName()#), it ran for #getTickCount() - queueContext.start#ms!" );

			// Stop log listener only if not in force mode
			if ( !arguments.force ) {
				variables.lock( () => {
					variables.logListener.active = false;
				} );
			}
		}
	}

	/**
	 * --------------------------------------------------------------------------
	 * Log Listener & Queue Events
	 * --------------------------------------------------------------------------
	 * These events are to be implemented by the appropriate appender
	 * in order to process the logging queue.
	 */

	/**
	 * Fired once the listener starts queue processing. This only runs
	 * once per listener thread.  Remember that the listener thread is
	 * created, then destroyed after the queue is empty or after a timeout.
	 *
	 * @queueContext A struct of data attached to this processing queue thread
	 */
	function onLogListenerStart( required struct queueContext ){
	}

	/**
	 * Fired once the listener will go to sleep. This happens
	 * when the queue is empty and the listener will sleep for a while
	 * to wait for more messages.
	 *
	 * @queueContext A struct of data attached to this processing queue thread
	 */
	function onLogListenerSleep( required struct queueContext ){
	}

	/**
	 * Fired once the listener stops queue processing.
	 * This happens when there are no more messages in the queue
	 * or when the queue has been idle for a while.
	 *
	 * @queueContext A struct of data attached to this processing queue thread
	 */
	function onLogListenerEnd( required struct queueContext ){
	}

	/**
	 *  Fired before the queue is processed within the log listener thread
	 *
	 * @queue        The queue itself
	 * @queueContext A struct of data attached to this processing queue thread
	 */
	function preProcessQueue( required queue, required struct queueContext ){
	}

	/**
	 *  Fired after the queue is processed within the log listener thread
	 *
	 * @queue        The queue itself
	 * @queueContext A struct of data attached to this processing queue thread
	 */
	function postProcessQueue( required queue, required struct queueContext ){
	}

	/**
	 * --------------------------------------------------------------------------
	 * Queuing Helpers
	 * --------------------------------------------------------------------------
	 * The processQueueElement can be implemented by the appender to process the queue
	 * The queueMessage() method is used to queue up messages to the appender instead
	 * of logging directly.
	 */

	/**
	 * Processes a queue element to a destination
	 * This method is called by the log listeners asynchronously.
	 *
	 * @data         The data element the queue needs processing
	 * @queueContext The queue context in process
	 * @queue        The queue itself
	 *
	 * @return The appender
	 */
	function processQueueElement(
		required data,
		required queueContext,
		required queue
	){
		variables.out( arguments.data.toString() );
		return this;
	}

	/**
	 * Appends a data struct into the logging array queue so the log listeners can deliver it
	 * to the destination. This is a NON-Blocking operation
	 *
	 * The appender has the option from the <code>logMessage()</code>
	 * to decide if they log directly or queue up the message for later
	 * processing.
	 *
	 * Example:
	 * <pre><code>
	 * function logMessage( required logEvent ){
	 * 	// Log it
	 *	switch ( logEvent.getSeverity() ) {
	 *		// Fatal + Error go to error stream
	 *		case "0":
	 *		case "1": {
	 *			// log message
	 *			queueMessage( { message : entry, isError : true } );
	 *			break;
	 *		}
	 *		// Warning and above go to info stream
	 *		default: {
	 *			// log message
	 *			queueMessage( { message : entry, isError : false } );
	 *			break;
	 *		}
	 *	 }
	 * }
	 * </code></pre>
	 *
	 * @data The data to be queued up
	 *
	 * @return The appender
	 */
	AbstractAppender function queueMessage( required data ){
		// Ensure log listener
		startLogListener();
		// Queue it up
		variables.logListener.queue.append( arguments.data );
		return this;
	}

	/**
	 * A functional locking wrapper for the appender which uses it's internal hash and name as the lock name
	 *
	 * @body The function/closure/lambda to wrap under a lock call
	 * @type The lock type. Exclusive or readonly. Defaults to exclusive if not passed
	 *
	 * @return The return of the arguments.body() call
	 */
	public function lock( required body, type = "exclusive" ){
		lock
			name          ="#getHash() & getName()#-logListener"
			type          =arguments.type
			timeout       ="#variables.lockTimeout#"
			throwOnTimeout=true {
			return arguments.body();
		}
	}

	/****************************************** PRIVATE *********************************************/

	/**
	 * Get the ColdBox Utility object
	 */
	private function getUtil(){
		if ( structKeyExists( variables, "util" ) ) {
			return variables.util;
		}
		variables.util = new coldbox.system.core.util.Util();
		return variables.util;
	}

	/**
	 * Facade to internal ColdFusion logging facilities, just in case.
	 *
	 * @severity The severity of the message
	 * @message  The message to log
	 */
	private AbstractAppender function $log( required severity, required message ){
		cflog(
			type = arguments.severity,
			file = "LogBox",
			text = arguments.message
		);
		return this;
	}

	/**
	 * Utility to send to output to the output stream.
	 *
	 * @message Message to send
	 */
	private function out( required message ){
		variables.System.out.println( arguments.message.toString() );
	}

	/**
	 * Utility to send to output to the error stream.
	 *
	 * @message Message to send
	 */
	private function err( required message ){
		variables.System.err.println( arguments.message.toString() );
	}

}
