﻿/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * The WireBox injector is the pivotal class in WireBox that performs dependency injection.
 * It can be used standalone or it can be used in conjunction of a ColdBox application context.
 * It can also be configured with a mapping configuration file called a binder, that can provide object/mappings and configuration data.
 *
 * A WireBox Injector: Builds the graphs of objects that make up your application.
 *
 * All injectors implement: coldbox.system.ioc.IInjector
 *
 * Easy Startup:
 * <pre class='brush: cf'>
 * injector = new coldbox.system.ioc.Injector();
 * </pre>
 *
 * Inline Config:
 * <pre class='brush: cf'>
 * injector = new coldbox.system.ioc.Injector( { scopeRegistration : { enabled : false } } );
 * </pre>
 *
 * Binder Startup
 * <pre class='brush: cf'>
 * injector = new coldbox.system.ioc.Injector(new MyBinder());
 * </pre>
 *
 * Binder Path Startup
 * <pre class='brush: cf'>
 * injector = new coldbox.system.ioc.Injector( "config.MyBinder" );
 * </pre>
 *
 * @see coldbox.system.ioc.IInjector
 */
component serializable="false" accessors="true" {

	/**
	 * ColdBox  Utility class
	 */
	property name="utility";

	/**
	 * Scope Storages Utility
	 */
	property name="scopeStorage";

	/**
	 * WireBox Version
	 */
	property name="version";

	/**
	 * The Configuration Binder object
	 */
	property name="binder";

	/**
	 * ColdBox Application Link
	 */
	property name="coldbox";

	/**
	 * CacheBox Link
	 */
	property name="cacheBox";

	/**
	 * Event Manager Link
	 */
	property name="eventManager";

	/**
	 * Configured Event States
	 */
	property name="eventStates" type="array";

	/**
	 * LogBox and Class Logger
	 */
	property name="logBox";

	/**
	 * Log Reference
	 */
	property name="log";

	/**
	 * Parent Injector
	 */
	property name="parent";

	/**
	 * Root Injector instance
	 */
	property name="root";

	/**
	 * LifeCycle Scopes
	 */
	property name="scopes";

	/**
	 * The injector Unique ID
	 */
	property name="injectorID";

	/**
	 * The Global AsyncManager
	 *
	 * @see coldbox.system.async.AsyncManager
	 */
	property name="asyncManager";

	/**
	 * The logBox task scheduler executor
	 *
	 * @see coldbox.system.async.executors.ScheduledExecutor
	 */
	property name="taskScheduler";

	/**
	 * An injector can have children injectors referenced by a unique name
	 */
	property name="childInjectors" type="struct";

	/**
	 * The name of the injector
	 */
	property name="name" type="string";

	/**
	 * The object builder for this injector
	 */
	property name="objectBuilder";

	/**
	 * The default binder class to use when no binder is passed to the injector
	 */
	variables.DEFAULT_BINDER = "coldbox.system.ioc.config.DefaultBinder";
	variables.IS_BOXLANG     = server.keyExists( "boxlang" );
	variables.IS_CLI         = variables.IS_BOXLANG && server.boxlang.cliMode ? true : false;

	/**
	 * WireBox can be constructed with no parameters and it will use the default binder: `coldbox.system.ioc.config.DefaultBinder` for configuration
	 * and place the instance in `application.wirebox` scope for easy access.
	 *
	 * However you can also instantiate Wirebox with:
	 * - A binder instance
	 * - A binder path
	 * - A WireBox configuration DSL structure
	 *
	 * @binder              A binder instance, path, or DSL structure to configure WireBox with
	 * @properties          A structure of binding properties to passthrough to the Binder Configuration CFC
	 * @coldbox             A coldbox application context that this instance of WireBox can be linked to, if not using it, we just ignore it.
	 * @coldbox.doc_generic coldbox.system.web.Controller
	 * @name                The internal name of the injector, defaults to 'root' if not passed
	 **/
	Injector function init(
		binder            = variables.DEFAULT_BINDER,
		struct properties = structNew(),
		coldbox           = "",
		name              = "root"
	){
		// Setup Available public scopes
		this.SCOPES                 = new coldbox.system.ioc.Scopes();
		// Setup Available public types
		this.TYPES                  = new coldbox.system.ioc.Types();
		// Build out the utilities
		variables.utility           = new coldbox.system.core.util.Util();
		variables.mixerUtil         = variables.utility.getMixerUtil();
		// Store name
		variables.name              = arguments.name;
		// Instance contains lookup
		variables.containsLookupMap = createObject( "java", "java.util.concurrent.ConcurrentHashMap" ).init();
		// Scope Storage
		variables.scopeStorage      = new coldbox.system.core.collections.ScopeStorage();
		// Do we have a binder?
		if ( isSimpleValue( arguments.binder ) AND NOT len( trim( arguments.binder ) ) ) {
			arguments.binder = variables.DEFAULT_BINDER;
		}
		// Version
		variables.version      = "@build.version@+@build.number@";
		// The Configuration Binder object
		variables.binder       = "";
		// ColdBox Application Link
		variables.coldbox      = "";
		// LogBox Link
		variables.logBox       = "";
		// CacheBox Link
		variables.cacheBox     = "";
		// Event Manager Link
		variables.eventManager = "";
		// Configured Event States
		variables.eventStates  = [
			"afterInjectorConfiguration", // X once injector is created and configured
			"beforeInstanceCreation", // X Before an injector creates or is requested an instance of an object, the mapping is passed.
			"afterInstanceInitialized", // X once the constructor is called and before DI is performed
			"afterInstanceCreation", // X once an object is created, initialized and done with DI
			"beforeInstanceInspection", // X before an object is inspected for injection metadata
			"afterInstanceInspection", // X after an object has been inspected and metadata is ready to be saved
			"beforeInjectorShutdown", // X right before the shutdown procedures start
			"afterInjectorShutdown", // X right after the injector is shutdown
			"beforeInstanceAutowire", // X right before an instance is autowired
			"afterInstanceAutowire", // X right after an instance is autowired
			"onInjectorMissingDependency" // when a dependency can't be located, last chance to provide it.
		];
		// LogBox and Class Logger
		variables.logBox = "";
		variables.log    = "";
		// Parent Injector
		variables.parent = "";
		// Root Injector
		variables.root   = "";
		// LifeCycle Scopes
		variables.scopes = {
			"APPLICATION" : "",
			"CACHEBOX"    : "",
			"NOSCOPE"     : "",
			"REQUEST"     : "",
			"SERVER"      : "",
			"SESSION"     : "",
			"SINGLETON"   : ""
		};
		// Child Injectors
		variables.childInjectors       = structNew( "ordered" );
		// Injector Reference Map for quick location via named injectors
		variables.injectorReferenceMap = {};

		// Prepare instance ID
		variables.injectorID = createUUID();
		// Prepare Lock Info
		variables.lockName   = "WireBox.Injector.#variables.injectorID#";
		// Link ColdBox Context if passed
		variables.coldbox    = arguments.coldbox;
		// Register the task scheduler according to operating mode
		if ( !isObject( variables.coldbox ) ) {
			variables.asyncManager  = new coldbox.system.async.AsyncManager();
			variables.taskScheduler = variables.asyncManager.newScheduledExecutor(
				name   : "wirebox-tasks",
				threads: 20
			);
		} else {
			// link LogBox
			variables.logBox        = variables.coldbox.getLogBox();
			// Configure Logging for this injector
			variables.log           = variables.logBox.getLogger( this );
			// Link CacheBox
			variables.cacheBox      = variables.coldbox.getCacheBox();
			// Link Event Manager
			variables.eventManager  = variables.coldbox.getInterceptorService();
			// Link Async Manager
			variables.asyncManager  = variables.coldbox.getAsyncManager();
			variables.taskScheduler = variables.asyncManager.getExecutor( "coldbox-tasks" );
		}

		// Configure the injector for operation
		configure( arguments.binder, arguments.properties );

		return this;
	}

	/**
	 * Verify if a child injector has been registered by name
	 *
	 * @name The name of the child injector to check
	 */
	boolean function hasChildInjector( required name ){
		return variables.childInjectors.keyExists( arguments.name );
	}

	/**
	 * Register a child injector instance with this injector and set this injector as a parent of the child.
	 *
	 * @name  The unique name to register the child with
	 * @child The child Injector instance to register
	 */
	Injector function registerChildInjector( required name, required child ){
		variables.childInjectors[ arguments.name ] = arguments.child.setParent( this );
		return this;
	}

	/**
	 * Remove a child injector from this injector
	 *
	 * @name The unique name of the child injector to remove
	 *
	 * @return Boolean indicator if the injector was found and removed (true) or not found and not removed (false)
	 */
	boolean function removeChildInjector( required name ){
		if ( variables.childInjectors.keyExists( arguments.name ) ) {
			variables.childInjectors[ arguments.name ].shutdown( this );
			return structDelete( variables.childInjectors, arguments.name );
		}
		return falase;
	}

	/**
	 * Get a child injector from this injector
	 *
	 * @throws ChildNotFoundException - If the passed child name does not exist with this injector
	 */
	Injector function getChildInjector( required name ){
		if ( variables.childInjectors.keyExists( arguments.name ) ) {
			return variables.childInjectors[ arguments.name ];
		}
		throw(
			type   : "ChildNotFoundException",
			message: "The child (#arguments.name#) has not been registered in this injector",
			detail : "Registered children are (#structKeyList( variables.childInjectors )#)"
		);
	}

	/**
	 * Get an array of all the registered child injectors in this injector
	 */
	array function getChildInjectorNames(){
		return variables.childInjectors.keyArray();
	}

	/**
	 * Register an injector to be tracked in the lookup reference map. Used for providers mostly.
	 *
	 * @injector The injector to track
	 */
	Injector function registerInjectorReference( required injector ){
		variables.injectorReferenceMap[ arguments.injector.getName() ] = arguments.injector;
		return this;
	}

	/**
	 * Get an injector reference by unique name
	 *
	 * @name The unique injector reference name
	 */
	Injector function getInjectorReference( required name ){
		return variables.injectorReferenceMap[ arguments.name ];
	}

	/**
	 * Get an array of registered injector references
	 */
	array function getInjectorReferenceNames(){
		return variables.injectorReferenceMap.keyArray();
	}

	/**
	 * Configure this injector for operation, called by the init(). You can also re-configure this injector programmatically, but it is not recommended.
	 *
	 * @binder     The configuration binder object or path or dsl structure to configure this Injector instance with
	 * @properties A structure of binding properties to passthrough to the Configuration CFC
	 **/
	Injector function configure( required binder, required struct properties ){
		// Create and Configure Event Manager
		configureEventManager();

		// Store binder object built accordingly to our binder building procedures
		variables.binder = buildBinder( arguments.binder, arguments.properties );

		// Create local cache, logging and event management if not coldbox context linked.
		if ( NOT isColdBoxLinked() ) {
			// Running standalone, so create our own logging first
			configureLogBox( variables.binder.getLogBoxConfig() );
			// Create local CacheBox reference
			configureCacheBox( variables.binder.getCacheBoxConfig() );
		}

		// Create our object builder
		variables.objectBuilder = new coldbox.system.ioc.Builder( this );
		// Register Custom DSL Builders
		variables.objectBuilder.registerCustomBuilders();

		// Register All Custom Listeners
		registerListeners();

		// Register Life Cycle Scopes
		registerScopes();

		// Parent Injector declared
		if ( isObject( variables.binder.getParentInjector() ) ) {
			setParent( variables.binder.getParentInjector() );
		}

		// Scope registration if enabled?
		if ( variables.binder.getScopeRegistration().enabled ) {
			doScopeRegistration( variables.binder.getScopeRegistration() );
		}

		// Register binder as an interceptor
		variables.eventManager.register( variables.binder, "wirebox-binder" );

		// process mappings for metadata and initialization if enabled
		// we lazy load processing
		if ( variables.binder.getAutoProcessMappings() ) {
			variables.binder.processMappings();
		}

		// Process Eager Inits
		variables.binder.processEagerInits();

		// Check if binder has onLoad convention and execute callback
		if ( structKeyExists( variables.binder, "onLoad" ) ) {
			variables.binder.onLoad( this );
		}

		// Announce To Listeners we are online
		variables.eventManager.announce( "afterInjectorConfiguration", { injector : this } );

		return this;
	}

	/**
	 * Shutdown the injector gracefully by calling the shutdown events internally.
	 **/
	function shutdown(){
		var iData = { injector : this };

		// Log
		if ( !isNull( variables.log ) && variables.log.canInfo() ) {
			variables.log.info( "Shutdown of Injector: #getInjectorID()# requested and started." );
		}

		// Notify Listeners
		if ( !isNull( variables.eventManager ) ) {
			variables.eventManager.announce( "beforeInjectorShutdown", iData );
		}

		// Check if binder has onShutdown convention
		if ( !isNull( variables.binder ) && structKeyExists( variables.binder, "onShutdown" ) ) {
			variables.binder.onShutdown( this );
		}

		// Do we have children?
		if ( !isNull( variables.childInjectors ) && structCount( variables.childInjectors ) ) {
			variables.childInjectors.each( function( childName, childInstance ){
				arguments.childInstance.shutdown( this );
			} );
		}

		// standalone cachebox? Yes, then shut it down baby!
		if ( isCacheBoxLinked() ) {
			variables.cacheBox.shutdown( this );
		}

		// Remove from scope
		if ( !isNull( variables.binder ) ) {
			removeFromScope();
		}

		// Notify Listeners
		if ( !isNull( variables.eventManager ) ) {
			variables.eventManager.announce( "afterInjectorShutdown", iData );
		}

		// Log shutdown complete
		if ( !isNull( variables.log ) && variables.log.canInfo() ) {
			variables.log.info( "Shutdown of injector: #getInjectorID()# completed." );
		}

		// Shutdown LogBox last if not in ColdBox Mode
		if ( !isColdBoxLinked() && !isNull( variables.logBox ) ) {
			variables.logBox.shutdown();
		}

		// Shutdown Executors if not in ColdBox Mode
		// This needs to happen AFTER logbox is shutdown since they share the taskScheduler
		if ( !isColdBoxLinked() && !isNull( variables.asyncManager ) ) {
			variables.asyncManager.shutdownAllExecutors( force = true );
		}

		return this;
	}

	/**
	 * Locates, Creates, Injects and Configures an object model instance
	 *
	 * @name          The mapping name or CFC instance path to try to build up
	 * @initArguments The constructor structure of arguments to passthrough when initializing the instance
	 * @dsl           The dsl string to use to retrieve the instance model object, mutually exclusive with 'name
	 * @targetObject  The object requesting the dependency, usually only used by DSL lookups
	 * @injector      The child injector to use when retrieving the instance
	 *
	 * @return The requested instance
	 *
	 * @throws InstanceNotFoundException - When the requested instance cannot be found
	 * @throws InvalidChildInjector      - When you request an instance from an invalid child injector name
	 **/
	function getInstance(
		name,
		struct initArguments = {},
		dsl,
		targetObject = "",
		injector
	){
		// Explicit Child injector request?
		if ( !isNull( arguments.injector ) ) {
			if ( variables.childInjectors.keyExists( arguments.injector ) ) {
				var childInjector = variables.childInjectors[ arguments.injector ];
				structDelete( arguments, "injector" );
				return childInjector.getInstance( argumentCollection = arguments );
			}
			throw(
				type        : "InvalidChildInjector",
				message     : "The child injector you requested (#arguments.injector#) has not been registered",
				detail      : "The registered child injectors are [#structKeyList( variables.childInjectors )#]",
				extendedInfo: "Current Injector -> #getName()#"
			);
		}

		// Is the name a DSL?
		if ( !isNull( arguments.name ) && variables.objectBuilder.isDSLString( arguments.name ) ) {
			arguments.dsl = arguments.name;
		}

		// Get by DSL?
		if ( !isNull( arguments.dsl ) ) {
			return variables.objectBuilder.buildSimpleDSL(
				dsl          = arguments.dsl,
				targetID     = "ExplicitCall",
				targetObject = arguments.targetObject
			);
		}

		// Check if Mapping Exists in local binder
		if ( NOT variables.binder.mappingExists( arguments.name ) ) {
			// Try to discover it locally
			var instancePath = locateInstance( arguments.name );

			// If not found, then lookup in hierarchy
			if ( NOT len( instancePath ) ) {
				// Verify Children hierarchy first
				for ( var thisChild in variables.childInjectors ) {
					if ( variables.childInjectors[ thisChild ].containsInstance( arguments.name ) ) {
						return variables.childInjectors[ thisChild ].getInstance( argumentCollection = arguments );
					}
				}

				// Verify via ancestor if set
				if ( hasParent() ) {
					return variables.parent.getInstance( argumentCollection = arguments );
				}

				// Announce missing dependency event
				var iData = {
					name          : arguments.name,
					initArguments : arguments.initArguments,
					targetObject  : arguments.targetObject,
					injector      : this
				};
				variables.eventManager.announce( "onInjectorMissingDependency", iData );
				// Verify if an instance was built?
				if ( !isNull( iData.instance ) ) {
					return iData.instance;
				}

				// We could not find it
				if ( !isNull( variables.log ) && variables.log.canError() ) {
					variables.log.error(
						"Requested instance:#arguments.name# was not located in any declared scan location(s): #structKeyList( variables.binder.getScanLocations() )#, or by path or by hierarchy."
					);
				}
				throw(
					message     : "Instance not found: '#arguments.name#'",
					detail      : "The instance could not be located in any declared scan location(s) (#structKeyList( variables.binder.getScanLocations() )#) or full path location or parent or children",
					type        : "Injector.InstanceNotFoundException",
					extendedInfo: "Current Injector -> #getName()#"
				);
			}

			// Let's create a mapping for this requested convention name+path as it is the first time we see it
			registerNewInstance( arguments.name, instancePath );
		}

		// Get Requested Mapping (Guaranteed to exist now)
		var mapping = variables.binder.getMapping( arguments.name );

		// Check if the mapping has been discovered yet, and if it hasn't it must be autowired enabled in order to process.
		if ( NOT mapping.isDiscovered() ) {
			try {
				// process inspection of instance
				mapping.process( binder = variables.binder, injector = this );
			} catch ( any e ) {
				// Remove bad mapping
				var mappings = variables.binder.getMappings();
				mappings.delete( name );
				// rethrow
				throw( object = e );
			}
		}

		// Request object from scope now, we now have it from the scope created, initialized and wired
		var target = variables.scopes[ mapping.getScope() ].getFromScope( mapping, arguments.initArguments );

		// Announce creation, initialization and DI magicfinicitation!
		variables.eventManager.announce(
			"afterInstanceCreation",
			{ mapping : mapping, target : target, injector : this }
		);

		return target;
	}

	/**
	 * Build an instance, this is called from registered scopes only as they provide locking and transactions
	 *
	 * @mapping             The mapping to construct
	 * @mapping.doc_generic coldbox.system.ioc.config.Mapping
	 * @initArguments       The constructor structure of arguments to passthrough when initializing the instance
	 **/
	function buildInstance( required mapping, struct initArguments = {} ){
		// before construction event
		variables.eventManager.announce(
			"beforeInstanceCreation",
			{ mapping : arguments.mapping, injector : this }
		);

		var oModel = "";
		// determine construction type
		switch ( arguments.mapping.getType() ) {
			case "cfc": {
				oModel = variables.objectBuilder.buildCFC( arguments.mapping, arguments.initArguments );
				break;
			}
			case "java": {
				oModel = variables.objectBuilder.buildJavaClass( arguments.mapping );
				break;
			}
			case "webservice": {
				oModel = variables.objectBuilder.buildWebservice( arguments.mapping, arguments.initArguments );
				break;
			}
			case "constant": {
				oModel = arguments.mapping.getValue();
				break;
			}
			case "rss": {
				oModel = variables.objectBuilder.buildFeed( arguments.mapping );
				break;
			}
			case "dsl": {
				oModel = variables.objectBuilder.buildSimpleDSL(
					dsl      = arguments.mapping.getDSL(),
					targetID = arguments.mapping.getName()
				);
				break;
			}
			case "factory": {
				oModel = variables.objectBuilder.buildFactoryMethod( arguments.mapping, arguments.initArguments );
				break;
			}
			case "provider": {
				// verify if it is a simple value or closure/UDF
				if ( isSimpleValue( arguments.mapping.getPath() ) ) {
					oModel = getInstance( arguments.mapping.getPath() ).$get();
				} else {
					var closure = arguments.mapping.getPath();
					oModel      = closure( injector = this );
				}
				break;
			}
			default: {
				throw(
					message     = "Invalid Construction Type: #arguments.mapping.getType()#",
					type        = "Injector.InvalidConstructionType",
					extendedInfo: "Current Injector -> #getName()#"
				);
			}
		}

		// Check and see if this mapping as an influence closure
		if ( arguments.mapping.hasInfluenceClosure() ) {
			var influenceClosure = arguments.mapping.getInfluenceClosure();
			// Influence the creation of the instance
			var result           = influenceClosure( instance = oModel, injector = this );
			// Allow the closure to override the entire instance if it wishes
			if ( !isNull( result ) ) {
				oModel = result;
			}
		}

		// log data
		if ( !isNull( variables.log ) && variables.log.canDebug() ) {
			variables.log.debug(
				"Instance object built: #arguments.mapping.getName()#:#arguments.mapping.getPath().toString()# by (#getName()#) injector"
			);
		}

		// announce afterInstanceInitialized
		variables.eventManager.announce(
			"afterInstanceInitialized",
			{
				mapping  : arguments.mapping,
				target   : oModel,
				injector : this
			}
		);

		return oModel;
	}

	/**
	 * Register a new requested mapping object instance thread safely and returns the mapping configured for this instance
	 *
	 * @name         The name of the mapping to register
	 * @instancePath The path of the mapping to register
	 **/
	function registerNewInstance( required name, required instancePath ){
		// Register new instance mapping
		lock
			name          ="Injector.#getInjectorID()#.RegisterNewInstance.#hash( arguments.instancePath )#"
			type          ="exclusive"
			timeout       ="20"
			throwontimeout="true" {
			if ( NOT variables.binder.mappingExists( arguments.name ) ) {
				// create a new mapping to be registered within the binder
				var mapping = new coldbox.system.ioc.config.Mapping( arguments.name )
					.setType( variables.binder.TYPES.CFC )
					.setPath( arguments.instancePath );
				// Now register it
				variables.binder.setMapping( arguments.name, mapping );
				// return it
				return mapping;
			}
		}

		return variables.binder.getMapping( arguments.name );
	}

	/**
	 * A direct way of registering custom DSL namespaces
	 *
	 * @namespace The namespace you would like to register
	 * @path      The instantiation path to the CFC that implements this scope, it must have an init() method and implement: coldbox.system.ioc.dsl.IDSLBuilder
	 */
	Injector function registerDSL( required namespace, required path ){
		variables.objectBuilder.registerDSL( argumentCollection = arguments );
		return this;
	}

	/**
	 * Checks if this injector can locate a model instance or not
	 *
	 * @name The object name or alias to search for if this container can locate it or has knowledge of it
	 */
	boolean function containsInstance( required name ){
		var cacheKey = lCase( arguments.name );
		var isFound  = false;

		// Have we asked to locate this instance before?
		if ( !isNull( variables.containsLookupMap.get( cacheKey ) ) ) {
			return true;
		}

		// check if we have a mapping first
		if ( variables.binder.mappingExists( arguments.name ) ) {
			isFound = true;
		}
		// check if we can locate it?
		else if ( locateInstance( arguments.name ).len() ) {
			isFound = true;
		}
		// Ask child hierarchy if set
		else if ( structCount( variables.childInjectors ) ) {
			isFound = variables.childInjectors
				.filter( function( childName, childInstance ){
					return arguments.childInstance.containsInstance( name );
				} )
				.count() > 0 ? true : false;
		} else {
			isFound = false;
		}

		// Cache if located
		if ( isFound ) {
			variables.containsLookupMap.put( cacheKey, true );
		}

		return isFound;
	}

	/**
	 * Tries to locate a specific instance by scanning all scan locations and returning the instantiation path. If model not found then the returned instantiation path will be empty
	 *
	 * @name The model instance name to locate
	 */
	function locateInstance( required name ){
		var scanLocations = variables.binder.getScanLocations();
		var CFCName       = replace( arguments.name, ".", "/", "all" );

		// If we find a :, then avoid doing lookups on the i/o system.
		if ( find( ":", CFCName ) ) {
			return "";
		}

		// Check Scan Locations In Order
		for ( var thisScanPath in scanLocations ) {
			// Check if located? If so, return instantiation path
			if (
				fileExists( scanLocations[ thisScanPath ] & CFCName & ".cfc" ) || fileExists(
					scanLocations[ thisScanPath ] & CFCName & ".bx"
				)
			) {
				return thisScanPath & "." & arguments.name;
			}
		}

		// Not found, so let's do full namespace location
		if ( fileExists( expandPath( "/" & CFCName & ".cfc" ) ) || fileExists( expandPath( "/" & CFCName & ".bx" ) ) ) {
			return arguments.name;
		}

		// debug info, NADA found!
		if ( !isNull( variables.log ) && variables.log.canDebug() ) {
			variables.log.debug( "Instance: #arguments.name# was not located anywhere by (#getName()#) injector" );
		}

		return "";
	}

	/**
	 * I wire up target objects with dependencies either by mappings or a-la-carte autowires
	 *
	 * @target              The target object to wire up
	 * @mapping             The object mapping with all the necessary wiring metadata. Usually passed by scopes and not a-la-carte autowires
	 * @mapping.doc_generic coldbox.system.ioc.config.Mapping
	 * @targetID            A unique identifier for this target to wire up. Usually a class path or file path should do. If none is passed we will get the id from the passed target via introspection but it will slow down the wiring
	 * @annotationCheck     This value determines if we check if the target contains an autowire annotation in the cfcomponent tag: autowire=true|false, it will only autowire if that metadata attribute is set to true. The default is false, which will autowire anything automatically.
	 */
	function autowire(
		required target,
		mapping,
		targetID                = "",
		boolean annotationCheck = false
	){
		var targetObject = arguments.target;
		var md           = "";

		// Do we have a mapping? Or is this a-la-carte wiring
		if ( isNull( arguments.mapping ) ) {
			// Ok, a-la-carte wiring, let's get our id first
			// Do we have an incoming target id?
			if ( NOT len( arguments.targetID ) ) {
				// need to get metadata to verify identity
				md                 = variables.utility.getInheritedMetaData( arguments.target, getBinder().getStopRecursions() );
				// We have identity now, use the full location path
				arguments.targetID = md.path;
			}

			// Now that we know we have an identity, let's verify if we have a mapping already
			if ( NOT variables.binder.mappingExists( arguments.targetID ) ) {
				// No mapping found, means we need to map this object for the first time.
				// Is md retrieved? If not, retrieve it as we need to register it for the first time.
				if ( isSimpleValue( md ) ) {
					md = variables.utility.getInheritedMetaData(
						arguments.target,
						getBinder().getStopRecursions()
					);
				}
				// register new mapping instance
				registerNewInstance( arguments.targetID, md.path );
				// get Mapping created
				arguments.mapping = variables.binder.getMapping( arguments.targetID );
				// process it with current metadata
				arguments.mapping.process(
					binder   = variables.binder,
					injector = this,
					metadata = md
				);
			} else {
				// get the mapping as it exists already
				arguments.mapping = variables.binder.getMapping( arguments.targetID );
			}
		}
		// end if mapping not found

		// Set local variable for easy reference use mapping to wire object up.
		if ( NOT len( arguments.targetID ) ) {
			arguments.targetID = arguments.mapping.getName();
		}

		// Only autowire if no annotation check or if there is one, make sure the mapping is set for autowire, and this is a CFC
		if (
			arguments.mapping.getType() eq this.TYPES.CFC
			AND
			(
				( arguments.annotationCheck eq false ) OR (
					arguments.annotationCheck AND arguments.mapping.isAutowire()
				)
			)
		) {
			// announce beforeInstanceAutowire
			var iData = {
				mapping  : arguments.mapping,
				target   : arguments.target,
				targetID : arguments.targetID,
				injector : this
			};
			variables.eventManager.announce( "beforeInstanceAutowire", iData );

			// prepare instance for wiring, done once for persisted objects and CFCs only
			variables.mixerUtil.start( arguments.target );

			// Bean Factory Awareness
			if ( structKeyExists( targetObject, "setBeanFactory" ) ) {
				targetObject.setBeanFactory( this );
			}
			if ( structKeyExists( targetObject, "setInjector" ) ) {
				targetObject.setInjector( this );
			}

			// ColdBox Context Awareness
			if ( structKeyExists( targetObject, "setColdBox" ) ) {
				targetObject.setColdBox( getColdBox() );
			}

			// DIProperty injection
			if ( arguments.mapping.getDIProperties().len() ) {
				processInjection(
					targetObject: targetObject,
					DIData      : arguments.mapping.getDIProperties(),
					targetId    : arguments.targetID,
					mapping     : arguments.mapping
				);
			}

			// DISetter injection
			if ( arguments.mapping.getDISetters().len() ) {
				processInjection(
					targetObject: targetObject,
					DIData      : arguments.mapping.getDISetters(),
					targetId    : arguments.targetID,
					mapping     : arguments.mapping
				);
			}

			// Process Provider Methods
			if ( arguments.mapping.getProviderMethods().len() ) {
				processProviderMethods( targetObject, arguments.mapping );
			}

			// Process Mixins
			if ( arguments.mapping.getMixins().len() ) {
				processMixins( targetObject, arguments.mapping );
			}

			// Process Lazy Properties
			if ( arguments.mapping.getLazyProperties().len() ) {
				processLazyProperties( targetObject, arguments.mapping );
			}

			// Process Observer Properties
			if ( arguments.mapping.getObservedProperties().len() ) {
				processObservedProperties( targetObject, arguments.mapping );
			}

			// Process After DI Complete
			processAfterCompleteDI( targetObject, arguments.mapping.getOnDIComplete() );

			// After Instance Autowire
			variables.eventManager.announce( "afterInstanceAutowire", iData );

			// Debug Data
			if ( !isNull( variables.log ) && variables.log.canDebug() ) {
				variables.log.debug(
					"Finalized Autowire for: #arguments.targetID#:#arguments.mapping.getName()#:#arguments.mapping.getPath().toString()#"
				);
			}
		}
	}

	/**
	 * Link a parent Injector with this injector
	 *
	 * @injector             A WireBox Injector to assign as a parent to this Injector
	 * @injector.doc_generic coldbox.system.ioc.Injector
	 *
	 * @return Injector
	 */
	function setParent( required injector ){
		variables.parent = arguments.injector;
		return this;
	}

	/**
	 * Has a parent injector
	 */
	boolean function hasParent(){
		return isObject( variables.parent );
	}

	/**
	 * Has a root injector
	 */
	boolean function hasRoot(){
		return isObject( variables.root );
	}

	/**
	 * Get a reference to the parent injector instance, else an empty simple string meaning nothing is set
	 *
	 * @doc_generic coldbox.system.ioc.Injector
	 */
	function getParent(){
		return variables.parent;
	}

	/**
	 * Get an object populator useful for populating objects from JSON,XML, etc.
	 *
	 * @return coldbox.system.core.dynamic.ObjectPopulator
	 */
	function getObjectPopulator(){
		return getInstance( "coldbox.system.core.dynamic.ObjectPopulator" );
	}

	/**
	 * Checks if Coldbox application context is linked
	 *
	 * @doc_generic boolean
	 */
	boolean function isColdBoxLinked(){
		return !isNull( variables.coldbox ) && isObject( variables.coldbox );
	}

	/**
	 * Checks if CacheBox is linked
	 *
	 * @doc_generic boolean
	 */
	boolean function isCacheBoxLinked(){
		return !isNull( variables.cacheBox ) && isObject( variables.cacheBox );
	}

	/**
	 * Remove the Injector from scope registration if enabled, else does nothing
	 */
	Injector function removeFromScope(){
		var scopeInfo = variables.binder.getScopeRegistration();
		// if enabled remove.
		if ( scopeInfo.enabled ) {
			variables.scopeStorage.delete( scopeInfo.key, scopeInfo.scope );

			// Log info
			if ( !isNull( variables.log ) && variables.log.canDebug() ) {
				variables.log.debug( "Injector (#getName()#) removed from scope: #scopeInfo.toString()#" );
			}
		}
		return this;
	}

	/**
	 * Get a registered scope in this injector by name
	 *
	 * @scope The scope name
	 *
	 * @throws InvalidScopeException - When the scope requested has not been registered in this Injector
	 */
	function getScope( required any scope ){
		if ( !variables.scopes.keyExists( arguments.scope ) ) {
			throw(
				message     : "The scope requested (#arguments.scope#) has not been registered in WireBox",
				detail      : "The valid registered scopes are: #variables.scopes.keyList()#",
				type        : "InvalidScopeException",
				extendedInfo: "Current Injector -> #getName()#"
			);
		}
		return variables.scopes[ arguments.scope ];
	}

	/**
	 * Clear the singleton cache
	 */
	Injector function clearSingletons(){
		getScope( "SINGLETON" ).clear();
		return this;
	}

	/**
	 * Clear the app singleton cache
	 */
	Injector function clearAppSingletons(){
		getScope( "SINGLETON" ).clearAppOnly();
		return this;
	}

	/**
	 * Return a self reference using the scoped registration, mostly used by providers or scope widening objects
	 *
	 * @doc_generic coldbox.system.ioc.Injector
	 */
	function locateScopedSelf(){
		var scopeInfo = variables.binder.getScopeRegistration();

		// Return if it exists, else throw exception
		if ( scopeInfo.enabled && variables.scopeStorage.exists( scopeInfo.key, scopeInfo.scope ) ) {
			return variables.scopeStorage.get( scopeInfo.key, scopeInfo.scope );
		}

		throw(
			message     : "The injector has not be registered in any scope",
			detail      : "The scope info is: #scopeInfo.toString()#",
			type        : "Injector.InvalidScopeRegistration",
			extendedInfo: "Current Injector -> #getName()#"
		);
	}

	/**
	 * Get the structure of scope registration information
	 */
	struct function getScopeRegistration(){
		var info = variables.binder.getScopeRegistration();

		if ( info.enabled ) {
			return info;
		}

		return hasParent() ? getParent().getScopeRegistration() : info;
	}

	/****************************************** PRIVATE ************************************************/

	/**
	 * Process lazy properties on the target object
	 *
	 * @targetObject The target object to do some goodness on
	 * @mapping      The target mapping
	 */
	private Injector function processLazyProperties( required targetObject, required mapping ){
		// Store lookup map on the target
		arguments.targetObject.$wbLazyProperties = arguments.mapping
			.getLazyProperties()
			.reduce( function( result, item ){
				arguments.result[ arguments.item.name ] = arguments.item;
				return arguments.result;
			}, {} );
		// Create the getter/builder methods
		arguments.mapping
			.getLazyProperties()
			.each( function( thisProperty ){
				targetObject.injectMixin( "get#thisProperty.name#", variables.objectBuilder.lazyPropertyGetter );
			} );

		return this;
	}

	/**
	 * Process observed properties on the target object
	 *
	 * @targetObject The target object to do some goodness on
	 * @mapping      The target mapping
	 */
	private Injector function processObservedProperties( required targetObject, required mapping ){
		// Store lookup map on the target
		arguments.targetObject.$wbObservedProperties = arguments.mapping
			.getObservedProperties()
			.reduce( function( result, item ){
				arguments.result[ arguments.item.name ] = arguments.item;
				return arguments.result;
			}, {} );
		// Create the getter/builder methods
		arguments.mapping
			.getObservedProperties()
			.each( function( thisProperty ){
				targetObject.injectMixin(
					"set#thisProperty.name#",
					variables.objectBuilder.observedPropertySetter
				);
			} );

		return this;
	}

	/**
	 * Process mixins on the selected target
	 *
	 * @targetObject The target object to do some goodness on
	 * @mapping      The target mapping
	 */
	private Injector function processMixins( required targetObject, required mapping ){
		// Process
		var mixin = new coldbox.system.ioc.config.Mixin().$init( arguments.mapping.getMixins() );

		// iterate and mixin baby!
		for ( var key in mixin ) {
			if ( key NEQ "$init" ) {
				arguments.targetObject.injectMixin( name = key, UDF = mixin[ key ] );
			}
		}

		return this;
	}

	/**
	 * Process provider methods on the selected target
	 *
	 * @targetObject The target object to do some goodness on
	 * @mapping      The target mapping
	 */
	private Injector function processProviderMethods( required targetObject, required mapping ){
		var providerMethods = arguments.mapping.getProviderMethods();

		// Decorate the target if provider methods found, in preparation for replacements
		arguments.targetObject.$wbProviders = {};
		arguments.targetObject.$wbInjector  = this;

		// iterate and provide baby!
		for ( var thisProvider in providerMethods ) {
			// add the provided method to the providers structure.
			arguments.targetObject.$wbProviders[ thisProvider.method ] = thisProvider.mapping;
			// Override the function by injecting it, this does private/public functions
			arguments.targetObject.injectMixin( thisProvider.method, variables.objectBuilder.buildProviderMixer );
		}

		return this;
	}

	/**
	 * Process after DI completion routines
	 *
	 * @targetObject      The target object to do some goodness on
	 * @DICompleteMethods The array of DI completion methods to call
	 */
	private Injector function processAfterCompleteDI( required targetObject, required DICompleteMethods ){
		//  Check for convention first
		if ( structKeyExists( arguments.targetObject, "onDIComplete" ) ) {
			arguments.targetObject.onDIComplete();
		}

		//  Iterate on DICompleteMethods
		for ( var thisMethod in arguments.DICompleteMethods ) {
			if ( structKeyExists( arguments.targetObject, thisMethod ) ) {
				//  Call our mixin invoker
				arguments.targetObject.invokerMixin( method = thisMethod );
			}
		}

		return this;
	}

	/**
	 * Process property and setter injections
	 *
	 * @targetObject The target object to do some goodness on, usually a CFC
	 * @DIData       The DI data array to use for injection
	 * @targetID     The target Identifier of the target object
	 * @mapping      The mapping of the target object
	 */
	private Injector function processInjection(
		required targetObject,
		required array DIData,
		required string targetID,
		required mapping
	){
		// Transient Cache Enabled Checks
		// - Global Flag
		// - Mapping has to be a transient
		// - Mapping has to be a non-virtual inheritance
		// - Mapping doesn't have a transientCache annotation
		// cfformat-ignore-start
		var transientCacheEnabled        = getBinder().getTransientInjectionCache() &&
			arguments.mapping.isTransient() &&
			!arguments.mapping.isVirtualInheritance() &&
			arguments.mapping.getComponentAnnotation( "transientCache", true )
		;
		var transientCache = getTransientCache();
		// cfformat-ignore-end

		// Verify if we have seen this transient in this request
		if ( transientCacheEnabled && transientCache.containsKey( arguments.targetID.lcase() ) ) {
			var targetTransientCache = getTransientCache( arguments.targetID.lcase() );
			// Injections Injection :)
			structAppend( arguments.targetObject.getVariablesMixin(), targetTransientCache.injections );
			// Delegations Injection
			arguments.targetObject.$wbDelegateMap = targetTransientCache.delegations;
			// inject delegation into the target
			for ( var delegationMethod in structKeyArray( arguments.targetObject.$wbDelegateMap ) ) {
				arguments.targetObject.injectMixin( delegationMethod, variables.mixerUtil.getByDelegate );
			}
			return this;
		}

		for ( var thisDIData in arguments.DIData ) {
			// Init the lookup structure
			var refLocal = {};

			// Check if direct value has been placed.
			if ( !isNull( local.thisDIData.value ) ) {
				refLocal.dependency = local.thisDIData.value;
			}
			// else check if dsl is used?
			else if ( !isNull( local.thisDIData.dsl ) ) {
				// Get DSL dependency by sending entire DI structure to retrieve
				refLocal.dependency = variables.objectBuilder.buildDSLDependency(
					definition   = local.thisDIData,
					targetID     = arguments.targetID,
					targetObject = arguments.targetObject
				);
			}
			// else we have to have a reference ID
			else {
				refLocal.dependency = getInstance( thisDIData.ref );
			}

			// Do we have a dependency to inject?
			if ( structKeyExists( refLocal, "dependency" ) ) {
				// Inject dependency
				injectTarget(
					target         = arguments.targetObject,
					propertyName   = thisDIData.name,
					propertyObject = refLocal.dependency,
					scope          = thisDIData.scope,
					argName        = thisDIData.argName
				);

				// Is this injection a delegation also?
				if ( thisDIData.delegate ) {
					processDelegation(
						target  : arguments.targetObject,
						targetId: arguments.targetID,
						delegate: refLocal.dependency,
						DIData  : thisDIData
					);
				}

				// Store in transient cache
				if ( transientCacheEnabled ) {
					var targetTransientCache                           = getTransientCache( arguments.targetID.lcase() );
					targetTransientCache.injections[ thisDIData.name ] = refLocal.dependency;
					if ( structKeyExists( arguments.targetObject, "$wbDelegateMap" ) ) {
						targetTransientCache.delegations = arguments.targetObject.$wbDelegateMap;
					}
				}

				// some debugging goodness
				if ( !isNull( variables.log ) && variables.log.canDebug() ) {
					variables.log.debug(
						"Dependency: #thisDIData.toString()# --> injected into #arguments.targetID# by (#getName()#) injector"
					);
				}
			} else if ( !isNull( variables.log ) && variables.log.canDebug() ) {
				variables.log.debug(
					"Dependency: #thisDIData.toString()# Not Found when wiring #arguments.targetID#. Registered mappings are: #structKeyList( variables.binder.getMappings() )# by (#getName()#) injector"
				);
			}
		}
		// end iteration

		return this;
	}

	/**
	 * Get a reference to the transient cache, if none exists, it will be created for the request.
	 *
	 * @targetID If passed, get the transient cache for the targetID, otherwise, get the global transient cache
	 */
	struct function getTransientCache( targetId ){
		if ( !request.keyExists( "cbTransientDICache" ) ) {
			lock name="wirebox:transientcache" type="exclusive" throwontimeout="true" timeout="15" {
				if ( !request.keyExists( "cbTransientDICache" ) ) {
					request.cbTransientDICache = createObject( "java", "java.util.concurrent.ConcurrentHashMap" ).init();
					if ( !isNull( variables.log ) ) {
						variables.log.debug( () => "WireBox Transient Cache Created" );
					}
				}
			}
		}

		// Global or targeted transient cache?
		if ( isNull( arguments.targetId ) ) {
			return request.cbTransientDICache;
		}

		// Init targetID storage if not found
		if ( !request.cbTransientDICache.containsKey( arguments.targetID.lcase() ) ) {
			lock
				name          ="wirebox:transientcache:#arguments.targetId#"
				type          ="exclusive"
				throwontimeout="true"
				timeout       ="15" {
				if ( !request.cbTransientDICache.containsKey( arguments.targetID.lcase() ) ) {
					request.cbTransientDICache.put(
						arguments.targetID.lcase(),
						{ "injections" : {}, "delegations" : {} }
					);
					if ( !isNull( variables.log ) ) {
						variables.log.debug( () => "WireBox Transient Cache Storage for #targetId# Created" );
					}
				}
			}
		}
		return request.cbTransientDICache.get( arguments.targetId.lcase() );
	}

	/**
	 * Process a target object dependency delegation
	 *
	 * @target   The target object being injected with dependencies/delegations
	 * @targetID The target ID to process injections
	 * @delegate The delegation object that was injected
	 * @DIData   The DI information about the delegation/injection
	 */
	private function processDelegation(
		required target,
		required string targetID,
		required delegate,
		required DIData
	){
		// systemOutput( "Processing Delegation for #getMetadata( target ).name#", true );
		// Init lookup maps and injection mixins
		param arguments.target.$wbDelegateMap        = {};
		param arguments.DIData.delegateExcludes      = [];
		param arguments.DIData.delegateIncludes      = [];
		param arguments.delegate.injectPropertyMixin = variables.mixerUtil.injectPropertyMixin;

		// Inject target into the delegate as $parent
		arguments.delegate.injectPropertyMixin( "$parent", arguments.target );

		// Defaults
		var delegateIncludes = arguments.DIData.delegateIncludes;
		var delegateExcludes = arguments.DIData.delegateExcludes;
		var delegateSuffix   = arguments.DIData.delegateSuffix;
		var delegatePrefix   = arguments.DIData.delegatePrefix;

		// Delegation Process
		var processDelegateInjection = function( thisMethod ){
			var delegationMethod = "#delegatePrefix##arguments.thisMethod##delegateSuffix#";
			// Check if this method has been override by the user first
			if ( !structKeyExists( target, delegationMethod ) ) {
				// Lookup targets
				target.$wbDelegateMap[ delegationMethod ] = { delegate : delegate, method : arguments.thisMethod };
				// inject delegation into the target
				target.injectMixin( delegationMethod, variables.mixerUtil.getByDelegate );
			}
			// Has it been injected by another delegate?
			else if ( structKeyExists( target.$wbDelegateMap, delegationMethod ) ) {
				throw(
					type        : "DuplicateDelegateException",
					message     : "The method: (#delegationMethod#) from the (#getMetadata( delegate ).name#) delegate has already been injected by (#getMetadata( target.$wbDelegateMap[ delegationMethod ].delegate ).name#)",
					detail      : "The target object is (#getMetadata( target ).name#).",
					extendedInfo: "Current Injector -> #getName()#"
				);
			}
		};

		// Process includes Only
		if ( delegateIncludes.len() ) {
			for ( var thisInclude in delegateIncludes ) {
				processDelegateInjection( thisInclude );
			}
			return;
		}
		// Process with exclusions now
		for ( var thisMethod in structKeyArray( arguments.delegate ) ) {
			if ( !arrayContainsNoCase( delegateExcludes, thisMethod ) ) {
				processDelegateInjection( thisMethod );
			}
		}
	}

	/**
	 * Inject a model object with dependencies via setters or property injections
	 *
	 * @target         The target that will be injected with dependencies
	 * @propertyName   The name of the property to inject
	 * @propertyObject The object to inject
	 * @scope          The scope to inject a property into, if any else empty means it is a setter call
	 * @argName        The name of the argument to send if setter injection
	 */
	private Injector function injectTarget(
		required target,
		required propertyName,
		required propertyObject,
		required scope,
		required argName
	){
		//  Property or Setter
		if ( len( arguments.scope ) == 0 ) {
			//  Call our mixin invoker: setterMethod
			arguments.target.invokerMixin(
				method        = "set#arguments.propertyName#",
				argCollection = { "#arguments.argname#" : arguments.propertyObject }
			);
		} else {
			//  Call our property injector mixin
			arguments.target.injectPropertyMixin(
				propertyName  = arguments.propertyName,
				propertyValue = arguments.propertyObject,
				scope         = arguments.scope
			);
		}

		return this;
	}

	/**
	 * Register all internal and configured WireBox Scopes
	 */
	private Injector function registerScopes(){
		// Core Scopes
		variables.scopes[ "NOSCOPE" ]     = new coldbox.system.ioc.scopes.NoScope( this );
		variables.scopes[ "SINGLETON" ]   = new coldbox.system.ioc.scopes.Singleton( this );
		variables.scopes[ "REQUEST" ]     = new coldbox.system.ioc.scopes.RequestScope( this );
		variables.scopes[ "SESSION" ]     = new coldbox.system.ioc.scopes.CFScopes( this );
		variables.scopes[ "SERVER" ]      = variables.scopes[ "SESSION" ];
		variables.scopes[ "APPLICATION" ] = variables.scopes[ "SESSION" ];

		// CacheBox if linked
		if ( isCacheBoxLinked() ) {
			variables.scopes[ "CACHEBOX" ] = new coldbox.system.ioc.scopes.CacheBox( this );
		}

		// Custom Scopes
		var customScopes = variables.binder.getCustomScopes();
		for ( var key in customScopes ) {
			variables.scopes[ key ] = createObject( "component", customScopes[ key ] ).init( this );
			// Debugging
			if ( !isNull( variables.log ) && variables.log.canDebug() ) {
				variables.log.debug( "Registered custom scope: #key# (#customScopes[ key ]#)" );
			}
		}
		return this;
	}

	/**
	 * Register all the configured listeners in the configuration file
	 */
	private Injector function registerListeners(){
		var aopMixerAdded = false;
		for ( var thisListener in variables.binder.getListeners() ) {
			if ( thisListener.class == "coldbox.system.aop.Mixer" ) {
				aopMixerAdded = true;
			}
			registerListener( thisListener );
		}
		// If we have any aspects defined but no mixer, auto-add it
		if ( !aopMixerAdded && variables.binder.hasAspects() ) {
			if ( !isNull( variables.log ) && variables.log.canInfo() ) {
				variables.log.info(
					"AOP aspects detected but no Mixer listener found, auto-adding it with defaults..."
				);
			}
			registerListener( { class : "coldbox.system.aop.Mixer", name : "aopMixer" } );
		}
		return this;
	}

	/**
	 * Register all the configured listeners in the configuration file
	 *
	 * @listener The listener struct to register: { class, name, properties }
	 */
	public Injector function registerListener( required struct listener ){
		param arguments.listener.properties = {};
		try {
			// create it
			var thisListener = createObject( "component", listener.class );
			// configure it
			thisListener.configure( this, listener.properties );
		} catch ( Any e ) {
			if ( !isNull( variables.log ) && variables.log.canError() ) {
				variables.log.error( "Error creating listener: #listener.toString()#", e );
			}
			throw(
				message     : "Error creating listener: #listener.toString()#",
				detail      : "#e.message# #e.detail# #e.stackTrace#",
				type        : "Injector.ListenerCreationException",
				extendedInfo: "Current Injector -> #getName()#"
			);
		}

		// Now register listener
		if ( NOT isColdBoxLinked() ) {
			variables.eventManager.register( thisListener, listener.name );
		} else {
			variables.eventManager.registerInterceptor(
				interceptorObject = thisListener,
				interceptorName   = listener.name
			);
		}

		// debugging
		if ( !isNull( variables.log ) && variables.log.canDebug() ) {
			variables.log.debug(
				"Injector (#getName()#) has just registered a new listener: #listener.toString()#"
			);
		}

		return this;
	}

	/**
	 * Register this injector on a user specified scope
	 *
	 * @scopeInfo The scope info struct: key, scope
	 */
	private Injector function doScopeRegistration( scopeInfo = variables.binder.getScopeRegistration() ){
		// register injector with scope
		variables.scopeStorage.put(
			arguments.scopeInfo.key,
			this,
			arguments.scopeInfo.scope
		);

		// Log info
		if ( !isNull( variables.log ) && variables.log.canDebug() ) {
			variables.log.debug(
				"Scope Registration enabled and Injector (#getName()#) scoped to: #arguments.scopeInfo.toString()#"
			);
		}

		return this;
	}

	/**
	 * Configure a standalone version of cacheBox for persistence
	 *
	 * @config The cacheBox configuration data structure
	 */
	private Injector function configureCacheBox( required struct config ){
		// is cachebox enabled?
		if ( NOT arguments.config.enabled ) {
			return this;
		}

		// Do we have a cacheBox reference?
		if ( isObject( arguments.config.cacheFactory ) ) {
			variables.cacheBox = arguments.config.cacheFactory;
			// debugging
			if ( !isNull( variables.log ) && variables.log.canDebug() ) {
				variables.log.debug(
					"Configured Injector #getName()# with direct CacheBox instance: #variables.cacheBox.getFactoryID()#"
				);
			}
			return this;
		}

		// Do we have a configuration file?
		if ( len( arguments.config.configFile ) ) {
			// Create CacheBox
			var oConfig = createObject( "component", "#arguments.config.classNamespace#.config.CacheBoxConfig" ).init(
				CFCConfigPath: arguments.config.configFile
			);
			variables.cacheBox = createObject( "component", "#arguments.config.classNamespace#.CacheFactory" ).init(
				config  = oConfig,
				wirebox = this
			);

			// debugging
			if ( !isNull( variables.log ) && variables.log.canDebug() ) {
				variables.log.debug(
					"Configured Injector #getName()# with CacheBox instance: #variables.cacheBox.getFactoryID()# and configuration file: #arguments.config.configFile#"
				);
			}
			return this;
		}

		// No config file, plain vanilla cachebox
		variables.cacheBox = createObject( "component", "#arguments.config.classNamespace#.CacheFactory" ).init();
		// debugging
		if ( !isNull( variables.log ) && variables.log.canDebug() ) {
			variables.log.debug(
				"Configured Injector #getName()# with vanilla CacheBox instance: #variables.cacheBox.getFactoryID()#"
			);
		}

		return this;
	}

	/**
	 * Configure a standalone version of logBox for logging
	 */
	private Injector function configureLogBox( required configPath ){
		var config = new coldbox.system.logging.config.LogBoxConfig( CFCConfigPath: arguments.configPath );

		// Create LogBox
		variables.logBox = new coldbox.system.logging.LogBox( config = config, wirebox = this );
		// Configure Logging for this injector
		variables.log    = variables.logBox.getLogger( this );

		return this;
	}

	/**
	 * Configure a standalone version of a WireBox Event Manager
	 */
	private Injector function configureEventManager(){
		// Use or create event manager
		if ( isColdBoxLinked() && isObject( variables.eventManager ) ) {
			// Link Interception States
			variables.eventManager.appendInterceptionPoints( variables.eventStates );
			return this;
		}

		// create event manager
		variables.eventManager = new coldbox.system.core.events.EventPoolManager( variables.eventStates );

		return this;
	}

	/**
	 * Load a configuration binder object according to passed in type
	 *
	 * @binder     The data CFC configuration instance, instantiation path or programmatic binder object to configure this injector with
	 * @properties A map of binding properties to passthrough to the Configuration CFC
	 */
	private any function buildBinder( required binder, required properties ){
		// Check if just a plain CFC path and build it
		if ( isSimpleValue( arguments.binder ) ) {
			arguments.binder = createObject( "component", arguments.binder );
		}

		// Inject Environment Support if it's an object
		if ( isObject( arguments.binder ) ) {
			var envUtil = new coldbox.system.core.delegates.Env();
			variables.mixerUtil
				.start( arguments.binder )
				.injectPropertyMixin( propertyName: "env", propertyValue: envUtil )
				.injectMixin( "getSystemSetting", envUtil.getSystemSetting )
				.injectMixin( "getSystemProperty", envUtil.getSystemProperty )
				.injectMixin( "getJavaSystem", envUtil.getJavaSystem )
				.injectMixin( "getEnv", envUtil.getEnv );
		}

		// Check if data CFC or binder family
		if ( !structKeyExists( arguments.binder, "$wbBinder" ) ) {
			// simple data cfc, create native binder and decorate data CFC
			var nativeBinder = new coldbox.system.ioc.config.Binder(
				injector   = this,
				config     = arguments.binder,
				properties = arguments.properties
			);
		} else {
			// else init the binder and configure it
			var nativeBinder = arguments.binder.init( injector = this, properties = arguments.properties );
			// Configure it
			nativeBinder.configure();
			// Load it
			nativeBinder.loadDataDSL();
		}

		return nativeBinder;
	}

}
