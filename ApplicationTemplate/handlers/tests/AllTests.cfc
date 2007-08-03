<!-----------------------------------------------------------------------
Template : AllTests.cfc
Author 	 : luis5198
Date     : 6/6/2007 5:59:04 PM
Description :
	
	Test suite for all Handler Tests.

---------------------------------------------------------------------->
<cfcomponent displayname="AllTests" output="false" hint="Test suite for test cases.">  
	
	<cffunction name="suite" returntype="org.cfcunit.framework.Test" access="public" output="false">  
		<cfset var suite = CreateObject("component", "org.cfcunit.framework.TestSuite").init("Test Suite")>  
		
		<!--- Add the test cases --->
		<cfset suite.addTestSuite(CreateObject("component", "cases.generalTest"))>
		<cfset suite.addTestSuite(CreateObject("component", "cases.mainTest"))>
		
		<cfreturn suite/>  
	</cffunction> 

</cfcomponent>