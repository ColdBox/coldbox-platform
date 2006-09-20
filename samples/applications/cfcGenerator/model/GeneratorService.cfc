<cfcomponent output="false" displayname="GeneratorService" hint="I am the Generator Service.">

	<!--- Constructor --->
	<cfset variables.instance = structnew()>
	
	<cffunction name="init" access="public" returntype="GeneratorService" output="false">
		<cfargument name="adminpass" required="true" type="string">
		<cfset variables.instance.adminAPIService = createObject("component","adminAPIService").init(arguments.adminpass) />
		<cfset variables.instance.mysql = createObject("component","mysql").init() />
		<cfset variables.instance.mssql = createObject("component","mssql").init() />
		<cfset variables.instance.oracle = createObject("component","oracle").init() />
		<cfset variables.instance.xsl = createObject("component","xslService").init() />
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getModel" access="public" returntype="any" output="false">
		<cfargument name="model" required="true" type="string" >
		<cfreturn instance["#arguments.model#"]>
	</cffunction>

</cfcomponent>