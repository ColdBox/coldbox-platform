<cfcomponent output="false" displayname="dbservice" hint="I am the Dashboard Service.">

	<!--- Constructor --->
	<cfset variables.instance = structnew()>
	
	<cffunction name="init" access="public" returntype="dbservice" output="false">
		<cfset instance.settings = CreateObject("component","settings").init()>
		<cfset instance.fwsettings = CreateObject("component","fwsettings").init()>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="get" access="public" returntype="any" output="false">
		<cfargument name="model" required="true" type="string" >
		<cfreturn instance["#arguments.model#"]>
	</cffunction>

</cfcomponent>