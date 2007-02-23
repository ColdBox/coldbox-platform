<cfsetting enablecfoutputonly="yes">
<!-----------------------------------------------------------------------
Copyright 2005 - 2006 ColdBox Framework by Luis Majano
www.coldboxframework.com | www.coldboxframework.org
-------------------------------------------------------------------------

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
---------------------------------------------------------------------->

<!---------------------------------------------------------------------->
<cffunction name="setupCalls" returntype="void">
	<cfscript>
	//Load Configuration
	application.cbController.configLoader();
	//Register the Handlers.
	application.cbController.registerHandlers();
	</cfscript>
</cffunction>

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
			<cfset setupCalls()>
		</cfif>
	</cflock>
<cfelse>
	<cftry>
		<!--- AutoReload Tests --->
		<cfif application.cbController.getSetting("ConfigAutoReload")>
			<cflock type="exclusive" name="Coldbox_configloader" timeout="#lockTimeout#">
				<cfset setupCalls()>
			</cflock>
		<cfelseif application.cbController.getSetting("HandlersIndexAutoReload")>
			<cflock type="exclusive" name="Coldbox_configloader" timeout="#lockTimeout#">
				<cfset application.cbController.registerHandlers()>
			</cflock>
		</cfif>

		<!--- Trap Framework Errors --->
		<cfcatch type="any">
			<cfset ExceptionBean = application.cbController.ExceptionHandler(cfcatch,"framework","Framework Initialization/Configuration Exception")>
			<cfoutput>#application.cbController.getPlugin("renderer").renderBugReport(ExceptionBean)#</cfoutput>
			<cfabort>
		</cfcatch>
	</cftry>
</cfif>

<!--- Start Application Requests --->
<cftry>
	<!--- Request Capture --->
	<cfset application.cbController.getRequestService().requestCapture()>

	<!--- Application Start Handler --->
	<cfif application.cbController.getSetting("ApplicationStartHandler") neq "" and (not application.cbController.getAppStartHandlerFired())>
		<cfset application.cbController.runEvent(application.cbController.getSetting("ApplicationStartHandler"))>
		<cfset application.cbController.setAppStartHandlerFired(true)>
	</cfif>

	<!--- IF Found in config, run onRequestStart Handler --->
	<cfif application.cbController.getSetting("RequestStartHandler") neq "">
		<cfset application.cbController.runEvent(application.cbController.getSetting("RequestStartHandler"))>
	</cfif>

	<!--- Run Default/Set Event --->
	<cfset application.cbController.runEvent()>

	<!--- Render Layout/View pair using plugin factory --->
	<cfoutput>#application.cbController.getPlugin("renderer").renderLayout()#</cfoutput>

	<!--- If Found in config, run onRequestEnd Handler --->
	<cfif application.cbController.getSetting("RequestEndHandler") neq "">
		<cfset application.cbController.runEvent(application.cbController.getSetting("RequestEndHandler"))>
	</cfif>

	<!--- Trap Application Errors --->
	<cfcatch type="any">
		<cfset ExceptionBean = application.cbController.ExceptionHandler(cfcatch,"application","Application Execution Exception")>
		<cfoutput>#application.cbController.getPlugin("renderer").renderBugReport(ExceptionBean)#</cfoutput>
	</cfcatch>
</cftry>

<!--- Time the request --->
<cfset request.fwExecTime = GetTickCount() - request.fwExecTime>
<!--- DebugMode Renders --->
<cfif application.cbController.getDebugMode()>
	<cfoutput>#application.cbController.getPlugin("renderer").renderDebugLog()#</cfoutput>
</cfif>
<cfsetting enablecfoutputonly="no">