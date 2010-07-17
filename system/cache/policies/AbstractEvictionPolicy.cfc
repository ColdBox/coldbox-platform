<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	11/14/2007
Description :
	This is an AbstractEviction Policy object.
----------------------------------------------------------------------->
<cfcomponent hint="An abstract CacheBox eviction policy" output="false" serializable="false" implements="coldbox.system.cache.policies.IEvictionPolicy">

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="any" hint="Constructor">
		<cfargument name="cacheProvider" type="coldbox.system.cache.ICacheProvider" required="true" hint="The associated cache provider"/>
		<cfscript>
			// link associated cache
			variables.cacheProvider = arguments.cacheProvider;
			// setup logger
			variables.logger = arguments.cacheProvider.getCacheFactory().getLogBox().getLogger( this );
			variables.logger.debug("Policy #getMetadata(this).name# constructed for cache: #arguments.cacheProvider.getname()#");
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- execute --->
	<cffunction name="execute" output="false" access="public" returntype="void" hint="Execute the eviction policy on the associated cache">
		<!--- Implemented by Concrete Classes --->
		<cfthrow message="Abstract method, please implement" type="AbstractMethodException">
	</cffunction>
	
	<!--- Get Associated Cache --->
	<cffunction name="getAssociatedCache" access="public" returntype="coldbox.system.cache.ICacheProvider" output="false" hint="Get the Associated Cache Provider">
		<cfreturn variables.cacheProvider>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- getLogger --->
    <cffunction name="getLogger" output="false" access="private" returntype="any" hint="Get a logbox logger for the policy">
    	<cfreturn variables.logger>
    </cffunction>
	
	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a ColdBox utility object">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>
		
</cfcomponent>