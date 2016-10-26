/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* I model a method invocation call
*/
component accessors="true"{

	/**
	* The currently executing method
	*/
	property name="method";
	/**
	* The currently executing method arguments
	*/
	property name="args";
	/**
	* The current method metadata
	*/
	property name="methodMetadata";
	/**
	* The target of execution
	*/
	property name="target";
	/**
	* The target shortname
	*/
	property name="targetName";
	/**
	* The target wirebox mapping
	*/
	property name="targetMapping";
	/**
	* The AOP interceptors to execute
	*/
	property name="interceptors";
	/**
	* The current index of execution
	*/
	property name="interceptorIndex";
	/**
	* The number of interceptors applied
	*/
	property name="interceptorLen";
	

	/**
	* Constructor
	* @method 			The method name that was intercepted
	* @args 			The argument collection that was intercepted
	* @methodMetadata 	The method metadata that was intercepted
	* @target 			The target object reference that was intercepted
	* @targetName		The name of the target wired up
	* @targetMapping 	The target's mapping object reference
	* @targetMapping.doc_generic coldbox.system.ioc.config.Mapping
	* @interceptors 	The array of interceptors for this invocation
	*/
    function init(
    	required method,
    	required args,
    	required methodMetadata,
    	required target,
    	required targetName,
    	required targetMapping,
    	required interceptors
    ){    
			
		// Method intercepted
		variables.method  			= arguments.method;
		// Arguments intercepted
		variables.args				= arguments.args;
		// Method metadata
		variables.methodMetadata	= deserializeJSON( URLDecode( arguments.methodMetadata ) );
		// Target intercepted
		variables.target			= arguments.target;
		// Target name
		variables.targetName		= arguments.targetName;
		// Target Mapping Reference
		variables.targetMapping		= arguments.targetMapping;
		// Interceptor array chain
		variables.interceptors		= arguments.interceptors;
		// Current index to start execution
		variables.interceptorIndex 	= 1;
		// Length of interceptor
		variables.interceptorLen	= arrayLen( arguments.interceptors );
		
		return this;
	}

	/**
	* Increment the interceptor index pointer
	* @return MethodInvocation
	*/
	function incrementInterceptorIndex(){    
    	variables.interceptorIndex++;
		return this;	    
	}	
	
	/**
	* Set args
	* @return MethodInvocation
	*/
	function setArgs( required args ){
		variables.args = arguments.args;
		return this;
	}
    
    /**
    * Proceed execution of the method invocation
    */
   	function proceed(){
   		// We will now proceed with our interceptor execution chain or regular method pointer call
		// execute the next interceptor in the chain
			
		// Check Current Index against interceptor length
		if( variables.interceptorIndex <= variables.interceptorLen ){
			return variables.interceptors[ variables.interceptorIndex ].invokeMethod( this.incrementInterceptorIndex() );
		}
		
		// If we get here all interceptors have fired and we need to fire the original proxied method
		return variables.target.$wbAOPInvokeProxy( method=variables.method, args=variables.args );
   	}
    
}