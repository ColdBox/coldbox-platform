<!-----------------------------------------------------------------------
Copyright 2005 - 2006 ColdBox Framework by Luis Majano
www.coldboxframework.com | www.coldboxframework.org
-------------------------------------------------------------------------

Author 	 :	Luis Majano
Date     :	September 23, 2005
Description :
	This is an abstract cfc that all plugins should extend.

Modification History:
----------------------------------------------------------------------->
<cfcomponent name="plugin" hint="This is the plugin base cfc." extends="coldbox.system.util.actioncontroller">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<!--- ************************************************************* --->
	<cffunction name="init" access="public" returntype="any" output="false" hint="The plugin constructor.">
		<cfscript>
		//<!--- memory reference for the request collection --->
		variables.rc = getCollection();
		//<!--- instance names --->
		variables.instance.pluginName = "";
		variables.instance.pluginVersion = "";
		variables.instance.pluginDescription = "";
		variables.instance.pluginPath = getCurrentTemplatePath();
		return this;
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->

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
	
<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>