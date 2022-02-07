/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Allows you to manipulate determine CFML engine capabilities
 */
component {

	// setup the engine properties
	this.ADOBE = "ADOBE";
	this.LUCEE = "LUCEE";

	// JDK Version
	this.JDK_VERSION = createObject( "java", "java.lang.System" ).getProperty( "java.version" );

	/**
	 * Constructor
	 */
	function init(){
		// Feature map by engine
		variables.features = {
			adobe2016 : { invokeArray : false },
			adobe2018 : { invokeArray : true },
			adobe2021 : { invokeArray : true },
			lucee     : { invokeArray : true }
		};
		variables.productVersion = listFirst( server.coldfusion.productversion );

		return this;
	}

	// ------------------------------------------- PUBLIC -------------------------------------------

	/**
	 * Returns the current running CFML major version
	 */
	numeric function getVersion(){
		return variables.productVersion;
	}

	/**
	 * Returns the current running CFML full version
	 */
	string function getFullVersion(){
		return server.coldfusion.productversion;
	}

	/**
	 * Get the current CFML Engine
	 */
	string function getEngine(){
		return ( structKeyExists( server, "lucee" ) ? this.lucee : this.adobe );
	}

	/**
	 * CFML Engine based features checker. Pass in the feature and engine and see if you can use it.
	 *
	 * @feature The feature to check
	 * @engine  The engine we are checking
	 */
	boolean function hasFeature( required feature, required engine ){
		return variables.features[ arguments.engine ][ arguments.feature ];
	}

}
