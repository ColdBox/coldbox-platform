/**
 * Covers how the HTML Helper's elixirPath() remembers the paths and manifests it has already looked up.
 */
component extends="tests.resources.BaseIntegrationTest" {

	function run( testResults, testBox ){
		describe( "HTML Helper elixirPath()", function(){
			beforeEach( function( currentSpec ){
				setup();
				htmlhelper             = prepareMock( getInstance( "HTMLHelper@HTMLHelper" ) );
				originalRequestService = htmlhelper.getRequestService();
				// The helper is a singleton, start every spec with nothing remembered
				htmlhelper.$property( "cachedPaths", "variables", {} );
				htmlhelper.$property( "elixirManifests", "variables", {} );
			} );

			afterEach( function( currentSpec ){
				htmlhelper.setRequestService( originalRequestService );
				htmlhelper.$property( "cachedPaths", "variables", {} );
				htmlhelper.$property( "elixirManifests", "variables", {} );
			} );

			it( "gives each module its own path for the same file name", function(){
				runningInModule( "conventionsTest", "modules_app/conventionsTest" );
				var first = htmlhelper.elixirPath( fileName = "js/app.js", useModuleRoot = true );

				runningInModule( "resourcesTest", "modules_app/resourcesTest" );
				var second = htmlhelper.elixirPath( fileName = "js/app.js", useModuleRoot = true );

				expect( first ).toInclude( "conventionsTest" );
				expect( second ).toInclude( "resourcesTest" );
			} );

			it( "returns the same path the second time when the file is not in the manifest", function(){
				runningInModule( "", "" );

				var first  = htmlhelper.elixirPath( "js/notInTheManifest.js" );
				var second = htmlhelper.elixirPath( "js/notInTheManifest.js" );

				expect( first ).toBe( "/includes/js/notInTheManifest.js" );
				expect( second ).toBe( first );
			} );

			it( "reads a manifest file only once", function(){
				runningInModule( "", "" );

				expect( htmlhelper.elixirPath( "js/jquery.js" ) ).toBe( "/includes/js/jquery.1.js" );

				// Change the manifest that was loaded into memory. If the helper reads the
				// file from disk again on the next lookup, this change is lost.
				var manifests = htmlhelper.$getProperty( "elixirManifests" );
				expect( manifests ).toHaveLength( 1 );
				for ( var key in manifests ) {
					manifests[ key ][ "includes/js/onlyInMemory.js" ] = "/includes/js/onlyInMemory.1.js";
				}

				expect( htmlhelper.elixirPath( "js/onlyInMemory.js" ) ).toBe( "/includes/js/onlyInMemory.1.js" );
			} );
		} );
	}

	/*********************************** HELPERS ***********************************/

	/**
	 * Makes the helper believe the current request is running inside the given module
	 *
	 * @moduleName The module the request is running in, empty for none
	 * @moduleRoot The root path of that module
	 */
	private function runningInModule( required moduleName, required moduleRoot ){
		var mockEvent = createStub()
			.$( "getCurrentModule", arguments.moduleName )
			.$( "getModuleRoot", arguments.moduleRoot );
		htmlhelper.setRequestService( createStub().$( "getContext", mockEvent ) );
	}

}
