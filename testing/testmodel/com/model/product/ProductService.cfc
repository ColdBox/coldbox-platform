<cfcomponent name="ProductService">

<cffunction name="init" output="false" returntype="any">
	<cfargument name="ProdDAO" type="any" required="true">
	<cfargument name="MyTitle" type="any" required="true">
	<cfargument name="MyTitle2" type="any" required="true">
	<cfscript>
		variables.ProductDAO = ProdDAO;
		variables.MyTitle = MyTitle;
		variables.MyTitle2 = MyTitle2;
		THIS.MyTitle = MyTitle;
		THIS.MyTitle2 = MyTitle2;
	</cfscript>
	<cfreturn THIS>
</cffunction>

<cffunction name="setCategoryService" output="false" returntype="void">
	<cfargument name="CategoryService" required="true" type="any">
	<cfset variables.CategoryService = CategoryService>
</cffunction>

<cffunction name="setMySetterTitle" output="false" returntype="void">
	<cfargument name="MySetterTitle" required="true" type="string">
	<cfset variables.MySetterTitle = MySetterTitle>
	<cfset THIS.MySetterTitle = MySetterTitle>
</cffunction>


<cffunction name="getProductDAO" output="false" returntype="any">
	<cfreturn variables.ProductDAO>
</cffunction>

<cffunction name="getCategoryService" output="false" returntype="any">
	<cfreturn variables.CategoryService>
</cffunction>

<cffunction name="getMyMixinTitle" output="false" returntype="string">
	<cfreturn variables.MyMixinTitle>
</cffunction>

<cffunction name="getAnotherMixinProperty" output="false" returntype="string">
	<cfreturn variables.AnotherMixinProperty>
</cffunction>

</cfcomponent>