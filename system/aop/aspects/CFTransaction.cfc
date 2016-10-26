/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* A simple ColdFusion transaction Aspect for WireBox
*/
component 	implements="coldbox.system.aop.MethodInterceptor"
			classMatcher="any" 
			accessors="true"
			methodMatcher="annotatedWith:transactional"{

	// DI 
	property name="log" inject="logbox:logger:{this}";

	/**
	* Constructor
	*/
	function init(){
		return this;
	}

	/**
	* Invoke an AOP method invocation
	* @invocation The invocation object
	* @invocation.doc_generic coldbox.system.aop.methodInvocation
	*/
	function invokeMethod( required invocation ) output="false"{
		var refLocal = {};

		// Are we already in a transaction?
		if( structKeyExists( request, "cbox_aop_transaction" ) ){
			// debug?
			if( log.canDebug() ){ 
				log.debug( "Call to '#arguments.invocation.getTargetName()#.#arguments.invocation.getMethod()#()' already transactioned, just executing it" );
			}
			// Just execute and return;
			return arguments.invocation.proceed();
		}

		try{

			transaction{
				// In Transaction
				request[ "cbox_aop_transaction" ] = true;
				if( log.canDebug() ){
					log.debug( "Call to '#arguments.invocation.getTargetName()#.#arguments.invocation.getMethod()#()' is now transactioned and begins execution" );
				}
				// Execute Transactioned method
				refLocal.results = arguments.invocation.proceed();
			}


		} catch( any e ){
			structDelete( request, "cbox_aop_transaction" );
			log.error( "An exception ocurred in the AOPed transactio for target: #arguments.invocation.getTargetName()#, method: #arguments.invocation.getMethod()#: #cfcatch.message# #cfcatch.detail#", cfcatch );
			rethrow;
		}

		// remove transaction pointer
		structDelete( request, "cbox_aop_transaction" );
		// results to return?
		if( structKeyExists( refLocal, "results" ) ){
			return refLocal.results;
		}
	}

}