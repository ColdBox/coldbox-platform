<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
			plugin = createObject("component","coldbox.system.Plugin");
			mockController = getMockBox().createMock("coldbox.system.Controller");
			
			plugin.init(mockController);
		</cfscript>
	</cffunction>
	
	<cffunction name="testGetSets">
		<cfscript>
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
			
			assertEquals(plugin.getPluginPath(),expandPath("/coldbox/system/Plugin.cfc"))
		</cfscript>
	</cffunction>
	
	
	
</cfcomponent>