<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	3/13/2009
Description :
	This is a CacheBox configuration object.  You can use it to configure
	a CacheBox instance.
----------------------------------------------------------------------->
<cfcomponent output="false" hint="This is a CacheBox configuration object.  You can use it to configure a CacheBox instance">

	<cfscript>
		// Utility
		utility  = createObject("component","coldbox.system.core.util.Util");
		
		// Instance private scope
		instance 		  = structnew();
		
		// CacheBox Defaults
		defaults = {
			objectDefaultTimeout = 60,
			objectDefaultLastAccessTimeout = 30,
			useLastAccessTimeouts = true,
			reapFrequency = 2,
			freeMemoryPercentageThreshold = 0,
			evictionPolicy = "LRU",
			evictCount = 1,
			maxObjects = 200,
			objectStore = "coldbox.system.cache.store.ConcurrentSoftReferenceStore",
			logBoxConfig = "coldbox.system.cache.config.LogBox",
			coldboxEnabled = false,
			provider = "coldbox.system.cache.providers.CacheBoxProvider"
		};
		
		// Startup the configuration
		reset();
	</cfscript>

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="CacheBoxConfig" hint="Constructor">
		<cfargument name="XMLConfig" 		type="string"   required="false" default="" hint="The xml configuration file to use instead of a programmatic approach"/>
		<cfargument name="CFCConfig" 		type="any" 		required="false" hint="The cacheBox Data Configuration CFC"/>
		<cfargument name="CFCConfigPath" 	type="string" 	required="false" hint="The cacheBox Data Configuration CFC path to use"/>
		<cfscript>
			var cacheBoxDSL = "";
			
			// Test and load via XML
			if( len(trim(arguments.XMLConfig)) ){
				parseAndLoad(xmlParse(arguments.XMLConfig));
			}
			
			// Test and load via Data CFC Path
			if( structKeyExists(arguments, "CFCConfigPath") ){
				arguments.CFCConfig = createObject("component",arguments.CFCConfigPath);
			}
			
			// Test and load via Data CFC
			if( structKeyExists(arguments,"CFCConfig") and isObject(arguments.CFCConfig) ){
				// Decorate our data CFC
				arguments.CFCConfig.getPropertyMixin = utility.getPropertyMixin;
				// Execute the configuration
				arguments.CFCConfig.configure();
				// Get Data
				cacheBoxDSL = arguments.CFCConfig.getPropertyMixin("cacheBox","variables",structnew());
				// Load the DSL
				loadDataDSL( cacheBoxDSL );
			}
			
			// Just return, most likely programmatic config
			return this;
		</cfscript>
	</cffunction>
	
	<!--- getDefaults --->
    <cffunction name="getDefaults" output="false" access="public" returntype="struct" hint="Get the default CacheBox settings">
    	<cfreturn variables.defaults>
    </cffunction>
	
	<!--- logBoxConfig --->
    <cffunction name="logBoxConfig" output="false" access="public" returntype="void" hint="Set the logBox Configuration to use">
    	<cfargument name="config" type="string" required="true" hint="The configuration file to use"/>
		<cfset instance.logBoxConfig = arguments.config>
    </cffunction>
	
	<!--- getLogBoxConfig --->
    <cffunction name="getLogBoxConfig" output="false" access="public" returntype="string" hint="Get the logBox Configuration file to use">
    	<cfreturn instance.logBoxConfig>
    </cffunction>
	
	<!--- loadDataCFC --->
    <cffunction name="loadDataDSL" output="false" access="public" returntype="void" hint="Load a data configuration CFC data DSL">
    	<cfargument name="rawDSL" type="struct" required="true" hint="The data configuration DSL structure"/>
    	<cfscript>
			var cacheBoxDSL  = arguments.rawDSL;
			var key 		= "";
			
			// Is default configuration defined
			if( NOT structKeyExists( cacheBoxDSL, "defaultCache" ) ){
				$throw("No default cache defined","Please define the 'defaultCache'","CacheBoxConfig.NoDefaultCacheFound");
			}
			
			// Register Default Cache
			defaultCache(argumentCollection=cacheBoxDSL.defaultCache);
			
			// Register LogBox Configuration
			logBoxConfig( variables.defaults.logBoxConfig );
			if( structKeyExists( cacheBoxDSL, "logBoxConfig") ){
				logBoxConfig(cacheBoxDSL.logBoxConfig);
			}
			
			// Register Caches
			if( structKeyExists( cacheBoxDSL, "caches") ){
				for( key in cacheBoxDSL.caches ){
					cacheBoxDSL.caches[key].name = key;
					cache(argumentCollection=cacheBoxDSL.caches[key]);
				}
			}
			
			// Register listeners
			if( structKeyExists( cacheBoxDSL, "listeners") ){
				for(key=1; key lte arrayLen(cacheBoxDSL.listeners); key++ ){
					listener(argumentCollection=cacheBoxDSL.listeners[key]);
				}
			}		
		</cfscript>
    </cffunction>
	
	<!--- reset --->
	<cffunction name="reset" output="false" access="public" returntype="void" hint="Reset the configuration">
		<cfscript>
			// default cache
			instance.defaultCache = {};
			// logBox File
			instance.logBoxConfig = "";
			// Named Caches
			instance.caches = {};
			// Listeners
			instance.listeners = [];
		</cfscript>
	</cffunction>
	
	<!--- resetDefaultCache --->
    <cffunction name="resetDefaultCache" output="false" access="public" returntype="void" hint="Reset the default cache configurations">
    	<cfset instance.defaultCache = {}>
    </cffunction>
	
	<!--- resetCaches --->
    <cffunction name="resetCaches" output="false" access="public" returntype="void" hint="Reset the set caches">
    	<cfset instance.caches = {}>
    </cffunction>
	
	<!--- resetListeners --->
    <cffunction name="resetListeners" output="false" access="public" returntype="void" hint="Reset the cache listeners">
    	<cfset instance.listeners = []>
    </cffunction>
	
	<!--- Get Memento --->
	<cffunction name="getMemento" access="public" returntype="struct" output="false" hint="Get the instance data">
		<cfreturn instance>
	</cffunction>
	
	<!--- validate --->
	<cffunction name="validate" output="false" access="public" returntype="void" hint="Validates the configuration. If not valid, it will throw an appropriate exception.">
		<cfscript>
			// Is the default cache defined
			if( structIsEmpty(instance.defaultCache) ){
				$throw(message="Invalid Configuration. No default cache defined",type="CacheBoxConfig.NoDefaultCacheFound");
			}
			
		</cfscript>
	</cffunction>
	
	<!--- defaultCache --->
	<cffunction name="defaultCache" output="false" access="public" returntype="void" hint="Add a default cache configuration.">
		<cfargument name="objectDefaultTimeout" 			type="numeric" required="false"  default="#variables.defaults.objectDefaultTimeout#">
	    <cfargument name="objectDefaultLastAccessTimeout"   type="numeric" required="false"  default="#variables.defaults.objectDefaultLastAccessTimeout#">
	    <cfargument name="reapFrequency" 					type="numeric" required="false"  default="#variables.defaults.reapFrequency#">
	    <cfargument name="maxObjects" 						type="numeric" required="false"  default="#variables.defaults.maxObjects#">
	    <cfargument name="freeMemoryPercentageThreshold" 	type="numeric" required="false"  default="#variables.defaults.freeMemoryPercentageThreshold#">
	    <cfargument name="useLastAccessTimeouts"			type="boolean" required="false"  default="#variables.defaults.useLastAccessTimeouts#">
	    <cfargument name="evictionPolicy"					type="string"  required="false"  default="#variables.defaults.evictionPolicy#">
	    <cfargument name="evictCount"						type="numeric" required="false"  default="#variables.defaults.evictCount#">
	    <cfargument name="objectStore" 						type="string"  required="false"  default="#variables.defaults.objectStore#">
	    <cfargument name="coldboxEnabled" 					type="boolean" required="false"  default="#variables.defaults.coldboxEnabled#"/>
	    <cfscript>			
			structAppend(getDefaultCache(), arguments);
		</cfscript>
	</cffunction>
	
	<!--- defaultCache --->
	<cffunction name="getDefaultCache" access="public" returntype="struct" output="false" hint="Get the defaultCache definition.">
		<cfreturn instance.defaultCache>
	</cffunction>
	
	<!--- cache --->
	<cffunction name="cache" output="false" access="public" returntype="void" hint="Add a new cache configuration.">
		<cfargument name="name" 		type="string" required="true"   hint="The name of the cache"/>
		<cfargument name="provider" 	type="string" required="false"  default="#variables.defaults.provider#" hint="The cache provider class, defaults to: coldbox.system.cache.providers.CacheBoxProvider"/>
		<cfargument name="properties" 	type="struct" required="false"  default="#structNew()#" hint="The structure of properties for the cache"/>
		<cfscript>
			instance.caches[arguments.name] = {
				provider 	= arguments.provider,
				properties 	= arguments.properties
			};
		</cfscript>
	</cffunction>
	
	<!--- getCache --->
	<cffunction name="getCache" output="false" access="public" returntype="struct" hint="Get a specifed cache definition">
		<cfargument name="name" type="string" required="true" hint="The cache configuration to retrieve"/>
		<cfreturn instance.caches[arguments.name]>
	</cffunction>
	
	<!--- cacheExists --->
	<cffunction name="cacheExists" output="false" access="public" returntype="boolean" hint="Check if a cache definition exists">
		<cfargument name="name" type="string" required="true" hint="The cache to check"/>
		<cfreturn structKeyExists(instance.caches, arguments.name)>
	</cffunction>
	
	<!--- getCaches --->
	<cffunction name="getCaches" output="false" access="public" returntype="struct" hint="Get the configured caches">
		<cfreturn instance.caches>
	</cffunction>
	
	<!--- listener --->
	<cffunction name="listener" output="false" access="public" returntype="void" hint="Add a new listener configuration.">
		<cfargument name="class" 		type="string" required="true"  hint="The class of the listener"/>
		<cfargument name="properties" 	type="struct" required="false" default="#structNew()#" hint="The structure of properties for the listner"/>
		<cfargument name="name" 		type="string" required="false" default=""  hint="The name of the listener"/>
		<cfscript>
			// Name check?
			if( NOT len(arguments.name) ){
				arguments.name = listLast(arguments.class,".");
			}
			// add listener
			arrayAppend(instance.listeners, arguments);
		</cfscript>
	</cffunction>
	
	<!--- getListener --->
	<cffunction name="getListener" output="false" access="public" returntype="struct" hint="Get a specifed listener definition">
		<cfargument name="name" type="string" required="true" hint="The listner configuration to retrieve"/>
		<cfreturn instance.listeners[arguments.name]>
	</cffunction>
	
	<!--- listenerExists --->
	<cffunction name="listenerExists" output="false" access="public" returntype="boolean" hint="Check if a listener definition exists">
		<cfargument name="name" type="string" required="true" hint="The listener to check"/>
		<cfreturn structKeyExists(instance.listeners, arguments.name)>
	</cffunction>
	
	<!--- getListeners --->
	<cffunction name="getListeners" output="false" access="public" returntype="struct" hint="Get the configured listeners">
		<cfreturn instance.listeners>
	</cffunction>
	
	<!--- parseAndLoad --->
	<cffunction name="parseAndLoad" output="false" access="public" returntype="void" hint="Parse and load a config xml object">
		<cfargument name="xmlDoc" type="any" required="true" hint="The xml document object to use for parsing."/>
		<cfscript>
			var xml 		 = arguments.xmlDoc;
			var logBoxXML	 = xmlSearch(xml,"//LogBoxConfig");
			var defaultXML	 = xmlSearch(xml,"//DefaultConfiguration");
			var cachesXML	 = xmlSearch(xml,"//CacheBox/Cache");
			var listenersXML = xmlSearch(xml,"//Listener");
			var args = structnew();
			var x =1;
			var y =1;
			
			// Default Cache Config Check
			if( NOT arrayLen(defaultXML) ){
				$throw(message="The defaultcache configuration cannot be found and it is mandatory",type="CacheBoxConfig.DefaultCacheConfigurationNotFound");
			}
			// Register Default Cache
			defaultCache(argumentCollection=defaultXML[1].XMLAttributes);
			
			// Register LogBox Configuration
			logBoxConfig( variables.defaults.logBoxConfig );
			if( arrayLen(logBoxXML) ){
				logBoxConfig( trim(logBoxXML[1].XMLText) );
			}
			
			// Register Caches
			for(x=1; x lte arrayLen( cachesXML ); x++){
				// Add arguments
				args = {};
				structAppend(args,cachesXML[x].XMLAttributes);
				// Check if properties exist
				if( structKeyExists(cachesXML[x],"Properties") ){
					args.properties = cachesXML[x].properties.XMLAttributes;
				}
				cache(argumentCollection=args);
			}
			
			// Register listeners
			for(x=1; x lte arrayLen( listenersXML ); x++){
				// Add arguments
				args = {};
				structAppend(args,listenersXML[x].XMLAttributes);
				
				// Check if properties exist
				if( structKeyExists(listenersXML[x],"Properties") ){
					args.properties = listenersXML[x].properties.XMLAttributes;
				}
				listener(argumentCollection=args);
			}		
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- Throw Facade --->
	<cffunction name="$throw" access="private" hint="Facade for cfthrow" output="false">
		<!--- ************************************************************* --->
		<cfargument name="message" 	type="string" 	required="yes">
		<cfargument name="detail" 	type="string" 	required="no" default="">
		<cfargument name="type"  	type="string" 	required="no" default="Framework">
		<!--- ************************************************************* --->
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>
	
		<!--- Dump facade --->
	<cffunction name="$dump" access="private" hint="Facade for cfmx dump" returntype="void" output="false">
		<cfargument name="var" required="yes" type="any">
		<cfargument name="isAbort" type="boolean" default="false" required="false" hint="Abort also"/>
		<cfdump var="#var#">
		<cfif arguments.isAbort><cfabort></cfif>
	</cffunction>
	
	<!--- Abort Facade --->
	<cffunction name="$abort" access="private" hint="Facade for cfabort" returntype="void" output="false">
		<cfabort>
	</cffunction>
	
</cfcomponent>