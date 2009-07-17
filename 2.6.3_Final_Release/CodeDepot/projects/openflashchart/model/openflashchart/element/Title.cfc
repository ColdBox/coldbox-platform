<cfcomponent output="false" extends="ofcplugin.model.openflashchart.element.Base">

	<cffunction name="init" access="public" returntype="Struct">
		<cfargument name="text" type="String" required="true" hint="">
		<cfset super.init()>
		<cfset setText(arguments.text)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setText" access="public" returntype="void">
		<cfargument name="text" type="string" required="true" hint="">
		<cfset this.text = arguments.text>		
	</cffunction>

	<cffunction name="getText" access="public" returntype="string" hint="Returns text">
		<cfreturn this.text>
	</cffunction>

	<cffunction name="getData" access="public" returntype="struct" hint="Returns chart data">
		<cfset var data = super.getData()>
		<cfset data.text = this.text>
		<cfreturn data>
	</cffunction>
					
</cfcomponent>