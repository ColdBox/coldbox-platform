<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	September 23, 2005
Description :
	This is an abstract cfc that all plugins should extend.

Modification History:
----------------------------------------------------------------------->
<cfcomponent name="plugin"
			 hint="This is the plugin base cfc."
			 extends="coldbox.system.FrameworkSupertype"
			 output="false"
			 serializable="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="any" output="false" hint="The plugin constructor.">
		<cfargument name="controller" type="any" required="true" hint="coldbox.system.Controller">
		<cfscript>
			// Register Controller
			variables.controller = arguments.controller;
			// Register ColdBox
			variables.logBox = arguments.controller.getLogBox();
			
			// Prepare a Plugin properties
			instance.pluginName = "";
			instance.pluginVersion = "";
			instance.pluginDescription = "";
			instance.pluginAuthor = "";
			instance.pluginAuthorURL = "";
			instance.pluginPath = getMetadata(this).path;
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- INSTANCE MUTATORS AND ACCESSORS ------------------------------------------->

	<!--- Plugin Author URL --->
	<cffunction name="getpluginAuthorURL" access="public" output="false" returntype="string" hint="Get the instance's pluginAuthorURL">
		<cfreturn instance.pluginAuthorURL/>
	</cffunction>
	<cffunction name="setpluginAuthorURL" access="public" output="false" returntype="void" hint="Set the instance's pluginAuthorURL">
		<cfargument name="pluginAuthorURL" type="string" required="true"/>
		<cfset instance.pluginAuthorURL = arguments.pluginAuthorURL/>
	</cffunction>
	
	<!--- Plugin Author --->
	<cffunction name="getpluginAuthor" access="public" output="false" returntype="string" hint="Get the instance's pluginAuthor">
		<cfreturn instance.pluginAuthor/>
	</cffunction>
	<cffunction name="setpluginAuthor" access="public" output="false" returntype="void" hint="Set the instance's pluginAuthor">
		<cfargument name="pluginAuthor" type="string" required="true"/>
		<cfset instance.pluginAuthor = arguments.pluginAuthor/>
	</cffunction>

	<!--- Get/set Plugin Name --->
	<cffunction name="getPluginName" access="public" hint="Get the instance's pluginName" returntype="string" output="false">
		<cfreturn instance.pluginName>
	</cffunction>
	<cffunction name="setPluginName" access="public" hint="Set the instance's pluginName" returntype="string" output="false">
		<cfargument name="pluginName" required="true" type="string">
		<cfset instance.pluginName = arguments.pluginName>
	</cffunction>

	<!--- Get/Set Plugin Version --->
	<cffunction name="getPluginVersion" access="public" hint="Get the instance's pluginVersion" returntype="string" output="false">
		<cfreturn instance.pluginVersion>
	</cffunction>
	<cffunction name="setPluginVersion" access="public" hint="Set the instance's pluginVersion" returntype="string" output="false">
		<cfargument name="pluginVersion" required="true" type="string">
		<cfset instance.pluginVersion = arguments.pluginVersion>
	</cffunction>

	<!--- Get/Set Plugin Description --->
	<cffunction name="getPluginDescription" access="public" hint="Get the instance's pluginDescription" returntype="string" output="false">
		<cfreturn instance.pluginDescription>
	</cffunction>
	<cffunction name="setPluginDescription" access="public" hint="Set the instance's pluginDescription" returntype="string" output="false">
		<cfargument name="pluginDescription" required="true" type="string">
		<cfset instance.pluginDescription = arguments.pluginDescription>
	</cffunction>

	<!--- Get Plugin Path --->
	<cffunction name="getpluginPath" access="public" hint="Get the instance's pluginPath" returntype="string" output="false">
		<cfreturn instance.pluginPath>
	</cffunction>

<!------------------------------------------- PRIVATE METHODS ------------------------------------------->

	<!--- Get Context --->
	<cffunction name="getRequestContext" access="private" returntype="coldbox.system.beans.RequestContext" hint="Retrieve the request context object" output="false" >
		<cfreturn controller.getRequestService().getContext()>
	</cffunction>
	
	<!--- Get RC --->
	<cffunction name="getRequestCollection" access="private" returntype="struct" hint="Get a reference to the request collection" output="false" >
		<cfargument name="private" type="boolean" required="false" default="false" hint="Get the request collection or private request collection"/>
		<cfreturn getRequestContext().getCollection(private=arguments.private)>
	</cffunction>

</cfcomponent>