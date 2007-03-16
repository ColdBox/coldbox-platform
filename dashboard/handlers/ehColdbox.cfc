<!---
Author			:	Luis Majano
Create Date		:	September 19, 2005
Update Date		:	September 25, 2006
Description		:

This is the main event handler for the ColdBox dashboard.

--->
<cfcomponent name="ehColdBox" extends="coldbox.system.eventhandler" output="false">

	<!--- ************************************************************* --->

	<cffunction name="onAppStart" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfscript>
			var MyService = getSetting("AppMapping") & ".model.dbservice";
			var dbService = CreateObject("component",MyService).init();
			//place in cache
			getColdboxOCM().set("dbservice",dbService);
			getColdboxOCM().set("isBD",server.ColdFusion.ProductName neq "Coldfusion Server",0);
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->

	<cffunction name="onRequestStart" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var storage = getPlugin("sessionstorage")>
		<!--- Check if the dbservice is set, else set it in cache --->
		<cfif not getColdboxOCM().lookup("dbservice")>
			<cfset onAppStart()>
		</cfif>
		<!--- GLOBAL EXIT HANDLERS: --->
		<cfset Event.setValue("xehLogout","ehSecurity.doLogout")>
		<!--- Inject dbservice to Eventon every request for usage --->
		<cfset Event.setValue("dbService",getColdBoxOCM().get("dbservice"))>
		<!--- Authorization --->
		<cfif (not storage.exists("authorized") or storage.getvar("authorized") eq false) and Event.getValue("event") neq "ehSecurity.doLogin">
			<cfset Event.overrideEvent("ehSecurity.dspLogin")>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->
	<!--- FRAMESET SECTION												--->
	<!--- ************************************************************* --->
	
	<cffunction name="dspFrameset" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var rc = Event.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehHome = "ehColdbox.dspHome">
		<cfset rc.xehHeader = "ehColdbox.dspHeader">
		<!--- Set the View --->
		<cfset Event.setView("vwFrameset",true)>
	</cffunction>
	
	<cffunction name="dspHome" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var rc = Event.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehSystemInfo = "ehInfo.dspSystemInfo">
		<cfset rc.xehResources = "ehInfo.dspOnlineResources">
		<cfset rc.xehCFCDocs = "ehInfo.dspCFCDocs">
		<!--- Set the Rollovers --->
		<cfset rc.qRollovers = getPlugin("queryHelper").filterQuery(rc.dbService.get("settings").getRollovers(),"pagesection","home")>
		<!--- Set the View --->
		<cfset Event.setView("home/vwHome")>
	</cffunction>
	
	<cffunction name="dspHeader" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var rc = Event.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehHome = "ehColdbox.dspHome">
		<cfset rc.xehSettings = "ehSettings.dspSettings">
		<cfset rc.xehTools = "ehColdbox.dspTools">
		<cfset rc.xehUpdate = "ehUpdater.dspUpdateSection">
		<cfset rc.xehBugs = "ehBugs.dspBugs">
		<!--- Set the View --->
		<cfset Event.setView("tags/header")>
	</cffunction>
	
		
	<!--- ************************************************************* --->
	<!--- TOOLS SECTION 												--->
	<!--- ************************************************************* --->
	
	<cffunction name="dspTools" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehAppBuilder = "ehAppBuilder.dspAppBuilder">
		<cfset rc.xehLogViewer = "ehLogViewer.dspLogViewer">
		<cfset rc.xehCFCGenerator = "ehGenerator.dspcfcGenerator">
		<!--- Set the Rollovers For This Section --->
		<cfset rc.qRollovers = filterQuery(application.dbservice.get("settings").getRollovers(),"pagesection","tools")>
		<!--- Set the View --->
		<cfset Event.setView("vwTools")>
	</cffunction>

	
</cfcomponent>