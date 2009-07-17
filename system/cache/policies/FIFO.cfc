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
			var objStruct = getCacheManager().getObjectPool().getpool_metadata();
			var FIFOHitIndex = structSort(objStruct,"numeric", "ASC", "Created");
			var indexLength = ArrayLen(FIFOHitIndex);
			var x = 1;
		
			//Loop Through Metadata
			for (x=1; x lte indexLength; x=x+1){
				//Override Eternal Checks
				if ( objStruct[FIFOHitIndex[x]].Timeout gt 0 ){
					//Evict it
					getCacheManager().expireKey(FIFOHitIndex[x]);
					//Record Eviction 
					getCacheManager().getCacheStats().evictionHit();
					break;
				}//end timeout gt 0
			}//end for loop			
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->


</cfcomponent>