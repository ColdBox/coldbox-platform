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
	var oSettings = session.fwController.getPlugin("settings");
	//Load Configuration
	oSettings.configLoader();
	//Register the Handlers.
	oSettings.registerHandlers();
	//Set the controller's debugMode
	session.fwController.setDebugMode(session.fwController.getSetting("DebugMode"));
	</cfscript>
</cffunction>

<cffunction name="isfwReinit" returntype="boolean">
 	<cfscript>
	var reinitPass = "";
	if ( not session.fwController.settingExists("ReinitPassword") )
		return true;
	else
		reinitPass = session.fwController.getSetting("ReinitPassword");
		
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
<cfset lockTimeout = 120>

<!--- Start Framework Request --->
<cftry>
	<!--- Initialize the Controller --->
	<cfif not structkeyExists(session,"fwController") or not structKeyExists(application, "ColdBox_fwInitiated") or isfwReinit()>
		<cflock type="exclusive" scope="session" timeout="#lockTimeout#">
			<cfif not structkeyExists(session,"fwController") or isfwReinit()>
				<cfset session.fwController = CreateObject("component","controller").init()>
			</cfif>
		</cflock>
		<!--- Initialize the Structures --->
		<cflock type="exclusive" name="Coldbox_configloader" timeout="#lockTimeout#">
			<cfif not structKeyExists(application, "ColdBox_fwInitiated") or isfwReinit()>
				<cfset setupCalls()>
			</cfif>
		</cflock>
	<cfelse>
		<!--- AutoReload Tests --->
		<cfif session.fwController.getSetting("ConfigAutoReload")>
			<cflock type="exclusive" name="Coldbox_configloader" timeout="#lockTimeout#">
				<cfset setupCalls()>
			</cflock>
		<cfelseif session.fwController.getSetting("HandlersIndexAutoReload")>
			<cflock type="exclusive" name="Coldbox_configloader" timeout="#lockTimeout#">
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
	<cfif session.fwController.getSetting("ApplicationStartHandler") neq "" and (not Application.ColdBox_fwAppStartHandlerFired)>
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
	
	<!--- Trap Application Errors --->
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