/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* Our AOP Method Interceptor Interface
*/
interface{

    /**
	* Invoke an AOP method invocation
	* @invocation The invocation object
	* @invocation.doc_generic coldbox.system.aop.methodInvocation
	*/
	function invokeMethod( required invocation ) output="false";
	
}