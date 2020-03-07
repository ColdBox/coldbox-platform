<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author          :	Luis Majano
Date               :	9/3/2007
Description :
Request service Test
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseModelTest" output="false">
	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfparam name="FORM" default="#structNew()#">
		<cfscript>
		cm = createEmptyMock( "coldbox.system.cache.providers.MockProvider" );
		cm.$( "getEventCacheKeyPrefix", "mock" );
		facade = new coldbox.system.cache.util.EventURLFacade( cm );
		</cfscript>
	</cffunction>

	<cffunction name="testgetUniqueHash" access="public" returntype="void" hint="" output="false">
		<cfscript>
		var routedStruct = { name : "luis" };

		/* Mocks */
		var context = createMock( "coldbox.system.web.context.RequestContext" ).setRoutedStruct( routedStruct ).setContext( { event : "main.index", id : "123" } );

		var testHash = facade.getUniqueHash( context );

		assertTrue( len( testHash ) );
		</cfscript>
	</cffunction>

	<cffunction name="testbuildHash" access="public" returntype="void" hint="" output="false">
		<cfscript>
		var args     = "id=1&name=luis";
		var testHash = facade.buildHash( args );
		var testargs = { "id" : 1, "name" : "luis" };
		var target   = {
			"incomingHash" : hash( testargs.toString() ),
			"cgihost"      : CGI.HTTP_HOST
		};

		expect( testHash ).toBe( hash( target.toString() ) );
		</cfscript>
	</cffunction>

	<cffunction name="testbuildEventKey" access="public" returntype="void" hint="" output="false">
		<cfscript>
		/* Mocks */
		var context = createMock( "coldbox.system.web.context.RequestContext" );
		context.setRoutedStruct( { "name" : "majano" } ).setContext( { event : "main.index", id : "123" } );

		var testCacheKey = facade.buildEventKey( "unittest", "main.index", context );
		var uniqueHash   = facade.getUniqueHash( context );
		var targetKey    = cm.getEventCacheKeyPrefix() & "main.index-unittest-" & uniqueHash;

		expect( testCacheKey ).toBe( targetKey );
		</cfscript>
	</cffunction>

	<cffunction name="testbuildEventKeyNoContext" access="public" returntype="void" hint="" output="false">
		<cfscript>
		var args = "id=1";

		var testCacheKey = facade.buildEventKeyNoContext( "unittest", "main.index", args );
		var targetKey    = cm.getEventCacheKeyPrefix() & "main.index-unittest-" & facade.buildHash( args );

		expect( testCacheKey ).toBe( targetKey );
		</cfscript>
	</cffunction>
</cfcomponent>
