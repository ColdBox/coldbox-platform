/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Base class for all interceptors
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
	property name="properties"         type="struct";
	// The interceptor service
	property name="interceptorService" type="coldbox.system.services.InterceptorService";

	/**
	 * Constructor
	 *
	 * @controller The ColdBox controller
	 * @properties The properties to init the Interceptor with
	 *
	 * @return Interceptor
	 */
	function init( required controller, struct properties={} ){
		// Register Controller
		variables.controller = arguments.controller;
		// Register LogBox
		variables.logBox     = arguments.controller.getLogBox();
		// Register Log object
		variables.log        = variables.logBox.getLogger( this );
		// Register Flash RAM
		variables.flash      = arguments.controller.getRequestService().getFlashScope();
		// Register CacheBox
		variables.cacheBox   = arguments.controller.getCacheBox();
		// Register WireBox
		variables.wireBox    = arguments.controller.getWireBox();
		// Load global UDF Libraries into target
		loadApplicationHelpers();
		// store properties
		variables.properties         = arguments.properties;
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
	 *
	 * @property The property to retrieve
	 * @defaultValue The default value to return if property does not exist
	 *
	 * @throws InvalidPropertyException
	 * @return The property value requested or the default value if not found
	 */
	any function getProperty( required property, defaultValue ){
		if( structKeyExists( variables.properties, arguments.property ) ){
			return variables.properties[ arguments.property ];
		}

		if( !isNull( arguments.defaultValue ) ){
			return arguments.defaultValue;
		}

		throw(
			message = "The requested property #arguments.property# does not exist.",
			type 	= "InvalidPropertyException"
		);
	}

	/**
	 * Get the struct of properties defined in this interceptor
	 */
	struct function getProperties(){
		return variables.properties;
	}

	/**
	 * Store an interceptor property
	 *
	 * @property The property to store
	 * @value The value to store
	 *
	 * @return Interceptor instance
	 */
	any function setProperty( required property, required value ){
		variables.properties[ arguments.property ] = arguments.value;
		return this;
	}

	/**
	 * Verify an interceptor property exists
	 *
	 * @property The property to check
	 */
	boolean function propertyExists( required property ){
		return structKeyExists( variables.properties, arguments.property );
	}

	/**
	 * Unregister the interceptor from the state passed
	 *
	 * @state The named state to unregister this interceptor from
	 *
	 * @return Interceptor
	 */
	function unregister( required state ){
		var interceptorClass = listLast( getMetadata( this ).name, "." );
		variables.controller
			.getInterceptorService()
			.unregister( interceptorClass, arguments.state );
		return this;
	}

}