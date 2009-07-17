<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
Description :
	Request service Test
----------------------------------------------------------------------->
<cfcomponent name="requestserviceTest" extends="coldbox.system.extras.testing.baseMXUnitTest" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox/testharness");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
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
		results = proxy.announceInterception(state='onLog',interceptData='');
		AssertTrue(results,"onLog intercepted");
		
		</cfscript>
	</cffunction>
	
	<cffunction name="testProxyPrivateMethods" access="public" returntype="void" output="false">
		<cfscript>
		var proxy = CreateObject("component","coldbox.testharness.coldboxproxy");
		var local = structnew();
		
		/* Get Method Injector */
		getController().getPlugin("methodInjector").start(proxy);
		/* Verify Test */
		proxy.invokerMixin("verifyColdBox");
		/* GetPlugin */
		local.plugin = proxy.invokerMixin(method='getPlugin',argList="plugin=logger");
		AssertTrue( isObject(local.plugin) );
		
		/* Get IOCFactory */
		local.obj = proxy.invokerMixin(method='getIoCFactory');
		AssertTrue( isObject(local.obj) );
		
		/* Get Bean */
		local.obj = proxy.invokerMixin(method='getBean',argList="beanName=testModel");
		AssertTrue( isObject(local.obj) );
		
		/* Get ColdBoxOCM */
		local.obj = proxy.invokerMixin(method='getColdBoxOCM');
		AssertTrue( isObject(local.obj) );
		
		/* Get Model Object */
		local.obj = proxy.invokerMixin(method="getModel",argList="name=testModel");
		AssertTrue( isObject(local.obj) );
		
		/* Stop Injection */
		getController().getPlugin("methodInjector").stop(proxy);
		</cfscript>
	</cffunction>
	
	<cffunction name="testProxyApplicationLoading" access="public" returntype="void" output="false">
		<cfscript>
		var proxy = CreateObject("component","coldbox.testharness.coldboxproxy");
		var local = structnew();
		
		/* Get Method Injector */
		getController().getPlugin("methodInjector").start(proxy);
		
		/* Load ColdBox */
		local.load = structnew();
		local.load.appRootPath = ExpandPath("/coldbox/testharness");
		local.load.configLocation = local.load.appRootPath & "/config/coldbox.xml.cfm";
		local.load.reloadApp = true;
		proxy.invokerMixin(method='loadColdbox',argCollection=local.load);
		
		local.load = structnew();
		local.load.appRootPath = ExpandPath("/coldbox/testharness");
		local.load.reloadApp = true;
		
		proxy.invokerMixin(method='loadColdbox',argCollection=local.load);
		
		
		/* Stop Injection */
		getController().getPlugin("methodInjector").stop(proxy);
		</cfscript>
	</cffunction>
	
</cfcomponent>