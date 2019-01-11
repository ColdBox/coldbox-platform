component{

	function configure(){
		setUniqueURLs( false );
		//setFullRewrites( false );

		// Redirects
		route( "/tempRoute" )
			.toRedirect( "/main/redirectTest", 302 );
		route( "/oldRoute" )
			.toRedirect( "/main/redirectTest" );

		route( "/render/:format" ).to( "actionRendering.index" );

		// With Regex
		route( "post/:postID-regex:([a-zA-Z]+?)/:userID-alpha/regex:(xml|json)" )
			.to( "ehGeneral.dumpRC" );

		// subdomain routing
		route( "/" )
			.withDomain( "subdomain-routing.dev" )
			.to( "subdomain.index" );
		route( "/" )
			.withDomain( ":username.forgebox.dev" )
			.to( "subdomain.show" );

		// Resources
		resources( "photos" );

		// Responses + Conditions
		route( "/ff" )
			.withCondition( function(){
				return ( findnocase( "Firefox", cgi.HTTP_USER_AGENT ) ? true : false );
			} )
			.toResponse( "Hello FireFox" );

		route( "/luis/:lname" )
			.toResponse( "<h1>Hi Luis {lname}, how are {you}</h1>", 200, "What up dude!" );

		route( "/luis2/:lname" )
			.toResponse( function( event, rc, prc ){
				return "<h1>Hello from closure land: #arguments.rc.lname#</h1>";
			} );

		// Views No Events
		route( pattern="contactus2", name="contactus2" )
			.toView( view="simpleView", noLayout=true );

		route( "contactus" )
			.as( "contactUs")
			.toView( "simpleView" );

		// Add Module Routing Here For Common-View Layout Testing
		route( "/moduleLookup" )
			.toModuleRouting( "moduleLookup" );
		route( "/parentLookup" )
			.toModuleRouting( "parentLookup" );

		// More Routes
		route( pattern="/complexParams/:id-numeric{2}/:name-regex(luis)", name="complexParams" )
			.to( "main.index" );
		route( pattern="/testroute/:id/:name", name="testRouteWithParams" )
			.to( "main.index" );
		route( pattern="/testroute", name="testRoute" )
			.to( "main.index" );

		// Should fire localized onInvalidHTTPMethod
		route( pattern="invalid-restful" )
			.withAction( { post = "index" } )
			.toHandler( "restful" );

		route( pattern="invalid-main-method" )
			.withAction( { post = "index" } )
			.toHandler( "main" );

		route( "invalid-main-verbs" )
			.withVerbs( "post" )
			.to( "main.index" );

		// Default Application Routing
		route( ":handler/:action?/:id-numeric?" )
			.end();


		// Some Legacy Namespace + With Closures

		// Register namespaces
		route( "/luis" )
			.toNamespaceRouting( "luis" );
		//addNamespace( pattern="/luis", namespace="luis");

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

		// awn sync with contact manager
		group( { pattern="/runAWNsync", handler="utilities.AWNsync" }, function( options ){
			route( '/:user_id' ).withAction( { get = "runAWNsync", options = "returnOptions" } ).end();
        } );

		// health check route
		route( "/health_check" )
			.withAction( { get = "runCheck", options = "returnOptions" } )
			.to( "utilities.HealthCheck" );

	}

}