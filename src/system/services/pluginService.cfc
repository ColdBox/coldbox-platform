<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	September 3, 2007
Description :
	This cfc takes care of all plugin related operations.

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="pluginService" output="false" hint="The coldbox plugin service" extends="baseService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="pluginService" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			/* Set Controller */
			setController(arguments.controller);
			
			/* Set Service Properties */
			setColdBoxPluginsPath('coldbox.system.plugins');
			setCacheDictionary(Structnew());
			
			/* Return instance */
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- Get a new plugin Instance --->
	<cffunction name="new" access="public" returntype="any" hint="Create a New Plugin Instance wether its core or custom" output="false" >
		<cfargument name="plugin" required="true" type="string"  hint="The named plugin to create">
		<cfargument name="custom" required="true" type="boolean" hint="Custom plugin or coldbox plugin">
		<cfscript>
		return CreateObject("component", locatePluginPath(arguments.plugin,arguments.custom) ).init( controller );
		</cfscript>
	</cffunction>

	<!--- Get a new or cached plugin instance --->
	<cffunction name="get" access="public" returntype="any" hint="Get a new/cached plugin instance" output="false" >
		<cfargument name="plugin" required="true" type="string"  hint="The named plugin to create">
		<cfargument name="custom" required="true" type="boolean" hint="Custom plugin or coldbox plugin">
		<cfscript>
			/* Used for caching. */
			var pluginKey = "cboxplugin_" & arguments.plugin;
			var pluginMD = "";
			var objTimeout = "";
			var oPlugin = structnew();
			var MetaData = "";
			var mdEntry = structnew();
			
			/* Differentiate a Custom PluginKey */
			if ( arguments.custom ){
				pluginKey = "cboxcustom_plugin_" & arguments.plugin;
			}
			
			/* Lookup plugin in Cache */
			if ( controller.getColdboxOCM().lookup(pluginKey) ){
				oPlugin = controller.getColdboxOCM().get(pluginKey);
			}
			else{
				/* Object not found, proceed to create and verify */
				oPlugin = new(argumentCollection=arguments);
				
				/* Determine if we have md and cacheable, else set it  */
				if ( not lookupCacheMD(pluginKey) ){
					/* Get Plugins MetaData and cache */
					MetaData = getMetaData(oPlugin);
					
					/* Set Default MD Entry */
					mdEntry.cacheable = false;
					mdEntry.timeout = "";
					
					/* Test for caching parameters */
					if ( structKeyExists(MetaData, "cache") and isBoolean(MetaData["cache"]) and MetaData["cache"] ){
						/* Plugins are NOT cached by default. */
						mdEntry.cacheable = true;
						if ( structKeyExists(MetaData,"cachetimeout") ){
							mdEntry.timeout = MetaData["cachetimeout"];
						}						
					}
					
					/* Set Entry in dictionary */
					setCacheMD(pluginKey,mdEntry);	
				}
				
				/* Do we Cache */
				if ( getCacheMD(pluginKey).cacheable ){
					controller.getColdboxOCM().set(pluginKey,oPlugin,getCacheMD(pluginKey).timeout);
				}				
			}//end else if instance not in cache.
			
			/* Return new or cached Instance */
			return oPlugin;
		</cfscript>
	</cffunction>
	
	<!--- Cache MD Lookup --->
	<cffunction name="lookupCacheMD" access="public" returntype="boolean" hint="Determine if we have this lookup md key" output="false" >
		<cfargument name="pluginKey" required="true" type="string" hint="The key to use">
		<cfreturn structKeyExists(getcacheDictionary(),arguments.pluginKey)>
	</cffunction>
	
	<!--- Get a cache plugin entry from the dictionary --->
	<cffunction name="getCacheMD" access="public" returntype="Struct" hint="Get a cache plugin entry from the dictionary" output="false" >
		<cfargument name="pluginKey" required="true" type="string" hint="The key to use">
		<cfset var cd = getCacheDictionary()>
		<cfreturn cd[arguments.pluginKey]>
	</cffunction>
	
	<!--- Set a new cache lookup entry --->
	<cffunction name="setCacheMD" access="public" returntype="void" hint="Set a new cache plugin entry in the dictionary" output="false" >
		<cfargument name="pluginKey" 	required="true" type="string" hint="The plugin Key">
		<cfargument name="entry" 		required="true" type="struct" hint="The md entry">
		<cfset structInsert(getCacheDictionary(),arguments.pluginKey,arguments.entry)>
	</cffunction>
	
	<!--- ColdBox Plugins Path --->
	<cffunction name="getColdBoxPluginsPath" access="public" output="false" returntype="string" hint="Get ColdBoxPluginsPath">
		<cfreturn instance.ColdBoxPluginsPath/>
	</cffunction>
	<cffunction name="setColdBoxPluginsPath" access="public" output="false" returntype="void" hint="Set ColdBoxPluginsPath">
		<cfargument name="ColdBoxPluginsPath" type="string" required="true"/>
		<cfset instance.ColdBoxPluginsPath = arguments.ColdBoxPluginsPath/>
	</cffunction>
	
	<!--- Plugin Cache Metadata --->
	<cffunction name="getcacheDictionary" access="public" output="false" returntype="struct" hint="Get the plugin cache dictionary">
		<cfreturn instance.cacheDictionary/>
	</cffunction>
	


<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- Set the internal plugin cache dictionary. --->
	<cffunction name="setcacheDictionary" access="private" output="false" returntype="void" hint="Set the plugin cache dictionary. NOT EXPOSED to avoid screwups">
		<cfargument name="cacheDictionary" type="struct" required="true"/>
		<cfset instance.cacheDictionary = arguments.cacheDictionary/>
	</cffunction>
	
	<!--- Locate a Plugin Instantiation Path --->
	<cffunction name="locatePluginPath" access="private" returntype="string" hint="Locate a full plugin instantiation path from the requested plugin name" output="false" >
		<cfargument name="plugin" required="true" type="string" hint="The plugin to validate the path on.">
		<cfargument name="custom" required="true" type="boolean" hint="Whether its a custom plugin or not.">
		<cfscript>
			var pluginPath = "";
			var pluginFilePath = "";
			
			/* Check if getting from custom plugins */
			if ( arguments.custom ){
				
				/* Set plugin key and file path check */
				pluginFilePath = replace(arguments.plugin,".",controller.getSetting("OSFileSeparator",true),"all") & ".cfc";
							
				/* Check for Convention First, MyPluginsPath was already setup with conventions on XMLParser */
				if ( fileExists(controller.getSetting("MyPluginsPath") & controller.getSetting("OSFileSeparator",true) & pluginFilePath ) ){
					pluginPath = "#controller.getSetting("MyPluginsInvocationPath")#.#arguments.plugin#";
				}
				else{
					/* Will search the alternate custom location */
					pluginPath = "#controller.getSetting("MyPluginsLocation")#.#arguments.plugin#";
				}
			}//end if custom plugin
			else{
				pluginPath = getColdboxPluginsPath() & "." & trim(arguments.plugin);
			}
			
			return pluginPath;
		</cfscript>
	</cffunction>


</cfcomponent>