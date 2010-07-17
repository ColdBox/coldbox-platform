<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	11/14/2007
Description :
	This is the LFU or least frequently used algorithm for cachebox.
	Removes entities from the cache that are used the least.
	
	More information can be found here:
	http://en.wikipedia.org/wiki/Least_Frequently_Used
----------------------------------------------------------------------->
<cfcomponent name="LFU" 
			 output="false" 
			 hint="LFU Eviction Policy Command" 
			 extends="coldbox.system.cache.policies.AbstractEvictionPolicy">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="LFU" hint="Constructor">
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
			var LFUIndex 		= "";
			var indexLength 	= 0;
			var x 				= 1;
			var md 				= "";
			var evictCount 		= oCacheManager.getConfiguration().evictCount;
			var evictedCounter 	= 0;
			
			// Get searchable index
			try{
				LFUIndex 	= structSort(poolMD, "numeric", "ASC", "hits");
				indexLength = ArrayLen(LFUIndex);
			}
			catch(Any e){
				getLogger().error("Error sorting metadata pool. #e.message# #e.detail#. Serialized Pool: #poolMD.toString()#. Serialized LFUIndex: #LFUIndex.toString()#");
			}
			
			//Loop Through Metadata
			for (x=1; x lte indexLength; x=x+1){
				
				//get object metadata and verify it
				if( NOT structKeyExists(poolMD, LFUIndex[x]) ){
					continue;
				}
				md = poolMD[ LFUIndex[x] ];
				
				//Override Eternal Checks
				if ( md.timeout gt 0 AND NOT md.isExpired ){
					// Expire Key
					oCacheManager.expireKey( LFUIndex[x] );
					
					// Record Eviction 
					oCacheManager.getStats().evictionHit();
					evictedCounter++;
					
					// Can we break or keep on evicting
					if( evictedCounter GTE evictCount ){
						break;
					}
				}//end timeout gt 0
			}//end for loop			
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->


</cfcomponent>