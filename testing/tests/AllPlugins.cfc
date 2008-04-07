<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
Description :
	Services test suites
	
----------------------------------------------------------------------->
<cfcomponent displayname="AllPlugins" output="false">  
	
	<cffunction name="suite" returntype="org.cfcunit.framework.Test" access="public" output="false">  
		<cfset var suite = CreateObject("component", "org.cfcunit.framework.TestSuite").init("ColdBox Plugins Suite")>  
		
		
		
		<!--- Add the test cases --->
		<cfset suite.addTestSuite(CreateObject("component", "cases.plugins.appstorageTest"))>
		<cfset suite.addTestSuite(CreateObject("component", "cases.plugins.beanfactoryTest"))>
		<cfset suite.addTestSuite(CreateObject("component", "cases.plugins.clientstorageTest"))>
		<cfset suite.addTestSuite(CreateObject("component", "cases.plugins.cookiestorageTest"))>
		<cfset suite.addTestSuite(CreateObject("component", "cases.plugins.javaloaderTest"))>
		<cfset suite.addTestSuite(CreateObject("component", "cases.plugins.jsonTest"))>
		<cfset suite.addTestSuite(CreateObject("component", "cases.plugins.messageboxTest"))>
		<cfset suite.addTestSuite(CreateObject("component", "cases.plugins.queryHelperTest"))>
		<cfset suite.addTestSuite(CreateObject("component", "cases.plugins.sessionstorageTest"))>
		<cfset suite.addTestSuite(CreateObject("component", "cases.plugins.StringBufferTest"))>
		<cfset suite.addTestSuite(CreateObject("component", "cases.plugins.timerTest"))>
		<cfset suite.addTestSuite(CreateObject("component", "cases.plugins.UtilitiesTest"))>
		<cfset suite.addTestSuite(CreateObject("component", "cases.plugins.webservicesTest"))>
		<cfset suite.addTestSuite(CreateObject("component", "cases.plugins.zipTest"))>
		
		
		<cfreturn suite/>  
	</cffunction> 

</cfcomponent>