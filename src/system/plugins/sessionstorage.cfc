<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	February 16,2007
Description :
	This is a plugin that enables the setting/getting of permanent variables in
	the session scope.

Modification History:

----------------------------------------------------------------------->
<cfcomponent name="sessionstorage"
			 hint="Session Storage plugin. It provides the user with a mechanism for permanent data storage using the session scope."
			 extends="coldbox.system.plugin"
			 output="false"
			 cache="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="sessionstorage" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfset super.Init(arguments.controller) />
		<cfset setpluginName("Session Storage")>
		<cfset setpluginVersion("1.0")>
		<cfset setpluginDescription("A permanent data storage plugin using the session scope.")>
		<cfreturn this>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->

	<cffunction name="setVar" access="public" returntype="void" hint="Set a new permanent variable." output="false">
		<!--- ************************************************************* --->
		<cfargument name="name"  type="string" required="true" hint="The name of the variable.">
		<cfargument name="value" type="any"    required="true" hint="The value to set in the variable.">
		<!--- ************************************************************* --->
		<cfset var tmpVar = "">
		<cfset session[arguments.name] = arguments.value>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getVar" access="public" returntype="any" hint="Get a new permanent variable. If the variable does not exist. The method returns blank." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" 		type="string"  required="true" 		hint="The variable name to retrieve.">
		<cfargument  name="default"  	type="any"     required="false"  	hint="The default value to set. If not used, a blank is returned." default="">
		<!--- ************************************************************* --->
		<cfset var rtnVar = "">
		<cfif exists(arguments.name)>
			<cfset rtnVar = session[arguments.name]>
		<cfelse>
			<cfset rtnVar = arguments.default>
		</cfif>
		<!--- Return Var --->
		<cfreturn rtnVar>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="exists" access="public" returntype="boolean" hint="Checks wether the permanent variable exists." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" type="string" required="true" 	hint="The variable name to retrieve.">
		<!--- ************************************************************* --->
		<cfif structKeyExists(session, arguments.name)>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="deleteVar" access="public" returntype="boolean" hint="Tries to delete a permanent client var." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" type="string" required="true" 	hint="The variable name to retrieve.">
		<!--- ************************************************************* --->
		<cfif exists(arguments.name)>
			<cfset structdelete(session, arguments.name)>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

</cfcomponent>