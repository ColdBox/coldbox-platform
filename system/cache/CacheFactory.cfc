<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The main CacheBox factory and configuration of caches. From this factory
	is where you will get all the caches you need to work with or register more caches.

----------------------------------------------------------------------->
<cfcomponent hint="The ColdBox CacheBox Factory" output="false" serializable="false">

<!----------------------------------------- CONSTRUCTOR ------------------------------------->			
		
	<!--- init --->
	<cffunction name="init" access="public" returntype="CacheFactory" hint="Constructor" output="false" >
		<cfargument name="config"  		required="false" hint="The CacheBoxConfig object to use to configure this instance of CacheBox. If not passed then CacheBox will instantiate the default configuration." colddoc:generic="coldbox.system.cache.config.CacheBoxConfig"/>
		<cfargument name="coldbox" 		required="false" hint="A coldbox application that this instance of CacheBox can be linked to, if not using it, just ignore it." colddoc:generic="coldbox.system.web.Controller"/>
		<cfargument name="factoryID" 	required="false" default="" hint="A unique ID or name for this factory. If not passed I will make one up for you."/>
		<cfscript>
			var defaultConfigPath = "coldbox.system.cache.config.DefaultConfiguration";
			
			// Prepare factory instance
			instance = {
				// CacheBox Factory UniqueID
				factoryID = createObject('java','java.lang.System').identityHashCode(this),	
				// Version
				version = "1.2.0",	 
				// Configuration object
				config  = "",
				// ColdBox Application Link
				coldbox = "",
				// Event Manager Link
				eventManager = "",
				// Configured Event States
				eventStates = [
					"afterCacheElementInsert",
					"afterCacheElementRemoved",
					"afterCacheElementExpired",
					"afterCacheElementUpdated",
					"afterCacheClearAll",
					"afterCacheRegistration",
					"afterCacheRemoval", 
					"beforeCacheRemoval",
					"beforeCacheReplacement", 
					"afterCacheFactoryConfiguration", 
					"beforeCacheFactoryShutdown", 
					"afterCacheFactoryShutdown",
					"beforeCacheShutdown",
					"afterCacheShutdown"
				],
				// LogBox Links
				logBox  = "",
				log		= "",
				// Caches
				caches  = {}
			};
			
			// Did we send a factoryID in?
			if( len(arguments.factoryID) ){
				instance.factoryID = arguments.factoryID;
			}
			
			// Prepare Lock Info
			instance.lockName = "CacheFactory.#instance.factoryID#";
			
			// Check if linking ColdBox
			if( structKeyExists(arguments, "coldbox") ){ 
				// Link ColdBox
				instance.coldbox = arguments.coldbox;
				// link LogBox
				instance.logBox  = instance.coldbox.getLogBox();
				// Link Event Manager
				instance.eventManager = instance.coldbox.getInterceptorService();
				// Link Interception States
				instance.coldbox.getInterceptorService().appendInterceptionPoints( arrayToList(instance.eventStates) ); 
			}
			else{
				// Running standalone, so create our own logging first
				configureLogBox();
				// Running standalone, so create our own event manager
				configureEventManager();
			}
			
			// Passed in configuration?
			if( NOT structKeyExists(arguments,"config") ){
				// Create default configuration
				arguments.config = createObject("component","coldbox.system.cache.config.CacheBoxConfig").init(CFCConfigPath=defaultConfigPath);
			}
			
			// Configure Logging for the Cache Factory
			instance.log = instance.logBox.getLogger( this );
			
			// Configure the Cache Factory
			configure( arguments.config );
			
			return this;
		</cfscript>
	</cffunction>
	
		
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
									  type="CacheBox.ListenerCreationException");
				}
				
				// Now register listener
				instance.eventManager.register(thisListener,listeners[x].name);
				
			}			
		</cfscript>
    </cffunction>
	
	<!--- configure --->
	<cffunction name="configure" output="false" access="public" returntype="void" hint="Configure the cache factory for operation, called by the init(). You can also re-configure CacheBox programmatically.">
		<cfargument name="config" required="true" hint="The CacheBoxConfig object to use to configure this instance of CacheBox" colddoc:generic="coldbox.system.cache.config.CacheBoxConfig"/>
		<cfscript>
			var defaultCacheConfig = "";
			var caches 	= "";
			var key 	= "";
			var iData	= {};
		</cfscript>
		
		<cflock name="#instance.lockName#" type="exclusive" timeout="30" throwontimeout="true">
			<cfscript>
			// Store config object
			instance.config = arguments.config;
			// Validate configuration
			instance.config.validate();
			// Reset Registries
			instance.caches = {};
			
			// Register Listeners if not using ColdBox
			if( not isObject(instance.coldbox) ){
				registerListeners();
			}
			
			// Register default cache first
			defaultCacheConfig = instance.config.getDefaultCache();
			createCache(name="default",provider=defaultCacheConfig.provider,properties=defaultCacheConfig);
			
			// Register named caches
			caches = instance.config.getCaches();
			for(key in caches){
				createCache(name=key,provider=caches[key].provider,properties=caches[key].properties);
			}		
			
			// Scope registrations
			if( instance.config.getScopeRegistration().enabled ){
				doScopeRegistration();
			}
			
			// Announce To Listeners
			iData.cacheFactory = this;
			instance.eventManager.processState("afterCacheFactoryConfiguration",iData);	
			</cfscript>
		</cflock>
	</cffunction>
	
