/**
 * AI & MCP Routing Tests — covers toAi() and toMCP() terminators
 */
component extends="coldbox.system.testing.BaseModelTest" skip="notBoxlang" {

	boolean function notBoxlang(){
		return !isBoxLang()
	}

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll()
		// Controller mock with bxai module registered so ensureBoxLang() passes
		variables.controller = createMock( "coldbox.system.web.Controller" )
			.init( expandPath( "/coldbox/test-harness" ), "cbController" )
			.setSetting( "AppMapping", "" )
			.setSetting( "RoutingAppMapping", "/" )
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		if ( notBoxlang() ) {
			return;
		}

		describe( "AI Routing — toAi()", function(){
			beforeEach( function(){
				variables.router = createMock( "coldbox.system.web.routing.Router" )
					.init()
					.setController( controller )
					.setLogBox( controller.getLogBox() )
					.setLog( controller.getLogBox().getLogger( this ) )
					.setCacheBox( controller.getCacheBox() )
					.setWireBox( controller.getWireBox() )
			} )

			story( "I want to register an AI runnable behind a base route pattern", function(){
				given( "a WireBox ID string as runnable", function(){
					then( "it should register 5 standardized sub-routes", function(){
						router.route( "/api/chat" ).toAi( "MockRunnable" )

						var routes   = router.getRoutes()
						var patterns = routes.map( ( r ) => r.pattern )

						expect( patterns ).toInclude( "api/chat/invoke/" )
						expect( patterns ).toInclude( "api/chat/stream/" )
						expect( patterns ).toInclude( "api/chat/batch/" )
						expect( patterns ).toInclude( "api/chat/info/" )
					} )
				} )

				given( "a WireBox ID string as runnable", function(){
					then( "all sub-routes should carry ai=true and the aiRunnable reference", function(){
						router.route( "/api/chat" ).toAi( "MockRunnable" )
						var routes = router.getRoutes()

						routes.each( ( r ) => {
							expect( r.ai ).toBeTrue()
							expect( r.aiRunnable ).toBe( "MockRunnable" )
						} )
					} )
				} )

				given( "a base route with withSSL() set", function(){
					then( "all sub-routes should inherit ssl=true", function(){
						router
							.route( "/api/chat" )
							.withSSL()
							.toAi( "MockRunnable" )
						var routes = router.getRoutes()

						expect( routes ).toHaveLength( 4 )
						routes.each( ( r ) => {
							expect( r.ssl ).toBeTrue()
						} )
					} )
				} )

				given( "a registered AI route family", function(){
					then( "POST sub-routes should be invoke/stream/batch and GET sub-routes should be info", function(){
						router.route( "/api/chat" ).toAi( "MockRunnable" )
						var routes     = router.getRoutes()
						var postRoutes = routes.filter( ( r ) => r.verbs == "POST" )
						var getRoutes  = routes.filter( ( r ) => r.verbs == "GET" )

						expect( postRoutes ).toHaveLength( 3 )
						expect( getRoutes ).toHaveLength( 1 )
					} )
				} )

				given( "a named base route", function(){
					then( "sub-routes should inherit the base name as a prefix", function(){
						router.route( pattern = "/api/chat", name = "chat" ).toAi( "MockRunnable" )
						var routes = router.getRoutes()
						var names  = routes.map( ( r ) => r.name )

						expect( names ).toInclude( "chat.invoke" )
						expect( names ).toInclude( "chat.stream" )
						expect( names ).toInclude( "chat.batch" )
						expect( names ).toInclude( "chat.info" )
					} )
				} )
			} )

			story( "I want conversational context resolution on toAi() sub-routes", function(){
				beforeEach( function(){
					makePublic( router, "resolveAiContext" )
				} )

				given( "no userId in the request body", function(){
					then( "it defaults to the controller's session identifier", function(){
						controller.$( "getUserSessionIdentifier" ).$results( "mock-session-id" )
						var ctx = router.resolveAiContext( {} )
						expect( ctx.userId ).toBe( "mock-session-id" )
					} )
				} )

				given( "a userId in the request body", function(){
					then( "it is passed through untouched", function(){
						var ctx = router.resolveAiContext( { "userId" : "explicit-user" } )
						expect( ctx.userId ).toBe( "explicit-user" )
					} )
				} )

				given( "no conversationId in the request body", function(){
					then( "the result carries no conversationId key at all", function(){
						var ctx = router.resolveAiContext( {} )
						expect( ctx ).notToHaveKey( "conversationId" )
					} )
				} )

				given( "a conversationId in the request body", function(){
					then( "it is passed through untouched", function(){
						var ctx = router.resolveAiContext( { "conversationId" : "conv-42" } )
						expect( ctx.conversationId ).toBe( "conv-42" )
					} )
				} )

				given( "no threadId in the request body", function(){
					then( "a new one is generated and always present in the result", function(){
						var ctx = router.resolveAiContext( {} )
						expect( ctx.threadId ).toBeString()
						expect( ctx.threadId ).notToBeEmpty()
					} )

					then( "two separate calls generate two different thread ids", function(){
						var first  = router.resolveAiContext( {} )
						var second = router.resolveAiContext( {} )
						expect( first.threadId ).notToBe( second.threadId )
					} )
				} )

				given( "a threadId in the request body", function(){
					then( "it is passed through untouched, not regenerated", function(){
						var ctx = router.resolveAiContext( { "threadId" : "thread-99" } )
						expect( ctx.threadId ).toBe( "thread-99" )
					} )
				} )
			} )

			story( "I want toAi() invoke/stream/batch to reject a request body that is not a JSON object", function(){
				beforeEach( function(){
					variables.runnable = createStub().$( "run", "stub-output" )
					router.route( "/api/chat" ).toAi( runnable )
				} )

				// Run a sub-route's response closure against a stub event whose body is `body`
				function callRoute( required string path, required any body ){
					var route = router.getRoutes().filter( ( r ) => r.pattern == "api/chat/#path#/" )[ 1 ]
					var event = createStub()
						.$( "getHTTPContent", body )
						.$( "renderData" )
						.$( "setHTTPHeader" )
					return { event : event, result : route.response( event, {}, {} ) }
				}

				function assertRejected( required struct called ){
					expect( called.event.$once( "renderData" ) ).toBeTrue()
					var args = called.event.$callLog().renderData[ 1 ]
					expect( args.statusCode ).toBe( 400 )
					expect( args.type ).toBe( "json" )
					expect( args.data.error ).toBeTrue()
					expect( args.data.message ).toBe( "The request body must be a JSON object" )
					expect( runnable.$never( "run" ) ).toBeTrue()
				}

				var routePaths = [ "invoke", "stream", "batch" ]
				var badBodies  = {
					"no body"       : "",
					"invalid JSON"  : "",
					"a JSON array"  : [ 1, 2 ],
					"a JSON string" : "hello"
				}

				routePaths.each( ( path ) => {
					badBodies.each( ( label, badBody ) => {
						given( "a POST to #path# with #label#", () => {
							then( "it answers 400 with a JSON error", () => {
								assertRejected( callRoute( path, badBody ) )
							} )
						} )
					} )
				} )

				given( "a valid JSON object body on invoke", function(){
					then( "it runs the runnable and answers as before", function(){
						var called = callRoute( "invoke", { "input" : "hi", "userId" : "u1", "threadId" : "t1" } )
						expect( called.event.$never( "renderData" ) ).toBeTrue()
						expect( called.result.success ).toBeTrue()
						expect( called.result.output ).toBe( "stub-output" )
						expect( called.result.threadId ).toBe( "t1" )
					} )
				} )

				given( "a valid JSON object body on batch", function(){
					then( "it runs the runnable for each input and answers as before", function(){
						var called = callRoute(
							"batch",
							{
								"inputs"   : [ "a", "b" ],
								"userId"   : "u1",
								"threadId" : "t1"
							}
						)
						expect( called.event.$never( "renderData" ) ).toBeTrue()
						expect( called.result.outputs ).toHaveLength( 2 )
						expect( called.result.outputs[ 1 ].success ).toBeTrue()
						expect( called.result.threadId ).toBe( "t1" )
					} )
				} )
			} )

			story( "I want argument validation on toAi()", function(){
				given( "a numeric value as runnable", function(){
					then( "it should throw InvalidArgumentException", function(){
						expect( function(){
							router.route( "/api/chat" ).toAi( 123 )
						} ).toThrow( "InvalidArgumentException" )
					} )
				} )

				given( "an array as runnable", function(){
					then( "it should throw InvalidArgumentException", function(){
						expect( function(){
							router.route( "/api/chat" ).toAi( [] )
						} ).toThrow( "InvalidArgumentException" )
					} )
				} )
			} )
		} )

		describe( "MCP Routing — toMCP()", function(){
			beforeEach( function(){
				variables.router = createMock( "coldbox.system.web.routing.Router" )
					.init()
					.setController( controller )
					.setLogBox( controller.getLogBox() )
					.setLog( controller.getLogBox().getLogger( this ) )
					.setCacheBox( controller.getCacheBox() )
					.setWireBox( controller.getWireBox() )
			} )

			story( "I want to expose an MCP server via a route", function(){
				given( "a valid server name", function(){
					then( "it should register one route with mcp=true and the server name", function(){
						router.route( "/mcp/filesystem" ).toMCP( "FileSystemServer" )
						var routes = router.getRoutes()

						expect( routes ).toHaveLength( 1 )
						expect( routes[ 1 ].mcp ).toBeTrue()
						expect( routes[ 1 ].mcpServer ).toBe( "FileSystemServer" )
					} )
				} )

				given( "a placeholder-style server name", function(){
					then( "it should store the placeholder as the mcpServer value", function(){
						router.route( "/mcp/:serverName" ).toMCP( "{serverName}" )
						var routes = router.getRoutes()

						expect( routes[ 1 ].mcpServer ).toBe( "{serverName}" )
					} )
				} )

				given( "an MCP route with withSSL()", function(){
					then( "the route should have ssl=true", function(){
						router
							.route( "/mcp/filesystem" )
							.withSSL()
							.toMCP( "FileSystemServer" )
						var routes = router.getRoutes()

						expect( routes[ 1 ].ssl ).toBeTrue()
					} )
				} )
			} )

			story( "I want argument validation on toMCP()", function(){
				given( "an empty string as serverName", function(){
					then( "it should throw InvalidArgumentException", function(){
						expect( function(){
							router.route( "/mcp/test" ).toMCP( "" )
						} ).toThrow( "InvalidArgumentException" )
					} )
				} )

				given( "a whitespace-only string as serverName", function(){
					then( "it should throw InvalidArgumentException", function(){
						expect( function(){
							router.route( "/mcp/test" ).toMCP( "   " )
						} ).toThrow( "InvalidArgumentException" )
					} )
				} )
			} )

			story( "I want dynamic routing support on toMCP()", function(){
				given( "an empty serverName but an :mcpServer placeholder in the route", function(){
					then( "it should not throw an exception", function(){
						router.route( "/mcp/:mcpServer" ).toMCP()
						var routes = router.getRoutes()
						expect( routes ).toHaveLength( 1 )
						expect( routes[ 1 ].mcp ).toBeTrue()
						expect( routes[ 1 ].mcpServer ).toBeEmpty()
					} )
				} )
			} )
		} )
	}

}
