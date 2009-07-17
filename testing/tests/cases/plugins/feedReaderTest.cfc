<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	June 01 2008
Description :
	feedReaderTest plugin test
----------------------------------------------------------------------->
<cfcomponent name="feedReaderTest" extends="coldbox.system.extras.testing.baseMXUnitTest" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox/testharness");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
		//Call the super setup method to setup the app.
		super.setup();
		variables.feedlink = 'http://newsrss.bbc.co.uk/rss/newsonline_world_edition/front_page/rss.xml';
		</cfscript>
	</cffunction>
	
	<cffunction name="testPlugin" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("feedReader");
			
			AssertTrue( isObject(plugin) );
		</cfscript>
	</cffunction>	
	
	<cffunction name="testReadFeed" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("feedReader");
			var tStruct = plugin.readFeed(variables.feedlink);
		
			assertTrue(isStruct(tStruct), "Returned value is not valid struct");
		</cfscript>
	</cffunction>
	
	<cffunction name="testRetrieveFeed" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("feedReader");
			var tStruct = plugin.retrieveFeed(variables.feedlink);
			
			assertTrue(isStruct(tStruct), "Returned value is not valid struct");
			
			plugin.setCachedFeed(variables.feedlink, tStruct);
			
			assertTrue(isStruct(plugin.getCachedFeed(variables.feedlink)), "Returned value is not valid struct");
			
			plugin.removeCachedFeed(variables.feedlink);
			
		</cfscript>
	</cffunction>
	
</cfcomponent>