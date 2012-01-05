<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	September 3, 2007
Description :
	plugin service test cases.

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="pluginserviceTest" extends="coldbox.system.testing.BaseTestCase" output="false" appMapping="/coldbox/testharness">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		super.setup();
		</cfscript>
	</cffunction>
	
	<cffunction name="testNewInstanceViaController" access="public" returntype="void" output="false">
		<cfscript>
		var plugin = getController().getPlugin("Logger",false,true);
		AssertTrue( isObject(plugin) );
		</cfscript>
	</cffunction>
	
	<cffunction name="testNormalPluginViaController" access="public" returntype="void" output="false">
		<cfscript>
		var plugin = getController().getPlugin("Logger",false);
		AssertTrue( isObject(plugin));
		</cfscript>
	</cffunction>
	
	<cffunction name="testPluginByConvention" access="public" returntype="void" output="false">
		<cfscript>
		var plugin = getController().getPluginService().get("dateNoAutowire",true);
		AssertTrue( isObject(plugin));
		</cfscript>
	</cffunction>
	
	<cffunction name="testPluginByConfiguration" access="public" returntype="void" output="false">
		<cfscript>
		var plugin = getController().getPluginService().get("myclientstorage",true);
		AssertTrue( isObject(plugin));
		</cfscript>
	</cffunction>
	
	<cffunction name="testPluginByModule" access="public" returntype="void" output="false">
		<cfscript>
		plugin = getController().getPluginService().get("ModPlugin",true,"test1");
		AssertTrue( isObject(plugin));
		
		try{
			plugin = getController().getPluginService().get("ModPlugin",true,"test2");
			fail("Should Fail");
		}
		catch("PluginService.ModuleConfigurationNotFound" e){}
		catch(any e){
			$rethrow(e);
		}
		
		try{
			plugin = getController().getPluginService().get("BogusPlugin",true,"test1");
			fail("Should Fail");
		}
		catch("PluginService.ModulePluginNotFound" e){}
		catch(any e){
			$rethrow(e);
		}
		</cfscript>
	</cffunction>
	
</cfcomponent>