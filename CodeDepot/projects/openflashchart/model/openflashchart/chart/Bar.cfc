<cfcomponent output="false" extends="ofcplugin.model.openflashchart.chart.Base">

	<cffunction name="init" access="public" returntype="Struct">
		<cfset super.init()>
		<cfset this.values = ArrayNew(1)>
		<cfreturn this>
	</cffunction>

	<cffunction name="addValue" access="public" returntype="void" hint="Adds a bar value object to collection">
		<cfargument name="value" type="Any" required="true">
		<cfset ArrayAppend(this.values,arguments.value)>
	</cffunction>

	<cffunction name="setValues" access="public" returntype="void" hint="Sets values array containing simple values e.g. 4,5,3,9,2,7">
		<cfargument name="values" type="Any" required="true" hint="Simple Array">
		<cfset this.values = arguments.values>
	</cffunction>

	<cffunction name="setColor" access="public" returntype="void">
		<cfargument name="Color" type="string" required="true" hint="e.g. HTML color">
		<cfset this.colour = arguments.color>		
	</cffunction>

	<cffunction name="getColor" access="public" returntype="string" hint="Returns Color">
		<cfreturn this.colour>
	</cffunction>	 
	
	<cffunction name="setAlpha" access="public" returntype="void">
		<cfargument name="alpha" type="string" required="true" hint="">
		<cfset this.alpha = arguments.alpha>		
	</cffunction>

	<cffunction name="getAlpha" access="public" returntype="string" hint="Returns alpha">
		<cfreturn this.alpha>
	</cffunction>	

	<cffunction name="setTooltip" access="public" returntype="void">
		<cfargument name="tooltip" type="string" required="true" hint="">
		<cfset this.tooltip = arguments.tooltip>		
	</cffunction>

	<cffunction name="getTooltip" access="public" returntype="Any" hint="Returns tooltip">
		<cfreturn this.tooltip>
	</cffunction>
	
	<cffunction name="getData" access="public" returntype="struct" hint="Returns chart data">
		<cfset var data = super.getData()>
		<cfset data.values = ArrayNew(1)>
		
		<!--- set type --->
		<cfset data.type = 'bar'>
		
		<!--- color? --->
		<cfif isDefined("this.colour")>
			<cfset data.colour = this.colour>
		</cfif>
		<!--- alpha? --->
		<cfif isDefined("this.alpha")>
			<cfset data.alpha = this.alpha>
		</cfif>
		<!--- tooltip? --->
		<cfif isDefined("this.tooltip")>
			<cfset data.tip = this.tooltip>
		</cfif>
		
		<!--- Loop all values --->
		<cfloop index="i" from="1" to="#ArrayLen(this.values)#">
			<!--- Item is bar value object? Get data? --->
			<cfif not isSimpleValue(this.values[i])>
				<cfset ArrayAppend(data.values,this.values[i].getData())>
			<cfelse>
				<cfset ArrayAppend(data.values,this.values[i])>
			</cfif>
		</cfloop>	
			
		<cfreturn data>
	</cffunction>	
</cfcomponent>