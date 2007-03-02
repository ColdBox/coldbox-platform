<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	June 30, 2006
Description :
	I model mail server settings. You can send this bean to model or EJB's
	and when sending email. It will use its settings.

Modification History:

----------------------------------------------------------------------->
<cfcomponent name="mailsettingsBean" hint="I model mail server settings" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		variables.instance = structnew();
		variables.instance.server = "";
		variables.instance.username = "";
	    variables.instance.password = "" ;
		variables.instance.port = "";
	</cfscript>

	<!--- ************************************************************* --->

	<cffunction name="init" access="public" output="false" hint="I return a mail setting bean." returntype="coldbox.system.beans.mailsettingsBean">
		<!--- ************************************************************* --->
		<cfargument name="server"	required="false" type="string" default="">
		<cfargument name="username"	required="false" type="string" default="">
		<cfargument name="password"	required="false" type="string" default="">
		<cfargument name="port"		required="false" type="string" default="">
		<!--- ************************************************************* --->
		<cfscript>
		instance.server = arguments.server;
		instance.username = arguments.username;
		instance.password = arguments.password;
		instance.port = arguments.port;
		return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->

	<cffunction name="getInstance" access="public" returntype="any" output="false">
		<cfreturn variables.instance >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setInstance" access="public" returntype="void" output="false">
		<cfargument name="instance" type="struct" required="true">
		<cfset variables.instance = arguments.instance>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setserver" access="public" return="void" output="false" hint="Set server">
	  <cfargument name="server" type="string" >
	  <cfset variables.instance.server=arguments.server >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getserver" access="public" return="string" output="false" hint="Get server">
	  <cfreturn variables.instance.server >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setport" access="public" return="void" output="false" hint="Set port">
	  <cfargument name="port" type="string" >
	  <cfset variables.instance.port=arguments.port >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getport" access="public" return="string" output="false" hint="Get port">
	  <cfreturn variables.instance.port >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setUsername" access="public" return="void" output="false" hint="Set Username">
	  <cfargument name="Username" type="string" >
	  <cfset variables.instance.Username=arguments.Username >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getUsername" access="public" return="string" output="false" hint="Get Username">
	  <cfreturn variables.instance.Username >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setPassword" access="public" return="void" output="false" hint="Set Password">
	  <cfargument name="Password" type="string" >
	  <cfset variables.instance.Password=arguments.Password >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getPassword" access="public" return="string" output="false" hint="Get Password">
	  <cfreturn variables.instance.Password >
	</cffunction>

	<!--- ************************************************************* --->

</cfcomponent>