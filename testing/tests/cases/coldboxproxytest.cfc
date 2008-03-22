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
<cfcomponent name="requestserviceTest" extends="coldbox.system.extras.baseTest" output="false">

	<cffunction name="setUp" returntype="void" access="private" output="false">
		<cfscript>
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
		//Call the super setup method to setup the app.
		super.setup();
		//place controller in app scope for this.
		application.cbController = getController();
		</cfscript>
	</cffunction>
	
	<cffunction name="testNoEvent" access="public" returntype="void" output="false">
		<cfscript>
		var proxy = CreateObject("component","coldbox.coldboxproxy");
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
		var proxy = CreateObject("component","coldbox.coldboxproxy");
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
		var proxy = CreateObject("component","coldbox.coldboxproxy");
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
		var proxy = CreateObject("component","coldbox.coldboxproxy");
		var results = "";
		
		//Announce interception
		results = proxy.announceInterception(state='onLog',interceptData='');
		AssertTrue(results,"onLog intercepted");
		
		</cfscript>
	</cffunction>
	
	<cffunction name="testProxyPrivateMethods" access="public" returntype="void" output="false">
		<cfscript>
		var proxy = CreateObject("component","coldbox.coldboxproxy");
		var results = "";
		
		/* Get Method Injector */
		getController().getPlugin("methodInjector").start(proxy);
		
		/* Verify Test */
		
		/* GetPlugin */
		
		/* Get IOCFactory */
		
		/* Get Bean */
		
		/* Get ColdBoxOCM */
		
		/* Load ColdBox */
		
		/* Stop Injection */
		getController().getPlugin("methodInjector").stop(proxy);
		</cfscript>
	</cffunction>
	
	<!--- tearDown --->
	<cffunction name="tearDown" output="false" access="public" returntype="void" hint="">
		<cfscript>
		structDelete(application,"cbController");
		</cfscript>
	</cffunction>
	
</cfcomponent>