<cfscript>
	setUniqueURLs(false);
	setBaseURL("http://#cgi.http_host#/#getSetting('AppMapping')#/index.cfm");
	
	// REST services via new action as JSON Struct
	/*
	
	addRoute(pattern="/rest",
		     handler="Rest",
		     action="{GET:'show', PUT:'update', DELETE:'delete', POST:'save'}");
	// REST services as Implicit structures
	addRoute(pattern="/api",
		     handler="Rest",
		     action={GET='show', PUT='update', DELETE='delete', POST='save'});
	
	*/
	
	addModuleRoutes(pattern="/space/:spaceUrl/luis",module="test1");
	
	//addModuleRoutes(pattern="/test1",module="test1");
	//addModuleRoutes(pattern="/modTest1",module="test1");
	addModuleRoutes(pattern="/forgebox",module="forgebox");
	
	// Add Module Routing Here For Common-View Layout Testing
	addModuleRoutes(pattern="/moduleLookup",module="moduleLookup");
	addModuleRoutes(pattern="/parentLookup",module="parentLookup");
	
	
	addRoute(pattern="/test/:id-numeric{2}/:num-numeric/:name/:month{3}?",handler="ehGeneral",action="dspHello");
	addRoute(pattern="test/:id/:name{4}?",handler="ehGeneral",action="dspHello");
	
	// Views No Events
	addRoute(pattern="contactus",view="simpleView");
	addRoute(pattern="contactus2",view="simpleView",viewnoLayout=true);
	
	// Constraints Implicitly
	//addRoute(pattern="/const/:test",view="simpleView",constraints={test='(ATest)'});
	
	// Default Application Routing
	addRoute(pattern=":handler/:action?/:id-numeric?",matchVariables="isFound=true,testDate=#now()#");
	
</cfscript>
