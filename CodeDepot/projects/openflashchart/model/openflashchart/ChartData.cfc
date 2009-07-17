<cfcomponent output="false">
	
	<!--- constructor --->
	<cffunction name="init" access="public" returntype="Struct">
		<cfset this.elements = ArrayNew(1)>
		<cfreturn this>
	</cffunction>

	<cffunction name="addElement" access="public" returntype="void" hint="Adds a chart element">
		<cfargument name="element" type="Any" required="true">
		<cfset ArrayAppend(this.elements,arguments.element)>
	</cffunction>
	 
 	<cffunction name="setTitle" access="public" returntype="void" hint="Sets title chart element">
		<cfargument name="title" type="Any" required="true">
		<cfset this.title = arguments.title>
	</cffunction>
	 
 	<cffunction name="getTitle" access="public" returntype="any" hint="">
		<cfreturn this.title>
	</cffunction>

	<cffunction name="setTooltip" access="public" returntype="void">
		<cfargument name="tooltip" type="Any" required="true" hint="">
		<cfset this.tooltip = arguments.tooltip>		
	</cffunction>

	<cffunction name="getTooltip" access="public" returntype="Any" hint="Returns tooltip">
		<cfreturn this.tooltip>
	</cffunction>
	
	<cffunction name="setXAxis" access="public" returntype="void" hint="Sets xAxis chart Element">
		<cfargument name="xAxis" type="Any" required="true">
		<cfset this.xAxis = arguments.xAxis>
	</cffunction>

 	<cffunction name="getXAxis" access="public" returntype="any" hint="">
		<cfreturn this.xAxis>
	</cffunction>
	
	<cffunction name="setYAxis" access="public" returntype="void" hint="Sets yAxis chart element">
		<cfargument name="yAxis" type="Any" required="true">
		<cfset this.yAxis = arguments.yAxis>
	</cffunction>

 	<cffunction name="getYAxis" access="public" returntype="any" hint="">
		<cfreturn this.yAxis>
	</cffunction>

	<cffunction name="setYAxisRight" access="public" returntype="void" hint="Sets right yAxis chart element">
		<cfargument name="yAxis" type="Any" required="true">
		<cfset this.yAxisRight = arguments.yAxisRight>
	</cffunction>

	<cffunction name="getRightYAxis" access="public" returntype="void" hint="Sets right yAxis chart element">
		<cfreturn this.yAxisrRight>
	</cffunction>
		 
	<cffunction name="setRadarXAxis" access="public" returntype="void">
		<cfargument name="radarXAxis" type="Any" required="true" hint="">
		<cfset this.radarXAxis = arguments.radarXAxis>		
	</cffunction>

	<cffunction name="getRadarXAxis" access="public" returntype="any" hint="Returns radarXAxis">
		<cfreturn this.radarXAxis>
	</cffunction>

	<cffunction name="setXLegend" access="public" returntype="void">
		<cfargument name="xLegend" type="Any" required="true" hint="">
		<cfset this.xLegend = arguments.xLegend>		
	</cffunction>

	<cffunction name="getXLegend" access="public" returntype="Any" hint="Returns xLegend">
		<cfreturn this.xLegend>
	</cffunction>
	
	<cffunction name="setYLegend" access="public" returntype="void">
		<cfargument name="yLegend" type="Any" required="true" hint="">
		<cfset this.yLegend = arguments.yLegend>		
	</cffunction>

	<cffunction name="getYLegend" access="public" returntype="Any" hint="Returns yLegend">
		<cfreturn this.yLegend>
	</cffunction>				 
			 
	<cffunction name="setBackGroundColor" access="public" returntype="void" hint="Sets background color of the chart">
		<cfargument name="color" type="Any" required="true">
		<cfset this.backGroundColor = arguments.color>
	</cffunction>	
	
	<cffunction name="getBackGroundColor" access="public" returntype="string" hint="Returns BGColor">
		<cfreturn this.backGroundColor>
	</cffunction>
	
	<cffunction name="getData" access="public" returntype="struct" hint="Returns chart data">
		<cfset var data = StructNew()>
		<cfset data.elements = ArrayNew(1)>
		
		<!--- title? --->
		<cfif isDefined("this.title")>
			<cfset data.title = this.title.getData()>
		</cfif>
		<!--- tooltip? --->
		<cfif isDefined("this.tooltip")>
			<cfset data.tip = this.tooltip.getData()>
		</cfif>
		<!--- xAxis? --->
		<cfif isDefined("this.xAxis")>
			<cfset data.xA_axis = this.xAxis.getData()>
		</cfif>
		<!--- yAxis? --->
		<cfif isDefined("this.yAxis")>
			<cfset data.y_axis = this.yAxis.getData()>
		</cfif>
		<!--- yAxisRight? --->
		<cfif isDefined("this.yAxisRight")>
			<cfset data.y_axis_right = this.yAxisRight.getData()>
		</cfif>
		<!--- radarXAxis? --->
		<cfif isDefined("this.radarXAxis")>
			<cfset data.radar_axis = this.radarXAxis.getData()>
		</cfif>
		<!--- yLegend? --->
		<cfif isDefined("this.yLegend")>
			<cfset data.y_legend = this.yLegend.getData()>
		</cfif>
		<!--- xLegend? --->
		<cfif isDefined("this.xLegend")>
			<cfset data.x_legend = this.xLegend.getData()>
		</cfif>
		<!--- backgroundColor? --->
		<cfif isDefined("this.backGroundColor")>
			<cfset data.bg_colour = this.backGroundColor>
		</cfif>
		
		<!--- Loop all elements --->
		<cfloop index="i" from="1" to="#ArrayLen(this.elements)#">
			<!--- Append element's data --->
			<cfset ArrayAppend(data.elements,this.elements[i].getData())>
		</cfloop>	
			
		<cfreturn data>
	</cffunction>

</cfcomponent>