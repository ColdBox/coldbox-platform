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
<cfcomponent hint="The ColdBox CacheBox Factory" output="false">

<!----------------------------------------- CONSTRUCTOR ------------------------------------->			
	
	<cfscript>
		instance = structnew();
		// CacheBox Factory UniqueID
		instance.factoryID = createObject('java','java.lang.System').identityHashCode(this);	
		// Version
		instance.version = "1.0";	 
		// Configuration object
		instance.config  = "";
		// ColdBox Application Link
		instance.coldbox = "";	
		// LogBox Links
		instance.logBox  = "";
		instance.log	 = "";
		// Caches
		instance.caches  		= {};
		// Lock info
		instance.lockName = "CacheFactory.#instance.factoryID#";
	</cfscript>
	
	<!--- init --->
	<cffunction name="init" access="public" returntype="CacheFactory" hint="Constructor" output="false" >
		<cfargument name="config"  type="coldbox.system.cache.config.CacheBoxConfig" required="false" hint="The CacheBoxConfig object to use to configure this instance of CacheBox. If not passed then CacheBox will instantiate the default configuration."/>
		<cfargument name="coldbox" type="coldbox.system.web.Controller" 			 required="false" hint="A coldbox application that this instance of CacheBox can be linked to, if not using it, just ignore it."/>
		<cfscript>
			var defaultConfigPath = "coldbox.system.cache.config.DefaultConfiguration";
			
			// Check if linking ColdBox
			if( structKeyExists(arguments, "coldbox") ){ 
				instance.coldbox = arguments.coldbox; 
				// link LogBox
				instance.logBox  = instance.coldbox.getLogBox();
			}
			else{
				// Running standalone, so create our own logging first
				configureLogBox();
			}
			
			// Passed in configuration?
			if( NOT structKeyExists(arguments,"config") ){
				// Create default configuration
				arguments.config = createObject("component","coldbox.system.cache.config.CacheBoxConfig").init(CFCConfigPath=defaultConfigPath);
			}
			
			// Configure Logging for the Cache Factory
			instance.log = getLogBox().getLogger( this );
			
			// Configure the Cache Factory
			configure( arguments.config );
			
			return this;
		</cfscript>
	</cffunction>
	
	<!--- configure --->
	<cffunction name="configure" output="false" access="public" returntype="void" hint="Configure the cache factory for operation, called by the init(). You can also re-configure CacheBox programmatically.">
		<cfargument name="config" type="coldbox.system.cache.config.CacheBoxConfig" required="true" hint="The CacheBoxConfig object to use to configure this instance of CacheBox"/>
		<cfscript>
			var defaultCacheConfig = "";
			var caches 	= "";
			var key 	= "";
			
		</cfscript>
		
		<cflock name="#instance.lockName#" type="exclusive" timeout="30" throwontimeout="true">
			<cfscript>
			// Store config object
			instance.config = arguments.config;
			// Validate configuration
			instance.config.validate();
			// Reset Registries
			instance.caches = {};
			// Register Listeners
			
			// Register default cache first
			defaultCacheConfig = instance.config.getDefaultCache();
			createCache(name="default",provider=defaultCacheConfig.provider,properties=defaultCacheConfig);
			
			// Register named caches
			caches = instance.config.getCaches();
			for(key in caches){
				createCache(name=key,provider=caches[key].provider,properties=caches[key].properties);
			}			
			</cfscript>
		</cflock>
	</cffunction>
	
	<!--- createCache --->
    <cffunction name="createCache" output="false" access="private" returntype="coldbox.system.cache.ICacheProvider" hint="Create a new cache according the the arguments, register it and return it">
    	<cfargument name="name" 		type="string" required="true" hint="The name of the cache to add"/>
		<cfargument name="provider" 	type="string" required="true" hint="The provider class path of the cache to add"/>
		<cfargument name="properties" 	type="struct" required="false" default="#structNew()#" hint="The properties of the cache to configure with"/>
		<cfscript>
			// Create Cache
			var oCache = createObject("component",arguments.provider).init();
			// Register Name
			oCache.setName( arguments.name );
			// Register Cache
			registerCache( oCache );
			
			return oCache;
		</cfscript>
    </cffunction>
	
	<!--- registerCache --->
    <cffunction name="registerCache" output="false" access="private" returntype="void" hint="Register a cache instance internaly">
    	<cfargument name="cache" 	 type="coldbox.system.cache.ICacheProvider" required="true" hint="The cache instance to register with this factory"/>
    	<cfset var name		= arguments.cache.getName()>
    	<cfset var oCache 	= arguments.cache>
    	
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
						// Link Properties
						oCache.setConfiguration( arguments.properties );
						// Link ColdBox if using it
						if( isObject(instance.coldbox) AND structKeyExists(oCache,"setColdBox")){ 
							oCache.setColdBox( instance.coldbox );
						}		
						// Call Configure it to start the cache up
						oCache.configure();				
						// Store it
						instance.caches[ name ] = oCache;
						
						// Announce new cache registration now 
						
					}
				</cfscript>
			</cflock>
		</cfif>
    </cffunction>	
	
