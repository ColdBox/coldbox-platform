component
	extends="tests.resources.BaseIntegrationTest"
{

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "Implicit Handlers", function(){
			beforeEach( function( currentSpec ){
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
				// Cleanup for invalid event handlers
				structDelete( request, "_lastInvalidEvent" );
			} );

			it( "can handle invalid events", function(){
				var event = execute( event = "invalid:bogus.index", renderResults = true );
				expect( event.getValue( "cbox_rendered_content" ) ).toInclude( "Invalid Page" );
			} );

		} );
	}

}
