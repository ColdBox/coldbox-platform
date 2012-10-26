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
	<cfset this.name = "ColdBoxTestHarness" & hash(getCurrentTemplatePath())>
	<cfset this.sessionManagement = true>
	<cfset this.setClientCookies = true>
	<cfset this.clientManagement = true>
	<cfset this.sessionTimeout = createTimeSpan(0,0,5,0)>

	<cfset this.mappings["/testmodel"] = expandPath("/coldbox/testing/testmodel")>
	<cfset this.mappings["/testing"] = expandPath("/coldbox/testing")>

	<cfset this.datasource = "coolblog">
	<cfset this.ormEnabled = "true">
	
	<cfset this.ormSettings = {
		logSQL = true,
		dbcreate = "update",
		secondarycacheenabled = true,
		cacheProvider = "ehcache",
		flushAtRequestEnd = false,
		eventhandling = true,
		eventHandler = "testmodel.EventHandler"
	}>

	<!--- <cfset this.ormsettings.eventhandler = "testmodel.EventHandler"> --->

	<!--- on Request Start --->
	<cffunction name="onRequestStart" returnType="boolean" output="true">
		<!--- ************************************************************* --->
		<cfargument name="targetPage" type="string" required="true" />
		<!--- ************************************************************* --->

		<!---<cfif structKeyExists(URL,"reinit")>--->
		<cfset ORMReload()>
		<!---</cfif>--->

		<!---<cfset application.wirebox = createObject("component","coldbox.system.ioc.Injector").init()>--->

		<cfreturn true>
	</cffunction>

</cfcomponent>