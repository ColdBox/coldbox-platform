<cfcomponent name="settingsTest" extends="coldbox.system.extras.testing.baseMXUnitTest" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
		//Call the super setup method to setup the app.
		super.setup();
		</cfscript>
	</cffunction>
	
	<cffunction name="testSettings" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			var obj = getController().getConfigSettings();
			
			AssertFalse( structIsEmpty(obj) , "Structure populated");
			
			obj = getController().getsettingStructure();
			AssertFalse( structIsEmpty(obj) , "Config Structure populated");
			
			obj = getController().getsettingStructure(false,true);
			AssertFalse( structIsEmpty(obj) , "Config Structure populated, deep copy");
			
			obj = getController().getsettingStructure(true);
			AssertFalse( structIsEmpty(obj) , "FW Structure populated");
			
			obj = getController().getsettingStructure(true, false);
			AssertFalse( structIsEmpty(obj) , "FW Structure populated, deep copy");
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testSettingProcedures" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			var obj = "";
			
			obj = getcontroller().getSetting('HandlerCaching');
			AssertTrue( isBoolean(obj), "get test");
			
			obj = getController().getSetting("OSFileSeparator",true);
			AssertTrue( obj.length() gt 0, "get fw test");
			
			obj = getController().settingExists('nada');
			AssertFalse(obj, "config exists check");
			
			obj = getController().settingExists('HandlerCaching');
			AssertTrue(obj, "config exists check");
			
			obj = getController().settingExists('nada',true);
			AssertFalse(obj, "fw exists check");
			
			obj = getController().settingExists('OSFileSeparator',true);
			AssertTrue(obj, "fw exists check");
			
			obj = "test_#createUUID()#";
			getController().setSetting(obj,obj);
			AssertEquals( obj, getController().getSetting(obj) );
			
			
		</cfscript>
	</cffunction>
	
</cfcomponent>