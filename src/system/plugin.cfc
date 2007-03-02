<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	September 23, 2005
Description :
	This is an abstract cfc that all plugins should extend.

Modification History:
----------------------------------------------------------------------->
<cfcomponent name="plugin" hint="This is the plugin base cfc." extends="coldbox.system.util.actioncontroller">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="any" output="false" hint="The plugin constructor.">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			setController(arguments.controller);
			//instance names
			variables.instance.pluginName = "";
			variables.instance.pluginVersion = "";
			variables.instance.pluginDescription = "";
			variables.instance.pluginPath = getCurrentTemplatePath();
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->


<!------------------------------------------- INSTANCE MUTATORS AND ACCESSORS ------------------------------------------->

	<!--- ************************************************************* --->

	<cffunction name="getPluginName" access="public" hint="Get the instance's pluginName" returntype="string" output="false">
		<cfreturn variables.instance.pluginName>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setPluginName" access="public" hint="Set the instance's pluginName" returntype="string" output="false">
		<cfargument name="pluginName" required="true" type="string">
		<cfset variables.instance.pluginName = arguments.pluginName>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getPluginVersion" access="public" hint="Get the instance's pluginVersion" returntype="string" output="false">
		<cfreturn variables.instance.pluginVersion>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setPluginVersion" access="public" hint="Set the instance's pluginVersion" returntype="string" output="false">
		<cfargument name="pluginVersion" required="true" type="string">
		<cfset variables.instance.pluginVersion = arguments.pluginVersion>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getPluginDescription" access="public" hint="Get the instance's pluginDescription" returntype="string" output="false">
		<cfreturn variables.instance.pluginDescription>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setPluginDescription" access="public" hint="Set the instance's pluginDescription" returntype="string" output="false">
		<cfargument name="pluginDescription" required="true" type="string">
		<cfset variables.instance.pluginDescription = arguments.pluginDescription>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getpluginPath" access="public" hint="Get the instance's pluginPath" returntype="string" output="false">
		<cfreturn variables.instance.pluginPath>
	</cffunction>

	<!--- ************************************************************* --->


<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>