<cfcomponent output="false" displayname="GeneratorService" hint="I am the Generator Service.">
	<!--- Constructor --->
	<cfset variables.instance = structnew()>
	
	<cffunction name="init" access="public" returntype="GeneratorService" output="false">
		<cfargument name="adminpass" 	required="true" type="string" _wireme="coldbox:setting:adminpass">
		
		<cfset instance.adminAPIService = createObject("component","adminAPIService").init(arguments.adminpass) />
		<cfset instance.mysql = createObject("component","mysql").init() />
		<cfset instance.mssql = createObject("component","mssql").init() />
		<cfset instance.oracle = createObject("component","oracle").init() />
		<cfset instance.xsl = createObject("component","xslService").init() />
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getModel" access="public" returntype="any" output="false">
		<cfargument name="model" required="true" type="string" >
		<cfreturn instance["#arguments.model#"]>
	</cffunction>

</cfcomponent>