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
				r = prepareMock( getController().getRenderer() );
			} );

			it( "can render views with caching parameters", function(){
				var results = r.renderView(
					view         = "simpleview",
					cache        = true,
					cacheTimeout = "5"
				);
				// debug( results );

				var results2 = r.renderView(
					view        = "simpleview",
					cache       = true,
					acheTimeout = "5"
				);
				expect( results ).toBe( results2 );
			} );

			it( "can render views with different caching providers", function(){
				var results = r.renderView(
					view          = "simpleview",
					cache         = true,
					cacheTimeout  = "5",
					cacheProvider = "default"
				);
				var results2 = r.renderView(
					view          = "simpleview",
					cache         = true,
					cacheTimeout  = "5",
					cacheProvider = "default"
				);
				expect( results ).toBe( results2 );
			} );

			it( "can render external views", function(){
				var results = r.renderExternalView( "/cbtestharness/external/testViews/externalview" );
				expect( results ).toInclude( "external" );
			} );

			it( "can render external views with caching parameters", function(){
				var results = r.renderExternalView(
					view         = "/cbtestharness/external/testViews/externalview",
					cache        = "true",
					cacheTimeout = "5"
				);
				var results2 = r.renderExternalView(
					view         = "/cbtestharness/external/testViews/externalview",
					cache        = "true",
					cacheTimeout = "5"
				);
				expect( results ).toBe( results2 );
			} );

			it( "can render external views with different caching parameters", function(){
				results = r.renderExternalView(
					view          = "/cbtestharness/external/testViews/externalview",
					cache         = "true",
					cacheTimeout  = "5",
					cacheProvider = "default"
				);
				results2 = r.renderExternalView(
					view          = "/cbtestharness/external/testViews/externalview",
					cache         = "true",
					cacheTimeout  = "5",
					cacheProvider = "default"
				);
				expect( results ).toBe( results2 );
			} );

			it( "can render external views with view caching turned off", function(){
				r.$property( "viewCaching", "variables", false );
				r.getTemplateCache().clearAllViews();
				var results = r.renderExternalView(
					view         = "/cbtestharness/external/testViews/externalview",
					cache        = "true",
					cacheTimeout = "5"
				);
				var results2 = r.renderExternalView(
					view         = "/cbtestharness/external/testViews/externalview",
					cache        = "true",
					cacheTimeout = "5"
				);
				expect( results ).notToBe( results2 );
			} );

			it( "can render views with view caching turned off", function(){
				r.$property( "viewCaching", "variables", false );
				r.getTemplateCache().clearAllViews();
				var results = r.renderView(
					view          = "simpleview",
					cache         = true,
					cacheTimeout  = "5",
					cacheProvider = "default"
				);
				var results2 = r.renderView(
					view          = "simpleview",
					cache         = true,
					cacheTimeout  = "5",
					cacheProvider = "default"
				);
				expect( results ).notToBe( results2 );
			} );
		} );
	}

}
