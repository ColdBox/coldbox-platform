/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * The WireBox injector is the pivotal class in WireBox that performs dependency injection.  
 * It can be used standalone or it can be used in conjunction of a ColdBox application context.  
 * It can also be configured with a mapping configuration file called a binder, that can provide object/mappings and configuration data.
 * 
 * A WireBox Injector: Builds the graphs of objects that make up your application.
 * 
 *   Easy Startup:
 *	injector = new coldbox.system.ioc.Injector();
 *
 *	Binder Startup
 *	injector = new coldbox.system.ioc.Injector(new MyBinder());
 *
 *	Binder Path Startup
 *	injector = new coldbox.system.ioc.Injector("config.MyBinder");
 **/
component output="false" serializable="false" accessors="true" implements="coldbox.system.ioc.IInjector" {

	/**
	 * Java Systemng
	 */
	property name="javaSystem";

	/**
	 * Utility class
	 */
	property name="utility";

	/**
	 * Scope Storages
	 */
	property name="scopeStorage";

	/**
	 * VersionString
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
	property name="eventStates";

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
	 * LifeCycle Scopes
	 */
	property name="scopes";

	/**
	 * Constructor. If called without a configuration binder, then WireBox will instantiate the default configuration binder found in: coldbox.system.ioc.config.DefaultBinder
	 *
	 * @binder The WireBox binder or data CFC instance or instantiation path to configure this injector with
	 * @properties A structure of binding properties to passthrough to the Binder Configuration CFC
	 * @properties.doc_generic struct
	 * @coldbox A coldbox application context that this instance of WireBox can be linked to, if not using it, we just ignore it.
	 * @coldbox.doc_generic coldbox.system.web.Controller
	 **/
	public Injector function init(binder="coldbox.system.ioc.config.DefaultBinder", struct properties=structNew(), coldbox="") {
		// Setup Available public scopes
		this.SCOPES = createObject("component","coldbox.system.ioc.Scopes");
		// Setup Available public types
		this.TYPES = createObject("component","coldbox.system.ioc.Types");

		// Do we have a binder?
		if( isSimpleValue( arguments.binder ) AND NOT len( trim( arguments.binder ) ) ){ 
			arguments.binder = "coldbox.system.ioc.config.DefaultBinder"; 
		}

		variables.javaSystem = createObject('java','java.lang.System');
		variables.utility  = createObject("component","coldbox.system.core.util.Util");
		variables.version  = "5.0.0-rc.1-snapshot";
		variables.binder = "";
		variables.coldbox  = "";
		variables.logBox = "";
		variables.cacheBox = "";
		variables.eventManager = "";
		variables.eventStates = [
			"afterInjectorConfiguration", 	// X once injector is created and configured
			"beforeInstanceCreation", 		// X Before an injector creates or is requested an instance of an object, the mapping is passed.
			"afterInstanceInitialized",		// X once the constructor is called and before DI is performed
			"afterInstanceCreation", 		// X once an object is created, initialized and done with DI
			"beforeInstanceInspection",		// X before an object is inspected for injection metadata
			"afterInstanceInspection",		// X after an object has been inspected and metadata is ready to be saved
			"beforeInjectorShutdown",		// X right before the shutdown procedures start
			"afterInjectorShutdown",		// X right after the injector is shutdown
			"beforeInstanceAutowire",		// X right before an instance is autowired
			"afterInstanceAutowire"			// X right after an instance is autowired
		];
		variables.log = "";
		variables.parent = "";
		variables.scopes = {};
		variables.scopeStorage = createObject("component","coldbox.system.core.collections.ScopeStorage").init();

		// Prepare instance ID
		variables.injectorID = variables.javaSystem.identityHashCode(this);
		// Prepare Lock Info
		variables.lockName = "WireBox.Injector.#variables.injectorID#";
		// Link ColdBox Context if passed
		variables.coldbox = arguments.coldbox;

		// Configure the injector for operation
		configure( arguments.binder, arguments.properties);

		return this;
	}

	/**
	 * Configure this injector for operation, called by the init(). You can also re-configure this injector programmatically, but it is not recommended.
	 *
	 * @binder The configuration binder object or path to configure this Injector instance with
	 * @binder.doc_generic coldbox.system.ioc.config.Binder
	 * @properties A structure of binding properties to passthrough to the Configuration CFC
	 * @properties.doc_generic struct
	 **/
	public void function configure(required binder, required struct properties) {
		var key 			= "";
		var iData			= {};
		var withColdbox 	= isColdBoxLinked();

		//Lock For Configuration
		lock name=variables.lockName type="exclusive" timeout="30" throwontimeout="true" {
			if( withColdBox ){
				// link LogBox
				variables.logBox  = variables.coldbox.getLogBox();
				// Configure Logging for this injector
				variables.log = variables.logBox.getLogger( this );
				// Link CacheBox
				variables.cacheBox = variables.coldbox.getCacheBox();
				// Link Event Manager
				variables.eventManager = variables.coldbox.getInterceptorService();
			}

			// Store binder object built accordingly to our binder building procedures
			variables.binder = buildBinder( arguments.binder, arguments.properties );

			// Create local cache, logging and event management if not coldbox context linked.
			if( NOT withColdbox ){
				// Running standalone, so create our own logging first
				configureLogBox( variables.binder.getLogBoxConfig() );
				// Create local CacheBox reference
				configureCacheBox( variables.binder.getCacheBoxConfig() );
			}
			// Create and Configure Event Manager
			configureEventManager();

			// Register All Custom Listeners
			registerListeners();

			// Create our object builder
			variables.builder = createObject("component","coldbox.system.ioc.Builder").init( this );
			// Register Custom DSL Builders
			variables.builder.registerCustomBuilders();

			// Register Life Cycle Scopes
			registerScopes();

			// Parent Injector declared
			if( isObject(variables.binder.getParentInjector()) ){
				setParent( variables.binder.getParentInjector() );
			}

			// Scope registration if enabled?
			if( variables.binder.getScopeRegistration().enabled ){
				doScopeRegistration();
			}

			// process mappings for metadata and initialization.
			variables.binder.processMappings();

			// Announce To Listeners we are online
			iData.injector = this;
			variables.eventManager.processState("afterInjectorConfiguration",iData);
		}
	}

	/**
	 * Shutdown the injector gracefully by calling the shutdown events internally.
	 **/
	public void function shutdown() {
		var iData = {
			injector = this
		};

		// Log
		if( variables.log.canInfo() ){
			variables.log.info("Shutdown of Injector: #getInjectorID()# requested and started.");
		}

		// Notify Listeners
		variables.eventManager.processState("beforeInjectorShutdown",iData);

		// Is parent linked
		if( isObject( variables.parent ) ){
			variables.parent.shutdown();
		}

		// standalone cachebox? Yes, then shut it down baby!
		if( isCacheBoxLinked() ){
			variables.cacheBox.shutdown();
		}

		// Remove from scope
		removeFromScope();

		// Notify Listeners
		variables.eventManager.processState("afterInjectorShutdown",iData);

		// Log shutdown complete
		if( variables.log.canInfo() ){
			variables.log.info("Shutdown of injector: #getInjectorID()# completed.");
		}
	}

	/**
	 * Locates, Creates, Injects and Configures an object model instance
	 *
	 * @name The mapping name or CFC instance path to try to build up
	 * @dsl The dsl string to use to retrieve the instance model object, mutually exclusive with 'name
	 * @initArguments The constructor structure of arguments to passthrough when initializing the instance
	 * @initArguments.doc_generic struct
	 * @targetObject The object requesting the dependency, usually only used by DSL lookups
	 **/
	function getInstance(name, dsl, initArguments = structNew(), targetObject="") {
		var instancePath 	= "";
		var mapping 		= "";
		var target			= "";
		var iData			= {};

		// Get by DSL?
		if( structKeyExists( arguments,"dsl" ) ){
			return variables.builder.buildSimpleDSL( dsl=arguments.dsl, targetID="ExplicitCall", targetObject=arguments.targetObject );
		}

		// Check if Mapping Exists?
		if( NOT variables.binder.mappingExists(arguments.name) ){
			// No Mapping exists, let's try to locate it first. We are now dealing with request by conventions
			instancePath = locateInstance(arguments.name);

			// check if not found and if we have a parent factory
			if( NOT len(instancePath) AND isObject(variables.parent) ){
				// we do have a parent factory so just request it from there, let the hierarchy deal with it
				return variables.parent.getInstance(argumentCollection=arguments);
			}

			// If Empty Throw Exception
			if( NOT len(instancePath) ){
				variables.log.error("Requested instance:#arguments.name# was not located in any declared scan location(s): #structKeyList(variables.binder.getScanLocations())# or full CFC path");
				throw(message="Requested instance not found: '#arguments.name#'",
								  detail="The instance could not be located in any declared scan location(s) (#structKeyList(variables.binder.getScanLocations())#) or full path location",
								  type="Injector.InstanceNotFoundException");
			}
			// Let's create a mapping for this requested convention name+path as it is the first time we see it
			registerNewInstance(arguments.name, instancePath);
		}

		// Get Requested Mapping (Guaranteed to exist now)
		mapping = variables.binder.getMapping( arguments.name );

		// Check if the mapping has been discovered yet, and if it hasn't it must be autowired enabled in order to process.
		if( NOT mapping.isDiscovered() ){
			// process inspection of instance
			mapping.process(binder=variables.binder,injector=this);
		}

		// scope persistence check
		if( NOT structKeyExists(variables.scopes, mapping.getScope()) ){
			variables.log.error("The mapping scope: #mapping.getScope()# is invalid and not registered in the valid scopes: #structKeyList(variables.scopes)#");
			throw(message="Requested mapping scope: #mapping.getScope()# is invalid for #mapping.getName()#",
							  detail="The registered valid object scopes are #structKeyList(variables.scopes)#",
							  type="Injector.InvalidScopeException");
		}

		// Request object from scope now, we now have it from the scope created, initialized and wired
		target = variables.scopes[ mapping.getScope() ].getFromScope( mapping, arguments.initArguments );

		// Announce creation, initialization and DI magicfinicitation!
		iData = {mapping=mapping,target=target,injector=this};
		variables.eventManager.processState("afterInstanceCreation",iData);

		return target;
	}

	/**
	 * Build an instance, this is called from registered scopes only as they provide locking and transactions
	 *
	 * @mapping The mapping to construct
	 * @mapping.doc_generic coldbox.system.ioc.config.Mapping
	 * @initArguments The constructor structure of arguments to passthrough when initializing the instance
	 * @initArguments.doc_generic struct
	 **/
	function buildInstance(required mapping, struct initArguments = StructNew()) {
		var thisMap = arguments.mapping;
		var oModel	= "";
		var iData	= "";
		var closure = "";

		// before construction event
		iData = {mapping=arguments.mapping,injector=this};
		variables.eventManager.processState("beforeInstanceCreation",iData);

		// determine construction type
		switch( thisMap.getType() ){
			case "cfc" : {
				oModel = variables.builder.buildCFC( thisMap, arguments.initArguments ); break;
			}
			case "java" : {
				oModel = variables.builder.buildJavaClass( thisMap ); break;
			}
			case "webservice" : {
				oModel = variables.builder.buildWebservice( thisMap, arguments.initArguments ); break;
			}
			case "constant" : {
				oModel = thisMap.getValue(); break;
			}
			case "rss" : {
				oModel = variables.builder.buildFeed( thisMap ); break;
			}
			case "dsl" : {
				oModel = variables.builder.buildSimpleDSL( dsl=thisMap.getDSL(), targetID=thisMap.getName() ); break;
			}
			case "factory" : {
				oModel = variables.builder.buildFactoryMethod( thisMap, arguments.initArguments ); break;
			}
			case "provider" : {
				// verify if it is a simple value or closure/UDF
				if( isSimpleValue( thisMap.getPath() ) ){
					oModel = getInstance( thisMap.getPath() ).get();
				}
				else{
					closure = thisMap.getPath();
					oModel = closure( injector = this );
				}
				break;
			}
			default: { throw(message="Invalid Construction Type: #thisMap.getType()#",type="Injector.InvalidConstructionType"); }
		}
		
		// Check and see if this mapping as an influence closure
		var influenceClosure = thisMap.getInfluenceClosure();
		if( !isSimpleValue( influenceClosure ) ) {
			// Influence the creation of the instance
			local.result = influenceClosure( instance=oModel, injector=this );
			// Allow the closure to override the entire instance if it wishes
			if( structKeyExists( local, 'result' ) ) {
				oModel = local.result;
			}	
		}
		
		// log data
		if( variables.log.canDebug() ){
			variables.log.debug("Instance object built: #arguments.mapping.getName()#:#arguments.mapping.getPath().toString()#");
		}

		// announce afterInstanceInitialized
		iData = {mapping=arguments.mapping,target=oModel,injector=this};
		variables.eventManager.processState("afterInstanceInitialized",iData);

		return oModel;
	}

	/**
	 * Register a new requested mapping object instance thread safely and returns the mapping configured for this instance
	 *
	 * @name The name of the mapping to register
	 * @instancePath The path of the mapping to register
	 **/
	function registerNewInstance(required name, required instancePath) {
		var mapping = "";

    	//Register new instance mapping
    	lock name="Injector.#getInjectorID()#.RegisterNewvariables.#hash(arguments.instancePath)#" type="exclusive" timeout="20" throwontimeout="true" {
				if( NOT variables.binder.mappingExists( arguments.name ) ){
					// create a new mapping to be registered within the binder
					mapping = createObject("component","coldbox.system.ioc.config.Mapping")
						.init( arguments.name )
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
     * @path The instantiation path to the CFC that implements this scope, it must have an init() method and implement: coldbox.system.ioc.dsl.IDSLBuilder
     */
    function registerDSL(required namespace, required path) {
		variables.builder.registerDSL( argumentCollection=arguments );
	}

	/**
	 * Checks if this injector can locate a model instance or not
	 * 
	 * @name The object name or alias to search for if this container can locate it or has knowledge of it
	 * @doc_generic boolean
	 */
	function containsInstance(required name) {
		// check if we have a mapping first
		if( variables.binder.mappingExists(arguments.name) ){ return true; }
		// check if we can locate it?
		if( len(locateInstance(arguments.name)) ){ return true; }
		// Ask parent hierarchy if set
		if( isObject(variables.parent) ){ return variables.parent.containsInstance(arguments.name); }
		// Else NADA!
		return false;
	}

	/**
	 * Tries to locate a specific instance by scanning all scan locations and returning the instantiation path. If model not found then the returned instantiation path will be empty
	 * 
	 * @name The model instance name to locate
	 */
	function locateInstance(required name) {
		var scanLocations		= variables.binder.getScanLocations();
		var thisScanPath		= "";
		var CFCName				= replace(arguments.name,".","/","all") & ".cfc";

		// Check Scan Locations In Order
		for(thisScanPath in scanLocations){
			// Check if located? If so, return instantiation path
			if( fileExists( scanLocations[thisScanPath] & CFCName ) ){
				if( variables.log.canDebug() ){ variables.log.debug("Instance: #arguments.name# located in #thisScanPath#"); }
				return thisScanPath & "." & arguments.name;
			}
		}

		// Not found, so let's do full namespace location
		if( fileExists( expandPath("/" & CFCName) ) ){
			if( variables.log.canDebug() ){ variables.log.debug("Instance: #arguments.name# located as is."); }
			return arguments.name;
		}

		// debug info, NADA found!
		if( variables.log.canDebug() ){ variables.log.debug("Instance: #arguments.name# was not located anywhere"); }
		return "";
	}

	/**
	 * I wire up target objects with dependencies either by mappings or a-la-carte autowires
	 * 
	 * @target The target object to wire up
	 * @mapping The object mapping with all the necessary wiring metadata. Usually passed by scopes and not a-la-carte autowires
	 * @mapping.doc_generic coldbox.system.ioc.config.Mapping
	 * @targetID A unique identifier for this target to wire up. Usually a class path or file path should do. If none is passed we will get the id from the passed target via introspection but it will slow down the wiring
	 * @annotationCheck This value determines if we check if the target contains an autowire annotation in the cfcomponent tag: autowire=true|false, it will only autowire if that metadata attribute is set to true. The default is false, which will autowire anything automatically.
	 * @annotationCheck.doc_generic Boolean
	 */
	function autowire(required target, mapping, targetID="", boolean annotationCheck=false) {
		var targetObject	= arguments.target;
		var thisMap			= "";
		var md				= "";
		var x				= 1;
		var DIProperties 	= "";
		var DISetters		= "";
		var refLocal		= structnew();
		var iData			= "";

		// Do we have a mapping? Or is this a-la-carte wiring
		if( NOT structKeyExists(arguments,"mapping") ){
			// Ok, a-la-carte wiring, let's get our id first
			// Do we have an incoming target id?
			if( NOT len(arguments.targetID) ){
				// need to get metadata to verify identity
				md = variables.utility.getInheritedMetaData(arguments.target, getBinder().getStopRecursions());
				// We have identity now, use the full location path
				arguments.targetID = md.path;
			}

			// Now that we know we have an identity, let's verify if we have a mapping already
			if( NOT variables.binder.mappingExists( arguments.targetID ) ){
				// No mapping found, means we need to map this object for the first time.
				// Is md retreived? If not, retrieve it as we need to register it for the first time.
				if( isSimpleValue(md) ){ md = variables.utility.getInheritedMetaData(arguments.target, getBinder().getStopRecursions()); }
				// register new mapping instance
				registerNewInstance(arguments.targetID, md.path);
				// get Mapping created
				arguments.mapping = variables.binder.getMapping( arguments.targetID );
				// process it with current metadata
				arguments.mapping.process(binder=variables.binder,injector=this,metadata=md);
			}
			else{
				// get the mapping as it exists already
				arguments.mapping = variables.binder.getMapping( arguments.targetID );
			}
		}// end if mapping not found

		// Set local variable for easy reference use mapping to wire object up.
		thisMap = arguments.mapping;
		if( NOT len(arguments.targetID) ){
			arguments.targetID = thisMap.getName();
		}

		// Only autowire if no annotation check or if there is one, make sure the mapping is set for autowire, and this is a CFC
		if ( thisMap.getType() eq this.TYPES.CFC
			 AND
			 ( (arguments.annotationCheck eq false) OR (arguments.annotationCheck AND thisMap.isAutowire()) ) ){

			// announce beforeInstanceAutowire
			iData = {mapping=thisMap,target=arguments.target,targetID=arguments.targetID,injector=this};
			variables.eventManager.processState("beforeInstanceAutowire",iData);

			// prepare instance for wiring, done once for persisted objects and CFCs only
			variables.utility.getMixerUtil().start( arguments.target );

			// Bean Factory Awareness
			if( structKeyExists(targetObject,"setBeanFactory") ){
				targetObject.setBeanFactory( this );
			}
			if( structKeyExists(targetObject,"setInjector") ){
				targetObject.setInjector( this );
			}
			// ColdBox Context Awareness
			if( structKeyExists(targetObject,"setColdBox") ){
				targetObject.setColdBox( getColdBox() );
			}
			// DIProperty injection
			processInjection( targetObject, thisMap.getDIProperties(), arguments.targetID );
			// DISetter injection
			processInjection( targetObject, thisMap.getDISetters(), arguments.targetID );
			// Process Provider Methods
			processProviderMethods( targetObject, thisMap );
			// Process Mixins
			processMixins( targetObject, thisMap );
			// Process After DI Complete
			processAfterCompleteDI( targetObject, thisMap.getOnDIComplete() );

			// After Instance Autowire
			variables.eventManager.processState("afterInstanceAutowire",iData);

			// Debug Data
			if( variables.log.canDebug() ){
				variables.log.debug("Finalized Autowire for: #arguments.targetID#", thisMap.getMemento().toString());
			}
		}
	}

	/**
	 * Process mixins on the selected target
	 * 
	 * @targetObject The target object to do some goodness on
	 * @mapping The target mapping
	 */
	 private void function processMixins(required targetObject, required mapping) {
		var mixin 	= createObject("component","coldbox.system.ioc.config.Mixin").$init( arguments.mapping.getMixins() );
		var key		= "";

		// iterate and mixin baby!
		for(key in mixin){
			if( key NEQ "$init" ){
				// add the provided method to the providers structure.
				arguments.targetObject.injectMixin(name=key,UDF=mixin[ key ]);
			}
		}
	}

	/**
	 * Process provider methods on the selected target
	 * 
	 * @targetObject The target object to do some goodness on
	 * @mapping The target mapping
	 */
	private void function processProviderMethods(required targetObject, required mapping) {
		var providerMethods = arguments.mapping.getProviderMethods();
		var providerLen 	= arrayLen(providerMethods);
		var x				= 1;

		// Decorate the target if provider methods found, in preparation for replacements
		if( providerLen ){
			arguments.targetObject.$wbScopeInfo 	= getScopeRegistration();
			arguments.targetObject.$wbScopeStorage 	= variables.scopeStorage;
			arguments.targetObject.$wbProviders 	= {};
		}

		// iterate and provide baby!
		for(x=1; x lte providerLen; x++){
			// add the provided method to the providers structure.
			arguments.targetObject.$wbProviders[ providerMethods[ x ].method ] = providerMethods[ x ].mapping;
			// Override the function by injecting it, this does private/public functions
			arguments.targetObject.injectMixin(providerMethods[ x ].method, variables.builder.buildProviderMixer);
		}
	}

	/**
	 * Process after DI completion routines
	 * @targetObject The target object to do some goodness on
	 * @DICompleteMethods The array of DI completion methods to call
	 */
	private void function processAfterCompleteDI(required targetObject, required DICompleteMethods) {
		var DILen 		= arrayLen(arguments.DICompleteMethods);
		var thisMethod 	= "";
		//  Check for convention first 
		if ( StructKeyExists(arguments.targetObject, "onDIComplete" ) ) {
			//  Call our mixin invoker 
			arguments.targetObject.invokerMixin(method="onDIComplete");
		}
		//  Iterate on DICompleteMethods 
		for ( thisMethod in arguments.DICompleteMethods ) {
			if ( StructKeyExists(arguments.targetObject, thisMethod ) ) {
				//  Call our mixin invoker 
				arguments.targetObject.invokerMixin(method=thisMethod);
			}
		}

	}

	/**
	 * Process property and setter injection
	 * 
	 * @tagetObject The target object to do some goodness on
	 * @DIData The DI data to use
	 * @targetID The target ID to process injections
	 */
	private void function processInjection(required targetObject, required DIData, required targetID) {
		var refLocal 	= "";
		var DILen 	 	= arrayLen(arguments.DIData);
		var x			= 1;

		for(x=1; x lte DILen; x++){
			var thisDIData = arguments.DIData[ x ];

			// Init the lookup structure
			refLocal = {};
			// Check if direct value has been placed.
			if( !isNull( thisDIData.value ) ){
				refLocal.dependency = thisDIData.value;
			}
			// else check if dsl is used?
			else if( !isNull(thisDIData.dsl) ){
				// Get DSL dependency by sending entire DI structure to retrieve
				refLocal.dependency = variables.builder.buildDSLDependency( definition=thisDIData, targetID=arguments.targetID, targetObject=arguments.targetObject );
			}
			// else we have to have a reference ID or a nasty bug has ocurred
			else{
				refLocal.dependency = getInstance( arguments.DIData[ x ].ref );
			}

			// Check if dependency located, else log it and skip
			if( structKeyExists( refLocal, "dependency" ) ){
				// scope or setter determination
				refLocal.scope = "";
				if( structKeyExists(arguments.DIData[ x ],"scope") ){ refLocal.scope = arguments.DIData[ x ].scope; }
				// Inject dependency
				injectTarget(target=targetObject,
						     propertyName=arguments.DIData[ x ].name,
						     propertyObject=refLocal.dependency,
						     scope=refLocal.scope,
						     argName=arguments.DIData[ x ].argName);

				// some debugging goodness
				if( variables.log.canDebug() ){
					variables.log.debug("Dependency: #arguments.DIData[ x ].toString()# --> injected into #arguments.targetID#");
				}
			}
			else if( variables.log.canDebug() ){
				variables.log.debug("Dependency: #arguments.DIData[ x ].toString()# Not Found when wiring #arguments.targetID#. Registered mappings are: #structKeyList(variables.binder.getMappings())#");
			}
		}
	}

	/**
	 * Inject a model object with dependencies via setters or property injections
	 * 
	 * target The target that will be injected with dependencies
	 * propertyName The name of the property to inject
	 * propertyObject The object to inject
	 * scope The scope to inject a property into, if any else empty means it is a setter call
	 * argName The name of the argument to send if setter injection
	 */
	private void function injectTarget(required target, required propertyName, required propertyObject, required scope, required argName) {
		var argCollection = structnew();
		argCollection[ arguments.argName ] = arguments.propertyObject;
		//  Property or Setter 
		if ( len(arguments.scope) == 0 ) {
			//  Call our mixin invoker: setterMethod
			arguments.target.invokerMixin(method="set#arguments.propertyName#", argCollection=argCollection);
		} else {
			//  Call our property injector mixin 
			arguments.target.injectPropertyMixin(propertyName=arguments.propertyName, propertyValue=arguments.propertyObject, scope=arguments.scope);
		}
	}

	/**
	 * Link a parent Injector with this injector
	 * 
	 * @injector A WireBox Injector to assign as a parent to this Injector
	 * @injector.doc_generic coldbox.system.ioc.Injector
	 */
	public void function setParent(required injector) {
		variables.parent = arguments.injector;
	}

	/**
	 * Get a reference to the parent injector instance, else an empty simple string meaning nothing is set
	 *
	 * @doc_generic coldbox.system.ioc.Injector
	 */
	public any function getParent() {
		return variables.parent;
	}

	/**
	 * Get an object populator useful for populating objects from JSON,XML, etc.
	 * 
	 * @doc_generic coldbox.system.core.dynamic.BeanPopulator
	 */
	function getObjectPopulator() {
		return createObject("component","coldbox.system.core.dynamic.BeanPopulator").init();
	}

	/**
	 * Get the instance of ColdBox linked in this Injector. Empty if using standalone version
	 * 
	 * @doc_generic coldbox.system.web.Controller
	 */
	public any function getColdbox() {
		return variables.coldbox;
	}

	/**
	 * Checks if Coldbox application context is linked
	 * 
	 * @doc_generic boolean
	 */
	public boolean function isColdBoxLinked() {
		return isObject(variables.coldbox);
	}

	/**
	 * Get the instance of CacheBox linked in this Injector. Empty if using standalone version
	 * 
	 * @doc_generic coldbox.system.cache.CacheFactory
	 */
	function getCacheBox() {
		return variables.cacheBox;
	}

	/**
	 * Checks if CacheBox is linked
	 * 
	 * @doc_generic boolean
	 */
	public boolean function isCacheBoxLinked() {
		return isObject(variables.cacheBox);
	}

	/**
	 * Get the instance of LogBox configured for this Injector
	 * 
	 * @doc_generic coldbox.system.logging.LogBox
	 */
	function getLogBox() {
		return variables.logBox;
	}

	/**
	 * Get the Injector's version string.
	 */
	public any function getVersion() {
		return variables.version;
	}

	/**
	 * Get the Injector's configuration binder object
	 * 
	 * @doc_generic coldbox.system.ioc.config.Binder
	 */
	function getBinder() {
		return variables.binder;
	}

	/**
	 * Get the Injector's builder object
	 * 
	 * @doc_generic coldbox.system.ioc.Builder
	 */
	function getBuilder() {
		return variables.builder;
	}

	/**
	 * Get the unique ID of this injector
	 */
	public any function getInjectorID() {
		return variables.injectorID;
	}

	/**
	 * Get the injector's event manager
	 */
	public any function getEventManager() {
		return variables.eventManager;
	}

	/**
	 * Get the structure of scope registration information
	 * 
	 * @doc_generic struct
	 */
	public struct function getScopeRegistration() {
		return variables.binder.getScopeRegistration();
	}

	/**
	 * Get the scope storage utility
	 * @doc_generic coldbox.system.core.collections.ScopeStorage
	 */
	function getScopeStorage() {
		return variables.scopeStorage;
	}

	/**
	 * Remove the Injector from scope registration if enabled, else does nothing
	 */
	public void function removeFromScope() {
		var scopeInfo 		= variables.binder.getScopeRegistration();
		// if enabled remove.
		if( scopeInfo.enabled ){
			variables.scopeStorage.delete(scopeInfo.key, scopeInfo.scope);

			// Log info
			if( variables.log.canDebug() ){
				variables.log.debug("Injector removed from scope: #scopeInfo.toString()#");
			}
		}
	}

	/**
	 * Get all the registered scopes structure in this injector
	 * @doc_generic struct
	 */
	public struct function getScopes() {
		return variables.scopes;
	}

	/**
	 * Get a registered scope in this injector by name
	 */
	public any function getScope(required any scope) {
		return variables.scopes[ arguments.scope ];
	}

	/**
	 * Clear the singleton cache
	 */
	public any function clearSingletons() {
		variables.scopes["SINGLETON"].clear();
	}

	/**
	 * Return a self reference using the scoped registration, mostly used by providers or scope widening objects
	 * 
	 * @doc_generic coldbox.system.ioc.Injector
	 */
	function locateScopedSelf() {
		var scopeInfo 	= variables.binder.getScopeRegistration();

		// Return if it exists, else throw exception
		if( variables.scopeStorage.exists(scopeInfo.key, scopeInfo.scope) ){
			return variables.scopeStorage.get(scopeInfo.key, scopeInfo.scope);
		}

		throw(message="The injector has not be registered in any scope",detail="The scope info is: #scopeInfo.toString()#",type="Injector.InvalidScopeRegistration");
	}

	/**
	 * Register all internal and configured WireBox Scopes
	 */
	private void function registerScopes() {
		var customScopes 	= variables.binder.getCustomScopes();
		var key				= "";

		// register no_scope
		variables.scopes["NOSCOPE"] = createObject("component","coldbox.system.ioc.scopes.NoScope").init( this );
		// register singleton
		variables.scopes["SINGLETON"] = createObject("component","coldbox.system.ioc.scopes.Singleton").init( this );
		// is cachebox linked?
		if( isCacheBoxLinked() ){
			variables.scopes["CACHEBOX"] = createObject("component","coldbox.system.ioc.scopes.CacheBox").init( this );
		}
		// CF Scopes and references
		variables.scopes["REQUEST"] 		= createObject("component","coldbox.system.ioc.scopes.RequestScope").init( this );
		variables.scopes["SESSION"] 		= createObject("component","coldbox.system.ioc.scopes.CFScopes").init( this );
		variables.scopes["SERVER"] 		= variables.scopes["SESSION"];
		variables.scopes["APPLICATION"] 	= variables.scopes["SESSION"];

		// Debugging
		if( variables.log.canDebug() ){
			variables.log.debug("Registered all internal lifecycle scopes successfully: #structKeyList(variables.scopes)#");
		}

		// Register Custom Scopes
		for(key in customScopes){
			variables.scopes[key] = createObject("component",customScopes[key]).init( this );
			// Debugging
			if( variables.log.canDebug() ){
				variables.log.debug("Registered custom scope: #key# (#customScopes[key]#)");
			}
		}
	}

	/**
	 * Register all the configured listeners in the configuration file
	 */
	private void function registerListeners() {
		var listeners 	= variables.binder.getListeners();
			var regLen		= arrayLen(listeners);
			var x			= 1;

			// iterate and register listeners
			for( x = 1; x lte regLen; x++ ){
				registerListener( listeners[ x ] );
			}
	}

	/**
	 * Register all the configured listeners in the configuration file
	 * 
	 * @listener The listener to register
	 */
	public void function registerListener(required listener) {
		try{
			// create it
			var thisListener = createObject("component", listener.class);
			// configure it
			thisListener.configure( this, listener.properties);
		}
		catch(Any e){
			variables.log.error("Error creating listener: #listener.toString()#", e);
			throw(message="Error creating listener: #listener.toString()#",
							  detail="#e.message# #e.detail# #e.stackTrace#",
							  type="Injector.ListenerCreationException");
		}

		// Now register listener
		if( NOT isColdBoxLinked() ){
			variables.eventManager.register(thisListener,listener.name);
		}
		else{
			variables.eventManager.registerInterceptor(interceptorObject=thisListener,interceptorName=listener.name);
		}

		// debugging
		if( variables.log.canDebug() ){
			variables.log.debug("Injector has just registered a new listener: #listener.toString()#");
		}
	}

	/**
	 * Register this injector on a user specified scope
	 */
	private void function doScopeRegistration() {
		var scopeInfo 		= variables.binder.getScopeRegistration();

		// register injector with scope
		variables.scopeStorage.put(scopeInfo.key, this, scopeInfo.scope);

		// Log info
		if( variables.log.canDebug() ){
			variables.log.debug("Scope Registration enabled and Injector scoped to: #scopeInfo.toString()#");
		}
	}

	/**
	 * Configure a standalone version of cacheBox for persistence
	 * 
	 * @config The cacheBox configuration data structure
	 * @config.doc_generic struct
	 */
	private void function configureCacheBox(required struct config) {
		var args 	= structnew();
		var oConfig	= "";

		// is cachebox enabled?
		if( NOT arguments.config.enabled ){
			return;
		}

		// Do we have a cacheBox reference?
		if( isObject(arguments.config.cacheFactory) ){
			variables.cacheBox = arguments.config.cacheFactory;
			// debugging
			if( variables.log.canDebug() ){
				variables.log.debug("Configured Injector #getInjectorID()# with direct CacheBox instance: #variables.cacheBox.getFactoryID()#");
			}
			return;
		}

		// Do we have a configuration file?
		if( len(arguments.config.configFile) ){
			// xml?
			if( listFindNoCase("xml,cfm", listLast(arguments.config.configFile,".") ) ){
				args["XMLConfig"] = arguments.config.configFile;
			}
			else{
				// cfc
				args["CFCConfigPath"] = arguments.config.configFile;
			}

			// Create CacheBox
			oConfig = createObject("component","#arguments.config.classNamespace#.config.CacheBoxConfig").init(argumentCollection=args);
			variables.cacheBox = createObject("component","#arguments.config.classNamespace#.CacheFactory").init( oConfig );
			// debugging
			if( variables.log.canDebug() ){
				variables.log.debug("Configured Injector #getInjectorID()# with CacheBox instance: #variables.cacheBox.getFactoryID()# and configuration file: #arguments.config.configFile#");
			}
			return;
		}

		// No config file, plain vanilla cachebox
		variables.cacheBox = createObject("component","#arguments.config.classNamespace#.CacheFactory").init();
		// debugging
		if( variables.log.canDebug() ){
			variables.log.debug("Configured Injector #getInjectorID()# with vanilla CacheBox instance: #variables.cacheBox.getFactoryID()#");
		}
	}

	/**
	 * Configure a standalone version of logBox for logging
	 */
	private void function configureLogBox(required configPath) {
		var config 	= "";
		var args 	= structnew();

		// xml?
		if( listFindNoCase("xml,cfm", listLast(arguments.configPath,".") ) ){
			args["XMLConfig"] = arguments.configPath;
		}
		else{
			// cfc
			args["CFCConfigPath"] = arguments.configPath;
		}

		config = createObject("component","coldbox.system.logging.config.LogBoxConfig").init(argumentCollection=args);

		// Create LogBox
		variables.logBox = createObject("component","coldbox.system.logging.LogBox").init( config );
		// Configure Logging for this injector
		variables.log = variables.logBox.getLogger( this );
	}

	/**
	 * Configure a standalone version of a WireBox Event Manager
	 */
	private void function configureEventManager() {
		// Use or create event manager
		if( isColdBoxLinked() && isObject( variables.eventManager ) ){
			// Link Interception States
			variables.eventManager.appendInterceptionPoints( arrayToList(variables.eventStates) );
			return;
		}

		// create event manager
		variables.eventManager = createObject("component","coldbox.system.core.events.EventPoolManager").init( variables.eventStates );
		// Debugging
		if( variables.log.canDebug() ){
			variables.log.debug("Registered injector's event manager with the following event states: #variables.eventStates.toString()#");
		}
	}

	/**
	 * Return the core util object
	 * 
	 * @doc_generic coldbox.system.core.util.Util
	 */
	function getUtil() {
		return variables.utility;
	}

	/**
	 * Load a configuration binder object according to passed in type
	 * 
	 * @binder  The data CFC configuration instance, instantiation path or programmatic binder object to configure this injector with
	 * @properties  A map of binding properties to passthrough to the Configuration CFC
	 */
	private any function buildBinder(required binder, required properties) {
		var dataCFC = "";

		// Check if just a plain CFC path and build it
		if( isSimpleValue( arguments.binder ) ){
			arguments.binder = createObject( "component", arguments.binder );
		}

		// Check if data CFC or binder family
		if( NOT isInstanceOf( arguments.binder, "coldbox.system.ioc.config.Binder" ) ){
			// simple data cfc, create native binder and decorate data CFC
			nativeBinder = createObject( "component", "coldbox.system.ioc.config.Binder" )
				.init( injector=this, config=arguments.binder, properties=arguments.properties );
		}
		else{
			// else init the binder and configur it
			nativeBinder = arguments.binder.init( injector=this, properties=arguments.properties );
			// Configure it
			nativeBinder.configure();
			// Load it
			nativeBinder.loadDataDSL();
		}

		return nativeBinder;
	}

}