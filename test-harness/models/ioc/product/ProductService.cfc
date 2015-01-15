<cfcomponent name="ProductService">

	<cfproperty name="categoryService" inject="model">

	<cffunction name="init" output="false" returntype="any">
		<cfargument name="productDAO" 	type="any" required="true" inject="model">
		<cfscript>
			variables.productDAO = arguments.productDAO;
			
			return this;
		</cfscript>
	</cffunction>
		
	<cffunction name="getProductDAO" output="false" returntype="any">
		<cfreturn variables.ProductDAO>
	</cffunction>
	
	<cffunction name="getCategoryService" output="false" returntype="any">
		<cfreturn variables.CategoryService>
	</cffunction>
	
</cfcomponent>