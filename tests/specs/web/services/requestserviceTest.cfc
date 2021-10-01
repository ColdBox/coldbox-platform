component extends="tests.resources.BaseIntegrationTest" {

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Request Services", function(){
			beforeEach( function( currentSpec ){
				setup();
				getController()
					.getRoutingService()
					.getRouter()
					.setEnabled( false );
				requestService = getController().getRequestService();
			} );

			afterEach( function( currentSpec ){
				getController()
					.getRoutingService()
					.getRouter()
					.setEnabled( true );
			} );

			it( "can capture requests", function(){
				var today = now();

				/* Setup test variables */
				form.name  = "luis majano";
				form.event = "ehGeneral.dspHome,movies.list";

				url.name  = "pio majano";
				url.today = today;

				/* Catpure the request */
				var context = requestService.requestCapture();

				// debug(context.getCollection());

				/* Tests */
				expect( context ).toBeComponent();
				expect( url.today ).toBe( context.getValue( "today" ) );
				expect( url.name ).toBe( context.getValue( "name" ) );
				expect( context.valueExists( "event" ) ).toBeTrue();
			} );

			it( "can capture a json body", function(){
				var mockContext = prepareMock( requestService.getContext() )
					.$( "getHTTPContent" )
					.$callback( function( boolean json = false ){
						var payload = { "fullName" : "Jon Clausen", "type" : "JSON" };

						if ( json ) {
							return payload;
						} else {
							return serializeJSON( payload );
						}
					} );
				// Mock it
				request[ "cb_requestContext" ] = mockContext;

				/* Catpure the request */
				var context = requestService.requestCapture();

				/* Tests */
				expect( context ).toBeComponent();
				expect( context.valueExists( "fullName" ) ).toBeTrue();
				expect( context.valueExists( "type" ) ).toBeTrue();
				expect( context.getValue( "type" ) ).toBe( "JSON" );
			} );

			it( "can test the default event setup", function(){
				/* Setup test variables */
				form.event = url.event = "photos.index";

				/* Catpure the request */
				structDelete( request, "cb_requestContext" );
				var context = requestService.requestCapture();

				/* Tests */
				expect( context ).toBeComponent();
				expect( url.event ).toBe( context.getCurrentEvent() );
			} );

			it( "can create and check for context in the request scope", function(){
				var context = requestService.getContext();
				expect( context ).toBeComponent();
				expect( requestService.contextExists() ).toBeTrue();

				structDelete( request, "cb_requestContext" );
				expect( requestService.contextExists() ).toBeFalse();

				requestService.setContext( context );
				expect( requestService.contextExists() ).toBeTrue();
				expect( request ).toHaveKey( "cb_requestContext" );
			} );
		} );
	}

}
