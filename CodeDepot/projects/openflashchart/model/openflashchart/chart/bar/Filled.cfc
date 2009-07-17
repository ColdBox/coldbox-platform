<cfcomponent output="false" extends="ofcplugin.model.openflashchart.chart.Bar">

	<cffunction name="init" access="public" returntype="Struct">
		<cfset super.init()>
		<cfreturn this>
	</cffunction>

	<cffunction name="setOutlineColor" access="public" returntype="void">
		<cfargument name="outLineColor" type="string" required="true" hint="e.g. HTML color">
		<cfset this.outline_color = arguments.outLineColor>		
	</cffunction>

	<cffunction name="getOutlineColor" access="public" returntype="string" hint="Returns Outline Color">
		<cfreturn this.outline_color>
	</cffunction>	 
		
	<cffunction name="getData" access="public" returntype="struct" hint="Returns chart data">
		<cfset var data = super.getData()>
		
		<!--- set type --->
		<cfset data.type = 'bar_filled'>
				
		<!--- outLineColor? --->
		<cfif isDefined("this.outLine_color")>
			<cfset data.outline_color = this.outline_color>
		</cfif>
		
		<cfreturn data>
	</cffunction>	
</cfcomponent>