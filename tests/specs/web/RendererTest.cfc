/**
 * Renderer integration tests
 */
component extends="tests.resources.BaseIntegrationTest" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		getPageContext().getResponse().setContentType( "text/html" );
		super.beforeAll();
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "ColdBox Renderer", function(){
			beforeEach( function( currentSpec ){
				setup();
				renderer = prepareMock( getController().getRenderer() );
			} );

			it( "can render views with caching parameters", function(){
				var results = renderer.view(
					view         = "simpleview",
					cache        = true,
					cacheTimeout = "5"
				);
				// debug( results );

				var results2 = renderer.view(
					view        = "simpleview",
					cache       = true,
					acheTimeout = "5"
				);
				expect( results ).toBe( results2 );
			} );

			it( "can render views with different caching providers", function(){
				var results = renderer.view(
					view          = "simpleview",
					cache         = true,
					cacheTimeout  = "5",
					cacheProvider = "default"
				);
				var results2 = renderer.view(
					view          = "simpleview",
					cache         = true,
					cacheTimeout  = "5",
					cacheProvider = "default"
				);
				expect( results ).toBe( results2 );
			} );

			it( "can render external views", function(){
				var results = renderer.externalView( "/cbtestharness/external/testViews/externalview" );
				expect( results ).toInclude( "external" );
			} );

			it( "can render external views with caching parameters", function(){
				var results = renderer.externalView(
					view         = "/cbtestharness/external/testViews/externalview",
					cache        = "true",
					cacheTimeout = "5"
				);
				var results2 = renderer.externalView(
					view         = "/cbtestharness/external/testViews/externalview",
					cache        = "true",
					cacheTimeout = "5"
				);
				expect( results ).toBe( results2 );
			} );

			it( "can render external views with different caching parameters", function(){
				results = renderer.externalView(
					view          = "/cbtestharness/external/testViews/externalview",
					cache         = "true",
					cacheTimeout  = "5",
					cacheProvider = "default"
				);
				results2 = renderer.externalView(
					view          = "/cbtestharness/external/testViews/externalview",
					cache         = "true",
					cacheTimeout  = "5",
					cacheProvider = "default"
				);
				expect( results ).toBe( results2 );
			} );

			it( "can render external views with view caching turned off", function(){
				renderer.$property( "viewCaching", "variables", false );
				renderer.getTemplateCache().clearAllViews();
				var results = renderer.externalView(
					view         = "/cbtestharness/external/testViews/externalview",
					cache        = "true",
					cacheTimeout = "5"
				);
				var results2 = renderer.externalView(
					view         = "/cbtestharness/external/testViews/externalview",
					cache        = "true",
					cacheTimeout = "5"
				);
				expect( results ).notToBe( results2 );
			} );

			it( "can render views with view caching turned off", function(){
				renderer.$property( "viewCaching", "variables", false );
				renderer.getTemplateCache().clearAllViews();
				var results = renderer.view(
					view          = "simpleview",
					cache         = true,
					cacheTimeout  = "5",
					cacheProvider = "default"
				);
				var results2 = renderer.view(
					view          = "simpleview",
					cache         = true,
					cacheTimeout  = "5",
					cacheProvider = "default"
				);
				expect( results ).notToBe( results2 );
			} );

			it( "can render a layout without changing the request context", function(){
				var event = getRequestContext();
				event.overrideEvent( "Main.index" );
				var beforeView = event.getCurrentView();
				var results    = renderer.layout( layout = "Simple", view = "simpleview" );
				expect( event.getCurrentView() ).toBe( beforeView );
			} );

			it( "can render implicit views", function(){
				var event = getRequestContext();
				event.overrideEvent( "main.index" );
				event.setPrivateValue( "welcomeMessage", "Welcome to ColdBox!" );
				var beforeView = event.getCurrentView();
				expect( beforeView ).toBe( "" );
				var results = renderer.layout();
				expect( event.getCurrentView() ).toBe( "main/index" );
			} );


			describe( "Discovery Cache", function(){
				it( "viewDiscoveryCaching setting defaults to true", function(){
					expect( getController().getSetting( "viewDiscoveryCaching" ) ).toBeTrue();
				} );

				it( "locateView caches path results when viewDiscoveryCaching is true", function(){
					renderer.$property( "locateViewCache", "variables", {} );
					renderer.$property( "isDiscoveryCaching", "variables", true );
					var path1 = renderer.locateView( "simpleview" );
					var path2 = renderer.locateView( "simpleview" );
					expect( path1 ).toBe( path2 );
					expect( path1 ).toInclude( "simpleview" );
					expect( structCount( renderer.getLocateViewCache() ) ).toBeGT( 0 );
				} );

				it( "locateLayout caches path results when viewDiscoveryCaching is true", function(){
					renderer.$property( "locateLayoutCache", "variables", {} );
					renderer.$property( "isDiscoveryCaching", "variables", true );
					var path1 = renderer.locateLayout( "Main" );
					var path2 = renderer.locateLayout( "Main" );
					expect( path1 ).toBe( path2 );
					expect( path1 ).toInclude( "Main" );
					expect( structCount( renderer.getLocateLayoutCache() ) ).toBeGT( 0 );
				} );

				it( "expandPathCache is always populated regardless of viewDiscoveryCaching", function(){
					renderer.$property( "expandPathCache", "variables", {} );
					renderer.$property( "isDiscoveryCaching", "variables", false );
					renderer.locateView( "simpleview" );
					expect( structCount( renderer.getExpandPathCache() ) ).toBeGT( 0 );
				} );

				it( "does not populate locateViewCache when viewDiscoveryCaching is false", function(){
					renderer.$property( "isDiscoveryCaching", "variables", false );
					renderer.$property( "locateViewCache", "variables", {} );
					renderer.locateView( "simpleview" );
					expect( structCount( renderer.getLocateViewCache() ) ).toBe( 0 );
				} );

				it( "does not populate locateLayoutCache when viewDiscoveryCaching is false", function(){
					renderer.$property( "isDiscoveryCaching", "variables", false );
					renderer.$property( "locateLayoutCache", "variables", {} );
					renderer.locateLayout( "Main" );
					expect( structCount( renderer.getLocateLayoutCache() ) ).toBe( 0 );
				} );

				it( "discoverViewPaths populates viewsRefMap when viewDiscoveryCaching is true", function(){
					renderer.$property( "viewsRefMap", "variables", {} );
					renderer.$property( "isDiscoveryCaching", "variables", true );
					renderer.discoverViewPaths( view : "simpleview", module : "", explicitModule : false );
					expect( structCount( renderer.$getProperty( "viewsRefMap", "variables" ) ) ).toBeGT( 0 );
				} );
			} );

			feature( "ColdBox can render view collections", function(){
				beforeEach( function( currentSpec ){
					aUsers = [
						{ id : createUUID(), name : "luis" },
						{ id : createUUID(), name : "alexia" },
						{ id : createUUID(), name : "lucas" }
					];
				} );

				given( "Default options", function(){
					then( "it can render the template with the collection", function(){
						var results = renderer.view( view: "tags/user", collection: aUsers );
						var htmlDoc = xmlParse( "<root>#results#</root>" );
						expect( htmlDoc.root.xmlChildren ).toHaveLength( 3 );

						expect( htmlDoc.root.xmlChildren[ 1 ].xmlattributes[ "data-total" ] ).toBe( 3 );
						expect( htmlDoc.root.xmlChildren[ 1 ].xmlattributes[ "data-row" ] ).toBe( 1 );

						expect( results )
							.toInclude( "luis" )
							.toInclude( "alexia" )
							.toInclude( "lucas" );
					} );
				} );

				given( "a collection delimiter", function(){
					then( "it can render the template with the collection", function(){
						var results = renderer.view(
							view           : "tags/user",
							collection     : aUsers,
							collectionDelim= "<hr/>"
						);
						var htmlDoc = xmlParse( "<root>#results#</root>" );
						expect( htmlDoc.root.xmlChildren ).toHaveLength( 5 );
						expect( results )
							.toInclude( "luis" )
							.toInclude( "alexia" )
							.toInclude( "lucas" );
					} );
				} );

				given( "max rows of 1", function(){
					then( "it can render the template with the collection", function(){
						var results = renderer.view(
							view             : "tags/user",
							collection       : aUsers,
							collectionMaxRows: 1
						);
						var htmlDoc = xmlParse( "<root>#results#</root>" );

						expect( htmlDoc.root.xmlChildren[ 1 ].xmlattributes[ "data-total" ] ).toBe( 1 );
						expect( htmlDoc.root.xmlChildren[ 1 ].xmlattributes[ "data-row" ] ).toBe( 1 );
						expect( htmlDoc.root.xmlChildren ).toHaveLength( 1 );
						expect( results ).toInclude( "luis" );
					} );
				} );

				given( "a collection alias", function(){
					then( "it can render the template with the collection", function(){
						var results = renderer.view(
							view        : "tags/member",
							collection  : aUsers,
							collectionAs: "member"
						);
						var htmlDoc = xmlParse( "<root>#results#</root>" );
						expect( htmlDoc.root.xmlChildren ).toHaveLength( 3 );

						expect( htmlDoc.root.xmlChildren[ 1 ].xmlattributes[ "data-total" ] ).toBe( 3 );
						expect( htmlDoc.root.xmlChildren[ 1 ].xmlattributes[ "data-row" ] ).toBe( 1 );

						expect( results )
							.toInclude( "luis" )
							.toInclude( "alexia" )
							.toInclude( "lucas" );
					} );
				} );
			} );
		} );
	}

}
