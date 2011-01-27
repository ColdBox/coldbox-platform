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
		<cfargument name="coldbox" 		required="false" hint="A coldbox application context that this instance of WireBox can be linked to, if not using it, we just ignore it." colddoc:generic="coldbox.system.web.Controller">
		<cfscript>
			// Setup Available public scopes
			this.SCOPES = createObject("component","coldbox.system.ioc.Scopes");
			// Setup Available public types
			this.TYPES = createObject("component","coldbox.system.ioc.Types");
		
			// Prepare Injector instance
			instance = {
				// Java System
				javaSystem = createObject('java','java.lang.System'),	
				// Utility class
				utility  = createObject("component","coldbox.system.core.util.Util"),
				// Method Invoker
				invoker	 = createObject("component","coldbox.system.core.dynamic.MethodInvoker").init(),
				// Version
				version  = "1.0.0",	 
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
					"beforeInstanceCreation", 		// Before an injector creates or is requested an instance of an object, the mapping is passed.
					"afterInstanceInitialized",		// once the constructor is called and before DI is performed
					"afterInstanceCreation", 		// once an object is created, initialized and done with DI
					"beforeInstanceInspection",		// X before an object is inspected for injection metadata
					"afterInstanceInspection"		// X after an object has been inspected and metadata is ready to be saved
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
				// Link ColdBox
				instance.coldbox = arguments.coldbox;
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
			
			// Register Life Cycle Scopes
			registerScopes();
			
			// TODO: Register DSLs
			// registerDSLs();
		
			// Parent Injector declared
			if( isObject(instance.binder.getParentInjector()) ){
				setParent( instance.binder.getParentInjector() );
			}
			
			// Scope registration if enabled?
			if( instance.binder.getScopeRegistration().enabled ){
				doScopeRegistration();
			}
			
			// Announce To Listeners we are online
			iData.injector = this;
			instance.eventManager.processState("afterInjectorConfiguration",iData);
			
			// Create Eager Objects
			//createEagerMappings();	
			</cfscript>
		</cflock>
	</cffunction>
	
	<!--- getInstance --->
    <cffunction name="getInstance" output="false" access="public" returntype="any" hint="Locates, Creates, Injects and Configures an object model instance">
    	<cfargument name="name" 			required="true" 	hint="The mapping name or CFC instance path to try to build up"/>
		<cfargument name="dsl"				required="false" 	hint="The dsl string to use to retrieve the instance model object, mutually exclusive with 'name'"/>
		<cfargument name="initArguments" 	required="false" 	hint="The constructor structure of arguments to passthrough when initializing the instance" colddoc:generic="struct"/>
		<cfscript>
			var instancePath 	= "";
			var mapping 		= "";
			var target			= "";
			var iData			= {};
			
			// Get by DSL?
			if( structKeyExists(arguments,"dsl") ){
				// TODO: Get by DSL
			}
			
			// Check if Mapping Exists?
			if( NOT instance.binder.mappingExists(arguments.name) ){
				// No Mapping exists, let's try to locate it first. We are now dealing with request by conventions
				// This is done once per instance request as then mappings are cached
				instancePath = locateInstance(arguments.name);
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
				// announce inspection
				iData = {mapping=mapping,binder=instance.binder};
				instance.eventManager.process("beforeInstanceInspection",iData);
				// process inspection of instance
				mapping.process( instance.binder );
				// announce it 
				instance.eventManager.process("afterInstanceInspection",iData);
			}
			
			// scope persistence check
			if( NOT structKeyExists(instance.scopes, mapping.getScope()) ){
				instance.log.error("The mapping scope: #mapping.getScope()# is invalid and not registered in the valid scopes: #structKeyList(instance.scopes)#");
				getUtil().throwit(message="Requested mapping scope: #mapping.getScope()# is invalid",
								  detail="The registered valid object scopes are #structKeyList(instance.scopes)#",
								  type="Injector.InvalidScopeException");
			}
			
			// Request object from scope now, we now have it from scope
			target = instance.scopes[ mapping.getScope() ].getFromScope( mapping );
			
			// Announce creation, initialization and DI magicfinicitation!
			iData = {mapping=arguments.mapping,target=target};
			instance.eventManager.process("afterInstanceCreation",iData);
			
			return target;
		</cfscript>
    </cffunction>
	
	<!--- constructInstance --->
    <cffunction name="constructInstance" output="false" access="public" returntype="any" hint="Construct an instance, this is called from registered scopes only as they provide locking and transactions">
    	<cfargument name="mapping" required="true" hint="The mapping to construct" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfscript>
    		var thisMap = arguments.mapping;
			var oModel	= "";
			var iData	= "";
			
			// before construction event
			iData = {mapping=arguments.mapping};
			instance.eventManager.process("beforeInstanceCreation",iData);
			
    		// determine construction type
    		switch( thisMap.getType() ){
				case "cfc" : {
					oModel = buildCFC( thisMap ); break;
				}
				case "java" : {
					oModel = buildJavaClass( thisMap ); break;
				}
				case "webservice" : {
					oModel = createObject("webservice", thisMap.getPath() ); break;
				}
				case "constant" : {
					oModel = thisMap.getValue(); break;
				}
				case "rss" : {
					oModel = buildFeed(thisMap.getPath()); break;
				}
				case "dsl" : {
					oModel = getDSLDependency(thisMap.getDSL()); break;
				}
				default: { getUtil().throwit(message="Invalid Construction Type: #thisMap.getType()#",type="Injector.InvalidConstructionType"); }
			}		
			
			// announce afterInstanceInitialized
			iData = {mapping=arguments.mapping,target=oModel};
			instance.eventManager.process("afterInstanceInitialized",iData);
			
			return oModel;
		</cfscript>
    </cffunction>
	
	<!--- buildCFC --->
    <cffunction name="buildCFC" output="false" access="private" returntype="any" hint="Build a cfc class via mappings">
    	<cfargument name="mapping" 	required="true" hint="The mapping to construct" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfscript>
			var thisMap = arguments.mapping;
			var oModel 	= createObject("component", thisMap.getPath() );
			
			// Constructor initialization?
			if( thisMap.isAutoInit() ){
				// init this puppy
				instance.invoker.invokeMethod(oModel,thisMap.getConstructor(),buildConstructorArguments(thisMap));
			}
			
			return oModel;
		</cfscript>
    </cffunction>
	
	<!--- buildJavaClass --->
    <cffunction name="buildJavaClass" output="false" access="private" returntype="any" hint="Build a Java class via mappings">
    	<cfargument name="mapping" 	required="true" hint="The mapping to construct" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfscript>
			var x 			= 1;
			var DIArgs 		= arguments.mapping.getDIConstructorArguments();
			var DIArgsLen 	= arrayLen(DIArgs);
			var args		= [];

			// Loop Over Arguments
			for(x = 1; x <= DIArgsLen; x++){
				// do we have javacasting?
				if( len(DIArgs[x].javaCast) ){
					ArrayAppend(args, "javaCast(DIArgs[#x#].javaCast, DIArgs[#x#].value)");
				}	
				else{
					ArrayAppend(args, "DIArgs[#x#].value");
				}
			}

			return evaluate('createObject("java",arguments.mapping.getPath()).init(#arrayToList(args)#)');
		</cfscript>
    </cffunction>
	
	<!--- buildConstructorArguments --->
    <cffunction name="buildConstructorArguments" output="false" access="private" returntype="any" hint="Build constructor arguments for a mapping and return the structure representation">
    	<cfargument name="mapping" 	required="true" hint="The mapping to construct" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfscript>
			var x 			= 1;
			var thisMap 	= arguments.mapping;
			var DIArgs 		= arguments.mapping.getDIConstructorArguments();
			var DIArgsLen 	= arrayLen(DIArgs);
			var args		= structnew();

			// Loop Over Arguments
			for(x=1;x lte DIArgsLen; x=x+1){
				
				// Is value set in mapping? If so, add it and continue
				if( NOT isSimpleValue(DIArgs[x].value) OR len(DIArgs[x].value) ){
					args[ DIArgs[x].name ] = DIArgs[x].value;
					continue;
				}
				
				// Is it by DSL construction? If so, add it and continue, if not found it returns null, which is ok
				if( len(DIArgs[x].dsl) ){
					args[ DIArgs[x].name ] = getDSLDependency( DIArgs[x].dsl );
				}
				
				// If we get here then it is by ref id, so let's verify it exists and optional
				if( len(containsInstance( DIArgs[x].ref )) ){
					args[ DIArgs[x].name ] = getInstance( DIArgs[x].ref );
				}
				else if( DIArgs[x].required ){
					// not found but required, then throw exception
					getUtil().throwIt(message="Constructor argument reference not located: #DIArgs[x].name#",
									  detail="Injecting: #thisMap.getMemento().toString()#. The constructor argument details are: #DIArgs[x].toString()#.",
									  type="Injector.ConstructorArgumentNotFoundException");
					instance.log.error("Constructor argument reference not located: #DIArgs[x].name# for mapping: #arguments.mapping.getMemento().toString()#", DIArgs[x]);
				}
				// else just log it via debug
				else if( instance.log.canDebug() ){
					instance.log.debug("Constructor argument reference not located: #DIArgs[x].name# for mapping: #arguments.mapping.getMemento().toString()#", DIArgs[x]);
				}
				
			}

			return args;
		</cfscript>
    </cffunction>
	
	<!--- buildFeed --->
    <cffunction name="buildFeed" output="false" access="private" returntype="any" hint="Build an rss feed the WireBox way">
    	<cfargument name="source" type="any" required="true" hint="The feed source to read"/>
    	<cfset var results = {}>
		
    	<cffeed action="read" source="#arguments.source#" query="results.items" properties="results.metadata">
    	
		<cfreturn results>
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
			// NADA!
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
    <cffunction name="autowire" output="false" access="public" returntype="any" hint="The main method that does the magical autowiring">
    	<cfargument name="target" 			required="true" 	hint="The target object to wire up"/>
		<cfargument name="targetID" 		required="false" 	hint="A unique identifier for this target to wire up. Usually a class path or file path should do. If none is passed we will get the id from the passed target via introspection but it will slow down the wiring"/>
    	<cfscript>
			// Targets
			var targetObject 	= arguments.target;
			var targetCacheKey 	= arguments.targetID;
			var metaData 		= "";
			
			// Dependencies
			var thisDependency = instance.NOT_FOUND;

			// Metadata entry structures
			var mdEntry 			= "";
			var targetDIEntry 		= "";
			var dependenciesLength 	= 0;
			var x 					= 1;
			var tmpBean 			= "";	
			
			// do we have a targetCache Key?
			if( NOT len(targetCacheKey) ){
				// Not sent, so get metadata, cache it and build cache id
				metadata 		= getMetadata(targetObject);
				targetCacheKey 	= metadata.name;
				instance.autowireCache[targetCacheKey] = metadata;
			}	
			// is md cached for target?
			else if( NOT structKeyExists(instance.autowireCache, targetCacheKey) ){
				metadata = getMetadata(targetObject);
				instance.autowireCache[targetCacheKey] = metadata;
			}
			else{
				// Get metadata for autowire target
				metadata = instance.autowireCache[targetCacheKey];
			}
		</cfscript>

		<!--- Do we have the incoming target object's data in the cache? or caching disabled for objects --->
		<cfif NOT instance.DICacheDictionary.keyExists(targetCacheKey) OR NOT instance.modelsObjectCaching>
			<cflock type="exclusive" name="plugins.autowire.#targetCacheKey#" timeout="30" throwontimeout="true">
				<cfscript>
					if ( not instance.DICacheDictionary.keyExists(targetCacheKey) ){
						// Get Empty Default MD Entry, default autowire = false
						mdEntry = getNewMDEntry();

						// Annotation Checks
						if( arguments.annotationCheck eq false){
							mdEntry.autowire = true;
						}
						else if ( structKeyExists(metaData,"autowire") and isBoolean(metaData["autowire"]) ){
							mdEntry.autowire = metaData.autowire;
						}

						// Lookup Dependencies if using autowire and not a ColdBox core object
						if ( mdEntry.autowire and findNoCase("coldbox.system",metaData.name) EQ 0 ){
							// Recurse for dependencies here, in order to build them
							mdEntry.dependencies = parseMetadata(metaData,mdEntry.dependencies,arguments.useSetterInjection,arguments.stopRecursion);
						}

						// Set Entry in dictionary
						instance.DICacheDictionary.setKey(targetCacheKey,mdEntry);
					}
				</cfscript>
			</cflock>
		</cfif>

		<cfscript>
		// We are now assured that the DI cache has data.
		targetDIEntry = instance.DICacheDictionary.getKey(targetCacheKey);

		// Do we Inject Dependencies, are we AutoWiring
		if ( targetDIEntry.autowire ){

			// Bean Factory Awareness
			if( structKeyExists(targetObject,"setBeanFactory") ){
				targetObject.setBeanFactory( this );
			}

			// ColdBox Context Awareness
			if( structKeyExists(targetObject,"setColdBox") ){
				targetObject.setColdBox( controller );
			}

			// Dependencies Length
			dependenciesLength = arrayLen(targetDIEntry.dependencies);
			if( dependenciesLength gt 0 ){
				// Let's inject our mixins
				instance.mixerUtil.start(targetObject);

				// Loop over dependencies and inject
				for(x=1; x lte dependenciesLength; x=x+1){
					// Get Dependency
					thisDependency = getDSLDependency(definition=targetDIEntry.dependencies[x]);

					// Was dependency Found?
					if( isSimpleValue(thisDependency) and thisDependency eq instance.NOT_FOUND ){
						if( log.canDebug() ){
							log.debug("Dependency: #targetDIEntry.dependencies[x].toString()# Not Found when wiring #getMetadata(arguments.target).name#");
						}
						continue;
					}

					// Inject dependency
					injectBean(targetBean=targetObject,
							   beanName=targetDIEntry.dependencies[x].name,
							   beanObject=thisDependency,
							   scope=targetDIEntry.dependencies[x].scope);

					if( log.canDebug() ){
						log.debug("Dependency: #targetDIEntry.dependencies[x].toString()# --> injected into #getMetadata(targetObject).name#.");
					}
				}//end for loop of dependencies.

				// Process After ID Complete
				processAfterCompleteDI(targetObject,onDICompleteUDF);

			}// if dependencies found.
		}//if autowiring
	</cfscript>
    </cffunction>
	
	<!--- setParent --->
    <cffunction name="setParent" output="false" access="public" returntype="void" hint="Link a parent Injector with this injector">
    	<cfargument name="injector" required="true" hint="A WireBox Injector to assign as a parent to this Injector" colddoc:generic="coldbox.system.ioc.Injector">
    	<cfset instance.parent = arguments.injector>
    </cffunction>
	
	<!--- hasParent --->
    <cffunction name="hasParent" output="false" access="public" returntype="any" hint="Checks if this Injector has a defined parent injector" colddoc:generic="boolean">
    	<cfreturn (isObject(instance.parent))>
    </cffunction>
	
	<!--- getParent --->
    <cffunction name="getParent" output="false" access="public" returntype="any" hint="Get a reference to the parent injector, else an empty string" colddoc:generic="coldbox.system.ioc.Injector">
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

	<!--- removeFromScope --->
    <cffunction name="removeFromScope" output="false" access="public" returntype="void" hint="Remove the Injector from scope registration if enabled, else does nothing">
    	<cfscript>
			var scopeInfo 		= instance.binder.getScopeRegistration();
			// if enabled remove.
			if( scopeInfo.enabled ){
				createObject("component","coldbox.system.core.collections.ScopeStorage")
					.init()
					.delete(scopeInfo.key, scopeInfo.scope);
			}
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
			createObject("component","coldbox.system.core.collections.ScopeStorage").init().put(scopeInfo.key, this, scopeInfo.scope);
			
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
	<cffunction name="getUtil" access="private" output="false" returntype="any" hint="Create and return a core util object" colddoc:generic="coldbox.system.core.util.Util">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
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
			
			// Now decorate it with properties, a self reference, and a coldbox reference if needed.
			arguments.binder.injectPropertyMixin = instance.utility.getMixerUtil().injectPropertyMixin;
			arguments.binder.injectPropertyMixin("properties",arguments.properties,"instance");
			arguments.binder.injectPropertyMixin("injector",this);
			if( isColdBoxLinked() ){
				arguments.binder.injectPropertyMixin("coldbox",getColdBox());
			}
			
			// Check if already a programmatic binder object?
			if( isInstanceOf(arguments.binder, "coldbox.system.ioc.config.Binder") ){
				// Configure it
				arguments.binder.configure();
				// Load it
				arguments.binder.loadDataDSL();
				// Use it
				return arguments.binder;
			}
			
			// If we get here, then it is a simple data CFC, decorate it with a vanilla binder object and configure it for operation
			return createObject("component","coldbox.system.ioc.config.Binder").init(arguments.binder);
		</cfscript>
    </cffunction>
	
</cfcomponent>