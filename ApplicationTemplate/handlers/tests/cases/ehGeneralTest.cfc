<!-----------------------------------------------------------------------
Author 	 :	ehGeneralTest.cfc
Date     :	September 25, 2005
Description :
	Unit Tests integration for the ehGeneral Handler.

----------------------------------------------------------------------->
<cfcomponent name="ehGeneralTest" extends="baseTest" output="false">

	<cffunction name="testdspHello" access="public" returntype="void" output="false">
		<cfscript>
		var event = "";
		
		//Place any variables on the form or URL scope to test the handler.
		//FORM.name = "luis"
		event = execute("ehGeneral.dspHello");
			
		//Do your asserts below
		assertEqualsString("Welcome to ColdBox!", event.getValue("welcomeMessage",""), "Failed to assert welcome message");
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testdoSomething" access="public" returntype="void" output="false">
		<cfscript>
		var event = "";
		
		//Place any variables on the form or URL scope to test the handler.
		//FORM.name = "luis"
		event = execute("ehGeneral.doSomething");
			
		//Do your asserts below for setnextevent you can test for a setnextevent boolean flag
		assertEqualsBoolean(true, event.getValue("setnextevent","false"), "Set Next Event flag not test by test controller");
			
		</cfscript>
	</cffunction>
	
</cfcomponent>