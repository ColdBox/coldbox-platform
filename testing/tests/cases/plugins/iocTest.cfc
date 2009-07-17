<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	April 04, 2008
Description :
	timerTest
----------------------------------------------------------------------->
<cfcomponent name="iocTest" extends="coldbox.system.extras.testing.baseMXUnitTest" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox/testharness");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
		//Call the super setup method to setup the app.
		super.setup();
		</cfscript>
	</cffunction>
	
	<cffunction name="testPlugin" access="public" returntype="void" output="false">
		<!--- Now test is returned value is object --->
		<cfscript>
			var plugin = getController().getPlugin("ioc");

			AssertTrue( isObject(plugin) );
			AssertTrue( isObject(plugin.getIOCFactory()) );
			
			plugin.configure();
		</cfscript>
	</cffunction>
	
	<cffunction name="testReloadDefinitionFile" access="public" returntype="void" output="false">
		<!--- Now test is returned value is object --->
		<cfscript>
			var plugin = getController().getPlugin("ioc");

			plugin.ReloadDefinitionFile();
		</cfscript>
	</cffunction>
	
	<cffunction name="testIOCProperties" access="public" returntype="void" output="false">
		<!--- Now test is returned value is object --->
		<cfscript>
			var plugin = getController().getPlugin("ioc");

			plugin.setIOCFramework('lightwire');
			AssertEquals( plugin.getIOCFramework(), "lightwire");
			
			AssertEquals( plugin.getIOCDefinitionFile(), getController().getSetting('IOCDefinitionFile') );
			plugin.setIOCDefinitionFile( plugin.getIOCDefinitionFile() );
			AssertEquals( plugin.getIOCDefinitionFile(), getController().getSetting('IOCDefinitionFile') );
			
			AssertTrue( fileExists(plugin.getExpandedIOCDefinitionFile()) );
			plugin.setExpandedIOCDefinitionFile(plugin.getExpandedIOCDefinitionFile());
			AssertTrue( fileExists(plugin.getExpandedIOCDefinitionFile()) );
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testLightWireFactorySettings" access="public" returntype="void" output="false">
		<!--- Now test is returned value is object --->
		<cfscript>
			var plugin = getController().getPlugin("ioc");
			var obj = "";
			
			obj = createObject("component",plugin.getLIGHTWIRE_FACTORY() );
			
			plugin.setLIGHTWIRE_FACTORY('bogus.bogus');
			
			try{
				obj = createObject("component",plugin.getLIGHTWIRE_FACTORY() );
				Fail('I should have not been able to do this.');
			}
			catch(Any e){
				AssertTrue(true);
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="testColdspringFactorySettings" access="public" returntype="void" output="false">
		<!--- Now test is returned value is object --->
		<cfscript>
			var plugin = getController().getPlugin("ioc");
			var obj = "";
			
			obj = createObject("component",plugin.getCOLDSPRING_FACTORY() );
			
			plugin.setCOLDSPRING_FACTORY('bogus.bogus');
			
			try{
				obj = createObject("component",plugin.getCOLDSPRING_FACTORY() );
				Fail('I should have not been able to do this.');
			}
			catch(Any e){
				AssertTrue(true);
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="testValidateDefinitionFile" access="public" returntype="void" output="false">
		<!--- Now test is returned value is object --->
		<cfscript>
			var plugin = getController().getPlugin("ioc");
			var newfile = Expandpath('/coldbox/testing/tests/resources/coldspring.xml.cfm');
			
			plugin.setIOCDefinitionFile(newFile);
			
			makePublic(plugin, "validateDefinitionFile", "_validateDefinitionFile");
			
			plugin._validateDefinitionFile();
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testCreateColdspring" access="public" returntype="void" output="false">
		<!--- Now test is returned value is object --->
		<cfscript>
			var plugin = getController().getPlugin("ioc");
			var cs = getController().getSetting('ColdspringBeanFactory',1);
			var newfile = Expandpath('/coldbox/testing/tests/resources/coldspring.xml.cfm');
			
			makePublic(plugin,"createColdspring","_createColdspring");
			
			plugin.setIOCDefinitionFile(newfile);
			plugin.setIOCFramework('coldspring');
			
			makePublic(plugin, "validateDefinitionFile", "_validateDefinitionFile");
			plugin._validateDefinitionFile();
			
			plugin.setCOLDSPRING_FACTORY(cs);
			
			plugin._createColdspring();			
		</cfscript>
	</cffunction>
	
	<cffunction name="testCreateLightWire" access="public" returntype="void" output="false">
		<!--- Now test is returned value is object --->
		<cfscript>
			var plugin = getController().getPlugin("ioc");
			var lw = getController().getSetting('LightWireBeanFactory',1);
			var newfile = Expandpath('/coldbox/testing/tests/resources/coldspring.xml.cfm');
			
			makePublic(plugin,"createLightwire","_createLightwire");
			
			plugin.setIOCDefinitionFile(newfile);
			makePublic(plugin, "validateDefinitionFile", "_validateDefinitionFile");
			plugin._validateDefinitionFile();
			
			plugin.setLIGHTWIRE_FACTORY(lw);
			
			plugin._createLightwire();
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testGetBean" access="public" returntype="void" output="false">
		<!--- Now test is returned value is object --->
		<cfscript>
			var plugin = getController().getPlugin("ioc");
			var newfile = '/coldbox/testing/tests/resources/coldspring.xml.cfm';
			var security = 0;
			
			//set IOC Caching
			getController().setSetting("IOCObjectCaching",true);
			
			//set coldspring framework
			plugin.setIOCFramework('coldspring');
			plugin.setIOCDefinitionFile(newfile);
			//Reconfigure the plugin
			plugin.configure();
			
			AssertEquals( newfile, plugin.getIOCDefinitionFile());
			
			security = plugin.getBean('security');
			AssertEquals(security, getController().getColdboxOcm().get("ioc_security"), "cache check");
			
			//test lightwire
			plugin.setIOCFramework('lightwire');
			//Reconfigure the plugin
			plugin.configure();
			AssertEquals( newfile, plugin.getIOCDefinitionFile());
			
			AssertEquals( plugin.getBean('security'), security ,"models not the same" );
			AssertEquals(security, getController().getColdboxOcm().get("ioc_security"), "cache check");
			
		</cfscript>
	</cffunction>

</cfcomponent>
