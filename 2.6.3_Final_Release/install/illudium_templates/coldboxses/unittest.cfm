<cfoutput>
<%cfcomponent name="#root.bean.xmlAttributes.name#Test" extends="coldbox.system.extras.testing.baseTest" output="false"%>

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
	
	<!-- custom code -->
	
<%/cfcomponent%>
</cfoutput>