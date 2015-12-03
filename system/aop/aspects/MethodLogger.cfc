/*-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	original: Luis Majano, cfscript: Ben Koshy
Description :
	A simple interceptor that logs method calls and their results
-----------------------------------------------------------------------*/
component
	implements = "coldbox.system.aop.MethodInterceptor"
	hint       = "A simple interceptor that logs method calls and their results"
	output     = false
{
	// dependencies
	property name="log" inject = "logbox:logger:{this}";

	/*
	* @hint		Constructor
	* @output 	false
	*
	* @logResults.hint	Do we log results or not?
	*/
	public any function init( required boolean logResults ){

		instance = {
			logResults = arguments.logResults
		};

		return this;
	} // init()

	/*
	* @hint 	Invoke an AOP method invocation
	* @output 	false
	*
	* @invocation.hint				The method invocation object: coldbox.system.aop.MethodInvocation
	* @invokemethod.colddoc:generic	coldbox.system.aop.MethodInvocation
	*/
	public any function invokeMethod( required any invocation ) {
		var refLocal = {};
		var debugString = "target: #arguments.invocation.getTargetName()#,method: #arguments.invocation.getMethod()#,arguments:#serializeJSON(arguments.invocation.getArgs())#";
		
		log.debug(debugString);
		
		refLocal.results = arguments.invocation.proceed();
		
		// result logging and returns
		if( structKeyExists( refLocal, "results" )){ 
			if( instance.logResults ){
				log.debug( "#debugString#, results:", refLocal.results );
			}
			return refLocal.results; 
		}
	} // invokeMethod()
}