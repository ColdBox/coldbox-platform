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
<cfcomponent displayname="AllTests" output="false">  
	
	<cffunction name="suite" returntype="org.cfcunit.framework.Test" access="public" output="false">  
		<cfset var suite = CreateObject("component", "org.cfcunit.framework.TestSuite").init("ColdBox Test Suite")>  
		
		<!--- Add the test cases --->
		<cfset suite.addTestSuite(CreateObject("component", "cases.coldboxfactoryTest"))>
		<cfset suite.addTestSuite(CreateObject("component", "cases.coldboxproxytest"))>
		<cfset suite.addTestSuite(CreateObject("component", "cases.coldboxproxytest"))>
		<cfset suite.addTestSuite(CreateObject("component", "cases.requestcontextTest"))>
		<cfset suite.addTestSuite(CreateObject("component", "cases.util.utilTest"))>
		
		<!--- Test Suites --->
		<cfset suite.addTest(CreateObject("component", "AllServices").suite())>
		<cfreturn suite/>  
	</cffunction> 

</cfcomponent>