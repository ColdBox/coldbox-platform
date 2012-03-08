<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	11/14/2007
Description :
	This is a LIFO eviction Policy meaning that the first object placed on cache
	will be the last one to come out. This is usually a structure that represents
	a stack.

More information can be found here:
http://en.wikipedia.org/wiki/FIFO
----------------------------------------------------------------------->
<cfcomponent output="false" 
			 hint="LIFO Eviction Policy Command" 
			 extends="coldbox.system.cache.policies.AbstractEvictionPolicy">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="LIFO" hint="Constructor">
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
				index 	= getAssociatedCache().getObjectStore().getIndexer().getSortedKeys("Created","numeric","desc");
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