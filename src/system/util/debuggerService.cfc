<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	This cfc takes care of debugging settings.

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="debuggerService" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="coldbox.system.util.debuggerService" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			variables.controller = arguments.controller;
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<cffunction name="getDebugMode" access="public" hint="I Get the current user's debugmode" returntype="boolean"  output="false">
		<cfset var appName = getNamedHash()>
		<cfif structKeyExists(cookie,"ColdBox_debugMode_#appName#")>
			<cfreturn cookie["ColdBox_debugMode_#appName#"]>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
	
	<cffunction name="setDebugMode" access="public" hint="I set the current user's debugmode" returntype="void"  output="false">
		<cfargument name="mode" type="boolean" required="true" >
		<cfset var appName = getNamedHash()>
		<cfif arguments.mode>
			<cfcookie name="ColdBox_debugMode_#appName#" value="true">
		<cfelseif structKeyExists(cookie,"ColdBox_debugMode_#appName#")>
			<cfcookie name="ColdBox_debugMode_#appName#" value="false" expires="#now()#">
		</cfif>
	</cffunction>
	
	<cffunction name="renderDebugLog" access="public" hint="Return the debug log." output="false" returntype="Any">
		<cfset var RenderedDebugging = "">
		<cfset var Event = controller.getRequestService().getContext()>
		<!--- Set local Variables --->
		<cfset var itemTypes = controller.getColdboxOCM().getItemTypes()>
		<!--- Setup Local Variables --->
		<cfset var debugStartTime = GetTickCount()>
		<cfset var RequestCollection = Event.getCollection()>
		<!--- JVM Data --->
		<cfset var JVMFreeMemory = controller.getPlugin("fileUtilities").getJVMfreeMemory()/1024>
		<cfset var JVMTotalMemory = controller.getPlugin("fileUtilities").getJVMTotalMemory()/1024>
		<cfsavecontent variable="RederedDebugging"><cfinclude template="../includes/debug.cfm"></cfsavecontent>
		<cfreturn RederedDebugging>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<cffunction name="getNamedHash" returntype="string" access="private" output="false" hint="Provide a hash name for the cookie.">
	<cfscript>
		return hash(controller.getSetting("AppName"));
	</cfscript>	
	</cffunction>

</cfcomponent>