<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	11/14/2007
Description :
	This is a FIFO eviction Policy
----------------------------------------------------------------------->
<cfcomponent name="FIFO" 
			 output="false" 
			 hint="FIFO Eviction Policy Command" 
			 extends="coldbox.system.cache.policies.AbstractEvictionPolicy">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="FIFO" hint="Constructor">
		<cfargument name="cacheManager" type="coldbox.system.cache.CacheManager" required="true" hint="The cache manager"/>
		<cfscript>
			setCacheManager(arguments.cacheManager);
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- execute --->
	<cffunction name="execute" output="false" access="public" returntype="void" hint="Execute the policy">
		<cfscript>
			var poolMD = getCacheManager().getPoolMetadata(deepCopy=false);
			var FIFOIndex = "";
			var indexLength = 0;
			var x = 1;
			var md = "";
		
			// Get searchable index
			try{
				FIFOIndex = structSort(poolMD,"numeric", "ASC", "Created");
			}
			catch(Any e){
				$log("error","Error sorting metadata pool. #e.message# #e.detail#. Serialized Pool: #poolMD.toString()#");
			}
			indexLength = ArrayLen(FIFOIndex);
			
			//Loop Through Metadata
			for (x=1; x lte indexLength; x=x+1){
				//get object metadata and verify it
				md = getCacheManager().getCachedObjectMetadata(FIFOIndex[x]);
				if( structIsEmpty(md) ){ continue; }
				
				//Override Eternal Checks
				if ( md.timeout gt 0 AND NOT md.isExpired ){
					//Evict it
					getCacheManager().expireKey(FIFOIndex[x]);
					//Record Eviction 
					getCacheManager().getCacheStats().evictionHit();
					break;
				}//end timeout gt 0
			}//end for loop			
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->


</cfcomponent>