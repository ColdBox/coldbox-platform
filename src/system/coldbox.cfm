<cfsetting enablecfoutputonly="yes">
<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

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
08/20/2006 - Reusabel setupCalls()
12/20/2006 - fwreinit password enabled.
03/24/2007 - move to 2.0 Using Loader Service
---------------------------------------------------------------------->

<!---------------------------------------------------------------------->
<cffunction name="isfwReinit" returntype="boolean">
 	<cfscript>
	var reinitPass = "";
	if ( not application.cbController.settingExists("ReinitPassword") )
		return true;
	else
		reinitPass = application.cbController.getSetting("ReinitPassword");

	if ( structKeyExists(url,"fwreinit") ){
		if ( reinitPass eq "" ){
			return true;
		}
		else if ( Compare(reinitPass, url.fwreinit) eq 0){
			return true;
		}
		else{
			return false;
		}
	}
	else
		return false;
	</cfscript>
</cffunction>
<!---------------------------------------------------------------------->

<!--- Initialize timing variable --->
<cfset request.fwExecTime = GetTickCount()>
<cfset lockTimeout = 60>

<!--- Initialize the Controller --->
<cfif not structkeyExists(application,"cbController") or not application.cbController.getColdboxInitiated() or isfwReinit()>
	<cflock type="exclusive" scope="application" timeout="#lockTimeout#">
		<cfif not structkeyExists(application,"cbController") or not application.cbController.getColdboxInitiated() or isfwReinit()>
			<cfset application.cbController = CreateObject("component","coldbox.system.controller").init()>
			<cfset application.cbController.getService("loader").setupCalls()>
		</cfif>
	</cflock>
<cfelse>
	<cftry>
		<!--- AutoReload Tests --->
		<cfif application.cbController.getSetting("ConfigAutoReload")>
			<cflock type="exclusive" name="Coldbox_configloader" timeout="#lockTimeout#">
				<cfset application.cbController.getService("loader").setupCalls()>
			</cflock>
		<cfelseif application.cbController.getSetting("HandlersIndexAutoReload")>
			<cflock type="exclusive" name="Coldbox_configloader" timeout="#lockTimeout#">
				<cfset application.cbController.getService("loader").registerHandlers()>
				<!--- Clear Cache --->
				<cfset application.cbController.getColdboxOCM().clear()>
			</cflock>
		</cfif>

		<!--- Trap Framework Errors --->
		<cfcatch type="any">
			<cfset ExceptionService = application.cbController.getService("exception")>
			<cfset ExceptionBean = ExceptionService.ExceptionHandler(cfcatch,"framework","Framework Initialization/Configuration Exception")>
			<cfoutput>#ExceptionService.renderBugReport(ExceptionBean)#</cfoutput>
			<cfabort>
		</cfcatch>
	</cftry>
</cfif>

<!--- Start Application Requests --->
<cftry>
	<!--- Local Reference --->
	<cfset cbController = application.cbController>

	<!--- Create Request Context & Capture Request --->
	<cfset Event = cbController.getRequestService().requestCapture()>
	
	<!--- Debugging Monitors Check --->
	<cfif cbController.getDebuggerService().getDebugMode() and event.getValue("debugPanel","") neq "">
		<!--- Which panel to render --->
		<cfif event.getValue("debugPanel") eq "cache">
			<cfoutput>#cbController.getDebuggerService().renderCachePanel()#</cfoutput>
			<cfabort>
		</cfif>
	</cfif>
	
	<!--- Application Start Handler --->
	<cfif cbController.getSetting("ApplicationStartHandler") neq "" and (not cbController.getAppStartHandlerFired())>
		<cfset cbController.runEvent(cbController.getSetting("ApplicationStartHandler"),true)>
		<cfset cbController.setAppStartHandlerFired(true)>
	</cfif>

	<!--- IF Found in config, run onRequestStart Handler --->
	<cfif cbController.getSetting("RequestStartHandler") neq "">
		<cfset cbController.runEvent(cbController.getSetting("RequestStartHandler"),true)>
	</cfif>

	<!--- Run Default/Set Event --->
	<cfset cbController.runEvent()>

	<!--- Render Layout/View pair using plugin factory --->
	<cfoutput>#cbController.getPlugin("renderer").renderLayout()#</cfoutput>

	<!--- If Found in config, run onRequestEnd Handler --->
	<cfif cbController.getSetting("RequestEndHandler") neq "">
		<cfset cbController.runEvent(cbController.getSetting("RequestEndHandler"),true)>
	</cfif>

	<!--- Trap Application Errors --->
	<cfcatch type="any">
		<cfset ExceptionService = application.cbController.getService("exception")>
		<cfset ExceptionBean = ExceptionService.ExceptionHandler(cfcatch,"application","Application Execution Exception")>
		<cfoutput>#ExceptionService.renderBugReport(ExceptionBean)#</cfoutput>
	</cfcatch>
</cftry>

<!--- DebugMode Renders --->
<cfif cbController.getDebuggerService().getDebugMode() and Event.getdebugpanelFlag()>
	<!--- Time the request --->
	<cfset request.fwExecTime = GetTickCount() - request.fwExecTime>
	<!--- Render Debug Log --->
	<cfoutput>#cbController.getDebuggerService().renderDebugLog()#</cfoutput>
</cfif>
<cfsetting enablecfoutputonly="no">