<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	September 3, 2007
Description :
	debugger service tests

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="debuggerserviceTest" extends="coldbox.system.testing.BaseTestCase" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox/testharness");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
		//Call the super setup method to setup the app.
		super.setup();
		</cfscript>
	</cffunction>
	
	<cffunction name="testDebugModes" access="public" returntype="void" output="false">
		<cfscript>
		var service = getController().getDebuggerService();
		var cookieName = "coldbox_debugmode_#getController().getApphash()#";
		
		//set test
		service.setDebugMode(true);
		AssertTrue( cookie[cookieName] , "Set Tests");
		//get test for true
		AssertTrue( service.getDebugMode(), "Get Test to true" );
		
		//set to false
		service.setDebugMode(false);
		AssertFalse( service.getDebugMode(), "Test after set to false");
		
		</cfscript>
	</cffunction>
	
	<cffunction name="testRenderDebugLog" access="public" returntype="void" output="false">
		<cfscript>
		var service = getController().getDebuggerService();
		var debugLog = service.renderDebugLog();
		
		assertTrue( isSimpleValue(debugLog));		
		</cfscript>
	</cffunction>
	
	<cffunction name="testRenderCachePanel" access="public" returntype="void" output="false">
		<cfscript>
		var service = getController().getDebuggerService();
		var cachePanel = service.renderCachePanel();
		
		assertTrue(isSimpleValue(cachePanel));		
		</cfscript>
	</cffunction>
	
	<cffunction name="testTimers" access="public" returntype="void" output="false">
		<cfscript>
		var service = getController().getDebuggerService();
		structClear(request);
		getMockFactory().createMock(object=service);
		service.mockmethod("getDebugMode",true);
		hashCode = service.timerStart('UnitTest');
		
		//debug(request);
		
		AssertTrue( isDefined("request.DebugTimers"), "debug timers" );
		//debug(hash('UnitTest'));
		AssertTrue( structKeyExists(request,hashcode), "unit test timer" );
		
		service.timerEnd(hashCode);
		
		AssertTrue( isDefined("request.DebugTimers") );
		AssertFalse( structKeyExists(request,hashCode) );
		AssertTrue( isQuery(request.debugTimers) );
		AssertTrue( request.debugTimers.recordCount eq 1 );
		</cfscript>
	</cffunction>
	
	<cffunction name="testProfilerPush">
		<cfscript>
			service = getController().getDebuggerService();
			mockConfig = getMockFactory().createMock('coldbox.system.beans.DebuggerConfigBean');
			
			/* Test Activate Check */
			mockConfig.mockMethod("getPersistentRequestProfiler",false);
			service.setDebuggerConfigBean(mockConfig);
			service.setProfilers(arrayNew(1));
			service.pushProfiler(queryNew(""));
			assertEquals( arrayLen(service.getProfilers()), 0);
			//debug( service.getProfilers() );
			
			/* Entry Check */
			mockConfig.mockMethod("getPersistentRequestProfiler",true);
			mockConfig.mockMethod("getmaxPersistentRequestProfilers",10);
			service.pushProfiler(queryNew(""));
			assertEquals( arrayLen(service.getProfilers()), 1);
			
			/* Max Profilers Check, check Pop */
			mockConfig.mockMethod("getmaxPersistentRequestProfilers",1);
			service.pushProfiler(queryNew(""));
			assertEquals( arrayLen(service.getProfilers()), 1);
		</cfscript>
	</cffunction>
	
	<cffunction name="testTracerPush">
		<cfscript>
			service = getController().getDebuggerService();
			mockConfig = getMockFactory().createMock('coldbox.system.beans.DebuggerConfigBean');
			
			/* Test Activate Check */
			mockConfig.mockMethod("getPersistentTracers",false);
			service.setDebuggerConfigBean(mockConfig);
			service.setTracers(arrayNew(1));
			service.pushTracer("Test");
			assertEquals( arrayLen(service.getTracers()), 0);
			//debug( service.getProfilers() );
			
			/* Entry Check */
			mockConfig.mockMethod("getPersistentTracers",true);
			service.pushTracer("Test");
			assertEquals( arrayLen(service.getTracers()), 1);
		</cfscript>
	</cffunction>
	
	
</cfcomponent>