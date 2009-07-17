<cfcomponent name="Product">

<cffunction name="init" output="false" returntype="any">
	<cfargument name="ProdDAO" type="any" required="true">
	<cfscript>
		variables.ProductDAO = ProdDAO;
	</cfscript>
	<cfreturn THIS>
</cffunction>

<cffunction name="getProductDAO" output="false" returntype="any">
	<cfreturn variables.ProductDAO>
</cffunction>

</cfcomponent>