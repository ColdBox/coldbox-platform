<cfcomponent output="false">

	<cffunction name="init" access="public" returntype="Struct">
		<cfreturn this>
	</cffunction>

	<cffunction name="getData" access="public" returntype="struct" hint="Returns chart data">
		<cfset var data = StructNew()>
		<cfreturn data>
	</cffunction>		
</cfcomponent>