<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">
<cfscript>
	function setup(){
		plugin 			= getMockBox().createMock("coldbox.system.Plugin");
		mockController  = getMockBox().createMock(className="coldbox.system.web.Controller");
		mockRS 			= getMockBox().createMock(className="coldbox.system.web.services.RequestService");
		flashScope 		= getMockBox().createMock(className="coldbox.system.web.flash.MockFlash");
		mockLogBox 		= getMockBox().createMock(className="coldbox.system.logging.LogBox");
		mockLogger 		= getMockBox().createMock(className="coldbox.system.logging.Logger");
		mockCacheBox    = getMockBox().createEmptyMock("coldbox.system.cache.CacheFactory");
		mockWireBox     = getMockBox().createEmptyMock("coldbox.system.ioc.Injector");
		
		mockController.$("getLogBox",mockLogBox)
			.$("getRequestService",mockRS)
			.$("getCacheBox", mockCacheBox)
			.$("getWireBox", mockWireBox);
		
		mockRS.$("getFlashScope",flashScope);
		mockLogBox.$("getLogger",mockLogger);
		
		
		plugin.init(mockController);
	}	
	function tests(){
			s = {};
			s.pluginName = "test";
			s.pluginVersion = "1.0";
			s.pluginDescription = "test";
			s.pluginAuthor = "luis";
			s.pluginAuthorURL="www.coldbox.org";
			
			for(key in s){
				evaluate("plugin.set#key#(s[key])");
			}
			
			for(key in s){
				assertEquals(s[key], evaluate("plugin.get#key#()"));
			}
			
			assertEquals(plugin.getPluginPath(),expandPath("/coldbox/system/Plugin.cfc"));
	}
</cfscript>
</cfcomponent>