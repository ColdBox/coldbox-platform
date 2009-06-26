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
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			/* Set Controller */
			setController(arguments.controller);
			
			/* Set Service Properties */
			setColdBoxPluginsPath('coldbox.system.plugins');
			setColdBoxExtensionsPluginsPath('coldbox.system.extensions.plugins');
			setCacheDictionary(CreateObject("component","coldbox.system.util.collections.BaseDictionary").init('PluginMetadata'));
			
			/* Return instance */
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- Get a new plugin Instance --->
	<cffunction name="new" access="public" returntype="any" hint="Create a New Plugin Instance whether it is core or custom" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="plugin" required="true" type="string"  hint="The name (classpath) of the plugin to create">
		<cfargument name="custom" required="true" type="boolean" hint="Custom plugin or coldbox plugin">
		<!--- ************************************************************* --->
		<cfscript>
			var oPlugin = 0;
			var interceptMetadata = structnew();
			
			/* Create Plugin */
			oPlugin = createObject("component",locatePluginPath(argumentCollection=arguments));
			
			/* Init It if it exists, more flexible now. */
			if( structKeyExists(oPlugin,"init") ){
				oPlugin.init( controller );
			}						
			
			//Interception if application is up and running. We need the interceptors.
			if ( controller.getColdboxInitiated() ){
				//Fill-up Intercepted MetaData
				interceptMetadata.pluginPath = arguments.plugin;
				interceptMetadata.custom = arguments.custom;			
				interceptMetadata.oPlugin = oPlugin;
				
				//Fire Interception
				controller.getInterceptorService().processState("afterPluginCreation",interceptMetadata);
			}
			
			//Return plugin
			return oPlugin;
		</cfscript>
	</cffunction>

	<!--- Get a new or cached plugin instance --->
	<cffunction name="get" access="public" returntype="any" hint="Get a new/cached plugin instance" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="plugin" required="true" type="string"  hint="The name (classpath) of the plugin to create. We will search for it.">
		<cfargument name="custom" required="true" type="boolean" hint="Custom plugin or coldbox plugin">
		<!--- ************************************************************* --->
		<cfscript>
			/* Used for caching. */
			var pluginKey = getColdboxOCM().PLUGIN_CACHEKEY_PREFIX & arguments.plugin;
			var oPlugin = 0;
			var pluginDictionaryEntry = "";
			
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
					storeMetadata(pluginKey,getMetadata(oPlugin));
				}
				
				/* Get Cache Entries */
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
	
	<!--- ColdBox Extensions Plugins Path --->
	<cffunction name="getColdBoxExtensionsPluginsPath" access="public" output="false" returntype="string" hint="Get ColdBoxExtensionsPluginsPath">
		<cfreturn instance.ColdBoxExtensionsPluginsPath/>
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
	
	<!--- storeMetadata --->
    <cffunction name="storeMetadata" output="false" access="private" returntype="void" hint="Store a plugin's metadata introspection">
    	<cfargument name="pluginKey" type="string" 	required="true" default="" hint="The plugin cache key"/>
    	<cfargument name="pluginMD"  type="any" 	required="true" hint="The plugin target"/>
    	<cfscript>
    		var metadata = arguments.pluginMD;
			var mdEntry = getNewMDEntry(); 
			
			/* Test for caching parameters */
			if ( structKeyExists(metadata, "cache") and isBoolean(metadata["cache"]) and metadata["cache"] ){
				/* Plugins are NOT cached by default. */
				mdEntry.cacheable = true;
				if ( structKeyExists(metadata,"cachetimeout") ){
					mdEntry.timeout = metadata["cachetimeout"];
				}
				if ( structKeyExists(metadata,"cachelastaccesstimeout") ){
					mdEntry.lastAccessTimeout = metadata["cachelastaccesstimeout"];
				}			
			}
			/* Test for singleton parameters */
			if( structKeyExists(metadata,"singleton") and isBoolean(metadata.singleton) and metadata.singleton){
				mdEntry.cacheable = true;
				mdEntry.timeout = 0;
			}
			/* Set Entry in dictionary */
			getcacheDictionary().setKey(arguments.pluginKey,mdEntry);		
    	</cfscript>
    </cffunction>
	
	<!--- Get a new MD cache entry structure --->
	<cffunction name="getNewMDEntry" access="private" returntype="struct" hint="Get a new metadata entry structure" output="false" >
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
		<cfargument name="ColdBoxPluginsPath" type="string" required="true"/>
		<cfset instance.ColdBoxPluginsPath = arguments.ColdBoxPluginsPath/>
	</cffunction>
	
	<!--- Set the coldbox plugins Path --->
	<cffunction name="setColdBoxExtensionsPluginsPath" access="private" output="false" returntype="void" hint="Set ColdBoxExtensionsPluginsPath">
		<cfargument name="ColdBoxExtensionsPluginsPath" type="string" required="true"/>
		<cfset instance.ColdBoxExtensionsPluginsPath = arguments.ColdBoxExtensionsPluginsPath/>
	</cffunction>
	
	<!--- Set the internal plugin cache dictionary. --->
	<cffunction name="setcacheDictionary" access="private" output="false" returntype="void" hint="Set the plugin cache dictionary. NOT EXPOSED to avoid screwups">
		<cfargument name="cacheDictionary" type="coldbox.system.util.collections.BaseDictionary" required="true"/>
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
				pluginFilePath = replace(arguments.plugin,".","/","all") & ".cfc";
							
				/* Check for Convention First, MyPluginsPath was already setup with conventions on XMLParser */
				if ( fileExists(controller.getSetting("MyPluginsPath") & "/" & pluginFilePath ) ){
					pluginPath = "#controller.getSetting('MyPluginsInvocationPath')#.#arguments.plugin#";
				}
				else{
					/* Will search the alternate custom location */
					pluginPath = "#controller.getSetting('PluginsExternalLocation')#.#arguments.plugin#";
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