<cfcomponent name="coldboxService" hint="This is the ColdBox Reader model service.">

	<!--- Constructor --->
	<cfset variables.instance = structnew()>
	<cfset variables.instance.dsnBean = "">
			
	<!--- ******************************************************************************** --->
	
	<cffunction name="init" access="public" returntype="any" output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="dsnBean" required="true" type="any">	
		<!--- ******************************************************************************** --->
		<cfset instance.dsnBean = arguments.dsnBean>
		<cfreturn this />
	</cffunction>
	
	<!--- ******************************************************************************** --->
	
	<cffunction name="getdao" access="public" returntype="any" output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="dao" required="true" type="string">	
		<!--- ******************************************************************************** --->
		<cfreturn CreateObject("component","#arguments.dao#").init(instance.dsnBean)>
	</cffunction>
	
	<!--- ******************************************************************************** --->
	
</cfcomponent>