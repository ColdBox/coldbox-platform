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
		<cfargument name="cacheProvider" type="any" required="true" hint="The associated cache provider of type: coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider"/>
		<cfscript>
			super.init(arguments.cacheProvider);
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- execute --->
	<cffunction name="execute" output="false" access="public" returntype="void" hint="Execute the policy">
		<cfscript>
			var index 		= "";
			
			// Get searchable index
			try{
				index 	= getAssociatedCache().getObjectStore().getIndexer().getSortedKeys("hits","numeric","asc");
				// process evictions
				processEvictions( index );
			}
			catch(Any e){
				getLogger().error("Error sorting via store indexer #e.message# #e.detail# #e.stackTrace#.");
			}		
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->


</cfcomponent>