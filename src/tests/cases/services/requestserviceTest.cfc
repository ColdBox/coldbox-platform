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
		</cfscript>
	</cffunction>
	
	<cffunction name="testRequestCapturesWithNoDecoration" access="public" returntype="void" output="false">
		<cfscript>
			var originalSetting = getcontroller().getSetting("RequestContextDecorator");
			
			getcontroller().setSetting("RequestContextDecorator","");
			testRequestCapturesWithDecoration();
			getcontroller().setSetting("RequestContextDecorator",originalSetting);			
		</cfscript>
	</cffunction>
	
	<cffunction name="testRequestCapturesWithDecoration" access="public" returntype="void" output="false">
		<cfscript>
		var service = getController().getRequestService();
		var context = "";
		var _coldbox_persistStruct = structnew();
		var today = now();
		
		/* Fill up the falsh storage */
		_coldbox_persistStruct.flashvariable = today;
		/* Store it in session */
		session._coldbox_persistStruct = _coldbox_persistStruct;
		
		/* Setup test variables */
		form.name = 'luis majano';
		url.name = "pio majano";
		form.event = "ehGeneral.dspHome,movies.list";
		url.today = today;
		
		/* Catpure the request */
		context = service.requestCapture();
		
		/* Tests */
		AssertComponent(context, "Context Creation");
		AssertTrue(today eq context.getValue('flashvariable') , "Flash variable creation");
		AssertTrue(url.today eq context.getValue('today') , "URL Append");
		AssertTrue(form.name eq context.getValue('name'), "Name test and precedence");
		AssertTrue(context.valueExists('event'), "Multi-Event Test");
		</cfscript>
	</cffunction>
	
	<cffunction name="testDebugModesRequestCaptures" access="public" returntype="void" output="false">
		<cfscript>
		var service = getController().getRequestService();
		var context = "";
		
		/* Set debugmode to false to tests */
		getcontroller().getDebuggerService().setDebugMode(false);
		
		/* Setup test variables */
		form.debugmode = true;
		form.debugpass = "invalid";
		
		/* Catpure the request */
		context = service.requestCapture();
		
		/* Tests */
		AssertFalse(getcontroller().getDebuggerService().getDebugMode(), "Debug Mode test invalid password");
		
		/* Now test with right password. */
		form.debugmode = true;
		form.debugpass = "coldbox";
		
		/* Catpure the request */
		context = service.requestCapture();
		
		/* Tests */
		AssertTrue(getcontroller().getDebuggerService().getDebugMode(), "Debug Mode test good password");
		</cfscript>
	</cffunction>
	
	<cffunction name="testContextGetterSetters" access="public" returntype="Void" output="false" >
		<cfscript>
		var service = getController().getRequestService();
		var context = "";
		
		context = service.getContext();	
		assertComponent(context, "Context Create");
		
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