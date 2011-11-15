<cfcomponent name="CategoryService">

	<cfproperty name="productService" inject="model">

	<cffunction name="init" output="false" returntype="any">
		<cfargument name="categoryDAO" type="any" inject="model">
		<cfscript>
			variables.categoryDAO = arguments.categoryDAO;
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="getCategoryDAO" output="false" returntype="any">
		<cfreturn variables.CategoryDAO>
	</cffunction>
	
	<cffunction name="getProductService" output="false" returntype="any">
		<cfreturn variables.ProductService>
	</cffunction>
	
	<cffunction name="getjsonProperty" access="public" output="false" returntype="string" hint="Get jsonProperty">
		<cfreturn variables.jsonProperty/>
	</cffunction>
	
	<cffunction name="setjsonProperty" access="public" output="false" returntype="void" hint="Set jsonProperty">
		<cfargument name="myJsonProperty" type="string" required="true"/>
		<cfset variables.jsonProperty = arguments.myJsonProperty/>
	</cffunction>
	
	<cffunction name="setjsonProperty2" access="public" output="false" returntype="void" hint="Set jsonProperty">
		<cfargument name="jsonProperty2" type="string" required="true"/>
		<cfset variables.jsonProperty = arguments.jsonProperty2/>
	</cffunction>

</cfcomponent>