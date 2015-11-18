/*-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	original: Luis Majano, cfscript: Ben Koshy
Description :
	A simple ColdFusion transaction Aspect for WireBox
--------------------------------------------------------------------------
*/
component
	implements    = "coldbox.system.aop.MethodInterceptor"
	hint          = "A simple ColdFusion transaction Aspect for WireBox"
	output        = false
	classMatcher  = "any"
	methodMatcher = "annotatedWith:transactional"
{
	// dependencies
	property name="log" inject = "logbox:logger:{this}";

	/*
	* @hint		Constructor
	* @output 	false
	*/
	public any function init(){

		return this;
	} // init()

	/*
	* @hint 	Invoke an AOP method invocation
	* @output 	false
	*
	* @invocation.hint	The method invocation object: coldbox.system.aop.MethodInvocation"
	* @invokemethod.colddoc:generic	coldbox.system.aop.MethodInvocation
	*/
	public any function invokeMethod( required any invocation ) {
		var refLocal = {};

		// Are we already in a transaction?
		if( structKeyExists( request, "cbox_aop_transaction" )){

			// debug?
			if( log.canDebug() ){ log.debug("Call to '#arguments.invocation.getTargetName()#.#arguments.invocation.getMethod()#()' already transactioned, just executing it"); }

			// Just execute and return;
			return arguments.invocation.proceed();
		}

		try {
			transaction {

				request["cbox_aop_transaction"] = true;

				// debug?
				if( log.canDebug() ){ log.debug("Call to '#arguments.invocation.getTargetName()#.#arguments.invocation.getMethod()#()' is now transactioned and begins execution"); }

				// Execute Transactioned method
				refLocal.results = arguments.invocation.proceed();
			}
		}
		catch( any var e ) {
			
			structDelete(request,"cbox_aop_transaction");
			log.error("An exception ocurred in the AOPed transactio for target: #arguments.invocation.getTargetName()#, method: #arguments.invocation.getMethod()#: #e.message# #e.detail#", e);
			rethrow;
		}
		
		structDelete(request,"cbox_aop_transaction");

		if( structKeyExists(refLocal,"results" )){
			return refLocal.results;			
		}
	} // invokeMethod()
}