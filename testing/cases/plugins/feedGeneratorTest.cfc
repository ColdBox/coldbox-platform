<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	June 01 2008
Description :
	FeedGeneratorTest plugin test
----------------------------------------------------------------------->
<cfcomponent name="FeedGeneratorTest" extends="coldbox.system.testing.BaseTestCase" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox/testharness");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
		//Call the super setup method to setup the app.
		super.setup();
		</cfscript>
		
		<cfset variables.q1 = queryNew('title,description,author,link')>
		<cfloop from="1" to="10" index="i">
			<cfset queryAddRow(q1,1) />
			<cfset querySetCell(q1, 'title', 'Title#i#')>
			<cfset querySetCell(q1, 'description', 'description-q1-#chr(65 + i)#')>
			<cfset querySetCell(q1, 'author', 'Sana')>
			<cfset querySetCell(q1, 'link', 'http://feed_link.com/test.rss')>
		</cfloop>
		
		<cfscript>
			variables.feedStruct['title'] = 'feed title';
			variables.feedStruct['link'] = 'http://feed_link.com/test';
			variables.feedStruct['description'] = 'feed generator unit test';
			variables.feedStruct['generator'] = 'ColdBox';
			variables.feedStruct['managingEditor'] = 'Luis Majano';
			variables.feedStruct['webMaster'] = 'Sana Ullah';
			
			variables.feedStruct['items'] = variables.q1;
		</cfscript>
	</cffunction>
	
	<cffunction name="testPlugin" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("FeedGenerator");
			
			AssertTrue( isObject(plugin) );
		</cfscript>
	</cffunction>	
	
	<cffunction name="testCreateFeed" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("FeedGenerator");
			var direactoryPath = ExpandPath('/coldbox/testing/tests/tmp/') & 'testrss.xml';
			var xmlDoc = plugin.createFeed(feedStruct = variables.feedStruct, OutputFile = direactoryPath);
		
			assertTrue(isXML(xmlDoc), "Returned value is not valid xml");
		</cfscript>
	</cffunction>
	
</cfcomponent>