<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
Description :
	Request service Test
----------------------------------------------------------------------->
<cfcomponent name="requestserviceTest" extends="coldbox.system.testing.BaseTestCase" output="false" appMapping="/coldbox/testharness">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		//Call the super setup method to setup the app.
		super.setup();
		</cfscript>
	</cffunction>
	
	<cffunction name="testFactoryCreations" access="public" returntype="void" output="false">
		<cfscript>
		var factory = CreateObject("component","coldbox.system.ioc.ColdboxFactory");
		var obj = "";
		
		//Create objects
		obj = factory.getConfigBean();
		AssertTrue( isObject(obj),"config bean");
		
		obj = factory.getColdbox();
		AssertEquals(getController(), obj, "Controller");
		
		obj = factory.getRequestContext();
		AssertEquals(getController().getREquestService().getContext(), obj, "Request Context");
		
		obj = factory.getRequestCollection();
		AssertEquals(getController().getREquestService().getContext().getCollection(), obj, "Request Collection");
		
		obj = factory.getColdboxOCM();
		AssertEquals(getController().getColdBoxOCM(), obj, "OCM");
		
		obj = factory.getPlugin("Logger");
		AssertEquals(getController().getPlugin("Logger"), obj, "Logger Plugin");
		
		obj = factory.getPlugin("date",true);
		AssertEquals(getController().getPlugin("date",true), obj, "Date Custom Plugin");
		
		obj = factory.getPlugin(plugin="ModPlugin",module="test1");
		AssertEquals(getController().getPlugin(plugin="ModPlugin",module="test1"), obj, "Module Plugin");
		
		AssertTrue( isObject(factory.getInterceptor("SES")), "Interceptor");
		
		obj = factory.getPlugin("date",true);
		AssertTrue(structKeyExists(obj,"getToday"), "Date Plugin");
		
		obj = factory.getDatasource("mysite");
		AssertTrue( isStruct(obj.getMemento()), "Datasource");
		
		obj = factory.getMailSettings();
		AssertTrue( isStruct(obj.getMemento()), "Mail Settings");
		
		obj = factory.getLogBox();
		assertEquals(obj, getController().getLogBox());
		
		obj = factory.getCacheBox();
		assertEquals(obj, getController().getCacheBox());
		
		obj = factory.getRootLogger();
		assertEquals(obj, getController().getLogBox().getRootLogger());
		
		obj = factory.getLogger('unittest');
		assertEquals(obj, getController().getLogBox().getLogger('unittest'));
		</cfscript>
	</cffunction>
	
	
</cfcomponent>