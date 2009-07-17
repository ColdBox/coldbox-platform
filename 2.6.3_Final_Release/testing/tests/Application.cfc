<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/16/2007
Description :
	This is the Application.cfc for usage withing the ColdBox Framework.
	Make sure that it extends the coldbox object:
	coldbox.system.coldbox
	
	So if you have refactored your framework, make sure it extends coldbox.
----------------------------------------------------------------------->
<cfcomponent output="false">

	<!--- APPLICATION CFC PROPERTIES --->
	<cfset this.name = "ColdBox Test Suite_" & hash(getCurrentTemplatePath())> 
	<cfset this.sessionManagement = true>
	<cfset this.setClientCookies = true>
	<cfset this.clientManagement = true>
	<cfset this.sessionTimeout = createTimeSpan(0,0,5,0)>
	
</cfcomponent>