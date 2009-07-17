<cfcomponent output="false">

	<cffunction name="init" access="public" returntype="Struct">
		<cfreturn this>
	</cffunction>

	<cffunction name="setStyle" access="public" returntype="void">
		<cfargument name="style" type="String" required="true" hint="css style">
		<cfset this.style = arguments.style>		
	</cffunction>

	<cffunction name="getStyle" access="public" returntype="String" hint="Returns style">
		<cfreturn this.style>
	</cffunction>	

	<cffunction name="getData" access="public" returntype="struct" hint="Returns chart data">
		<cfset var data = StructNew()>
		<!--- style? --->
		<cfif isDefined("this.style")>
			<cfset data.style = this.style>
		</cfif>		
		<cfreturn data>
	</cffunction>		
</cfcomponent>