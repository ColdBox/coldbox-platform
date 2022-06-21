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
				var results = renderer.renderView(
					view         = "simpleview",
					cache        = true,
					cacheTimeout = "5"
				);
				// debug( results );

				var results2 = renderer.renderView(
					view        = "simpleview",
					cache       = true,
					acheTimeout = "5"
				);
				expect( results ).toBe( results2 );
			} );

			it( "can render views with different caching providers", function(){
				var results = renderer.renderView(
					view          = "simpleview",
					cache         = true,
					cacheTimeout  = "5",
					cacheProvider = "default"
				);
				var results2 = renderer.renderView(
					view          = "simpleview",
					cache         = true,
					cacheTimeout  = "5",
					cacheProvider = "default"
				);
				expect( results ).toBe( results2 );
			} );

			it( "can render external views", function(){
				var results = renderer.renderExternalView( "/cbtestharness/external/testViews/externalview" );
				expect( results ).toInclude( "external" );
			} );

			it( "can render external views with caching parameters", function(){
				var results = renderer.renderExternalView(
					view         = "/cbtestharness/external/testViews/externalview",
					cache        = "true",
					cacheTimeout = "5"
				);
				var results2 = renderer.renderExternalView(
					view         = "/cbtestharness/external/testViews/externalview",
					cache        = "true",
					cacheTimeout = "5"
				);
				expect( results ).toBe( results2 );
			} );

			it( "can render external views with different caching parameters", function(){
				results = renderer.renderExternalView(
					view          = "/cbtestharness/external/testViews/externalview",
					cache         = "true",
					cacheTimeout  = "5",
					cacheProvider = "default"
				);
				results2 = renderer.renderExternalView(
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
				var results = renderer.renderExternalView(
					view         = "/cbtestharness/external/testViews/externalview",
					cache        = "true",
					cacheTimeout = "5"
				);
				var results2 = renderer.renderExternalView(
					view         = "/cbtestharness/external/testViews/externalview",
					cache        = "true",
					cacheTimeout = "5"
				);
				expect( results ).notToBe( results2 );
			} );

			it( "can render views with view caching turned off", function(){
				renderer.$property( "viewCaching", "variables", false );
				renderer.getTemplateCache().clearAllViews();
				var results = renderer.renderView(
					view          = "simpleview",
					cache         = true,
					cacheTimeout  = "5",
					cacheProvider = "default"
				);
				var results2 = renderer.renderView(
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
		} );
	}

}
