<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	11/14/2007
Description :
	This is an AbstractEviction Policy object.
----------------------------------------------------------------------->
<cfcomponent name="LRU" 
			 output="false" 
			 hint="LFU Eviction Policy Command" 
			 extends="coldbox.system.cache.policies.AbstractEvictionPolicy">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="LRU" hint="Constructor">
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
			var objStruct = getCacheManager().getObjectPool().getpool_metadata();
			var LRUhitIndex = structSort(objStruct,"numeric", "ASC", "LastAccessTimeout");
			var indexLength = ArrayLen(LRUhitIndex);
			var x = 1;
			
			//Loop Through Metadata
			for (x=1; x lte indexLength; x=x+1){
				//Override Eternal Checks
				if ( objStruct[LRUhitIndex[x]].Timeout gt 0 ){
					//Evict it
					getCacheManager().expireKey(LRUhitIndex[x]);
					//Record Eviction 
					getCacheManager().getCacheStats().evictionHit();
					break;
				}//end timeout gt 0
			}//end for loop
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	
	
</cfcomponent>