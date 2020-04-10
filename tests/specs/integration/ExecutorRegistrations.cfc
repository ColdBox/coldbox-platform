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
 extends   ="tests.resources.BaseIntegrationTest"
{

 /*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "Application configuration executor registration", function(){
			beforeEach( function( currentSpec ){
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			} );

			story( "I want to register executors in my app config", function(){
				then( "it should register them upon startup", function(){
						var e = this.get( event = "main.index" );
						expect( getController().getSetting( "executors" ) ).notToBeEmpty();
						expect( getInstance( "AsyncManager@coldbox" ).hasExecutor( "simpleTaskRunner" ) ).toBeTrue();
						expect( getInstance( "AsyncManager@coldbox" ).hasExecutor( "scheduledTasks" ) ).toBeTrue();
				} );
			} );

		} );
	}

}
