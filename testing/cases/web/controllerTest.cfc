<cfcomponent extends="coldbox.system.testing.BaseTestCase">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
			
			controller = getMockBox().createMock("coldbox.system.web.Controller").init(ExpandPath('/coldbox/testharness'));
			getMockBox().prepareMock( controller.getRequestService() );
			getMockBox().prepareMock( controller.getInterceptorService() );
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testAppRoots" returntype="void" access="public" output="false">
		<cfscript>
			AssertTrue( controller.getAppRootPath() eq expandPath('/coldbox/testharness') & "/");
			controller.setAppRootPath('nothing');
			AssertTrue( controller.getAppRootPath() eq "nothing");
		</cfscript>
	</cffunction>
	
	<cffunction name="testDependencies" access="public" returntype="any" hint="" output="false" >
		<cfscript>
			AssertTrue( isObject(controller.getLoaderService()) );
			AssertTrue( isObject(controller.getExceptionService()) );
			AssertTrue( isObject(controller.getRequestService()) );
			AssertTrue( isObject(controller.getDebuggerService()) );
			AssertTrue( isObject(controller.getPluginService()) );
			AssertTrue( isObject(controller.getinterceptorService()) );
			AssertTrue( isObject(controller.getHandlerService()) );
			AssertTrue( isObject(controller.getModuleService()) );
		</cfscript>
	</cffunction>
	
	<cffunction name="testSettings" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			//Populate
			config = {handlerCaching=true, mysetting='nothing', eventCaching=true};
			fwsettings = {Author="Luis Majano"};
			
			controller.setConfigSettings(config);
			controller.setColdboxSettings(fwsettings);
			
			obj = controller.getConfigSettings();
			AssertFalse( structIsEmpty(obj) , "Structure populated");
			
			obj = controller.getsettingStructure();
			AssertFalse( structIsEmpty(obj) , "Config Structure populated");
			
			obj = controller.getsettingStructure(false,true);
			AssertFalse( structIsEmpty(obj) , "Config Structure populated, deep copy");
			
			obj = controller.getsettingStructure(true);
			AssertFalse( structIsEmpty(obj) , "FW Structure populated");
			
			obj = controller.getsettingStructure(true, false);
			AssertFalse( structIsEmpty(obj) , "FW Structure populated, deep copy");
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testSettingProcedures" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			//Populate
			config = {handlerCaching=true, mysetting='nothing', eventCaching=true};
			fwsettings = {Author="Luis Majano"};
			
			controller.setConfigSettings(config);
			controller.setColdboxSettings(fwsettings);
			
			obj = controller.getSetting('HandlerCaching');
			AssertTrue( isBoolean(obj), "get test");
			
			obj = controller.settingExists('nada');
			AssertFalse(obj, "config exists check");
			
			obj = controller.settingExists('HandlerCaching');
			AssertTrue(obj, "config exists check");
			
			obj = controller.settingExists('nada',true);
			AssertFalse(obj, "fw exists check");
			
			obj = "test_#createUUID()#";
			controller.setSetting(obj,obj);
			AssertEquals( obj, controller.getSetting(obj) );
		</cfscript>
	</cffunction>
	
	<cffunction name="testColdboxInit" access="public" returntype="any" hint="" output="false" >
		<cfscript>
			AssertFalse(controller.getColdboxInitiated());
			controller.setColdboxInitiated(true);
			AssertTrue(controller.getColdboxInitiated());
		</cfscript>
	</cffunction>
	
	<cffunction name="testAspectsInitiated" access="public" returntype="any" hint="" output="false" >
		<cfscript>
			AssertFalse(controller.getAspectsInitiated());
			controller.setAspectsInitiated(true);
			AssertTrue(controller.getAspectsInitiated());
		</cfscript>
	</cffunction>
	
	<cffunction name="testAppHash" access="public" returntype="any" hint="" output="false" >
		<cfscript>
			AssertTrue( hash(expandPath('/coldbox/testharness')) eq controller.getAppHash() );
			
			controller.setAppHash(hash('unittest'));
			AssertTrue( hash('unittest') eq controller.getAppHash() );
		</cfscript>
	</cffunction>
	
	<cffunction name="appstarthandlerFired" access="public" returntype="any" hint="" output="false" >
		<cfscript>
			AssertFalse(controller.getAppStartHandlerFired());
			controller.setAppStartHandlerFired(true);
			AssertTrue(controller.getAppStartHandlerFired());
		</cfscript>
	</cffunction>
	
	<cfscript>
	
		function testPersistVariables(){
			mockFlash = getMockBox().createMock("coldbox.system.web.flash.MockFlash").init(controller);
			controller.getRequestService().$("getFlashScope",mockFlash);
			mockFlash.$("persistRC").$("putAll");
			
			controller.persistVariables("hello,test");
			assertEquals( "hello,test", mockFlash.$callLog().persistRC[1].include  );
			
 			persistStruct = { hello="test", name="luis"};
			controller.persistVariables(persistStruct=persistStruct);
			assertEquals( persistStruct, mockFlash.$callLog().putAll[1].map  );
		}
		
		function testsetNextEvent(){
			// mock data
			mockFlash = getMockBox().createMock("coldbox.system.web.flash.MockFlash").init(controller);
			mockContext = getMockRequestContext();
			
			mockFlash.$("saveFlash");
			
			controller.$("getSetting").$args("EventName").$results("event");
			controller.$("getSetting").$args("DefaultEvent").$results("general.index");
			controller.$("persistVariables").$("pushTimers").$("sendRelocation");
			controller.getRequestService().$("getContext", mockContext );
			controller.getRequestService().$("getFlashScope",mockFlash);
			controller.getRequestService().$("processState");
			
			// Test Full URL
			controller.setNextEvent(URL="http://www.coldbox.org",addToken=true);
			assertEquals( "http://www.coldbox.org", controller.$callLog().sendRelocation[1].URL );
			assertEquals( true, controller.$callLog().sendRelocation[1].addToken );
			assertEquals( 0, controller.$callLog().sendRelocation[1].statusCode );
			
			// Full URL with more stuff
			controller.setNextEvent(URL="http://www.coldbox.org",statusCode=301,queryString="page=2&test=1");
			assertEquals( "http://www.coldbox.org?page=2&test=1", controller.$callLog().sendRelocation[2].URL );
			assertEquals( false, controller.$callLog().sendRelocation[2].addToken );
			assertEquals( 301, controller.$callLog().sendRelocation[2].statusCode );
			
			// Test relative URI with query strings
			controller.setNextEvent(URI="/route/path/two",queryString="page=2&test=1");
			assertEquals( "/route/path/two?page=2&test=1", controller.$callLog().sendRelocation[3].URL );
			
			// Test normal event
			controller.setNextEvent(event="general.page",querystring="page=2&test=1");
			//assertEquals( "", controller.$callLog().sendRelocation[4].URL );
			
			debug( controller.$calllog() );
		}
	
	</cfscript>
	
	
</cfcomponent>