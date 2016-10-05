<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 12, 2010
Description :
I oversee and manage ColdBox modules

----------------------------------------------------------------------->
<cfcomponent output="false" hint="I oversee and manage ColdBox modules" extends="coldbox.system.web.services.BaseService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="ModuleService" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			variables.controller = arguments.controller;

			// service properties
			instance.logger 			= "";
			instance.mConfigCache 		= {};
			instance.moduleRegistry 	= createObject( "java", "java.util.LinkedHashMap" ).init();
			instance.cfmappingRegistry 	= {};

			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- INTERNAL COLDBOX EVENTS ------------------------------------------->

	<!--- onConfigurationLoad --->
    <cffunction name="onConfigurationLoad" output="false" access="public" returntype="void" hint="Called by loader service when configuration file loads">
    	<cfscript>
			//Get Local Logger Now Configured
			instance.logger = controller.getLogBox().getLogger(this);

    		// Register The Modules
			registerAllModules();
    	</cfscript>
    </cffunction>

	<!--- onShutdown --->
    <cffunction name="onShutdown" output="false" access="public" returntype="void" hint="Called when the application stops">
    	<cfscript>
    		// Unload all modules
			unloadAll();
    	</cfscript>
    </cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- getModuleRegistry --->
    <cffunction name="getModuleRegistry" output="false" access="public" returntype="struct" hint="Get the discovered module's registry structure">
    	<cfreturn instance.moduleRegistry>
    </cffunction>

    <!--- getModuleConfigCache  --->
    <cffunction name="getModuleConfigCache" access="public" returntype="struct" output="false" hint="Return the loaded module's configuration objects">
    	<cfreturn instance.mConfigCache>
    </cffunction>

	<!--- rebuildRegistry --->
    <cffunction name="rebuildModuleRegistry" output="false" access="public" returntype="any" hint="Rescan the module locations directories and re-register all located modules, this method does NOT register or activate any modules, it just reloads the found registry">
    	<cfscript>
    		// Add the application's module's location and the system core modules
    		var modLocations   = [ controller.getSetting( "ModulesLocation" ) ];
			// Add the application's external locations array.
			modLocations.addAll( controller.getSetting( "ModulesExternalLocation" ) );
			// Add the ColdBox Core Modules Location
			arrayPrepend( modLocations, "/coldbox/system/modules" );
			// iterate through locations and build the module registry in order
			buildRegistry( modLocations );
		</cfscript>
    </cffunction>

	<!--- registerAllModules --->
	<cffunction name="registerAllModules" output="false" access="public" returntype="ModuleService" hint="Register all modules for the application. Usually called by framework to load configuration data.">
		<cfscript>
			var foundModules   = "";
			var includeModules = controller.getSetting( "modulesInclude" );

			// Register the initial empty module configuration holder structure
			structClear( controller.getSetting( "modules" ) );
			// clean the registry as we are registering all modules
			instance.moduleRegistry = createObject( "java", "java.util.LinkedHashMap" ).init();
			// Now rebuild it
			rebuildModuleRegistry();

			// Are we using an include list?
			if( arrayLen( includeModules ) ){
				for( var thisModule in includeModules ){
					// does module exists in the registry? We only register what is found
					if( structKeyExists( instance.moduleRegistry, thisModule ) ){
						registerModule( thisModule );
					}
				}
				return this;
			}

			// Iterate through registry and register each module
			var aModules = structKeyArray( instance.moduleRegistry );
			for( var thisModule in aModules ){
				if( canLoad( thisModule ) ){
					registerModule( thisModule );
				}
			}

			return this;
		</cfscript>
	</cffunction>

	<!--- registerAndActivateModule --->
    <cffunction name="registerAndActivateModule" output="false" access="public" returntype="void" hint="Register and activate a new module">
    	<cfargument name="moduleName" 		type="string" required="true" hint="The name of the module to load."/>
		<cfargument name="invocationPath" 	type="string" required="false" default="" hint="The module's invocation path to its root from the webroot (the instantiation path,ex:myapp.myCustomModules), if empty we use registry location, if not we are doing a explicit name+path registration. Do not include the module name, you passed that in the first argument right"/>
		<cfscript>
			registerModule( arguments.moduleName, arguments.invocationPath );
			activateModule( arguments.moduleName );
		</cfscript>
    </cffunction>

	<!--- registerModule --->
	<cffunction name="registerModule" output="false" access="public" returntype="boolean" hint="Register a module's configuration information and config object">
		<cfargument name="moduleName" 		type="string" 	required="true" hint="The name of the module to load."/>
		<cfargument name="invocationPath" 	type="string" 	required="false" default="" hint="The module's invocation path to its root from the webroot (the instantiation path,ex:myapp.myCustomModules), if empty we use registry location, if not we are doing a explicit name+path registration. Do not include the module name, you passed that in the first argument right"/>
		<cfargument name="parent"			type="string" 	required="false" default="" hint="The name of the parent module">
		<cfargument name="force" 			type="boolean" 	required="false" default="false" hint="Force a registration"/>
		<cfscript>
			// Module To Load
			var modName 				= arguments.moduleName;
			var modulesConfiguration	= controller.getSetting( "modules" );
			var appSettings 			= controller.getConfigSettings();


			// Check if incoming invocation path is sent, if so, register as new module
			if( len( arguments.invocationPath ) ){
				// Check if passed module name is already registered
				if( structKeyExists( instance.moduleRegistry, arguments.moduleName ) AND !arguments.force ){
					instance.logger.warn( "The module #arguments.moduleName# has already been registered, so skipping registration" );
					return false;
				}
				// register new incoming location
				instance.moduleRegistry[ arguments.moduleName ] = {
					locationPath 	= "/" & replace( arguments.invocationPath,".","/","all" ),
					physicalPath 	= expandPath( "/" & replace( arguments.invocationPath,".","/","all" ) ),
					invocationPath 	= arguments.invocationPath
				};
			}

			// Check if passed module name is not loaded into the registry
			if( NOT structKeyExists( instance.moduleRegistry, arguments.moduleName ) ){
				throw( message="The module #arguments.moduleName# is not valid",
					   detail="Valid module names are: #structKeyList( instance.moduleRegistry )#",
					   type="ModuleService.InvalidModuleName" );
			}

			// Setup module metadata info
			var modulesLocation 		= instance.moduleRegistry[ modName ].locationPath;
			var modulesPath 			= instance.moduleRegistry[ modName ].physicalPath;
			var modulesInvocationPath	= instance.moduleRegistry[ modName ].invocationPath;
			var modLocation				= modulesPath & "/" & modName;
			var isBundle				= listLast( modLocation, "-" ) eq "bundle";

			// Check if module config exists, or we have a module.
			if( NOT fileExists( modLocation & "/ModuleConfig.cfc" ) && NOT isBundle ){
				instance.logger.WARN( "The module (#modName#) cannot be loaded as it does not have a ModuleConfig.cfc in its root. Path Checked: #modLocation#" );
				return false;
			}

			// Module Bundle Registration
			if( isBundle ){
				// Bundle Loading
				var aBundleModules = directoryList( modLocation, false, "array" );
				for( var thisModule in aBundleModules ){
					// cleanup module name
					var bundleModuleName = listLast( thisModule, "/\" );
					// register the bundle module if not in exclude list
					if( canLoad( bundleModuleName ) ){
						registerModule( 
							moduleName		= bundleModuleName,
							invocationPath	= modulesInvocationPath & "." & modName,
							parent			= modName,
							force			= true 
						);
					} else {
						instance.logger.warn( "The module (#bundleModuleName#) cannot load as it is in the excludes list" );
					}
				}
				// the bundle has loaded, it needs no config data
				return true;
			}

			// lock registration
			lock name="module.#getController().getAppHash()#.registration.#arguments.modulename#" type="exclusive" throwontimeout="true" timeout="20"{

				// Setup Vanilla Config information for module
				var mConfig = {
					// Module MetaData and Directives
					title				= "",
					// execution aliases
					aliases				= [],
					author				="",
					webURL				="",
					description			="",
					version				="",
					// view check in parent first
					viewParentLookup 	= "true",
					// layout check in parent first
					layoutParentLookup 	= "true",
					// SES entry point
					entryPoint 			= "",
					// ColdFusion mapping
					cfmapping			= "",
					// Models namespsace
					modelNamespace		= modName,
					// Auto map models flag
					autoMapModels		= true,
					// when this registration ocurred
					loadTime 			= now(),
					// Flag that denotes if the module has been activated or not
					activated 			= false,
					// Any dependencies this module requires to be loaded first
					dependencies		= [],
					// Flag that says if this module should NOT be loaded
					disabled			= false,
					// flag that says if this module can be activated or not
					activate			= true,
					// flag that determines if the module settings overrides any
					// module settings in the parent config (ColdBox.cfc) or
					// if the parent settings get merged (and overwrite the defaults).
					parseParentSettings = true,
					// Module Configurations
					path				 	= modLocation,
					invocationPath 			= modulesInvocationPath & "." & modName,
					mapping 				= modulesLocation & "/" & modName,
					handlerInvocationPath 	= modulesInvocationPath & "." & modName,
					handlerPhysicalPath     = modLocation,
					modelsInvocationPath    = modulesInvocationPath & "." & modName,
					modelsPhysicalPath		= modLocation,
					registeredHandlers 		= '',
					datasources				= {},
					parentSettings			= {},
					settings 				= {},
					interceptors 			= [],
					interceptorSettings     = { customInterceptionPoints = "" },
					layoutSettings			= { defaultLayout = ""},
					routes 					= [],
					conventions = {
						handlersLocation 	= "handlers",
						layoutsLocation 	= "layouts",
						viewsLocation 		= "views",
						modelsLocation      = "models",
						includesLocation    = "includes"
					},
					childModules			= [],
					parent 					= arguments.parent
				};

				// Load Module configuration from cfc and store it in module Config Cache
				var oConfig = loadModuleConfiguration( mConfig, arguments.moduleName );
				// Verify if module has been disabled
				if( mConfig.disabled ){
					if( instance.logger.canDebug() ){
						instance.logger.debug( "Skipping module: #arguments.moduleName# as it has been disabled!" );
					}
					return false;
				} else {
					instance.mConfigCache[ modName ] = oConfig;
				}
				// Store module configuration in main modules configuration
				modulesConfiguration[ modName ] = mConfig;
				// Link aliases by reference in both modules list and config cache
				for( var thisAlias in mConfig.aliases ){
					modulesConfiguration[ thisAlias ] 	= modulesConfiguration[ modName ];
					instance.mConfigCache[ thisAlias ]  = instance.mConfigCache[ modName ];
				}
				// Update the paths according to conventions
				mConfig.handlerInvocationPath 	&= ".#replace( mConfig.conventions.handlersLocation, "/", ".", "all" )#";
				mConfig.handlerPhysicalPath     &= "/#mConfig.conventions.handlersLocation#";
				mConfig.modelsInvocationPath    &= ".#replace( mConfig.conventions.modelsLocation, "/", ".", "all" )#";
				mConfig.modelsPhysicalPath		&= "/#mConfig.conventions.modelsLocation#";
				// Register CFML Mapping if it exists, for loading purposes
				if( len( trim( mConfig.cfMapping ) ) ){
					controller.getUtil().addMapping( name=mConfig.cfMapping, path=mConfig.path );
					instance.cfmappingRegistry[ mConfig.cfMapping ] = mConfig.path;
				}
				// Register Custom Interception Points
				controller.getInterceptorService().appendInterceptionPoints( mConfig.interceptorSettings.customInterceptionPoints );
				// Register Parent Settings
				structAppend( appSettings, mConfig.parentSettings, true );
				// Register Module Datasources
				structAppend( appSettings.datasources, mConfig.datasources, true );
				// Inception?
				if( directoryExists( mConfig.path & "/modules" ) ){
					// register the children
					var childModules = directoryList( mConfig.path & "/modules", false, "array" );
					for( var thisChild in childModules ){
						// cleanup module name
						var childName = listLast( thisChild, "/\" );
						// verify ModuleConfig exists, else skip
						if( fileExists( thisChild & "/ModuleConfig.cfc" ) ){
							// add to parent children
							arrayAppend( mConfig.childModules, childname );
							// register it
							registerModule( moduleName=childName,
											invocationPath=mConfig.invocationPath & ".modules",
											parent=modName );
						} else if( instance.logger.canDebug() ){
							instance.logger.debug( "Inception Module #childName# does not have a valid ModuleConfig.cfc in its root, so skipping registration" );
						}
					}
				}

				// Log registration
				if( instance.logger.canDebug() ){
					instance.logger.debug( "Module #arguments.moduleName# registered successfully." );
				}
			} // end lock

			return true;
		</cfscript>
	</cffunction>

	<!--- loadMappings --->
    <cffunction name="loadMappings" output="false" access="public" returntype="any" hint="Load all module mappings">
    	<cfscript>
			// Iterate through cfmapping registry and load them
			for( var thisMapping in instance.cfmappingRegistry ){
				controller.getUtil().addMapping( name=thisMapping, path=instance.cfmappingRegistry[ thisMapping ] );
			}
    	</cfscript>
    </cffunction>

	<!--- activateModules --->
	<cffunction name="activateAllModules" output="false" access="public" returntype="void" hint="Go over all the loaded module configurations and activate them for usage within the application">
		<cfscript>
			var modules = controller.getSetting( "modules" );
			// Iterate through module configuration and activate each module
			for( var moduleName in modules ){
				// Verify the exception and inclusion lists
				if( canLoad( moduleName ) ){
					activateModule( moduleName );
				}
			}
		</cfscript>
	</cffunction>

	<!--- activateModule --->
	<cffunction name="activateModule" output="false" access="public" returntype="ModuleService" hint="Activate a module">
		<cfargument name="moduleName" type="string" required="true" hint="The name of the module to load. It must exist and be valid. Else we ignore it by logging a warning and returning false."/>
		<cfscript>
			var modules 			= controller.getSetting( "modules" );
			var iData       		= {};
			var interceptorService  = controller.getInterceptorService();
			var wirebox				= controller.getWireBox();

			// If module not registered, throw exception
			if( NOT structKeyExists( modules, arguments.moduleName ) ){
				throw( 
					message = "Cannot activate module: #arguments.moduleName#",
					detail 	= "The module has not been registered, register the module first and then activate it.",
					type 	= "ModuleService.IllegalModuleState" 
				);
			}

			// Check if module already activated
			if( modules[ arguments.moduleName ].activated ){
				// Log it
				if( instance.logger.canDebug() ){
					instance.logger.debug( "Module #arguments.moduleName# already activated, skipping activation." );
				}
				return this;
			}

			// Check if module CAN be activated
			if( !modules[ arguments.moduleName ].activate ){
				// Log it
				if( instance.logger.canDebug() ){
					instance.logger.debug( "Module #arguments.moduleName# cannot be activated as it is flagged to not activate, skipping activation." );
				}
				return this;
			}

			// Get module settings
			var mConfig = modules[ arguments.moduleName ];

			// Do we have dependencies to activate first
			for( var thisDependency in mConfig.dependencies ){
				if( instance.logger.canDebug() ){
					instance.logger.debug( "Activating #arguments.moduleName# requests dependency activation: #thisDependency#" );
				}
				// Activate dependency first
				activateModule( thisDependency );
			}

			// lock and load baby
			lock 	name="module.#getController().getAppHash()#.activation.#arguments.moduleName#" 
					type="exclusive" 
					timeout="20" 
					throwontimeout="true"
			{

				// preModuleLoad interception
				var iData = { moduleLocation=mConfig.path, moduleName=arguments.moduleName };
				interceptorService.processState( "preModuleLoad", iData );

				// Register handlers
				mConfig.registeredHandlers = controller.getHandlerService().getHandlerListing( mconfig.handlerPhysicalPath );
				mConfig.registeredHandlers = arrayToList( mConfig.registeredHandlers );

				// Register the Config as an observable also.
				interceptorService.registerInterceptor( 
					interceptorObject 	= instance.mConfigCache[ arguments.moduleName ], 
					interceptorName 	= "ModuleConfig:#arguments.moduleName#" 
				);

				// Register Models if it exists
				if( directoryExists( mconfig.modelsPhysicalPath ) and mConfig.autoMapModels ){
					// Add as a mapped directory with module name as the namespace with correct mapping path
					var packagePath = ( len( mConfig.cfmapping ) ? mConfig.cfmapping & ".#mConfig.conventions.modelsLocation#" :  mConfig.modelsInvocationPath );
					if( len( mConfig.modelNamespace ) ){
						wirebox.getBinder().mapDirectory( packagePath=packagePath, namespace="@#mConfig.modelNamespace#" );
					} else {
						// just register with no namespace
						wirebox.getBinder().mapDirectory( packagePath=packagePath );
					}
					wirebox.getBinder().processMappings();
				}

				// Register Interceptors with Announcement service
				for( var y=1; y lte arrayLen( mConfig.interceptors ); y++ ){
					interceptorService.registerInterceptor( 
						interceptorClass 		= mConfig.interceptors[ y ].class,
						interceptorProperties 	= mConfig.interceptors[ y ].properties,
						interceptorName 		= mConfig.interceptors[ y ].name
					);
					// Loop over module interceptors to autowire them
					wirebox.autowire( 
						target 	= interceptorService.getInterceptor( mConfig.interceptors[ y ].name, true ),
						targetID= mConfig.interceptors[ y ].class 
					);
				}

				// Register module routing entry point pre-pended to routes
				if( controller.settingExists( 'sesBaseURL' ) AND 
					len( mConfig.entryPoint ) AND NOT 
					find( ":", mConfig.entryPoint ) 
				){
					interceptorService.getInterceptor( "SES", true )
						.addModuleRoutes( pattern=mConfig.entryPoint, module=arguments.moduleName, append=false );
				}

				// Call on module configuration object onLoad() if found
				if( structKeyExists( instance.mConfigCache[ arguments.moduleName ], "onLoad" ) ){
					instance.mConfigCache[ arguments.moduleName ].onLoad();
				}

				// postModuleLoad interception
				iData = { moduleLocation=mConfig.path, moduleName=arguments.moduleName, moduleConfig=mConfig };
				interceptorService.processState( "postModuleLoad", iData );

				// Mark it as loaded as it is now activated
				mConfig.activated = true;

				// Now activate any children
				for( var thisChild in mConfig.childModules ){
					activateModule( moduleName=thisChild );
				}

				// Log it
				if( instance.logger.canDebug() ){
					instance.logger.debug( "Module #arguments.moduleName# activated sucessfully." );
				}

			} // end lock

			return this;
		</cfscript>
	</cffunction>

	<!--- reload --->
	<cffunction name="reload" output="false" access="public" returntype="void" hint="Reload a targeted module">
		<cfargument name="moduleName" type="string" required="true" hint="The module to reload"/>
		<cfscript>
			unload(arguments.moduleName);
			registerModule(arguments.moduleName);
			activateModule(arguments.moduleName);
		</cfscript>
	</cffunction>

	<!--- reloadAll --->
	<cffunction name="reloadAll" output="false" access="public" returntype="void" hint="Reload all modules">
		<cfscript>
			unloadAll();
			registerAllModules();
			activateAllModules();
		</cfscript>
	</cffunction>

	<!--- getLoadedModules --->
	<cffunction name="getLoadedModules" output="false" access="public" returntype="array" hint="Get a listing of all loaded modules">
		<cfscript>
			var modules = structKeyList(controller.getSetting( "modules" ));

			return listToArray(modules);
		</cfscript>
	</cffunction>

	<!--- isModuleRegistered --->
	<cffunction name="isModuleRegistered" output="false" access="public" returntype="boolean" hint="Check and see if a module has been registered">
		<cfargument name="moduleName" required="true" type="string">
		<!--- Verify it in the main settings --->
		<cfreturn structKeyExists( controller.getSetting( "modules" ), arguments.moduleName )>
	</cffunction>

	<!--- isModuleActive --->
	<cffunction name="isModuleActive" output="false" access="public" returntype="boolean" hint="Check and see if a module has been activated">
		<cfargument name="moduleName" required="true" type="string">
		<cfscript>
			var modules = controller.getSetting( "modules" );
			return ( isModuleRegistered( arguments.moduleName ) and modules[ arguments.moduleName ].activated ? true : false );
		</cfscript>
	</cffunction>

	<!--- unload --->
	<cffunction name="unload" output="false" access="public" returntype="boolean" hint="Unload a module if found from the configuration">
		<cfargument name="moduleName" type="string" required="true" hint="The module name to unload"/>
		<cfscript>
			// This method basically unregisters the module configuration
			var appConfig = controller.getConfigSettings();
			var iData = {moduleName=arguments.moduleName};
			var interceptorService = controller.getInterceptorService();
			var x = 1;
			var exceptionUnloading = "";

			// Check if module is loaded?
			if( NOT structKeyExists(appConfig.modules,arguments.moduleName) ){ return false; }

		</cfscript>

		<cflock name="module.#getController().getAppHash()#.unload.#arguments.moduleName#" type="exclusive" timeout="20" throwontimeout="true">
		<cfscript>
			// Check if module is loaded?
			if( NOT structKeyExists(appConfig.modules,arguments.moduleName) ){ return false; }

			// Before unloading a module interception
			interceptorService.processState( "preModuleUnload",iData);

			// Call on module configuration object onLoad() if found
			if( structKeyExists(instance.mConfigCache[ arguments.moduleName ],"onUnload" ) ){
				try{
					instance.mConfigCache[ arguments.moduleName ].onUnload();
				} catch( Any e ){
					instance.logger.error( "Error unloading module: #arguments.moduleName#. #e.message# #e.detail#", e );
					exceptionUnloading = e;
				}
			}

			// Unregister all interceptors
			for(x=1; x lte arrayLen( appConfig.modules[ arguments.moduleName ].interceptors ); x++){
				interceptorService.unregister( appConfig.modules[ arguments.moduleName ].interceptors[ x ].name);
			}
			// Unregister Config object
			interceptorService.unregister( "ModuleConfig:#arguments.moduleName#" );

			// Remove SES if enabled.
			if( controller.settingExists( "sesBaseURL" ) ){
				interceptorService.getInterceptor( "SES", true ).removeModuleRoutes( arguments.moduleName );
			}

			// Remove configuration
			structDelete( appConfig.modules, arguments.moduleName );

			// Remove Configuration object from Cache
			structDelete( instance.mConfigCache, arguments.moduleName );

			//After unloading a module interception
			interceptorService.processState( "postModuleUnload", iData );

			// Log it
			if( instance.logger.canDebug() ){
				instance.logger.debug( "Module #arguments.moduleName# unloaded successfully." );
			}

			// Do we need to throw exception?
			if( !isSimpleValue( exceptionUnloading ) ){
				throw( exceptionUnloading );
			}
		</cfscript>
		</cflock>

		<cfreturn true>
	</cffunction>

	<!--- unloadAll --->
	<cffunction name="unloadAll" output="false" access="public" returntype="void" hint="Unload all registered modules">
		<cfscript>
			// This method basically unregisters the module configuration
			var modules = controller.getSetting( "modules" );
			var key = "";

			// Unload all modules
			for(key in modules){
				unload(key);
			}
		</cfscript>
	</cffunction>

	<!--- loadModuleConfiguration --->
	<cffunction name="loadModuleConfiguration" output="false" access="public" returntype="any" hint="Load the module configuration object and return it">
		<cfargument name="config" 		type="struct" required="true" hint="The module config structure">
		<cfargument name="moduleName"	type="string" required="true" hint="The module name">
		<cfscript>
			var mConfig 	= arguments.config;
			var oConfig 	= createObject( "component", mConfig.invocationPath & ".ModuleConfig" );
			var toLoad 		= "";
			var appSettings = controller.getConfigSettings();
			var mixerUtil	= controller.getUtil().getMixerUtil();

			// Decorate It
			oConfig.injectPropertyMixin = mixerUtil.injectPropertyMixin;
			oConfig.getPropertyMixin 	= mixerUtil.getPropertyMixin;

			// MixIn Variables
			oConfig.injectPropertyMixin( "controller", 		controller );
			oConfig.injectPropertyMixin( "appMapping", 		controller.getSetting( "appMapping" ) );
			oConfig.injectPropertyMixin( "moduleMapping", 	mConfig.mapping );
			oConfig.injectPropertyMixin( "modulePath", 		mConfig.path );
			oConfig.injectPropertyMixin( "logBox", 			controller.getLogBox() );
			oConfig.injectPropertyMixin( "log", 			controller.getLogBox().getLogger( oConfig) );
			oConfig.injectPropertyMixin( "wirebox", 		controller.getWireBox() );
			oConfig.injectPropertyMixin( "binder", 			controller.getWireBox().getBinder() );
			oConfig.injectPropertyMixin( "cachebox", 		controller.getCacheBox() );

			// Configure the module
			oConfig.configure();

			// Get parent environment settings and if same convention of 'environment'() found, execute it.
			if( structKeyExists( oConfig, appSettings.environment ) ){
				evaluate( "oConfig.#appSettings.environment#()" );
			}

			// title
			if( !structKeyExists( oConfig, "title" ) ){ oConfig.title = arguments.moduleName; }
			mConfig.title = oConfig.title;
			// aliases
			if( structKeyExists( oConfig, "aliases" ) ){
				// inflate list to array
				if( isSimpleValue( oConfig.aliases ) ){ oConfig.aliases = listToArray( oConfig.aliases ); }
				mConfig.aliases = oConfig.aliases;
			}
			// author
			if( !structKeyExists( oConfig, "author" ) ){ oConfig.author = ""; }
			mConfig.author = oConfig.author;
			// web url
			if( !structKeyExists( oConfig, "webURL" ) ){ oConfig.webURL = ""; }
			mConfig.webURL = oConfig.webURL;
			// description
			if( !structKeyExists( oConfig, "description" ) ){ oConfig.description = ""; }
			mConfig.description	= oConfig.description;
			// version
			if( !structKeyExists( oConfig, "version" ) ){ oConfig.version = ""; }
			mConfig.version	= oConfig.version;
			// cf mapping
			if( !structKeyExists( oConfig, "cfmapping" ) ){ oConfig.cfmapping = ""; }
			mConfig.cfmapping = oConfig.cfmapping;
			// model namespace override
			if( structKeyExists( oConfig, "modelNamespace" ) ){
				mConfig.modelNamespace = oConfig.modelNamespace;
			}
			// Auto map models
			if( structKeyExists( oConfig, "autoMapModels" ) ){
				mConfig.autoMapModels = oConfig.autoMapModels;
			}
			// Dependencies
			if( structKeyExists( oConfig, "dependencies" ) ){
				// set it always as an array
				mConfig.dependencies = isSimpleValue( oConfig.dependencies ) ? listToArray( oConfig.dependencies ) : oConfig.dependencies;
			}
			// Parent Lookups
			mConfig.viewParentLookup = true;
			if( structKeyExists( oConfig,"viewParentLookup" ) ){
				mConfig.viewParentLookup = oConfig.viewParentLookup;
			}
			mConfig.layoutParentLookup  = true;
			if( structKeyExists( oConfig,"layoutParentLookup" ) ){
				mConfig.layoutParentLookup = oConfig.layoutParentLookup;
			}
			// Entry Point
			mConfig.entryPoint = "";
			if( structKeyExists( oConfig,"entryPoint" ) ){
				mConfig.entryPoint= oConfig.entryPoint;
			}
			// Disabled
			mConfig.disabled = false;
			if( structKeyExists( oConfig,"disabled" ) ){
				mConfig.disabled = oConfig.disabled;
			}
			// Activated
			mConfig.activate = true;
			if( structKeyExists( oConfig,"activate" ) ){
				mConfig.activate = oConfig.activate;
			}
			// Merge the settings with the parent module settings 
			if( structKeyExists( oConfig, "parseParentSettings" ) ){
				mConfig.parseParentSettings = oConfig.parseParentSettings;
			}

			//Get the parent settings
			mConfig.parentSettings = oConfig.getPropertyMixin( "parentSettings", "variables", {} );
			//Get the module settings
			mConfig.settings = oConfig.getPropertyMixin( "settings", "variables", {} );
			// Add the module settings to the parent settings under the modules namespace
			if ( mConfig.parseParentSettings ) {
				// Merge the parent module settings into module settings
				var parentModuleSettings = controller.getSetting( "ColdBoxConfig" )
					.getPropertyMixin( "moduleSettings", "variables", structnew() );
				if ( ! structKeyExists( parentModuleSettings, mConfig.modelNamespace ) ) {
					parentModuleSettings[ mConfig.modelNamespace ] = {};
				}
				structAppend(
					mConfig.settings,
					parentModuleSettings[ mConfig.modelNamespace ],
					true
				);
			}
			appSettings[ mConfig.modelNamespace ] = mConfig.settings;
			//Get module datasources
			mConfig.datasources = oConfig.getPropertyMixin( "datasources", "variables", {} );
			//Get Interceptors
			mConfig.interceptors = oConfig.getPropertyMixin( "interceptors", "variables", [] );
			for(var x=1; x lte arrayLen( mConfig.interceptors ); x=x+1){
				//Name check
				if( NOT structKeyExists(mConfig.interceptors[x],"name" ) ){
					mConfig.interceptors[x].name = listLast(mConfig.interceptors[x].class,"." );
				}
				//Properties check
				if( NOT structKeyExists(mConfig.interceptors[x],"properties" ) ){
					mConfig.interceptors[x].properties = structnew();
				}
			}

			//Get custom interception points
			mConfig.interceptorSettings = oConfig.getPropertyMixin( "interceptorSettings","variables",structnew());
			if( NOT structKeyExists(mConfig.interceptorSettings,"customInterceptionPoints" ) ){
				mConfig.interceptorSettings.customInterceptionPoints = "";
			}

			//Get SES Routes
			mConfig.routes = oConfig.getPropertyMixin( "routes", "variables", [] );
			// Get and Append Module conventions
			structAppend( mConfig.conventions, oConfig.getPropertyMixin( "conventions", "variables", {} ), true );
			// Get Module Layout Settings
			structAppend( mConfig.layoutSettings, oConfig.getPropertyMixin( "layoutSettings", "variables", {} ), true );

			return oConfig;
		</cfscript>
	</cffunction>


<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- buildRegistry --->
    <cffunction name="buildRegistry" output="false" access="private" returntype="void" hint="Build the modules registry">
    	<cfargument name="locations" type="array" 	required="true" hint="The array of locations to register"/>
		<cfscript>
			var locLen = arrayLen( arguments.locations );

			for(var x=1; x lte locLen; x++){
				if( len( trim( arguments.locations[ x ] ) ) ){
					// Get all modules found in the module location and append to module registry, only new ones are added
					scanModulesDirectory( arguments.locations[ x ] );
				}
			}
		</cfscript>
    </cffunction>

	<!--- scanModulesDirectory --->
	<cffunction name="scanModulesDirectory" output="false" access="private" returntype="void" hint="Get an array of modules found and add to the registry structure">
		<cfargument name="dirPath" 			type="string" required="true" hint="Path to scan"/>
		<cfset var q = "">
		<cfset var expandedPath = expandPath( arguments.dirpath )>

		<cfdirectory action="list" directory="#expandedPath#" name="q" type="dir" sort="asc">

		<cfloop query="q">
			<cfif NOT find( ".", q.name )>
				<!--- Add only if it does not exist, so location preference kicks in --->
				<cfif  NOT structKeyExists(instance.moduleRegistry, q.name)>
					<cfset instance.moduleRegistry[q.name] = {
						locationPath 	= arguments.dirPath,
						physicalPath 	= expandedPath,
						invocationPath 	= replace( reReplace(arguments.dirPath,"^/","" ), "/", ".","all" )
					}>
				<cfelse>
					<cfset instance.logger.debug( "Found duplicate module: #q.name# in #arguments.dirPath#. Skipping its registration in our module registry, order of preference given." ) >
				</cfif>
			</cfif>
		</cfloop>

	</cffunction>

	<!--- canLoad --->
    <cffunction name="canLoad" output="false" access="private" returntype="boolean" hint="Checks if the module can be loaded or registered">
  		<cfargument name="moduleName" type="string" required="true" hint="The module name"/>
  		<cfscript>
    		var excludeModules = ArrayToList( controller.getSetting( "ModulesExclude" ) );

			// If we have excludes and in the excludes
			if( len( excludeModules ) and listFindNoCase( excludeModules, arguments.moduleName ) ){
				instance.logger.info( "Module: #arguments.moduleName# excluded from loading." );
				return false;
			}

			return true;
    	</cfscript>
    </cffunction>

</cfcomponent>
