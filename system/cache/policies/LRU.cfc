<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	11/14/2007
Description :
	This is the LRU or least recently used algorithm for cachebox.
	It basically discards the least recently used items first according to the last accessed date.
	This is also the default algorithm for CacheBox.
	
	For more information visit: http://en.wikipedia.org/wiki/Least_Recently_Used

----------------------------------------------------------------------->
<cfcomponent output="false" 
			 hint="LRU Eviction Policy Command" 
			 extends="coldbox.system.cache.policies.AbstractEvictionPolicy">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="LRU" hint="Constructor">
		<cfargument name="cacheProvider" type="coldbox.system.cache.ICacheProvider" required="true" hint="The associated cache provider"/>
		<cfscript>
			super.init(arguments.cacheProvider);
			
			return this;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- execute --->
	<cffunction name="execute" output="false" access="public" returntype="void" hint="Execute the policy">
		<cfscript>
			var oCacheManager 	= getAssociatedCache();
			var poolMD 			= oCacheManager.getStoreMetadataReport();
			var LRUIndex 		= "";
			var indexLength 	= 0;
			var x 				= 1;
			var md 				= "";
			var evictCount 		= oCacheManager.getConfiguration().evictCount;
			var evictedCounter 	= 0;
			
			// Get searchable index
			try{
				LRUIndex    = structSort(poolMD,"numeric", "ASC", "LastAccesed");
				indexLength = ArrayLen(LRUIndex);
			}
			catch(Any e){
				getLogger().error("Error sorting metadata pool. #e.message# #e.detail#. Serialized Pool: #poolMD.toString()#. Serialized LRUIndex: #LRUIndex.toString()#");
			}
			
			//Loop Through Metadata
			for (x=1; x lte indexLength; x=x+1){
				
				//get object metadata and verify it
				if( NOT structKeyExists(poolMD, LRUIndex[x]) ){
					continue;
				}
				md = poolMD[ LRUIndex[x] ];
				
				// Evict if not already marked for eviction or an eternal object.
				if( md.timeout gt 0 AND NOT md.isExpired ){
					// Expire Key
					oCacheManager.expireKey( LRUIndex[x] );
					
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

<!------------------------------------------- PRIVATE ------------------------------------------->

	
	
</cfcomponent>