component extends="tests.resources.BaseIntegrationTest" {

	function beforeAll(){
		// We need to make sure we start fresh on this test.
		shutdownColdBox();
		// Super size me!
		super.beforeAll();
	}

	function afterAll(){
		super.afterAll();
		shutdownColdBox();
	}

	function run(){
		describe( "subdomain routing", function(){
			beforeEach( function(){
				setup();
			} );

			it( "can match on a specific domain", function(){
				writeDump( var = "*****> Testing: subdomain-routing.dev", output = "console" );

				var event = execute( route: "/", domain: "subdomain-routing.dev" );
				var rc    = event.getCollection();
				expect( rc ).toHaveKey( "event" );
				expect( rc.event ).toBe( "subdomain.index" );
			} );

			it( "skips if the domain is not matched", function(){
				var event = execute( route: "/", domain: "not-the-correct-domain.dev" );
				var rc    = event.getCollection();
				expect( rc ).toHaveKey( "event" );
				expect( rc.event ).toBe( "main.index" );
			} );

			it( "can match on a domain with wildcards", function(){
				var event = execute( route: "/", domain: "luis.forgebox.dev" );
				var rc    = event.getCollection();
				expect( rc ).toHaveKey( "event" );
				expect( rc.event ).toBe( "subdomain.show" );
			} );

			it( "provides any matched values in the domain in the rc", function(){
				var event = execute( route: "/", domain: "luis.forgebox.dev" );
				var rc    = event.getCollection();
				expect( rc ).toHaveKey( "username" );
				expect( rc.username ).toBe( "luis" );
			} );
		} );
	}

}
