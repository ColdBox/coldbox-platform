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
	// Views No Events
	addRoute(pattern="contactus",view="simpleView");
	addRoute(pattern="contactus2",view="simpleView",viewnoLayout=true);
	
	addModuleRoutes(pattern="/space/:spaceUrl/luis",module="test1");
	
	//addModuleRoutes(pattern="/test1",module="test1");
	//addModuleRoutes(pattern="/modTest1",module="test1");
	//addModuleRoutes(pattern="/theforge",module="forgebox");
	//addModuleRoutes(pattern="/forgebox",module="forgebox");
	
	// Add Module Routing Here For Common-View Layout Testing
	addModuleRoutes(pattern="/moduleLookup",module="moduleLookup");
	addModuleRoutes(pattern="/parentLookup",module="parentLookup");
	
	// Register namespaces
	addNamespace(pattern="/luis",namespace="luis");
	
	// Sample namespace
	with(namespace="luis")
		.addRoute(pattern="contactus",view="simpleView")
		.addRoute(pattern="contactus2",view="simpleView",viewnoLayout=true)
	.endWith();
	
	// Test Simple With
	with(pattern="/test",handler="ehGeneral",action="dspHello")
		.addRoute(pattern="/:id-numeric{2}/:num-numeric/:name/:month{3}?")
		.addRoute(pattern="/:id/:name{4}?")
	.endWith();
	
	// Constraints Implicitly
	//addRoute(pattern="/const/:test",view="simpleView",constraints={test='(ATest)'});
	
	// Default Application Routing
	addRoute(pattern=":handler/:action?/:id-numeric?",matchVariables="isFound=true,testDate=#now()#");
	
</cfscript>
