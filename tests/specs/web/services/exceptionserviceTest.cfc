﻿<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	September 3, 2007
Description :
	debugger service tests

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="exceptionserviceTest" extends="coldbox.system.testing.BaseTestCase" output="false" appMapping="/cbtestharness">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		super.setup();
		</cfscript>
	</cffunction>

	<cffunction name="testExceptionhandler" access="public" returntype="void" output="false">
		<cfscript>
			var service = getController().getExceptionService();
			var exceptionBean = "";

			AssertTrue( isObject(service),"component test");

			exceptionBean = service.ExceptionHandler(structnew(),"application","Unit Testing");
			AssertTrue( isObject(exceptionBean),"exception handling test1");

			exceptionBean = service.ExceptionHandler(structnew(),"framework","Unit Testing");
			AssertTrue( isObject(exceptionBean),"exception handling test2");

			exceptionBean = service.ExceptionHandler(structnew(),"coldboxproxy","Unit Testing");
			AssertTrue( isObject(exceptionBean),"exception handling test3");

		</cfscript>
	</cffunction>

	<cffunction name="testrenderBugReport" access="public" returntype="void" output="false">
		<cfscript>
			var service = getController().getExceptionService();
			var exceptionBean = "";
			var log = "";

			AssertTrue( isObject(service),"component test");

			exceptionBean = service.ExceptionHandler(structnew(),"application","Unit Testing");
			AssertTrue( isObject(exceptionBean),"exception handling test1");

			log = service.renderBugReport(exceptionBean);

			assertTrue( isSimpleValue(log), "Rendering exception");
		</cfscript>
	</cffunction>


</cfcomponent>