<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	September 3, 2007
Description :
	debugger service tests

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox/testharness");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
		super.setup();
		
		/* Service To Test */
		debugger = getController().getDebuggerService();
		getMockBox().prepareMock(debugger);
		getMockBox().prepareMock(getController());
	}
	function testTimersExist(){
		assertFalse( debugger.timersExist() );
		request.debugTimers = "";
		assertTrue( debugger.timersExist() );
		structclear(request);
	}
	function testGetTimers(){
		assertEquals( debugger.getTimers(), QueryNew("Id,Method,Time,Timestamp,RC") );
		request.debugTimers = querySim("id, method
										123 | hello");
		assertEquals( debugger.getTimers(), request.debugTimers);
	}
	function testTimerStart(){
		/* Mocks */
		debugger.$("getTimers",queryNew(""));
		//1: No Debug Mode
		debugger.$("getDebugMode",false);
		assertEquals( debugger.timerStart('TEST'), 0 );
		//2: Debug Mode
		debugger.$("getDebugMode",true);
		labelHash = debugger.timerStart('TEST');
		assertTrue( structKeyExists(request, labelHash) );
		assertEquals( labelHash, hash('TEST') );		
	}
	function testTimerEnd(){
		/* Mocks */
		debugger.$("getDebugMode",true);
		labelHash = hash('TEST');
		qTimers = QueryNew("Id,Method,Time,Timestamp,RC");
		debugger.$("getTimers",qTimers);
		
		//1: With RC
		request[labelHash] = {label="TEST",stime=getTickCount()};
		debugger.timerEnd(labelHash);
		assertFalse( structKeyExists(request, labelHash) );
		assertTrue( qTimers.recordCount );
		
		//2: Without RC
		request[labelHash] = {label="Rendering Page",stime=getTickCount()};
		debugger.timerEnd(labelHash);
		assertFalse( structKeyExists(request, labelHash) );
		assertTrue( qTimers.recordCount );
	}
	function testGetDebugMode(){
		/* Mocks */
		debugger.$("getCookieName","unittest");
		//global debug mode on with no COOKIE
		getController().$("getSetting").$args("debugMode").$results(true);
		assertTrue( debugger.getDebugMode() );
		// global debug mode on with Cookie false
		cookie["unittest"] = false;
		assertFalse( debugger.getDebugMode() );
		
		//global debug mode off
		cookie["unittest"] = "";
		getController().$("getSetting").$args("debugMode").$results(false);
		//cookie off
		assertFalse( debugger.getDebugMode() );
		//Cookie found but not boolean
		cookie["unittest"] = "hello-123";
		assertFalse( debugger.getDebugMode() );
		//cooki with boolean
		cookie["unittest"] = true;
		assertTrue( debugger.getDebugMode() );
		cookie["unittest"] = false;
		assertFalse( debugger.getDebugMode() );
	}
	function testSetDebugMode(){
		// Should remove cookie 
		debugger.$("getCookieName","unittest");
		cookie["unittest"] = "hello";
		debugger.setDebugMode(false);
		assertEquals( cookie["unittest"], "false" );
		
		debugger.setDebugMode(true);
		assertEquals( cookie["unittest"], "true" );
	}
	function testRenderDebugLog(){
		debugLog = debugger.renderDebugLog();
		assertTrue( len(debugLog) );		
		debug(debugLog);
	}
	function testRenderCachePanel(){
		panel = debugger.renderCachePanel();
		assertTrue( len(panel) );		
		debug(panel);
	}
	function testRenderCacheDumper(){
		dumper = debugger.renderCacheDumper();
		assertTrue( len(dumper) );		
		debug(dumper);
	}
	function testRenderProfiler(){
		profilers = debugger.renderProfiler();
		assertTrue( len(profilers) );		
		debug(profilers);
	}
	function testRecordProfiler(){
		debugger.$("getDebugMode",false);
		debugger.$("timersExist",false);
		debugger.$("pushProfiler");
		debugger.$("getTimers",queryNew(""));
		
		debugger.recordProfiler();
		assertEquals(debugger.$count("pushProfiler"),0);
		
		debugger.$("timersExist",true);
		debugger.$("getDebugMode",true);		
		debugger.recordProfiler();
		assertEquals(debugger.$count("pushProfiler"),1);		
	}
	
	function testPushProfiler(){
		/* Mocks */
		mockConfig = getMockBox().createMock(className='coldbox.system.web.config.DebuggerConfig',clearMethods=true);
		debugger.setProfilers(arrayNew(1));
		debugger.$("getDebuggerConfig",mockConfig);
		debugger.$("popProfiler");
		
		/* Test Activate Check */
		mockConfig.$("getPersistentRequestProfiler",false);
		debugger.pushProfiler(queryNew(""));
		assertEquals( arrayLen(debugger.getProfilers()), 0);
		
		/* Less than Max, so push record */
		mockConfig.$("getPersistentRequestProfiler",true);
		mockConfig.$("getmaxPersistentRequestProfilers",10);
		debugger.pushProfiler(queryNew(""));
		assertEquals( arrayLen(debugger.getProfilers()), 1);
		
		/* Max Profilers Check, check Pop */
		mockConfig.$("getmaxPersistentRequestProfilers",1);
		debugger.pushProfiler(queryNew(""));
		assertEquals( debugger.$count("popProfiler"), 1);		
	}
	function testPopProfiler(){
		props = [1,2,3,4];
		debugger.setProfilers(props);
		debugger.popProfiler();
		assertEquals( arrayLen(debugger.getProfilers()), 3);
	}
	function testPushTracer(){
		mockConfig = getMockBox().createMock(className='coldbox.system.web.config.DebuggerConfig',clearMethods=true);
		debugger.setTracers(arrayNew(1));
		debugger.$("getDebuggerConfig",mockConfig);
		
		/* Test Activate Check */
		mockConfig.$("getPersistentTracers",false);
		debugger.pushTracer("Test");
		assertEquals( arrayLen(debugger.getTracers()), 0);
		//debug( service.getProfilers() );
		
		/* Entry Check */
		mockConfig.$("getPersistentTracers",true);
		debugger.pushTracer("Test");
		assertEquals( arrayLen(debugger.getTracers()), 1);
		tracers = debugger.getTracers();
		assertEquals( tracers[1].message , "Test");
		assertEquals( tracers[1].extraInfo , "");
	}
	function testResetTracers(){
		tracers = [1,2,3];
		debugger.setTracers(tracers);
		
		debugger.resetTracers();
		
		assertEquals( arrayLen(debugger.getTracers()), 0);
	}
</cfscript>
</cfcomponent>