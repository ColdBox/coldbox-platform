<cfcomponent output="false">

	<cffunction name="getDataFromDB" access="public" returntype="query" hint="A nice query from the db" output="false" >
		<cfset var q = 0>

		<cfquery name="q" datasource="coolblog">
		select * from categories
		where active = 0
		</cfquery>
		
		<cfreturn q>
	</cffunction>
	
</cfcomponent>