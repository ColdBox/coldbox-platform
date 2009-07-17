<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	September 23, 2005
Description :
	This is a plugin that enables the setting/getting of permanent variables in
	the client scope using the wddx features if needed.

Modification History:

----------------------------------------------------------------------->
<cfcomponent name="clientstorage"
			 hint="Client Storage plugin. It provides the user with a mechanism for permanent data storage using the client scope and WDDX."
			 extends="coldbox.system.plugin"
			 output="false"
			 cache="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="clientstorage" output="false" hint="Constructor.">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true" hint="coldbox.system.controller">
		<!--- ************************************************************* --->
		<cfscript>
			super.Init(arguments.controller);
			
			/* Plugin Properties */
			setpluginName("Client Storage");
			setpluginVersion("1.0");
			setpluginDescription("A permanent data storage plugin.");
			
			/* Return Instance */
			return this;
		</cfscript>			
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Set a variable --->
	<cffunction name="setVar" access="public" returntype="void" hint="Set a new permanent variable." output="false">
		<!--- ************************************************************* --->
		<cfargument name="name"  type="string" required="true" hint="The name of the variable.">
		<cfargument name="value" type="any"    required="true" hint="The value to set in the variable.">
		<!--- ************************************************************* --->
		<cfset var tmpVar = "">
		<!--- Test for simple mode --->
		<cfif isSimpleValue(arguments.value)>
			<cfset client[arguments.name] = arguments.value>
		<cfelse>
			<!--- Wddx variable --->
			<cfwddx action="cfml2wddx" input="#arguments.value#" output="tmpVar">
			<!--- Set Variable --->
			<cfset client[arguments.name] = tmpVar>
		</cfif>
	</cffunction>

	<!--- Get a variable --->
	<cffunction name="getVar" access="public" returntype="any" hint="Get a new permanent variable. If the variable does not exist. The method returns blank." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" 		type="string"  required="true" 		hint="The variable name to retrieve.">
		<cfargument  name="default"  	type="any"     required="false"  	hint="The default value to set. If not used, a blank is returned." default="">
		<!--- ************************************************************* --->
		<cfset var wddxVar = "">
		<cfset var rtnVar = "">
		
		<cfif exists(arguments.name)>
			<!--- Get Value --->
			<cfset rtnVar = client[arguments.name]>
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

	<!--- Exists Check --->
	<cffunction name="exists" access="public" returntype="boolean" hint="Checks wether the permanent variable exists." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" type="string" required="true" 	hint="The variable name to retrieve.">
		<!--- ************************************************************* --->
		<cfreturn structKeyExists(client,arguments.name)>
	</cffunction>

	<!--- Delete a Var --->
	<cffunction name="deleteVar" access="public" returntype="boolean" hint="Tries to delete a permanent client var." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" type="string" required="true" 	hint="The variable name to retrieve.">
		<!--- ************************************************************* --->
		<cfreturn structdelete(client, arguments.name, true)>
	</cffunction>


</cfcomponent>