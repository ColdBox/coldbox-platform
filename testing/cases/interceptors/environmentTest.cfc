<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
Description :
	securityTest
----------------------------------------------------------------------->
<cfcomponent name="securityTest" extends="coldbox.system.testing.BaseTestCase" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		var mypath = getDirectoryFromPath(getMetaData(this).path);
		
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox/testharness");
		setConfigMapping("#mypath#../../resources/interceptor_configs/environment_cbox.xml");
		//Call the super setup method to setup the app.
		super.setup();
		</cfscript>
	</cffunction>
	
	<cffunction name="testLoading" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			AssertEquals('TRUE', getController().getSetting('TierControlFired'));			
		</cfscript>
	</cffunction>	

	
</cfcomponent>