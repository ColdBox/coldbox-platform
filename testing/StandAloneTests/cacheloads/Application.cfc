<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
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
	<cfset this.name = "ColdBox Cache Loads" & hash(getCurrentTemplatePath())> 
	<cfset this.sessionManagement = true>
	<cfset this.setClientCookies = true>
	<cfset this.clientManagement = true>
	<cfset this.sessionTimeout = createTimeSpan(0,0,5,0)>
	
</cfcomponent>