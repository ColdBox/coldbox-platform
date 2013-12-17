<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="any" hint="constructor">
		<cfreturn this>
	</cffunction>
	
	<!--- getData --->
	<cffunction name="getData" output="false" access="public" returntype="any" hint="Get sample data">
		<cfset var data = {
			name = "Luis majano",
			age = 32,
			date = now()		
		}>
		<cfreturn data>
	</cffunction>

</cfcomponent>