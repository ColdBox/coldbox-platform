<cfcomponent output="false">

	<cfscript>
		variables.reload = false;
		variables.name = "Luis";
	</cfscript>

	<!--- getData --->
	<cffunction name="getData" output="false" access="public" returntype="any" hint="">
		<cfreturn 5>
	</cffunction>
	
	<cffunction name="getreload" access="public" returntype="boolean" output="false">
		<cfreturn variables.reload>
	</cffunction>
	
	<!--- getName --->
	<cffunction name="getFullName" output="false" access="public" returntype="string" hint="Get Full Name">
		<cfreturn getName()>
	</cffunction>
	<cffunction name="getName" output="false" access="private" returntype="string" hint="Get Name">
		<cfreturn variables.name>
	</cffunction>

</cfcomponent>