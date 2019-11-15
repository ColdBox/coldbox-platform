/**
 * This class ingests a Java thread proxy and abstracts its usage by providing
 * a functional interface to interact with the thread and a value that the thread could produce.
 *
 * TODO:
 * - then( callback )
 * - error( callback )
 */
component accessors="true"{

	property name="runnable";

	function init( required runnable ){
		variables.runnable 	= arguments.runnable;
		variables.transformers = [];

		return this;
	}

	Future function then( target ){
		variables.transformers.append( arguments.target );
		return this;
	}

	private function processTransformers( required result ){
		var localResult = arguments.result;
		// Do we have any transformers?
		if( variables.transformers.len() ){
			variables.transformers.each( function( item ){
				localResult = item( localResult );
			} );
		}
		return localResult;
	}

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

	Future function onError( target ){
		var oHandler = createDynamicProxy(
			new UncaughtExceptionHandler( arguments.target, this ),
			[ "java.lang.Thread$UncaughtExceptionHandler" ]
		);
		variables.runnable.setUncaughtExceptionHandler( oHandler );
		return this;
	}

	Future function start(){
		variables.runnable.start();
		return this;
	}

	string function getName(){
		return variables.runnable.getName();
	}

	string function getId(){
		return variables.runnable.getId();
	}

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

}