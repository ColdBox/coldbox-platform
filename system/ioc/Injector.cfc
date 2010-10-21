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
	file that can provide object/mappings.
	

----------------------------------------------------------------------->
<cfcomponent hint="A WireBox Injector: Builds the graphs of objects that make up your application." output="false" serializable="false">

<!----------------------------------------- CONSTRUCTOR ------------------------------------->			
		
	<!--- init --->
	<cffunction name="init" access="public" returntype="CacheFactory" hint="Constructor. If called with no configuration objects, then WireBox will instantiate the default configuration" output="false" >
		<cfargument name="config" 		type="any" 		required="false" default="coldbox.system.ioc.config.DefaultConfiguration" hint="The data CFC configuration instance or instantiation path or programmatic WireBoxConfig object to configure this injector with"/>
		<cfargument name="properties" 	type="struct" 	required="false" default="#structNew()#" hint="A map of binding properties to passthrough to the Configuration CFC"/>
		<cfargument name="coldbox" 		type="coldbox.system.web.Controller" required="false" hint="A coldbox application that this instance of CacheBox can be linked to, if not using it, just ignore it."/>
		<cfscript>
			// Available public scopes
			this.SCOPES = createObject("component","coldbox.system.ioc.Scopes");
			// Available public types
			this.TYPES = createObject("component","coldbox.system.ioc.Types");
		
			// Prepare Injector
			instance = {
				// WireBox Injector UniqueID
				injectorID = createObject('java','java.lang.System').identityHashCode(this),	
				// Version
				version = "1.0.0",	 
				// Configuration object
				config  = "",
				// ColdBox Application Link
				coldbox = "",
				// Event Manager Link
				eventManager = "",
				// Configured Event States
				eventStates = [
					"afterInjectorConfiguration", 	// once injector is created and configured
					"beforeObjectCreation", 	// Before an injector creates the object, the configuration data is passed here.
					"afterObjectCreation", 		// once an object is created but not initialized via its constructor, the obj reference is passed
					"beforeObjectInitialized",	// before the constructor is called, the arguments that will be passed to the constructer are sent
					"afterObjectInitialized",	// once the constructor is called
					"afterDIComplete",			// after object is completely initialized and DI injections have ocurred
					"beforeMetadataInspection",	// before an object is inspected for injection metadata
					"afterMetadataInspection",	// after an object has been inspected and metadata is ready to be saved
					"onObjectException"			// traps when the injector throws controlled exceptions when building, injeting objects
				],
				// LogBox and Class Logger
				logBox  = "",
				log		= "",
				// Singleton Cache
				singletons = structnew(),
				// Parent Injector
				parent = "",
				// Utility class
				utility  = createObject("component","coldbox.system.core.util.Util")
			};
			
			// Prepare Lock Info
			instance.lockName = "WireBox.Injector.#instance.injectorID#";
			
			// Check if linking ColdBox
			if( structKeyExists(arguments, "coldbox") ){ 
				instance.coldbox = arguments.coldbox;
				// link LogBox
				instance.logBox  = instance.coldbox.getLogBox();
				// Link CacheBox
				instance.cacheBox = instance.coldbox.getCacheBox();
				// Link Event Manager
				instance.eventManager = instance.coldbox.getInterceptorService();
				// Link Interception States
				instance.coldbox.getInterceptorService().appendInterceptionPoints( arrayToList(instance.eventStates) ); 
			}
			
			// Configure the injector
			configure( arguments.config, arguments.properties);
			
			return this;
		</cfscript>
	</cffunction>
				
	<!--- configure --->
	<cffunction name="configure" output="false" access="public" returntype="void" hint="Configure this injector for operation, called by the init(). You can also re-configure this injector programmatically, but it is not recommended.">
		<cfargument name="config" 		type="any"		required="true" hint="The configuration object or path to configure this Injector instance with"/>
		<cfargument name="properties" 	type="struct" 	required="true" hint="A map of binding properties to passthrough to the Configuration CFC"/>
		<cfscript>
			var key 	= "";
			var iData	= {};
		</cfscript>
		
		<cflock name="#instance.lockName#" type="exclusive" timeout="30" throwontimeout="true">
			<cfscript>
			// Store config object built accordingly
			instance.config = buildConfiguration( arguments.config, arguments.properties );
			
			// Validate configuration
			instance.config.validate();
			
			// Create local cache, logging and event management if not coldbox linked.
			if( NOT isColdBoxLinked() ){ 
				// Running standalone, so create our own logging first
				configureLogBox( instance.config.getLogBoxConfig() );
				// Create local CacheBox reference
				configureCacheBox( instance.config.getCacheBoxConfig() ); 
				// Create local event manager
				configureEventManager();
			}
			
			// Configure Logging for this injector
			instance.log = getLogBox().getLogger( this );
			
			// Reset Registries
			instance.singletons = {};
			
			// Register Listeners if not using ColdBox
			if( NOT isColdBoxLinked() ){
				registerListeners();
			}
			
			// Parent Injector declared
			if( isObject(config.getParent()) ){
				setParent( config.getParent() );
			}
			
			// Register Scan Locations
			
			// Register Mappings
			
			// Scope registration
			if( instance.config.getScopeRegistration().enabled ){
				doScopeRegistration();
			}
			
			// Announce To Listeners
			iData.injector = this;
			getEventManager().processState("afterInjectorConfiguration",iData);	
			</cfscript>
		</cflock>
	</cffunction>
	
	<!--- removeFromScope --->
    <cffunction name="removeFromScope" output="false" access="public" returntype="void" hint="Remove the Injector from scope registration if enabled, else does nothing">
    	<cfscript>
			var scopeInfo 		= instance.config.getScopeRegistration();
			var scopeStorage	= "";
			
			if( scopeInfo.enabled ){
				scopeStorage = createObject("component","coldbox.system.core.collections.ScopeStorage").init();
				scopeStorage.delete(scopeInfo.key, scopeInfo.scope);
			}
		</cfscript>
    </cffunction>
	
	<!--- contains --->
    <cffunction name="contains" output="false" access="public" returntype="boolean" hint="Checks if this container contains a specific object mapping or not">
    	<cfargument name="name" type="string" required="true" hint="The object name or alias to search for if this container has information about it"/>
    </cffunction>
	
	<!--- locateInstance --->
    <cffunction name="locateInstance" output="false" access="public" returntype="any" hint="Tries to locate a specific instance by name or alias">
    	
    </cffunction>
	
	<!--- getInstance --->
    <cffunction name="getInstance" output="false" access="public" returntype="any" hint="Locates, Creates, Injects and Configures an object instance">
    	
    </cffunction>

	<!--- autowire --->
    <cffunction name="autowire" output="false" access="public" returntype="any" hint="The main method that does the magical autowiring">
    	
    </cffunction>
	
	<!--- setParent --->
    <cffunction name="setParent" output="false" access="public" returntype="void" hint="Link a parent Injector with this injector">
    	<cfargument name="injector" type="any" required="true" hint="A WireBox Injector to assign as a parent to this Injector"/>
    	<cfset instance.parent = arguments.injector>
    </cffunction>
	
	<!--- getParent --->
    <cffunction name="getParent" output="false" access="public" returntype="any" hint="Get a reference to the parent injector, else an empty string" colddoc:generic="coldbox.system.ioc.Injector">
    	<cfreturn instance.parent>
    </cffunction>
	
	<!--- getPopulator --->
    <cffunction name="getPopulator" output="false" access="public" returntype="coldbox.system.core.dynamic.BeanPopulator" hint="Get an object populator useful for populating objects from JSON,XML, etc.">
    	<cfreturn createObject("component","coldbox.system.core.dynamic.BeanPopulator").init()>
    </cffunction>
	
	<!--- getSingletons --->
    <cffunction name="getSingletons" output="false" access="public" returntype="any" hint="Get a collection of all the objects in the singleton cache">
    	<cfreturn instance.singletons>
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
	
	<!--- Get the config object --->
	<cffunction name="getConfig" access="public" returntype="coldbox.system.ioc.config.WireBoxConfig" output="false" hint="Get the Injector's configuration object">
		<cfreturn instance.config>
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
    	<cfreturn instance.config.getScopeRegistration()>
    </cffunction>

