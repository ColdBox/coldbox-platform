<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/16/2007
Description :
	This is the Application.cfc for usage withing the ColdBox Framework.
	Make sure that it extends the coldbox object:
	coldbox.system.Coldbox
	
	So if you have refactored your framework, make sure it extends coldbox.
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
	<cfset COLDBOX_APP_MAPPING   = "">
	
	<!--- COLDBOX PROPERTIES --->
	<cfset COLDBOX_CONFIG_FILE = "">
	
	<!--- COLDBOX APPLICATION KEY OVERRIDE --->
	<cfset COLDBOX_APP_KEY = "">
	
	<!--- on Application Start --->
	<cffunction name="onApplicationStart" returnType="boolean" output="false">
		<cfscript>
			//Load ColdBox
			loadColdBox();
			return true;
		</cfscript>
	</cffunction>
	
	<!--- on Request Start --->
	<cffunction name="onRequestStart" returnType="boolean" output="true">
		<!--- ************************************************************* --->
		<cfargument name="targetPage" type="string" required="true" />
		<!--- ************************************************************* --->
		<!--- Reload Checks --->
		<cfset reloadChecks()>
		
		<!--- Process A ColdBox Request Only --->
		<cfif findNoCase('index.cfm', listLast(arguments.targetPage, '/'))>
			<cfset processColdBoxRequest()>
		</cfif>
			
		<!--- WHATEVER YOU WANT BELOW --->
		<cfreturn true>
	</cffunction>

</cfcomponent>