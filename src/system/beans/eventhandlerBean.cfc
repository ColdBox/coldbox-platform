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
<cfcomponent name="eventhandlerBean"
			 hint="I model a ColdBox event handler"
			 output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
	variables.instance = structnew();
	instance.invocationPath = "";
	instance.handler = "";
	instance.method = "";
	</cfscript>


	<!--- ************************************************************* --->

	<cffunction name="init" access="public" returntype="coldbox.system.beans.eventhandlerBean" output="false">
		<cfargument name="invocationPath" type="string" required="false" default="" hint="The default invocation path" />
		<cfset setInvocationPath(arguments.invocationPath)>
		<cfreturn this >
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->

	<cffunction name="getMemento" access="public" returntype="any" output="false" hint="Get the memento">
		<cfreturn variables.instance >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setmemento" access="public" returntype="void" output="false" hint="Set the memento">
		<cfargument name="memento" type="struct" required="true">
		<cfset variables.instance = arguments.memento>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getRunnable" access="public" returntype="any" output="false">
		<cfreturn getInvocationPath() & "." & getHandler()>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setMethod" access="public" returntype="void" output="false">
		<cfargument name="method" type="string" required="true" />
		<cfset instance.method = arguments.method>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getMethod" access="public" returntype="any" output="false">
		<cfreturn instance.method >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setHandler" access="public" returntype="void" output="false">
		<cfargument name="handler" type="string" required="true" />
		<cfset instance.handler = arguments.handler >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getHandler" access="public" returntype="any" output="false">
		<cfreturn instance.handler >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setInvocationPath" access="public" returntype="void" output="false">
		<cfargument name="InvocationPath" type="string" required="true" />
		<cfset instance.InvocationPath = arguments.InvocationPath >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getInvocationPath" access="public" returntype="any" output="false">
		<cfreturn instance.InvocationPath >
	</cffunction>

	<!--- ************************************************************* --->
</cfcomponent>