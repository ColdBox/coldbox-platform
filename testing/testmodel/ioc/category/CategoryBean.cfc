<cfcomponent name="Category">
	
	<cfproperty name="categoryService" inject="model">
	
	<cffunction name="init" output="false" returntype="any">
		<cfargument name="jsonProperty" inject="model">
		<cfset variables.jsonProperty = arguments.jsonProperty>
		<cfreturn THIS>
	</cffunction>

</cfcomponent>