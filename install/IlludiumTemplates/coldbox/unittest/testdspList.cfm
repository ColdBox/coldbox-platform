	<%cffunction name="testdspList" access="public" returntype="void" output="false"%>
		<%cfscript%>
		//Get references
		var event = "";
		
		//Place any variables on the form or URL scope to test the handler.
		//FORM.name = "luis"
		event = execute("#root.bean.xmlAttributes.name#.dspList");
			
		//Do your asserts below
				
		<%/cfscript%>
	<%/cffunction%>