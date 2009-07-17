	<%cffunction name="testdoDelete" access="public" returntype="void" output="false"%>
		<%cfscript%>
		//Get references
		var event = "";
		
		//Place any variables on the form or URL scope to test the handler.
		//FORM.name = "luis"
		form.#primaryKey# = '123';
		
		event = execute("#root.bean.xmlAttributes.name#.doDelete");
			
		//Do your asserts below
				
		<%/cfscript%>
	<%/cffunction%>