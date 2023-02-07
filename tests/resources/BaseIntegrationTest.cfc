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

	// Load on first test
	this.loadColdBox   = true;
	// Never unload until the request dies
	this.unloadColdBox = false;

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){

		// Cleanup
		cleanupColdBoxRequestData();
		structDelete( url, "event" );
		structDelete( url, "format" );

		// Super size me!
		super.beforeAll();

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

	/**
	 * Cleanup for invalid handler on all tests
	 * @beforeEach
	 */
	function cleanupColdBoxRequestData(){
		structDelete( request, "_lastInvalidEvent" );
		structDelete( request, "cbTransientDICache" )
	}

	function isAdobe(){
		return !server.keyExists( "lucee" );
	}

	function isLucee(){
		return server.keyExists( "lucee" );
	}

	function shutdownColdBox(){
		getColdBoxVirtualApp().shutdown();
	}

}
