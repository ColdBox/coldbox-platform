<cfcomponent output="false">

	<!--- configure --->
    <cffunction name="configure" output="false" access="public">
    	<cfargument name="cacheBox" 	type="any"/>
		<cfargument name="properties" 	type="struct"/>
		<cfscript>
			variables.cacheBox = arguments.cacheBox;
			variables.properties = arguments.properties;
			
			variables.log = variables.cacheBox.getLogBox().getLogger(this);
		</cfscript>
    </cffunction>

	<!--- afterCacheElementInsert --->
    <cffunction name="afterCacheElementInsert" output="false" access="public" returntype="any" hint="">
    	<cfargument name="interceptData" type="struct"/>		
		<cfset log.info("#properties.name# -> afterCacheElementInsert called", arguments.interceptData.toString())>
    </cffunction>

	<!--- beforeCacheShutdown --->
    <cffunction name="beforeCacheShutdown" output="false" access="public" returntype="any" hint="">
    	<cfargument name="interceptData" type="struct"/>
		<cfset log.info("#properties.name# -> beforeCacheShutdown called", arguments.interceptData.toString())>
    </cffunction>
	
	<!--- afterCacheFactoryConfiguration --->
    <cffunction name="afterCacheFactoryConfiguration" output="false" access="public" returntype="any" hint="">
    	<cfargument name="interceptData" type="struct"/>
		<cfset log.info("#properties.name# -> afterCacheFactoryConfiguration called", arguments.interceptData.toString())>
    </cffunction>
	

</cfcomponent>