<!------------------------------------------- PUBLIC CACHE FACTORY OPERATIONS ------------------------------------------>

	<!--- getCache --->
    <cffunction name="getCache" output="false" access="public" returntype="any" hint="Get a reference to a registered cache in this factory.  If the cache does not exist it will return an exception. Type: coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider">
    	<cfargument name="name" required="true" hint="The named cache to retrieve"/>
		
		<cflock name="#instance.lockName#" type="readonly" timeout="20" throwontimeout="true">
			<cfif structKeyExists(instance.caches, arguments.name)>
				<cfreturn instance.caches[ arguments.name ]>
			</cfif>
			<!--- Not Found --->
			<cfthrow message="Cache #arguments.name# is not registered." detail="Valid cache names are #structKeyList(instance.caches)#" type="CacheFactory.CacheNotFoundException">
		</cflock>
		
    </cffunction>
	
	<!--- addCache --->
    <cffunction name="addCache" output="false" access="public" returntype="void" hint="Register a new instantiated cache with this cache factory">
    	<cfargument name="cache" required="true" hint="The cache instance to register with this factory of type: coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider"/>
    	<cfset registerCache( arguments.cache )>
	</cffunction>
	
	<!--- addDefaultCache --->
    <cffunction name="addDefaultCache" output="false" access="public" returntype="any" hint="Add a default named cache to our registry, create it, config it, register it and return it of type: coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider">
    	<cfargument name="name" required="true" hint="The name of the default cache to create"/>
    	<cfscript>
    		var defaultCacheConfig	  = instance.config.getDefaultCache();
			
			// Check length
			if( len(arguments.name) eq 0 ){ 
				getUtil().throwit(message="Invalid Cache Name",
								  detail="The name you sent in is invalid as it was blank, please send in a name",
								  type="CacheFactory.InvalidNameException");
			}
			
			// Check it does not exist already
			if( cacheExists( arguments.name ) ){
				getUtil().throwit(message="Cache #arguments.name# already exists",
								  detail="Cannot register named cache as it already exists in the registry",
								  type="CacheFactory.CacheExistsException");
			}
			
			// Create default cache instance
			cache = createCache(name=arguments.name,provider=defaultCacheConfig.provider,properties=defaultCacheConfig);
			
			// Return it
			return cache;
		</cfscript>
    </cffunction>

	<!--- shutdown --->
    <cffunction name="shutdown" output="false" access="public" returntype="void" hint="Recursively sends shutdown commands to al registered caches and cleans up in preparation for shutdown">
    	<cfscript>
    		var iData 	= {};
			var cacheNames = getCacheNames();
			var cacheLen   = arraylen(cacheNames);
			var cache 	   = "";
			var i 		   = 1;
			
			// Log startup
			if( instance.log.canInfo() ){
    			instance.log.info("Shutdown of cache factory: #getFactoryID()# requested and started.");
    		}
			
			// Notify Listeners
			iData = {cacheFactory=this};
			instance.eventManager.processState("beforeCacheFactoryShutdown",iData);
			
			// safely iterate and shutdown caches
			for( i=1; i lte cacheLen; i++){
				
				// Get cache to shutdown
				cache = getCache( cacheNames[i] );
				
				// Log it
				if( instance.log.canDebug() ){
					instance.log.debug("Shutting down cache: #cacheNames[i]# on factoryID: #getFactoryID()#.");
				}
				
				//process listners
				iData = {cache=cache};
				instance.eventManager.processState("beforeCacheShutdown",iData);
				
				//Shutdown each cache
				cache.shutdown();
				
				//process listeners
				instance.eventManager.processState("afterCacheShutdown",iData);
				
				// log
				if( instance.log.canDebug() ){
					instance.log.debug("Cache: #cacheNames[i]# was shut down on factoryID: #getFactoryID()#.");
				}				
			}
			
			// Remove all caches
			removeAll();
			
			// remove scope registration
			removeFromScope();
			
			// Notify Listeners
			iData = {cacheFactory=this};
			instance.eventManager.processState("afterCacheFactoryShutdown",iData);
			
			// Log shutdown complete
			if( instance.log.canInfo() ){
				instance.log.info("Shutdown of cache factory: #getFactoryID()# completed.");
			}
		</cfscript>
    </cffunction>
	
	<!--- shutdownCache --->
    <cffunction name="shutdownCache" output="false" access="public" returntype="void" hint="Send a shutdown command to a specific cache provider to bring down gracefully. It also removes it from the cache factory">
    	<cfargument name="name" required="true" hint="The cache provider name to shutdown"/>
    	<cfscript>
    		var iData 		= {};
			var cache 	   	= "";
			var i 		   	= 1;
			
    		// Check if cache exists, else exit out
			if( NOT cacheExists(arguments.name) ){
				if( instance.log.canWarn() ){
					instance.log.warn("Trying to shutdown #arguments.name#, but that cache does not exist, skipping.");
				}
				return;
			}
			
			//get Cache
			cache = getCache(arguments.name);
		
			// log it
			if( instance.log.canInfo() ){
				instance.log.info("Shutdown of cache: #arguments.name# requested and started on factoryID: #getFactoryID()#");
			}
			
			// Notify Listeners
			iData = {cache=cache};
			instance.eventManager.processState("beforeCacheShutdown",iData);
			
			//Shutdown the cache
			cache.shutdown();
				
			//process listeners
			instance.eventManager.processState("afterCacheShutdown",iData);
			
			// remove cache
			removeCache(arguments.name);
			
			// Log it
			if( instance.log.canDebug() ){
				instance.log.debug("Cache: #arguments.name# was shut down and removed on factoryID: #getFactoryID()#.");
			}
		</cfscript>
    </cffunction>
	
	<!--- removeFromScope --->
    <cffunction name="removeFromScope" output="false" access="public" returntype="void" hint="Remove the cache factory from scope registration if enabled, else does nothing">
    	<cfscript>
			var scopeInfo = instance.config.getScopeRegistration();
			if( scopeInfo.enabled ){
				createObject("component","coldbox.system.core.collections.ScopeStorage").init().delete(scopeInfo.key, scopeInfo.scope);
			}
		</cfscript>
    </cffunction>

	<!--- removeCache --->
    <cffunction name="removeCache" output="false" access="public" returntype="any" hint="Try to remove a named cache from this factory, returns Boolean if successfull or not" colddoc:generic="Boolean">
    	<cfargument name="name" required="true" hint="The name of the cache to remove"/>
		<cfset var cache = "">
		<cfset var iData = {}>
						
		<cfif cacheExists( arguments.name )>
			<cflock name="#instance.lockName#" type="exclusive" timeout="20" throwontimeout="true">
				<cfscript>
					// double check
					if( structKeyExists( instance.caches, arguments.name ) ){
					
						//Log
						if( instance.log.canDebug() ){
							instance.log.debug("Cache: #arguments.name# asked to be removed from factory: #getFactoryID()#");
						}
						
						// Retrieve it
						cache = instance.caches[ arguments.name ];
						
						// Notify listeners here
						iData.cache = cache;
						instance.eventManager.processState("beforeCacheRemoval",iData);
						
						// process shutdown
						cache.shutdown();
						
						// Remove it
						structDelete( instance.caches, arguments.name );
						
						// Announce it
						iData.cache = arguments.name;
						instance.eventManager.processState("afterCacheRemoval",iData);
						
						// Log it
						if( instance.log.canDebug() ){
							instance.log.debug("Cache: #arguments.name# removed from factory: #getFactoryID()#");
						}
						
						return true;
					}
				</cfscript>
			</cflock>
		</cfif>
		
		<cfif instance.log.canDebug()>
			<cfset instance.log.debug("Cache: #arguments.name# not removed because it does not exist in registered caches: #arrayToList(getCacheNames())#. FactoryID: #getFactoryID()#")>
		</cfif>
		
		<cfreturn false>
    </cffunction>

	<!--- removeAll --->
    <cffunction name="removeAll" output="false" access="public" returntype="void" hint="Remove all the registered caches in this factory, this triggers individual cache shutdowns">
    	<cfscript>
			var cacheNames 	= getCacheNames();
			var cacheLen   	= arraylen(cacheNames);
			var i 		   	= 1;
		
			if( instance.log.canDebug() ){
				instance.log.debug("Removal of all caches requested on factoryID: #getFactoryID()#");
			}
		
			for( i=1; i lte cacheLen; i++){
				removeCache( cacheNames[i] );
			}
			
			if( instance.log.canDebug() ){
				instance.log.debug("All caches removed.");
			}
		</cfscript>
    </cffunction>
	
	<!--- reapAll --->
    <cffunction name="reapAll" output="false" access="public" returntype="void" hint="A nice way to call reap on all registered caches">
    	<cfscript>
			var cacheNames = getCacheNames();
			var cacheLen   = arraylen(cacheNames);
			var i 		   = 1;
			var cache 	   = "";
		
			if( instance.log.canDebug() ){
				instance.log.debug("Executing reap on factoryID: #getFactoryID()#");
			}
		
			for( i=1; i lte cacheLen; i++){
				cache = getCache( cacheNames[i] );
				cache.reap();
			}
		</cfscript>
    </cffunction>
	
	<!--- cacheExists --->
    <cffunction name="cacheExists" output="false" access="public" returntype="any" hint="Check if the passed in named cache is already registered in this factory or not" colddoc:generic="Boolean">
    	<cfargument name="name" required="true" hint="The name of the cache to check"/>
    	
		<cflock name="#instance.lockName#" type="readonly" timeout="20" throwontimeout="true">
			<cfreturn structKeyExists(instance.caches, arguments.name )>
		</cflock>
		
    </cffunction>
	
	<!--- replaceCache --->
    <cffunction name="replaceCache" output="false" access="public" returntype="void" hint="Replace a registered named cache with a new decorated cache of the same name.">
    	<cfargument name="cache" 			required="true" hint="The name of the cache to replace or the actual instance of the cache to replace" colddoc:generic="coldbox.system.cache.ICacheProvider"/>
		<cfargument name="decoratedCache" 	required="true" hint="The decorated cache manager instance to replace with of type coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider"/>
		
		<cfscript>
			var name = "";
			var iData = {};
			
			// determine cache name
			if( isObject(arguments.cache) ){
				name = arguments.cache.getName();
			}
			else{
				name = arguments.cache;
			}
		</cfscript>		

		<cflock name="#instance.lockName#" type="exclusive" timeout="20" throwontimeout="true">
			<cfscript>
				// Announce to listeners
				iData.oldCache = instance.caches[name];
				iData.newCache = arguments.decoratedCache;
				instance.eventManager.processState("beforeCacheReplacement",iData);
				
				// remove old Cache
				structDelete( instance.caches, name);
				// Replace it
				instance.caches[ name ] = arguments.decoratedCache;
				
				// debugging
				if( instance.log.canDebug() ){
					instance.log.debug("Cache #name# replaced with decorated cache: #getMetadata(arguments.decoratedCache).name# on factoryID: #getFactoryID()#");
				}
			</cfscript>
		</cflock>
		
    </cffunction>
	
	<!--- clearAll --->
    <cffunction name="clearAll" output="false" access="public" returntype="void" hint="Clears all the elements in all the registered caches without de-registrations">
    	<cfscript>
			var cacheNames = getCacheNames();
			var cacheLen   = arraylen(cacheNames);
			var i 		   = 1;
			var cache 	   = "";
		
			if( instance.log.canDebug() ){
				instance.log.debug("Clearing all registered caches of their content on factoryID: #getFactoryID()#");
			}
		
			for( i=1; i lte cacheLen; i++){
				cache = getCache( cacheNames[i] );
				cache.clearAll();
			}
		</cfscript>
    </cffunction>
	
	<!--- expireAll --->
    <cffunction name="expireAll" output="false" access="public" returntype="void" hint="Expires all the elements in all the registered caches without de-registrations">
    	<cfscript>
			var cacheNames = getCacheNames();
			var cacheLen   = arraylen(cacheNames);
			var i 		   = 1;
			var cache 	   = "";
		
			if( instance.log.canDebug() ){
				instance.log.debug("Expiring all registered caches of their content on factoryID: #getFactoryID()#");
			}
		
			for( i=1; i lte cacheLen; i++){
				cache = getCache( cacheNames[i] );
				cache.expireAll();
			}
		</cfscript>
    </cffunction>

	<!--- getCacheNames --->
    <cffunction name="getCacheNames" output="false" access="public" returntype="any" hint="Get the array of caches registered with this factory" colddoc:Generic="array">
    	
    	<cflock name="#instance.lockName#" type="readonly" timeout="20" throwontimeout="true">
			<cfreturn structKeyArray( instance.caches )>
		</cflock>
		
    </cffunction>

