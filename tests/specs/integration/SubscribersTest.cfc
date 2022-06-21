component extends="tests.resources.BaseIntegrationTest" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();
		// do your own stuff here
	}

	function afterAll(){
		// do your own stuff here
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "Subscribers Tests", function(){
			beforeEach( function( currentSpec ){
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			} );

			it( "will throw a 400 error", function(){
				var event    = post( route = "/subscribers/create", params = {} );
				var response = event.getPrivateValue( "response" );
				debug( response.getDataPacket() );
				expect( response.getError() ).toBeTrue();
				expect( response.getStatusCode() ).toBe( 400 );
			} );
		} );
	}

}
