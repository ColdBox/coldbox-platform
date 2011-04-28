<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/16/2007
Description :
	This is the bootstrapper Application.cfc for ColdBox Applications.
	It uses inheritance on the CFC, so if you do not want inheritance
	then use the Application_noinheritance.cfc instead.
	
	
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.Coldbox" output="false">
	<cfsetting enablecfoutputonly="yes">
	
	<!--- APPLICATION CFC PROPERTIES --->
	<cfset this.name = hash(getCurrentTemplatePath())> 
	<cfset this.sessionManagement = true>
	<cfset this.sessionTimeout = createTimeSpan(0,0,30,0)>
	<cfset this.setClientCookies = true>
	
	<!--- COLDBOX STATIC PROPERTY, DO NOT CHANGE UNLESS THIS IS NOT THE ROOT OF YOUR COLDBOX APP --->
	<cfset COLDBOX_APP_ROOT_PATH = getDirectoryFromPath(getCurrentTemplatePath())>
	<!--- The web server mapping to this application. Used for remote purposes or static purposes --->
	<!--- THIS IS SUPER IMPORTANT AND MANDATORY FOR FLEX/AIR APPS --->
	<cfset COLDBOX_APP_MAPPING   = "/coldbox/ApplicationTemplates/FlexAirRemote">
	<!--- COLDBOX PROPERTIES --->
	<cfset COLDBOX_CONFIG_FILE   = "">	
	<!--- COLDBOX APPLICATION KEY OVERRIDE --->
	<cfset COLDBOX_APP_KEY       = "">

</cfcomponent>