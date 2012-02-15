<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
Description :
	Request service Test
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfparam name="FORM" default="#structnew()#">
		<cfscript>
		cm = getMockBox().createEmptyMock(className='coldbox.system.cache.providers.MockProvider');
		cm.$("getEventCacheKeyPrefix","mock");
		facade = CreateObject("component","coldbox.system.cache.util.eventURLFacade").init(cm);
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetUniqueHash" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			routedStruct.name = "luis";
			
			/* Mocks */
			context = getMockBox().createMock('coldbox.system.web.context.RequestContext');
			context.$('getRoutedStruct').$results(routedStruct)
			       .$("getValue","123");
			
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
			
			myStruct['cgihost'] = cgi.http_host;
			
			AssertEquals( testHash, hash(myStruct.toString()) );
		</cfscript>
	</cffunction>
	
	<cffunction name="testbuildEventKey" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			routedStruct.name = "majano";
			
			/* Mocks */
			context = getMockBox().createMock('coldbox.system.web.context.RequestContext');
			context.$('getRoutedStruct').$results(routedStruct)
			       .$("getValue","123");
		
			/* setup url vars */
			url.event = 'main.index';
			url.id = "123";
			url.fwCache="True";
			
			testCacheKey = facade.buildEventKey("unittest","main.index",context);
			uniqueHash = facade.getUniqueHash(context);
			targetKey = cm.getEventCacheKeyPrefix() & "main.index-unittest-" & uniqueHash;
			
			AssertEquals( testCacheKey, targetKey );
		</cfscript>
	</cffunction>
	
	<cffunction name="testbuildEventKeyNoContext" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			event = "main.index";
			args = "id=1";
			myStruct["id"] = 1;
			myStruct['cgihost'] = cgi.http_host;
			
			testCacheKey = facade.buildEventKeyNoContext("unittest","main.index",args);
			targetKey = cm.getEventCacheKeyPrefix() & "main.index-unittest-" & hash(myStruct.toString());
			
			AssertEquals( testCacheKey, targetKey  );
		</cfscript>
	</cffunction>
	
	
</cfcomponent>