	<%cffunction name="testdspHome" access="public" returntype="void" output="false"%>
		<%cfscript%>
		var event = "";
		
		//Place any variables on the form or URL scope to test the handler.
		//FORM.name = "luis"
		event = execute("general.dspHome");
			
		//Do your asserts below
		assertEqualsString("Welcome to ColdBox!", event.getValue("welcomeMessage",""), "Failed to assert welcome message");
			
		<%/cfscript%>
	<%/cffunction%>