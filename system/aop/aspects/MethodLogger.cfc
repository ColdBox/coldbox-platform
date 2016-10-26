/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* A simple interceptor that logs method calls and their results
*/
component 	implements="coldbox.system.aop.MethodInterceptor"
			accessors="true"{

	// DI 
	property name="log" inject="logbox:logger:{this}";
	
	/**
	* Log results
	*/
	property name="logResults" type="boolean" default="true";

	/**
	* Constructor
	* @logResults Log results or not
	*/
	function init( boolean logResults=true){
		variables.logResults = arguments.logResults;
		return this;
	}

	/**
	* Invoke an AOP method invocation
	* @invocation The invocation object
	* @invocation.doc_generic coldbox.system.aop.methodInvocation
	*/
	function invokeMethod( required invocation ) output="false"{
		var refLocal = {};
		var debugString = "target: #arguments.invocation.getTargetName()#,method: #arguments.invocation.getMethod()#,arguments:#serializeJSON(arguments.invocation.getArgs())#";
		
		// log incoming call
		if( log.canDebug() ){
			log.debug( debugString );
		}
		
		// proceed execution
		refLocal.results = arguments.invocation.proceed();
		
		// result logging and returns
		if( structKeyExists( refLocal, "results") ){ 
			if( variables.logResults and log.canDebug() ){
				log.debug( "#debugString#, results:", refLocal.results );
			}
			return refLocal.results; 
		}
	}
	
}