/**
 * This class ingests a Java thread proxy and abstracts its usage by providing
 * a functional interface to interact with the thread and a value that the thread could potentially produce.
 */
component accessors="true"{

	/**
	 * The runnable thread it is bound to
	 */
	property name="runnable";

	/**
	 * Constructor
	 *
	 * @runnable The thread proxy it monitors
	 */
	function init( required runnable ){
		variables.runnable 		= arguments.runnable;
		variables.transformers 	= [];

		return this;
	}

	/**
	 * A transformer that is executed on the result of the thread if any.
	 * The then transformers are NEVER called unless you call the `get()` method on the Future
	 *
	 * @target A closure/lambda to execute upon the result, if any
	 */
	Future function then( target ){
		variables.transformers.append( arguments.target );
		return this;
	}

	/**
	 * This will wait/join for the Thread to finish in order to retrieve the result the thread produced.
	 * The result can be null if the thread did not produce any result
	 *
	 * @timeout Timeout in milliseconds to wait for the thread to finish, else it finishes and will act upon the default value. The default is to wait forever
	 * @defaultValue If no value is returned by the thread, or the timeout is reached, the deafult will be returned
	 */
	any function get( timeout=0, defaultValue ){
		// Block until it finishes
		variables.runnable.join( javaCast( "long", arguments.timeout ) );

		// Do we have a result for this runnable?
		if( request.keyExists( getName() ) ){
			return processTransformers( request[ getName() ] );
		}

		// Do we have a result and a default value?
		if( !request.keyExists( getName() ) && !isNull( arguments.defaultValue ) ){
			return processTransformers( arguments.defaultValue );
		}

		// Else returns null
	}

	/**
	 * Attach a closure/lambda to process exceptions within the thread.
	 * Internally, we created a Thread$UncaughtExceptionHandler and attach it to the thread for processing
	 *
	 * @target The closure/lamda that will process the exception
	 */
	Future function onError( target ){
		var oHandler = createDynamicProxy(
			new UncaughtExceptionHandler( arguments.target, this ),
			[ "java.lang.Thread$UncaughtExceptionHandler" ]
		);
		variables.runnable.setUncaughtExceptionHandler( oHandler );
		return this;
	}

	/**
	 * This will start the thread this future represents to execute in the background and return itself
	 *
	 * @priority The thread priority, we default to normal (5)
	 */
	Future function start( priority="normal" ){
		this.setPriority( arguments.priority );
		variables.runnable.start();
		return this;
	}

	/**
	 * Return the name of the Thread this Future represents
	 */
	string function getName(){
		return variables.runnable.getName();
	}

	/**
	 * Return the unique Id of the Thread this Future represents
	 */
	string function getId(){
		return variables.runnable.getId();
	}

	/**
	 * Set the priority of the running thread. You must do this BEFORE calling `start()`
	 */
	Future function setPriority( string priority ){
		switch( variables.runnable.getPriority() ){
			case "high" : local.priority = 10;break;
			case "low" 	: local.priority = 1;break;
			default 	: local.priority = 5;break;
		}
		variables.runnable.setPriority( javaCast( "int", local.priority ) );
		return this;
	}

	string function getPriority(){
		return variables.runnable.getPriority();
	}

	string function getPriorityValue(){
		switch( variables.runnable.getPriority() ){
			case 10 : return "high";
			case 5 : return "normal";
			case 1 : return "low";
		}
	}

	Future function cancel(){
		variables.runnable.interrupt();
		return this;
	}

	string function getState(){
		return variables.runnable.getState().toString();
	}

	boolean function isDone(){
		return !this.isAlive();
	}

	boolean function isAlive(){
		return variables.runnable.isAlive();
	}

	boolean function isInterrupted(){
		return variables.runnable.isInterrupted();
	}

	Future function dumpStack(){
		variables.runnable.dumpStack();
		return this;
	}

	array function getStackTrace(){
		var stack = [];
		return stack
			.append( variables.runnable.getStackTrace(), true )
			.map( function( item ){
				return item.toString();
			} );
	}

	any function getThreadGroup(){
		return variables.runnable.getThreadGroup();
	}

	function onMissingMethod( missingMethodName, missingMethodArguments ){
		if( !structIsEmpty( arguments.missingMethodArguments ) ){
			return invoke(
				variables.runnable,
				arguments.missingMethodName,
				arguments.missingMethodArguments
			);
		}

		return invoke(
			variables.runnable,
			arguments.missingMethodName
		);
	}

	/**
	 * Process all transformers upon an initial result
	 *
	 * @result The result to act upon
	 *
	 * @return The transformed result
	 */
	private function processTransformers( required result ){
		var localResult = arguments.result;
		// Do we have any transformers?
		variables.transformers.each( function( item ){
			localResult = item( localResult );
		} );
		return localResult;
	}

}