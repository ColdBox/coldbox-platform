<cfscript>
	setUniqueURLs( false );
	setBaseURL( "http://#cgi.http_host#/#getSetting('AppMapping')#/index.cfm" );

	// REST services via new action as JSON Struct
	/*

	addRoute( pattern="/rest",
		     handler="Rest",
		     action="{GET:'show', PUT:'update', DELETE:'delete', POST:'save'}");
	// REST services as Implicit structures
	addRoute( pattern="/api",
		     handler="Rest",
		     action={GET='show', PUT='update', DELETE='delete', POST='save'});

	*/

	addRoute( pattern="post/:postID-regex:([a-zA-Z]+?)/:userID-alpha/regex:(xml|json)", handler="ehGeneral", action="dumpRC" );

	function ff(){
		return ( findnocase( "Firefox", cgi.HTTP_USER_AGENT ) ? true : false );
	};

	function fResponse(rc){
		return "<h1>Hello from closure land: #arguments.rc.lname#</h1>";
	};

	// Responses
	addRoute( pattern="/ff", response="Hello FireFox", condition=ff);
	addRoute( pattern="/luis/:lname", response="<h1>Hi Luis {lname}, how are {you}</h1>", statusCode="200", statusText="What up dude!");
	addRoute( pattern="/luis2/:lname", response=fResponse, statusCode="202", statusText="What up from closure land");

	// Views No Events
	addRoute( pattern="contactus",view="simpleview");
	addRoute( pattern="contactus2",view="simpleview",viewnoLayout=true);

	// Add Module Routing Here For Common-View Layout Testing
	addModuleRoutes( pattern="/moduleLookup", module="moduleLookup");
	addModuleRoutes( pattern="/parentLookup", module="parentLookup");

	// Register namespaces
	addNamespace( pattern="/luis",namespace="luis");

	// Sample namespace
	with( namespace="luis" )
		.addRoute( pattern="contactus",view="simpleview")
		.addRoute( pattern="contactus2",view="simpleview",viewnoLayout=true)
	.endWith();

	// Test Simple With
	with( pattern="/test",handler="ehGeneral",action="dspHello" )
		.addRoute( pattern="/:id-numeric{2}/:num-numeric/:name/:month{3}?" )
		.addRoute( pattern="/:id/:name{4}?")
	.endWith();

	addRoute( pattern="/testroute", handler="main", action="index" );

	// Default Application Routing
	addRoute( pattern=":handler/:action?/:id-numeric?",matchVariables="isFound=true,testDate=#now()#");

</cfscript>
