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
		
		if( notBoxlang() ){
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
