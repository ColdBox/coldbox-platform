<cfcomponent name="settingsTest" extends="coldbox.testing.tests.resources.baseMockCase" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
			super.setup();
		
			controller = createObject("component","coldbox.system.controller").init(ExpandPath('/coldbox/testharness'));
		
		</cfscript>
	</cffunction>
	
	<cffunction name="testAppRoots" returntype="void" access="public" output="false">
		<cfscript>
			AssertTrue( controller.getAppRootPath() eq expandPath('/coldbox/testharness'));
			controller.setAppRootPath('nothing');
			AssertTrue( controller.getAppRootPath() eq "nothing");
		</cfscript>
	</cffunction>
	
	<cffunction name="testDependencies" access="public" returntype="any" hint="" output="false" >
		<cfscript>
			AssertTrue( isObject(controller.getColdboxOCM()) );
			AssertTrue( isObject(controller.getLoaderService()) );
			AssertTrue( isObject(controller.getExceptionService()) );
			AssertTrue( isObject(controller.getRequestService()) );
			AssertTrue( isObject(controller.getDebuggerService()) );
			AssertTrue( isObject(controller.getPluginService()) );
			AssertTrue( isObject(controller.getinterceptorService()) );
			AssertTrue( isObject(controller.getHandlerService()) );
		</cfscript>
	</cffunction>
	
	<cffunction name="testSettings" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			//Populate
			config = {handlerCaching=true, mysetting='nothing', eventCaching=true};
			fwsettings = {OSFileSeparator="/", Author="Luis Majano"};
			
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
			fwsettings = {OSFileSeparator="/", Author="Luis Majano"};
			
			controller.setConfigSettings(config);
			controller.setColdboxSettings(fwsettings);
			
			obj = controller.getSetting('HandlerCaching');
			AssertTrue( isBoolean(obj), "get test");
			
			obj = controller.getSetting("OSFileSeparator",true);
			AssertTrue( obj.length() gt 0, "get fw test");
			
			obj = controller.settingExists('nada');
			AssertFalse(obj, "config exists check");
			
			obj = controller.settingExists('HandlerCaching');
			AssertTrue(obj, "config exists check");
			
			obj = controller.settingExists('nada',true);
			AssertFalse(obj, "fw exists check");
			
			obj = controller.settingExists('OSFileSeparator',true);
			AssertTrue(obj, "fw exists check");
			
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
	
	<cffunction name="testSessionPersistance" access="public" returntype="any" hint="" output="false" >
		<cfscript>
			fwsetting.FlashURLPersistScope = "session";
			controller.setColdboxSettings(fwsetting);
			mockCollection = {test='luis', today=now(), lastname="majano"};
			varStruct = {test="Jose", myVar="nothing"};
			
			mocksession = createObject("component","coldbox.system.plugins.sessionstorage").init(controller);
			
			context = mockFactory.createMock('coldbox.system.beans.requestContext');
			context.mockMethod('getCollection').returns(mockCollection,mockCollection);
			
			pluginService = mockfactory.createMock('coldbox.system.services.pluginService');
			pluginService.mockMethod('get').returns(mocksession,mocksession);
			controller.setPluginService(pluginService,pluginService);
			
			requestService = mockfactory.createMock('coldbox.system.services.requestService');
			requestService.mockMethod('getContext').returns(context,context);
			controller.setrequestService(requestService,requestService);
			
			controller.persistVariables('test',varStruct);
			
			debug(session);
			AssertTrue(mocksession.exists('_coldbox_persistStruct'));
			
			controller.persistVariables('today,lastname');
			
			debug(session);
			AssertTrue(mocksession.exists('_coldbox_persistStruct'));
		</cfscript>
	</cffunction>
	
	<cffunction name="testClientPersistance" access="public" returntype="any" hint="" output="false" >
		<cfscript>
			fwsetting.FlashURLPersistScope = "client";
			controller.setColdboxSettings(fwsetting);
			mockCollection = {test='luis', today=now(), lastname="majano"};
			varStruct = {test="Jose", myVar="nothing"};
			
			mocksession = createObject("component","coldbox.system.plugins.clientstorage").init(controller);
			
			context = mockFactory.createMock('coldbox.system.beans.requestContext');
			context.mockMethod('getCollection').returns(mockCollection,mockCollection);
			
			pluginService = mockfactory.createMock('coldbox.system.services.pluginService');
			pluginService.mockMethod('get').returns(mocksession,mocksession);
			controller.setPluginService(pluginService,pluginService);
			
			requestService = mockfactory.createMock('coldbox.system.services.requestService');
			requestService.mockMethod('getContext').returns(context,context);
			controller.setrequestService(requestService,requestService);
			
			controller.persistVariables('test',varStruct);
			
			debug(client);
			AssertTrue(mocksession.exists('_coldbox_persistStruct'));
			
			controller.persistVariables('today,lastname');
			
			debug(client);
			AssertTrue(mocksession.exists('_coldbox_persistStruct'));
		</cfscript>
	</cffunction>
	
	
</cfcomponent>