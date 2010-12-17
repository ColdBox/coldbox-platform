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
		<cfargument name="binder" 		type="any" 		required="false" default="coldbox.system.ioc.config.DefaultBinder" hint="The WireBox binder or data CFC instance or instantiation path to configure this injector with"/>
		<cfargument name="properties" 	type="struct" 	required="false" default="#structNew()#" hint="A structure of binding properties to passthrough to the Binder Configuration CFC"/>
		<cfargument name="coldbox" 		type="coldbox.system.web.Controller" required="false" hint="A coldbox application context that this instance of WireBox can be linked to, if not using it, we just ignore it."/>
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
					"afterInjectorConfiguration", 	// once injector is created and configured
					"beforeObjectCreation", 		// Before an injector creates an object, the mapping is passed.
					"afterObjectCreation", 			// once an object is created but not initialized via its constructor, the obj reference is passed
					"beforeObjectInitialized",		// before the constructor is called, the arguments that will be passed to the constructer are sent
					"afterObjectInitialized",		// once the constructor is called
					"afterDIComplete",				// after object is completely initialized and DI injections have ocurred
					"beforeMetadataInspection",		// before an object is inspected for injection metadata
					"afterMetadataInspection",		// after an object has been inspected and metadata is ready to be saved
					"onObjectException"				// traps when the injector throws controlled exceptions when building, injeting objects
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
			
			// Check if linking with ColdBox Application Context
			if( structKeyExists(arguments, "coldbox") ){ 
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
				instance.coldbox.getInterceptorService().appendInterceptionPoints( arrayToList(instance.eventStates) ); 
			}
			
			// Configure the injector for operation
			configure( arguments.binder, arguments.properties);
			
			return this;
		</cfscript>
	</cffunction>
				
	<!--- configure --->
	<cffunction name="configure" output="false" access="public" returntype="void" hint="Configure this injector for operation, called by the init(). You can also re-configure this injector programmatically, but it is not recommended.">
		<cfargument name="binder" 		type="any"		required="true" hint="The configuration binder object or path to configure this Injector instance with"/>
		<cfargument name="properties" 	type="struct" 	required="true" hint="A map of binding properties to passthrough to the Configuration CFC"/>
		<cfscript>
			var key 	= "";
			var iData	= {};
		</cfscript>
		
		<!--- Lock For Configuration --->
		<cflock name="#instance.lockName#" type="exclusive" timeout="30" throwontimeout="true">
			<cfscript>
			// Store binder object built accordingly to our binder building procedures
			instance.binder = buildBinder( arguments.binder, arguments.properties );
			
			// Create local cache, logging and event management if not coldbox context linked.
			if( NOT isColdBoxLinked() ){ 
				// Running standalone, so create our own logging first
				configureLogBox( instance.binder.getLogBoxConfig() );
				// Create local CacheBox reference
				configureCacheBox( instance.binder.getCacheBoxConfig() ); 
				// Create local event manager
				configureEventManager();
			}		
			
			// Register Life Cycle Scopes
			registerScopes();
			
			// Register DSLs
			// registerDSLs();
			
			// Register Listeners if not using ColdBox
			if( NOT isColdBoxLinked() ){
				registerListeners();
			}
			
			// Parent Injector declared
			if( isObject(instance.binder.getParentInjector()) ){
				setParent( instance.binder.getParentInjector() );
			}
			
			// Scope registration
			if( instance.binder.getScopeRegistration().enabled ){
				doScopeRegistration();
			}
			
			// Announce To Listeners we are online
			iData.injector = this;
			getEventManager().processState("afterInjectorConfiguration",iData);
			
			// Now create eager objects
			//createEagerMappings();	
			</cfscript>
		</cflock>
	</cffunction>
		
	<!--- containsMapping --->
    <cffunction name="containsMapping" output="false" access="public" returntype="boolean" hint="Checks if this container contains a specific object mapping or not">
    	<cfargument name="name" type="string" required="true" hint="The object name or alias to search for if this container has information about it"/>
		<cfreturn true>
    </cffunction>
	
	<!--- locateInstance --->
    <cffunction name="locateInstance" output="false" access="public" returntype="any" hint="Tries to locate a specific instance by name or alias">
    	
    </cffunction>
	
	<!--- getInstance --->
    <cffunction name="getInstance" output="false" access="public" returntype="any" hint="Locates, Creates, Injects and Configures an object instance">
    	<cfargument name="name" type="any" required="true" hint="The mapping name or alias to retrieve"/>
    </cffunction>

	<!--- autowire --->
    <cffunction name="autowire" output="false" access="public" returntype="any" hint="The main method that does the magical autowiring">
    	
    </cffunction>
	
	<!--- setParent --->
    <cffunction name="setParent" output="false" access="public" returntype="void" hint="Link a parent Injector with this injector">
    	<cfargument name="injector" type="any" required="true" hint="A WireBox Injector to assign as a parent to this Injector"/>
    	<cfset instance.parent = arguments.injector>
    </cffunction>
	
	<!--- hasParent --->
    <cffunction name="hasParent" output="false" access="public" returntype="boolean" hint="Checks if this Injector has a defined parent injector">
    	<cfreturn (isObject(instance.parent))>
    </cffunction>
	
	<!--- getParent --->
    <cffunction name="getParent" output="false" access="public" returntype="any" hint="Get a reference to the parent injector, else an empty string" colddoc:generic="coldbox.system.ioc.Injector">
    	<cfreturn instance.parent>
    </cffunction>
	
	<!--- getObjectPopulator --->
    <cffunction name="getObjectPopulator" output="false" access="public" returntype="coldbox.system.core.dynamic.BeanPopulator" hint="Get an object populator useful for populating objects from JSON,XML, etc.">
    	<cfreturn createObject("component","coldbox.system.core.dynamic.BeanPopulator").init()>
    </cffunction>
	
	<!--- getColdbox --->
    <cffunction name="getColdbox" output="false" access="public" returntype="coldbox.system.web.Controller" hint="Get the instance of ColdBox linked in this Injector. Empty if using standalone version">
    	<cfreturn instance.coldbox>
    </cffunction>
	
	<!--- isColdBoxLinked --->
    <cffunction name="isColdBoxLinked" output="false" access="public" returntype="boolean" hint="Checks if Coldbox application context is linked">
    	<cfreturn isObject(instance.coldbox)>
    </cffunction>
	
	<!--- getCacheBox --->
    <cffunction name="getCacheBox" output="false" access="public" returntype="any" hint="Get the instance of CacheBox linked in this Injector. Empty if using standalone version">
    	<cfreturn instance.cacheBox>
    </cffunction>
	
	<!--- isCacheBoxLinked --->
    <cffunction name="isCacheBoxLinked" output="false" access="public" returntype="boolean" hint="Checks if CacheBox is linked">
    	<cfreturn isObject(instance.cacheBox)>
    </cffunction>

	<!--- getLogBox --->
    <cffunction name="getLogBox" output="false" access="public" returntype="coldbox.system.logging.LogBox" hint="Get the instance of LogBox configured for this Injector">
    	<cfreturn instance.logBox>
    </cffunction>

	<!--- Get Version --->
	<cffunction name="getVersion" access="public" returntype="string" output="false" hint="Get the Injector's version string.">
		<cfreturn instance.version>
	</cffunction>
	
	<!--- Get the binder config object --->
	<cffunction name="getBinder" access="public" returntype="coldbox.system.ioc.config.Binder" output="false" hint="Get the Injector's configuration binder object">
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
    <cffunction name="getScopeRegistration" output="false" access="public" returntype="struct" hint="Get the scope registration information">
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
    		var customScopes 	= "";
    		var key				= "";
			
    		// register no_scope
			instance.scopes["NOSCOPE"] = createObject("component","coldbox.system.ioc.scopes.NoScope").init();
			instance.scopes["NOSCOPE"].configure(this);
			// register singleton
			instance.scopes["SINGLETON"] = createObject("component","coldbox.system.ioc.scopes.Singleton").init();
			instance.scopes["SINGLETON"].configure(this);
			// is cachebox linked?
			if( isCacheBoxLinked() ){
				instance.scopes["CACHEBOX"] = createObject("component","coldbox.system.ioc.scopes.CacheBox").init();
				instance.scopes["CACHEBOX"].configure(this);
			}
			// CF Scopes and references
			instance.scopes["REQUEST"] 	= createObject("component","coldbox.system.ioc.scopes.CFScopes").init();
			instance.scopes["REQUEST"].configure(this);
			instance.scopes["SESSION"] 		= instance.scopes["REQUEST"];
			instance.scopes["SERVER"] 		= instance.scopes["REQUEST"];
			instance.scopes["APPLICATION"] 	= instance.scopes["REQUEST"];
			
			// Debugging
			if( instance.log.canDebug() ){
				instance.log.debug("Registered all internal lifecycle scopes successfully: #structKeyList(instance.scopes)#");
			}
			
			// Custom Scopes
			customScopes = instance.binder.getCustomScopes();
			// register Custom Scopes
			for(key in customScopes){
				instance.scopes[key] = createObject("component",customScopes[key]).init();
				instance.scopes[key].configure(this);
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
				getEventManager().register(thisListener,listeners[x].name);
				
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
			var scopeStorage	= createObject("component","coldbox.system.core.collections.ScopeStorage").init();
			// register injector with scope
			scopeStorage.put(scopeInfo.key, this, scopeInfo.scope);
			// Log info
			if( instance.log.canDebug() ){
				instance.log.debug("Scope Registration enabled and Injector scoped to: #scopeInfo.toString()#");
			}
		</cfscript>
    </cffunction>
	
	<!--- configureCacheBox --->
    <cffunction name="configureCacheBox" output="false" access="private" returntype="void" hint="Configure a standalone version of cacheBox for persistence">
    	<cfargument name="config" type="struct" required="true" hint="The cacheBox configuration data structure"/>
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
    	<cfargument name="configPath" type="string" required="true" hint="The logBox configuration path to use"/>
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
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a core util object">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>
	
	<!--- buildBinder --->
    <cffunction name="buildBinder" output="false" access="private" returntype="any" hint="Load a configuration binder object according to passed in type">
    	<cfargument name="binder" 		type="any" 		required="true" hint="The data CFC configuration instance, instantiation path or programmatic binder object to configure this injector with"/>
		<cfargument name="properties" 	type="struct" 	required="true" hint="A map of binding properties to passthrough to the Configuration CFC"/>
		<cfscript>
			var dataCFC = "";
			
			// Check if just a plain CFC path and build it
			if( isSimpleValue(arguments.binder) ){
				arguments.binder = createObject("component",arguments.binder);
			}
			
			// Now decorate it with properties, a self reference, and a coldbox reference if needed.
			arguments.binder.injectPropertyMixin = instance.utility.getMixerUtil().injectPropertyMixin;
			arguments.binder.injectPropertyMixin("properties",arguments.properties,"instance");
			arguments.binder.injectPropertyMixin("wirebox",this);
			if( isColdBoxLinked() ){
				arguments.binder.injectPropertyMixin("coldbox",getColdBox());
			}
			
			// Check if already a programmatic binder object
			if( isInstanceOf(arguments.binder, "coldbox.system.ioc.config.Binder") ){
				// Configure it
				arguments.binder.configure();
				// use it
				return arguments.binder;
			}
			
			// If we get here, then it is a simple data CFC, decorate it with a vanilla binder object and configure it for operation
			return createObject("component","coldbox.system.ioc.config.Binder").init(arguments.binder);
		</cfscript>
    </cffunction>
	
</cfcomponent>