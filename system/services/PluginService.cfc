<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	September 3, 2007
Description :
	This cfc takes care of all plugin related operations.

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="PluginService" output="false" hint="The coldbox plugin service" extends="coldbox.system.services.BaseService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="PluginService" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true">
		<!--- ************************************************************* --->
		<cfscript>
			/* Set Controller */
			setController(arguments.controller);
			
			/* Set Service Properties */
			setColdBoxPluginsPath('coldbox.system.plugins');
			setCacheDictionary(CreateObject("component","coldbox.system.util.BaseDictionary").init('PluginMetadata'));
			
			/* Return instance */
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- Get a new plugin Instance --->
	<cffunction name="new" access="public" returntype="any" hint="Create a New Plugin Instance wether its core or custom" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="plugin" required="true" type="string"  hint="The named plugin to create">
		<cfargument name="custom" required="true" type="boolean" hint="Custom plugin or coldbox plugin">
		<!--- ************************************************************* --->
		<cfscript>
			var oPlugin = CreateObject("component", locatePluginPath(arguments.plugin,arguments.custom) ).init( controller );
			var interceptMetadata = structnew();
			
			//Interception if application is up and running. We need the interceptors.
			if ( getController().getColdboxInitiated() ){
				//Fill-up Intercepted MetaData
				interceptMetadata.pluginPath = arguments.plugin;
				interceptMetadata.custom = arguments.custom;			
				interceptMetadata.oPlugin = oPlugin;
				
				//Fire Interception
				getController().getInterceptorService().processState("afterPluginCreation",interceptMetadata);
			}
			
			//Return plugin
			return oPlugin;
		</cfscript>
	</cffunction>

	<!--- Get a new or cached plugin instance --->
	<cffunction name="get" access="public" returntype="any" hint="Get a new/cached plugin instance" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="plugin" required="true" type="string"  hint="The named plugin to create">
		<cfargument name="custom" required="true" type="boolean" hint="Custom plugin or coldbox plugin">
		<!--- ************************************************************* --->
		<cfscript>
			/* Used for caching. */
			var pluginKey = getColdboxOCM().PLUGIN_CACHEKEY_PREFIX & arguments.plugin;
			var oPlugin = structnew();
			var MetaData = "";
			var mdEntry = structnew();
			var pluginDictionaryEntry = "";
			var tester = "";
			
			/* Differentiate a Custom PluginKey */
			if ( arguments.custom ){
				pluginKey = getColdboxOCM().CUSTOMPLUGIN_CACHEKEY_PREFIX & arguments.plugin;
			}
			
			/* Lookup plugin in Cache */
			oPlugin = controller.getColdboxOCM().get(pluginKey);
			
			/* Verify it */
			if( not isObject(oPlugin) ){
				/* Object not found, proceed to create and verify */
				oPlugin = new(argumentCollection=arguments);
				
				/* Determine if we have md and cacheable, else set it  */
				if ( not getcacheDictionary().keyExists(pluginKey) ){
					/* Get Plugins MetaData and cache */
					MetaData = getMetaData(oPlugin);
					
					/* Get Default MD Entry */
					mdEntry = getNewMDEntry(); 
					
					/* Test for caching parameters */
					if ( structKeyExists(MetaData, "cache") and isBoolean(MetaData["cache"]) and MetaData["cache"] ){
						/* Plugins are NOT cached by default. */
						mdEntry.cacheable = true;
						if ( structKeyExists(MetaData,"cachetimeout") ){
							mdEntry.timeout = MetaData["cachetimeout"];
						}
						if ( structKeyExists(MetaData,"cachelastaccesstimeout") ){
							mdEntry.lastAccessTimeout = MetaData["cachelastaccesstimeout"];
						}			
					}
					/* Set Entry in dictionary */
					getcacheDictionary().setKey(pluginKey,mdEntry);	
				}
				/* Set dictionary entry for operations, it is now guaranteed. */
				pluginDictionaryEntry = getcacheDictionary().getKey(pluginKey);
				/* Do we Cache */
				if ( pluginDictionaryEntry.cacheable ){
					controller.getColdboxOCM().set(pluginKey,oPlugin,pluginDictionaryEntry.timeout,pluginDictionaryEntry.lastAccessTimeout);
				}				
			}
			//end else if instance not in cache.
			
			/* Return new or cached Instance */
			return oPlugin;
		</cfscript>
	</cffunction>
	
	<!--- ColdBox Plugins Path --->
	<cffunction name="getColdBoxPluginsPath" access="public" output="false" returntype="string" hint="Get ColdBoxPluginsPath">
		<cfreturn instance.ColdBoxPluginsPath/>
	</cffunction>
	
	<!--- Plugin Cache Metadata Dictionary --->
	<cffunction name="getcacheDictionary" access="public" output="false" returntype="struct" hint="Get the plugin cache dictionary">
		<cfreturn instance.cacheDictionary/>
	</cffunction>
	
	<!--- Clear the metadata dictionary --->
	<cffunction name="clearDictionary" access="public" returntype="void" hint="Clear the cache dictionary" output="false" >
		<cfset getcacheDictionary().clearAll()>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- Get a new MD cache entry structure --->
	<cffunction name="getNewMDEntry" access="public" returntype="struct" hint="Get a new metadata entry structure" output="false" >
		<cfscript>
			var mdEntry = structNew();
			
			mdEntry.cacheable = false;
			mdEntry.timeout = "";
			mdEntry.lastAccessTimeout = "";
			
			return mdEntry;
		</cfscript>
	</cffunction>
	
	<!--- Set the coldbox plugins Path --->
	<cffunction name="setColdBoxPluginsPath" access="private" output="false" returntype="void" hint="Set ColdBoxPluginsPath">
		<!--- ************************************************************* --->
		<cfargument name="ColdBoxPluginsPath" type="string" required="true"/>
		<!--- ************************************************************* --->
		<cfset instance.ColdBoxPluginsPath = arguments.ColdBoxPluginsPath/>
	</cffunction>
	
	<!--- Set the internal plugin cache dictionary. --->
	<cffunction name="setcacheDictionary" access="private" output="false" returntype="void" hint="Set the plugin cache dictionary. NOT EXPOSED to avoid screwups">
		<!--- ************************************************************* --->
		<cfargument name="cacheDictionary" type="coldbox.system.util.BaseDictionary" required="true"/>
		<!--- ************************************************************* --->
		<cfset instance.cacheDictionary = arguments.cacheDictionary/>
	</cffunction>
	
	<!--- Locate a Plugin Instantiation Path --->
	<cffunction name="locatePluginPath" access="private" returntype="string" hint="Locate a full plugin instantiation path from the requested plugin name" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="plugin" required="true" type="string" hint="The plugin to validate the path on.">
		<cfargument name="custom" required="true" type="boolean" hint="Whether its a custom plugin or not.">
		<!--- ************************************************************* --->
		<cfscript>
			var pluginPath = "";
			var pluginFilePath = "";
			
			/* Check if getting from custom plugins */
			if ( arguments.custom ){
				
				/* Set plugin key and file path check */
				pluginFilePath = replace(arguments.plugin,".",controller.getSetting("OSFileSeparator",true),"all") & ".cfc";
							
				/* Check for Convention First, MyPluginsPath was already setup with conventions on XMLParser */
				if ( fileExists(controller.getSetting("MyPluginsPath") & controller.getSetting("OSFileSeparator",true) & pluginFilePath ) ){
					pluginPath = "#controller.getSetting('MyPluginsInvocationPath')#.#arguments.plugin#";
				}
				else{
					/* Will search the alternate custom location */
					pluginPath = "#controller.getSetting('MyPluginsLocation')#.#arguments.plugin#";
				}
			}//end if custom plugin
			else{
				/* Create the plugin instantiation path */
				pluginPath = getColdboxPluginsPath() & "." & trim(arguments.plugin);
			}
			
			return pluginPath;
		</cfscript>
	</cffunction>

</cfcomponent>