<!----------------------------------------- PRIVATE ------------------------------------->	

	<!--- registerListeners --->
    <cffunction name="registerListeners" output="false" access="private" returntype="void" hint="Register all the configured listeners in the configuration file">
    	<cfscript>
    		var listeners 	= instance.config.getListeners();
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
					getUtil().throwit(message="Error creating listener: #listeners[x].toString()#",
									  detail="#e.message# #e.detail# #e.stackTrace#",
									  type="Injector.ListenerCreationException");
				}
				
				// Now register listener
				getEventManager().register(thisListener,listeners[x].name);
			}			
		</cfscript>
    </cffunction>
	
	<!--- doScopeRegistration --->
    <cffunction name="doScopeRegistration" output="false" access="private" returntype="void" hint="Register this injector on a user specified scope">
    	<cfscript>
    		var scopeInfo 		= instance.config.getScopeRegistration();
			var scopeStorage	= createObject("component","coldbox.system.core.collections.ScopeStorage").init();
			// register injector with scope
			scopeStorage.put(scopeInfo.key, this, scopeInfo.scope);
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
			
			// Do we have a configuration file?
			if( len(arguments.config.configFile) ){
				// xml?
				if( listFindNoCase("xml,cfm", listLast(arguments.configPath,".") ) ){
					args["XMLConfig"] = arguments.configPath;
				}
				else{
					// cfc
					args["CFCConfigPath"] = arguments.configPath;
				}
				
				// Create CacheBox
				oConfig = createObject("component","#arguments.config.classNamespace#.config.CacheBoxConfig").init(argumentCollection=args);
				instance.cacheBox = createObject("component","#arguments.config.classNamespace#.CacheFactory").init( config );
				return;
			}
			
			// Do we have a cacheBox reference?
			if( isObject(arguments.config.cacheFactory) ){
				instance.cacheBox = arguments.config.cacheFactory;
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
		</cfscript>
    </cffunction>
	
	<!--- configureEventManager --->
    <cffunction name="configureEventManager" output="false" access="private" returntype="void" hint="Configure a standalone version of a WireBox Event Manager">
    	<cfscript>
    		// create event manager
			instance.eventManager = createObject("component","coldbox.system.core.events.EventPoolManager").init( instance.eventStates );
		</cfscript>
    </cffunction>
	
	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a core util object">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>
	
	<!--- buildConfiguration --->
    <cffunction name="buildConfiguration" output="false" access="private" returntype="any" hint="Load a configuration object according to passed in config type">
    	<cfargument name="config" 		type="any" 		required="true" hint="The data CFC configuration instance or instantiation path or programmatic WireBoxConfig object to configure this injector with"/>
		<cfargument name="properties" 	type="struct" 	required="true" hint="A map of binding properties to passthrough to the Configuration CFC"/>
		<cfscript>
			var dataCFC = "";
			
			// Check if just a plain CFC path and build it
			if( isSimpleValue(arguments.config) ){
				arguments.config = createObject("component",arguments.config);
			}
			
			// Now decorate it with properties, a self reference, and a coldbox reference if needed.
			arguments.config.injectPropertyMixin = instance.utility.injectPropertyMixin;
			arguments.config.injectPropertyMixin("properties",arguments.properties,"instance");
			arguments.config.injectPropertyMixin("wirebox",this);
			if( isColdBoxLinked() ){
				arguments.config.injectPropertyMixin("coldbox",getColdBox());
			}
			
			// Check if already a programmatic config object
			if( isInstanceOf(arguments.config, "coldbox.system.ioc.config.WireBoxConfig") ){
				// Configure it
				arguments.config.configure();
				return arguments.config;
			}
			
			// If we get here, then it is a simple CFC, decorate it with a vanilla config object and configure
			return createObject("component","coldbox.system.ioc.config.WireBoxConfig").init(arguments.config);
		</cfscript>
    </cffunction>
	
</cfcomponent>