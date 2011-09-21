<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 		: Luis Majano
Date     		: September 23, 2005
Description		: 

Loads all the default ColdBox settings into an application controller

----------------------------------------------------------------------->
<cfcomponent hint="Loads all the default ColdBox settings into an application controller" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="FrameworkLoader" hint="constructor">
		<cfscript>
			instance = {
				frameworkPath 	= expandPath("/coldbox/system") & "/"
			};
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>
	
	<!--- loadSettings --->
	<cffunction name="loadSettings" output="false" access="public" returntype="void" hint="Get the coldbox default settings">
		<cfargument name="controller" type="any" required="true" hint="The coldbox controller to load"/>
		<cfscript>
			var settingsStruct 	= {};
			var key 			= "";
			var cf				= arguments.controller.getCFMLEngine();
			
			//Setup the ColdBox CFML Engine Info
			settingsStruct["CFMLEngine"] 	= cf.getEngine();
			settingsStruct["CFMLVersion"] 	= cf.getVersion();	
			settingsStruct["JDKVersion"]	= cf.JDK_VERSION;		
			
			// Setup metadata paths
			settingsStruct["ApplicationPath"] 		= arguments.controller.getAppRootPath();
			settingsStruct["FrameworkPath"] 		= instance.frameworkPath;
			settingsStruct["FrameworkPluginsPath"] 	= instance.frameworkPath & "plugins";
			settingsStruct["ConfigFileLocation"] 	= "";
			
			// Create fw config
			configCFC = createObject("component","coldbox.system.web.config.Settings");
			// iterate and register settings
			for(key in configCFC){
				settingsStruct[ key ] = configCFC[ key ];
			}
						
			// Store loaded settings
			arguments.controller.setColdBoxSettings( settingsStruct );
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>
	
</cfcomponent>