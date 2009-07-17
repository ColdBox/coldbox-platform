<cfcomponent output="false" extends="ofcplugin.model.openflashchart.chart.bar.Value">

	<cffunction name="init" access="public" returntype="Struct">
		<cfset super.init()>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setValue" access="public" returntype="void">
		<cfargument name="value" type="numeric" required="true" hint="">
		<cfset this.value = arguments.value>		
	</cffunction>

	<cffunction name="getValue" access="public" returntype="numeric" hint="Returns Stack value">
		<cfreturn this.value>
	</cffunction>	
	
	<cffunction name="getData" access="public" returntype="struct" hint="Returns chart data">
		<cfset var data = super.getData()>
		
		<!--- Value? --->
		<cfif isDefined("this.value")>
			<cfset data.val = this.value>
		</cfif>
		
		<cfreturn data>
	</cffunction>	
</cfcomponent>