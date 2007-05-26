<!-----------------------------------------------------------------------
Template : baseTest.cfc
Author 	 : luis5198
Date     : 5/25/2007 5:59:04 PM
Description :
	Base Unit Test Component based on CFCUnit.

	If you would like to change this to CFUnit, then change the extends
	portion to net.sourceforge.cfunit.framework.TestCase

Modification History:
5/25/2007 - Created Template
---------------------------------------------------------------------->
<cfcomponent name="baseTest" extends="org.cfcunit.framework.TestCase" output="false">

	<cfscript>
	variables.instance = structnew();
	</cfscript>

	<cffunction name="setUp" returntype="void" access="private">
		<cfscript>
		//Setup ColdBox Mappings For Testing
		instance.AppMapping = "/applications/coldbox/ApplicationTemplate";
		instance.ConfigMapping = ExpandPath(instance.AppMapping & "/config/config.xml.cfm");
		//Initialize ColdBox Controller
		instance.controller = CreateObject("component", "coldbox.system.controller").init();
		//Load Configurations
		instance.controller.getService("loader").configLoader(instance.ConfigMapping,instance.AppMapping);
		//Finish Registration
		instance.controller.getService("loader").registerHandlers();
		</cfscript>
	</cffunction>

	<!--- getter for AppMapping --->
	<cffunction name="getAppMapping" access="public" returntype="string" output="false">
		<cfreturn instance.AppMapping>
	</cffunction>

	<!--- getter for ConfigMapping --->
	<cffunction name="getConfigMapping" access="public" returntype="string" output="false">
		<cfreturn instance.ConfigMapping>
	</cffunction>

	<!--- getter for controller --->
	<cffunction name="getcontroller" access="public" returntype="any" output="false">
		<cfreturn instance.controller>
	</cffunction>

</cfcomponent>