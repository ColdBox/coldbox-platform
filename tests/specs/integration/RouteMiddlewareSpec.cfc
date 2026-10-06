component extends="tests.resources.BaseIntegrationTest" {

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "Route Middleware in Integration Tests", function(){
			beforeEach( function( currentSpec ){
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			} );

			story( "I want route middleware to run when I execute a route in a test", function(){
				given( "a route with a preProcess middleware that blocks the request", function(){
					then( "it should block it, exactly like it does in a real request", function(){
						var e          = this.get( "routeMiddleware/blocked" );
						var renderData = e.getRenderData();
						expect( renderData.statusCode ).toBe( 403 );
						expect( renderData.data ).toBe( "blocked by middleware" );
					} );
				} );

				given( "a route with preProcess and postProcess middleware", function(){
					then( "it should run both of them around the event", function(){
						var e = this.get( "routeMiddleware/open" );
						expect( e.getPrivateValue( "routeMiddlewarePre", false ) ).toBeTrue();
						expect( e.getPrivateValue( "routeMiddlewarePost", false ) ).toBeTrue();
					} );
				} );

				given( "a route with no middleware", function(){
					then( "it should not run any route middleware", function(){
						var e = this.get( "main/returnTest" );
						expect( e.getPrivateValue( "routeMiddlewarePre", false ) ).toBeFalse();
					} );
				} );
			} );
		} );
	}

}
