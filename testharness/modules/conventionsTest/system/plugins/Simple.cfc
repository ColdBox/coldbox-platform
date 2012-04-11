<cfcomponent output="false">
	
	<!--- getData --->
	<cffunction name="getData" output="false" access="public" returntype="any" hint="Get sample data">
		<cfset var data = {
			name = "Plugin Test",
			id = createUUID(),
			date = now()		
		}>
		<cfreturn data>
	</cffunction>

</cfcomponent>