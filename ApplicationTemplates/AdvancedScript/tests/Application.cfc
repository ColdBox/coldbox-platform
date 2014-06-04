<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/16/2007
Description :
	This is the Application.cfc for usage withing the ColdBox Framework.
	Make sure that it extends the coldbox object:
	coldbox.system.Coldbox

	So if you have refactored your framework, make sure it extends coldbox.
----------------------------------------------------------------------->
<cfcomponent output="false">

	<!--- APPLICATION CFC PROPERTIES --->
	<cfset this.name = "ColdBoxTestingSuite" & hash(getCurrentTemplatePath())>
	<cfset this.sessionManagement = true>
	<cfset this.sessionTimeout = createTimeSpan(0,0,30,0)>
	<cfset this.setClientCookies = true>

	<!--- Create testing mapping --->
	<cfset this.mappings[ "/tests" ] = getDirectoryFromPath( getCurrentTemplatePath() )>
	<!--- Map back to its root --->
	<cfset rootPath = REReplaceNoCase( this.mappings[ "/tests" ], "tests(\\|/)", "" )>
	<cfset this.mappings["/root"]   = rootPath>

</cfcomponent>