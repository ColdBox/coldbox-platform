component {

	function configure(){

		// =====================================================================================
		// AI ROUTING
		// =====================================================================================

		if( server.keyExists( "boxlang" ) ){
			// Create a basic MCP Server
			MCPServer( "MyMCPServer" )
				.registerTool(
					aiTool( "echo", "Echoes the input message", ( message ) => {
					 	return {
							"echoedMessage": message
						}
					} )
				)

			var routerAiAgent = aiAgent(
				name: "ColdBox Test Agent",
				instructions: "You are a helpful assistant for testing AI routing in ColdBox."
			)

			// Define a basic MCP server route for testing
			route( "/mcp/test" ).toMCP( "MyMCPServer" )
			route( "/ai/test" ).toAi( routerAiAgent )
		}

		// =====================================================================================
		// NORMAL ROUTING
		// =====================================================================================

		route( "/bar" ).toModuleRouting( "resourcesTest" );

		// Nested Resources
		resources(
			resource = "agents",
			pattern  = "/sites/:id/agents"
		);

		// Redirects
		route( "/tempRoute" ).toRedirect( "/main/redirectTest", 302 );
		route( "/oldRoute" ).toRedirect( "/main/redirectTest" );
		route( "/old/api/users/:id" )
			.toRedirect( function( route, params ){
				return "/luis/";
			} );

		route( "/render/:format" ).meta( { secure : false } ).to( "actionRendering.index" );

		// With Regex
		route( "post/:postID-regex:([a-zA-Z]+?)/:userID-alpha/regex:(xml|json)" ).to(
			"ehGeneral.dumpRC"
		);

		// subdomain routing
		route( "/" )
			.withDomain( "subdomain-routing.dev" )
			.to( "subdomain.index" );
		route( "/" )
			.withDomain( ":username.forgebox.dev" )
			.to( "subdomain.show" );

		// Resources
		resources(
			resource: "photos",
			meta    : { secure : true }
		);

		// Responses + Conditions
		route( "/ff" )
			.withCondition( function(){
				return ( findNoCase( "Firefox", CGI.HTTP_USER_AGENT ) ? true : false );
			} )
			.toResponse( "Hello FireFox" );

		route( "/luis/:lname" ).toResponse(
			"<h1>Hi Luis {lname}, how are {you}</h1>",
			200,
			"What up dude!"
		);

		route( "/luis2/:lname" ).toResponse( function( event, rc, prc ){
			return "<h1>Hello from closure land: #arguments.rc.lname#</h1>";
		} );

		// Views No Events
		route(
			pattern = "contactus2",
			name    = "contactus2"
		).toView( view = "simpleView", noLayout = true );

		route( "contactus" ).as( "contactUs" ).toView( "simpleView" );

		// Add Module Routing Here For Common-View Layout Testing
		route( "/moduleLookup" ).toModuleRouting( "moduleLookup" );
		route( "/parentLookup" ).toModuleRouting( "parentLookup" );

		// More Routes
		route(
			pattern = "/complexParams/:id-numeric{2}/:name-regex(luis)",
			name    = "complexParams"
		).to( "main.main" );
		route(
			pattern = "/testroute/:id/:name",
			name    = "testRouteWithParams"
		).to( "main.main" );
		route(
			pattern = "/testroute",
			name    = "testRoute"
		).to( "main.main" );

		// Route-scoped middleware: BaseTestCase.execute() must run it just like the Bootstrap does
		route( "/routeMiddleware/blocked" )
			.middleware( function( event, rc, prc ){
				event
					.renderData(
						data       = "blocked by middleware",
						statusCode = 403
					)
					.noExecution()
				return true
			} )
			.to( "main.returnTest" )
		route( "/routeMiddleware/open" )
			.middleware( function( event, rc, prc ){
				prc.routeMiddlewarePre = true
			} )
			.middleware(
				function( event, rc, prc ){
					prc.routeMiddlewarePost = true
				},
				"postProcess"
			)
			.to( "main.returnTest" )

		// Named middleware: registered once, referenced by name, opted out of with withoutMiddleware()
		registerMiddleware( "namedBlocker", function( event, rc, prc ){
			event
				.renderData(
					data       = "blocked by named middleware",
					statusCode = 403
				)
				.noExecution()
			return true
		} )
		route( "/routeMiddleware/named/blocked" )
			.middleware( "namedBlocker" )
			.to( "main.returnTest" )
		group( { pattern : "/routeMiddleware/named/group", middleware : [ "namedBlocker" ] }, function(){
			route( "/blocked" ).to( "main.returnTest" )
			route( "/exempt" ).withoutMiddleware( "namedBlocker" ).to( "main.returnTest" )
		} )

		// Names routes
		route(
			pattern = "/routeRunner/:id/:name",
			name    = "routeRunner"
		).to( "main.returnTest" );

		// Should fire localized onInvalidHTTPMethod
		route( pattern = "invalid-restful" ).withAction( { post : "index" } ).toHandler( "restful" );

		route( pattern = "invalid-main-method" )
			.withAction( { post : "index" } )
			.toHandler( "main" );

		route( "invalid-main-verbs" ).withVerbs( "post" ).to( "main.index" );

		// Browser testing routes: tests/specs/browser
		route( "/users/:id" ).as( "users.show" ).to( "browserTesting.user" )
		route( "/browser-posts/:id?" ).as( "browserPosts" ).to( "browserTesting.user" )
		route( "/browser-testing/login" ).as( "browserTesting.login" ).to( "browserTesting.login" )
		route( "/browser-testing/whoami" ).as( "browserTesting.whoami" ).to( "browserTesting.whoami" )
		route( "/" ).withDomain( "browser-root.dev" ).as( "browserRoot" ).to( "main.index" )

		// Default Application Routing
		route( ":handler/:action?/:id-numeric?" ).end();


		// Some Legacy Namespace + With Closures

		// Register namespaces
		route( "/luis" ).toNamespaceRouting( "luis" );
		// addNamespace( pattern="/luis", namespace="luis");

		// Sample namespace
		group( { namespace : "luis" }, ( options ) => {
			route( pattern: "contactus" ).toView( view: "simpleview" );
			route( pattern: "contactus2" ).toView( view: "simpleview", noLayout: true );
		} );

		group(
			{ pattern : "/test2", handler : "ehGeneral", action : "dspHello" },
		 	( options ) =>{
			route( "/:id-numeric{2}/:num-numeric/:name/:month{3}?" );
			route( "/:id/:name{4}?" )
		} );

		// awn sync with contact manager
		group( { pattern : "/runAWNsync", handler : "utilities.AWNsync" }, function( options ){
			route( "/:user_id" )
				.withAction( { get : "runAWNsync", options : "returnOptions" } )
				.end();
		} );

		// health check route
		route( "/health_check" )
			.withAction( { get : "runCheck", options : "returnOptions" } )
			.to( "utilities.HealthCheck" );

	}

}
