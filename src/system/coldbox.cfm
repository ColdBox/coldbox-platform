<cfsetting enablecfoutputonly="yes">
<!-----------------------------------------------------------------------
Template : coldbox.cfm
Author 	 :	Luis Majano
Date     :	October 1, 2005
Description :
	This is the coldbox framework runnable template. You will need
	a coldfusion mapping to your application's root directory in order
	for the framework to work. You will place this mapping name in your
	{appRoot}/config/config.xml.cfm. If this file
	does not exists the framework will not start also.

	Please view the quickstart guide if you have more questions.

Modification History:
06/07/2006 - Updated to coldbox.
08/07/2006 - Ticket #45 fix, autoreloadflag cleaned handlers.
---------------------------------------------------------------------->
<cfparam type="boolean" name="url.fwreinit" default="false">
<!--- Initialize timing variable --->
<cfset request.fwExecTime = GetTickCount()>
<cftry>
	<!--- Initialize the Controller --->
	<cfif not structkeyExists(session,"fwController") or not structKeyExists(application, "ColdBox_fwInitiated") or url.fwreinit>
		<cflock type="exclusive" scope="session" timeout="120">
			<cfif not structkeyExists(session,"fwController") or url.fwreinit>
				<cfset session.fwController = CreateObject("component","controller").init()>
			</cfif>
		</cflock>
		<!--- Initialize the Structures --->
		<cflock type="exclusive" name="Coldbox_configloader" timeout="120">
			<cfif not structKeyExists(application, "ColdBox_fwInitiated") or url.fwreinit>
				<cfset session.fwController.getPlugin("settings").configLoader()>
				<cfset session.fwController.setDebugMode(session.fwController.getSetting("DebugMode"))>
				<cfset session.fwController.getPlugin("settings").registerHandlers()>
			</cfif>
		</cflock>
	<cfelse>
		<!--- AutoReload Tests --->
		<cfif session.fwController.getSetting("ConfigAutoReload")>
			<cflock type="exclusive" name="Coldbox_configloader" timeout="120">
				<cfset session.fwController.getPlugin("settings").configLoader()>
				<cfset session.fwController.setDebugMode(session.fwController.getSetting("DebugMode"))>
				<cfset session.fwController.getPlugin("settings").registerHandlers()>
			</cflock>
		<cfelseif session.fwController.getSetting("HandlersIndexAutoReload")>
			<cflock type="exclusive" name="Coldbox_configloader" timeout="120">
				<cfset session.fwController.getPlugin("settings").registerHandlers()>
			</cflock>
		</cfif>
	</cfif>
	<!--- Trap Framework Errors --->
	<cfcatch type="any">
		<cfset ExceptionBean = session.fwController.getPlugin("settings").ExceptionHandler(cfcatch,"framework","Framework Initialization/Configuration Exception")>
		<cfoutput>#session.fwController.getPlugin("renderer").renderBugReport(ExceptionBean)#</cfoutput>
		<cfabort>
	</cfcatch>
</cftry>
<!--- Start Application Requests --->
<cftry>
	<!--- Request Capture --->
	<cfset session.fwController.reqCapture(FORM, URL)>
	<!--- Application Start Handler --->	
	<cfif session.fwController.getSetting("ApplicationStartHandler") neq "" and (not Application.ColdBox_fwAppStartHandlerFired or url.fwreinit)>
		<!--- Test for ApplicationStartHandler --->
		<cfset session.fwController.runEvent(session.fwController.getSetting("ApplicationStartHandler"))>
		<cfset application.ColdBox_fwAppStartHandlerFired = true>
	</cfif>
	<!--- IF Found in config, run onRequestStart Handler --->
	<cfif session.fwController.getSetting("RequestStartHandler") neq "">
		<cfset session.fwController.runEvent(session.fwController.getSetting("RequestStartHandler"))>
	</cfif>
	<!--- Run Default/Set Event --->
	<cfset session.fwController.runEvent()>
	<!--- Render Layout/View pair using plugin factory --->
	<cfoutput>#session.fwController.getPlugin("renderer").renderLayout()#</cfoutput>
	<!--- If Found in config, run onRequestEnd Handler --->
	<cfif session.fwController.getSetting("RequestEndHandler") neq "">
		<cfset session.fwController.runEvent(session.fwController.getSetting("RequestEndHandler"))>
	</cfif>
	<cfcatch type="any">
		<cfset ExceptionBean = session.fwController.getPlugin("settings").ExceptionHandler(cfcatch,"application","Application Execution Exception")>
		<cfoutput>#session.fwController.getPlugin("renderer").renderBugReport(ExceptionBean)#</cfoutput>
	</cfcatch>
</cftry>
<!--- Time the request --->
<cfset request.fwExecTime = GetTickCount() - request.fwExecTime>
<!--- DebugMode Renders --->
<cfif session.fwController.getDebugMode()>
	<cfoutput>#session.fwController.getPlugin("renderer").renderDebugLog()#</cfoutput>
</cfif>
<cfsetting enablecfoutputonly="no">