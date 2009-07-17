<cfsetting enablecfoutputonly="yes">
<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Template : coldbox.cfm
Author 	 :	Luis Majano
Date     :	October 1, 2005
Description :
	Please use the Application.cfc method instead. This file will be deprecated later on.

	Please view the quickstart guide if you have more questions.
---------------------------------------------------------------------->
<cfparam name="COLDBOX_CONFIG_FILE" default="" type="string">
<cfparam name="COLDBOX_APP_ROOT_PATH" default="#getDirectoryFromPath(getbaseTemplatePath())#" type="string">
	
<!--- Create the BootStrapper --->
<cfif not structKeyExists(application,"cbBootstrap") or application.cbBootstrap.isfwReinit()>
	<cflock name="coldbox.bootstrap_#hash(getBaseTemplatePath())#" type="exclusive" timeout="5" throwontimeout="true">
	<cfif not structKeyExists(application,"cbBootstrap") or application.cbBootstrap.isfwReinit()>
		<cfset structDelete(application,"cbBootStrap")>
		<cfset application.cbBootStrap = CreateObject("component","coldbox")>
	</cfif>
	</cflock>
</cfif>

<!--- Reference --->
<Cfset coldbox = application.cbBootStrap>

<!--- Set the ColdBox App Root --->
<cfset coldbox.setCOLDBOX_APP_ROOT_PATH(COLDBOX_APP_ROOT_PATH)>
<!--- Set the Coldbox Config File --->
<cfset coldbox.setCOLDBOX_CONFIG_FILE(COLDBOX_CONFIG_FILE)>

<!--- Reload Checks --->
<cfset coldbox.reloadChecks()>

<!--- Process Request --->
<cfset coldbox.processColdBoxRequest()>

<cfsetting enablecfoutputonly="no">