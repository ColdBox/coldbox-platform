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
			instance.customPluginsPath 			= '';
			instance.customPluginsPhysicalPath 	= '';
			instance.customPluginsExternalPath 	= '';
			
			// Prepare Extension Points using default values
			instance.extensionsPath = instance.CORE_EXTENSIONS_PATH;
			instance.extensionsPhysicalPath = expandPath("/" & replace(instance.extensionsPath,".","/","all") & "/");
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- Configure ------------------------------------------->
	
	<!--- configure --->
	<cffunction name="configure" access="public" output="false" returntype="void">
		<cfscript>
			// Local References
			instance.cache 				= getColdboxOCM();
			instance.interceptorService	= controller.getInterceptorService();
			
			// Set the custom plugin paths
			instance.customPluginsPath 			= controller.getSetting("MyPluginsInvocationPath");
			instance.customPluginsPhysicalPath 	= controller.getSetting("MyPluginsPath");
			instance.customPluginsExternalPath 	= controller.getSetting('PluginsExternalLocation');
			
			// Override the coldbox plugin extensions if defined in the configuration
			if( len(controller.getSetting("ColdBoxExtensionsLocation")) ){
				instance.extensionsPath = controller.getSetting("ColdBoxExtensionsLocation") & ".plugins";
				instance.extensionsPhysicalPath = expandPath("/" & replace(instance.extensionsPath,".","/","all") & "/");
			}		
			
			// refLocation map for location caching
			instance.refLocationMap = structnew();	
			
			// Plugin base class
			instance.PLUGIN_BASE_CLASS = "coldbox.system.Plugin";
		</cfscript>
	</cffunction>
	    
<!------------------------------------------- EVENTS ------------------------------------------>

	<!--- afterInstanceAutowire --->
    <cffunction name="afterInstanceAutowire" output="false" access="public" returntype="void" hint="Called by wirebox once instances are autowired">
		<cfargument name="event" />
		<cfargument name="interceptData" />
    	<cfscript>
			var attribs = interceptData.mapping.getExtraAttributes();
			var iData 	= {};
			
			// listen to plugins only
			if( controller.getColdboxInitiated() AND structKeyExists(attribs, "isPlugin") ){
				//Fill-up Intercepted MetaData
				iData.pluginPath = attribs.pluginPath;
				iData.custom 	 = attribs.custom;	
				iData.module 	 = attribs.module;		
				iData.oPlugin    = interceptData.target;
				
				//Fire Interception
				instance.interceptorService.processState("afterPluginCreation",iData);
			}
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
			var pluginLocation 		= "";
			var pluginLocationKey 	= arguments.plugin & arguments.custom & arguments.module;
			var attribs				= "";
			var wirebox				= controller.getWireBox();
					
			// Locate Plugin, lazy loaded and cached
			if( NOT structKeyExists(instance.refLocationMap, pluginLocationKey) ){
				instance.refLocationMap[pluginLocationKey] = locatePluginPath(argumentCollection=arguments);
			}
			pluginLocation = instance.refLocationMap[pluginLocationKey];
			
			// Check if plugin mapped?
			if( NOT wirebox.getBinder().mappingExists( pluginLocation ) ){
				// lazy load checks for wirebox
				wireboxSetup();
				// build plugin attributes
				attribs = {
					pluginPath 	= pluginLocation,
					custom 	 	= arguments.custom,
					module 		= arguments.module,
					isPlugin	= true
				};
				// feed this plugin to wirebox with virtual inheritance just in case, use registerNewInstance so its thread safe
				wirebox.registerNewInstance(name=pluginLocation,instancePath=pluginLocation)
					.setVirtualInheritance( "coldbox.system.Plugin" )
					.addDIConstructorArgument(name="controller", value=controller)
					.setExtraAttributes( attribs );
			}
			
			// retrieve, build and wire from wirebox
			oPlugin = wirebox.getInstance( pluginLocation );			
			
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
			return new(argumentCollection=arguments);
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

<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- wireboxSetup --->    
    <cffunction name="wireboxSetup" output="false" access="private" returntype="any" hint="Verifies the setup for plugin classes is online">    
    	<cfscript>	    
			var wirebox = controller.getWireBox();
			// Check if handler mapped?
			if( NOT wirebox.getBinder().mappingExists( instance.PLUGIN_BASE_CLASS ) ){
				// feed the base class
				wirebox.registerNewInstance(name=instance.PLUGIN_BASE_CLASS,instancePath=instance.PLUGIN_BASE_CLASS)
					.addDIConstructorArgument(name="controller", value=controller);
				// register ourselves to listen for autowirings
				instance.interceptorService.registerInterceptionPoint("PluginService","afterInstanceAutowire",this);
			}
    	</cfscript>    
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
				if ( fileExists( instance.customPluginsPhysicalPath & "/" & pluginFilePath ) ){
					return "#instance.customPluginsPath#.#arguments.plugin#";
				}
				
				// External Locations Search
				if( len( trim( instance.customPluginsExternalPath ) ) ){
					return instance.customPluginsExternalPath & "." & arguments.plugin;
				}
				// If not, just return the plugin location
				return arguments.plugin;
				
			}//end if custom plugin
			
			// Check coldbox extensions
			pluginFilePath = instance.extensionsPhysicalPath & replace(arguments.plugin,".","/","all") & ".cfc";
			
			// Check Extensions locations First
			if( fileExists( pluginFilePath ) ){
				return instance.extensionsPath & "." & arguments.plugin;
			}
						
			// else return the core coldbox path
			return instance.CORE_PLUGINS_PATH & "." & arguments.plugin;
		</cfscript>
	</cffunction>

</cfcomponent>