/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * I oversee and manage ColdBox modules
 */
component extends="coldbox.system.web.services.BaseService" accessors="true" {

	/**
	 * Logger object
	 */
	property name="logger";

	/**
	 * Configuration cache dictionary
	 */
	property name="mConfigCache";

	/**
	 * Module registry dictionary
	 */
	property name="moduleRegistry";

	/**
	 * CF Mapping registry Dictionary
	 */
	property name="cfmappingRegistry";

	/**
	 * Constructor
	 */
	function init( required controller ){
		variables.controller         = arguments.controller;
		variables.util               = arguments.controller.getUtil();
		variables.interceptorService = arguments.controller.getInterceptorService();

		// service properties
		variables.logger            = "";
		variables.mConfigCache      = {};
		variables.moduleRegistry    = structNew( "ordered" );
		variables.cfmappingRegistry = {};

		return this;
	}

	/**************************************** INTERNAL COLDBOX EVENTS ****************************************/

	/**
	 * Called by loader service when configuration file loads
	 */
	ModuleService function onConfigurationLoad(){
		// Get Local Logger Now Configured
		variables.logger  = variables.controller.getLogBox().getLogger( this );
		variables.wirebox = variables.controller.getWireBox();

		// Setup more properties for usage
		variables.registeredModules = variables.controller.getSetting( "modules" );
		variables.appRouter         = variables.wirebox.getInstance( "router@coldbox" );

		// Register All Modules
		registerAllModules();

		return this;
	}

	/**
	 * Called when the application stops
	 */
	ModuleService function onShutdown(){
		// Unload all modules
		unloadAll();
		return this;
	}

	/**************************************** PUBLIC ****************************************/

	/**
	 * Get the discovered module's registry structure
	 */
	struct function getModuleRegistry(){
		return variables.moduleRegistry;
	}

	/**
	 * Return the loaded module's configuration objects
	 */
	struct function getModuleConfigCache(){
		return variables.mConfigCache;
	}

	/**
	 * Rescan the module locations directories and re-register all located modules, this{method does NOT register or activate any modules, it just reloads the found registry
	 */
	ModuleService function rebuildModuleRegistry(){
		// Add the application's module's location and the system core modules
		var modLocations = [ variables.controller.getSetting( "ModulesLocation" ) ];
		// Add the application's external locations array.
		modLocations.addAll( variables.controller.getSetting( "ModulesExternalLocation" ) );
		// Add the ColdBox Core Modules Location
		arrayPrepend( modLocations, "/coldbox/system/modules" );
		// iterate through locations and build the module registry in order
		buildRegistry( modLocations );
		return this;
	}

	/**
	 * Register all modules for the application. Usually called by framework to load configuration data.
	 */
	ModuleService function registerAllModules(){
		var foundModules   = "";
		var includeModules = variables.controller.getSetting( "modulesInclude" );
		var totalTime      = getTickCount();

		// Register the initial empty module configuration holder structure
		structClear( variables.controller.getSetting( "modules" ) );
		// clean the registry as we are registering all modules
		variables.moduleRegistry = structNew( "ordered" );
		// Now rebuild it
		rebuildModuleRegistry();

		// Are we using an include list?
		if ( arrayLen( includeModules ) ) {
			for ( var thisModule in includeModules ) {
				// does module exists in the registry? We only register what is found
				if ( structKeyExists( variables.moduleRegistry, thisModule ) ) {
					registerModule( thisModule );
				}
			}
			return this;
		}

		// Iterate through registry and register each module
		var aModules = structKeyArray( variables.moduleRegistry );
		for ( var thisModule in aModules ) {
			if ( canLoad( thisModule ) ) {
				registerModule( thisModule );
			}
		}

		variables.logger.info( "+ Registered All Modules in #numberFormat( getTickCount() - totalTime )# ms" );

		// interception
		variables.interceptorService.announce(
			"afterModuleRegistrations",
			{ moduleRegistry : variables.moduleRegistry }
		);

		return this;
	}

	/**
	 * Register and activate a new module
	 *
	 * @moduleName     The name of the module to load.
	 * @invocationPath The module's invocation path to its root from the webroot (the instantiation path,ex:myapp.myCustomModules), if empty we use registry location, if not we are doing a explicit name+path registration. Do not include the module name, you passed that in the first argument right
	 */
	function registerAndActivateModule( required moduleName, invocationPath = "" ){
		registerModule( arguments.moduleName, arguments.invocationPath );
		activateModule( arguments.moduleName );
	}

	/**
	 * Register a module's configuration information and config object
	 *
	 * @moduleName     The name of the module to load.
	 * @invocationPath The module's invocation path to its root from the webroot (the instantiation path,ex:myapp.myCustomModules), if empty we use registry locatioif not we are doing a explicit name+path registration. Do not include the module name, you passed that in the first argument right
	 * @parent         The name of the parent module
	 * @force          Force a registration
	 * @bundle         If the module belongs to a bundle
	 * @parentInjector The parent injector if used
	 *
	 * @return If the module registered or not
	 *
	 * @throws InvalidModuleName - When a module is not on disk
	 */
	boolean function registerModule(
		required moduleName,
		invocationPath = "",
		parent         = "",
		boolean force  = false,
		bundle         = "",
		parentInjector = ""
	){
		var sTime                = getTickCount();
		var modName              = arguments.moduleName;
		var modulesConfiguration = variables.registeredModules;
		var appSettings          = variables.controller.getConfigSettings();
		var interceptorService   = variables.controller.getInterceptorService();

		// Check if incoming invocation path is sent, if so, register as new module
		if ( len( arguments.invocationPath ) ) {
			// Check if passed module name is already registered
			if ( structKeyExists( variables.moduleRegistry, arguments.moduleName ) AND !arguments.force ) {
				variables.logger.info(
					"> The module #arguments.moduleName# has already been registered, so skipping registration"
				);
				return false;
			}
			// register new incoming location
			variables.moduleRegistry[ arguments.moduleName ] = {
				locationPath   : "/" & replace( arguments.invocationPath, ".", "/", "all" ),
				physicalPath   : expandPath( "/" & replace( arguments.invocationPath, ".", "/", "all" ) ),
				invocationPath : arguments.invocationPath
			};
		}

		// Check if passed module name is not loaded into the registry
		if ( NOT structKeyExists( variables.moduleRegistry, arguments.moduleName ) ) {
			throw(
				message: "The module #arguments.moduleName# is not valid",
				detail : "Valid module names are: #structKeyList( variables.moduleRegistry )#",
				type   : "InvalidModuleName"
			);
		}

		/*
		|--------------------------------------------------------------------------
		| Setup Module metadata
		|--------------------------------------------------------------------------
		*/
		var modulesLocation       = variables.moduleRegistry[ modName ].locationPath;
		var modulesPath           = variables.moduleRegistry[ modName ].physicalPath;
		var modulesInvocationPath = variables.moduleRegistry[ modName ].invocationPath;
		var modLocation           = modulesPath & "/" & modName;
		var isBundle              = listLast( modLocation, "-" ) eq "bundle";

		// Check if module config exists, or we have a module.
		if ( NOT fileExists( modLocation & "/ModuleConfig.cfc" ) && NOT isBundle ) {
			variables.logger.WARN(
				"The module (#modName#) cannot be loaded as it does not have a ModuleConfig.cfc in its root. Path Checked: #modLocation#"
			);
			return false;
		}

		/*
		|--------------------------------------------------------------------------
		| Module Bundle Registration
		|--------------------------------------------------------------------------
		*/
		if ( isBundle ) {
			// Bundle Loading
			var aBundleModules = directoryList( modLocation, false, "array" );
			for ( var thisModule in aBundleModules ) {
				// cleanup module name
				var bundleModuleName = listLast( thisModule, "/\" );
				// register the bundle module if not in exclude list
				if ( canLoad( bundleModuleName ) ) {
					registerModule(
						moduleName     = bundleModuleName,
						invocationPath = modulesInvocationPath & "." & modName,
						bundle         = modName,
						force          = true
					);
				} else {
					variables.logger.warn(
						"The module (#bundleModuleName#) cannot load as it is in the excludes list"
					);
				}
			}
			// the bundle has loaded, it needs no config data
			return true;
		}

		/*
		|--------------------------------------------------------------------------
		| Module Registration
		|--------------------------------------------------------------------------
		*/
		lock
			name          ="module#variables.controller.getAppHash()#.registration.#modName#"
			type          ="exclusive"
			throwontimeout="true"
			timeout       ="20" {
			// interception
			variables.interceptorService.announce(
				"preModuleRegistration",
				{
					moduleRegistration : variables.moduleRegistry[ modName ],
					moduleName         : modName
				}
			);

			/*
			|--------------------------------------------------------------------------
			| Module Config Struct
			|--------------------------------------------------------------------------
			*/
			var mConfig = {
				// flag that says if this module can be activated or not
				activate          : true,
				// Flag that denotes if the module has been activated or not
				activated         : false,
				// execution aliases
				aliases           : [],
				// Application Helpers
				applicationHelper : [],
				// Author Metadata
				author            : "",
				// Automatically map the models folder
				autoMapModels     : true,
				// Auto process models for metadata and annotations, default is lazy loading now due to performance
				autoProcessModels : false,
				// Does the module belong to a bundle or not
				bundle            : arguments.bundle,
				// ColdFusion mapping
				cfmapping         : "",
				// Child modules
				childModules      : [],
				// Module Conventions
				conventions       : {
					handlersLocation  : "handlers",
					layoutsLocation   : "layouts",
					viewsLocation     : "views",
					modelsLocation    : "models",
					includesLocation  : "includes",
					routerLocation    : "config.Router",
					schedulerLocation : "config.Scheduler"
				},
				// Any dependencies this module requires to be loaded first
				dependencies            : [],
				// Module human description
				description             : "",
				// Flag that says if this module should NOT be loaded
				disabled                : false,
				// SES entry point
				entryPoint              : "",
				// Module Custom executors
				executors               : {},
				// Handlers pathing
				handlerInvocationPath   : modulesInvocationPath & "." & modName,
				handlerPhysicalPath     : modLocation,
				// Inherit Entry Point from parent hierarchies
				inheritEntryPoint       : false,
				// The actual inherited entry point slug
				inheritedEntryPoint     : "",
				// Invocation path
				invocationPath          : modulesInvocationPath & "." & modName,
				// The module's injector reference and name
				injector                : "",
				injectorName            : modName & "-" & hash( modulesLocation ),
				// Module interceptors
				interceptors            : [],
				interceptorSettings     : { customInterceptionPoints : "" },
				// layout check in parent first
				layoutParentLookup      : "true",
				// when this registration occurred
				loadTime                : now(),
				// Layout settings
				layoutSettings          : { defaultLayout : "" },
				// Module mapping
				mapping                 : modulesLocation & "/" & modName,
				// Module namespace
				modelNamespace          : modName,
				// Models pathing
				modelsInvocationPath    : modulesInvocationPath & "." & modName,
				modelsPhysicalPath      : modLocation,
				// Module Injector : If enabled, we use the new cb7 injector, else previous behavior
				// TODO: This will be true in cb8+
				moduleInjector          : false,
				// Module Routes
				routes                  : [],
				// Registered handlers
				registeredHandlers      : "",
				// Routing resources
				resources               : [],
				// My Daddy!
				parent                  : arguments.parent,
				// Settings to incorporate into the root
				parentSettings          : {},
				parseParentSettings     : true,
				// Module location
				path                    : modLocation,
				// Module Router
				router                  : "",
				routerInvocationPath    : modulesInvocationPath & "." & modName,
				routerPhysicalPath      : modLocation,
				// Module Settings
				settings                : {},
				// Task Scheduler
				scheduler               : "",
				schedulerInvocationPath : modulesInvocationPath & "." & modName,
				schedulerPhysicalpath   : modLocation,
				// Module human title
				title                   : "",
				// View check in parent first
				viewParentLookup        : true,
				// Module version
				version                 : "",
				// Web url metadata
				webURL                  : ""
			};

			/*
			|--------------------------------------------------------------------------
			| Load ModuleConfig.cfc and Injector
			|--------------------------------------------------------------------------
			*/
			var moduleConfigAndInjector = loadModuleConfiguration(
				config        : mConfig,
				moduleName    : arguments.moduleName,
				parent        : isBundle ? "" : arguments.parent,
				parentInjector: arguments.parentInjector
			);
			mConfig.injector = moduleConfigAndInjector.injector;

			/*
			|--------------------------------------------------------------------------
			| Disable Checks + Config object storage
			|--------------------------------------------------------------------------
			*/
			if ( mConfig.disabled ) {
				if ( variables.logger.canInfo() ) {
					variables.logger.info( "> Skipping module: #arguments.moduleName# as it has been disabled!" );
				}
				return false;
			} else {
				variables.mConfigCache[ modName ] = moduleConfigAndInjector.config;
			}

			// Store module configuration in main modules configuration
			modulesConfiguration[ modName ] = mConfig;

			// Link aliases by reference in both modules list and config cache
			for ( var thisAlias in mConfig.aliases ) {
				modulesConfiguration[ thisAlias ]   = modulesConfiguration[ modName ];
				variables.mConfigCache[ thisAlias ] = variables.mConfigCache[ modName ];
			}

			// Update the paths according to conventions
			mConfig.handlerInvocationPath &= ".#replace(
				mConfig.conventions.handlersLocation,
				"/",
				".",
				"all"
			)#";
			mConfig.handlerPhysicalPath &= "/#mConfig.conventions.handlersLocation#";
			mConfig.modelsInvocationPath &= ".#replace(
				mConfig.conventions.modelsLocation,
				"/",
				".",
				"all"
			)#";
			mConfig.modelsPhysicalPath &= "/#mConfig.conventions.modelsLocation#";
			// Router
			mConfig.routerInvocationPath &= ".#mConfig.conventions.routerLocation#";
			mConfig.routerPhysicalPath &= "/#mConfig.conventions.routerLocation.replace( ".", "/", "all" )#.cfc";
			// Scheduler
			mConfig.schedulerInvocationPath &= ".#mConfig.conventions.schedulerLocation#";
			mConfig.schedulerPhysicalPath &= "/#mConfig.conventions.schedulerLocation.replace( ".", "/", "all" )#.cfc";

			// Register CFML Mapping if it exists, for loading purposes
			// TODO: If a duplicate mapping is detected, warn it to logs
			if ( len( trim( mConfig.cfMapping ) ) ) {
				variables.util.addMapping( name = mConfig.cfMapping, path = mConfig.path );
				variables.cfmappingRegistry[ "/#mConfig.cfMapping#" ] = mConfig.path;
			}

			// Register Custom Interception Points
			controller
				.getInterceptorService()
				.appendInterceptionPoints( mConfig.interceptorSettings.customInterceptionPoints );

			// Register Parent Settings
			structAppend( appSettings, mConfig.parentSettings, true );

			/*
			|--------------------------------------------------------------------------
			| Register inception
			|--------------------------------------------------------------------------
			*/
			var inceptionPaths = [ "modules", "modules_app" ];
			for ( var thisInceptionPath in inceptionPaths ) {
				if ( directoryExists( mConfig.path & "/" & thisInceptionPath ) ) {
					// register the children
					var childModules = directoryList(
						mConfig.path & "/" & thisInceptionPath,
						false,
						"array"
					);
					for ( var thisChild in childModules ) {
						// cleanup module name
						var childName = listLast( thisChild, "/\" );
						// verify ModuleConfig exists, else skip
						if ( fileExists( thisChild & "/ModuleConfig.cfc" ) ) {
							// add to parent children
							arrayAppend( mConfig.childModules, childname );
							// register child
							registerModule(
								moduleName    : childName,
								invocationPath: mConfig.invocationPath & "." & thisInceptionPath,
								parent        : modName,
								bundle        : arguments.bundle,
								parentInjector: moduleConfigAndInjector.injector
							);
						} else if ( variables.logger.canInfo() ) {
							variables.logger.info(
								"> Inception Module #childName# does not have a valid ModuleConfig.cfc in its root, so skipping registration"
							);
						}
					}
				}
			}
			// end inception loading

			// Log Registration Time
			mConfig.registrationTime = getTickCount() - sTime;

			// Announce module registered
			variables.interceptorService.announce(
				"postModuleRegistration",
				{
					moduleConfig : mConfig,
					moduleName   : arguments.moduleName
				}
			);

			// Log registration
			variables.logger.info(
				"+ Module (#arguments.moduleName#) Registered (#mConfig.registrationTime#ms) => { version: #mConfig.version#, from: #mConfig.path# }"
			);
		}
		// end lock

		return true;
	}

	/**
	 * Load all module mappings
	 */
	function loadMappings(){
		variables.util.addMapping( mappings = variables.cfmappingRegistry );
		return this;
	}

	/**
	 * Go over all the loaded module configurations and activate them for usage within the{application
	 */
	function activateAllModules(){
		var aModules  = structKeyArray( variables.moduleRegistry );
		var totalTime = getTickCount();

		// Iterate through module configuration and activate each module
		for ( var moduleName in aModules ) {
			// Can we load module and has it been registered?
			if ( structKeyExists( variables.registeredModules, moduleName ) && canLoad( moduleName ) ) {
				activateModule( moduleName );
			}
		}

		variables.logger.info( "+ Activated All Modules in #numberFormat( getTickCount() - totalTime )# ms" );

		// interception
		variables.interceptorService.announce(
			"afterModuleActivations",
			{ moduleRegistry : variables.moduleRegistry }
		);
	}

	/**
	 * Activate a module
	 *
	 * @moduleName The name of the module to activate. It must exist and be valid. Else we ignore it by logging a warning
	 *
	 * @return The Module Service
	 *
	 * @throws IllegalModuleState - When the requested module to active is not registered
	 */
	ModuleService function activateModule( required moduleName ){
		var sTime   = getTickCount();
		var modules = variables.registeredModules;

		// If module not registered, throw exception
		if ( isNull( modules[ arguments.moduleName ] ) ) {
			throw(
				message: "Cannot activate module (#arguments.moduleName#) as it has not been registered.",
				detail : "Registered modules are #modules.keyList()#",
				type   : "IllegalModuleState"
			);
		}

		// Check if module already activated
		if ( modules[ arguments.moduleName ].activated ) {
			variables.logger.warn( "==> Module '#arguments.moduleName#' already activated, skipping activation." );
			return this;
		}

		// Check if module CAN be activated
		if ( !modules[ arguments.moduleName ].activate ) {
			// Log it
			variables.logger.info(
				"==> Module '#arguments.moduleName#' cannot be activated as it is flagged to not activate, skipping activation."
			);
			return this;
		}

		var mConfig = modules[ arguments.moduleName ];

		/*
		|--------------------------------------------------------------------------
		| Module Dependencies Activation
		|--------------------------------------------------------------------------
		*/
		// Activate dependencies first
		mConfig.dependencies.each( function( thisDependency ){
			variables.logger.debug( "==> Activating '#moduleName#' dependency: #arguments.thisDependency#" );
			activateModule( arguments.thisDependency );
		} );

		// Check if activating one of this module's dependencies already activated this module, hey it can happen!
		if ( modules[ arguments.moduleName ].activated ) {
			variables.logger.warn(
				"==> Module '#arguments.moduleName#' already activated during dependency activation, skipping activation."
			);
			return this;
		}

		// lock and load baby
		lock
			name          ="module#variables.controller.getAppHash()#.activation.#arguments.moduleName#"
			type          ="exclusive"
			timeout       ="20"
			throwontimeout="true" {
			/*
			|--------------------------------------------------------------------------
			| Announce Module Load Event
			|--------------------------------------------------------------------------
			*/
			variables.interceptorService.announce(
				"preModuleLoad",
				{
					moduleLocation : mConfig.path,
					moduleName     : arguments.moduleName
				}
			);

			/*
			|--------------------------------------------------------------------------
			| Register Module Handlers
			|--------------------------------------------------------------------------
			*/
			mConfig.registeredHandlers = controller
				.getHandlerService()
				.getHandlerListing( mconfig.handlerPhysicalPath )
				.toList();

			/*
			|--------------------------------------------------------------------------
			| Module Config Observer
			|--------------------------------------------------------------------------
			*/
			variables.interceptorService.registerInterceptor(
				interceptorObject = variables.mConfigCache[ arguments.moduleName ],
				interceptorName   = "ModuleConfig:#arguments.moduleName#"
			);

			/*
			|--------------------------------------------------------------------------
			| Module Models
			|--------------------------------------------------------------------------
			*/
			if ( mConfig.autoMapModels AND directoryExists( mconfig.modelsPhysicalPath ) ) {
				var binder = mConfig.injector.getBinder();

				// Add as a mapped directory with module name as the namespace with correct mapping path
				var packagePath = (
					len( mConfig.cfmapping ) ? mConfig.cfmapping & ".#mConfig.conventions.modelsLocation#" : mConfig.modelsInvocationPath
				);

				// Module Injector : Map with no namespace in the local injector
				if ( mConfig.moduleInjector ) {
					binder.mapDirectory( packagePath = packagePath, process = mConfig.autoProcessModels );
				}

				// Map with namespace
				if ( len( mConfig.modelNamespace ) ) {
					binder.mapDirectory(
						packagePath: packagePath,
						namespace  : "@#mConfig.modelNamespace#",
						process    : mConfig.autoProcessModels
					);
				} else {
					binder.mapDirectory( packagePath = packagePath, process = mConfig.autoProcessModels );
				}

				// Register Default Module Export if it exists as @moduleName, so you can do getInstance( "@moduleName" )
				if ( fileExists( mconfig.modelsPhysicalPath & "/#arguments.moduleName#.cfc" ) ) {
					mConfig.injector
						.getBinder()
						.map( [
							"@#arguments.moduleName#",
							"@#mConfig.modelNamespace#"
						] )
						.to( packagePath & ".#arguments.moduleName#" );
				}

				// Process mapped data if true
				if ( mConfig.autoProcessModels ) {
					binder.processMappings();
				}
			}

			/*
			|--------------------------------------------------------------------------
			| Module Interceptors
			|--------------------------------------------------------------------------
			*/
			mConfig.interceptors.each( function( thisInterceptor ){
				variables.interceptorService.registerInterceptor(
					interceptorClass     : thisInterceptor.class,
					interceptorProperties: thisInterceptor.properties,
					interceptorName      : thisInterceptor.name & "@" & moduleName,
					injector             : mConfig.injector
				);
			} );

			/*
			|--------------------------------------------------------------------------
			| Module Routing
			|--------------------------------------------------------------------------
			*/
			if ( mConfig.entryPoint.len() ) {
				var parentEntryPoint      = "";
				var visitParentEntryPoint = function( parent ){
					var moduleConfig   = modules[ arguments.parent ];
					var thisEntryPoint = reReplace( moduleConfig.entryPoint, "^/", "" );
					// Do we recurse?
					if ( len( moduleConfig.parent ) ) {
						return visitParentEntryPoint( moduleConfig.parent ) & "/" & thisEntryPoint;
					}
					return thisEntryPoint;
				};

				// Discover parent inherit mapping? if set to true and we actually have a parent
				if ( mConfig.inheritEntryPoint && len( mConfig.parent ) ) {
					parentEntryPoint = visitParentEntryPoint( mConfig.parent ) & "/";
				}

				// Store Inherited Entry Point
				mConfig.inheritedEntryPoint = parentEntryPoint & reReplace( mConfig.entryPoint, "^/", "" );

				// Register Module Routing Entry Point + Struct Literals for routes and resources
				appRouter.addModuleRoutes(
					pattern = mConfig.inheritedEntryPoint,
					module  = arguments.moduleName,
					append  = false
				);

				// config/Router.cfc Conventions
				if ( fileExists( mConfig.routerPhysicalPath ) ) {
					// Process as a Router.cfc with virtual inheritance
					mConfig.injector
						.registerNewInstance(
							name         = mConfig.routerInvocationPath,
							instancePath = mConfig.routerInvocationPath
						)
						.setVirtualInheritance( "coldbox.system.web.routing.Router" )
						.setThreadSafe( true )
						.addDIConstructorArgument( name = "controller", value = variables.controller );
					// Create the Router back into the config
					mConfig.router = mConfig.injector.getInstance( mConfig.routerInvocationPath );
					// Register the Config as an observable also.
					variables.interceptorService.registerInterceptor(
						interceptorObject = mConfig.router,
						interceptorName   = "Router@#arguments.moduleName#"
					);
					// Process it
					mConfig.router.configure();
				}

				// Add convention based routing if it does not exist.
				var conventionsRouteExists = mConfig.router
					.getRoutes()
					.findAll( function( item ){
						return ( item.pattern == "/:handler/:action" || item.pattern == ":handler/:action" );
					} );
				if ( arrayLen( conventionsRouteExists ) == 0 ) {
					mConfig.router.route( "/:handler/:action?" ).end();
				};

				// Process Module Router
				mConfig.router
					.getRoutes()
					.each( function( item ){
						// Incorporate module context
						if ( !item.module.len() ) {
							item.module = moduleName;
						}
						// Add to App Router
						appRouter.getModuleRoutes( moduleName ).append( item );
					} );
			}

			// Register App and View Helpers
			if ( arrayLen( mConfig.applicationHelper ) ) {
				// Map the helpers with the right mapping if not starting with /
				mConfig.applicationHelper = mConfig.applicationHelper.map( function( item ){
					return ( reFind( "^/", item ) ? item : "#mConfig.mapping#/#item#" );
				} );

				// Incorporate into global helpers
				variables.controller.getSetting( "applicationHelper" ).addAll( mConfig.applicationHelper );
			}

			/*
			|--------------------------------------------------------------------------
			| Module Executors
			|--------------------------------------------------------------------------
			*/
			mConfig.executors.each( function( key, config ){
				arguments.config.name = arguments.key;
				variables.controller.getAsyncManager().newExecutor( argumentCollection = arguments.config );
				variables.logger.info( "+ Registered Module (#moduleName#) Executor: #arguments.key#" );
			} );

			/*
			|--------------------------------------------------------------------------
			| Module Schedulers
			|--------------------------------------------------------------------------
			*/
			if ( fileExists( mConfig.schedulerPhysicalPath ) ) {
				mConfig.scheduler = variables.controller
					.getSchedulerService()
					.loadScheduler(
						name  : "cbScheduler@#arguments.moduleName#",
						path  : mConfig.schedulerInvocationPath,
						module: arguments.moduleName
					);
			}

			/*
			|--------------------------------------------------------------------------
			| onLoad() Lifecycle
			|--------------------------------------------------------------------------
			*/
			if ( structKeyExists( variables.mConfigCache[ arguments.moduleName ], "onLoad" ) ) {
				variables.mConfigCache[ arguments.moduleName ].onLoad();
			}

			// Mark it as loaded as it is now activated
			mConfig.activated = true;

			/*
			|--------------------------------------------------------------------------
			| Activate Module Children
			|--------------------------------------------------------------------------
			*/
			mConfig.childModules.each( function( thisChild ){
				activateModule( moduleName = thisChild );
			} );

			// Log activation time
			mConfig.activationTime = getTickCount() - sTime;

			/*
			|--------------------------------------------------------------------------
			| Module Done Event
			|--------------------------------------------------------------------------
			*/
			variables.interceptorService.announce(
				"postModuleLoad",
				{
					moduleLocation : mConfig.path,
					moduleName     : arguments.moduleName,
					moduleConfig   : mConfig
				}
			);

			// We are done! Phew!
			variables.logger.info(
				"+ Module (#arguments.moduleName#@#mConfig.version#) activated in (#mConfig.activationTime#ms)"
			);
		}
		// end lock

		return this;
	}

	/**
	 * Reload a targeted module
	 *
	 * @moduleName The module
	 */
	ModuleService function reload( required moduleName ){
		unload( arguments.moduleName );
		registerModule( arguments.moduleName );
		activateModule( arguments.moduleName );
		return this;
	}

	/**
	 * Reload all modules
	 */
	ModuleService function reloadAll(){
		unloadAll();
		registerAllModules();
		activateAllModules();
		return this;
	}

	/**
	 * Get a listing of all loaded modules
	 */
	array function getLoadedModules(){
		return structKeyArray( variables.registeredModules );
	}

	/**
	 * Check and see if a module has been registered
	 *
	 * @moduleName The module
	 */
	function isModuleRegistered( required moduleName ){
		return structKeyExists( variables.registeredModules, arguments.moduleName );
	}

	/**
	 * Check and see if a module has been activated
	 *
	 * @moduleName The module
	 */
	boolean function isModuleActive( required moduleName ){
		var modules = variables.registeredModules;
		return (
			isModuleRegistered( arguments.moduleName ) and modules[ arguments.moduleName ].activated ? true : false
		);
	}

	/**
	 * Unload a module if found from the configuration
	 *
	 * @moduleName The module
	 *
	 * @return If the module unloaded or not
	 */
	boolean function unload( required moduleName ){
		// This method basically unregisters the module configuration
		var appConfig          = variables.controller.getConfigSettings();
		var exceptionUnloading = "";

		// Check if module is loaded? else skip
		if ( NOT structKeyExists( appConfig.modules, arguments.moduleName ) ) {
			return false;
		}

		lock
			name          ="module#variables.controller.getAppHash()#.unload.#arguments.moduleName#"
			type          ="exclusive"
			timeout       ="20"
			throwontimeout="true" {
			// Check if module is loaded?
			if ( NOT structKeyExists( appConfig.modules, arguments.moduleName ) ) {
				return false;
			}

			// Shortcut to config due to ACF16 stupid parser bug on member functions
			var mConfig = appConfig.modules[ arguments.moduleName ];

			// Before unloading a module interception
			variables.interceptorService.announce( "preModuleUnload", { moduleName : arguments.moduleName } );

			// Call on module configuration object onLoad() if found
			if ( structKeyExists( variables.mConfigCache[ arguments.moduleName ], "onUnload" ) ) {
				try {
					variables.mConfigCache[ arguments.moduleName ].onUnload();
				} catch ( Any e ) {
					variables.logger.error(
						"X: Error unloading module: #arguments.moduleName#. #e.message# #e.detail#",
						e
					);
					exceptionUnloading = e;
				}
			}

			// Unregister scheduler if loaded
			if ( isObject( mConfig.scheduler ) ) {
				variables.controller.getSchedulerService().removeScheduler( mConfig.scheduler.getName() );
			}

			// Unregister app Helpers
			if ( arrayLen( mConfig.applicationHelper ) ) {
				controller.setSetting(
					"applicationHelper",
					arrayFilter( controller.getSetting( "applicationHelper" ), function( helper ){
						return ( !arrayFindNoCase( appConfig.modules[ moduleName ].applicationHelper, helper ) );
					} )
				);
			}

			// Unregister all interceptors
			for ( var x = 1; x lte arrayLen( mConfig.interceptors ); x++ ) {
				variables.interceptorService.unregister( mConfig.interceptors[ x ].name );
			}

			// Unregister Config object
			variables.interceptorService.unregister( "ModuleConfig:#arguments.moduleName#" );

			// Remove SES if enabled.
			if ( controller.settingExists( "sesBaseURL" ) ) {
				variables.wirebox.getInstance( "router@coldbox" ).removeModuleRoutes( arguments.moduleName );
			}

			// Remove executors
			mConfig.executors.each( function( key, config ){
				variables.controller.getAsyncManager().deleteExecutor( arguments.key );
			} );

			// Remove configuration
			structDelete( appConfig.modules, arguments.moduleName );

			// Remove Configuration object from Cache
			structDelete( variables.mConfigCache, arguments.moduleName );

			// After unloading a module interception
			variables.interceptorService.announce( "postModuleUnload", { moduleName : arguments.moduleName } );

			// Log it
			if ( variables.logger.canInfo() ) {
				variables.logger.info( "+ Module #arguments.moduleName# unloaded successfully." );
			}

			// Do we need to throw exception?
			if ( !isSimpleValue( exceptionUnloading ) ) {
				throw( exceptionUnloading );
			}
		}
		// end lock

		return true;
	}

	/**
	 * Unload all registered modules
	 */
	ModuleService function unloadAll(){
		// Verify registered modules
		if ( !isNull( variables.registeredModules ) && isStruct( variables.registeredModules ) ) {
			// Unload all modules
			variables.registeredModules.each( function( key, module ){
				unload( arguments.key );
			} );
		}
		return this;
	}

	/**
	 * Load the module configuration object and return it now loaded
	 *
	 * @config     The config structure
	 * @moduleName The module name
	 * @parent     The parent that invoked the registration
	 * @parent     The parent injector this module will be linked to
	 *
	 * @return struct : { config:cfc, injector:cfc }
	 */
	struct function loadModuleConfiguration(
		required struct config,
		required moduleName,
		parent         = "",
		parentInjector = ""
	){
		var appSettings = controller.getConfigSettings();
		var envUtil     = variables.wirebox.getInstance( "Env@coreDelegates" );
		var mConfig     = arguments.config;
		var results     = { "config" : "", "injector" : "" };

		/*
		|--------------------------------------------------------------------------
		| Build the Module Configuration
		|--------------------------------------------------------------------------
		*/
		results.config = variables.wirebox.getInstance( mConfig.invocationPath & ".ModuleConfig" );

		/*
		|--------------------------------------------------------------------------
		| Module Properties Processing
		|--------------------------------------------------------------------------
		*/

		// title
		param results.config.title = arguments.moduleName;
		mConfig.title              = results.config.title;
		// aliases
		if ( structKeyExists( results.config, "aliases" ) ) {
			// inflate list to array
			if ( isSimpleValue( results.config.aliases ) ) {
				results.config.aliases = listToArray( results.config.aliases );
			}
			mConfig.aliases = results.config.aliases;
		}
		// author
		param results.config.author         = "";
		mConfig.author                      = results.config.author;
		// web url
		param results.config.webURL         = "";
		mConfig.webURL                      = results.config.webURL;
		// description
		param results.config.description    = "";
		mConfig.description                 = results.config.description;
		// version
		param results.config.version        = "1.0.0";
		mConfig.version                     = results.config.version;
		// cf mapping
		param results.config.cfmapping      = "";
		mConfig.cfmapping                   = results.config.cfmapping;
		// Module Injector
		param results.config.moduleInjector = false;
		mConfig.moduleInjector              = results.config.moduleInjector;
		// model namespace override
		if ( structKeyExists( results.config, "modelNamespace" ) ) {
			mConfig.modelNamespace = results.config.modelNamespace;
		}
		// Auto map models
		if ( structKeyExists( results.config, "autoMapModels" ) ) {
			mConfig.autoMapModels = results.config.autoMapModels;
		}
		// Dependencies
		if ( structKeyExists( results.config, "dependencies" ) ) {
			// set it always as an array
			mConfig.dependencies = isSimpleValue( results.config.dependencies ) ? listToArray(
				results.config.dependencies
			) : results.config.dependencies;
		}
		// Application Helpers
		if ( structKeyExists( results.config, "applicationHelper" ) ) {
			// set it always as an array
			mConfig.applicationHelper = isSimpleValue( results.config.applicationHelper ) ? listToArray(
				results.config.applicationHelper
			) : results.config.applicationHelper;
		}
		// Parent Lookups
		mConfig.viewParentLookup = true;
		if ( structKeyExists( results.config, "viewParentLookup" ) ) {
			mConfig.viewParentLookup = results.config.viewParentLookup;
		}
		mConfig.layoutParentLookup = true;
		if ( structKeyExists( results.config, "layoutParentLookup" ) ) {
			mConfig.layoutParentLookup = results.config.layoutParentLookup;
		}
		// Entry Point
		mConfig.entryPoint = "";
		if ( structKeyExists( results.config, "entryPoint" ) ) {
			mConfig.entryPoint = results.config.entryPoint;
		}
		// Inherit Entry Point
		mConfig.inheritEntryPoint = false;
		if ( structKeyExists( results.config, "inheritEntryPoint" ) ) {
			mConfig.inheritEntryPoint = results.config.inheritEntryPoint;
		}
		// Disabled
		mConfig.disabled = false;
		if ( structKeyExists( results.config, "disabled" ) ) {
			mConfig.disabled = results.config.disabled;
		}
		// Activated
		mConfig.activate = true;
		if ( structKeyExists( results.config, "activate" ) ) {
			mConfig.activate = results.config.activate;
		}

		/**
		 *--------------------------------------------------------------------------
		 * Build the Module's Injector Hierarchy
		 *--------------------------------------------------------------------------
		 * Only build it if we are in moduleInjector = true mode.
		 */
		if ( mConfig.moduleInjector ) {
			results.injector = new coldbox.system.ioc.Injector(
				binder    : { scopeRegistration : { enabled : false } },
				properties: appSettings,
				coldbox   : controller,
				name      : mConfig.injectorName
			).setRoot( variables.wirebox );

			// Register the child injector via parent or root
			if ( len( arguments.parent ) ) {
				results.injector.setParent( arguments.parentInjector );
				arguments.parentInjector.registerChildInjector(
					name : mConfig.injectorName,
					child: results.injector
				);
			} else {
				// Set parent to the module's injector
				results.injector.setParent( variables.wirebox );
				// Register the module's injector in the parent
				variables.wirebox.registerChildInjector( name: mConfig.injectorName, child: results.injector );
			}

			/*
			|--------------------------------------------------------------------------
			| Register the module injector in the root reference map
			| This is used for providers, so specific injectors can be located
			|--------------------------------------------------------------------------
			*/
			variables.wirebox.registerInjectorReference( results.injector );
		} else {
			results.injector = variables.wirebox;
		}

		/*
		|--------------------------------------------------------------------------
		| Module Router Creation
		|--------------------------------------------------------------------------
		*/

		mConfig.router = results.injector.getInstance( "coldbox.system.web.routing.Router" );

		/*
		|--------------------------------------------------------------------------
		| Module Injections
		|--------------------------------------------------------------------------
		*/
		results.config
			.injectPropertyMixin( "controller", controller )
			.injectPropertyMixin( "coldboxVersion", controller.getColdBoxSettings().version )
			.injectPropertyMixin( "appMapping", controller.getSetting( "appMapping" ) )
			.injectPropertyMixin( "moduleMapping", mConfig.mapping )
			.injectPropertyMixin( "modulePath", mConfig.path )
			.injectPropertyMixin( "logBox", controller.getLogBox() )
			.injectPropertyMixin( "log", controller.getLogBox().getLogger( results.config ) )
			.injectPropertyMixin( "wirebox", results.injector )
			.injectPropertyMixin( "rootWirebox", variables.wirebox )
			.injectPropertyMixin( "binder", results.injector.getBinder() )
			.injectPropertyMixin( "cachebox", controller.getCacheBox() )
			.injectPropertyMixin( "getJavaSystem", envUtil.getJavaSystem )
			.injectPropertyMixin( "getSystemSetting", envUtil.getSystemSetting )
			.injectPropertyMixin( "getSystemProperty", envUtil.getSystemProperty )
			.injectPropertyMixin( "getEnv", envUtil.getEnv )
			.injectPropertyMixin( "appRouter", variables.wireBox.getInstance( "router@coldbox" ) )
			.injectPropertyMixin( "router", arguments.config.router );

		/*
		|--------------------------------------------------------------------------
		| Execute the configuration for the module
		|--------------------------------------------------------------------------
		*/
		results.config.configure();

		/*
		|--------------------------------------------------------------------------
		| Module Environment Control
		|--------------------------------------------------------------------------
		*/
		if ( structKeyExists( results.config, appSettings.environment ) ) {
			invoke( results.config, "#appSettings.environment#" );
		}

		/*
		|--------------------------------------------------------------------------
		| Module Parent Settings
		|--------------------------------------------------------------------------
		*/
		mConfig.parentSettings = results.config.getPropertyMixin( "parentSettings", "variables", {} );

		/*
		|--------------------------------------------------------------------------
		| Module Settings + Global App Overrides
		|--------------------------------------------------------------------------
		*/

		mConfig.settings = results.config.getPropertyMixin( "settings", "variables", {} );
		if ( structKeyExists( results.config, "parseParentSettings" ) ) {
			mConfig.parseParentSettings = results.config.parseParentSettings;
		}

		// If true, then look into the global app and load the module config overrides
		if ( mConfig.parseParentSettings ) {
			// Global config/Coldbox.cfc moduleSettings override
			var globalModuleSettings = controller
				.getSetting( "ColdBoxConfig" )
				.getPropertyMixin( "moduleSettings", "variables", {} );
			param name="globalModuleSettings[ mConfig.modelNamespace ]" default="#structNew()#";
			mConfig.settings.append( globalModuleSettings[ mConfig.modelNamespace ], true );

			// config/{mConfig.modelNamespace}.cfc overrides
			if ( fileExists( "#appSettings.applicationPath#config/modules/#mConfig.modelnamespace#.cfc" ) ) {
				loadModuleSettingsOverride( mConfig, mConfig.modelNamespace );
			}
		}
		// Store the reference globally
		appSettings.moduleSettings[ mConfig.modelNamespace ] = mConfig.settings;

		/*
		|--------------------------------------------------------------------------
		| Module Interceptor Normalizations and Custom Interception Points
		|--------------------------------------------------------------------------
		*/
		mConfig.interceptors = results.config.getPropertyMixin( "interceptors", "variables", [] );
		for ( var x = 1; x lte arrayLen( mConfig.interceptors ); x = x + 1 ) {
			// Name check
			if ( NOT structKeyExists( mConfig.interceptors[ x ], "name" ) ) {
				mConfig.interceptors[ x ].name = listLast( mConfig.interceptors[ x ].class, "." );
			}
			// Properties check
			if ( NOT structKeyExists( mConfig.interceptors[ x ], "properties" ) ) {
				mConfig.interceptors[ x ].properties = structNew();
			}
		}

		mConfig.interceptorSettings = results.config.getPropertyMixin(
			"interceptorSettings",
			"variables",
			structNew()
		);
		if ( NOT structKeyExists( mConfig.interceptorSettings, "customInterceptionPoints" ) ) {
			mConfig.interceptorSettings.customInterceptionPoints = "";
		}

		/*
		|--------------------------------------------------------------------------
		| Module Executors
		|--------------------------------------------------------------------------
		*/
		mConfig.executors = results.config.getPropertyMixin( "executors", "variables", {} );

		/*
		|--------------------------------------------------------------------------
		| Module Routing
		|--------------------------------------------------------------------------
		*/
		mConfig.routes    = results.config.getPropertyMixin( "routes", "variables", [] );
		mConfig.resources = results.config.getPropertyMixin( "resources", "variables", [] );

		/*
		|--------------------------------------------------------------------------
		| Module Conventions
		|--------------------------------------------------------------------------
		*/
		structAppend(
			mConfig.conventions,
			results.config.getPropertyMixin( "conventions", "variables", {} ),
			true
		);

		/*
		|--------------------------------------------------------------------------
		| Module Layouts/Views
		|--------------------------------------------------------------------------
		*/
		structAppend(
			mConfig.layoutSettings,
			results.config.getPropertyMixin( "layoutSettings", "variables", {} ),
			true
		);

		return results;
	}

	/************************************ PRIVATE ****************************************/

	/**
	 * Build the modules registry
	 *
	 * @locations The array of locations to register
	 */
	private function buildRegistry( required array locations ){
		arguments.locations
			.filter( function( item ){
				return item.trim().len();
			} )
			.each( function( item ){
				// Get all modules found in the module location and append to module registry, only new ones are added
				scanModulesDirectory( item );
			} );
	}

	/**
	 * Load module settings override from config disk
	 *
	 * @config     The module config struct
	 * @moduleName The target module name
	 */
	private function loadModuleSettingsOverride( required struct config, required moduleName ){
		var mConfig     = arguments.config;
		var appSettings = controller.getConfigSettings();
		var configPath  = len( appSettings.appMapping ) ? "#appSettings.appMapping#.config.modules.#arguments.moduleName#" : "config.modules.#arguments.moduleName#";
		var oConfig     = variables.wirebox.getInstance( configPath );
		var envUtil     = variables.wirebox.getInstance( "Env@coreDelegates" );

		/*
		|--------------------------------------------------------------------------
		| Config Injections
		|--------------------------------------------------------------------------
		*/
		oConfig
			.injectPropertyMixin( "controller", controller )
			.injectPropertyMixin( "coldboxVersion", controller.getColdBoxSettings().version )
			.injectPropertyMixin( "appMapping", controller.getSetting( "appMapping" ) )
			.injectPropertyMixin( "moduleMapping", mConfig.mapping )
			.injectPropertyMixin( "modulePath", mConfig.path )
			.injectPropertyMixin( "logBox", controller.getLogBox() )
			.injectPropertyMixin( "log", controller.getLogBox().getLogger( oConfig ) )
			.injectPropertyMixin( "wirebox", variables.wireBox )
			.injectPropertyMixin( "binder", variables.wireBox.getBinder() )
			.injectPropertyMixin( "cachebox", controller.getCacheBox() )
			.injectPropertyMixin( "getJavaSystem", envUtil.getJavaSystem )
			.injectPropertyMixin( "getSystemSetting", envUtil.getSystemSetting )
			.injectPropertyMixin( "getSystemProperty", envUtil.getSystemProperty )
			.injectPropertyMixin( "getEnv", envUtil.getEnv )
			.injectPropertyMixin( "appRouter", variables.wireBox.getInstance( "router@coldbox" ) )
			.injectPropertyMixin( "router", arguments.config.router );

		/*
		|--------------------------------------------------------------------------
		| Module Settings Config Seeding
		|--------------------------------------------------------------------------
		*/
		mConfig.settings.append( oConfig.configure(), true );

		/*
		|--------------------------------------------------------------------------
		| Module Environment Control
		|--------------------------------------------------------------------------
		*/
		// Get parent environment settings and if same convention of 'environment'() found, execute it.
		if ( structKeyExists( oConfig, appSettings.environment ) ) {
			invoke(
				oConfig,
				"#appSettings.environment#",
				[ mConfig.settings ]
			);
		}
	};

	/**
	 * Get an array of modules found and add to the registry structure
	 *
	 * @dirPath The path to scan
	 */
	private function scanModulesDirectory( required dirPath ){
		var expandedPath = expandPath( arguments.dirpath );

		directoryList( expandedPath, false, "array", "", "asc" )
			.filter( function( item ){
				// Only directories please and no . folders
				return ( directoryExists( item ) && !item.listLast( "\/" ).find( "." ) );
			} )
			.each( function( item ){
				var moduleName = item.listLast( "\/" );
				// Add only if it does not exist, so location preference kicks in
				if ( not structKeyExists( variables.moduleRegistry, moduleName ) ) {
					variables.moduleRegistry[ moduleName ] = {
						locationPath   : dirPath,
						physicalPath   : expandedPath,
						invocationPath : replace(
							reReplace( dirPath, "^/", "" ),
							"/",
							".",
							"all"
						)
					};
				} else {
					variables.logger.debug(
						"Found duplicate module: #moduleName# in #dirPath#. Skipping its registration in our module registry, order of preference given."
					);
				}
			} );
	}

	/**
	 * Checks if the module can be loaded or registered
	 *
	 * @moduleName The module to check
	 */
	private boolean function canLoad( required moduleName ){
		var excludeModules = arrayToList( controller.getSetting( "ModulesExclude" ) );

		// If we have excludes and in the excludes
		if ( len( excludeModules ) and listFindNoCase( excludeModules, arguments.moduleName ) ) {
			variables.logger.info( "> Module: #arguments.moduleName# excluded from loading." );
			return false;
		}

		return true;
	}

}
