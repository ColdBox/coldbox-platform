<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Luis Majano
Date     :	June 30, 2006
Description :
	I model a ColdBox Event Handler

Modification History:

----------------------------------------------------------------------->
<cfcomponent name="eventhandlerBean" hint="I model a ColdBox event handler" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
	variables.instance = structnew();
	variables.instance.invocationPath = "";
	variables.instance.handler = "";
	variables.instance.method = "";
	</cfscript>


	<!--- ************************************************************* --->

	<cffunction name="init" access="public" returntype="coldbox.system.beans.eventhandlerBean" output="false">
		<cfargument name="invocationPath" type="string" required="true" />
		<cfset setInvocationPath(arguments.invocationPath)>
		<cfreturn this >
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

	<cffunction name="getRunnable" access="public" returntype="any" output="false">
		<cfreturn getInvocationPath() & "." & getHandler()>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setMethod" access="public" returntype="void" output="false">
		<cfargument name="method" type="string" required="true" />
		<cfset variables.instance.method = arguments.method>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getMethod" access="public" returntype="any" output="false">
		<cfreturn variables.instance.method >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setHandler" access="public" returntype="void" output="false">
		<cfargument name="handler" type="string" required="true" />
		<cfset variables.instance.handler = arguments.handler >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getHandler" access="public" returntype="any" output="false">
		<cfreturn variables.instance.handler >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setInvocationPath" access="public" returntype="void" output="false">
		<cfargument name="InvocationPath" type="string" required="true" />
		<cfset variables.instance.InvocationPath = arguments.InvocationPath >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getInvocationPath" access="public" returntype="any" output="false">
		<cfreturn variables.instance.InvocationPath >
	</cffunction>

	<!--- ************************************************************* --->
</cfcomponent>