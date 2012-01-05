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
	
	<cffunction name="testNoEvent" access="public" returntype="void" output="false">
		<cfscript>
		var proxy = CreateObject("component","coldbox.testharness.coldboxproxy");
		var results = "";
		
		//Test With default ProxyReturnCollection = false
		try{
			results = proxy.process();
			Fail("Proxy did not throw");
		}
		catch(Any e){
			AssertTrue(true);
		}
		</cfscript>
	</cffunction>
	
	<cffunction name="testProxyNoCollection" access="public" returntype="void" output="false">
		<cfscript>
		var proxy = CreateObject("component","coldbox.testharness.coldboxproxy");
		var results = "";
		
		//Test With default ProxyReturnCollection = false
		results = proxy.process(event='ehProxy.getIntroArrays');
		AssertTrue( isArray(results), "Getting Array");
		
		//test other process
		results = proxy.process(event='ehProxy.getIntroStructure');
		AssertTrue( isStruct(results), "Getting Structure");
		
		</cfscript>
	</cffunction>

	<cffunction name="testProxyWithCollection" access="public" returntype="void" output="false">
		<cfscript>
		var proxy = CreateObject("component","coldbox.testharness.coldboxproxy");
		var results = "";
		
		//Set return setting
		application.cbController.setSetting("ProxyReturnCollection",true);
		
		//Test With default ProxyReturnCollection = false
		results = proxy.process(event='ehProxy.getIntroArraysCollection');
		AssertTrue( isStruct(results), "Collection Test");
		AssertTrue( isArray(results.myArray), "Getting Array From Collection");
		
		application.cbController.setSetting("ProxyReturnCollection",false);
		</cfscript>
	</cffunction>
	
	<cffunction name="testProxyInterceptions" access="public" returntype="void" output="false">
		<cfscript>
		var proxy = CreateObject("component","coldbox.testharness.coldboxproxy");
		var results = "";
		
		//Announce interception
		makePublic(proxy,"announceInterception");
		results = proxy.announceInterception(state='onLog');
		AssertTrue(results,"onLog intercepted");
		
		</cfscript>
	</cffunction>
	
	<cffunction name="testProxyPrivateMethods" access="public" returntype="void" output="false">
		<cfscript>
		var proxy = CreateObject("component","coldbox.testharness.coldboxproxy");
		var local = structnew();
		
		/* GetPlugin */
		makePublic(proxy, "getPlugin");
		local.plugin = proxy.getPlugin("Logger");
		local.plugin = proxy.getPlugin("date",true);
		local.plugin = proxy.getPlugin(plugin="ModPlugin",module="test1");
		
		
		/* Get IOCFactory */
		makePublic(proxy, "getIoCFactory");
		local.obj = proxy.getIoCFactory();
		
		/* Get Bean */
		makePublic(proxy, "getBean");
		local.obj = proxy.getBean(beanName="testModel");
		
		/* Get ColdBoxOCM */
		makePublic(proxy, "getColdBoxOCM");
		local.obj = proxy.getColdBoxOCM();
		
		/* Get Model Object */
		makePublic(proxy, "getModel");
		local.obj = proxy.getModel(name="testModel");
		
		makePublic(proxy,"getLogBox");
		makePublic(proxy,"getRootLogger");
		makePublic(proxy,"getLogger");
		
		assertEquals(getController().getLogBox(), proxy.getLogBox());
		assertEquals(getController().getLogBox().getRootLogger(), proxy.getRootLogger());
		assertEquals(getController().getLogBox().getLogger('unittest'), proxy.getLogger('unittest'));
	
		</cfscript>
	</cffunction>
	
	<cffunction name="testProxyApplicationLoading" access="public" returntype="void" output="false">
		<cfscript>
		var proxy = CreateObject("component","coldbox.testharness.coldboxproxy");
		var local = structnew();
		
		createObject("component","coldbox.system.core.dynamic.MixerUtil").init().start(proxy);
		
		local.load = structnew();
		local.load.appMapping = "/coldbox/testharness";
		local.load.configLocation = expandPath(local.load.appMapping) & "/config/Coldbox.cfc";
		local.load.reloadApp = true;
		proxy.invokerMixin(method='loadColdbox',argCollection=local.load);
		
		local.load = structnew();
		local.load.appMapping = "/coldbox/testharness";
		local.load.reloadApp = true;
		
		proxy.invokerMixin(method='loadColdbox',argCollection=local.load);
		
		
		</cfscript>
	</cffunction>
	
</cfcomponent>