<!------------------------------------------- PUBLIC CACHE FACTORY OPERATIONS ------------------------------------------>

	<!--- getCache --->
    <cffunction name="getCache" output="false" access="public" returntype="coldbox.system.cache.ICacheProvider" hint="Get a reference to a registered cache in this factory.  If the cache does not exist it will return an exception">
    	<cfargument name="name" type="string" required="true" hint="The named cache to retrieve"/>
		
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
    	<cfargument name="cache" 	 type="coldbox.system.cache.ICacheProvider" required="true" hint="The cache instance to register with this factory"/>
    	<cfset registerCache( arguments.cache )>
	</cffunction>
	
	<!--- addDefaultCache --->
    <cffunction name="addDefaultCache" output="false" access="public" returntype="coldbox.system.cache.ICacheProvider" hint="Add a default named cache to our registry, create it, config it, register it and return it">
    	<cfargument name="name" type="string" required="true" hint="The name of the default cache to create"/>
    	<cfscript>
    		var defaultCacheConfig	  = instance.config.getDefaultCache();
			
			// Check length
			if( len(arguments.name) eq 0 ){ return; }
			
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
    		instance.log.info("Shutdown of cache factory: #getFactoryID()# requested and started.");
			
			// Remove all caches first
			removeAll();
			
			// Notify Listeners
			
			// Shutdown listeners
		</cfscript>
    </cffunction>
	
	<!--- removeCache --->
    <cffunction name="removeCache" output="false" access="public" returntype="boolean" hint="Try to remove a named cache from this factory">
    	<cfargument name="name" type="string" required="true" hint="The name of the cache to remove"/>
		<cfset var cache = "">
						
		<cfif cacheExists( arguments.name )>
			<cflock name="#instance.lockName#" type="exclusive" timeout="20" throwontimeout="true">
				<cfscript>
					// double check
					if( structKeyExists( instance.caches, arguments.name ) ){
						// Retrieve it
						cache = instance.caches[ arguments.name ];
						// process shutdown
						cache.shutdown();
						// Notify listeners here
						
						// Remove it
						structDelete( instance.caches, arguments.name );
						// Log It
						instance.log.debug("Cache: #arguments.name# removed from factory: #getFactoryID()#");
						return true;
					}
				</cfscript>
			</cflock>
		</cfif>
		
		<cfset instance.log.debug("Cache: #arguments.name# not removed because it does not exist in registered caches")>
		
		<cfreturn false>
    </cffunction>

	<!--- removeAll --->
    <cffunction name="removeAll" output="false" access="public" returntype="void" hint="Remove all the registered caches in this factory, this triggers individual cache shutdowns">
    	<cfscript>
			var cacheNames 	= getCacheNames();
			var cacheLen   	= arraylen(cacheNames);
			var i 		   	= 1;
		
			instance.log.debug("Removal of all caches requested.");
		
			for( i=1; i lte cacheLen; i++){
				removeCache( cacheNames[i] );
			}
		</cfscript>
    </cffunction>
	
	<!--- cacheExists --->
    <cffunction name="cacheExists" output="false" access="public" returntype="boolean" hint="Check if the passed in named cache is already registered in this factory">
    	<cfargument name="name" type="string" required="true" hint="The name of the cache to check"/>
    	
		<cflock name="#instance.lockName#" type="readonly" timeout="20" throwontimeout="true">
			<cfreturn structKeyExists(getCaches(), arguments.name )>
		</cflock>
		
    </cffunction>
	
	<!--- replaceCache --->
    <cffunction name="replaceCache" output="false" access="public" returntype="void" hint="Replace a registered named cache with a new decorated cache of the same name.">
    	<cfargument name="cache" type="any" required="true" hint="The name of the cache to replace or the actual instance of the cache to replace"/>
		<cfargument name="decoratedCache" type="coldbox.system.cache.ICacheProvider" required="true" hint="The decorated cache manager instance to replace with"/>
		
		<cfscript>
			var name = "";
			
			// determine cache name
			if( isObject(arguments.cache) ){
				name = arguments.cache.getName();
			}
			else{
				name = arguments.cache;
			}
		</cfscript>		

		<cflock name="#instance.lockName#" type="exclusive" timeout="20" throwontimeout="true">
			<cfset structDelete( instance.caches, name)>
			<cfset instance.caches[ name ] = arguments.decoratedCache>
			<cfset instance.log.debug("Cache #name# replaced with decorated cache: #getMetadata(arguments.decoratedCache).name#")>
		</cflock>
		
    </cffunction>
	
	<!--- clearAll --->
    <cffunction name="clearAll" output="false" access="public" returntype="void" hint="Clears all the elements in all the registered caches without de-registrations">
    	<cfscript>
			var cacheNames = getCacheNames();
			var cacheLen   = arraylen(cacheNames);
			var i 		   = 1;
			var cache 	   = "";
		
			instance.log.debug("Clearing all registered caches of their content");
		
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
		
			instance.log.debug("Expiring all registered caches of their content");
		
			for( i=1; i lte cacheLen; i++){
				cache = getCache( cacheNames[i] );
				cache.expireAll();
			}
		</cfscript>
    </cffunction>

	<!--- getCacheNames --->
    <cffunction name="getCacheNames" output="false" access="public" returntype="array" hint="Get the array of caches registered with this factory">
    	
    	<cflock name="#instance.lockName#" type="readonly" timeout="20" throwontimeout="true">
			<cfreturn structKeyArray( instance.caches )>
		</cflock>
		
    </cffunction>

