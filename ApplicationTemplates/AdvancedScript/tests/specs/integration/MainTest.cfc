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

	<cffunction name="testdoSomething">
		<cfscript>
		var event = "";

		//Place any variables on the form or URL scope to test the handler.
		//URL.name = "luis"
		event = execute("main.doSomething");

		// debug(event.getCollection());

		//Do your asserts below for setnextevent you can test for a setnextevent boolean flag
		$assert.isEqual( "main.index", event.getValue( "setnextevent", "" ), "Relocation Test" );
		</cfscript>
	</cffunction>

	<cffunction name="testonAppInit">
		<cfscript>
		var event = "";

		//Place any variables on the form or URL scope to test the handler.
		//URL.name = "luis"
		event = execute( "main.onAppInit" );

		//Do your asserts below

		</cfscript>
	</cffunction>

	<cffunction name="testonRequestStart">
		<cfscript>
		var event = "";

		//Place any variables on the form or URL scope to test the handler.
		//URL.name = "luis"
		event = execute( "main.onRequestStart" );

		//Do your asserts below

		</cfscript>
	</cffunction>

	<cffunction name="testonRequestEnd">
		<cfscript>
		var event = "";

		//Place any variables on the form or URL scope to test the handler.
		//URL.name = "luis"
		event = execute( "main.onRequestEnd" );

		//Do your asserts below

		</cfscript>
	</cffunction>

	<cffunction name="testSessionStart" returntype="void" output="false">
		<cfscript>
		var event = "";

		//Place any variables on the form or URL scope to test the handler.
		//URL.name = "luis"
		event = execute( "main.onSessionStart" );

		//Do your asserts below

		</cfscript>
	</cffunction>

	<cffunction name="testSessionEnd" returntype="void" output="false">
		<cfscript>
		var event = "";
		var sessionReference = "";

		//Place a fake session structure here, it mimics what the handler receives
		URL.sessionReference = structnew();
		URL.applicationReference = structnew();

		event = execute( "main.onSessionEnd" );

		//Do your asserts below

		</cfscript>
	</cffunction>

	<cffunction name="testonException" returntype="void" output="false">
		<cfscript>
		//You need to create an exception bean first and place it on the request context FIRST as a setup.
		var exceptionBean = createMock( "coldbox.system.web.context.ExceptionBean" )
			.init( erroStruct=structnew(), extramessage="My unit test exception", extraInfo="Any extra info, simple or complex" );

		// Attach to request
		getRequestContext().setValue( name="exception", value=exceptionBean, private=true );

		var event = "";

		//TEST EVENT EXECUTION
		event = execute( "main.onException" );

		//Do your asserts HERE

		</cfscript>
	</cffunction>

</cfcomponent>