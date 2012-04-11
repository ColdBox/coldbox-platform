<cfcomponent name="Product">

	<cffunction name="init" output="false" returntype="any">
		<cfargument name="ProductDAO" type="any" required="true" inject="model">
		<cfscript>
			variables.ProductDAO = ProdDAO;
		</cfscript>
		<cfreturn THIS>
	</cffunction>
	
	<cffunction name="getProductDAO" output="false" returntype="any">
		<cfreturn variables.ProductDAO>
	</cffunction>

</cfcomponent>