component extends="coldbox.system.testing.BaseTestCase" {

	function run(){
		describe( "BaseTestCase", function(){
			it( "can set custom test headers", function(){
				setup();
				var event = get( route = "/base-test-case/headers", headers = { "Origin" : "example.com" } );
				expect( event.getStatusCode() ).toBe( 200 );
				var data = event.getRenderData().data;
				expect( structCount( data ) ).toBeGT( 1 );
				expect( data ).toHaveKey( "Origin" );
				expect( data[ "Origin" ] ).toBe( "example.com" );
			} );
		} );
	}

}
