<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	April 03, 2008
Description :
	All tests are done via the core object.
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BasePluginTest" plugin="coldbox.system.plugins.JVMUtils">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		super.setup();
		
		plugin.init();
		</cfscript>
	</cffunction>
	
	<!--- testCreation --->
    <cffunction name="testCreation" output="false" access="public" returntype="any" hint="">
    	<cfset assertTrue( isObject(plugin) )>
    </cffunction>
		
</cfcomponent>
