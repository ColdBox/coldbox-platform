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
		<cfargument name="controller" type="any" required="true" hint="coldbox.system.controller">
		<!--- ************************************************************* --->
		<cfscript>	
			super.Init(arguments.controller);
			
			/* Plugin Properties */
			setpluginName("Cookie Storage");
			setpluginVersion("1.0");
			setpluginDescription("A permanent data storage plugin.");
			
			/* Return Instance. */
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Set A Cookie --->
	<cffunction name="setVar" access="public" returntype="void" hint="Set a new permanent variable." output="false">
		<!--- ************************************************************* --->
		<cfargument name="name"  	type="string" 	required="true"  hint="The name of the variable.">
		<cfargument name="value" 	type="any"    	required="true"  hint="The value to set in the variable, simple, array, query or structure.">
		<cfargument name="expires"	type="numeric"	required="no"	default="1"	hint="Cookie Expire in number of days. [default cookie is session only]">
		<!--- ************************************************************* --->
		<cfset var tmpVar = "">
		
		<!--- Test for simple mode --->
		<cfif isSimpleValue(arguments.value)>
			<cfset tmpVar = arguments.value>
		<cfelse>
			<!--- Wddx variable --->
			<cfwddx action="cfml2wddx" input="#arguments.value#" output="tmpVar">
		</cfif>
		
		<!--- Store cookie with expiration info --->
		<cfif arguments.expires EQ 1>
			<cfcookie name="#arguments.name#" value="#tmpVar#" />
		<cfelse>
			<cfcookie name="#arguments.name#" value="#tmpVar#" expires="#arguments.expires#" />
		</cfif>	
	</cffunction>

	<!--- Get a Cookie Var --->
	<cffunction name="getVar" access="public" returntype="any" hint="Get a new permanent variable. If the cookie does not exist. The method returns blank." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" 		type="string"  required="true" 		hint="The variable name to retrieve.">
		<cfargument  name="default"  	type="any"     required="false"  	hint="The default value to set. If not used, a blank is returned." default="">
		<!--- ************************************************************* --->
		<cfset var wddxVar = "">
		<cfset var rtnVar = "">
		
		<cfif exists(arguments.name)>
			<!--- Get value --->
			<cfset rtnVar = cookie[arguments.name]>
			<cfif isWDDX(rtnVar)>
				<!--- Unwddx packet --->
				<cfwddx action="wddx2cfml" input="#rtnVar#" output="wddxVar">
				<cfset rtnVar = wddxVar>
			</cfif>
		<cfelse>
			<!--- Return the default value --->
			<cfset rtnVar = arguments.default>
		</cfif>
		<!--- Return Var --->
		<cfreturn rtnVar>
	</cffunction>

	<!--- Check if a cookie value exists --->
	<cffunction name="exists" access="public" returntype="boolean" hint="Checks wether the permanent variable exists." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" type="string" required="true" 	hint="The variable name to retrieve.">
		<!--- ************************************************************* --->
		<cfreturn structKeyExists(cookie,arguments.name)>
	</cffunction>

	<!--- Delete a Cookie Value --->
	<cffunction name="deleteVar" access="public" returntype="boolean" hint="Tries to delete a permanent cookie var." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" type="string" required="true" 	hint="The variable name to retrieve.">
		<!--- ************************************************************* --->
		<cfif exists(arguments.name)>
			<cfcookie name="#arguments.name#" expires="NOW" value='NULL'>
			<cfset structdelete(cookie, arguments.name)>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
	
</cfcomponent>
