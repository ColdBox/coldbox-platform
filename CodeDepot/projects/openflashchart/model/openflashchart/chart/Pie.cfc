<cfcomponent output="false" extends="ofcplugin.model.openflashchart.chart.Base">

	<cffunction name="init" access="public" returntype="Struct">
		<cfset super.init()>
		<cfset this.values = ArrayNew(1)>
		<cfreturn this>
	</cffunction>

	<cffunction name="addValue" access="public" returntype="void" hint="Adds a pie value object to collection">
		<cfargument name="value" type="Any" required="true">
		<cfset ArrayAppend(this.values,arguments.value)>
	</cffunction>

	<cffunction name="setValues" access="public" returntype="void" hint="Sets values array containing pie value objects">
		<cfargument name="values" type="array" required="true" hint="Array of objects">
		<cfset this.values = arguments.values>
	</cffunction>

	<cffunction name="setColors" access="public" returntype="void">
		<cfargument name="Colors" type="array" required="true" hint="">
		<cfset this.colors = arguments.colors>		
	</cffunction>

	<cffunction name="getColors" access="public" returntype="string" hint="Returns Color">
		<cfreturn this.colors>
	</cffunction>	 
	
	<cffunction name="setBorder" access="public" returntype="void">
		<cfargument name="border" type="numeric" required="true" hint="">
		<cfset this.border = arguments.border>		
	</cffunction>

	<cffunction name="getBorder" access="public" returntype="numeric" hint="Returns border">
		<cfreturn this.border>
	</cffunction>
		
	<cffunction name="setAlpha" access="public" returntype="void">
		<cfargument name="alpha" type="string" required="true" hint="">
		<cfset this.alpha = arguments.alpha>		
	</cffunction>

	<cffunction name="getAlpha" access="public" returntype="string" hint="Returns alpha">
		<cfreturn this.alpha>
	</cffunction>	
			
	<cffunction name="setIsAnimate" access="public" returntype="void">
		<cfargument name="isAnimate" type="boolean" required="true" hint="">
		<cfset this.isAnimate = arguments.isAnimate>		
	</cffunction>

	<cffunction name="getIsAnimate" access="public" returntype="boolean" hint="Returns isAnimate">
		<cfreturn this.isAnimate>
	</cffunction>
			
	<cffunction name="setStartAngle" access="public" returntype="void">
		<cfargument name="angle" type="numeric" required="true" hint="">
		<cfset this.startAngle = arguments.angle>		
	</cffunction>

	<cffunction name="getStartAngle" access="public" returntype="numeric" hint="Returns startAngle">
		<cfreturn this.startAngle>
	</cffunction>
				
	<cffunction name="setTooltip" access="public" returntype="void">
		<cfargument name="tooltip" type="string" required="true" hint="">
		<cfset this.tooltip = arguments.tooltip>		
	</cffunction>

	<cffunction name="getTooltip" access="public" returntype="Any" hint="Returns tooltip">
		<cfreturn this.tooltip>
	</cffunction>
	
	<cffunction name="setLabelColor" access="public" returntype="void">
		<cfargument name="labelColor" type="string" required="true" hint="">
		<cfset this.labelColor = arguments.labelColor>		
	</cffunction>

	<cffunction name="getLabelColor" access="public" returntype="string" hint="Returns labelColor">
		<cfreturn this.labelColor>
	</cffunction>

	<cffunction name="setIsGradient" access="public" returntype="void">
		<cfargument name="isGradient" type="boolean" required="true" hint="">
		<cfset this.isGradient = arguments.isGradient>		
	</cffunction>

	<cffunction name="getIsGradient" access="public" returntype="boolean" hint="Returns isGradient">
		<cfreturn this.isGradient>
	</cffunction>
		
	<cffunction name="setIsLabels" access="public" returntype="void">
		<cfargument name="isLabels" type="boolean" required="true" hint="">
		<cfset this.isLabels = arguments.isLabels>		
	</cffunction>

	<cffunction name="getIsLabels" access="public" returntype="boolean" hint="Returns isLabels">
		<cfreturn this.isLabels>
	</cffunction>
			
	<cffunction name="setOnClick" access="public" returntype="void">
		<cfargument name="onClick" type="string" required="true" hint="">
		<cfset this.onClick = arguments.onClick>		
	</cffunction>

	<cffunction name="getOnClick" access="public" returntype="string" hint="Returns onClick">
		<cfreturn this.onClick>
	</cffunction>
				
	<cffunction name="setFontSize" access="public" returntype="void">
		<cfargument name="fontSize" type="numeric" required="true" hint="">
		<cfset this.fontSize = arguments.fontSize>		
	</cffunction>

	<cffunction name="getFontSize" access="public" returntype="numeric" hint="Returns fontSize">
		<cfreturn this.fontSize>
	</cffunction>
					
	<cffunction name="getData" access="public" returntype="struct" hint="Returns chart data">
		<cfset var data = super.getData()>
		<cfset data.values = ArrayNew(1)>
		
		<!--- set type --->
		<cfset data.type = 'pie'>
		
		<!--- colors? --->
		<cfif isDefined("this.colors")>
			<cfset data.colours = this.colors>
		</cfif>
		
		<!--- alpha? --->
		<cfif isDefined("this.alpha")>
			<cfset data.alpha = this.alpha>
		</cfif>
		
		<!--- tooltip? --->
		<cfif isDefined("this.tooltip")>
			<cfset data.tip = this.tooltip>
		</cfif>
		
		<!--- animate? --->
		<cfif isDefined("this.isAnimate")>
			<cfset data.animate = this.isAnimate>
		</cfif>
		
		<!--- startAngle? --->
		<cfif isDefined("this.startAngle")>
			<cfset data['start-angle']= this.startAngle>
		</cfif>
		
		<!--- labelColor? --->
		<cfif isDefined("this.labelColor")>
			<cfset data['label-colour']= this.labelColor>
		</cfif>
				
		<!--- isGradientFill? --->
		<cfif isDefined("this.isGradient")>
			<cfset data['gradient-fill']= this.isGradient>
		</cfif>
				
		<!--- isLabels? --->
		<cfif isDefined("this.isLabels")>
			<cfif this.isLabels>
				<cfset data['no-labels']= false>
			<cfelse>
				<cfset data['no-labels']= true>
			</cfif>
		</cfif>
				
		<!--- onClick? --->
		<cfif isDefined("this.onClick")>
			<cfset data['on-click']= this.onClick>
		</cfif>
				
		<!--- fontSize? --->
		<cfif isDefined("this.fontSize")>
			<cfset data['font-size']= this.fontSize>
		</cfif>
						
		<!--- Loop all values --->
		<cfloop index="i" from="1" to="#ArrayLen(this.values)#">
			<cfset ArrayAppend(data.values,this.values[i].getData())>
		</cfloop>	
			
		<cfreturn data>
	</cffunction>	
</cfcomponent>