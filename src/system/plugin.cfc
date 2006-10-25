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
<cfcomponent name="plugin" hint="This is the plugin base cfc." extends="coldbox.system.util.sharedlibrary">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<!--- ************************************************************* --->
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="controllerInstance" type="struct">
		<!--- memory reference for the request collection --->
		<cfset variables.rc = getCollection()>
		<!--- instance names --->
		<cfset variables.instance.pluginName = "">
		<cfset variables.instance.pluginVersion = "">
		<cfset variables.instance.pluginDescription = "">
		<cfset variables.instance.pluginPath = getCurrentTemplatePath()>
		<cfreturn this>
	</cffunction>
	<!--- ************************************************************* --->

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->
	<cffunction name="getCurrentLayout" access="public" hint="Gets the current set layout" returntype="string" output="false">
		<cfreturn getValue("currentLayout","")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getCurrentEvent" access="public" hint="Gets the current set event" returntype="string" output="false">
		<cfreturn getValue("event","")>
	</cffunction>
	<!--- ************************************************************* --->
		
	<!--- ************************************************************* --->
	<cffunction name="getCurrentView" access="public" hint="Gets the current set view" returntype="string" output="false">
		<cfreturn getValue("currentView","")>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="getResource" access="public" output="false" returnType="any" hint="Facade to i18n.getResource">
		<!--- ************************************************************* --->
		<cfargument name="resource" type="string" hint="The resource to retrieve from the bundle.">
		<!--- ************************************************************* --->
		<cfreturn getPlugin("resourceBundle").getResource("#arguments.resource#")>
	</cffunction>
	<!--- ************************************************************* --->

	
<!------------------------------------------- INSTANCE MUTATORS AND ACCESSORS ------------------------------------------->

	<!--- ************************************************************* --->
	<cffunction name="getPluginName" access="public" hint="Get the instance's pluginName" returntype="string" output="false">
		<cfreturn variables.instance.pluginName>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="setPluginName" access="public" hint="Set the instance's pluginName" returntype="string" output="false">
		<cfargument name="pluginName" required="true" type="string">
		<cfset variables.instance.pluginName = arguments.pluginName>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="getPluginVersion" access="public" hint="Get the instance's pluginVersion" returntype="string" output="false">
		<cfreturn variables.instance.pluginVersion>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="setPluginVersion" access="public" hint="Set the instance's pluginVersion" returntype="string" output="false">
		<cfargument name="pluginVersion" required="true" type="string">
		<cfset variables.instance.pluginVersion = arguments.pluginVersion>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="getPluginDescription" access="public" hint="Get the instance's pluginDescription" returntype="string" output="false">
		<cfreturn variables.instance.pluginDescription>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="setPluginDescription" access="public" hint="Set the instance's pluginDescription" returntype="string" output="false">
		<cfargument name="pluginDescription" required="true" type="string">
		<cfset variables.instance.pluginDescription = arguments.pluginDescription>
	</cffunction>
	<!--- ************************************************************* --->
	
	
<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>