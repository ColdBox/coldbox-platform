component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.web.routing.Router" {

	function beforeAll(){
		super.setup();
		mockController = getMockController().setSetting( "RoutingAppMapping", "/" );
		router         = model.init( mockController );
	}

	function run(){
		describe( "Mapping resources", function(){
			beforeEach( function(){
				router.$reset();
				router.$( "addRoute" );
			} );


			it( "can register nested resources", function(){
				router.resources( resource = "agents", pattern = "/sites/:siteId/agents" );
				var cl = router.$callLog().addRoute;
				expect( cl[ 1 ] ).toBe(
					{
						pattern   : "/sites/:siteId/agents/:id/edit",
						handler   : "agents",
						action    : { GET : "edit" },
						module    : "",
						namespace : "",
						meta      : {}
					},
					"The route did not match.  Remember that order matters.  Add the most specific routes first."
				);
				expect( cl[ 2 ] ).toBe(
					{
						pattern   : "/sites/:siteId/agents/new",
						handler   : "agents",
						action    : { GET : "new" },
						module    : "",
						namespace : "",
						meta      : {}
					},
					"The route did not match.  Remember that order matters.  Add the most specific routes first."
				);
				expect( cl[ 3 ] ).toBe(
					{
						pattern : "/sites/:siteId/agents/:id",
						handler : "agents",
						action  : {
							GET    : "show",
							PUT    : "update",
							PATCH  : "update",
							DELETE : "delete"
						},
						module    : "",
						namespace : "",
						meta      : {}
					},
					"The route did not match.  Remember that order matters.  Add the most specific routes first."
				);
				expect( cl[ 4 ] ).toBe(
					{
						pattern   : "/sites/:siteId/agents",
						handler   : "agents",
						action    : { GET : "index", POST : "create" },
						module    : "",
						namespace : "",
						meta      : {}
					},
					"The route did not match.  Remember that order matters.  Add the most specific routes first."
				);
			} );

			it( "can add RESTFul routes as a string list", function(){
				router.resources( "photos,users" );

				var cl = router.$callLog().addRoute;

				expect( cl ).toHaveLength(
					8,
					"addRoute should have been called 8 times, but it was called: #arrayLen( cl )#"
				);
			} );

			it( "can add RESTFul routes as an array list", function(){
				router.resources( [ "photos", "users" ] );

				var cl = router.$callLog().addRoute;

				expect( cl ).toHaveLength(
					8,
					"addRoute should have been called 8 times, but it was called: #arrayLen( cl )#"
				);
			} );

			it( "can add all the RESTful routes for a resource", function(){
				router.resources( "photos" );

				var cl = router.$callLog().addRoute;

				debug( cl );

				expect( cl ).toHaveLength( 4, "addRoute should have been called 4 times" );
				expect( cl[ 1 ] ).toBe(
					{
						pattern   : "/photos/:id/edit",
						handler   : "photos",
						action    : { GET : "edit" },
						module    : "",
						namespace : "",
						meta      : {}
					},
					"The route 1 did not match.  Remember that order matters.  Add the most specific routes first."
				);
				expect( cl[ 2 ] ).toBe(
					{
						pattern   : "/photos/new",
						handler   : "photos",
						action    : { GET : "new" },
						module    : "",
						namespace : "",
						meta      : {}
					},
					"The route 2 did not match.  Remember that order matters.  Add the most specific routes first."
				);
				expect( cl[ 3 ] ).toBe(
					{
						pattern : "/photos/:id",
						handler : "photos",
						action  : {
							GET    : "show",
							PUT    : "update",
							PATCH  : "update",
							DELETE : "delete"
						},
						module    : "",
						namespace : "",
						meta      : {}
					},
					"The route 3 did not match.  Remember that order matters.  Add the most specific routes first."
				);
				expect( cl[ 4 ] ).toBe(
					{
						pattern   : "/photos",
						handler   : "photos",
						action    : { GET : "index", POST : "create" },
						module    : "",
						namespace : "",
						meta      : {}
					},
					"The route 4 did not match.  Remember that order matters.  Add the most specific routes first."
				);
			} );

			it( "can override the handler used", function(){
				router.resources( "photos", "PhotosController" );

				var cl = router.$callLog().addRoute;
				// debug( cl );

				expect( cl ).toHaveLength( 4, "addRoute should have been called 4 times" );
				expect( cl[ 1 ] ).toBe(
					{
						pattern   : "/photos/:id/edit",
						handler   : "PhotosController",
						action    : { GET : "edit" },
						module    : "",
						namespace : "",
						meta      : {}
					},
					"The route did not match.  Remember that order matters.  Add the most specific routes first."
				);
				expect( cl[ 2 ] ).toBe(
					{
						pattern   : "/photos/new",
						handler   : "PhotosController",
						action    : { GET : "new" },
						module    : "",
						namespace : "",
						meta      : {}
					},
					"The route did not match.  Remember that order matters.  Add the most specific routes first."
				);
				expect( cl[ 3 ] ).toBe(
					{
						pattern : "/photos/:id",
						handler : "PhotosController",
						action  : {
							GET    : "show",
							PUT    : "update",
							PATCH  : "update",
							DELETE : "delete"
						},
						module    : "",
						namespace : "",
						meta      : {}
					},
					"The route did not match.  Remember that order matters.  Add the most specific routes first."
				);
				expect( cl[ 4 ] ).toBe(
					{
						pattern   : "/photos",
						handler   : "PhotosController",
						action    : { GET : "index", POST : "create" },
						module    : "",
						namespace : "",
						meta      : {}
					},
					"The route did not match.  Remember that order matters.  Add the most specific routes first."
				);
			} );

			it( "can override the parameterName used", function(){
				router.resources( resource = "photos", parameterName = "photoId" );

				var cl = router.$callLog().addRoute;
				// debug( cl );

				expect( cl ).toHaveLength( 4, "addRoute should have been called 4 times" );
				expect( cl[ 1 ] ).toBe(
					{
						pattern   : "/photos/:photoId/edit",
						handler   : "photos",
						action    : { GET : "edit" },
						module    : "",
						namespace : "",
						meta      : {}
					},
					"The route did not match.  Remember that order matters.  Add the most specific routes first."
				);
				expect( cl[ 2 ] ).toBe(
					{
						pattern   : "/photos/new",
						handler   : "photos",
						action    : { GET : "new" },
						module    : "",
						namespace : "",
						meta      : {}
					},
					"The route did not match.  Remember that order matters.  Add the most specific routes first."
				);
				expect( cl[ 3 ] ).toBe(
					{
						pattern : "/photos/:photoId",
						handler : "photos",
						action  : {
							GET    : "show",
							PUT    : "update",
							PATCH  : "update",
							DELETE : "delete"
						},
						module    : "",
						namespace : "",
						meta      : {}
					},
					"The route did not match.  Remember that order matters.  Add the most specific routes first."
				);
				expect( cl[ 4 ] ).toBe(
					{
						pattern   : "/photos",
						handler   : "photos",
						action    : { GET : "index", POST : "create" },
						module    : "",
						namespace : "",
						meta      : {}
					},
					"The route did not match.  Remember that order matters.  Add the most specific routes first."
				);
			} );

			it( "returns itself to continue chaining", function(){
				var result = router.resources( "photos" );

				expect( result ).toBe( router );
			} );


			describe( "limiting the routes created by action", function(){
				describe( "using the `only` parameter", function(){
					it( "can take a list of actions and only generate those routes", function(){
						router.resources( resource = "photos", only = "index,show" );

						var cl = router.$callLog().addRoute;
						// debug( cl );

						expect( cl ).toHaveLength( 2, "addRoute should have been called 2 times" );
						expect( cl[ 1 ] ).toBe(
							{
								pattern   : "/photos/:id",
								handler   : "photos",
								action    : { GET : "show" },
								module    : "",
								namespace : "",
								meta      : {}
							},
							"The route did not match.  Remember that order matters.  Add the most specific routes first."
						);
						expect( cl[ 2 ] ).toBe(
							{
								pattern   : "/photos",
								handler   : "photos",
								action    : { GET : "index" },
								module    : "",
								namespace : "",
								meta      : {}
							},
							"The route did not match.  Remember that order matters.  Add the most specific routes first."
						);
					} );

					it( "can take an array of actions and only generate those routes", function(){
						router.resources( resource = "photos", only = [ "index", "show" ] );

						var cl = router.$callLog().addRoute;
						// debug( cl );

						expect( cl ).toHaveLength( 2, "addRoute should have been called 2 times" );
						expect( cl[ 1 ] ).toBe(
							{
								pattern   : "/photos/:id",
								handler   : "photos",
								action    : { GET : "show" },
								module    : "",
								namespace : "",
								meta      : {}
							},
							"The route did not match.  Remember that order matters.  Add the most specific routes first."
						);
						expect( cl[ 2 ] ).toBe(
							{
								pattern   : "/photos",
								handler   : "photos",
								action    : { GET : "index" },
								module    : "",
								namespace : "",
								meta      : {}
							},
							"The route did not match.  Remember that order matters.  Add the most specific routes first."
						);
					} );
				} );

				describe( "using the `except` parameter", function(){
					it( "can take a list of actions and generate all except those routes", function(){
						router.resources( resource = "photos", except = "create,edit,update,delete" );

						var cl = router.$callLog().addRoute;
						// debug( cl );

						expect( cl ).toHaveLength( 3, "addRoute should have been called 3 times" );
						expect( cl[ 1 ] ).toBe(
							{
								pattern   : "/photos/new",
								handler   : "photos",
								action    : { GET : "new" },
								module    : "",
								namespace : "",
								meta      : {}
							},
							"The route did not match.  Remember that order matters.  Add the most specific routes first."
						);
						expect( cl[ 2 ] ).toBe(
							{
								pattern   : "/photos/:id",
								handler   : "photos",
								action    : { GET : "show" },
								module    : "",
								namespace : "",
								meta      : {}
							},
							"The route did not match.  Remember that order matters.  Add the most specific routes first."
						);
						expect( cl[ 3 ] ).toBe(
							{
								pattern   : "/photos",
								handler   : "photos",
								action    : { GET : "index" },
								module    : "",
								namespace : "",
								meta      : {}
							},
							"The route did not match.  Remember that order matters.  Add the most specific routes first."
						);
					} );

					it( "can take an array of actions and generate all except those routes", function(){
						router.resources( resource = "photos", except = [ "create", "edit", "update", "delete" ] );

						var cl = router.$callLog().addRoute;
						// debug( cl );

						expect( cl ).toHaveLength( 3, "addRoute should have been called 3 times" );
						expect( cl[ 1 ] ).toBe(
							{
								pattern   : "/photos/new",
								handler   : "photos",
								action    : { GET : "new" },
								module    : "",
								namespace : "",
								meta      : {}
							},
							"The route did not match.  Remember that order matters.  Add the most specific routes first."
						);
						expect( cl[ 2 ] ).toBe(
							{
								pattern   : "/photos/:id",
								handler   : "photos",
								action    : { GET : "show" },
								module    : "",
								namespace : "",
								meta      : {}
							},
							"The route did not match.  Remember that order matters.  Add the most specific routes first."
						);
						expect( cl[ 3 ] ).toBe(
							{
								pattern   : "/photos",
								handler   : "photos",
								action    : { GET : "index" },
								module    : "",
								namespace : "",
								meta      : {}
							},
							"The route did not match.  Remember that order matters.  Add the most specific routes first."
						);
					} );
				} );

				describe( "using both `only` and `except`", function(){
					it( "can apply both the `only` and the `except` parameters", function(){
						router.resources(
							resource = "photos",
							only     = [ "index", "show" ],
							except   = "show",
							module   = "",
							namespace= "",
							meta     : {}
						);

						var cl = router.$callLog().addRoute;
						// debug( cl );

						expect( cl ).toHaveLength( 1, "addRoute should have been called 1 time" );
						expect( cl[ 1 ] ).toBe(
							{
								pattern   : "/photos",
								handler   : "photos",
								action    : { GET : "index" },
								module    : "",
								namespace : "",
								meta      : {}
							},
							"The route did not match.  Remember that order matters.  Add the most specific routes first."
						);
					} );
				} );
			} );
		} );
	}

}
