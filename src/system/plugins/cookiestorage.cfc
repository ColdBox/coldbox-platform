<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Sana Ullah
Date     :	October 15, 2007
Description :
	This is a plugin that enables the setting/getting of permanent variables in	the cookie scope.
	Usage: 
	set		controller.getPlugin("cookiestorage").setVar(name="name1",value="hello1",expires="11")
	get		controller.getPlugin("cookiestorage").getVar(name="name1")
Modification History:

----------------------------------------------------------------------->
<cfcomponent name="cookiestorage"
			 hint="Cookie Storage plugin. It provides the user with a mechanism for permanent data storage using the cookie scope."
			 extends="coldbox.system.plugin"
			 output="false"
			 cache="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="cookiestorage" output="false" hint="Constructor.">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true">
		<!--- ************************************************************* --->
		<cfset super.Init(arguments.controller) />
		<cfset setpluginName("Cookie Storage")>
		<cfset setpluginVersion("1.0")>
		<cfset setpluginDescription("A permanent data storage plugin.")>
	
		<cfreturn this>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->

	<cffunction name="setVar" access="public" returntype="void" hint="Set a new permanent variable." output="false">
		<!--- ************************************************************* --->
		<cfargument name="name"  type="string" required="true"  hint="The name of the variable.">
		<cfargument name="value" type="any"    required="true"  hint="The value to set in the variable.">
		<cfargument name="expires"	type="numeric"	required="no"	default="1"	hint="Cookie Expire in number of days. [default cookie is session only]">
		<!--- ************************************************************* --->
		<cfset var tmpVar = "">
		<!--- Test for simple mode --->
		<cfif isSimpleValue(arguments.value)>
			<cfif arguments.expires EQ 1>
				<cfcookie name="#arguments.name#" value="#arguments.value#" />
			<cfelse>
				<cfcookie name="#arguments.name#" value="#arguments.value#" expires="#arguments.expires#" />
			</cfif>
		<cfelse>
			<!--- throw error if this is complex object --->
			<cfthrow type="Framework.plugin.cookiestorage.InvalidValue" message="Cannot store complex value in cookie">
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getVar" access="public" returntype="any" hint="Get a new permanent variable. If the cookie does not exist. The method returns blank." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" 		type="string"  required="true" 		hint="The variable name to retrieve.">
		<cfargument  name="default"  	type="any"     required="false"  	hint="The default value to set. If not used, a blank is returned." default="">
		<!--- ************************************************************* --->
		<cfif exists(arguments.name)>
			<!--- Return value --->
			<cfreturn cookie[arguments.name] />
		<cfelse>
			<!--- Return empty value --->
			<cfreturn arguments.default />
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="exists" access="public" returntype="boolean" hint="Checks wether the permanent variable exists." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" type="string" required="true" 	hint="The variable name to retrieve.">
		<!--- ************************************************************* --->
		<cfreturn structKeyExists(cookie,arguments.name)>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="deleteVar" access="public" returntype="boolean" hint="Tries to delete a permanent cookie var." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" type="string" required="true" 	hint="The variable name to retrieve.">
		<!--- ************************************************************* --->
		<cfif exists(arguments.name)>
			<cfset structdelete(cookie, arguments.name)>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->
	
</cfcomponent>
