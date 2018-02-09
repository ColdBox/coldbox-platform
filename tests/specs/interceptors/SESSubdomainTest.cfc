component extends="coldbox.system.testing.BaseTestCase" appMapping="/cbTestHarness"{

	function run() {
		describe( "subdomain routing", function() {
            beforeEach( function() {
                setup();
                variables.mockSES = prepareMock( getInterceptor( "SES" ) );
            } );

            it( "can match on a specific domain", function() {
                mockSES
                    .$( "getCGIElement" )
                    .$args( "server_name", getRequestContext() )
                    .$results( "subdomain-routing.dev" );

                var event = execute( route = "/" );

                var rc = event.getCollection();
                expect( rc ).toHaveKey( "event" );
                expect( rc.event ).toBe( "subdomain.index" );
            } );

            it( "skips if the domain is not matched", function() {
                mockSES
                    .$( "getCGIElement" )
                    .$args( "server_name", getRequestContext() )
                    .$results( "not-the-correct-domain.dev" );

                var event = execute( route = "/" );

                var rc = event.getCollection();
                expect( rc ).toHaveKey( "event" );
                expect( rc.event ).toBe( "main.index" );
            } );

            it( "can match on a domain with wildcards", function() {
                mockSES
                    .$( "getCGIElement" )
                    .$args( "server_name", getRequestContext() )
                    .$results( "luis.forgebox.dev" );

                var event = execute( route = "/" );

                var rc = event.getCollection();
                expect( rc ).toHaveKey( "event" );
                expect( rc.event ).toBe( "subdomain.show" );
            } );

            it( "provides any matched values in the domain in the rc", function() {
                mockSES
                    .$( "getCGIElement" )
                    .$args( "server_name", getRequestContext() )
                    .$results( "luis.forgebox.dev" );

                var event = execute( route = "/" );

                var rc = event.getCollection();
                expect( rc ).toHaveKey( "username" );
                expect( rc.username ).toBe( "luis" );
            } );
        } );
	}
}
