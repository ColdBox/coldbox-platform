<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
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
			
			/* JDK Version */
			this.JDK_VERSION = CreateObject("java", "java.lang.System").getProperty("java.version");
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Get the current CFML Version --->
	<cffunction name="getVersion" access="public" returntype="numeric" hint="Returns the current running CFML version" output="false" >
		<cfreturn listfirst(server.coldfusion.productversion)>
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
	
	<!--- Test if we can use MT --->
	<cffunction name="isMT" access="public" returntype="boolean" hint="Checks if the engine is MT." output="false" >
		<cfscript>
			var version = getVersion();
			var engine = getEngine();
			
			if ( (engine eq this.ADOBE and version gte 8) or
				 (engine eq this.BLUEDRAGON and version gte 7) ){
				return true;	 
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
				return true;	 
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

</cfcomponent>