/*-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano, cfscript: Ben Koshy
Description :	I model a method invocation call
-----------------------------------------------------------------------*/
component
	hint   = "I model a method invocation call"
	output = false
{

	/*
	* @hint		Constructor
	* @output	false
	*
	* @method.hint						The method name that was intercepted	
	* @args.hint						The argument collection that was intercepted
	* @methodMetadata.hint				The method metadata that was intercepted
	* @target.hint						The target object reference that was intercepted
	* @targetName.hint					The name of the target wired up
	* @targetMapping.hint				The target's mapping object reference
	* @targetMapping.colddoc:generic	coldbox.system.ioc.config.Mapping
	* @interceptors.hint				The array of interceptors for this invocation
	*/
	public any function init(
		required any method,
		required any args,
		required any methodMetadata,
		required any target,
		required any targetName,
		required any targetMapping,
		required any interceptors
	){
		// store references
		instance = {
			method 				= arguments.method,
			args 				= arguments.args,
			methodMetadata		= deserializeJSON( URLDecode( arguments.methodMetadata )),
			target				= arguments.target,
			targetName			= arguments.targetName,
			targetMapping		= arguments.targetMapping,
			interceptors		= arguments.interceptors,
			// Current index to start execution
			interceptorIndex	= 1,
			interceptorLen		= arrayLen( arguments.interceptors )
		};
		
		return this;
	} // init()

	/*
	* @hint		Increment the interceptor index pointer
	* @output	false
	*/
	public any function incrementInterceptorIndex(){
		instance.interceptorIndex++;
		return this;	    		
	} // incrementInterceptorIndex()

	/*
	* @hint				Get the currently executing interceptor index
	* @output			false
	* @colddoc:generic	numeric
	*/
	public any function getInterceptorIndex(){
		return instance.interceptorIndex;	
	} // getInterceptorIndex()

	/*
	* @hint		Return the method name that was intercepted for this method invocation
	* @output	false
	*/
	public any function getMethod(){
		return instance.method;    		
	} // getMethod()

	/*
	* @hint		Return methods's metadata that was intercepted for this method invocation
	* @output	false
	*/
	public any function getMethodMetadata(){
		return instance.methodMetadata;    		
	} // getMethodMetadata()

	/*
	* @hint		Get the original target object of this method invocation
	* @output	false
	*/
	public any function getTarget(){
		return instance.target;    		
	} // getTarget()

	/*
	* @hint		Get the name of this target
	* @output	false
	*/
	public any function getTargetName(){
		return instance.targetName;    		
	} // getTargetName()

	/*
	* @hint		Get the wirebox mapping of this target
	* @output	false
	*/
	public any function getTargetMapping(){
		return instance.targetMapping;    		
	} // getTargetMapping()

	/*
	* @hint				Get the argument collection of this method invocation
	* @output			false
	* @colddoc:generic	struct
	*/
	public any function getArgs(){
		return instance.args;    		
	} // getArgs()

	/*
	* @hint				Set the argument collection of this method invocation, override orginal
	* @output			false
	*
	* @args.hint		The argument collection that you want to now use
	*/
	public any function setArgs( required any args ){
		instance.args = arguments.args;
		return this;
	} // getArgs()

	/*
	* @hint				Get the array of aspect interceptors for this method invocation
	* @output			false
	* @colddoc:generic	array
	*/
	public any function getInterceptors(){
		return instance.interceptors;	    
	} // getInterceptors()

	/*
	* @hint		Proceed execution of the method invocation
	* @output	false
	*/
	public any function proceed(){
		// We will now proceed with our interceptor execution chain or regular method pointer call
		// execute the next interceptor in the chain
			
		// Check Current Index against interceptor length
		if( instance.interceptorIndex LTE instance.interceptorLen ){
			return instance.interceptors[ instance.interceptorIndex ].invokeMethod( this.incrementInterceptorIndex() );
		}
		
		// If we get here all interceptors have fired and we need to fire the original proxied method
		return instance.target.$wbAOPInvokeProxy( method=instance.method, args=instance.args );
	} // proceed()
}