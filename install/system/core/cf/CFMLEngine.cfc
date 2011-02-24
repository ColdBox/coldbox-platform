<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/2/2007
Description :
	A facade to server so I can determine CF Version and Type
----------------------------------------------------------------------->
<cfcomponent name="CFMLEngine" output="false" hint="A facade to determine the current running CFML Version and Engine">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cffunction name="init" access="public" returntype="CFMLEngine" output="false" hint="Constructor">
		<cfscript>
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
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Get the current CFML Version --->
	<cffunction name="getVersion" access="public" returntype="numeric" hint="Returns the current running CFML version" output="false" >
		<cfscript>
			if ( server.coldfusion.productname eq "BlueDragon" ){ return server.bluedragon.edition; }
			return listfirst(server.coldfusion.productversion);
		</cfscript>
	</cffunction>
	
	<!--- Get the CFML Engine according to my standards --->
	<cffunction name="getEngine" access="public" returntype="string" hint="Get the current CFML Engine" output="false" >
		<cfscript>
			var engine = "ADOBE";
			
			if ( server.coldfusion.productname eq "BlueDragon" ){
				engine = "BLUEDRAGON";	
			}
			else if ( server.coldfusion.productname eq "Railo" ){
				engine = "RAILO";
			}
			
			return engine;
		</cfscript>
	</cffunction>
	
	<!--- isRAMResource --->
	<cffunction name="isRAMResource" output="false" access="public" returntype="boolean" hint="Check if the engine supports RAM writing">
		<cfscript>
			var version = getVersion();
			var engine = getEngine();
			
			if ( (engine eq this.ADOBE and version gte 9) or
				 (engine eq this.RAILO) ){
				return (true AND featureCheck("ramResource",engine));	 
			}
			else{
				return false;
			}
		</cfscript>
	</cffunction>
	
	<!--- Test if we can use onMissingMethod --->
	<cffunction name="isOnMM" access="public" returntype="boolean" hint="Checks if the engine is onMissingMethod capable." output="false" >
		<cfscript>
			var version = getVersion();
			var engine = getEngine();
			
			if ( (engine eq this.ADOBE and version gte 8) or
				 (engine eq this.BLUEDRAGON and version gte 7) or
				 (engine eq this.RAILO) ){
				return (true AND featureCheck("onmm",engine));
			}
			else{
				return false;
			}
		</cfscript>
	</cffunction>
	
	<!--- Test if we can use MT --->
	<cffunction name="isMT" access="public" returntype="boolean" hint="Checks if the engine is MT." output="false" >
		<cfscript>
			var version = getVersion();
			var engine = getEngine();
			
			if ( (engine eq this.ADOBE and version gte 8) or
				 (engine eq this.BLUEDRAGON and version gte 7) or
				 (engine eq this.RAILO) ){
				return (true AND featureCheck("mt",engine));
			}
			else{
				return false;
			}
		</cfscript>
	</cffunction>
	
	<!--- checks instance --->
	<cffunction name="isInstanceCheck" access="public" returntype="boolean" hint="Checks if the engine can check instances." output="false" >
		<cfscript>
			var version = getVersion();
			var engine  = getEngine();
			
			if ( (engine eq this.ADOBE and version gte 8) or
				 (engine eq this.BLUEDRAGON and version gte 7) or
				 (engine eq this.RAILO) ){
				return (true AND featureCheck("instanceCheck",engine));
			}
			else{
				return false;
			}
		</cfscript>
	</cffunction>
	
	<!--- Test if we can use JSON methods --->
	<cffunction name="isJSONSupported" access="public" returntype="boolean" hint="Checks if the engine can use json methods." output="false" >
		<cfscript>
			var version = getVersion();
			var engine = getEngine();
			
			if ( (engine eq this.ADOBE and version gte 8) or
				 (engine eq this.RAILO and version gte 8) ){
				return (true AND featureCheck("json",engine));	 
			}
			else{
				return false;
			}
		</cfscript>
	</cffunction>
	
	<!--- Test if we can use component data methods --->
	<cffunction name="isComponentData" access="public" returntype="boolean" hint="Checks if the engine can use component data." output="false" >
		<cfscript>
			var version = getVersion();
			var engine = getEngine();
			
			if ( (engine eq this.ADOBE and version gte 8) or
				 (engine eq this.RAILO) ){
				return true;	 
			}
			else{
				return false;
			}
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- featureCheck --->
	<cffunction name="featureCheck" output="false" access="private" returntype="boolean" hint="Feature Active Check">
		<cfargument name="feature" type="string" required="true"/>
		<cfargument name="engine"  type="string" required="true"/>
		<cfreturn instance[arguments.engine][arguments.feature]>		
	</cffunction>
	
</cfcomponent>