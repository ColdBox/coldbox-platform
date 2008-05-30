<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
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
		instance.isPrivate = false;
		instance.isMissingAction = false;
		instance.MissingAction = "";
	</cfscript>

	<cffunction name="init" access="public" returntype="coldbox.system.beans.eventhandlerBean" output="false">
		<cfargument name="invocationPath" type="string" required="false" default="" hint="The default invocation path" />
		<cfset setInvocationPath(arguments.invocationPath)>
		<cfreturn this >
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- Get Set Memento --->
	<cffunction name="getMemento" access="public" returntype="struct" output="false" hint="Get the memento">
		<cfreturn variables.instance >
	</cffunction>
	<cffunction name="setmemento" access="public" returntype="void" output="false" hint="Set the memento">
		<cfargument name="memento" type="struct" required="true">
		<cfset variables.instance = arguments.memento>
	</cffunction>
		
	<!--- Get Full Event Syntax --->
	<cffunction name="getFullEvent" access="public" returntype="any" output="false">
		<cfreturn getHandler() & "." & getMethod()>
	</cffunction>

	<!--- Getr Runnable object --->
	<cffunction name="getRunnable" access="public" returntype="any" output="false">
		<cfreturn getInvocationPath() & "." & getHandler()>
	</cffunction>
	
	<!--- Get/Set Method --->
	<cffunction name="setMethod" access="public" returntype="void" output="false">
		<cfargument name="method" type="string" required="true" />
		<cfset instance.method = arguments.method>
	</cffunction>
	<cffunction name="getMethod" access="public" returntype="any" output="false">
		<cfreturn instance.method >
	</cffunction>
	
	<!--- Get/Set Private --->
	<cffunction name="getisPrivate" access="public" returntype="boolean" output="false">
		<cfreturn instance.isPrivate>
	</cffunction>
	<cffunction name="setisPrivate" access="public" returntype="void" output="false">
		<cfargument name="isPrivate" type="boolean" required="true">
		<cfset instance.isPrivate = arguments.isPrivate>
	</cffunction>

	<!--- Get/Set Handler name --->
	<cffunction name="setHandler" access="public" returntype="void" output="false">
		<cfargument name="handler" type="any" required="true" />
		<cfset instance.handler = arguments.handler >
	</cffunction>
	<cffunction name="getHandler" access="public" returntype="any" output="false">
		<cfreturn instance.handler >
	</cffunction>

	<!--- Get Set Invocation Path --->
	<cffunction name="setInvocationPath" access="public" returntype="void" output="false">
		<cfargument name="InvocationPath" type="any" required="true" />
		<cfset instance.InvocationPath = arguments.InvocationPath >
	</cffunction>
	<cffunction name="getInvocationPath" access="public" returntype="any" output="false">
		<cfreturn instance.InvocationPath >
	</cffunction>
	
	<!--- Is missing Action --->
	<cffunction name="getisMissingAction" access="public" returntype="boolean" output="false">
		<cfreturn instance.isMissingAction>
	</cffunction>
	<cffunction name="setisMissingAction" access="public" returntype="void" output="false">
		<cfargument name="isMissingAction" type="boolean" required="true">
		<cfset instance.isMissingAction = arguments.isMissingAction>
	</cffunction>
	
	<!--- Missing Action item. --->
	<cffunction name="getmissingAction" access="public" returntype="string" output="false">
		<cfreturn instance.missingAction>
	</cffunction>
	<cffunction name="setmissingAction" access="public" returntype="void" output="false">
		<cfargument name="missingAction" type="string" required="true">
		<cfset instance.missingAction = arguments.missingAction>
	</cffunction>

</cfcomponent>