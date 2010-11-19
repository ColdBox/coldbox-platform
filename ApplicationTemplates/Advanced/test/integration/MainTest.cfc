<!-----------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	September 25, 2005
Description :

	Unit test for the ehMain Handler.

----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseTestCase" appMapping="/coldbox/ApplicationTemplates/Advanced">
	
	<cffunction name="setUp" returntype="void" output="false">
		<cfscript>
		// Call the super setup method to setup the app.
		super.setup();
		
		// Any preparation work will go here for this test.
		</cfscript>
	</cffunction>
	
	<cffunction name="testonAppInit" returntype="void" output="false">
		<cfscript>
		var event = "";
		
		//Place any variables on the form or URL scope to test the handler.
		//URL.name = "luis"
		event = execute("main.onAppInit");
			
		//Do your asserts below
				
		</cfscript>
	</cffunction>

	<cffunction name="testonRequestStart" returntype="void" output="false">
		<cfscript>
		var event = "";
		
		//Place any variables on the form or URL scope to test the handler.
		//URL.name = "luis"
		event = execute("main.onRequestStart");
			
		//Do your asserts below
				
		</cfscript>
	</cffunction>

	<cffunction name="testonRequestEnd" returntype="void" output="false">
		<cfscript>
		var event = "";
		
		//Place any variables on the form or URL scope to test the handler.
		//URL.name = "luis"
		event = execute("main.onRequestEnd");
			
		//Do your asserts below
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testSessionStart" returntype="void" output="false">
		<cfscript>
		var event = "";
		
		//Place any variables on the form or URL scope to test the handler.
		//URL.name = "luis"
		event = execute("main.onSessionStart");
			
		//Do your asserts below
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testSessionEnd" returntype="void" output="false">
		<cfscript>
		var event = "";
		var sessionReference = "";
		
		//Place a fake session structure here, it mimics what the handler receives
		URL.sessionReference = structnew();
		URL.applicationReference = structnew();
		
		event = execute("main.onSessionEnd");
			
		//Do your asserts below
			
		</cfscript>
	</cffunction>

	<cffunction name="testonException" returntype="void" output="false">
		<cfscript>
		//You need to create an exception bean first and place it on the request context FIRST as a setup.
		var exceptionBean = CreateObject("component","coldbox.system.web.context.ExceptionBean");
		var event = "";
		
		//Initialize an exception
		exceptionBean.init(erroStruct=structnew(), extramessage="My unit test exception", extraInfo="Any extra info, simple or complex");
		//Place it on form or url scope to attach it to request
		URL.exceptionBean = exceptionBean;
		
		//TEST EVENT EXECUTION
		event = execute("main.onException");
		
		//Do your asserts HERE

		</cfscript>
	</cffunction>


</cfcomponent>