<!----------------------------------------- PUBLIC PROPERTY RETRIEVERS ------------------------------------->	
	
	<!--- getCaches --->
    <cffunction name="getCaches" output="false" access="public" returntype="any" hint="Get a reference to all the registered caches in the cache factory as a structure" colddoc:generic="Struct">
    	<cfreturn instance.caches>
    </cffunction>
	
	<!--- getColdbox --->
    <cffunction name="getColdbox" output="false" access="public" returntype="any" hint="Get the instance of ColdBox linked in this cache factory. Empty if using standalone version" colddoc:generic="coldbox.system.web.Controller">
    	<cfreturn instance.coldbox>
    </cffunction>
	
	<!--- isColdBoxLinked --->
    <cffunction name="isColdBoxLinked" output="false" access="public" returntype="any" hint="Checks if Coldbox application controller is linked" colddoc:generic="Boolean">
    	<cfreturn isObject(instance.coldbox)>
    </cffunction>

	<!--- getLogBox --->
    <cffunction name="getLogBox" output="false" access="public" returntype="any" hint="Get the instance of LogBox configured for this cache factory" colddoc:generic="coldbox.system.logging.LogBox">
    	<cfreturn instance.logBox>
    </cffunction>

	<!--- Get Version --->
	<cffunction name="getVersion" access="public" returntype="any" output="false" hint="Get the CacheBox version string.">
		<cfreturn instance.version>
	</cffunction>
	
	<!--- Get the config object --->
	<cffunction name="getConfig" access="public" returntype="any" output="false" hint="Get this LogBox's configuration object." colddoc:generic="coldbox.system.cache.config.CacheBoxConfig">
		<cfreturn instance.config>
	</cffunction>
	
	<!--- getFactoryID --->
    <cffunction name="getFactoryID" output="false" access="public" returntype="any" hint="Get the unique ID of this cache factory">
    	<cfreturn instance.factoryID>
    </cffunction>
	
	<!--- getDefaultCache --->
    <cffunction name="getDefaultCache" output="false" access="public" returntype="any" hint="Get the default cache provider of type coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider">
    	<cfreturn getCache("default")>
    </cffunction>
	
	<!--- getEventManager --->
    <cffunction name="getEventManager" output="false" access="public" returntype="any" hint="Get the cache factory's event manager">
 		<cfreturn instance.eventManager>
    </cffunction>

	<!--- getScopeRegistration --->
    <cffunction name="getScopeRegistration" output="false" access="public" returntype="any" hint="Get the scope registration information" colddoc:generic="struct">
    	<cfreturn instance.config.getScopeRegistration()>
    </cffunction>

