<cfcomponent output="false" extends="ofcplugin.model.openflashchart.chart.Bar">

	<cffunction name="init" access="public" returntype="Struct">
		<cfset super.init()>
		<cfreturn this>
	</cffunction>

	<cffunction name="setOutlineColor" access="public" returntype="void">
		<cfargument name="outLineColor" type="string" required="true" hint="e.g. HTML color">
		<cfset this.outLine_color = arguments.outLineColor>		
	</cffunction>

	<cffunction name="getOutlineColor" access="public" returntype="string" hint="Returns Outline Color">
		<cfreturn this.outLine_color>
	</cffunction>	 
	
	<cffunction name="setOffset" access="public" returntype="void">
		<cfargument name="offset" type="numeric" required="true" hint="fun factor">
		<cfset this.offset = arguments.offset>		
	</cffunction>

	<cffunction name="getOffset" access="public" returntype="numeric" hint="Returns offset">
		<cfreturn this.offset>
	</cffunction>	
	
	<cffunction name="getData" access="public" returntype="struct" hint="Returns chart data">
		<cfset var data = super.getData()>
		
		<!--- set type --->
		<cfset data.type = 'bar_sketch'>
		
		<!--- color? --->
		<cfif isDefined("this.colour")>
			<cfset data.colour = this.colour>
		</cfif>
		<!--- outLineColor? --->
		<cfif isDefined("this.outLine_color")>
			<cfset data.outLine_color = this.outLine_color>
		</cfif>
		<!--- offset? --->
		<cfif isDefined("this.offset")>
			<cfset data.offset = this.offset>
		</cfif>
		
		<cfreturn data>
	</cffunction>	
</cfcomponent>