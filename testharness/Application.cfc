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
<cfcomponent output="false">

	<!--- APPLICATION CFC PROPERTIES --->
	<cfset this.name = "Test Harness" & hash(getCurrentTemplatePath())>
	<cfset this.sessionManagement = true>
	<cfset this.sessionTimeout = createTimeSpan(0,0,1,0)>
	<cfset this.setClientCookies = true>
	<cfset this.clientManagement = true>

	<!--- COLDBOX STATIC PROPERTY, DO NOT CHANGE UNLESS THIS IS NOT THE ROOT OF YOUR COLDBOX APP --->
	<cfset COLDBOX_APP_ROOT_PATH = getDirectoryFromPath(getCurrentTemplatePath())>
	<!--- The web server mapping to this application. Used for remote purposes or static purposes --->
	<cfset COLDBOX_APP_MAPPING   = "/coldbox/testharness">
	<!--- COLDBOX PROPERTIES --->
	<cfset COLDBOX_CONFIG_FILE = "">
	<!--- COLDBOX APPLICATION KEY OVERRIDE --->
	<cfset COLDBOX_APP_KEY = "">

	<cfset this.mappings["/coldbox"] = expandPath('../') />
	<cfset this.mappings["/testmodel"] = expandpath("../testing/testmodel")>

	<cfset this.datasource = "coolblog">

	<!---<cfif NOT structKeyExists(server,"railo")>--->
		<cfset this.ormEnabled = "true">
		<cfset this.ormSettings = {
			dialect = "MySQLwithInnoDB",
			cfclocation = ["/coldbox","/testmodel"],
			skipCFCWithError = true,
			eventHandling=true,
			logSQL = true,
			eventhandling = true,
			eventhandler = "model.EventHandler",
			secondarycacheenabled = true,
			cacheProvider = "ehcache",
			flushAtRequestEnd = false
		}>
	<!---</cfif>--->

	<!--- on Application Start --->
	<cffunction name="onApplicationStart" returnType="boolean" output="false">
		<cfset var start = getTickCOunt()>
		<cfscript>
			request.fwloadTime = getTickCount() - start;

			application.cbBootstrap = CreateObject("component","coldbox.system.Coldbox").init(COLDBOX_CONFIG_FILE,COLDBOX_APP_ROOT_PATH,COLDBOX_APP_KEY,COLDBOX_APP_MAPPING);
			application.cbBootstrap.loadColdbox();

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
		<cfsetting showdebugoutput="true">

		<!---<cfset structDelete(application,"cbBootStrap")>
		<cfset structDelete(application,"cbController")>
		<cfset structDelete(application,"wirebox")>
		<cfdump var="#application#"><cfabort>--->

		<cfif structKeyExists(url,"fwreinit")>
			<cfset structDelete(application,"cbBootStrap")>
			<cfset structDelete(application,"cbController")>
			<cfset structDelete(application,"wirebox")>
		</cfif>
		<cfif structKeyExists(URL,"ormreinit")>
			<cfset ORMReload()>
		</cfif>

		<!--- BootStrap Reinit Check --->
		<cfif not structKeyExists(application,"cbBootstrap") or application.cbBootStrap.isfwReinit()>
			<cflock name="coldbox.bootstrap_#hash(getCurrentTemplatePath())#" type="exclusive" timeout="5" throwontimeout="true">
				<cfset structDelete(application,"cbBootStrap")>
				<cfset application.cbBootstrap = CreateObject("component","coldbox.system.Coldbox").init(COLDBOX_CONFIG_FILE,COLDBOX_APP_ROOT_PATH,COLDBOX_APP_KEY,COLDBOX_APP_MAPPING)>
			</cflock>
		</cfif>

		<!--- Reload Checks --->
		<cfset application.cbBootstrap.reloadChecks()>
		<cfset request.fwLoadTIme = getTickCount() - start>

		<!--- Process A ColdBox Request Only --->
		<cfif findNoCase('index.cfm', listLast(arguments.targetPage, '/'))>
			<cfset application.cbBootstrap.processColdBoxRequest()>
		</cfif>

		<!--- WHATEVER YOU WANT BELOW --->
		<cfsetting enablecfoutputonly="no">
		<cfreturn true>
	</cffunction>

	<!--- onrequest end --->
	<cffunction name="onrequestend">
		<cfif structKeyExists(url,"appstop")>
			<cfset applicationStop()>
		</cfif>
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
		<cfset application.cbBootstrap.onSessionStart()>
		<!--- WHATEVER YOU WANT BELOW --->
	</cffunction>

	<!--- on Session End --->
	<cffunction name="onSessionEnd" returnType="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="sessionScope" type="struct" required="true">
		<cfargument name="appScope" 	type="struct" required="false">
		<!--- ************************************************************* --->
		<cfset appScope.cbBootstrap.onSessionEnd(argumentCollection=arguments)>
		<!--- WHATEVER YOU WANT BELOW --->
	</cffunction>

</cfcomponent>