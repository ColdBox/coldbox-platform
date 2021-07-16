/**
 * Router tests
 */
component extends="coldbox.system.testing.BaseModelTest" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		super.beforeAll();
		// Mocks
		controller = createMock( "coldbox.system.web.Controller" )
			.init( expandPath( "/coldbox/test-harness" ), "cbController" )
			.setSetting( "AppMapping", "" )
			.setSetting( "RoutingAppMapping", "/" )
			.setSetting(
				"modules",
				{
					"unitTest" : {
						"routes" : [
							{
								pattern : "/",
								handler : "home",
								action  : "index",
								name    : "home"
							}
						],
						"resources" : [
							{ resource : "users" },
							{ resource : "products" }
						]
					}
				}
			);
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Routing Router", function(){
			beforeEach( function( currentSpec ){
				// Create Router
				router = createMock( "coldbox.system.web.routing.Router" ).init( controller );
			} );

			story( "I want to group routes with common options", function(){
				given( "a grouped route with handler and pattern only", function(){
					then( "it should store the route with common options", function(){
						router.group( { pattern : "/api", handler : "api" }, function( options ){
							router
								.route( "/CountiesByZip/:zip" )
								.withAction( { get : "CountiesByZip", options : "returnOptions" } )
								.end()
								.route( "/UtcOffsetByZip/:zip" )
								.toAction( { get : "UtcOffsetByZip", options : "returnOptions" } );
						} );

						var routes = router.getRoutes();
						expect( routes ).toHaveLength( 2 );

						expect( routes[ 1 ].handler ).toBe( "api" );
						expect( routes[ 1 ].pattern ).toBe( "api/CountiesByZip/:zip/" );
						expect( routes[ 1 ].action ).toBe( { get : "CountiesByZip", options : "returnOptions" } );

						expect( routes[ 2 ].handler ).toBe( "api" );
						expect( routes[ 2 ].pattern ).toBe( "api/UtcOffsetByZip/:zip/" );
						expect( routes[ 2 ].action ).toBe( { get : "UtcOffsetByZip", options : "returnOptions" } );
					} );
				} );

				given( "a grouped route with valid options", function(){
					then( "it should store the route with common options", function(){
						router.group( { target : "api.", handler : "api.", pattern : "/api" }, function( options ){
							router
								.route( "/", "main.index" )
								.route( "/hello", "echo.index" )
								.route( "/users/:id" )
								.withAction( {
									"get"    : "index",
									"post"   : "save",
									"put"    : "save",
									"delete" : "delete"
								} )
								.toHandler( "users" );
						} );

						var routes = router.getRoutes();
						expect( routes ).toHaveLength( 3 );

						expect( routes[ 1 ].event ).toBe( "api.main.index" );
						expect( routes[ 1 ].pattern ).toBe( "api/" );

						expect( routes[ 2 ].event ).toBe( "api.echo.index" );
						expect( routes[ 2 ].pattern ).toBe( "api/hello/" );

						expect( routes[ 3 ].handler ).toBe( "api.users" );
						expect( routes[ 3 ].pattern ).toBe( "api/users/:id/" );
					} );
				} );
			} );

			story( "I want to register routes with a toAction() terminator", function(){
				given( "a toAction() terminator", function(){
					then( "it should register the appropriate route", function(){
						router
							.route( "/toAction" )
							.withHandler( "luis" )
							.toAction( "index" );
						expect( router.getRoutes()[ 1 ].pattern ).toBe( "toAction/" );
						expect( router.getRoutes()[ 1 ].action ).toBe( "index" );
					} );
				} );
			} );

			story( "I want to register fluent routes with no modifiers or terminators", function(){
				given( "no inline target", function(){
					then( "it should store the route pointer", function(){
						router.route( "/luis" );
						expect( router.getThisRoute().pattern ).toBe( "/luis" );
					} );
				} );
				given( "an inline event", function(){
					then( "it should store the route immediately", function(){
						router.route( "/luis", "main.index" );
						expect( router.getRoutes()[ 1 ].pattern ).toBe( "luis/" );
						expect( router.getRoutes()[ 1 ].event ).toBe( "main.index" );
					} );
				} );
				given( "an inline closure", function(){
					then( "it should store the route immediately", function(){
						router.route( "/luis", function( event, rc, prc ){
							return "closure awesomeness";
						} );
						expect( router.getRoutes()[ 1 ].pattern ).toBe( "luis/" );
						expect( isClosure( router.getRoutes()[ 1 ].response ) ).toBeTrue();
					} );
				} );
			} );

			story( "I want to register fluent routes with HTTP Verb Restrictions", function(){
				given( "a valid HTTP Verb method shortcut", function(){
					var methods = [
						"get",
						"put",
						"post",
						"patch",
						"delete",
						"options"
					];
					methods.each( function( item ){
						when( "using #item#", function(){
							then(
								then = "it should restrict with #item#",
								data = { method : item },
								body = function( data ){
									invoke(
										router,
										data.method,
										{ pattern : "/get", target : "main.#data.method#" }
									);
									var thisRoute = router
										.getRoutes()
										.reduce( function( result, item ){
											if ( item.event == "main.#data.method#" ) return item;
										} );
									expect( thisRoute ).notToBeNull();
								}
							);
						} );
					} );
				} );

				given( "different HTTP verbs for the same route", function(){
					then( "both verbs should be registered", function(){
						router.post( "photos/", "photos.create" );
						router.get( "photos/", "photos.index" );

						var routes = router.getRoutes();
						expect( routes ).toBeArray();
						expect( routes ).toHaveLength( 1, "One route should be registered" );
						expect( routes[ 1 ].pattern ).toBe( "photos/" );
						expect( routes[ 1 ].action ).toBeStruct();
						expect( routes[ 1 ].action ).toHaveLength(
							2,
							"The registered route should have two actions"
						);
						expect( routes[ 1 ].action ).toBe( { "GET" : "photos.index", "POST" : "photos.create" } );
					} );
				} );
			} );

			story( "I can register module routes", function(){
				given( "an vaid module", function(){
					then( "it should add resources and routes", function(){
						router.addModuleRoutes( pattern = "/myModule", module = "unitTest" );
						var routes = router.getModuleRoutes( "unitTest" );
						// debug( routes );
						// Verify route
						expect(
							routes.filter( function( item ){
								return item.name == "home";
							} )
						).notToBeEmpty();
						// Verify Rources
						expect(
							routes.filter( function( item ){
								return reFindNoCase( "(users|products)", item.handler );
							} )
						).notToBeEmpty();
					} );
				} );
			} );

			story( "I can register namespace routes", function(){
				given( "a valid namespace", function(){
					then( "it will create the namespace entry point", function(){
						router.addNamespace( pattern = "/myNamespace", namespace = "myNamespace" );
						var routes = router.getRoutes();
						// Verify route
						expect(
							routes.filter( function( item ){
								return item.namespaceRouting == "myNamespace";
							} )
						).notToBeEmpty();
					} );
				} );
			} );

			story( "I can register routes with a with closure", function(){
				given( "a with closure", function(){
					then( "it will concatenate its members", function(){
						router
							.with( pattern = "/api", handler = "luis" )
							.addRoute( pattern = "/users", action = "index" )
							.addRoute( pattern = "/hello", action = "hello" )
							.endWith();
						var routes = router
							.getRoutes()
							.filter( function( item ){
								return ( reFindNoCase( "^api", item.pattern ) && reFindNoCase( "luis", item.handler ) );
							} );
						expect( routes ).notToBeEmpty();
					} );
				} );
			} );

			story( "I can register route headers", function(){
				given( "A single or multiple headers", function(){
					then( "they will register correctly", function(){
						router
							.route( "/withHeaders" )
							.header( "name", "luis" )
							.headers( { name : "majano", age : 100 } );
						expect( router.getThisRoute().headers )
							.toBeStruct()
							.toHaveKey( "name" )
							.toHaveKey( "age" );
						expect( router.getThisRoute().headers.name ).toBe( "majano" );
					} );
				} );
			} );

			story( "Router will throw exception if a non-closure or string is passed to the body of a toResponse()", function(){
				given( "Anything but a closure or string to the toResponse() body", function(){
					then( "an InvalidArgumentException will be thrown", function(){
						expect( function(){
							router.route( "/home" ).toResponse( {} );
						} ).toThrow();
					} );
				} );
			} );

			story( "I can register named routes", function(){
				given( "A named option", function(){
					then( "the route will register", function(){
						router.route( "/home" ).as( "Home" );
						expect( router.getThisRoute().name ).toBe( "home" );
					} );
				} );
			} );

			story( "I can register route rc parameters", function(){
				given( "A single or multiple params", function(){
					then( "they will register correctly", function(){
						router
							.route( "/withRC" )
							.rc( "name", "luis" )
							.rcAppend( { name : "majano", age : 100 } );
						expect( router.getThisRoute().rc )
							.toBeStruct()
							.toHaveKey( "name" )
							.toHaveKey( "age" );
						expect( router.getThisRoute().rc.name ).toBe( "majano" );
					} );
				} );
			} );

			story( "I can register route prc parameters", function(){
				given( "A single or multiple params", function(){
					then( "they will register correctly", function(){
						router
							.route( "/withPRC" )
							.prc( "name", "luis" )
							.prcAppend( { name : "majano", age : 100 } );
						expect( router.getThisRoute().prc )
							.toBeStruct()
							.toHaveKey( "name" )
							.toHaveKey( "age" );
						expect( router.getThisRoute().prc.name ).toBe( "majano" );
					} );
				} );
			} );

			story( "I can register constraints", function(){
				given( "A constraints struct", function(){
					then( "the route will register", function(){
						router.route( "/home/:id" ).constraints( { "id" : "(numeric)" } );
						expect( router.getThisRoute().constraints ).toBeStruct().toHaveKey( "id" );
					} );
				} );
			} );

			story( "I can register routes to views", function(){
				given( "A view terminator", function(){
					then( "the route will register", function(){
						router.route( "/about" ).toView( "about" );
						var thisRoute = router
							.getRoutes()
							.reduce( function( result, item ){
								if ( item.view == "about" ) return item;
							} );

						expect( thisRoute ).toBeStruct();
						expect( thisRoute.view ).toBe( "about" );
						expect( thisRoute.layout ).toBeEmpty();
						expect( thisRoute.viewNoLayout ).toBeFalse();
					} );
				} );
				given( "A view with no layout terminator", function(){
					then( "the route will register", function(){
						router.route( "/about" ).toView( view = "about", noLayout = true );
						var thisRoute = router
							.getRoutes()
							.reduce( function( result, item ){
								if ( item.view == "about" ) return item;
							} );

						expect( thisRoute ).toBeStruct();
						expect( thisRoute.view ).toBe( "about" );
						expect( thisRoute.layout ).toBeEmpty();
						expect( thisRoute.viewNoLayout ).toBeTrue();
					} );
				} );
				given( "A view with a layout terminator", function(){
					then( "the route will register", function(){
						router.route( "/about" ).toView( view = "about", layout = "document" );
						var thisRoute = router
							.getRoutes()
							.reduce( function( result, item ){
								if ( item.view == "about" ) return item;
							} );

						expect( thisRoute ).toBeStruct();
						expect( thisRoute.view ).toBe( "about" );
						expect( thisRoute.layout ).toBe( "document" );
						expect( thisRoute.viewNoLayout ).toBeFalse();
					} );
				} );
			} );

			story( "I can register routes to redirects", function(){
				given( "A redirect terminator", function(){
					then( "the route will register", function(){
						router.route( "/about" ).toRedirect( "/about2" );
						var thisRoute = router
							.getRoutes()
							.reduce( function( result, item ){
								if ( item.redirect == "/about2" ) return item;
							} );

						expect( thisRoute ).toBeStruct();
						expect( thisRoute.redirect ).toBe( "/about2" );
						expect( thisRoute.statusCode ).toBe( 301 );
					} );
				} );
			} );

			story( "I can register routes to events", function(){
				given( "A to terminator", function(){
					then( "the route will register", function(){
						router.route( "/about" ).to( "home.about" );
						var thisRoute = router
							.getRoutes()
							.reduce( function( result, item ){
								if ( item.event == "home.about" ) return item;
							} );

						expect( thisRoute ).toBeStruct();
					} );
				} );
			} );

			story( "I can register routes to handlers", function(){
				given( "A toHandler() terminator", function(){
					then( "the route will register", function(){
						router.route( "/about/:action" ).toHandler( "static" );
						var thisRoute = router
							.getRoutes()
							.reduce( function( result, item ){
								if ( item.handler == "static" ) return item;
							} );

						expect( thisRoute ).toBeStruct();
					} );
				} );
			} );

			story( "I can register routes to responses", function(){
				given( "A response terminator", function(){
					then( "the route will register", function(){
						router
							.route( "/about" )
							.toResponse( function( event, rc, prc ){
								return "About Page";
							} );

						var thisRoute = router
							.getRoutes()
							.reduce( function( result, item ){
								if ( isClosure( item.response ) ) return item;
							} );

						expect( thisRoute ).toBeStruct();
						expect( thisRoute.response() ).toBe( "About Page" );
					} );
				} );
			} );

			story( "I can register routes with the default terminator", function(){
				given( "A route with only modifiers and the default terminator of end()", function(){
					then( "the route will register", function(){
						router
							.route( "/about/:handler" )
							.withAction( "static" )
							.end();
						var thisRoute = router
							.getRoutes()
							.reduce( function( result, item ){
								if ( item.action == "static" ) return item;
							} );

						expect( thisRoute ).toBeStruct();
					} );
				} );
			} );

			story( "I can register a suite of routes with resources", function(){
				given( "I register a resource", function(){
					then( "I should have a suite of routes for that resource", function(){
						router.resources( "photos" );
						var routes = router.getRoutes();
						expect( routes ).toBeArray();
						expect( routes ).toHaveLength( 4 );
						expect( routes[ 1 ].pattern ).toBe( "photos/:id/edit/" );
						expect( routes[ 1 ].action ).toBe( { "GET" : "edit" } );
						expect( routes[ 2 ].pattern ).toBe( "photos/new/" );
						expect( routes[ 2 ].action ).toBe( { "GET" : "new" } );
						expect( routes[ 3 ].pattern ).toBe( "photos/:id/" );
						expect( routes[ 3 ].action ).toBe( {
							"GET"    : "show",
							"PATCH"  : "update",
							"PUT"    : "update",
							"DELETE" : "delete"
						} );
						expect( routes[ 4 ].pattern ).toBe( "photos/" );
						expect( routes[ 4 ].action ).toBe( { "GET" : "index", "POST" : "create" } );
					} );
				} );
				given( "I register multiple resources using an array", function(){
					then( "I should have a suite of routes for that resource", function(){
						router.resources( [ "photos", "videos" ] );
						var routes = router.getRoutes();
						expect( routes ).toBeArray();
						expect( routes ).toHaveLength( 8 );
						expect( routes[ 1 ].pattern ).toBe( "photos/:id/edit/" );
						expect( routes[ 1 ].action ).toBe( { "GET" : "edit" } );
						expect( routes[ 2 ].pattern ).toBe( "photos/new/" );
						expect( routes[ 2 ].action ).toBe( { "GET" : "new" } );
						expect( routes[ 3 ].pattern ).toBe( "photos/:id/" );
						expect( routes[ 3 ].action ).toBe( {
							"GET"    : "show",
							"PATCH"  : "update",
							"PUT"    : "update",
							"DELETE" : "delete"
						} );
						expect( routes[ 4 ].pattern ).toBe( "photos/" );
						expect( routes[ 4 ].action ).toBe( { "GET" : "index", "POST" : "create" } );
						expect( routes[ 5 ].pattern ).toBe( "videos/:id/edit/" );
						expect( routes[ 5 ].action ).toBe( { "GET" : "edit" } );
						expect( routes[ 6 ].pattern ).toBe( "videos/new/" );
						expect( routes[ 6 ].action ).toBe( { "GET" : "new" } );
						expect( routes[ 7 ].pattern ).toBe( "videos/:id/" );
						expect( routes[ 7 ].action ).toBe( {
							"GET"    : "show",
							"PATCH"  : "update",
							"PUT"    : "update",
							"DELETE" : "delete"
						} );
						expect( routes[ 8 ].pattern ).toBe( "videos/" );
						expect( routes[ 8 ].action ).toBe( { "GET" : "index", "POST" : "create" } );
					} );
				} );
				given( "I register multiple resources using a list", function(){
					then( "I should have a suite of routes for that resource", function(){
						router.resources( "photos,videos" );
						var routes = router.getRoutes();
						expect( routes ).toBeArray();
						expect( routes ).toHaveLength( 8 );
						expect( routes[ 1 ].pattern ).toBe( "photos/:id/edit/" );
						expect( routes[ 1 ].action ).toBe( { "GET" : "edit" } );
						expect( routes[ 2 ].pattern ).toBe( "photos/new/" );
						expect( routes[ 2 ].action ).toBe( { "GET" : "new" } );
						expect( routes[ 3 ].pattern ).toBe( "photos/:id/" );
						expect( routes[ 3 ].action ).toBe( {
							"GET"    : "show",
							"PATCH"  : "update",
							"PUT"    : "update",
							"DELETE" : "delete"
						} );
						expect( routes[ 4 ].pattern ).toBe( "photos/" );
						expect( routes[ 4 ].action ).toBe( { "GET" : "index", "POST" : "create" } );
						expect( routes[ 5 ].pattern ).toBe( "videos/:id/edit/" );
						expect( routes[ 5 ].action ).toBe( { "GET" : "edit" } );
						expect( routes[ 6 ].pattern ).toBe( "videos/new/" );
						expect( routes[ 6 ].action ).toBe( { "GET" : "new" } );
						expect( routes[ 7 ].pattern ).toBe( "videos/:id/" );
						expect( routes[ 7 ].action ).toBe( {
							"GET"    : "show",
							"PATCH"  : "update",
							"PUT"    : "update",
							"DELETE" : "delete"
						} );
						expect( routes[ 8 ].pattern ).toBe( "videos/" );
						expect( routes[ 8 ].action ).toBe( { "GET" : "index", "POST" : "create" } );
					} );
				} );
			} );

			story( "I can register a route with a condition", function(){
				given( "I register a route with a condition", function(){
					then( "I should have a route with a condition closure specified", function(){
						router
							.route( "/about" )
							.withCondition( function(){
								return url.keyExists( "firstName" );
							} )
							.withAction( { "GET" : "getFirstName" } )
							.toHandler( "About" );

						var routes = router.getRoutes();
						expect( routes ).toBeArray();
						expect( routes ).toHaveLength( 1 );
						expect( routes[ 1 ] ).toHaveKey( "condition" );
						expect( isClosure( routes[ 1 ].condition ) || isCustomFunction( routes[ 1 ].condition ) ).toBeTrue(
							"Condition should be callable."
						);
						expect( routes[ 1 ] ).toHaveKey( "handler" );
						expect( routes[ 1 ].handler ).toBe( "About" );
						expect( routes[ 1 ] ).toHaveKey( "action" );
						expect( routes[ 1 ].action ).toBeStruct();
						expect( routes[ 1 ].action ).toHaveKey( "GET" );
						expect( routes[ 1 ].action.GET ).toBe( "getFirstName" );
					} );
				} );

				given( "I register two routes with the same pattern and different conditions", function(){
					then( "I should have two routes showing both conditions", function(){
						router
							.route( "/about" )
							.withCondition( function(){
								return url.keyExists( "firstName" );
							} )
							.withAction( { "GET" : "getFirstName" } )
							.toHandler( "About" );

						router
							.route( "/about" )
							.withCondition( function(){
								return url.keyExists( "lastName" );
							} )
							.withAction( { "GET" : "getLastName" } )
							.toHandler( "About" );

						var routes = router.getRoutes();
						expect( routes ).toBeArray();
						expect( routes ).toHaveLength( 2 );

						expect( routes[ 1 ] ).toHaveKey( "condition" );
						expect( isClosure( routes[ 1 ].condition ) || isCustomFunction( routes[ 1 ].condition ) ).toBeTrue(
							"Condition should be callable."
						);
						expect( routes[ 1 ] ).toHaveKey( "handler" );
						expect( routes[ 1 ].handler ).toBe( "About" );
						expect( routes[ 1 ] ).toHaveKey( "action" );
						expect( routes[ 1 ].action ).toBeStruct();
						expect( routes[ 1 ].action ).toHaveKey( "GET" );
						expect( routes[ 1 ].action.GET ).toBe( "getFirstName" );

						expect( routes[ 2 ] ).toHaveKey( "condition" );
						expect( isClosure( routes[ 2 ].condition ) || isCustomFunction( routes[ 2 ].condition ) ).toBeTrue(
							"Condition should be callable."
						);
						expect( routes[ 1 ] ).toHaveKey( "handler" );
						expect( routes[ 1 ].handler ).toBe( "About" );
						expect( routes[ 2 ] ).toHaveKey( "action" );
						expect( routes[ 2 ].action ).toBeStruct();
						expect( routes[ 2 ].action ).toHaveKey( "GET" );
						expect( routes[ 2 ].action.GET ).toBe( "getLastName" );
					} );
				} );
			} );
		} );
	}

}
