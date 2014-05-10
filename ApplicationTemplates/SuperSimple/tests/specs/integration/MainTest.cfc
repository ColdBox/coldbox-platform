<!------------------------------------------------------------------------------------------------
	Integration Test as xUnit

	Extends the integration class: coldbox.system.testing.BaseTestCase

	so you can test your ColdBox application headlessly. The 'appMapping' points by default to 
	the '/root' mapping created in the test folder Application.cfc.  Please note that this 
	Application.cfc must mimic the real one in your root, including ORM settings if needed.

	CFComponent Available Annotations
	* 'displayname' is used to name the test suite
	* 'asyncAll' is used to execute the tests asynchronously in parallel, make sure everything is varscoped

	The 'execute()' method is used to execute a ColdBox event, with the following arguments
	* event : the name of the event
	* private : if the event is private or not
	* prePostExempt : if the event needs to be exempt of pre post interceptors
	* eventArguments : The struct of args to pass to the event
	* renderResults : Render back the results of the event
-------------------------------------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseTestCase" appMapping="/root" displayName="Main Handler Events">
	
	<cffunction name="setUp">
		<cfscript>
		// Call the super setup method to setup the app.
		super.setup();
		
		// Any preparation work will go here for this test.
		</cfscript>
	</cffunction>
	
	<cffunction name="testIndex">
		<cfscript>
		var event = "";
		
		// Place any variables on the form or URL scope to test the handler event
		// URL.name = "luis"
		event = execute( event="main.index", renderResults=true );
		
		//debug(event.getCollection());
		
		//Do your asserts below
		$assert.isEqual( "Welcome to ColdBox!", event.getValue( "welcomeMessage", "", true ) );
			
		</cfscript>
	</cffunction>

</cfcomponent>