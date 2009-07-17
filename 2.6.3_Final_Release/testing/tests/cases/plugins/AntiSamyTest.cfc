<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	November 10, 2008
Description :
	securityTest
----------------------------------------------------------------------->
<cfcomponent name="AntiSamyTest" extends="coldbox.system.extras.testing.baseMXUnitTest" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox/testharness");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
		//Call the super setup method to setup the app.
		super.setup();
		</cfscript>
	</cffunction>
	
	<cffunction name="testA" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("AntiSamy");
			
			assertTrue( IsObject(plugin), "AntiSamy plugin is not a object");
		</cfscript>
	</cffunction>	
	
	<cffunction name="testMethods" access="public" returntype="void" output="false">
		<!--- Now test some html cross site scripting --->
		<cfset var htmlcontent = '' />
		<cfset var plugin = getController().getPlugin("AntiSamy") />
		<cfsavecontent variable="htmlcontent">
		<cfoutput>	
		<img src="http://www.coldboxframework.com/includes/images/logos/coldbox_110.png" onclick="javascript:alert('hello cross site scripting test')" onmouseover="javascript:alert('WOW cross site scripting')">
		</cfoutput>
		</cfsavecontent>
		<!--- scan result must be like this: <img src="http://www.coldboxframework.com/includes/images/logos/coldbox_110.png" /> --->
		<cfset assertFalse(FindNoCase('onclick=' ,plugin.HtmlSanitizer(trim(htmlcontent))),'Html Sanitaser is not working') />
	</cffunction>

</cfcomponent>
