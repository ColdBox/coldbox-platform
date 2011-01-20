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
<cfcomponent name="PluginService" output="false" hint="The coldbox plugin service" extends="coldbox.system.web.services.BaseService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="PluginService" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			// setup controller
			setController(arguments.controller);
			
			// Core Plugins Location
			instance.CORE_PLUGINS_PATH = "coldbox.system.plugins";
			// Core Extensions Location
			instance.CORE_EXTENSIONS_PATH = "coldbox.system.extensions.plugins";
			
			// Custom Convention Locations
			setCustomPluginsPath('');
			setCustomPluginsPhysicalPath('');
			setCustomPluginsExternalPath('');
			
			// Prepare Extension Points using default values
			setExtensionsPath( instance.CORE_EXTENSIONS_PATH );
			setExtensionsPhysicalPath( expandPath("/" & replace(getExtensionsPath(),".","/","all") & "/") );
			
			// Prepare MD dictionary
			setCacheDictionary(CreateObject("component","coldbox.system.core.collections.BaseDictionary").init('PluginMetadata'));
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- INTERNAL COLDBOX EVENTS ------------------------------------------->
	
	<!--- onConfigurationLoad --->
	<cffunction name="onConfigurationLoad" access="public" output="false" returntype="void">
		<cfscript>
			// Cache Reference
			instance.cache = getColdboxOCM();
			// Set the custom plugin paths
			setCustomPluginsPath(controller.getSetting("MyPluginsInvocationPath"));
			setCustomPluginsPhysicalPath(controller.getSetting("MyPluginsPath"));
			setCustomPluginsExternalPath(controller.getSetting('PluginsExternalLocation'));
			
			// Override the coldbox plugin extensions if defined in the configuration
			if( len(controller.getSetting("ColdBoxExtensionsLocation")) ){
				setExtensionsPath(controller.getSetting("ColdBoxExtensionsLocation") & ".plugins");
				setExtensionsPhysicalPath(expandPath("/" & replace(getExtensionsPath(),".","/","all") & "/"));
			}		
			
			// refLocation map
			instance.refLocationMap = structnew();	
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- Get a new plugin Instance --->
	<cffunction name="new" access="public" returntype="any" hint="Create a New Plugin Instance whether it is core or custom" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="plugin" type="any"  	  	required="true"  hint="The name (classpath) of the plugin to create">
		<cfargument name="custom" type="any"  		required="true"  hint="Custom plugin or coldbox plugin: Boolean" colddoc:generic="Boolean">
		<cfargument name="module" type="any" 	  	required="false" default="" hint="The module to retrieve the plugin from"/>
		<cfargument name="init"   type="any"  		required="false" default="true" hint="Auto init() the plugin upon construction: Boolean" colddoc:generic="Boolean"/>
		<!--- ************************************************************* --->
		<cfscript>
			var oPlugin 			= 0;
			var iData 				= structnew();
			var pluginKey 			= getPluginCacheKey(argumentCollection=arguments);
			var pluginLocation 		= "";
			var pluginLocationKey 	= arguments.plugin & arguments.custom & arguments.module;
			
			// Locate Plugin, lazy loaded and cached
			if( NOT structKeyExists(instance.refLocationMap, pluginLocationKey) ){
				instance.refLocationMap[pluginLocationKey] = locatePluginPath(argumentCollection=arguments);
			}
			pluginLocation = instance.refLocationMap[pluginLocationKey];
			
			// Create Plugin
			oPlugin = createObject("component",pluginLocation);
			
			// Determine if we have md and cacheable, else store object metadata for efficiency
			if ( not instance.cacheDictionary.keyExists(pluginKey) ){
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
		<cfargument name="plugin" type="any" required="true" hint="The name (classpath) of the plugin to create. We will search for it.">
		<cfargument name="custom" type="any" required="true" hint="Custom plugin or coldbox plugin Boolean">
		<cfargument name="module" type="any" required="false" default="" hint="The module to retrieve the plugin from"/>
		<cfargument name="init"   type="any" required="false" default="true" hint="Auto init() the plugin upon construction. Boolean"/>
		<!--- ************************************************************* --->
		<cfscript>
			var pluginKey 				= getPluginCacheKey(argumentCollection=arguments);
			var pluginDictionaryEntry 	= "";
			var refLocal				= structnew();
			var oPlugin					= "";
			
			// Lookup plugin in Cache
			refLocal.oPlugin = instance.cache.get(pluginKey);
			
			// Verify it, COMPAT MODE Remove later
			if( NOT structKeyExists(refLocal,"oPlugin") OR NOT isObject(refLocal.oPlugin) ){
				// Object not found, proceed to create and verify
				refLocal.oPlugin = new(argumentCollection=arguments);
				
				// Get plugin metadata Entry
				pluginDictionaryEntry = instance.cacheDictionary.getKey(pluginKey);
				
				// Do we Cache the plugin?
				if ( pluginDictionaryEntry.cacheable ){
					instance.cache.set(pluginKey,refLocal.oPlugin,pluginDictionaryEntry.timeout,pluginDictionaryEntry.lastAccessTimeout);
				}				
			}
			//end else if instance not in cache.
			
			return	refLocal.oPlugin;
		</cfscript>
	</cffunction>
	
	<!--- ColdBox Custom Conventions Plugins Path --->
	<cffunction name="getCustomPluginsPath" access="public" output="false" returntype="any" hint="Get the base invocation path where custom convention plugins exist.">
		<cfreturn instance.customPluginsPath/>
	</cffunction>
	
	<!--- Set the custom plugins Path --->
	<cffunction name="setCustomPluginsPath" access="public" output="false" returntype="void" hint="Set CorePluginsPath">
		<cfargument name="customPluginsPath" type="any" required="true"/>
		<cfset instance.customPluginsPath = arguments.customPluginsPath/>
	</cffunction>
	
	<!--- ColdBox Custom Conventions External Plugins Path --->
	<cffunction name="getCustomPluginsExternalPath" access="public" output="false" returntype="any" hint="Get the base invocation path where external custom convention plugins exist.">
		<cfreturn instance.customPluginsExternalPath/>
	</cffunction>
	
	<!--- Set the custom plugins Path --->
	<cffunction name="setCustomPluginsExternalPath" access="public" output="false" returntype="void" hint="Set customPluginsExternalPath">
		<cfargument name="customPluginsExternalPath" type="any" required="true"/>
		<cfset instance.customPluginsExternalPath = arguments.customPluginsExternalPath/>
	</cffunction>
	
	<!--- ColdBox Extensions Plugins Physical Path --->
	<cffunction name="getCustomPluginsPhysicalPath" access="public" output="false" returntype="string" hint="Get the physical path where custom convention plugins exist.">
		<cfreturn instance.customPluginsPhysicalPath/>
	</cffunction>
	
	<!--- Set the custom plugins Path --->
	<cffunction name="setCustomPluginsPhysicalPath" access="public" output="false" returntype="void" hint="Set customPluginsPhysicalPath">
		<cfargument name="customPluginsPhysicalPath" type="any" required="true"/>
		<cfset instance.customPluginsPhysicalPath = arguments.customPluginsPhysicalPath/>
	</cffunction>
	
	<!--- ColdBox Extensions Plugins Path --->
	<cffunction name="getExtensionsPath" access="public" output="false" returntype="any" hint="Get the base invocation path where extension plugins exist.">
		<cfreturn instance.extensionsPath/>
	</cffunction>
	
	<!--- Set the coldbox plugins Path --->
	<cffunction name="setExtensionsPath" access="public" output="false" returntype="void" hint="Set ExtensionsPath">
		<cfargument name="extensionsPath" type="any" required="true"/>
		<cfset instance.extensionsPath = arguments.extensionsPath/>
	</cffunction>
	
	<!--- Set the coldbox physical plugins Path --->
	<cffunction name="setExtensionsPhysicalPath" access="public" output="false" returntype="void" hint="Set ExtensionsPhysicalPath">
		<cfargument name="extensionsPhysicalPath" type="any" required="true"/>
		<cfset instance.extensionsPhysicalPath = arguments.extensionsPhysicalPath/>
	</cffunction>
		
	<!--- ColdBox Extensions Plugins Physical Path --->
	<cffunction name="getExtensionsPhysicalPath" access="public" output="false" returntype="any" hint="Get the physical path where extension plugins exist.">
		<cfreturn instance.extensionsPhysicalPath/>
	</cffunction>
	
	<!--- Plugin Cache Metadata Dictionary --->
	<cffunction name="getCacheDictionary" access="public" output="false" returntype="any" hint="Get the plugin cache dictionary structure">
		<cfreturn instance.cacheDictionary/>
	</cffunction>
	
	<!--- Clear the metadata dictionary --->
	<cffunction name="clearDictionary" access="public" returntype="void" hint="Clear the cache dictionary" output="false" >
		<cfset getCacheDictionary().clearAll()>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- storeMetadata --->
    <cffunction name="storeMetadata" output="false" access="private" returntype="any" hint="Store a plugin's metadata introspection, return the md struct">
    	<cfargument name="pluginKey" type="any" 	required="true" hint="The plugin cache key"/>
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
			instance.cacheDictionary.setKey(arguments.pluginKey,mdEntry);		
			
			return mdEntry;
    	</cfscript>
    </cffunction>
	
	<!--- Get a new MD cache entry structure --->
	<cffunction name="getNewMDEntry" access="private" returntype="any" hint="Get a new metadata entry structure for plugins" output="false" >
		<cfscript>
			var mdEntry = structNew();
			
			mdEntry.cacheable = false;
			mdEntry.timeout = "";
			mdEntry.lastAccessTimeout = "";
			mdEntry.init = true;
			
			return mdEntry;
		</cfscript>
	</cffunction>
	
	<!--- Set the internal plugin cache dictionary. --->
	<cffunction name="setCacheDictionary" access="private" output="false" returntype="void" hint="Set the plugin cache dictionary. NOT EXPOSED to avoid screwups">
		<cfargument name="cacheDictionary" type="any" required="true"/>
		<cfset instance.cacheDictionary = arguments.cacheDictionary/>
	</cffunction>
	
	<!--- Locate a Plugin Instantiation Path --->
	<cffunction name="locatePluginPath" access="private" returntype="any" hint="Locate a full plugin instantiation path from the requested plugin name" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="plugin" type="any" 	 	required="true" hint="The plugin to validate the path on.">
		<cfargument name="custom" type="any" 		required="true" hint="Whether its a custom plugin or not. Boolean">
		<cfargument name="module" type="any" 	 	required="false" default="" hint="The module to retrieve the plugin from"/>
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
				
				// External Locations Search
				if( len( trim( getCustomPluginsExternalPath() ) ) ){
					return getCustomPluginsExternalPath() & "." & arguments.plugin;
				}
				// If not, just return the plugin location
				return arguments.plugin;
				
			}//end if custom plugin
			
			// Check coldbox extensions
			pluginFilePath = getExtensionsPhysicalPath() & replace(arguments.plugin,".","/","all") & ".cfc";
			
			// Check Extensions locations First
			if( fileExists(pluginFilePath) ){
				return getExtensionsPath() & "." & arguments.plugin;
			}
						
			// else return the core coldbox path
			return instance.CORE_PLUGINS_PATH & "." & arguments.plugin;
		</cfscript>
	</cffunction>

	<!--- getPluginCacheKey --->
	<cffunction name="getPluginCacheKey" output="false" access="private" returntype="any" hint="Get the plugin Cache Key">
		<cfargument name="plugin" type="any"    required="true"  hint="The name (classpath) of the plugin to create">
		<cfargument name="custom" type="any" 	required="true"  hint="Custom plugin or coldbox plugin. Boolean">
		<cfargument name="module" type="any" 	required="false" default="" hint="The module to retrieve the plugin from"/>
		<cfscript>
			var pluginKey = instance.cache.PLUGIN_CACHEKEY_PREFIX & arguments.plugin;
			
			// A module Plugin
			if( len(arguments.module) ){
				return instance.cache.CUSTOMPLUGIN_CACHEKEY_PREFIX & arguments.module & ":" & arguments.plugin;
			}
			
			// Differentiate a Custom PluginKey
			if ( arguments.custom ){
				return instance.cache.CUSTOMPLUGIN_CACHEKEY_PREFIX & arguments.plugin;
			}
			
			return pluginKey;
		</cfscript>
	</cffunction>
	
</cfcomponent>