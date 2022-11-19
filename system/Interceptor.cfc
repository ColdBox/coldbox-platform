/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Base class for all interceptors
 */
component
	extends     ="coldbox.system.FrameworkSupertype"
	serializable="false"
	accessors   ="true"
	threadsafe
{

	/****************************************************************
	 * Properties *
	 ****************************************************************/

	/**
	 * The properties this interceptors is bound with
	 */
	property name="properties" type="struct";

	/**
	 * Constructor
	 *
	 * @properties The properties to init the Interceptor with
	 *
	 * @return Interceptor
	 */
	function init( struct properties = {} ){
		variables.properties = arguments.properties;
		super.init();
		return this;
	}

	/**
	 * Internal ColdBox event so all interceptors can load their UDF helpers
	 * DO NOT OVERRIDE or funky things will happen!
	 */
	function cbLoadInterceptorHelpers( event, interceptData ){
		// Load global UDF Libraries into target
		loadApplicationHelpers( force: true );
	}

	/**
	 * Configuration method for the interceptor
	 */
	void function configure(){
	}

	/**
	 * Get an interceptor property
	 *
	 * @property     The property to retrieve
	 * @defaultValue The default value to return if property does not exist
	 *
	 * @return The property value requested or the default value if not found
	 *
	 * @throws InvalidPropertyException
	 */
	any function getProperty( required property, defaultValue ){
		if ( structKeyExists( variables.properties, arguments.property ) ) {
			return variables.properties[ arguments.property ];
		}

		if ( !isNull( arguments.defaultValue ) ) {
			return arguments.defaultValue;
		}

		throw(
			message = "The requested property #arguments.property# does not exist.",
			type    = "InvalidPropertyException"
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
	 * @value    The value to store
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
		variables.controller.getInterceptorService().unregister( interceptorClass, arguments.state );
		return this;
	}

}
