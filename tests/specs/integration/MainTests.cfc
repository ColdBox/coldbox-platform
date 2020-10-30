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

			xit( "can render the cache panel", function(){
				// Why can't I just call GET() ACF, why do you make things hard!
				var event = this.request( route = "main/cachePanel" );
				expect( event.getRenderedContent() ).toInclude( "cachebox_cache" );
			} );

			it( "can handle invalid events", function(){
				var event = execute( event = "invalid:bogus.index", renderResults = true );
				expect( event.getValue( "cbox_rendered_content" ) ).toInclude( "Invalid Page" );
			} );

			it( "can handle invalid onInvalidEvent handlers", function(){
				var originalInvalidEventHandler = getController().getSetting( "invalidEventHandler" );
				getController().setSetting( "invalidEventHandler", "notEvenAnAction" );
				try {
					getController().getHandlerService().onConfigurationLoad();
					execute( event = "invalid:bogus.index", renderResults = true );
					fail( "The event handler was invalid and should have thrown an exception" );
				} catch ( HandlerService.InvalidEventHandlerException e ) {
					expect( e.message ).toInclude( "The invalidEventHandler event is also invalid" );
				} finally {
					getController().setSetting( "invalidEventHandler", originalInvalidEventHandler );
					getController().getHandlerService().onConfigurationLoad();
				}
			} );
		} );
	}

}
