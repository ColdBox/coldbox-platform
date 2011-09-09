<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/16/2007
Description :
	This is the Application.cfc for usage withing the ColdBox Framework.
	Make sure that it extends the coldbox object:
	coldbox.system.Coldbox
	
	So if you have refactored your framework, make sure it extends coldbox.
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.Coldbox" output="false">

	<!--- APPLICATION CFC PROPERTIES --->
	<cfset this.name = hash(getCurrentTemplatePath())> 
	<cfset this.sessionManagement = true>
	<cfset this.sessionTimeout = createTimeSpan(0,0,30,0)>
	<cfset this.setClientCookies = true>
	<cfset this.clientManagement = true>
	
	<!--- COLDBOX STATIC PROPERTY, DO NOT CHANGE UNLESS THIS IS NOT THE ROOT OF YOUR COLDBOX APP --->
	<cfset COLDBOX_APP_ROOT_PATH = getDirectoryFromPath(getCurrentTemplatePath())>

	<!--- COLDBOX PROPERTIES --->
	<cfset COLDBOX_CONFIG_FILE = "">
	
	<!--- on Application Start --->
	<cffunction name="onApplicationStart" returnType="boolean" output="false">
		<cfset var start = getTickCOunt()>
		<cfscript>
			//Load ColdBox
			loadColdBox();
			request.fwloadTime = getTickCount() - start;
			return true;
		</cfscript>
	</cffunction>
	
	<!--- on Request Start --->
	<cffunction name="onRequestStart" returnType="boolean" output="true">
		<!--- ************************************************************* --->
		<cfargument name="targetPage" type="string" required="true" />
		<!--- ************************************************************* --->
		<cfset var start = getTickCount()>
		<cfsetting enablecfoutputonly="yes">
		<!--- Reload Checks --->
		<cfset reloadChecks()>
		<cfset request.fwLoadTIme = getTickCount() - start>
		
		<!--- Process A ColdBox Request Only --->
		<cfif findNoCase('index.cfm', listLast(arguments.targetPage, '/'))>
			<cfset processColdBoxRequest()>
		</cfif>
			
		<!--- WHATEVER YOU WANT BELOW --->
		<cfsetting enablecfoutputonly="no">
		<cfreturn true>
	</cffunction>
	
	<!--- on Application End --->
	<cffunction name="onApplicationEnd" returnType="void"  output="false">
		<!--- ************************************************************* --->
		<cfargument name="applicationScope" type="struct" required="true">
		<!--- ************************************************************* --->
		<!--- WHATEVER YOU WANT BELOW --->
	</cffunction>
	
	<!--- on Session Start --->
	<cffunction name="onSessionStart" returnType="void" output="false">			
		<cfset super.onSessionStart()>
		<!--- WHATEVER YOU WANT BELOW --->
	</cffunction>
	
	<!--- on Session End --->
	<cffunction name="onSessionEnd" returnType="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="sessionScope" type="struct" required="true">
		<cfargument name="appScope" 	type="struct" required="false">
		<!--- ************************************************************* --->
		<cfset super.onSessionEnd(argumentCollection=arguments)>
		<!--- WHATEVER YOU WANT BELOW --->
	</cffunction>
	
</cfcomponent>