<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	An abstract CacheBox Provider

Properties
- name : The cache name
- enabled : Boolean flag if cache is enabled
- reportingEnabled: Boolean falg if cache can report
- stats : The statistics object
- configuration : The configuration structure
- cacheFactory : The linkage to the cachebox factory
- eventManager : The linkage to the event manager
- cacheID : The unique identity code of this CFC
----------------------------------------------------------------------->
<cfcomponent hint="An abstract CacheBox Provider with basic/boring functionality built" 
			 output="false" 
			 serializable="false"
			 colddoc:abstract="true">
	
	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="any" hint="Simple Constructor">
    	<cfscript>
    		instance = {
				name 				= "",
				enabled 			= false,
				reportingEnabled 	= false,
				stats   			= "",
				configuration 		= {},
				cacheFactory 		= "",
				eventManager		= "",
				cacheID				= createObject('java','java.lang.System').identityHashCode(this)
			};
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- getCacheID --->
    <cffunction name="getCacheID" output="false" access="public" returntype="any" hint="The unique cache ID number">
    	<cfreturn instance.cacheID>
    </cffunction>

	<!--- getName --->
    <cffunction name="getName" output="false" access="public" returntype="string" hint="Get the name of this cache">
    	<cfreturn instance.name>
    </cffunction>
	
	<!--- setName --->
    <cffunction name="setName" output="false" access="public" returntype="void" hint="Set the cache name">
    	<cfargument name="name" type="string" required="true" hint="The cache name"/>
		<cfset instance.name = arguments.name>
    </cffunction>

	<!--- isEnabled --->
    <cffunction name="isEnabled" output="false" access="public" returntype="boolean" hint="Returns a flag indicating if the cache is ready for operation">
    	<cfreturn instance.enabled>
    </cffunction>
	
	<!--- isReportingEnabled --->
    <cffunction name="isReportingEnabled" output="false" access="public" returntype="boolean" hint="Returns a flag indicating if the cache has reporting enabled">
   		<cfreturn instance.reportingEnabled>
    </cffunction>

	<!--- getStats --->
    <cffunction name="getStats" output="false" access="public" returntype="any" hint="Get the cache statistics object as coldbox.system.cache.util.ICacheStats" colddoc:generic="coldbox.system.cache.util.ICacheStats">
    	<cfreturn instance.stats>
    </cffunction>
	
	<!--- clearStatistics --->
    <cffunction name="clearStatistics" output="false" access="public" returntype="void" hint="Clear the cache statistics">
    	<cfset instance.stats.clearStatistics()>
    </cffunction>

	<!--- getConfiguration --->
    <cffunction name="getConfiguration" output="false" access="public" returntype="struct" hint="Get the structure of configuration parameters for the cache">
    	<cfreturn instance.configuration>
    </cffunction>

	<!--- setConfiguration --->
    <cffunction name="setConfiguration" output="false" access="public" returntype="void" hint="Override the entire configuration structure for this cache">
    	<cfargument name="configuration" type="struct" required="true" hint="The configuration structure"/>
		<cfset instance.configuration = arguments.configuration>
    </cffunction>

	<!--- getCacheFactory --->
    <cffunction name="getCacheFactory" output="false" access="public" returntype="coldbox.system.cache.CacheFactory" hint="Get the cache factory reference this cache provider belongs to">
   		<cfreturn instance.cacheFactory>
    </cffunction>
	
	<!--- setCacheFactory --->
    <cffunction name="setCacheFactory" output="false" access="public" returntype="void" hint="Set the cache factory reference for this cache">
    	<cfargument name="cacheFactory" type="coldbox.system.cache.CacheFactory" required="true"/>
		<cfset instance.cacheFactory = arguments.cacheFactory>
    </cffunction>

	<!--- getEventManager --->
    <cffunction name="getEventManager" output="false" access="public" returntype="any" hint="Get this cache managers event listner manager">
    	<cfreturn instance.eventManager>
    </cffunction>
	
	<!--- setEventManager --->
    <cffunction name="setEventManager" output="false" access="public" returntype="void" hint="Set the event manager for this cache">
    	<cfargument name="eventManager" type="any" required="true" hint="The event manager class"/>
    	<cfset instance.eventManager = arguments.eventManager>
	</cffunction>
	
	<!--- getMemento --->
    <cffunction name="getMemento" output="false" access="public" returntype="any" hint="Return the cache provider's instance memento">
    	<cfreturn instance>
    </cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- Get Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a util object">
		<cfreturn CreateObject("component","coldbox.system.core.util.Util")/>
	</cffunction>	
	
	<!--- statusCheck --->
    <cffunction name="statusCheck" output="false" access="private" returntype="void" hint="Check if the cache is operational, else throw exception">
    	<cfif NOT isEnabled()>
    		<cfthrow message="The cache #getName()# is not yet enabled" detail="The cache was being accessed without the configuration being complete" type="IllegalStateException">
		</cfif>
    </cffunction>

	
</cfcomponent>