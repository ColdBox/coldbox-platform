<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Description :
	I model mail server settings. You can send this bean to model or EJB's
	and when sending email. It will use its settings.


----------------------------------------------------------------------->
<cfcomponent hint="I model mail server settings" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" hint="I return a mail setting bean." returntype="MailSettingsBean">
		<!--- ************************************************************* --->
		<cfargument name="server"	required="false" default="">
		<cfargument name="username"	required="false" default="">
		<cfargument name="password"	required="false" default="">
		<cfargument name="port"		required="false" default="">
		<!--- ************************************************************* --->
		<cfscript>
			instance 			= structnew();
			instance.server 	= arguments.server;
			instance.username 	= arguments.username;
			instance.password 	= arguments.password;
			instance.port 		= arguments.port;
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- memento --->
	<cffunction name="getMemento" access="public" returntype="any" output="false" hint="Get the memento">
		<cfreturn variables.instance >
	</cffunction>
	<cffunction name="setMemento" access="public" returntype="void" output="false" hint="Set the memento">
		<cfargument name="memento" type="struct" required="true">
		<cfset variables.instance = arguments.memento>
	</cffunction>

	<!--- get/set server --->
	<cffunction name="setServer" access="public" return="any" output="false" hint="Set server">
		<cfargument name="server" >
		<cfset instance.server=arguments.server >
		<cfreturn this>
	</cffunction>
	<cffunction name="getServer" access="public" return="string" output="false" hint="Get server">
		<cfreturn instance.server >
	</cffunction>

	<!--- get/set port --->
	<cffunction name="setPort" access="public" return="any" output="false" hint="Set port">
		<cfargument name="port" >
		<cfset instance.port=arguments.port >
		<cfreturn this>
	</cffunction>
	<cffunction name="getPort" access="public" return="string" output="false" hint="Get port">
		<cfreturn instance.port >
	</cffunction>
	
	<!--- get/set username --->
	<cffunction name="setUsername" access="public" return="any" output="false" hint="Set Username">
	  <cfargument name="username" >
	  <cfset instance.username=arguments.username >
	  <cfreturn this>
	</cffunction>
	<cffunction name="getUsername" access="public" return="string" output="false" hint="Get Username">
		<cfreturn instance.Username >
	</cffunction>

	<!--- get/set password --->
	<cffunction name="setPassword" access="public" return="any" output="false" hint="Set Password">
		<cfargument name="password" >
		<cfset instance.password=arguments.password >
		<cfreturn this>
	</cffunction>
	<cffunction name="getPassword" access="public" return="string" output="false" hint="Get Password">
		<cfreturn instance.Password >
	</cffunction>

</cfcomponent>