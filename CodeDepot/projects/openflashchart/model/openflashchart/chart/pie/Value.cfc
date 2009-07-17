<cfcomponent output="false">

	<cffunction name="init" access="public" returntype="Struct">
		<cfreturn this>
	</cffunction>

	<cffunction name="setValue" access="public" returntype="void">
		<cfargument name="value" type="numeric" required="true" hint="">
		<cfset this.value = arguments.value>		
	</cffunction>

	<cffunction name="getValue" access="public" returntype="numeric" hint="Returns value">
		<cfreturn this.value>
	</cffunction>
	
	<cffunction name="setLabel" access="public" returntype="void">
		<cfargument name="label" type="string" required="true" hint="">
		<cfset this.label = arguments.label>		
	</cffunction>

	<cffunction name="getLabel" access="public" returntype="string" hint="Returns label">
		<cfreturn this.label>
	</cffunction>
	
	<cffunction name="setLabelColor" access="public" returntype="void">
		<cfargument name="labelColor" type="string" required="true" hint="">
		<cfset this.labelColor = arguments.labelColor>		
	</cffunction>

	<cffunction name="getLabelColor" access="public" returntype="string" hint="Returns labelColor">
		<cfreturn this.labelColor>
	</cffunction>
	
	<cffunction name="setFontSize" access="public" returntype="void">
		<cfargument name="fontSize" type="numeric" required="true" hint="">
		<cfset this.fontSize = arguments.fontSize>		
	</cffunction>

	<cffunction name="getFontSize" access="public" returntype="numeric" hint="Returns fontSize">
		<cfreturn this.fontSize>
	</cffunction>
					
	<cffunction name="getData" access="public" returntype="struct" hint="Returns chart data">
		<cfset var data = StructNew()>
		
		<!--- value? --->
		<cfif isDefined("this.value")>
			<cfset data['value']= this.value>
		</cfif>

		<!--- label? --->
		<cfif isDefined("this.label")>
			<cfset data['label']= this.label>
		</cfif>
		
		<!--- labelColor? --->
		<cfif isDefined("this.labelColor")>
			<cfset data['label-colour']= this.labelColor>
		</cfif>
				
		<!--- onClick? --->
		<cfif isDefined("this.onClick")>
			<cfset data['on-click']= this.onClick>
		</cfif>
				
		<!--- fontSize? --->
		<cfif isDefined("this.fontSize")>
			<cfset data['font-size']= this.fontSize>
		</cfif>

		<cfreturn data>
	</cffunction>	
</cfcomponent>