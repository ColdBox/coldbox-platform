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
<cfcomponent name="LRU" 
			 output="false" 
			 hint="LFU Eviction Policy Command" 
			 extends="coldbox.system.cache.archive.policies.AbstractEvictionPolicy">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="LRU" hint="Constructor">
		<cfargument name="cacheManager" type="coldbox.system.cache.archive.CacheManager" required="true" hint="The cache manager"/>
		<cfscript>
			setCacheManager(arguments.cacheManager);
			return this;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- execute --->
	<cffunction name="execute" output="false" access="public" returntype="void" hint="Execute the policy">
		<cfscript>
			var oCacheManager = getCacheManager();
			var poolMD = oCacheManager.getPoolMetadata(deepCopy=false);
			var LRUIndex = "";
			var indexLength = 0;
			var x = 1;
			var md = "";
			var evictCount = oCacheManager.getCacheConfig().getEvictCount();
			var evictedCounter = 0;
			
			// Get searchable index
			try{
				LRUIndex    = structSort(poolMD,"numeric", "ASC", "LastAccesed");
				indexLength = ArrayLen(LRUIndex);
			}
			catch(Any e){
				$log("error","Error sorting metadata pool. #e.message# #e.detail#. Serialized Pool: #poolMD.toString()#. Serialized LRUIndex: #LRUIndex.toString()#");
			}
			
			//Loop Through Metadata
			for (x=1; x lte indexLength; x=x+1){
				//get object metadata and verify it
				md = oCacheManager.getCachedObjectMetadata(LRUIndex[x]);
				if( structIsEmpty(md) ){ continue; }
				
				// Evict if not already marked for eviction or an eternal object.
				if( md.timeout gt 0 AND NOT md.isExpired ){
					// Expire Key
					oCacheManager.expireKey(LRUIndex[x]);
					// Record Eviction 
					oCacheManager.getCacheStats().evictionHit();
					evictedCounter = evictedCounter + 1;
					
					// Can we break or keep on evicting
					if( evictedCounter gte evictCount ){
						break;
					}			
				}
			}//end for loop
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	
	
</cfcomponent>