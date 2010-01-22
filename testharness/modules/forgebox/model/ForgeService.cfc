<cfcomponent outut="false">

	<!--- Dependencies --->
	<cfproperty name="forgeBoxAPI" inject="coldbox:myplugin:ForgeBox@forgebox">
	<cfproperty name="cache"	   inject="coldbox:cacheManager">

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="any" hint="Constructor">
		<cfreturn this>
	</cffunction>
	
	<!--- getTypes --->
	<cffunction name="getTypes" output="false" access="public" returntype="query" hint="Get the types">
		<cfscript>
			var q = "";
			
			// Cache Lookups
			if( cache.lookup("forge-q-types") ){
				return cache.get("forge-q-types");
			}
			
			q = forgeBoxAPI.getTypes();
			
			// Cache with Defaults
			cache.set("forge-q-types",q);
			
			return q;
		</cfscript>
	</cffunction>
	
	
	

</cfcomponent>