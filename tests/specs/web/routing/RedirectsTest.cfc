component extends="tests.resources.BaseIntegrationTest" {

	function run(){
		describe( "Route Redirects", function(){
			beforeEach( function(){
				setup();
			} );

			it( "can relocate with the default status code", function(){
				var event = execute( route = "/oldRoute" );
				var rc    = event.getCollection();
				expect( rc.relocate_event ).toBe( "/main/redirectTest" );
				expect( rc.relocate_statusCode ).toBe( 301 );
			} );


			it( "can relocate with a custom status code", function(){
				var event = execute( route = "/tempRoute" );
				var rc    = event.getCollection();
				expect( rc.relocate_event ).toBe( "/main/redirectTest" );
				expect( rc.relocate_statusCode ).toBe( 302 );
			} );
		} );
	}

}
