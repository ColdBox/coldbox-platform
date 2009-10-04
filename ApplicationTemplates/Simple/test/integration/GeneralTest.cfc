<!-----------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	September 25, 2005
Description :
	Unit Tests integration for the ehGeneral Handler.

----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">
	
	<cfscript>
		//Uncomment the following if you dont' need the controller in application scope for testing.
		//this.PERSIST_FRAMEWORK = false;
	</cfscript>
	
	<cffunction name="setUp" returntype="void" output="false">
		<cfscript>
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox/ApplicationTemplates/Simple");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
			
		//Call the super setup method to setup the app.
		super.setup();
		
		//EXECUTE THE APPLICATION START HANDLER: UNCOMMENT IF NEEDED AND FILL IT OUT.
		//getController().runEvent("main.onAppInit");

		//EXECUTE THE ON REQUEST START HANDLER: UNCOMMENT IF NEEDED AND FILL IT OUT
		//getController().runEvent("main.onRequestStart");
		</cfscript>
	</cffunction>
	
	<cffunction name="testindex" returntype="void" output="false">
		<cfscript>
		var event = "";
		
		//Place any variables on the form or URL scope to test the handler.
		//FORM.name = "luis"
		event = execute("general.index");
		
		debug(event.getCollection());
		
		//Do your asserts below
		assertEquals("Welcome to ColdBox!", event.getValue("welcomeMessage",""), "Failed to assert welcome message");
			
		</cfscript>
	</cffunction>
	
</cfcomponent>