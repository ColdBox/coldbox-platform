component extends="tests.resources.BaseIntegrationTest" {

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Request Services", () => {
			beforeEach( ( currentSpec ) =>{
				setup();
				getController()
					.getRoutingService()
					.getRouter()
					.setEnabled( false );
				requestService = getController().getRequestService();
			} );

			afterEach( ( currentSpec ) =>{
				getController()
					.getRoutingService()
					.getRouter()
					.setEnabled( true );
			} );

			it( "can capture requests", () => {
				var today = now();

				/* Setup test variables */
				form.name  = "luis majano";
				form.event = "ehGeneral.dspHome,movies.list";

				url.name  = "pio majano";
				url.today = today;

				/* Capture the request */
				var context = requestService.requestCapture();

				// debug(context.getCollection());

				/* Tests */
				try {
					expect( context ).toBeComponent();
					expect( dateCompare( url.today, context.getValue( "today" ), "s" ) ).toBe(
						0,
						"dates should match to the second"
					);
					expect( url.name ).toBe( context.getValue( "name" ) );
					expect( context.valueExists( "event" ) ).toBeTrue();
				} finally {
					structDelete( form, "event" );
					structDelete( url, "event" );
				}
			} );

			it( "can capture a json body", () => {
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

			it( "can test the default event setup", () =>{
				/* Setup test variables */
				form.event = url.event = "photos.index";

				/* Catpure the request */
				structDelete( request, "cb_requestContext" );
				var context = requestService.requestCapture();

				/* Tests */
				try {
					expect( context ).toBeComponent();
					expect( url.event ).toBe( context.getCurrentEvent() );
				} finally {
					structDelete( form, "event" );
					structDelete( url, "event" );
				}
			} );

			it( "can create and check for context in the request scope", () =>{
				var context = requestService.getContext();
				expect( context ).toBeComponent();
				expect( requestService.contextExists() ).toBeTrue();

				structDelete( request, "cb_requestContext" );
				expect( requestService.contextExists() ).toBeFalse();

				requestService.setContext( context );
				expect( requestService.contextExists() ).toBeTrue();
				expect( request ).toHaveKey( "cb_requestContext" );
			} );

			it( "skips getHTTPContent when jsonPayloadToRC is disabled", () =>{
				// Temporarily disable jsonPayloadToRC
				var originalValue = getController().getSetting( "jsonPayloadToRC" );
				getController().setSetting( "jsonPayloadToRC", false );
				// Re-run onConfigurationLoad to pick up the cached setting
				requestService.onConfigurationLoad();

				// Mock context that tracks getHTTPContent calls
				var callCount = 0;
				var mockContext = prepareMock( requestService.getContext() )
					.$( "getHTTPContent" )
					.$callback( ( boolean json = false ) => {
						callCount++;
						return '{"shouldNotBeParsed":true}';
					} );
				request[ "cb_requestContext" ] = mockContext;

				// Capture the request
				var context = requestService.requestCapture();

				// getHTTPContent should NOT have been called since jsonPayloadToRC is false
				expect( callCount ).toBe( 0, "getHTTPContent should not be called when jsonPayloadToRC is false" );
				expect( context.valueExists( "shouldNotBeParsed" ) ).toBeFalse();

				// Restore original value
				getController().setSetting( "jsonPayloadToRC", originalValue );
				requestService.onConfigurationLoad();
			} );

			it( "caches getHTTPContent result to avoid redundant calls", () =>{
				// Ensure jsonPayloadToRC is enabled
				var originalValue = getController().getSetting( "jsonPayloadToRC" );
				getController().setSetting( "jsonPayloadToRC", true );
				requestService.onConfigurationLoad();

				// Mock context that tracks getHTTPContent calls
				var callCount = 0;
				var payload   = { "cached" : "true", "name" : "test" };
				var mockContext = prepareMock( requestService.getContext() )
					.$( "getHTTPContent" )
					.$callback( ( boolean json = false ) => {
						callCount++;
						if ( json ) {
							return payload;
						}
						return serializeJSON( payload );
					} );
				request[ "cb_requestContext" ] = mockContext;

				// Capture the request
				var context = requestService.requestCapture();

				// getHTTPContent should be called exactly twice: once for raw content, once for JSON parsed
				// (not 3 times as before the optimization)
				expect( callCount ).toBeLTE( 2, "getHTTPContent should be called at most 2 times (cached raw + json parse)" );
				expect( context.valueExists( "cached" ) ).toBeTrue();
				expect( context.getValue( "cached" ) ).toBe( "true" );

				// Restore original value
				getController().setSetting( "jsonPayloadToRC", originalValue );
				requestService.onConfigurationLoad();
			} );

			it( "uses cached defaultEvent from onConfigurationLoad", () =>{
				// Capture a request with no event in FORM/URL to trigger default event logic
				structDelete( form, "event" );
				structDelete( url, "event" );
				structDelete( request, "cb_requestContext" );

				var context = requestService.requestCapture();

				// The default event should be correctly applied from the cached variable
				var expectedDefault = getController().getSetting( "DefaultEvent" );
				expect( context.getCurrentEvent() ).toBe( expectedDefault );
			} );
		} );
	}

}
