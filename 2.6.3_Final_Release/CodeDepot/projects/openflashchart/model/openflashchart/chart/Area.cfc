<cfcomponent output="false" extends="ofcplugin.model.openflashchart.chart.Line">

	<cffunction name="init" access="public" returntype="Struct">
		<cfset super.init()>
		<cfset this.values = ArrayNew(1)>
		<cfreturn this>
	</cffunction>

	<cffunction name="setFillAlpha" access="public" returntype="void">
		<cfargument name="fillAlpha" type="numeric" required="true" hint="">
		<cfset this.fillAlpha = arguments.fillAlpha>		
	</cffunction>

	<cffunction name="getFillAlpha" access="public" returntype="numeric" hint="Returns fillAlpha">
		<cfreturn this.fillAlpha>
	</cffunction>
	
	<cffunction name="setFillColor" access="public" returntype="void">
		<cfargument name="fillColor" type="string" required="true" hint="">
		<cfset this.fillColor = arguments.fillColor>		
	</cffunction>

	<cffunction name="getFillColor" access="public" returntype="string" hint="Returns fillColor">
		<cfreturn this.fillColor>
	</cffunction>
	
	<cffunction name="setIsLoop" access="public" returntype="void">
		<cfargument name="isLoop" type="boolean" required="true" hint="">
		<cfset this.isLoop = arguments.isLoop>		
	</cffunction>

	<cffunction name="getIsLoop" access="public" returntype="boolean" hint="Returns isLoop">
		<cfreturn this.isLoop>
	</cffunction>
	
	<cffunction name="getData" access="public" returntype="struct" hint="Returns chart data">
		<cfset var data = super.getData()>
		
		<!--- fillAlpha? --->
		<cfif isDefined("this.fillAlpha")>
			<cfset data['fill-alpha'] = this.fillAlpha>
		</cfif>

		<!--- fillColor? --->
		<cfif isDefined("this.fillColor")>
			<cfset data.fill = this.fillColor>
		</cfif>

		<!--- isLoop? --->
		<cfif isDefined("this.isLoop")>
			<cfset data.loop = this.isLoop>
		</cfif>
		
		<cfreturn data>
	</cffunction>	
</cfcomponent>