/*******************************************************************************
 *	Integration Test as BDD
 *
 *	Extends the integration class: coldbox.system.testing.BaseTestCase
 *
 *	so you can test your ColdBox application headlessly. The 'appMapping' points by default to
 *	the '/root' mapping created in the test folder Application.cfc.  Please note that this
 *	Application.cfc must mimic the real one in your root, including ORM settings if needed.
 *
 *	The 'execute()' method is used to execute a ColdBox event, with the following arguments
 *	* event : the name of the event
 *	* private : if the event is private or not
 *	* prePostExempt : if the event needs to be exempt of pre post interceptors
 *	* eventArguments : The struct of args to pass to the event
 *	* renderResults : Render back the results of the event
 *******************************************************************************/
component
	extends="tests.resources.BaseIntegrationTest"
{

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
				expect( event.getValue( "cbox_rendered_content" ) ).toBe( "<h1>Invalid Page</h1>
" );
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
