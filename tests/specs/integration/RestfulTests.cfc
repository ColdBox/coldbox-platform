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
	extends="coldbox.system.testing.BaseTestCase"
	appMapping="/cbTestHarness"
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
		describe( "ColdBox REST", function() {
			beforeEach( function(currentSpec) {
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			} );

			it( "can handle allowed HTTP methods in action annotations", function() {
				prepareMock( getRequestContext() ).$( "getHTTPMethod", "POST" );

				var event = execute( event = "main.actionAllowedMethod", renderResults = true );
				expect( event.getRenderedContent() ).toBe( "invalid http: main.actionAllowedMethod" );
			} );

			it( "can handle onInvalidHTTPMethod exceptions", function() {
				prepareMock( getRequestContext() ).$( "getHTTPMethod", "GET" );
				var event = execute( event = "rendering.testHTTPMethod", renderResults = true );
				expect( event.getValue( "cbox_rendered_content" ) ).toBe( "Yep, onInvalidHTTPMethod works!" );
			} );


			var formats = [ "json" ];
			// var formats = [ "json", "xml", "pdf", "wddx", "html" ];
			it( "can do #formats.toString()# data renderings", function() {
				for ( var thisFormat in formats ) {
					getRequestContext().setValue( "format", thisFormat );
					var event = execute( event = "rendering.index", renderResults = true );
					var prc = event.getCollection( private = true );
					expect( prc.cbox_renderData ).toBeStruct();
					expect( prc.cbox_renderData.contenttype ).toMatch( thisFormat );
				}
			} );

			it( "can redirect only for html formats with the `formatsRedirect` parameter", function() {
				getRequestContext().setValue( "format", "json" );
				var event = execute( event = "rendering.redirect", renderResults = true );
				var rc = event.getCollection();
				var prc = event.getCollection( private = true );
				expect( rc ).notToHaveKey( "relocate_event" );
				expect( prc.cbox_renderData ).toBeStruct();
				expect( prc.cbox_renderData.contenttype ).toMatch( "json" );

				getRequestContext().setValue( "format", "html" );
				var event = execute( event = "rendering.redirect", renderResults = true );
				var rc = event.getCollection();
				expect( rc ).toHaveKey( "relocate_event" );
				expect( rc[ "relocate_event" ] ).toBe( "Main.index" );
			} );
		} );
	}

}
