<!-----------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	September 23, 2005
Description : 			
	This is a plugin that enables the setting/getting of permanent variables in
	the client scope using the wddx features if needed.
				
Modification History:
	
----------------------------------------------------------------------->
<cfcomponent name="myclientstorage" hint="Client Storage plugin. It provides the user with a mechanism for permanent data storage using the client scope and WDDX." extends="coldbox.system.Plugin">

	<!--- ************************************************************* --->
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfset super.Init() />
		<cfreturn this>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="setVar" access="public" returntype="void" hint="Set a new permanent variable." output="false">
		<!--- ************************************************************* --->
		<cfargument name="name"  type="string" required="true" hint="The name of the variable.">
		<cfargument name="value" type="any"    required="true" hint="The value to set in the variable.">
		<!--- ************************************************************* --->
		<cfset var tmpVar = "">
		<!--- Test for simple mode --->
		<cfif isSimpleValue(arguments.value)>
			<cfset client["#arguments.name#"] = #arguments.value#>
		<cfelse>
			<!--- Wddx variable --->
			<cfwddx action="cfml2wddx" input="#arguments.value#" output="tmpVar">
			<!--- Set Variable --->
			<cfset client["#arguments.name#"] = tmpVar>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getVar" access="public" returntype="any" hint="Get a new permanent variable. If the variable does not exist. The method returns blank." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" 		type="string"  required="true" 		hint="The variable name to retrieve.">
		<cfargument  name="default"  	type="any"     required="false"  	hint="The default value to set. If not used, a blank is returned." default="">
		<!--- ************************************************************* --->
		<cfset var wddxVar = "">
		<cfset var rtnVar = "">
		<cfif exists("#arguments.name#")>
			<!--- Get Value --->
			<cfset rtnVar = client["#arguments.name#"]>
			<cfif isWDDX(rtnVar)>
				<!--- Unwddx packet --->
				<cfwddx action="wddx2cfml" input="#rtnVar#" output="wddxVar">
				<cfset rtnVar = wddxVar>
			</cfif>
		<cfelse>
			<cfset rtnVar = arguments.default>
		</cfif>
		<!--- Return Var --->
		<cfreturn rtnVar>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="exists" access="public" returntype="boolean" hint="Checks wether the permanent variable exists." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" type="string" required="true" 	hint="The variable name to retrieve.">
		<!--- ************************************************************* --->
		<cfif structKeyExists(client, "#arguments.name#")>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="deleteVar" access="public" returntype="boolean" hint="Tries to delete a permanent client var." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" type="string" required="true" 	hint="The variable name to retrieve.">
		<!--- ************************************************************* --->
		<cfif exists(arguments.name)>
			<cfset structdelete(client, "#arguments.name#")>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>