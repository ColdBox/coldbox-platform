<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
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
			setController(arguments.controller);
			
			// Core Location
			setCorePluginsPath('coldbox.system.plugins');
			
			// Custom Convention Locations
			setCustomPluginsPath('');
			setCustomPluginsPhysicalPath('');
			setCustomPluginsExternalPath('');
			
			// Extension Points
			setExtensionsPath('');
			setExtensionsPhysicalPath('');
			
			// MD dictionary
			setCacheDictionary(CreateObject("component","coldbox.system.core.collections.BaseDictionary").init('PluginMetadata'));
			
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="onConfigurationLoad" access="public" output="false" returntype="void">
		<cfscript>
			// Set convention paths 
			setCustomPluginsPath(controller.getSetting("MyPluginsInvocationPath"));
			setCustomPluginsPhysicalPath(controller.getSetting("MyPluginsPath"));
			setCustomPluginsExternalPath(controller.getSetting('PluginsExternalLocation'));
			
			// set the plugin extensions location by using the configured locations
			setExtensionsPath(controller.getSetting("ColdBoxExtensionsLocation") & ".plugins");
			setExtensionsPhysicalPath(expandPath("/" & replace(getExtensionsPath(),".","/","all") & "/"));			
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- Get a new plugin Instance --->
	<cffunction name="new" access="public" returntype="any" hint="Create a New Plugin Instance whether it is core or custom" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="plugin" type="any"  	  required="true"  hint="The name (classpath) of the plugin to create">
		<cfargument name="custom" type="boolean"  required="true"  hint="Custom plugin or coldbox plugin">
		<cfargument name="module" type="any" 	  required="false" default="" hint="The module to retrieve the plugin from"/>
		<cfargument name="init"   type="boolean"  required="false" default="true" hint="Auto init() the plugin upon construction"/>
		<!--- ************************************************************* --->
		<cfscript>
			var oPlugin 	= 0;
			var iData 		= structnew();
			var pluginKey 	= getPluginCacheKey(argumentCollection=arguments);
			
			// Create Plugin
			oPlugin = createObject("component",locatePluginPath(argumentCollection=arguments));
			
			// Determine if we have md and cacheable, else store object metadata for efficiency
			if ( not getCacheDictionary().keyExists(pluginKey) ){
				storeMetadata(pluginKey,getMetadata(oPlugin));
			}
			
			// Is it plugin family or not? If not, then decorate it
			if( NOT isFamilyType("plugin",oPlugin) ){
				convertToColdBox( "plugin", oPlugin );
				// Init super
				oPlugin.$super.init( controller );
				// Check if doing cbInit()
				if( structKeyExists(oPlugin, "$cbInit") ){ oPlugin.$cbInit( controller ); }
			}
				
			// init It if it exists
			if( structKeyExists(oPlugin,"init") and arguments.init ){
				oPlugin.init( controller );
			}						
			
			//Interception if application is up and running. We need the interceptors.
			if ( controller.getColdboxInitiated() ){
				//Fill-up Intercepted MetaData
				iData.pluginPath = arguments.plugin;
				iData.custom 	 = arguments.custom;	
				iData.module 	 = arguments.module;		
				iData.oPlugin    = oPlugin;
				
				//Fire Interception
				controller.getInterceptorService().processState("afterPluginCreation",iData);
			}
			
			//Return plugin
			return oPlugin;
		</cfscript>
	</cffunction>
	
	<!--- Get a new or cached plugin instance --->
	<cffunction name="get" access="public" returntype="any" hint="Get a new/cached plugin instance" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="plugin" type="any"      required="true" hint="The name (classpath) of the plugin to create. We will search for it.">
		<cfargument name="custom" type="boolean"  required="true" hint="Custom plugin or coldbox plugin">
		<cfargument name="module" type="any" 	  required="false" default="" hint="The module to retrieve the plugin from"/>
		<cfargument name="init"   type="boolean"  required="false" default="true" hint="Auto init() the plugin upon construction"/>
		<!--- ************************************************************* --->
		<cfscript>
			var pluginKey = getPluginCacheKey(argumentCollection=arguments);
			var oPlugin = 0;
			var pluginDictionaryEntry = "";
			
			// Lookup plugin in Cache
			oPlugin = controller.getColdboxOCM().get(pluginKey);
			
			// Verify it
			if( not isObject(oPlugin) ){
				// Object not found, proceed to create and verify
				oPlugin = new(argumentCollection=arguments);
				
				// Get plugin metadata Entry
				pluginDictionaryEntry = getCacheDictionary().getKey(pluginKey);
				
				// Do we Cache the plugin?
				if ( pluginDictionaryEntry.cacheable ){
					controller.getColdboxOCM().set(pluginKey,oPlugin,pluginDictionaryEntry.timeout,pluginDictionaryEntry.lastAccessTimeout);
				}				
			}
			//end else if instance not in cache.
			
			return oPlugin;
		</cfscript>
	</cffunction>
	
	<!--- ColdBox Plugins Path --->
	<cffunction name="getCorePluginsPath" access="public" output="false" returntype="string" hint="Get the base invocation path where core plugins exist.">
		<cfreturn instance.corePluginsPath/>
	</cffunction>
	
	<!--- ColdBox Custom Conventions Plugins Path --->
	<cffunction name="getCustomPluginsPath" access="public" output="false" returntype="string" hint="Get the base invocation path where custom convention plugins exist.">
		<cfreturn instance.customPluginsPath/>
	</cffunction>
	
	<!--- ColdBox Custom Conventions External Plugins Path --->
	<cffunction name="getCustomPluginsExternalPath" access="public" output="false" returntype="string" hint="Get the base invocation path where external custom convention plugins exist.">
		<cfreturn instance.customPluginsExternalPath/>
	</cffunction>
	
	<!--- ColdBox Extensions Plugins Physical Path --->
	<cffunction name="getCustomPluginsPhysicalPath" access="public" output="false" returntype="string" hint="Get the physical path where custom convention plugins exist.">
		<cfreturn instance.customPluginsPhysicalPath/>
	</cffunction>
	
	<!--- ColdBox Extensions Plugins Path --->
	<cffunction name="getExtensionsPath" access="public" output="false" returntype="string" hint="Get the base invocation path where extension plugins exist.">
		<cfreturn instance.extensionsPath/>
	</cffunction>
	
	<!--- ColdBox Extensions Plugins Physical Path --->
	<cffunction name="getExtensionsPhysicalPath" access="public" output="false" returntype="string" hint="Get the physical path where extension plugins exist.">
		<cfreturn instance.extensionsPhysicalPath/>
	</cffunction>
	
	<!--- Plugin Cache Metadata Dictionary --->
	<cffunction name="getCacheDictionary" access="public" output="false" returntype="struct" hint="Get the plugin cache dictionary">
		<cfreturn instance.cacheDictionary/>
	</cffunction>
	
	<!--- Clear the metadata dictionary --->
	<cffunction name="clearDictionary" access="public" returntype="void" hint="Clear the cache dictionary" output="false" >
		<cfset getCacheDictionary().clearAll()>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- storeMetadata --->
    <cffunction name="storeMetadata" output="false" access="private" returntype="struct" hint="Store a plugin's metadata introspection">
    	<cfargument name="pluginKey" type="string" 	required="true" hint="The plugin cache key"/>
    	<cfargument name="pluginMD"  type="any" 	required="true" hint="The plugin's metadata"/>
    	<cfscript>
    		var metadata = arguments.pluginMD;
			var mdEntry = getNewMDEntry(); 
			
			// Test for caching parameters
			if ( structKeyExists(metadata, "cache") and isBoolean(metadata["cache"]) and metadata["cache"] ){
				
				mdEntry.cacheable = true;
				
				// Timeout
				if ( structKeyExists(metadata,"cachetimeout") ){
					mdEntry.timeout = metadata["cachetimeout"];
				}
				
				// Idle Timeout
				if ( structKeyExists(metadata,"cachelastaccesstimeout") ){
					mdEntry.lastAccessTimeout = metadata["cachelastaccesstimeout"];
				}			
			}
			
			// Test for singleton annotation
			if( structKeyExists(metadata,"singleton") ){
				mdEntry.cacheable = true;
				mdEntry.timeout = 0;
			}
			
			// Init annotation
			if( structKeyExists(metadata,"autoInit") and isBoolean(metadata.autoInit) ){
				mdEntry.init = metadata.autoInit;
			}
			
			// Set Entry in dictionary
			getcacheDictionary().setKey(arguments.pluginKey,mdEntry);		
			
			return mdEntry;
    	</cfscript>
    </cffunction>
	
	<!--- Get a new MD cache entry structure --->
	<cffunction name="getNewMDEntry" access="private" returntype="struct" hint="Get a new metadata entry structure for plugins" output="false" >
		<cfscript>
			var mdEntry = structNew();
			
			mdEntry.cacheable = false;
			mdEntry.timeout = "";
			mdEntry.lastAccessTimeout = "";
			mdEntry.init = true;
			
			return mdEntry;
		</cfscript>
	</cffunction>
	
	<!--- Set the coldbox plugins Path --->
	<cffunction name="setCorePluginsPath" access="private" output="false" returntype="void" hint="Set CorePluginsPath">
		<cfargument name="corePluginsPath" type="string" required="true"/>
		<cfset instance.corePluginsPath = arguments.corePluginsPath/>
	</cffunction>
	
	<!--- Set the custom plugins Path --->
	<cffunction name="setCustomPluginsPath" access="private" output="false" returntype="void" hint="Set CorePluginsPath">
		<cfargument name="customPluginsPath" type="string" required="true"/>
		<cfset instance.customPluginsPath = arguments.customPluginsPath/>
	</cffunction>
	
	<!--- Set the custom plugins Path --->
	<cffunction name="setCustomPluginsExternalPath" access="private" output="false" returntype="void" hint="Set customPluginsExternalPath">
		<cfargument name="customPluginsExternalPath" type="string" required="true"/>
		<cfset instance.customPluginsExternalPath = arguments.customPluginsExternalPath/>
	</cffunction>
	
	<!--- Set the custom plugins Path --->
	<cffunction name="setCustomPluginsPhysicalPath" access="private" output="false" returntype="void" hint="Set customPluginsPhysicalPath">
		<cfargument name="customPluginsPhysicalPath" type="string" required="true"/>
		<cfset instance.customPluginsPhysicalPath = arguments.customPluginsPhysicalPath/>
	</cffunction>
	
	<!--- Set the coldbox plugins Path --->
	<cffunction name="setExtensionsPath" access="private" output="false" returntype="void" hint="Set ExtensionsPath">
		<cfargument name="extensionsPath" type="string" required="true"/>
		<cfset instance.extensionsPath = arguments.extensionsPath/>
	</cffunction>
	
	<!--- Set the coldbox physical plugins Path --->
	<cffunction name="setExtensionsPhysicalPath" access="private" output="false" returntype="void" hint="Set ExtensionsPhysicalPath">
		<cfargument name="extensionsPhysicalPath" type="string" required="true"/>
		<cfset instance.extensionsPhysicalPath = arguments.extensionsPhysicalPath/>
	</cffunction>
	
	<!--- Set the internal plugin cache dictionary. --->
	<cffunction name="setCacheDictionary" access="private" output="false" returntype="void" hint="Set the plugin cache dictionary. NOT EXPOSED to avoid screwups">
		<cfargument name="cacheDictionary" type="coldbox.system.core.collections.BaseDictionary" required="true"/>
		<cfset instance.cacheDictionary = arguments.cacheDictionary/>
	</cffunction>
	
	<!--- Locate a Plugin Instantiation Path --->
	<cffunction name="locatePluginPath" access="private" returntype="string" hint="Locate a full plugin instantiation path from the requested plugin name" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="plugin" type="any" 	 required="true" hint="The plugin to validate the path on.">
		<cfargument name="custom" type="boolean" required="true" hint="Whether its a custom plugin or not.">
		<cfargument name="module" type="any" 	 required="false" default="" hint="The module to retrieve the plugin from"/>
		<!--- ************************************************************* --->
		<cfscript>
			var pluginFilePath = "";
			var mConfig = "";
			
			// Check if getting from custom plugins
			if ( arguments.custom OR len(arguments.module) ){
				
				// Set plugin key and file path check
				pluginFilePath = replace(arguments.plugin,".","/","all") & ".cfc";
				
				// Is this a Module Call?
				if( len(arguments.module) ){
					mConfig = controller.getSetting("modules");
					// Verify module
					if( NOT structKeyExists(mConfig,arguments.module) ){
						getUtil().throwit(message="The module requested #arguments.module# does not exist or has not been loaded.",
									  	  detail="Modules defined are #structKeyList(mConfig)#",
									  	  type="PluginService.ModuleConfigurationNotFound");
					}
					
					// Verify it exists
					if( fileExists(mConfig[arguments.module].pluginsPhysicalPath & "/" & pluginFilePath) ){
						return "#mConfig[arguments.module].pluginInvocationPath#.#arguments.plugin#";
					}
					
					// Else throw exception
					getUtil().throwit(message="Plugin #arguments.plugin# was not located in the specified module: #arguments.module#",
									  detail="The path search was: ",
									  type="PluginService.ModulePluginNotFound");
				}
				
				// Check for Convention First, pluginsExternalLocation was already setup with conventions
				if ( fileExists(getCustomPluginsPhysicalPath() & "/" & pluginFilePath ) ){
					return "#getCustomPluginsPath()#.#arguments.plugin#";
				}
				
				// Else default to search the alternate custom external locations and just return, no checking, if it fails it fails.
				return "#getCustomPluginsExternalPath()#.#arguments.plugin#";
				
			}//end if custom plugin
			
			// Plugin File Path to check, start with extensions first.
			pluginFilePath = getExtensionsPhysicalPath() & replace(arguments.plugin,".","/","all") & ".cfc";
			
			// Check Extensions locations First
			if( fileExists(pluginFilePath) ){
				return getExtensionsPath() & "." & arguments.plugin;
			}
			
			// Else return the core coldbox path
			return getCorePluginsPath() & "." & arguments.plugin;
		</cfscript>
	</cffunction>

	<!--- getPluginCacheKey --->
	<cffunction name="getPluginCacheKey" output="false" access="private" returntype="string" hint="Get the plugin Cache Key">
		<cfargument name="plugin" type="any"     required="true"  hint="The name (classpath) of the plugin to create">
		<cfargument name="custom" type="boolean" required="true"  hint="Custom plugin or coldbox plugin">
		<cfargument name="module" type="any" 	 required="false" default="" hint="The module to retrieve the plugin from"/>
		<cfscript>
			var pluginKey = getColdboxOCM().PLUGIN_CACHEKEY_PREFIX & arguments.plugin;
			
			// A module Plugin
			if( len(arguments.module) ){
				return getColdboxOCM().CUSTOMPLUGIN_CACHEKEY_PREFIX & arguments.module & ":" & arguments.plugin;
			}
			
			// Differentiate a Custom PluginKey
			if ( arguments.custom ){
				return getColdboxOCM().CUSTOMPLUGIN_CACHEKEY_PREFIX & arguments.plugin;
			}
			
			return pluginKey;
		</cfscript>
	</cffunction>
	
</cfcomponent>