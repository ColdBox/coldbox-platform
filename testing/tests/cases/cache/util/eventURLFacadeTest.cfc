<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
Description :
	Request service Test
----------------------------------------------------------------------->
<cfcomponent name="eventURLFacadeTest" extends="coldbox.testing.tests.resources.baseMockCase" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		super.setup();
		cacheManager = mockFactory.createMock('coldbox.system.cache.CacheManager');
		cacheManager.EVENT_CACHEKEY_PREFIX = "UNITEVENTTEST";
		facade = CreateObject("component","coldbox.system.cache.util.eventURLFacade").init(cacheManager);
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetUniqueHash" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			routedStruct.name = "luis";
			
			/* Mocks */
			context = mockFactory.createMock('coldbox.system.beans.requestContext');
			context.mockMethod('getRoutedStruct').returns(routedStruct);
			context.mockMethod('getCurrentEvent').returns('main.index');
			context.mockMethod('getEventName').returns('event');
			
			/* setup url vars */
			url.event = 'main.index';
			url.id = "123";
			url.fwCache="True";
			
			testHash = facade.getUniqueHash(context);
			
			AssertTrue( len(testHash) );			
		</cfscript>
	</cffunction>
	
	<cffunction name="testbuildHash" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			event = "main.index";
			args = "id=1";
			myStruct["id"] = 1;
			
			testHash = facade.buildHash(args);
			
			AssertEquals( testHash, hash(myStruct.toString()) );
		</cfscript>
	</cffunction>
	
	<cffunction name="testbuildEventKey" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			routedStruct.name = "majano";
			
			/* Mocks */
			context = mockFactory.createMock('coldbox.system.beans.requestContext');
			context.mockMethod('getRoutedStruct').returns(routedStruct,routedStruct);
			context.mockMethod('getCurrentEvent').returns('main.index');
			context.mockMethod('getEventName').returns('event','event');
			
			/* setup url vars */
			url.event = 'main.index';
			url.id = "123";
			url.fwCache="True";
			
			testCacheKey = facade.buildEventKey("unittest","main.index",context);
			uniqueHash = facade.getUniqueHash(context);
			targetKey = cacheManager.EVENT_CACHEKEY_PREFIX & "main.index-unittest-" & uniqueHash;
			
			AssertEquals( testCacheKey, targetKey );
		</cfscript>
	</cffunction>
	
	<cffunction name="testbuildEventKeyNoContext" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			event = "main.index";
			args = "id=1";
			myStruct["id"] = 1;
			
			testCacheKey = facade.buildEventKeyNoContext("unittest","main.index",args);
			targetKey = cacheManager.EVENT_CACHEKEY_PREFIX & "main.index-unittest-" & hash(myStruct.toString());
			
			AssertEquals( testCacheKey, targetKey  );
		</cfscript>
	</cffunction>
	
	
</cfcomponent>