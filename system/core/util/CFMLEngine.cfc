/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Allows you to manipulate determine CFML engine capabilities
 */
component {

	// setup the engine properties
	this.ADOBE = "adobe";
	this.LUCEE = "lucee";

	// JDK Version
	this.JDK_VERSION = createObject( "java", "java.lang.System" ).getProperty( "java.version" );

	/**
	 * Constructor
	 */
	function init(){
		// Features map by engine
		variables.features = {
			adobe2016 : { invokeArray : false },
			adobe2018 : { invokeArray : false },
			adobe2021 : { invokeArray : false },
			lucee     : { invokeArray : true }
		};
		variables.productVersion = listFirst( server.coldfusion.productversion );

		return this;
	}

	/**
	 * Returns the current running CFML major version level
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
	 * Verify if this is a lucee server
	 */
	boolean function isLucee(){
		return structKeyExists( server, "lucee" );
	}

	/**
	 * Verify if this is an adobe server
	 */
	boolean function isAdobe(){
		return !isLucee();
	}

	/**
	 * Get the current CFML Engine name
	 *
	 * @return Either 'lucee' or 'adobe'
	 */
	string function getEngine(){
		return ( isLucee() ? this.lucee : this.adobe );
	}

	/**
	 * Discover the running engine slug for feature checks
	 *
	 * @return lucee, adobe{version}
	 */
	string function getFeatureEngineSlug(){
		return isLucee() ? this.lucee : this.adobe & getVersion();
	}

	/**
	 * CFML Engine based features checker. Pass in the feature and engine and see if you can use it.
	 *
	 * @feature The feature to check
	 * @engine  The engine we are checking or defaults to the running engine
	 */
	boolean function hasFeature( required feature, engine = getFeatureEngineSlug() ){
		return variables.features[ arguments.engine ][ arguments.feature ];
	}

}
