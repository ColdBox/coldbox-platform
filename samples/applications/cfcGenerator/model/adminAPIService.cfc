<cfcomponent name="adminAPIService" output="false">
	
	<cffunction name="init" access="public" output="false" returntype="adminAPIService">
		<cfargument name="administratorPassword" type="string" required="true" />
		
		<cfset variables.administrator = createObject("component","cfide.adminapi.administrator").login(arguments.administratorPassword) />
		<cfset variables.datasource = createObject("component","cfide.adminapi.datasource") />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getDatasources" access="public" output="false" returntype="struct">
		<cfreturn variables.datasource.getdatasources() />	
	</cffunction>
	
</cfcomponent>