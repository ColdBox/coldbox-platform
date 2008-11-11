<cfcomponent output="false">

	<cffunction name="init" access="public" returntype="Struct">
		<cfreturn this>
	</cffunction>

	<cffunction name="setTop" access="public" returntype="void">
		<cfargument name="top" type="numeric" required="true" hint="">
		<cfset this.top = arguments.top>		
	</cffunction>

	<cffunction name="getTop" access="public" returntype="numeric" hint="Returns top">
		<cfreturn this.top>
	</cffunction>

	<cffunction name="setBottom" access="public" returntype="void">
		<cfargument name="bottom" type="numeric" required="true" hint="">
		<cfset this.bottom = arguments.bottom>		
	</cffunction>

	<cffunction name="getBottom" access="public" returntype="numeric" hint="Returns bottom">
		<cfreturn this.bottom>
	</cffunction>	

	<cffunction name="setColor" access="public" returntype="void">
		<cfargument name="Color" type="string" required="true" hint="e.g. HTML color">
		<cfset this.colour = arguments.color>		
	</cffunction>

	<cffunction name="getColor" access="public" returntype="string" hint="Returns Color">
		<cfreturn this.colour>
	</cffunction>	 
	
	<cffunction name="setTooltip" access="public" returntype="void">
		<cfargument name="tooltip" type="String" required="true" hint="">
		<cfset this.tooltip = arguments.tooltip>		
	</cffunction>

	<cffunction name="getTooltip" access="public" returntype="Any" hint="Returns tooltip">
		<cfreturn this.tooltip>
	</cffunction>
	
	<cffunction name="getData" access="public" returntype="struct" hint="Returns chart data">
		<cfset var data = StructNew()>
		
		<!--- top? --->
		<cfif isDefined("this.top")>
			<cfset data.top = this.top>
		</cfif>
		<!--- bottom? --->
		<cfif isDefined("this.bottom")>
			<cfset data.bottom = this.bottom>
		</cfif>
		<!--- color? --->
		<cfif isDefined("this.colour")>
			<cfset data.colour = this.colour>
		</cfif>
		<!--- tooltip? --->
		<cfif isDefined("this.tooltip")>
			<cfset data.tip = this.tooltip>
		</cfif>

		<cfreturn data>
	</cffunction>	
</cfcomponent>