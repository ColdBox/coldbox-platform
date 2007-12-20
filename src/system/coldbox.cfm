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
	Please use the Application.cfc method instead. This file will be deprecated later on.

	Please view the quickstart guide if you have more questions.
---------------------------------------------------------------------->
<cfparam name="COLDBOX_CONFIG_FILE" default="" type="string">
<cfparam name="COLDBOX_APP_ROOT_PATH" default="#getDirectoryFromPath(getbaseTemplatePath())#" type="string">
	
<!--- Create the BootStrapper --->
<cfset coldbox = CreateObject("component","coldbox")>

<!--- Set the ColdBox App Root --->
<cfset coldbox.setCOLDBOX_APP_ROOT_PATH(COLDBOX_APP_ROOT_PATH)>
<!--- Set the Coldbox Config File --->
<cfset coldbox.setCOLDBOX_CONFIG_FILE(COLDBOX_CONFIG_FILE)>

<!--- Reload Checks --->
<cfset coldbox.reloadChecks()>

<!--- Process Request --->
<cfset coldbox.processColdBoxRequest()>

<cfsetting enablecfoutputonly="no">