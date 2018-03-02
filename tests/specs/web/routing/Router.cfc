/**
* Router tests
*/
component extends="coldbox.system.testing.BaseModelTest"{

/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		super.beforeAll();
		// Mocks
		controller = createMock( "coldbox.system.web.Controller" )
			.init( expandPath( '/coldbox/test-harness'), "cbController" )
			.setSetting( "AppMapping", "" )
			.setSetting( "RoutingAppMapping", "/" )
			.setSetting( "modules", {
				"unitTest" = {
					"routes" = [
						{ pattern="/", handler="home", action="index", name="home" }
					],
					"resources" = [
						{ resource = "users" },
						{ resource = "products" }
					]
				}
			} );
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
		super.afterAll();
	}

/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Routing Router", function(){

			beforeEach(function( currentSpec ){
				// Create Router
				router = createMock( "coldbox.system.web.routing.Router" ).init( controller );
			});

			story( "I want to register fluent routes with no modifiers or terminators", function(){
				given( "no inline target", function(){
					then( "it should store the route pointer", function(){
						router.route( "/luis" );
						expect( router.getThisRoute().pattern ).toBe( "/luis" );
					});
				});
				given( "an inline event", function(){
					then( "it should store the route immediately", function(){
						router.route( "/luis", "main.index" );
						expect( router.getRoutes()[ 1 ].pattern ).toBe( "luis/" );
						expect( router.getRoutes()[ 1 ].event ).toBe( "main.index" );
					});
				});
				given( "an inline closure", function(){
					then( "it should store the route immediately", function(){
						router.route( "/luis", function( event, rc, prc ){
							return "closure awesomeness";
						} );
						expect( router.getRoutes()[ 1 ].pattern ).toBe( "luis/" );
						expect( isClosure( router.getRoutes()[ 1 ].response ) ).toBeTrue();
					});
				});
			} );

			story( "I want to register fluent routes with HTTP Verb Restrictions", function(){
				given( "a valid HTTP Verb method shortcut", function(){
					var methods = [ "get", "put", "post", "patch", "delete", "options" ];
					methods.each( function( item ){
						when( "using #item#", function(){
							then(
								then 	= "it should restrict with #item#",
								data 	= { method = item },
								body 	= function( data ){
									invoke(
										router,
										data.method,
										{ pattern = "/get", target="main.#data.method#" }
									);
									var thisRoute = router.getRoutes().reduce( function( result, item ){
										if( item.event == "main.#data.method#" )
											return item;
									});
									expect( thisRoute ).notToBeNull();
								}
							);
						} );
					} );
				});
			} );

			story( "I can register module routes", function(){
				given( "an vaid module", function(){
					then( "it should add resources and routes", function(){
						router.addModuleRoutes( pattern="/myModule", module="unitTest" );
						var routes = router.getModuleRoutes( "unitTest" );
						//debug( routes );
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
						router.addNamespace( pattern="/myNamespace", namespace="myNamespace" );
						var routes = router.getRoutes();
						// Verify route
						expect(
							routes.filter( function( item ){
								return item.namespaceRouting == "myNamespace";
							} )
						).notToBeEmpty();
					});
				} );
			});

			story( "I can register routes with a with closure", function(){
				given( "a with closure", function(){
					then( "it will concatenate its members", function(){
						router.with( pattern="/api", handler="luis" )
							.addRoute( pattern="/users", action="index" )
							.addRoute( pattern="/hello", action="hello" )
						.endWith();
						var routes = router.getRoutes().filter( function( item ){
							return ( reFindNoCase( "^api", item.pattern ) && reFindNoCase( "luis", item.handler ) );
						});
						expect( routes ).notToBeEmpty();
					});
				});
			});

			story( "I can register route headers", function(){
				given( "A single or mulitple headers", function(){
					then( "they will register correctly", function(){
						router.route( "/withHeaders" )
							.header( "name", "luis" )
							.headers( {
								name : "majano",
								age : 100
							} );
						expect( router.getThisRoute().headers )
							.toBeStruct()
							.toHaveKey( "name" )
							.toHaveKey( "age" );
						expect( router.getThisRoute().headers.name ).toBe( "majano" );
					});
				});
			});

			story( "I can register named routes", function(){
				given( "A named option", function(){
					then( "the route will register", function(){
						router.route( "/home" ).as( "Home" );
						expect( router.getThisRoute().name ).toBe( "home" );
					});
				});
			});

			story( "I can register route rc parameters", function(){
				given( "A single or mulitple params", function(){
					then( "they will register correctly", function(){
						router.route( "/withRC" )
							.rc( "name", "luis" )
							.rcAppend( {
								name : "majano",
								age : 100
							} );
						expect( router.getThisRoute().rc )
							.toBeStruct()
							.toHaveKey( "name" )
							.toHaveKey( "age" );
						expect( router.getThisRoute().rc.name ).toBe( "majano" );
					});
				});
			});

			story( "I can register route prc parameters", function(){
				given( "A single or mulitple params", function(){
					then( "they will register correctly", function(){
						router.route( "/withPRC" )
							.prc( "name", "luis" )
							.prcAppend( {
								name : "majano",
								age : 100
							} );
						expect( router.getThisRoute().prc )
							.toBeStruct()
							.toHaveKey( "name" )
							.toHaveKey( "age" );
						expect( router.getThisRoute().prc.name ).toBe( "majano" );
					});
				});
			});

			story( "I can register constraints", function(){
				given( "A constraints struct", function(){
					then( "the route will register", function(){
						router.route( "/home/:id" )
							.constraints( {
								"id" : "(numeric)"
							} );
						expect( router.getThisRoute().constraints )
							.toBeStruct()
							.toHaveKey( "id" );
					});
				});
			});

			story( "I can register routes to views", function(){
				given( "A view terminator", function(){
					then( "the route will register", function(){
						router.route( "/about" )
							.toView( "about" );
						var thisRoute = router.getRoutes().reduce( function( result, item ){
							if( item.view == "about" )
								return item;
						} );

						expect(	thisRoute ).toBeStruct();
						expect( thisRoute.view ).toBe( "about" );
						expect( thisRoute.layout ).toBeEmpty();
						expect( thisRoute.noLayout ).toBeFalse();

					});
				});
				given( "A view with no layout terminator", function(){
					then( "the route will register", function(){
						router.route( "/about" )
							.toView( view="about", noLayout=true );
						var thisRoute = router.getRoutes().reduce( function( result, item ){
							if( item.view == "about" )
								return item;
						} );

						expect(	thisRoute ).toBeStruct();
						expect( thisRoute.view ).toBe( "about" );
						expect( thisRoute.layout ).toBeEmpty();
						expect( thisRoute.noLayout ).toBeTrue();

					});
				});
				given( "A view with a layout terminator", function(){
					then( "the route will register", function(){
						router.route( "/about" )
							.toView( view="about", layout="document" );
						var thisRoute = router.getRoutes().reduce( function( result, item ){
							if( item.view == "about" )
								return item;
						} );

						expect(	thisRoute ).toBeStruct();
						expect( thisRoute.view ).toBe( "about" );
						expect( thisRoute.layout ).toBe( "document" );
						expect( thisRoute.noLayout ).toBeFalse();

					});
				});
			});

			story( "I can register routes to redirects", function(){
				given( "A redirect terminator", function(){
					then( "the route will register", function(){
						router.route( "/about" )
							.toRedirect( "/about2" );
						var thisRoute = router.getRoutes().reduce( function( result, item ){
							if( item.redirect == "/about2" )
								return item;
						} );

						expect(	thisRoute ).toBeStruct();
						expect( thisRoute.redirect ).toBe( "/about2" );
						expect( thisRoute.statusCode ).toBe( 301 );

					});
				});
			});

			story( "I can register routes to events", function(){
				given( "A to terminator", function(){
					then( "the route will register", function(){
						router.route( "/about" )
							.to( "home.about" );
						var thisRoute = router.getRoutes().reduce( function( result, item ){
							if( item.event == "home.about" )
								return item;
						} );

						expect(	thisRoute ).toBeStruct();

					});
				});
			});

			story( "I can register routes to handlers", function(){
				given( "A toHandler() terminator", function(){
					then( "the route will register", function(){
						router.route( "/about/:action" )
							.toHandler( "static" );
						var thisRoute = router.getRoutes().reduce( function( result, item ){
							if( item.handler == "static" )
								return item;
						} );

						expect(	thisRoute ).toBeStruct();

					});
				});
			});

			story( "I can register routes to responses", function(){
				given( "A response terminator", function(){
					then( "the route will register", function(){
						router.route( "/about" )
							.toResponse(
								function( event, rc, prc ){
									return "About Page";
								}
							);

						var thisRoute = router.getRoutes().reduce( function( result, item ){
							if( isClosure( item.response ) )
								return item;
						} );

						expect(	thisRoute ).toBeStruct();
						expect( thisRoute.response() ).toBe( "About Page" );

					});
				});
			});

			story( "I can register routes with the default terminator", function(){
				given( "A route with only modifiers and the default terminator of end()", function(){
					then( "the route will register", function(){
						router.route( "/about/:handler" )
							.withAction( "static" )
							.end();
						var thisRoute = router.getRoutes().reduce( function( result, item ){
							if( item.action == "static" )
								return item;
						} );

						expect(	thisRoute ).toBeStruct();

					});
				});
			});


		});
	}

}
