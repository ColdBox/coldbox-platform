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
	extends   ="coldbox.system.testing.BaseTestCase"
	appMapping="/cbTestHarness"
{

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();
		// do your own stuff here

		// add custom matchers
		addMatchers( {
			toHavePartialKey : function( expectation, args = {} ){
				// iterate over actual to find key
				for ( var thisKey in arguments.expectation.actual ) {
					if ( findNoCase( arguments.args[ 1 ], thisKey ) ) {
						return true;
					}
				}
				return false;
			}
		} );
	}

	function afterAll(){
		// do your own stuff here
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "Event Caching", function(){
			beforeEach( function( currentSpec ){
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			} );

			afterEach( function( currentSpec ){
				structDelete( url, "format" );
			} );

			it( "can do basic cached events", function(){
				var event = execute( event = "eventcaching", renderResults = true );
				var prc   = event.getPrivateCollection();

				expect( prc.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "provider" );
				expect( prc.cbox_eventCacheableEntry.provider ).toBe( "template" );
				// debug( prc.cbox_eventCacheableEntry );
			} );


			it( "can do cached events with custom provider annotations", function(){
				var event = execute( event = "eventcaching.withProvider", renderResults = true );
				var prc   = event.getPrivateCollection();

				expect( prc.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "provider" );
				expect( prc.cbox_eventCacheableEntry.provider ).toBe( "default" );
			} );

			var formats = [ "json", "xml", "pdf" ];
			for ( var thisFormat in formats ) {
				it(
					title = "can do #thisFormat# cached events",
					data  = { format : thisFormat },
					body  = function( data ){
						getRequestContext().setValue( "format", data.format );
						var event = execute( event = "eventcaching", renderResults = true );
						var prc   = event.getCollection( private = true );

						expect( prc.cbox_eventCacheableEntry ).toBeStruct();
						expect( prc.cbox_renderData.contenttype ).toMatch( data.format );
					}
				);
			}

			describe( "via runEvent()", function(){
				beforeEach( function( currentSpec ){
					cache = prepareMock( getCache( "template" ) );
					cache.clearAllEvents( async = false );
				} );

				it( "can cache with defaults", function(){
					// should not be there, so should be cached now
					var data  = controller.runEvent( event = "eventcaching.widget", cache = true );
					// run again, and get cached data.
					var data2 = controller.runEvent( event = "eventcaching.widget", cache = true );
					// Make sure they match
					expect( data2 ).toBe( data );
				} );

				it( "can cache with suffixes", function(){
					// should not be there, so should be cached now
					var data = controller.runEvent(
						event       = "eventcaching.widget",
						cache       = true,
						cacheSuffix = "bddtesting"
					);
					// run again, and get cached data.
					var data2 = controller.runEvent(
						event       = "eventcaching.widget",
						cache       = true,
						cacheSuffix = "bddtesting"
					);
					// Make sure they match
					expect( data2 ).toBe( data );

					// find key
					var keys = cache.getKeys();
					expect( keys ).toHavePartialKey( "bddtesting" );
				} );

				it( "can cache with provider", function(){
					// should not be there, so should be cached now
					var data = controller.runEvent(
						event         = "eventcaching.widget",
						cache         = true,
						cacheProvider = "default"
					);
					// run again, and get cached data.
					var data2 = controller.runEvent(
						event         = "eventcaching.widget",
						cache         = true,
						cacheProvider = "default"
					);
					// Make sure they match
					expect( data2 ).toBe( data );

					// find key
					var keys = getCache( "default" ).getKeys();
					expect( keys ).toHavePartialKey( "eventcaching.widget" );
				} );

				it( "can cache differently with event arguments", function(){
					// should not be there, so should be cached now
					var data = controller.runEvent(
						event          = "eventcaching.widget",
						cache          = true,
						eventArguments = { widget : true }
					);
					// run again, and get cached data.
					var data2 = controller.runEvent(
						event         = "eventcaching.widget",
						cache         = true,
						cacheProvider = "default"
					);
					// Make sure they match
					expect( data2 ).notToBe( data );
				} );
			} );
		} );
	}

}
