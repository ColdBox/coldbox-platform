<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	June 30, 2006
Description :
	I model mail server settings. You can send this bean to model or EJB's
	and when sending email. It will use its settings.

Modification History:

----------------------------------------------------------------------->
<cfcomponent name="mailsettingsBean"
			 hint="I model mail server settings"
			 output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		variables.instance = structnew();
		instance.server = "";
		instance.username = "";
	    instance.password = "" ;
		instance.port = "";
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

	<cffunction name="getmemento" access="public" returntype="any" output="false" hint="Get the memento">
		<cfreturn variables.instance >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setmemento" access="public" returntype="void" output="false" hint="Set the memento">
		<cfargument name="memento" type="struct" required="true">
		<cfset variables.instance = arguments.memento>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setserver" access="public" return="void" output="false" hint="Set server">
	  <cfargument name="server" type="string" >
	  <cfset instance.server=arguments.server >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getserver" access="public" return="string" output="false" hint="Get server">
	  <cfreturn instance.server >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setport" access="public" return="void" output="false" hint="Set port">
	  <cfargument name="port" type="string" >
	  <cfset instance.port=arguments.port >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getport" access="public" return="string" output="false" hint="Get port">
	  <cfreturn instance.port >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setUsername" access="public" return="void" output="false" hint="Set Username">
	  <cfargument name="Username" type="string" >
	  <cfset instance.Username=arguments.Username >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getUsername" access="public" return="string" output="false" hint="Get Username">
	  <cfreturn instance.Username >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setPassword" access="public" return="void" output="false" hint="Set Password">
	  <cfargument name="Password" type="string" >
	  <cfset instance.Password=arguments.Password >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getPassword" access="public" return="string" output="false" hint="Get Password">
	  <cfreturn instance.Password >
	</cffunction>

	<!--- ************************************************************* --->

</cfcomponent>