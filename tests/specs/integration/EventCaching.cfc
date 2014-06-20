/*******************************************************************************
*	Integration Test as BDD (CF10+ or Railo 4.1 Plus)
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
component extends="coldbox.system.testing.BaseTestCase" appMapping="/cbTestHarness"{

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

		describe( "Event Caching", function(){

			beforeEach(function( currentSpec ){
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			});
			afterEach(function( currentSpec ){
				structDelete( url, "format" );
			});

			it( "can do cached events", function(){
				var event = execute( event="eventcaching", renderResults=true );
				var prc = event.getCollection(private=true);

				expect( prc.cbox_eventCacheableEntry ).toBeStruct();
			});

			var formats = [ "json", "xml", "pdf" ];
			for( var thisFormat in formats ){
				it( "can do #thisFormat# cached events", function(){
					url.format = "#thisFormat#";
					var event = execute( event="eventcaching", renderResults=true );
					var prc = event.getCollection(private=true);

					expect( prc.cbox_eventCacheableEntry ).toBeStruct();
					expect( prc.cbox_renderData.contenttype ).toMatch( thisFormat );
				});
			}

		});

	}

}