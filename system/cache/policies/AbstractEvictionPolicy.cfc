<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	11/14/2007
Description :
	This is an AbstractEviction Policy object for usage in a CacheBox provider
----------------------------------------------------------------------->
<cfcomponent hint="An abstract CacheBox eviction policy" 
			 output="false" 
			 serializable="false" 
			 implements="coldbox.system.cache.policies.IEvictionPolicy"
			 colddoc:abstract="true">

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="AbstractEvictionPolicy" hint="Constructor">
		<cfargument name="cacheProvider" type="any" required="true" hint="The associated cache provider of type: coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider"/>
		<cfscript>
			// link associated cache
			variables.cacheProvider = arguments.cacheProvider;
			// setup logger
			variables.logger = arguments.cacheProvider.getCacheFactory().getLogBox().getLogger( this );
			
			// Debug logging
			if( variables.logger.canDebug() ){
				variables.logger.debug("Policy #getMetadata(this).name# constructed for cache: #arguments.cacheProvider.getname()#");
			}
			
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
	<cffunction name="getAssociatedCache" access="public" returntype="any" output="false" hint="Get the Associated Cache Provider of type: coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider">
		<cfreturn variables.cacheProvider>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- processEvictions --->
    <cffunction name="processEvictions" output="false" access="private" returntype="void" hint="Abstract processing of evictions">
    	<cfargument name="index" type="any" required="true" hint="The array of metadata keys used for processing evictions"/>
    	<cfscript>
    		var oCacheManager 	= variables.cacheProvider;
			var indexer			= oCacheManager.getObjectStore().getIndexer();
			var indexLength 	= arrayLen(arguments.index);
			var x 				= 1;
			var md 				= "";
			var evictCount 		= oCacheManager.getConfiguration().evictCount;
			var evictedCounter 	= 0;
			
			//Loop Through Metadata
			for (x=1; x lte indexLength; x=x+1){
				
				// verify object in indexer
				if( NOT indexer.objectExists( arguments.index[x] ) ){
					continue;
				}
				md = indexer.getObjectMetadata( arguments.index[x] );
				
				// Evict if not already marked for eviction or an eternal object.
				if( md.timeout gt 0 AND NOT md.isExpired ){
					
					// Expire Object
					oCacheManager.expireObject( arguments.index[x] );
					
					// Record Eviction 
					oCacheManager.getStats().evictionHit();
					evictedCounter++;
					
					// Can we break or keep on evicting
					if( evictedCounter GTE evictCount ){
						break;
					}			
				}
			}//end for loop
    	</cfscript>
    </cffunction>

	<!--- getLogger --->
    <cffunction name="getLogger" output="false" access="private" returntype="any" hint="Get a logbox logger for the policy">
    	<cfreturn variables.logger>
    </cffunction>
	
	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="any" hint="Create and return a ColdBox utility object">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>
		
</cfcomponent>