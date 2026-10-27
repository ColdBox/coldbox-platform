/**
 * Test appender for driving the FileAppender log listener in the test thread.
 * queueMessage() only queues (no background listener is scheduled), and a direct
 * runLogListener() call returns as soon as the queue is empty instead of idling.
 */
component extends="coldbox.system.logging.appenders.FileAppender" {

	/**
	 * Do not schedule a background listener, the spec calls runLogListener() itself.
	 */
	function startLogListener(){
	}

	/**
	 * End the listener loop as soon as the queue is empty.
	 *
	 * @queueContext A struct of data attached to this processing queue thread
	 */
	function onLogListenerSleep( required struct queueContext ){
		arguments.queueContext.maxIdle = 0
	}

	/**
	 * How many entries are still waiting in the appender's own queue.
	 */
	numeric function pending(){
		return variables.logListener.queue.len()
	}

}
