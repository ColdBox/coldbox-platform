/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* Allows you to maninpulate determine CFML engine capabilities
*/
component {

	//setup the engine properties
	this.ADOBE = "ADOBE";
	this.LUCEE = "LUCEE";

	// JDK Version
	this.JDK_VERSION = createObject( "java", "java.lang.System" ).getProperty( "java.version" );

	/**
	* Constructor
	*/
	function init() {
		// Feature map
		variables.features = {
			adobe = {},
			lucee = {}
		};

		return this;

	}

// ------------------------------------------- PUBLIC -------------------------------------------

	/**
	* Returns the current running CFML major version
	*/
	numeric function getVersion() {
		return listfirst( server.coldfusion.productversion );
	}

	/**
	* Returns the current running CFML full version
	*/
	string function getFullVersion() {
		return server.coldfusion.productversion;
	}

	/**
	* Get the current CFML Engine
	*/
	string function getEngine() {
		var engine = this.adobe;

		if ( server.coldfusion.productname eq "Lucee" ){
			engine = this.lucee;
		}

		return engine;
	}

	/**
	 * Feature Active Check
	 * 
	 * @feature The feature to check
	 * @engine The engine we are checking
	*/
	boolean function featureCheck( required feature, required engine ) {
		return variables.features[ arguments.engine ][ arguments.feature ];
	}

}