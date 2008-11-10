<cfcomponent output="false" extends="ofcplugin.model.openflashchart.element.Base">

	<cffunction name="init" access="public" returntype="Struct">
		<cfset super.init()>
		<cfreturn this>
	</cffunction>

	<cffunction name="setColor" access="public" returntype="void">
		<cfargument name="color" type="string" required="true" hint="">
		<cfset this.color = arguments.color>		
	</cffunction>

	<cffunction name="getColor" access="public" returntype="string" hint="Returns color">
		<cfreturn this.color>
	</cffunction>
	
	<cffunction name="setColor2" access="public" returntype="void">
		<cfargument name="color2" type="string" required="true" hint="">
		<cfset this.color2 = arguments.color2>		
	</cffunction>

	<cffunction name="getColor2" access="public" returntype="string" hint="Returns color2">
		<cfreturn this.color2>
	</cffunction>
		
	<cffunction name="setAngle" access="public" returntype="void">
		<cfargument name="angle" type="numeric" required="true" hint="90=vertical, 180=horizontal, 45=diag, etc.">
		<cfset this.angle = arguments.angle>		
	</cffunction>

	<cffunction name="getAngle" access="public" returntype="numeric" hint="Returns angle">
		<cfreturn this.angle>
	</cffunction>
				
	<cffunction name="getData" access="public" returntype="struct" hint="Returns chart data">
		<cfset var data = super.getData()>

		<!--- startColor? --->
		<cfif isDefined("this.color")>
			<cfset data.inner_background['values'] = [getColor(),'##000',90]>
		</cfif>
		
		<cfreturn data>
	</cffunction>
					
</cfcomponent>