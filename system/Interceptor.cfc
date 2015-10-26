/**
********************************************************************************
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* Base class for all interceptors
* @author Luis Majano <lmajano@ortussolutions.com>
*/
component extends="coldbox.system.FrameworkSupertype" serializable="false" accessors="true"{

	// Controller Reference
	property name="controller";
	// LogBox reference
	property name="logBox";
	// Pre-Configured Log Object
	property name="log";
	// Flash Reference
	property name="flash";
	// CacheBox Reference
	property name="cachebox";
	// WireBox Reference
	property name="wirebox";
	// The interceptor properties structure
	property name="properties" 			type="struct";
	// The interceptor service
	property name="interceptorService" 	type="coldbox.system.services.InterceptorService";

	/**
	* Constructor
	* @controller.hint The ColdBox controller
	* @properties.hint The properties to init the Interceptor with
	*
	* @result Interceptor
	*/
	function init( required controller, struct properties={} ){
		// Register Controller
		variables.controller = arguments.controller;
		// Register LogBox
		variables.logBox = arguments.controller.getLogBox();
		// Register Log object
		variables.log = variables.logBox.getLogger( this );
		// Register Flash RAM
		variables.flash = arguments.controller.getRequestService().getFlashScope();
		// Register CacheBox
		variables.cacheBox = arguments.controller.getCacheBox();
		// Register WireBox
		variables.wireBox = arguments.controller.getWireBox();
		// Load global UDF Libraries into target
		loadApplicationHelpers();
		// store properties
		variables.properties = arguments.properties;
		// setup interceptor service
		variables.interceptorService = arguments.controller.getInterceptorService();

		return this;
	}

	/**
	* Configuration method for the interceptor
	*/
	void function configure(){}

	/**
	* Get an interceptor property
	* @property.hint The property to retrieve
	* @defaultValue.hint The default value to return if property does not exist
	*/
	any function getProperty( required property, defaultValue ){
		return ( structKeyExists( variables.properties, arguments.property ) ? variables.properties[ arguments.property ] : arguments.defaultValue );
	}

	/**
	* Store an interceptor property
	* @property.hint The property to store
	* @value.hint The value to store
	*
	* @return Interceptor instance
	*/
	any function setProperty( required property, required value ){
		variables.properties[ arguments.property ] = arguments.value;
		return this;
	}

	/**
	* Verify an interceptor property
	* @property.hint The property to check
	*/
	boolean function propertyExists( required property ){
		return structKeyExists( variables.properties, arguments.property );
	}

	/**
	* Unregister the interceptor
	* @state.hint The named state to unregister this interceptor from
	*
	* @return Interceptor
	*/
	function unregister( required state ){
		var interceptorClass = listLast( getMetadata( this ).name, "." );
		variables.controller.getInterceptorService().unregister( interceptorClass, arguments.state );
		return this;
	}

	/**************************************** BUFFER METHODS ****************************************/

	/**
	* Clear the interceptor buffer
	* @return Interceptor
	*/
	function clearBuffer(){
		getBufferObject().clear();
		return this;
	}

	/**
	* Append to the interceptor buffer
	* @str.hint The string to append to the buffer
	*
	* @return Interceptor
	*/
	function appendToBuffer( required str ){
		getBufferObject().append( arguments.str );
		return this;
	}

	/**
	* Get the string representation of the buffer
	*/
	string function getBufferString(){
		return getBufferObject().getString();
	}

	/**
	* Get the request buffer object from scope.
	* @return coldbox.system.core.util.RequestBuffer
	*/
	function getBufferObject(){
		return variables.interceptorService.getRequestBuffer();
	}



}