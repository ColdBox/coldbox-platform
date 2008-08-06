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
		controller = mockFactory.createMock('coldbox.system.controller');
		facade = CreateObject("component","coldbox.system.cache.util.eventURLFacade").init(controller);
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetUniqueHash" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			routedStruct.name = "luis";
			
			/* Mocks */
			context = mockFactory.createMock('coldbox.system.beans.requestContext');
			context.mockMethod('getRoutedStruct').returns(routedStruct);
			context.mockMethod('getCurrentEvent').returns('main.index');
			controller.mockMethod('getSetting').returns('event');
			
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
			myStruct["event"] = event;
			myStruct["id"] = 1;
			
			controller.mockMethod('getSetting').returns('event');
			
			testHash = facade.buildHash(event,args);
			
			AssertEquals( testHash, hash(myStruct.toString()) );
		</cfscript>
	</cffunction>
	
	
</cfcomponent>