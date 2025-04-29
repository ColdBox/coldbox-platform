component extends="tests.resources.BaseIntegrationTest" autowire {

	property name="logger" inject="logbox:logger:{this}";

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "Implicit Handlers", function(){
			beforeEach( function( currentSpec ){
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			} );

			it( "can handle autowire annotations for tests", function(){
				expect( variables.logger ).toBeComponent();
			} );

			it( "reads metadata for the test and stores it", function(){
				expect( variables.metadata ).notToBeEmpty();
			} );

			it( "can handle invalid events", function(){
				var event = execute( event = "invalid:bogus.index", renderResults = true );
				expect( event.getValue( "cbox_rendered_content" ) ).toInclude( "Invalid Page" );
			} );
		} );
	}

}
