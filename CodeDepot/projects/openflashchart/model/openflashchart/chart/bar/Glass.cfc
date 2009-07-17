<cfcomponent output="false" extends="ofcplugin.model.openflashchart.chart.Bar">

	<cffunction name="init" access="public" returntype="Struct">
		<cfset super.init()>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getData" access="public" returntype="struct" hint="Returns chart data">
		<cfset var data = super.getData()>
		
		<!--- set type --->
		<cfset data.type = 'bar_glass'>
		
		<cfreturn data>
	</cffunction>	
</cfcomponent>