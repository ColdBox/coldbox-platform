<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author                    :	Luis Majano
Date                             :	9/3/2007
Description :
Request service Test
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseTestCase" appMapping="/coldbox/test-harness">
	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		// Call the super setup method to setup the app.
		super.setup();
		</cfscript>
	</cffunction>

	<cffunction name="testRequestCapturesWithNoDecoration" access="public" returntype="void" output="false">
		<cfscript>
		var originalSetting = getcontroller().getSetting( "RequestContextDecorator" );

		getcontroller().setSetting( "RequestContextDecorator", "" );
		testRequestCaptures();
		getcontroller().setSetting( "RequestContextDecorator", originalSetting );
		</cfscript>
	</cffunction>

	<cffunction name="testRequestCaptures" access="public" returntype="void" output="false">
		<cfscript>
		var service       = getController().getRequestService();
		var context       = "";
		var persistStruct = structNew();
		var today         = now();

		/* Setup test variables */
		form.name  = "luis majano";
		form.event = "ehGeneral.dspHome,movies.list";

		url.name  = "pio majano";
		url.today = today;

		/* Catpure the request */
		context = service.requestCapture();

		// debug(context.getCollection());

		/* Tests */
		assertTrue( isObject( context ), "Context Creation" );
		assertTrue( url.today eq context.getValue( "today" ), "URL Append" );
		assertTrue( context.valueExists( "event" ), "Multi-Event Test" );
		</cfscript>
	</cffunction>

	<cffunction name="testRequestCaptureOfJSONBody" access="public" returntype="void" output="false">
		<cfscript>
		getController().setSetting( "jsonPayloadToRC", true );
		var mockContext = prepareMock( getController().getRequestService().getContext() )
			.$( "getHTTPContent" )
			.$callback( function( boolean json = false ){
				var payload = {
					"name" : "Jon Clausen",
					"type" : "JSON"
				};

				if ( json ) {
					return payload;
				} else {
					return serializeJSON( payload );
				}
			} );
		var service = prepareMock( getController().getRequestService() )
			.$( "getContext" )
			.$callback( function(){
				return mockContext;
			} );

		/* Catpure the request */
		context = service.requestCapture();

		debug( context.getCollection() );

		/* Tests */
		assertTrue( isObject( context ), "Context Creation" );
		assertTrue( context.valueExists( "name" ), "JSON Append" );
		assertTrue( context.valueExists( "type" ), "JSON Append" );
		assertEquals( context.getValue( "type" ), "JSON" );
		</cfscript>
	</cffunction>

	<cffunction name="testDefaultEvent" access="public" returntype="void" output="false">
		<cfscript>
		var service = getController().getRequestService();
		var context = "";

		/* Setup test variables */
		url.event = "default";

		/* Catpure the request */
		context = service.requestCapture();

		/* Tests */
		assertTrue( isObject( context ), "Context Creation" );
		assertTrue( url.event eq context.getCurrentEvent(), "Event mismatch: #context.getCurrentEvent()#" );
		</cfscript>
	</cffunction>

	<cffunction name="testContextGetterSetters" access="public" returntype="Void" output="false">
		<cfscript>
		var service = getController().getRequestService();
		var context = "";

		context = service.getContext();
		assertTrue( isObject( context ), "Context Create" );

		structDelete( request, "cb_requestContext" );
		assertFalse( service.contextExists(), "Context exists" );

		service.setContext( context );
		assertTrue( structKeyExists( request, "cb_requestContext" ), "setter in request" );
		</cfscript>
	</cffunction>

	<cffunction name="tearDown" access="public" returntype="Void" hint="teardown" output="false">
		<cfscript>
		// This errors sometimes on Adobe CF 11
		try {
			structClear( cookie );
		} catch ( any e ) {
		}
		</cfscript>
	</cffunction>
</cfcomponent>
