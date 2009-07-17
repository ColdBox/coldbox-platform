<cfcomponent output="false" extends="ofcplugin.model.openflashchart.chart.Line">

	<cffunction name="init" access="public" returntype="Struct">
		<cfset super.init()>
		<cfreturn this>
	</cffunction>

	<cffunction name="getData" access="public" returntype="struct" hint="Returns chart data">
		<cfset var data = super.getData()>
		
		<!--- set type --->
		<cfset data.type = 'line_dot'>
		
		<cfreturn data>
	</cffunction>	
</cfcomponent>