<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The WireBox injector is the pivotal class in WireBox that performs
	dependency injection.  It can be used standalone or it can be used in conjunction
	of a ColdBox application context.  It can also be configured with a mapping configuration
	file called a binder, that can provide object/mappings and configuration data.
	
	Easy Startup:
	injector = new coldbox.system.ioc.Injector();
	
	Binder Startup
	injector = new coldbox.system.ioc.Injector(new MyBinder());
	
	Binder Path Startup
	injector = new coldbox.system.ioc.Injector("config.MyBinder");

----------------------------------------------------------------------->
<cfcomponent hint="A WireBox Injector: Builds the graphs of objects that make up your application." output="false" serializable="false">

<!----------------------------------------- CONSTRUCTOR ------------------------------------->			
		
	<!--- init --->
	<cffunction name="init" access="public" returntype="Injector" hint="Constructor. If called without a configuration binder, then WireBox will instantiate the default configuration binder found in: coldbox.system.ioc.config.DefaultBinder" output="false" >
		<cfargument name="binder" 		required="false" default="coldbox.system.ioc.config.DefaultBinder" hint="The WireBox binder or data CFC instance or instantiation path to configure this injector with">
		<cfargument name="properties" 	required="false" default="#structNew()#" hint="A structure of binding properties to passthrough to the Binder Configuration CFC" colddoc:generic="struct">
		<cfargument name="coldbox" 		required="false" default="" hint="A coldbox application context that this instance of WireBox can be linked to, if not using it, we just ignore it." colddoc:generic="coldbox.system.web.Controller">
		<cfscript>
			// Setup Available public scopes
			this.SCOPES = createObject("component","coldbox.system.ioc.Scopes");
			// Setup Available public types
			this.TYPES = createObject("component","coldbox.system.ioc.Types");
			
			// Do we have a binder?
			if( NOT len(trim(arguments.binder)) ){ arguments.binder = "coldbox.system.ioc.config.DefaultBinder"; }
					
			// Prepare Injector instance
			instance = {
				// Java System
				javaSystem = createObject('java','java.lang.System'),	
				// Utility class
				utility  = createObject("component","coldbox.system.core.util.Util"),
				// Scope Storages
				scopeStorage = createObject("component","coldbox.system.core.collections.ScopeStorage").init(),
				// Version
				version  = "1.1.1",	 
				// The Configuration Binder object
				binder   = "",
				// ColdBox Application Link
				coldbox  = "",
				// LogBox Link
				logBox   = "",
				// CacheBox Link
				cacheBox = "",
				// Event Manager Link
				eventManager = "",
				// Configured Event States
				eventStates = [
					"afterInjectorConfiguration", 	// X once injector is created and configured
					"beforeInstanceCreation", 		// X Before an injector creates or is requested an instance of an object, the mapping is passed.
					"afterInstanceInitialized",		// X once the constructor is called and before DI is performed
					"afterInstanceCreation", 		// X once an object is created, initialized and done with DI
					"beforeInstanceInspection",		// X before an object is inspected for injection metadata
					"afterInstanceInspection",		// X after an object has been inspected and metadata is ready to be saved
					"beforeInjectorShutdown",		// X right before the shutdown procedures start
					"afterInjectorShutdown"			// X right after the injector is shutdown
				],
				// LogBox and Class Logger
				logBox  = "",
				log		= "",
				// Parent Injector
				parent = "",
				// LifeCycle Scopes
				scopes = {}
			};
			
			// Prepare instance ID
			instance.injectorID = instance.javaSystem.identityHashCode(this);
			// Prepare Lock Info
			instance.lockName = "WireBox.Injector.#instance.injectorID#";
			// Link ColdBox Context if passed
			instance.coldbox = arguments.coldbox;
				
			// Configure the injector for operation
			configure( arguments.binder, arguments.properties);
			
			return this;
		</cfscript>
	</cffunction>
				
	<!--- configure --->
	<cffunction name="configure" output="false" access="public" returntype="void" hint="Configure this injector for operation, called by the init(). You can also re-configure this injector programmatically, but it is not recommended.">
		<cfargument name="binder" 		required="true" hint="The configuration binder object or path to configure this Injector instance with" colddoc:generic="coldbox.system.ioc.config.Binder">
		<cfargument name="properties" 	required="true" hint="A structure of binding properties to passthrough to the Configuration CFC" colddoc:generic="struct">
		<cfscript>
			var key 			= "";
			var iData			= {};
			var withColdbox 	= isColdBoxLinked();
		</cfscript>
		
		<!--- Lock For Configuration --->
		<cflock name="#instance.lockName#" type="exclusive" timeout="30" throwontimeout="true">
			<cfscript>
			if( withColdBox ){ 
				// link LogBox
				instance.logBox  = instance.coldbox.getLogBox();
				// Configure Logging for this injector
				instance.log = instance.logBox.getLogger( this );
				// Link CacheBox
				instance.cacheBox = instance.coldbox.getCacheBox();
				// Link Event Manager
				instance.eventManager = instance.coldbox.getInterceptorService();
				// Link Interception States
				instance.eventManager.appendInterceptionPoints( arrayToList(instance.eventStates) ); 
			}	
			
			// Store binder object built accordingly to our binder building procedures
			instance.binder = buildBinder( arguments.binder, arguments.properties );
			
			// Create local cache, logging and event management if not coldbox context linked.
			if( NOT withColdbox ){ 
				// Running standalone, so create our own logging first
				configureLogBox( instance.binder.getLogBoxConfig() );
				// Create local CacheBox reference
				configureCacheBox( instance.binder.getCacheBoxConfig() ); 
				// Create local event manager
				configureEventManager();
				// Register All Custom Listeners
				registerListeners();
			}
			
			// Create our object builder
			instance.builder = createObject("component","coldbox.system.ioc.Builder").init( this );
			// Register Custom DSL Builders
			instance.builder.registerCustomBuilders();
		
			// Register Life Cycle Scopes
			registerScopes();
			
			// Parent Injector declared
			if( isObject(instance.binder.getParentInjector()) ){
				setParent( instance.binder.getParentInjector() );
			}
			
			// Scope registration if enabled?
			if( instance.binder.getScopeRegistration().enabled ){
				doScopeRegistration();
			}
			
			// process mappings for metadata and initialization.
			instance.binder.processMappings();
			
			// Announce To Listeners we are online
			iData.injector = this;
			instance.eventManager.processState("afterInjectorConfiguration",iData);
			</cfscript>
		</cflock>
	</cffunction>
	
	<!--- shutdown --->
    <cffunction name="shutdown" output="false" access="public" returntype="void" hint="Shutdown the injector gracefully by calling the shutdown events internally.">
    	<cfscript>
    		var iData = { 
				injector = this 
			};
			
			// Log
			if( instance.log.canInfo() ){
    			instance.log.info("Shutdown of Injector: #getInjectorID()# requested and started.");
    		}
			
			// Notify Listeners
			instance.eventManager.processState("beforeInjectorShutdown",iData);
			
			// standalone cachebox? Yes, then shut it down baby!
			if( NOT isColdBoxLinked() ){
				instance.cacheBox.shutdown();
			}
			
			// Remove from scope
			removeFromScope();		
			
			// Notify Listeners
			instance.eventManager.processState("afterInjectorShutdown",iData);
			
			// Log shutdown complete
			if( instance.log.canInfo() ){
				instance.log.info("Shutdown of injector: #getInjectorID()# completed.");
			}	
		</cfscript>
    </cffunction>

	<!--- getInstance --->
    <cffunction name="getInstance" output="false" access="public" returntype="any" hint="Locates, Creates, Injects and Configures an object model instance">
    	<cfargument name="name" 			required="false" 	hint="The mapping name or CFC instance path to try to build up"/>
		<cfargument name="dsl"				required="false" 	hint="The dsl string to use to retrieve the instance model object, mutually exclusive with 'name'"/>
		<cfargument name="initArguments" 	required="false" 	default="#structnew()#" hint="The constructor structure of arguments to passthrough when initializing the instance" colddoc:generic="struct"/>
		<cfscript>
			var instancePath 	= "";
			var mapping 		= "";
			var target			= "";
			var iData			= {};
			
			// Get by DSL?
			if( structKeyExists(arguments,"dsl") ){
				return instance.builder.buildSimpleDSL( arguments.dsl );
			}
			
			// Check if Mapping Exists?
			if( NOT instance.binder.mappingExists(arguments.name) ){
				// No Mapping exists, let's try to locate it first. We are now dealing with request by conventions
				instancePath = locateInstance(arguments.name);
				
				// check if not found and if we have a parent factory
				if( NOT len(instancePath) AND isObject(instance.parent) ){
					// we do have a parent factory so just request it from there, let the hierarchy deal with it
					return instance.parent.getInstance(argumentCollection=arguments);
				}
				
				// If Empty Throw Exception
				if( NOT len(instancePath) ){
					instance.log.error("Requested instance:#arguments.name# was not located in any declared scan location(s): #structKeyList(instance.binder.getScanLocations())# or full CFC path");
					getUtil().throwit(message="Requested instance not found: '#arguments.name#'",
									  detail="The instance could not be located in any declared scan location(s) (#structKeyList(instance.binder.getScanLocations())#) or full path location",
									  type="Injector.InstanceNotFoundException");
				}
				// Let's create a mapping for this requested convention name+path as it is the first time we see it
				registerNewInstance(arguments.name, instancePath);
			}
			
			// Get Requested Mapping (Guaranteed to exist now)
			mapping = instance.binder.getMapping( arguments.name );
			
			// Check if the mapping has been discovered yet, and if it hasn't it must be autowired enabled in order to process.
			if( NOT mapping.isDiscovered() AND mapping.isAutowire() ){ 
				// process inspection of instance
				mapping.process(binder=instance.binder,injector=this);
			}
			
			// scope persistence check
			if( NOT structKeyExists(instance.scopes, mapping.getScope()) ){
				instance.log.error("The mapping scope: #mapping.getScope()# is invalid and not registered in the valid scopes: #structKeyList(instance.scopes)#");
				getUtil().throwit(message="Requested mapping scope: #mapping.getScope()# is invalid for #mapping.getName()#",
								  detail="The registered valid object scopes are #structKeyList(instance.scopes)#",
								  type="Injector.InvalidScopeException");
			}
			
			// Request object from scope now, we now have it from the scope created, initialized and wired
			target = instance.scopes[ mapping.getScope() ].getFromScope( mapping, arguments.initArguments );
			
			// Announce creation, initialization and DI magicfinicitation!
			iData = {mapping=mapping,target=target,injector=this};
			instance.eventManager.processState("afterInstanceCreation",iData);
			
			return target;
		</cfscript>
    </cffunction>
	
	<!--- buildInstance --->
    <cffunction name="buildInstance" output="false" access="public" returntype="any" hint="Build an instance, this is called from registered scopes only as they provide locking and transactions">
    	<cfargument name="mapping" 			required="true" 	hint="The mapping to construct" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfargument name="initArguments" 	required="false"	default="#structnew()#" 	hint="The constructor structure of arguments to passthrough when initializing the instance" colddoc:generic="struct"/>
		<cfscript>
    		var thisMap = arguments.mapping;
			var oModel	= "";
			var iData	= "";
			
			// before construction event
			iData = {mapping=arguments.mapping,injector=this};
			instance.eventManager.processState("beforeInstanceCreation",iData);
			
    		// determine construction type
    		switch( thisMap.getType() ){
				case "cfc" : {
					oModel = instance.builder.buildCFC( thisMap, arguments.initArguments ); break;
				}
				case "java" : {
					oModel = instance.builder.buildJavaClass( thisMap ); break;
				}
				case "webservice" : {
					oModel = instance.builder.buildWebservice( thisMap, arguments.initArguments ); break;
				}
				case "constant" : {
					oModel = thisMap.getValue(); break;
				}
				case "rss" : {
					oModel = instance.builder.buildFeed( thisMap ); break;
				}
				case "dsl" : {
					oModel = instance.builder.buildSimpleDSL( thisMap.getDSL() ); break;
				}
				case "factory" : {
					oModel = instance.builder.buildFactoryMethod( thisMap, arguments.initArguments ); break;
				}
				case "provider" : {
					oModel = getInstance( thisMap.getPath() ).get(); break;
				}
				default: { getUtil().throwit(message="Invalid Construction Type: #thisMap.getType()#",type="Injector.InvalidConstructionType"); }
			}		
			
			// log data
			if( instance.log.canDebug() ){
				instance.log.debug("Instance object built: #arguments.mapping.getName()#:#arguments.mapping.getPath()#");
			}
			
			// announce afterInstanceInitialized
			iData = {mapping=arguments.mapping,target=oModel,injector=this};
			instance.eventManager.processState("afterInstanceInitialized",iData);
			
			return oModel;
		</cfscript>
    </cffunction>
	
	<!--- registerNewInstance --->
    <cffunction name="registerNewInstance" output="false" access="private" returntype="void" hint="Register a new requested mapping object instance">
    	<cfargument name="name" 		required="true" hint="The name of the mapping to register"/>
		<cfargument name="instancePath" required="true" hint="The path of the mapping to register">
    	
    	<!--- Register new instance mapping --->
    	<cflock name="Injector.RegisterNewInstance.#hash(arguments.instancePath)#" type="exclusive" timeout="20" throwontimeout="true">
    		<!--- double lock for concurrency --->
    		<cfif NOT instance.binder.mappingExists(arguments.name)>
    			<cfset instance.binder.map(arguments.name).to(arguments.instancePath)>
    		</cfif>
		</cflock>
		
    </cffunction>
		
	<!--- containsInstance --->
    <cffunction name="containsInstance" output="false" access="public" returntype="any" hint="Checks if this injector can locate a model instance or not" colddoc:generic="boolean">
    	<cfargument name="name" required="true" hint="The object name or alias to search for if this container can locate it or has knowledge of it"/>
		<cfscript>
			// check if we have a mapping first
			if( instance.binder.mappingExists(arguments.name) ){ return true; }
			// check if we can locate it?
			if( len(locateInstance(arguments.name)) ){ return true; }
			// Ask parent hierarchy if set
			if( isObject(instance.parent) ){ return instance.parent.containsInstance(arguments.name); }
			// Else NADA!
			return false;		
		</cfscript>
    </cffunction>
		
	<!--- locateInstance --->
    <cffunction name="locateInstance" output="false" access="public" returntype="any" hint="Tries to locate a specific instance by scanning all scan locations and returning the instantiation path. If model not found then the returned instantiation path will be empty">
    	<cfargument name="name" required="true" hint="The model instance name to locate">
		<cfscript>
			var scanLocations		= instance.binder.getScanLocations();
			var thisScanPath		= "";
			var CFCName				= replace(arguments.name,".","/","all") & ".cfc";
			
			// Check Scan Locations In Order
			for(thisScanPath in scanLocations){
				// Check if located? If so, return instantiation path
				if( fileExists( scanLocations[thisScanPath] & CFCName ) ){
					if( instance.log.canDebug() ){ instance.log.debug("Instance: #arguments.name# located in #thisScanPath#"); }
					return thisScanPath & "." & arguments.name;
				}
			}

			// Not found, so let's do full namespace location
			if( fileExists( expandPath("/" & CFCName) ) ){
				if( instance.log.canDebug() ){ instance.log.debug("Instance: #arguments.name# located as is."); }
				return arguments.name;
			}
			
			// debug info, NADA found!
			if( instance.log.canDebug() ){ instance.log.debug("Instance: #arguments.name# was not located anywhere"); }
			
			return "";			
		</cfscript>
    </cffunction>
	
	<!--- autowire --->
    <cffunction name="autowire" output="false" access="public" returntype="any" hint="I wire up target objects with dependencies either by mappings or a-la-carte autowires">
    	<cfargument name="target" 				required="true" 	hint="The target object to wire up"/>
		<cfargument name="mapping" 				required="false" 	hint="The object mapping with all the necessary wiring metadata. Usually passed by scopes and not a-la-carte autowires" colddoc:generic="coldbox.system.ioc.config.Mapping"/>
		<cfargument name="targetID" 			required="false" 	default="" hint="A unique identifier for this target to wire up. Usually a class path or file path should do. If none is passed we will get the id from the passed target via introspection but it will slow down the wiring"/>
    	<cfargument name="annotationCheck" 		required="false" 	default="false" hint="This value determines if we check if the target contains an autowire annotation in the cfcomponent tag: autowire=true|false, it will only autowire if that metadata attribute is set to true. The default is false, which will autowire anything automatically." colddoc:generic="Boolean">
		<cfscript>
			var targetObject	= arguments.target;
			var thisMap			= "";
			var md				= "";
			var x				= 1;
			var DIProperties 	= "";
			var DISetters		= "";
			var refLocal		= structnew();
			
			// Do we have a mapping? Or is this a-la-carte wiring
			if( NOT structKeyExists(arguments,"mapping") ){
				// Ok, a-la-carte wiring, let's get our id first
				// Do we have an incoming target id?
				if( NOT len(arguments.targetID) ){
					// need to get metadata to verify identity
					md = getMetadata(arguments.target);
					// We have identity now, use the full location path
					arguments.targetID = md.path;
				}
				
				// Now that we know we have an identity, let's verify if we have a mapping already
				if( NOT instance.binder.mappingExists( arguments.targetID ) ){
					// No mapping found, means we need to map this object for the first time.
					// Is md retreived? If not, retrieve it as we need to register it for the first time.
					if( isSimpleValue(md) ){ md = getMetadata(arguments.target); }
					// register new mapping instance
					registerNewInstance(arguments.targetID,md.path);
					// get Mapping created
					arguments.mapping = instance.binder.getMapping( arguments.targetID );
					// process it with current metadata
					arguments.mapping.process(binder=instance.binder,injector=this,metadata=md);
				}
				else{
					// get the mapping as it exists already
					arguments.mapping = instance.binder.getMapping( arguments.targetID );
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
				
				// prepare instance for wiring, done once for persisted objects and CFCs only
				instance.utility.getMixerUtil().start( arguments.target );
				
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
				// Process After DI Complete
				processAfterCompleteDI( targetObject, thisMap.getOnDIComplete() );
				
				// Debug Data
				if( instance.log.canDebug() ){
					instance.log.debug("Finalized Autowire for: #arguments.targetID#", thisMap.getMemento().toString());
				}
			}
	</cfscript>
    </cffunction>
	
	<!--- processProviderMethods --->
    <cffunction name="processProviderMethods" output="false" access="private" returntype="void" hint="Process provider methods on the selected target">
    	<cfargument name="targetObject" 	required="true"  	hint="The target object to do some goodness on">
		<cfargument name="mapping" 			required="true"  	hint="The target mapping">
		<cfscript>
			var providerMethods = arguments.mapping.getProviderMethods();
			var providerLen 	= arrayLen(providerMethods);
			var x				= 1;
			
			// Decorate the target if provider methods found, in preparation for replacements
			if( providerLen ){
				arguments.targetObject.$wbScopeInfo 	= getScopeRegistration();
				arguments.targetObject.$wbScopeStorage 	= instance.scopeStorage;
				arguments.targetObject.$wbProviders 	= {};
			}
			
			// iterate and provide baby!
			for(x=1; x lte providerLen; x++){
				// add the provided method to the providers structure.
				arguments.targetObject.$wbProviders[ providerMethods[x].method ] = providerMethods[x].mapping;
				// Override the function by injecting it, this does private/public functions
				arguments.targetObject.injectMixin(providerMethods[x].method, instance.builder.buildProviderMixer);
			}
		</cfscript>
    </cffunction>

	<!--- Process After DI Complete --->
	<cffunction name="processAfterCompleteDI" access="private" returntype="void" output="false" hint="Process after DI completion routines">
		<cfargument name="targetObject" 		required="true"  	hint="The target object to do some goodness on">
		<cfargument name="DICompleteMethods" 	required="true"  	hint="The array of DI completion methods to call">
		
		<cfset var DILen 		= arrayLen(arguments.DICompleteMethods)>
		<cfset var thisMethod 	= "">
		
		<!--- Check for convention first --->
		<cfif StructKeyExists(arguments.targetObject, "onDIComplete" )>
			<!--- Call our mixin invoker --->
			<cfinvoke component="#arguments.targetObject#" method="invokerMixin">
				<cfinvokeargument name="method"  value="onDIComplete">
			</cfinvoke>
		</cfif>
		
		<!--- Iterate on DICompleteMethods --->
		<cfloop array="#arguments.DICompleteMethods#" index="thisMethod">
			<cfif StructKeyExists(arguments.targetObject, thisMethod )>
				<!--- Call our mixin invoker --->
				<cfinvoke component="#arguments.targetObject#" method="invokerMixin">
					<cfinvokeargument name="method"  value="#thisMethod#">
				</cfinvoke>
			</cfif>
		</cfloop>
		
	</cffunction>
	
	<!--- processInjection --->
    <cffunction name="processInjection" output="false" access="private" returntype="void" hint="Process property and setter injection">
    	<cfargument name="targetObject" required="true" hint="The target object to do some goodness on">
		<cfargument name="DIData" 		required="true" hint="The DI data to use"/>
		<cfargument name="targetID" 	required="true" hint="The target ID to process injections"/>
    	<cfscript>
    		var refLocal 	= "";
			var DILen 	 	= arrayLen(arguments.DIData);
			var x			= 1;
			
			for(x=1; x lte DILen; x++){
				// Init the lookup structure
				refLocal = {};
				// Check if direct value has been placed.
				if( structKeyExists(arguments.DIData[x],"value") ){
					refLocal.dependency = arguments.DIData[x].value;
				}
				// else check if dsl is used?
				else if( structKeyExists(arguments.DIData[x], "dsl") ){
					// Get DSL dependency by sending entire DI structure to retrieve
					refLocal.dependency = instance.builder.buildDSLDependency( arguments.DIData[x] );
				}
				// else we have to have a reference ID or a nasty bug has ocurred
				else{
					refLocal.dependency = getInstance( arguments.DIData[x].ref );
				}
				
				// Check if dependency located, else log it and skip
				if( structKeyExists(refLocal,"dependency") ){
					// scope or setter determination
					refLocal.scope = "";
					if( structKeyExists(arguments.DIData[x],"scope") ){ refLocal.scope = arguments.DIData[x].scope; }
					// Inject dependency
					injectTarget(target=targetObject,
							     propertyName=arguments.DIData[x].name,
							     propertyObject=refLocal.dependency,
							     scope=refLocal.scope);
					
					// some debugging goodness
					if( instance.log.canDebug() ){
						instance.log.debug("Dependency: #arguments.DIData[x].toString()# --> injected into #arguments.targetID#");
					}
				}
				else if( instance.log.canDebug() ){
					instance.log.debug("Dependency: #arguments.DIData[x].toString()# Not Found when wiring #arguments.targetID#. Registered mappings are: #structKeyList(instance.binder.getMappings())#");
				}
			}
		</cfscript>
    </cffunction>
	
	<!--- Inject A Target Object --->
	<cffunction name="injectTarget" access="private" returntype="void" output="false" hint="Inject a model object with dependencies via setters or property injections">
		<cfargument name="target"  	 		required="true" hint="The target that will be injected with dependencies" />
		<cfargument name="propertyName"  	required="true" hint="The name of the property to inject"/>
		<cfargument name="propertyObject" 	required="true" hint="The object to inject" />
		<cfargument name="scope" 			required="true" hint="The scope to inject a property into, if any else empty means it is a setter call">
		
		<cfset var argCollection = structnew()>
		<cfset argCollection[arguments.propertyName] = arguments.propertyObject>
		
		<!--- Property or Setter --->
		<cfif len(arguments.scope) eq 0>
			<!--- Call our mixin invoker: setterMethod--->
			<cfinvoke component="#arguments.target#" method="invokerMixin">
				<cfinvokeargument name="method"  		value="set#arguments.propertyName#">
				<cfinvokeargument name="argCollection"  value="#argCollection#">
			</cfinvoke>
		<cfelse>
			<!--- Call our property injector mixin --->
			<cfinvoke component="#arguments.target#" method="injectPropertyMixin">
				<cfinvokeargument name="propertyName"  	value="#arguments.propertyName#">
				<cfinvokeargument name="propertyValue"  value="#arguments.propertyObject#">
				<cfinvokeargument name="scope"			value="#arguments.scope#">
			</cfinvoke>
		</cfif>
	</cffunction>
	
	<!--- setParent --->
    <cffunction name="setParent" output="false" access="public" returntype="void" hint="Link a parent Injector with this injector">
    	<cfargument name="injector" required="true" hint="A WireBox Injector to assign as a parent to this Injector" colddoc:generic="coldbox.system.ioc.Injector">
    	<cfset instance.parent = arguments.injector>
    </cffunction>
	
	<!--- getParent --->
    <cffunction name="getParent" output="false" access="public" returntype="any" hint="Get a reference to the parent injector instance, else an empty simple string meaning nothing is set" colddoc:generic="coldbox.system.ioc.Injector">
    	<cfreturn instance.parent>
    </cffunction>
	
	<!--- getObjectPopulator --->
    <cffunction name="getObjectPopulator" output="false" access="public" returntype="any" hint="Get an object populator useful for populating objects from JSON,XML, etc." colddoc:generic="coldbox.system.core.dynamic.BeanPopulator">
    	<cfreturn createObject("component","coldbox.system.core.dynamic.BeanPopulator").init()>
    </cffunction>
	
	<!--- getColdbox --->
    <cffunction name="getColdbox" output="false" access="public" returntype="any" hint="Get the instance of ColdBox linked in this Injector. Empty if using standalone version" colddoc:generic="coldbox.system.web.Controller">
    	<cfreturn instance.coldbox>
    </cffunction>
	
	<!--- isColdBoxLinked --->
    <cffunction name="isColdBoxLinked" output="false" access="public" returntype="any" hint="Checks if Coldbox application context is linked" colddoc:generic="boolean">
    	<cfreturn isObject(instance.coldbox)>
    </cffunction>
	
	<!--- getCacheBox --->
    <cffunction name="getCacheBox" output="false" access="public" returntype="any" hint="Get the instance of CacheBox linked in this Injector. Empty if using standalone version" colddoc:generic="coldbox.system.cache.CacheFactory">
    	<cfreturn instance.cacheBox>
    </cffunction>
	
	<!--- isCacheBoxLinked --->
    <cffunction name="isCacheBoxLinked" output="false" access="public" returntype="any" hint="Checks if CacheBox is linked" colddoc:generic="boolean">
    	<cfreturn isObject(instance.cacheBox)>
    </cffunction>

	<!--- getLogBox --->
    <cffunction name="getLogBox" output="false" access="public" returntype="any" hint="Get the instance of LogBox configured for this Injector" colddoc:generic="coldbox.system.logging.LogBox">
    	<cfreturn instance.logBox>
    </cffunction>

	<!--- Get Version --->
	<cffunction name="getVersion" access="public" returntype="any" output="false" hint="Get the Injector's version string.">
		<cfreturn instance.version>
	</cffunction>
	
	<!--- Get the binder config object --->
	<cffunction name="getBinder" access="public" returntype="any" output="false" hint="Get the Injector's configuration binder object" colddoc:generic="coldbox.system.ioc.config.Binder">
		<cfreturn instance.binder>
	</cffunction>
	
	<!--- getInjectorID --->
    <cffunction name="getInjectorID" output="false" access="public" returntype="any" hint="Get the unique ID of this injector">
    	<cfreturn instance.injectorID>
    </cffunction>
	
	<!--- getEventManager --->
    <cffunction name="getEventManager" output="false" access="public" returntype="any" hint="Get the injector's event manager">
 		<cfreturn instance.eventManager>
    </cffunction>

	<!--- getScopeRegistration --->
    <cffunction name="getScopeRegistration" output="false" access="public" returntype="any" hint="Get the structure of scope registration information" colddoc:generic="struct">
    	<cfreturn instance.binder.getScopeRegistration()>
    </cffunction>
	
	<!--- getScopeStorage --->
    <cffunction name="getScopeStorage" output="false" access="public" returntype="any" hint="Get the scope storage utility" colddoc:generic="coldbox.system.core.collections.ScopeStorage">
    	<cfreturn instance.scopeStorage>
    </cffunction>

	<!--- removeFromScope --->
    <cffunction name="removeFromScope" output="false" access="public" returntype="void" hint="Remove the Injector from scope registration if enabled, else does nothing">
    	<cfscript>
			var scopeInfo 		= instance.binder.getScopeRegistration();
			// if enabled remove.
			if( scopeInfo.enabled ){
				instance.scopeStorage.delete(scopeInfo.key, scopeInfo.scope);
			
				// Log info
				if( instance.log.canDebug() ){
					instance.log.debug("Injector removed from scope: #scopeInfo.toString()#");
				}
			}
		</cfscript>
    </cffunction>
	
	<!--- getScopes --->
    <cffunction name="getScopes" output="false" access="public" returntype="any" hint="Get all the registered scopes structure in this injector" colddoc:generic="struct">
    	<cfreturn instance.scopes>
    </cffunction>
	
	<!--- getScope --->
    <cffunction name="getScope" output="false" access="public" returntype="any" hint="Get a registered scope in this injector by name">
    	<cfargument name="scope" type="any" required="true" hint="The name of the scope"/>
		<cfreturn instance.scopes[ arguments.scope ]>
    </cffunction>
	
	<!--- clearSingletons --->
    <cffunction name="clearSingletons" output="false" access="public" returntype="any" hint="Clear the singleton cache">
    	<cfset instance.scopes["SINGLETON"].clear()>
    </cffunction>
	
	<!--- locateScopedSelf --->
    <cffunction name="locateScopedSelf" output="false" access="public" returntype="any" hint="Return a self reference using the scoped registration, mostly used by providers or scope widening objects" colddoc:generic="coldbox.system.ioc.Injector">
    	<cfscript>
    		var scopeInfo 	= instance.binder.getScopeRegistration();
			
			// Return if it exists, else throw exception
			if( instance.scopeStorage.exists(scopeInfo.key, scopeInfo.scope) ){
				return instance.scopeStorage.get(scopeInfo.key, scopeInfo.scope);
			}
			
			instance.utility.throwit(message="The injector has not be registered in any scope",detail="The scope info is: #scopeInfo.toString()#",type="Injector.InvalidScopeRegistration");	
		</cfscript>
    </cffunction>
	
<!----------------------------------------- PRIVATE ------------------------------------->	

	<!--- registerScopes --->
    <cffunction name="registerScopes" output="false" access="private" returntype="void" hint="Register all internal and configured WireBox Scopes">
    	<cfscript>
    		var customScopes 	= instance.binder.getCustomScopes();
    		var key				= "";
			
    		// register no_scope
			instance.scopes["NOSCOPE"] = createObject("component","coldbox.system.ioc.scopes.NoScope").init( this );
			// register singleton
			instance.scopes["SINGLETON"] = createObject("component","coldbox.system.ioc.scopes.Singleton").init( this );
			// is cachebox linked?
			if( isCacheBoxLinked() ){
				instance.scopes["CACHEBOX"] = createObject("component","coldbox.system.ioc.scopes.CacheBox").init( this );
			}
			// CF Scopes and references
			instance.scopes["REQUEST"] 	= createObject("component","coldbox.system.ioc.scopes.CFScopes").init( this );
			instance.scopes["SESSION"] 		= instance.scopes["REQUEST"];
			instance.scopes["SERVER"] 		= instance.scopes["REQUEST"];
			instance.scopes["APPLICATION"] 	= instance.scopes["REQUEST"];
			
			// Debugging
			if( instance.log.canDebug() ){
				instance.log.debug("Registered all internal lifecycle scopes successfully: #structKeyList(instance.scopes)#");
			}
			
			// Register Custom Scopes
			for(key in customScopes){
				instance.scopes[key] = createObject("component",customScopes[key]).init( this );
				// Debugging
				if( instance.log.canDebug() ){
					instance.log.debug("Registered custom scope: #key# (#customScopes[key]#)");
				}
			}			 
		</cfscript>
    </cffunction>
		
	<!--- registerListeners --->
    <cffunction name="registerListeners" output="false" access="private" returntype="void" hint="Register all the configured listeners in the configuration file">
    	<cfscript>
    		var listeners 	= instance.binder.getListeners();
			var regLen		= arrayLen(listeners);
			var x			= 1;
			var thisListener = "";
			
			// iterate and register listeners
			for(x=1; x lte regLen; x++){
				// try to create it
				try{
					// create it
					thisListener = createObject("component", listeners[x].class);
					// configure it
					thisListener.configure( this, listeners[x].properties);
				}
				catch(Any e){
					instance.log.error("Error creating listener: #listeners[x].toString()#", e);
					getUtil().throwit(message="Error creating listener: #listeners[x].toString()#",
									  detail="#e.message# #e.detail# #e.stackTrace#",
									  type="Injector.ListenerCreationException");
				}
				
				// Now register listener
				instance.eventManager.register(thisListener,listeners[x].name);
				
				// debugging
				if( instance.log.canDebug() ){
					instance.log.debug("Injector has just registered a new listener: #listeners[x].toString()#");
				}
			}			
		</cfscript>
    </cffunction>
	
	<!--- doScopeRegistration --->
    <cffunction name="doScopeRegistration" output="false" access="private" returntype="void" hint="Register this injector on a user specified scope">
    	<cfscript>
    		var scopeInfo 		= instance.binder.getScopeRegistration();
			
			// register injector with scope
			instance.scopeStorage.put(scopeInfo.key, this, scopeInfo.scope);
			
			// Log info
			if( instance.log.canDebug() ){
				instance.log.debug("Scope Registration enabled and Injector scoped to: #scopeInfo.toString()#");
			}
		</cfscript>
    </cffunction>
	
	<!--- configureCacheBox --->
    <cffunction name="configureCacheBox" output="false" access="private" returntype="void" hint="Configure a standalone version of cacheBox for persistence">
    	<cfargument name="config" required="true" hint="The cacheBox configuration data structure" colddoc:generic="struct"/>
    	<cfscript>
    		var args 	= structnew();
			var oConfig	= "";
			
			// is cachebox enabled?
			if( NOT arguments.config.enabled ){
				return;
			}
			
			// Do we have a cacheBox reference?
			if( isObject(arguments.config.cacheFactory) ){
				instance.cacheBox = arguments.config.cacheFactory;
				// debugging
				if( instance.log.canDebug() ){
					instance.log.debug("Configured Injector #getInjectorID()# with direct CacheBox instance: #instance.cacheBox.getFactoryID()#");
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
				instance.cacheBox = createObject("component","#arguments.config.classNamespace#.CacheFactory").init( oConfig );
				// debugging
				if( instance.log.canDebug() ){
					instance.log.debug("Configured Injector #getInjectorID()# with CacheBox instance: #instance.cacheBox.getFactoryID()# and configuration file: #arguments.config.configFile#");
				}
				return;
			}
			
			// No config file, plain vanilla cachebox
			instance.cacheBox = createObject("component","#arguments.config.classNamespace#.CacheFactory").init();
			// debugging
			if( instance.log.canDebug() ){
				instance.log.debug("Configured Injector #getInjectorID()# with vanilla CacheBox instance: #instance.cacheBox.getFactoryID()#");
			}						
		</cfscript>
    </cffunction>
	
	<!--- configureLogBox --->
    <cffunction name="configureLogBox" output="false" access="private" returntype="void" hint="Configure a standalone version of logBox for logging">
    	<cfargument name="configPath" required="true" hint="The logBox configuration path to use"/>
    	<cfscript>
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
			instance.logBox = createObject("component","coldbox.system.logging.LogBox").init( config );
			// Configure Logging for this injector
			instance.log = instance.logBox.getLogger( this );	
		</cfscript>
    </cffunction>
	
	<!--- configureEventManager --->
    <cffunction name="configureEventManager" output="false" access="private" returntype="void" hint="Configure a standalone version of a WireBox Event Manager">
    	<cfscript>
    		// create event manager
			instance.eventManager = createObject("component","coldbox.system.core.events.EventPoolManager").init( instance.eventStates );
			// Debugging
			if( instance.log.canDebug() ){
				instance.log.debug("Registered injector's event manager with the following event states: #instance.eventStates.toString()#");
			}
		</cfscript>
    </cffunction>
	
	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="public" output="false" returntype="any" hint="Return the core util object" colddoc:generic="coldbox.system.core.util.Util">
		<cfreturn instance.utility>
	</cffunction>
	
	<!--- buildBinder --->
    <cffunction name="buildBinder" output="false" access="private" returntype="any" hint="Load a configuration binder object according to passed in type">
    	<cfargument name="binder" 		required="true" hint="The data CFC configuration instance, instantiation path or programmatic binder object to configure this injector with"/>
		<cfargument name="properties" 	required="true" hint="A map of binding properties to passthrough to the Configuration CFC"/>
		<cfscript>
			var dataCFC = "";
			
			// Check if just a plain CFC path and build it
			if( isSimpleValue(arguments.binder) ){
				arguments.binder = createObject("component",arguments.binder);
			}
			
			// Check if data CFC or binder family
			if( NOT isInstanceOf(arguments.binder, "coldbox.system.ioc.config.Binder") ){
				// simple data cfc, create native binder and decorate data CFC
				nativeBinder = createObject("component","coldbox.system.ioc.config.Binder").init(injector=this,config=arguments.binder,properties=arguments.properties);
			}
			else{
				// else init the binder and configur it
				nativeBinder = arguments.binder.init(injector=this,properties=arguments.properties);
				// Configure it
				nativeBinder.configure();
				// Load it
				nativeBinder.loadDataDSL();
			}
			
			return nativeBinder;
		</cfscript>
    </cffunction>
	
</cfcomponent>