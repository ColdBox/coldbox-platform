<cfcomponent outut="false">

	<!--- Dependencies --->
	<cfproperty name="forgeBoxAPI" inject="coldbox:myplugin:ForgeBox@forgebox">
	<cfproperty name="cache"	   inject="coldbox:cacheManager">

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="any" hint="Constructor">
		<cfscript>
			this.POPULAR = "popular";
			this.NEW	 = "new";
			this.RECENT  = "recent";
			
			return this;
		</cfscript>
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
	
	<!--- getEntries --->
	<cffunction name="getEntries" output="false" access="public" returntype="query" hint="Get entries">
		<cfargument name="orderBy"  type="string"  required="false" default="#this.POPULAR#" hint="The type to order by, look at this.ORDERBY"/>
		<cfargument name="maxrows"  type="numeric" required="false" default="0" hint="Max rows to return"/>
		<cfargument name="startRow" type="numeric" required="false" default="1" hint="StartRow"/>
		<cfargument name="typeSlug" type="string" required="false" default="" hint="The tye slug to filter on"/>
		<cfscript>
			var q = "";
			var cacheKey = "forge-q-entries-" & hash(arguments.toString());
			
			
			// Cache Lookups
			if( cache.lookup(cachekey) ){
				return cache.get(cacheKey);
			}
			
			q = forgeBoxAPI.getEntries(argumentCollection=arguments);
		
			// Cache with Defaults
			cache.set(cacheKey,q);
			
			return q;		
		</cfscript>
	</cffunction>
	
	
	

</cfcomponent>