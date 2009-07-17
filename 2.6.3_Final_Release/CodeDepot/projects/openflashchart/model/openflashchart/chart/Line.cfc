<cfcomponent output="false" extends="ofcplugin.model.openflashchart.chart.Base">

	<cffunction name="init" access="public" returntype="Struct">
		<cfset super.init()>
		<cfset this.values = ArrayNew(1)>
		<cfreturn this>
	</cffunction>

	<cffunction name="addValue" access="public" returntype="void" hint="Adds a value object to collection">
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

	<cffunction name="setTooltip" access="public" returntype="void">
		<cfargument name="tooltip" type="string" required="true" hint="">
		<cfset this.tooltip = arguments.tooltip>		
	</cffunction>

	<cffunction name="getTooltip" access="public" returntype="Any" hint="Returns tooltip">
		<cfreturn this.tooltip>
	</cffunction>
	
	<cffunction name="setDotSize" access="public" returntype="void">
		<cfargument name="size" type="numeric" required="true" hint="">
		<cfset this.dotSize = arguments.size>		
	</cffunction>

	<cffunction name="getDotSize" access="public" returntype="numeric" hint="Returns dotSize">
		<cfreturn this.dotSize>
	</cffunction>
	
	<cffunction name="setHaloSize" access="public" returntype="void">
		<cfargument name="size" type="numeric" required="true" hint="">
		<cfset this.haloSize = arguments.size>		
	</cffunction>

	<cffunction name="getHaloSize" access="public" returntype="numeric" hint="Returns haloSize">
		<cfreturn this.haloSize>
	</cffunction>

	<cffunction name="setWidth" access="public" returntype="void">
		<cfargument name="width" type="numeric" required="true" hint="">
		<cfset this.width = arguments.width>		
	</cffunction>

	<cffunction name="getWidth" access="public" returntype="numeric" hint="Returns width">
		<cfreturn this.width>
	</cffunction>

	<cffunction name="setLineStyle" access="public" returntype="void">
		<cfargument name="lineStyle" type="string" required="true" hint="">
		<cfset this.lineStyle = arguments.lineStyle>		
	</cffunction>

	<cffunction name="getLineStyle" access="public" returntype="string" hint="Returns lineStyle">
		<cfreturn this.lineStyle>
	</cffunction>

	<cffunction name="getData" access="public" returntype="struct" hint="Returns chart data">
		<cfset var data = super.getData()>
		<cfset data.values = ArrayNew(1)>
		
		<!--- set type --->
		<cfset data.type = 'line'>
		
		<!--- color? --->
		<cfif isDefined("this.colour")>
			<cfset data.colour = this.colour>
		</cfif>

		<!--- dotSize? --->
		<cfif isDefined("this.dotSize")>
			<cfset data['dot-size'] = this.dotSize>
		</cfif>

		<!--- haloSize? --->
		<cfif isDefined("this.haloSize")>
			<cfset data['halo-size'] = this.haloSize>
		</cfif>
		
		<!--- tooltip? --->
		<cfif isDefined("this.tooltip")>
			<cfset data.tip = this.tooltip>
		</cfif>
		
		<!--- width? --->
		<cfif isDefined("this.width")>
			<cfset data.width = this.width>
		</cfif>

		<!--- lineStyle? --->
		<cfif isDefined("this.lineStyle")>
			<cfset data['line-style'] = this.lineStyle>
		</cfif>
		
		<!--- Loop all values --->
		<cfloop index="i" from="1" to="#ArrayLen(this.values)#">
			<!--- Item is value object? Get data? --->
			<cfif not isSimpleValue(this.values[i])>
				<cfset ArrayAppend(data.values,this.values[i].getData())>
			<cfelse>
				<cfset ArrayAppend(data.values,this.values[i])>
			</cfif>
		</cfloop>	
			
		<cfreturn data>
	</cffunction>	
</cfcomponent>