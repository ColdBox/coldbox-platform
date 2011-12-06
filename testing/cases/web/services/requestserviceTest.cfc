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
<cfcomponent name="requestserviceTest" extends="coldbox.system.testing.BaseTestCase" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox/testharness");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
		//Call the super setup method to setup the app.
		super.setup();
		</cfscript>
	</cffunction>
	
	<cffunction name="testRequestCapturesWithNoDecoration" access="public" returntype="void" output="false">
		<cfscript>
			var originalSetting = getcontroller().getSetting("RequestContextDecorator");
			
			getcontroller().setSetting("RequestContextDecorator","");
			testRequestCaptures();
			getcontroller().setSetting("RequestContextDecorator",originalSetting);
				
		</cfscript>
	</cffunction>
	
	<cffunction name="testRequestCaptures" access="public" returntype="void" output="false">
		<cfscript>
		var service = getController().getRequestService();
		var context = "";
		var persistStruct = structnew();
		var today = now();
		var SessionStorage = getController().getPlugin("SessionStorage");
		
		/* Fill up the flash storage */
		SessionStorage.setVar('_coldbox_persistStruct', structnew());
		persistStruct = SessionStorage.getVar('_coldbox_persistStruct');
		persistStruct.flashvariable = today;
		
		/* Setup test variables */
		form.name = 'luis majano';
		form.event = "ehGeneral.dspHome,movies.list";
		
		url.name = "pio majano";
		url.today = today;
		
		/* Catpure the request */
		context = service.requestCapture();
		
		debug(context.getCollection());
		
		/* Tests */
		AssertTrue( isObject(context), "Context Creation");
		AssertTrue(url.today eq context.getValue('today') , "URL Append");
		AssertTrue(context.valueExists('event'), "Multi-Event Test");
		</cfscript>
	</cffunction>
	
	<cffunction name="testDebugModesRequestCaptures" access="public" returntype="void" output="false">
		<cfscript>
		var service = getController().getRequestService();
		var context = "";
		
		/* Setup test variables */
		url.debugmode = true;
		url.debugpass = "invalid";
		
		/* Catpure the request */
		context = service.requestCapture();
		
		/* Set debugmode to false to tests */
		getcontroller().getDebuggerService().setDebugMode(false);
		
		/* Tests */
		AssertFalse(getcontroller().getDebuggerService().getDebugMode(), "Debug Mode test invalid password");
		
		/* Now test with right password. */
		structClear(url);
		structClear(request);
		url.debugmode = true;
		url.debugpass = "coldbox";
		getController().setSetting('debugPassword',"coldbox");
		
		/* Catpure the request */
		context = service.requestCapture();
		
		/* Tests */
		AssertTrue(getcontroller().getDebuggerService().getDebugMode(), "Debug Mode test good password: #getcontroller().getDebuggerService().getDebugMode()#");
		</cfscript>
	</cffunction>
	
	<cffunction name="testDefaultEvent" access="public" returntype="void" output="false">
		<cfscript>
		var service = getController().getRequestService();
		var context = "";
		
		/* Setup test variables */
		url.event = "default";
		
		/* Catpure the request */
		context = service.requestCapture();
		
		/* Tests */
		AssertTrue( isObject(context), "Context Creation");
		AssertTrue( url.event neq context.getCurrentEvent(), "Event mismatch");
		AssertEquals( context.getCurrentEvent(), url.event & "." & getController().getSetting("EventAction",1) );
		</cfscript>
	</cffunction>
	
	<cffunction name="testContextGetterSetters" access="public" returntype="Void" output="false" >
		<cfscript>
		var service = getController().getRequestService();
		var context = "";
		
		context = service.getContext();	
		AssertTrue( isObject(context), "Context Create");
		
		structDelete(request, "cb_requestContext");
		assertFalse( service.contextExists() , "Context exists");
		
		service.setContext(context);
		assertTrue( structKeyExists(request,"cb_requestContext") ,"setter in request");
				
		</cfscript>
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="Void" hint="teardown" output="false" >
		<cfscript>
		structClear(cookie);
		</cfscript>
	</cffunction>
		
	
</cfcomponent>