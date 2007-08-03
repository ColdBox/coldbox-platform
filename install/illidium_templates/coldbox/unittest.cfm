<cfoutput>
<%cfcomponent name="#root.bean.xmlAttributes.name#Test" extends="coldbox.system.extras.baseTest" output="false"%>

	<%cffunction name="setUp" returntype="void" access="private" output="false" %>
		<%cfscript%>
		//Setup ColdBox Mappings For this Test
		setAppMapping("PLACE PATH HERE");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/config.xml.cfm"));
		
		//Call the super setup method to setup the app.
		super.setup();
		
		//EXECUTE THE APPLICATION START HANDLER: UNCOMMENT IF NEEDED AND FILL IT OUT.
		//getController().runEvent("main.onAppInit");

		//EXECUTE THE ON REQUEST START HANDLER: UNCOMMENT IF NEEDED AND FILL IT OUT
		//getController().runEvent("main.onRequestStart");
		<%/cfscript%>
	<%/cffunction%>
	
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
	
	<%cffunction name="testdspEditor" access="public" returntype="void" output="false"%>
		<%cfscript%>
		//Get references
		var event = "";
		
		//Place any variables on the form or URL scope to test the handler.
		//FORM.name = "luis"
		event = execute("#root.bean.xmlAttributes.name#.dspEditor");
			
		//Do your asserts below
				
		<%/cfscript%>
	<%/cffunction%>
	
	<%cffunction name="testdoSave" access="public" returntype="void" output="false"%>
		<%cfscript%>
		//Get references
		var event = "";
		
		//Place any variables on the form or URL scope to test the handler.
		//FORM.name = "luis"
		<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i">
		<cfset element = root.bean.dbtable.xmlChildren[i].xmlAttributes>
		<cfif primaryKey neq element.name>
		<cfif element.type eq "numeric">
		form.#element.name# = '';
		<cfelseif element.type eq "Boolean">
		form.#element.name# = true;
		<cfelseif element.type eq "Date">
		form.#element.name# = dateformat(now(),"medium");
		<cfelse>
		form.#element.name# = 'UNIT TEST';
		</cfif>
		</cfif>
		</cfloop>
		
		event = execute("#root.bean.xmlAttributes.name#.doSave");
			
		//Do your asserts below
				
		<%/cfscript%>
	<%/cffunction%>
	
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
			
<%/cfcomponent%>
</cfoutput>