<!----------------------------------------- PRIVATE ------------------------------------->	

	<!--- doScopeRegistration --->
    <cffunction name="doScopeRegistration" output="false" access="private" returntype="void" hint="Register this cachefactory on a user specified scope">
    	<cfscript>
    		var scopeInfo 		= instance.config.getScopeRegistration();
			var scopeStorage	= createObject("component","coldbox.system.core.collections.ScopeStorage").init();
			// register factory with scope
			scopeStorage.put(scopeInfo.key, this, scopeInfo.scope);
		</cfscript>
    </cffunction>
	
	<!--- createCache --->
    <cffunction name="createCache" output="false" access="private" returntype="any" hint="Create a new cache according the the arguments, register it and return it of type: coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider">
    	<cfargument name="name" 		required="true" hint="The name of the cache to add"/>
		<cfargument name="provider" 	required="true" hint="The provider class path of the cache to add"/>
		<cfargument name="properties" 	required="false" default="#structNew()#" hint="The properties of the cache to configure with" colddoc:generic="struct"/>
		<cfscript>
			// Create Cache
			var oCache = createObject("component",arguments.provider).init();
			// Register Name
			oCache.setName( arguments.name );
			// Link Properties
			oCache.setConfiguration( arguments.properties );
			// Register Cache
			registerCache( oCache );
			
			return oCache;
		</cfscript>
    </cffunction>
	
	<!--- registerCache --->
    <cffunction name="registerCache" output="false" access="private" returntype="void" hint="Register a cache instance internaly">
    	<cfargument name="cache" required="true" hint="The cache instance to register with this factory of type: coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider"/>
    	<cfset var name		= arguments.cache.getName()>
    	<cfset var oCache 	= arguments.cache>
    	<cfset var iData 	= {}>
    	
    	<!--- Verify it does not exist already --->
		<cfif structKeyExists(instance.caches, name)>
			<cfthrow message="Cache #name# already exists!" type="CacheFactory.CacheExistsException">
		</cfif>
		
		<!--- Verify Registration --->
		<cfif NOT structKeyExists(instance.caches, name)>
			<cflock name="#instance.lockName#" type="exclusive" timeout="20" throwontimeout="true">
				<cfscript>
					if( NOT structKeyExists(instance.caches, name) ){
						// Link to this CacheFactory
						oCache.setCacheFactory( this );
						// Link ColdBox if using it
						if( isObject(instance.coldbox) AND structKeyExists(oCache,"setColdBox")){ 
							oCache.setColdBox( instance.coldbox );
						}		
						// Link Event Manager
						oCache.setEventManager( instance.eventManager );
						// Call Configure it to start the cache up
						oCache.configure();				
						// Store it
						instance.caches[ name ] = oCache;
						
						// Announce new cache registration now 
						iData.cache = oCache;
						instance.eventManager.processState("afterCacheRegistration",iData);
					}
				</cfscript>
			</cflock>
		</cfif>
    </cffunction>	
	
	<!--- configureLogBox --->
    <cffunction name="configureLogBox" output="false" access="private" returntype="void" hint="Configure a standalone version of logBox for logging">
    	<cfscript>
    		// Config LogBox Configuration
			var config = createObject("component","coldbox.system.logging.config.LogBoxConfig").init(CFCConfigPath="coldbox.system.cache.config.LogBox");
			// Create LogBox
			instance.logBox = createObject("component","coldbox.system.logging.LogBox").init( config );
		</cfscript>
    </cffunction>
	
	<!--- configureEventManager --->
    <cffunction name="configureEventManager" output="false" access="private" returntype="void" hint="Configure a standalone version of a ColdBox Event Manager">
    	<cfscript>
    		// create event manager
			instance.eventManager = createObject("component","coldbox.system.core.events.EventPoolManager").init( instance.eventStates );
			// register the points to listen to
			instance.eventManager.appendCustomStates( arrayToList(instance.eventStates) );
		</cfscript>
    </cffunction>

	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="any" hint="Create and return a util object" colddoc:generic="coldbox.system.core.util.Util">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>
	
</cfcomponent>