<!----------------------------------------- PUBLIC PROPERTY RETRIEVERS ------------------------------------->	
	
	<!--- getCaches --->
    <cffunction name="getCaches" output="false" access="public" returntype="struct" hint="Get a reference to all the registered caches in the cache factory">
    	<cfreturn instance.caches>
    </cffunction>
	
	<!--- getColdbox --->
    <cffunction name="getColdbox" output="false" access="public" returntype="any" hint="Get the instance of ColdBox linked in this cache factory. Empty if using standalone version">
    	<cfreturn instance.coldbox>
    </cffunction>

	<!--- getLogBox --->
    <cffunction name="getLogBox" output="false" access="public" returntype="coldbox.system.logging.LogBox" hint="Get the instance of LogBox configured for this cache factory">
    	<cfreturn instance.logBox>
    </cffunction>

	<!--- Get Version --->
	<cffunction name="getVersion" access="public" returntype="string" output="false" hint="Get the CacheBox version string.">
		<cfreturn instance.version>
	</cffunction>
	
	<!--- Get the config object --->
	<cffunction name="getConfig" access="public" returntype="coldbox.system.cache.config.CacheBoxConfig" output="false" hint="Get this LogBox's configuration object.">
		<cfreturn instance.config>
	</cffunction>
	
	<!--- getFactoryID --->
    <cffunction name="getFactoryID" output="false" access="public" returntype="any" hint="Get the unique ID of this cache factory">
    	<cfreturn instance.factoryID>
    </cffunction>
	
	<!--- getDefaultCache --->
    <cffunction name="getDefaultCache" output="false" access="public" returntype="coldbox.system.cache.ICacheProvider" hint="Get the default cache provider">
    	<cfreturn getCache("default")>
    </cffunction>

<!----------------------------------------- PRIVATE ------------------------------------->	

	<!--- configureLogBox --->
    <cffunction name="configureLogBox" output="false" access="private" returntype="void" hint="Configure a standalone version of logBox for logging">
    	<cfscript>
    		// Config LogBox Configuration
			var config = createObject("component","coldbox.system.logging.config.LogBoxConfig").init(CFCConfigPath="coldbox.system.cache.config.LogBox");
			// Create LogBox
			instance.logBox = createObject("component","coldbox.system.logging.LogBox").init( config );
		</cfscript>
    </cffunction>

	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a util object">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>
	
</cfcomponent>