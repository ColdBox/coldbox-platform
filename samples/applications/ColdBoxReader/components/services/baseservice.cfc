<cfcomponent name="baseservice" output="false">

	<!--- ******************************************************************************** --->

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="any" output="false">
		<cfreturn this />
	</cffunction>
	
	<!--- ******************************************************************************** --->

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	
	
<!------------------------------------------- PRIVATE ------------------------------------------->

	<cffunction name="dump" access="private" hint="Facade for cfmx dump" returntype="void">
		<!--- ************************************************************* --->
		<cfargument name="var" required="yes" type="any">
		<!--- ************************************************************* --->
		<cfdump var="#var#">
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="abort" access="private" hint="Facade for cfabort" returntype="void" output="false">
		<cfabort>
	</cffunction>
	
	<!--- ************************************************************* --->


</cfcomponent>