<cfcomponent output="false" displayname="fwsettings" hint="I am the Dashboard Framework Settings model.">

	<!--- Constructor --->
	<cfset variables.instance = structnew()>
	
	<cffunction name="init" access="public" returntype="fwsettings" output="false">
		
		<cfreturn this>
	</cffunction>
	


</cfcomponent>