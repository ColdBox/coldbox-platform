<cfcomponent name="CategoryService">

<cffunction name="init" output="false" returntype="any">
	<cfargument name="CategoryDAO" type="any">
	<cfscript>
		variables.CategoryDAO = CategoryDAO;
	</cfscript>
	<cfreturn THIS>
</cffunction>

<cffunction name="setProductService" output="false" returntype="void">
	<cfargument name="ProductService" required="true" type="any">
	<cfset variables.ProductService = ProductService>
</cffunction>

<cffunction name="getCategoryDAO" output="false" returntype="any">
	<cfreturn variables.CategoryDAO>
</cffunction>

<cffunction name="getProductService" output="false" returntype="any">
	<cfreturn variables.ProductService>
</cffunction>

</cfcomponent>