<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The main CacheBox factory and configuration of caches

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
		instance.caches  = {};
	</cfscript>
	
	<!--- init --->
	<cffunction name="init" access="public" returntype="CacheFactory" hint="Constructor" output="false" >
		<cfargument name="config"  type="coldbox.system.cache.config.CacheBoxConfig" required="true" hint="The CacheBoxConfig object to use to configure this instance of CacheBox"/>
		<cfargument name="coldbox" type="any" required="false" default="" hint="A coldbox application that this instance of CacheBox can be linked to."/>
		<cfscript>
			// Check if linking ColdBox
			if( isObject(arguments.coldbox) ){ 
				instance.coldbox = arguments.coldbox; 
				// link LogBox
				instance.logBox  = instance.coldbox.getLogBox();
			}
			else{
				// Running standalone, so create our own logging
				configureLogBox();
			}
			
			// Configure Logging for the Cache Factory
			instance.log = getLogBox().getLogger( this );
			
			return this;
		</cfscript>
	</cffunction>
	
	<!--- configure --->
	<cffunction name="configure" output="false" access="public" returntype="void" hint="Configure logbox for operation. You can also re-configure LogBox programmatically. Basically we register all appenders here and all categories">
		<cfargument name="config" type="coldbox.system.logging.config.LogBoxConfig" required="true" hint="The LogBoxConfig object to use to configure this instance of LogBox"/>
		<cfscript>
		
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PUBLIC CACHE FACTORY OPERATIONS ------------------------------------------>

	<!--- getCache --->
    <cffunction name="getCache" output="false" access="public" returntype="coldbox.system.cache." hint="Get a reference to a registered cache in this factory.  If the cache does not exist we will return null">
    	<cfargument name="name" type="string" required="true" hint="The named cache to retrieve"/>
		
		<cflock name="cacheBoxFactory-#getFactoryID()#" type="readonly" timeout="20">
			<cfreturn getCaches().get( arguments.name )>
		</cflock>
		
    </cffunction>
	
	<!--- addCache --->
    <cffunction name="addCache" output="false" access="public" returntype="void" hint="Register a cache with this cache factory">
    	<cfargument name="cache" 	 type="coldbox.system.cache.ICache" required="true" hint="The cache instance to register with this factory"/>
    	<cfscript>
			
		</cfscript>
	</cffunction>
	
	<!--- addDefaultCache --->
    <cffunction name="addDefaultCache" output="false" access="public" returntype="coldbox.system.cache.ICache" hint="Add a default named cache to our registry, create it, config it, register it and return it">
    	<cfargument name="name" type="string" required="true" hint="The name of the default cache to create"/>
    	<cfscript>
    		var cache = "";
			
			// Check length
			if( len(arguments.name) eq 0 ){ return; }
			
			// Check it does not exist already
			if( cacheExists( arguments.name ) ){
				getUtil().throwit(message="Cache #arguments.name# already exists",
								  detail="Cannot register named cache as it already exists in the registry",
								  type="CacheFactory.CacheExistsException");
			}
			
			// Create default cache with name
			cache = createDefaultCache();
			cache.setName( arguments.name );
			
			// Add it
			addCache( cache );
			
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
			<cflock name="cacheBoxFactory-#getFactoryID()#" type="exclusive" timeout="20">
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
						instance.log.debug("Cache: #arguments.name# removed from factory: #getFactoryID()#");
					}
				</cfscript>
			</cflock>
		</cfif>
		
		<cfreturn false>
    </cffunction>

	<!--- removeAll --->
    <cffunction name="removeAll" output="false" access="public" returntype="void" hint="Remove all the registered caches in this factory, this triggers individual cache shutdowns">
    	<cfscript>
			var cacheNames = getCacheNames();
			var cacheLen   = arraylen(cacheNames);
			var i 		   = 1;
		
			instance.log.debug("Removal of all caches requested.");
		
			for( i=1; i lte cacheLen; i++){
				removeCache( cacheNames[i] );
			}
		</cfscript>
    </cffunction>
	
	<!--- cacheExists --->
    <cffunction name="cacheExists" output="false" access="public" returntype="boolean" hint="Check if the passed in named cache is already registered in this factory">
    	<cfargument name="name" type="string" required="true" hint="The name of the cache to check"/>
    	
		<cflock name="cacheBoxFactory-#getFactoryID()#" type="readonly" timeout="20">
			<cfreturn getCaches().containsKey( arguments.name )>
		</cflock>
		
    </cffunction>
	
	<!--- replaceCache --->
    <cffunction name="replaceCache" output="false" access="public" returntype="void" hint="Replace a registered named cache with a new decorated cache of the same name.">
    	<cfargument name="cache" type="any" required="true" hint="The name of the cache to replace or the actual instance of the cache to replace"/>
		<cfargument name="decoratedCache" type="coldbox.system.cache.ICache" required="true" hint="The decorated cache manager instance to replace with"/>
		
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

		<cflock name="cacheBoxFactory-#getFactoryID()#" type="exclusive" timeout="20">
			<cfset structDelete( instance.caches, name)>
			<cfset instance.caches[ name ] = arguments.decoratedCache>
		</cflock>
		
    </cffunction>
	
	<!--- newCache --->
    <cffunction name="newCache" output="false" access="public" returntype="coldbox.system.cache.ICache" hint="Create a new cache according the the arguments, register it and return it">
    	<cfargument name="name" 		type="string" required="true" hint="The name of the cache to add"/>
		<cfargument name="class" 		type="string" required="true" hint="The class path of the cache to add"/>
		<cfargument name="properties" 	type="struct" required="false" default="#structNew()#" hint="The properties of the cache to configure with"/>
		<cfscript>
		
		</cfscript>
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
    	
    	<cflock name="cacheBoxFactory-#getFactoryID()#" type="readonly" timeout="20">
			<cfreturn getCaches().keySet().toArray()>
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
		<cfreturn instance.Version>
	</cffunction>
	
	<!--- Get the config object --->
	<cffunction name="getConfig" access="public" returntype="coldbox.system.cache.config.CacheBoxConfig" output="false" hint="Get this LogBox's configuration object.">
		<cfreturn instance.config>
	</cffunction>
	
	<!--- getFactoryID --->
    <cffunction name="getFactoryID" output="false" access="public" returntype="any" hint="Get the unique ID of this cache factory">
    	<cfreturn instance.factoryID>
    </cffunction>

<!----------------------------------------- PRIVATE ------------------------------------->	

	<!--- configureLogBox --->
    <cffunction name="configureLogBox" output="false" access="private" returntype="void" hint="Configure a standalone version of logBox for logging">
    	<cfscript>
    		// Config LogBox Configuration
			var config = createObject("component","coldbox.system.logging.config.LogBoxConfig").init(CFCConfigPath="coldbox.system.cache.config.LogBoxConfig");
			// Create LogBox
			instance.logBox = createObject("component","coldbox.system.logging.LogBox").init( config );
		</cfscript>
    </cffunction>

	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a util object">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>
	
</cfcomponent>