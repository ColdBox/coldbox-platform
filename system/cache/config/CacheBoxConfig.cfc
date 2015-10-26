<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	3/13/2009
Description :
	This is a CacheBox configuration object.  You can use it to configure
	a CacheBox instance.
----------------------------------------------------------------------->
<cfcomponent output="false" hint="This is a CacheBox configuration object.  You can use it to configure a CacheBox instance">

	<cfscript>
		// Utility class
		utility  = createObject("component","coldbox.system.core.util.Util");

		// Instance private scope
		instance = structnew();

		// CacheBox Provider Defaults
		DEFAULTS = {
			logBoxConfig = "coldbox.system.cache.config.LogBox",
			cacheBoxProvider = "coldbox.system.cache.providers.CacheBoxProvider",
			coldboxAppProvider = "coldbox.system.cache.providers.CacheBoxColdBoxProvider",
			scopeRegistration = {
				enabled = true,
				scope = "application",
				key = "cachebox"
			}
		};

		// Startup the configuration
		reset();
	</cfscript>

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="CacheBoxConfig" hint="Constructor">
		<cfargument name="CFCConfig" 		type="any" 		required="false" hint="The cacheBox Data Configuration CFC"/>
		<cfargument name="CFCConfigPath" 	type="string" 	required="false" hint="The cacheBox Data Configuration CFC path to use"/>
		<cfscript>
			var cacheBoxDSL = "";

			// Test and load via Data CFC Path
			if( structKeyExists( arguments, "CFCConfigPath" ) ){
				arguments.CFCConfig = createObject( "component", arguments.CFCConfigPath );
			}

			// Test and load via Data CFC
			if( structKeyExists( arguments, "CFCConfig" ) and isObject( arguments.CFCConfig ) ){
				// Decorate our data CFC
				arguments.CFCConfig.getPropertyMixin = utility.getMixerUtil().getPropertyMixin;
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
    	<cfreturn variables.DEFAULTS>
    </cffunction>

	<!--- logBoxConfig --->
    <cffunction name="logBoxConfig" output="false" access="public" returntype="any" hint="Set the logBox Configuration to use">
    	<cfargument name="config" type="string" required="true" hint="The configuration file to use"/>
		<cfset instance.logBoxConfig = arguments.config>
		<cfreturn this>
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
				throw("No default cache defined","Please define the 'defaultCache'","CacheBoxConfig.NoDefaultCacheFound");
			}

			// Register Default Cache
			defaultCache(argumentCollection=cacheBoxDSL.defaultCache);

			// Register LogBox Configuration
			logBoxConfig( variables.DEFAULTS.logBoxConfig );
			if( structKeyExists( cacheBoxDSL, "logBoxConfig") ){
				logBoxConfig(cacheBoxDSL.logBoxConfig);
			}

			// Register Server Scope Registration
			if( structKeyExists( cacheBoxDSL, "scopeRegistration") ){
				scopeRegistration(argumentCollection=cacheBoxDSL.scopeRegistration);
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
			// Scope Registration
			instance.scopeRegistration = {
				enabled = false,
				scope 	= "server",
				key		= "cachebox"
			};
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
				throw(message="Invalid Configuration. No default cache defined",type="CacheBoxConfig.NoDefaultCacheFound");
			}
		</cfscript>
	</cffunction>

	<!--- scopeRegistration --->
    <cffunction name="scopeRegistration" output="false" access="public" returntype="any" hint="Use to define cachebox factory scope registration">
    	<cfargument name="enabled" 	type="boolean" 	required="false" default="#DEFAULTS.scopeRegistration.enabled#" hint="Enable registration"/>
		<cfargument name="scope" 	type="string" 	required="false" default="#DEFAULTS.scopeRegistration.scope#" hint="The scope to register on, defaults to application scope"/>
		<cfargument name="key" 		type="string" 	required="false" default="#DEFAULTS.scopeRegistration.key#" hint="The key to use in the scope, defaults to cachebox"/>
		<cfscript>
			instance.scopeRegistration.enabled 	= arguments.enabled;
			instance.scopeRegistration.key 		= arguments.key;
			instance.scopeRegistration.scope 	= arguments.scope;

			return this;
		</cfscript>
    </cffunction>

	<!--- getScopeRegistration --->
    <cffunction name="getScopeRegistration" output="false" access="public" returntype="struct" hint="Get the scope registration details">
    	<cfreturn instance.scopeRegistration>
    </cffunction>

	<!--- defaultCache --->
	<cffunction name="defaultCache" output="false" access="public" returntype="any" hint="Add a default cache configuration.">
		<cfargument name="objectDefaultTimeout" 			type="numeric" required="false">
	    <cfargument name="objectDefaultLastAccessTimeout"   type="numeric" required="false">
	    <cfargument name="reapFrequency" 					type="numeric" required="false">
	    <cfargument name="maxObjects" 						type="numeric" required="false">
	    <cfargument name="freeMemoryPercentageThreshold" 	type="numeric" required="false">
	    <cfargument name="useLastAccessTimeouts"			type="boolean" required="false">
	    <cfargument name="evictionPolicy"					type="string"  required="false">
	    <cfargument name="evictCount"						type="numeric" required="false">
	    <cfargument name="objectStore" 						type="string"  required="false">
	    <cfargument name="coldboxEnabled" 					type="boolean" required="false"/>
	    <cfscript>
	    	var cacheConfig = getDefaultCache();

			// Append all incoming arguments to configuration, just in case using non-default arguments, maybe for stores
			structAppend(cacheConfig, arguments);

			// coldbox enabled context
			if( structKeyExists(arguments,"coldboxEnabled") AND arguments.coldboxEnabled ){
				cacheConfig.provider = variables.DEFAULTS.coldboxAppProvider;
			}
			else{
				cacheConfig.provider = variables.DEFAULTS.cacheboxProvider;
			}

			return this;
		</cfscript>
	</cffunction>

	<!--- defaultCache --->
	<cffunction name="getDefaultCache" access="public" returntype="struct" output="false" hint="Get the defaultCache definition.">
		<cfreturn instance.defaultCache>
	</cffunction>

	<!--- cache --->
	<cffunction name="cache" output="false" access="public" returntype="any" hint="Add a new cache configuration.">
		<cfargument name="name" 		type="string" required="true"   hint="The name of the cache"/>
		<cfargument name="provider" 	type="string" required="false"  default="#variables.DEFAULTS.cacheBoxProvider#" hint="The cache provider class, defaults to: coldbox.system.cache.providers.CacheBoxProvider"/>
		<cfargument name="properties" 	type="struct" required="false"  default="#structNew()#" hint="The structure of properties for the cache"/>
		<cfscript>
			instance.caches[arguments.name] = {
				provider 	= arguments.provider,
				properties 	= arguments.properties
			};
			return this;
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
	<cffunction name="listener" output="false" access="public" returntype="any" hint="Add a new listener configuration.">
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

			return this;
		</cfscript>
	</cffunction>

	<!--- getListeners --->
	<cffunction name="getListeners" output="false" access="public" returntype="array" hint="Get the configured listeners">
		<cfreturn instance.listeners>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>

</cfcomponent>