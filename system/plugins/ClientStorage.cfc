<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	September 23, 2005
Description :
	This is a plugin that enables the setting/getting of permanent variables in
	the client scope using the wddx features if needed.

A ColdBox Storage Plugin implements the following methods:

getVar(name,default):any
setVar(name,value):void
deleteVar(name):boolean
exists(name):boolean
clearAll():void
getStorage():struct
clearStorage():void

----------------------------------------------------------------------->
<cfcomponent name="ClientStorage"
			 hint="Client Storage plugin. It provides the user with a mechanism for permanent data storage using the client scope and WDDX."
			 extends="coldbox.system.Plugin"
			 output="false"
			 cache="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="ClientStorage" output="false" hint="Constructor.">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true" hint="coldbox.system.web.Controller">
		<!--- ************************************************************* --->
		<cfscript>
			super.Init(arguments.controller);
			
			/* Plugin Properties */
			setpluginName("Client Storage");
			setpluginVersion("1.0");
			setpluginDescription("A permanent data storage plugin.");
			setpluginAuthor("Luis Majano");
			setpluginAuthorURL("http://www.coldbox.org");
			
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
			<cfset rtnVar = client[arguments.name]>
			<cfif isWDDX(rtnVar)>
				<!--- Unwddx packet --->
				<cfwddx action="wddx2cfml" input="#rtnVar#" output="wddxVar">
				<cfset rtnVar = wddxVar>
			</cfif>
			<cfreturn rtnVar>
		<cfelse>
			<cfreturn arguments.default>
		</cfif>
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
	
	<!--- Clear All From Storage --->
	<cffunction name="clearAll" access="public" returntype="void" hint="Clear the entire coldbox client storage" output="false">
		<cfset structClear(client)>
	</cffunction>
	
	<!--- Get Storage --->
	<cffunction name="getStorage" access="public" returntype="struct" hint="Get the entire storage scope structure" output="false" >
		<cfreturn client>
	</cffunction>

</cfcomponent>