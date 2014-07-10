/** -----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/2/2007
Description :
	A facade to server so I can determine CF Version and Type
-----------------------------------------------------------------------  */
component {

// ------------------------------------------ CONSTRUCTOR -------------------------------------------

	public function init() {
		//setup the engine properties
		this.ADOBE = "ADOBE";
		this.BLUEDRAGON = "BLUEDRAGON";
		this.RAILO = "RAILO";

		// JDK Version
		this.JDK_VERSION = CreateObject("java", "java.lang.System").getProperty("java.version");

		// Engine Turn off/on features
		instance = structnew();

		instance.adobe 				= structnew();
		instance.adobe.mt 			= true;
		instance.adobe.json 		= true;
		instance.adobe.ramResource	= true;
		instance.adobe.onmm			= true;
		instance.adobe.instanceCheck = true;

		instance.railo = structnew();
		instance.railo.mt   		= true;
		instance.railo.json 		= true;
		instance.railo.ramResource 	= true;
		instance.railo.onmm 		= true;
		instance.railo.instanceCheck = true;

		instance.bluedragon 			= structnew();
		instance.bluedragon.mt 			= true;
		instance.bluedragon.json 		= true;
		instance.bluedragon.ramResource = false;
		instance.bluedragon.onmm 		= true;
		instance.bluedragon.instanceCheck = true;

		return this;

	}

// ------------------------------------------- PUBLIC -------------------------------------------

	/** 
	* Returns the current running CFML version
	*/
	public numeric function getVersion() {
		if ( server.coldfusion.productname eq "BlueDragon" ){ return server.bluedragon.edition; }
		return listfirst(server.coldfusion.productversion);
	}

	/** 
	* Get the current CFML Engine
	*/
	public string function getEngine() {
		var engine = "ADOBE";

		if ( server.coldfusion.productname eq "BlueDragon" ){
			engine = "BLUEDRAGON";
		} else if ( server.coldfusion.productname eq "Railo" ){
			engine = "RAILO";
		}

		return engine;
	}

	
	/** 
	* Check if the engine supports RAM writing
	*/
	public boolean function isRAMResource() {
		var version = getVersion();
		var engine = getEngine();

		if ( (engine eq this.ADOBE and version gte 9) or
			 (engine eq this.RAILO) ){
			return (true AND featureCheck("ramResource",engine));
		} else {
			return false;
		}		
	}

	
	/** 
	* Checks if the engine is onMissingMethod capable.
	*/
	public boolean function isOnMM() {
		var version = getVersion();
		var engine = getEngine();

		if ( (engine eq this.ADOBE and version gte 8) or
			 (engine eq this.BLUEDRAGON and version gte 7) or
			 (engine eq this.RAILO) ){
			return (true AND featureCheck("onmm",engine));
		} else {
			return false;
		}		
	}

	
	/** 
	* Checks if the engine is Multi-Threaded.
	*/
	public boolean function isMT() {
		var version = getVersion();
		var engine = getEngine();

		if ( (engine eq this.ADOBE and version gte 8) or
			 (engine eq this.BLUEDRAGON and version gte 7) or
			 (engine eq this.RAILO) ){
			return (true AND featureCheck("mt",engine));
		} else {
			return false;
		}		
	}

	
	/** 
	* Checks if the engine can check instances.
	*/
	public boolean function isInstanceCheck() {
		var version = getVersion();
		var engine  = getEngine();

		if ( (engine eq this.ADOBE and version gte 8) or
			 (engine eq this.BLUEDRAGON and version gte 7) or
			 (engine eq this.RAILO) ){
			return (true AND featureCheck("instanceCheck",engine));
		} else {
			return false;
		}		
	}

	
	/** 
	* Checks if the engine can use json methods.
	*/
	public boolean function isJSONSupported() {
		var version = getVersion();
		var engine = getEngine();

		if ( (engine eq this.ADOBE and version gte 8) or
			 (engine eq this.RAILO and version gte 8) ){
			return (true AND featureCheck("json",engine));
		} else {
			return false;
		}		
	}

	
	/** 
	* Checks if the engine can use component data.
	*/
	public boolean function isComponentData() {
		var version = getVersion();
		var engine = getEngine();

		if ( (engine eq this.ADOBE and version gte 8) or
			 (engine eq this.RAILO) ){
			return true;
		} else {
			return false;
		}		
	}
		
// ------------------------------------------- PRIVATE -------------------------------------------

	
	/** 
	* Feature Active Check
	*/
	public boolean function featureCheck( required string feature, required string engine ) {
		return instance[arguments.engine][arguments.feature];
	}

}