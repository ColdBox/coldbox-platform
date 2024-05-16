/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Allows you to manipulate determine CFML engine capabilities
 */
component {

	// setup the engine properties
	this.ADOBE   = "adobe";
	this.LUCEE   = "lucee";
	this.BOXLANG = "boxlang";

	// JDK Version
	this.JDK_VERSION = createObject( "java", "java.lang.System" ).getProperty( "java.version" );

	/**
	 * Constructor
	 */
	function init(){
		// Features map by engine
		variables.features = {
			adobe2018 : { invokeArray : false },
			adobe2021 : { invokeArray : false },
			adobe2023 : { invokeArray : false },
			lucee     : { invokeArray : true },
			boxlang   : { invokeArray : true }
		};

		return this;
	}

	/**
	 * Returns the current running CFML major version level
	 */
	numeric function getVersion(){
		return listFirst( getFullVersion(), "." );
	}

	/**
	 * Returns the current running CFML full version
	 */
	string function getFullVersion(){
		switch ( getEngine() ) {
			case this.adobe:
				return server.coldfusion.productVersion;
			case this.lucee:
				return server.lucee.version;
			case this.boxlang:
				return server.boxlang.version;
		}
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
		return server.keyExists( "coldfusion" ) && server.coldfusion.productName.findNoCase( "ColdFusion" );
	}

	/**
	 * Verify if this is a boxlang server
	 */
	boolean function isBoxLang(){
		return server.keyExists( "boxlang" );
	}

	/**
	 * Get the current CFML Engine name
	 *
	 * @return Either 'lucee' or 'adobe' or 'boxlang'
	 */
	string function getEngine(){
		if ( isLucee() ) {
			return this.lucee;
		} else if ( isAdobe() ) {
			return this.adobe;
		} else if ( isBoxLang() ) {
			return this.boxlang;
		}
	}

	/**
	 * Discover the running engine slug for feature checks
	 *
	 * @return lucee, adobe{version}
	 */
	string function getFeatureEngineSlug(){
		var engine = getEngine();
		return isAdobe() ? engine & getVersion() : engine;
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
