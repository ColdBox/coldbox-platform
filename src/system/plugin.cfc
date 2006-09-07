<!-----------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	September 23, 2005
Description :
	This is an abstract cfc that all plugins should extend.

Modification History:
----------------------------------------------------------------------->
<cfcomponent name="plugin" hint="This is the plugin base cfc." extends="controller">

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
		<!--- Shared implementations library --->
		<cfset variables.sharedLibrary = CreateObject("component","util.sharedlibrary")>
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
	
	<!--- ************************************************************* --->
	<cffunction name="getfwLocale" access="public" output="false" returnType="string" hint="Get the default locale string used in the framework as a facade. This improves by 100% calling the i18n Plugin.">
		<cfreturn variables.sharedLibrary.getfwLocale()>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="getDatasource" access="public" output="false" returnType="any" hint="I will return to you a datasourceBean according to the name of the datasource you wish to get from the configstruct (config.xml)">
		<!--- ************************************************************* --->
		<cfargument name="name" type="string" hint="The name of the datasource to get from the configstruct (name property in the config.xml)">
		<!--- ************************************************************* --->
		<cfreturn variables.sharedLibrary.getDatasource(arguments.name)>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getMyPlugin" access="public" hint="Get a custom plugin" returntype="any" output="false">
		<!--- ************************************************************* --->
		<cfargument name="plugin" type="string" hint="The Plugin object's name to instantiate" required="true" >
		<!--- ************************************************************* --->
		<cfreturn variables.sharedLibrary.getMyPlugin(arguments.plugin)>
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

	<!--- ************************************************************* --->
	<cffunction name="throw" access="private" hint="Facade for cfthrow" output="false">
		<!--- ************************************************************* --->
		<cfargument name="message" 	type="string" 	required="yes">
		<cfargument name="detail" 	type="string" 	required="no" default="">
		<cfargument name="type"  	type="string" 	required="no" default="Framework">
		<!--- ************************************************************* --->
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dump" access="private" hint="Facade for cfmx dump">
		<cfargument name="var" required="yes" type="any">
		<cfdump var="#var#">
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="abort" access="private" hint="Facade for cfabort" output="false">
		<cfabort>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="relocate" access="private" hint="Facade for cflocation" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="url" 		type="string" 	required="true">
		<cfargument name="addtoken" type="boolean" 	required="false" default="false">
		<!--- ************************************************************* --->
		<cflocation urL="#arguments.url#" addtoken="#arguments.addtoken#">
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="include" access="private" hint="Facade for cfinclude" output="false">
		<cfargument name="template" type="string">
		<cfinclude template="#template#">
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>