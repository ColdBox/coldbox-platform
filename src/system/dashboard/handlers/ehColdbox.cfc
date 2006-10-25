<!---
Author			:	Luis Majano
Create Date		:	September 19, 2005
Update Date		:	September 25, 2006
Description		:

This is the main event handler for the ColdBox dashboard.

--->
<cfcomponent name="ehColdBox" extends="coldbox.system.eventhandler">

	<!--- ************************************************************* --->

	<cffunction name="onAppStart" access="public" returntype="void">
		<cfset var MyService = getSetting("AppMapping") & ".model.dbservice">
		<cfset application.dbservice = CreateObject("component",MyService).init()>
		<cfset application.isBD = server.ColdFusion.ProductName neq "Coldfusion Server">
	</cffunction>
	
	<!--- ************************************************************* --->

	<cffunction name="onRequestStart" access="public" returntype="void">
		<!--- Authorization --->
		<cfif (not isDefined("session.authorized") or session.authorized eq false) and
			  getValue("event") neq "ehColdbox.doLogin">
			<cfset overrideEvent("ehColdbox.dspLogin")>
		</cfif>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehLogout = "ehColdbox.doLogout">
	</cffunction>

	<!--- ************************************************************* --->
	<!--- LOGIN SECTION													--->
	<!--- ************************************************************* --->
	
	<cffunction name="dspLogin" access="public" returntype="void">
		<!--- EVENT HANDLERS: --->
		<cfset rc.xehLogin = "ehColdbox.doLogin">
		<!--- Set the View --->
		<cfset setView("vwLogin")>
	</cffunction>
	
	<cffunction name="doLogin" access="public" returntype="void">
		<!--- Do Login --->
		<cfif len(trim(getValue("password",""))) eq 0>
			<cfset getPlugin("messagebox").setMessage("error", "Please fill out the password field.")>
			<cfset setNextEvent()>
		</cfif>
		<cfif application.dbservice.get("settings").validatePassword(getvalue("password"))>
			<!--- Validate user --->
			<cfset session.authorized = true>
			<cfset setNextEvent()>
		<cfelse>
			<cfset getPlugin("messagebox").setMessage("error", "The password you entered is not correct. Please try again.")>
			<cfset setNextEvent()>
		</cfif>
	</cffunction>
	
	<cffunction name="doLogout" access="public" returntype="void">
		<cfset session.authorized = false>
		<cfset SetNextEvent("ehColdbox.dspLogin")>
	</cffunction>
	
	<!--- ************************************************************* --->
	<!--- FRAMESET SECTION												--->
	<!--- ************************************************************* --->
	
	<cffunction name="dspFrameset" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehHome = "ehColdbox.dspHome">
		<cfset rc.xehHeader = "ehColdbox.dspHeader">
		<!--- Set the View --->
		<cfset setView("vwFrameset",true)>
	</cffunction>
	
	<cffunction name="dspHome" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehSystemInfo = "ehInfo.dspSystemInfo">
		<cfset rc.xehResources = "ehInfo.dspOnlineResources">
		<cfset rc.xehCFCDocs = "ehInfo.dspCFCDocs">
		<!--- Set the Rollovers --->
		<cfset rc.qRollovers = filterQuery(application.dbservice.get("settings").getRollovers(),"pagesection","home")>
		
		<!--- Set the View --->
		<cfset setView("vwHome")>
	</cffunction>
	
	<cffunction name="dspHeader" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehHome = "ehColdbox.dspHome">
		<cfset rc.xehSettings = "ehSettings.dspSettings">
		<cfset rc.xehTools = "ehColdbox.dspTools">
		<cfset rc.xehUpdate = "ehUpdater.dspUpdateSection">
		<cfset rc.xehBugs = "ehBugs.dspBugs">
		<!--- Set the View --->
		<cfset setView("tags/header")>
	</cffunction>
	
		
	<!--- ************************************************************* --->
	<!--- TOOLS SECTION 												--->
	<!--- ************************************************************* --->
	
	<cffunction name="dspTools" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehAppBuilder = "ehAppBuilder.dspAppBuilder">
		<cfset rc.xehLogViewer = "ehLogViewer.dspLogViewer">
		<cfset rc.xehCFCGenerator = "ehGenerator.dspcfcGenerator">
		<!--- Set the Rollovers For This Section --->
		<cfset rc.qRollovers = filterQuery(application.dbservice.get("settings").getRollovers(),"pagesection","tools")>
		<!--- Set the View --->
		<cfset setView("vwTools")>
	</cffunction>

	
</cfcomponent>