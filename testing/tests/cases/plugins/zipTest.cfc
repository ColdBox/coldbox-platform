<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	April 03, 2008
Description :
	zipTest
----------------------------------------------------------------------->
<cfcomponent name="zipTest" extends="coldbox.system.extras.baseTest" output="false">

	<cffunction name="setUp" returntype="void" access="private" output="false">
		<cfscript>
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
		//Call the super setup method to setup the app.
		super.setup();
		</cfscript>
	</cffunction>
	
	<cffunction name="testPlugin" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("zip");
			
			assertComponent(plugin);			
		</cfscript>
	</cffunction>
	
	<cffunction name="testAddFiles" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("zip");
			var direactoryPath = ExpandPath('/applications/coldbox/testing/tests/resources');
			
			assertTrue(plugin.AddFiles(zipFilePath = direactoryPath  & '\Test1.zip', directory = direactoryPath, savePaths = true),'something gone wrong');			
		</cfscript>
	</cffunction>	
	
	<cffunction name="testDeleteFiles" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("zip");
			var direactoryPath = ExpandPath('/applications/coldbox/testing/tests/resources');
			
			assertTrue(plugin.DeleteFiles(zipFilePath = direactoryPath  & '\Test1.zip', files = 'security.xml.cfm'),'something gone wrong');			
		</cfscript>
	</cffunction>
	
	<cffunction name="testExtract" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("zip");
			var direactoryPath = ExpandPath('/applications/coldbox/testing/tests/resources');
			
			assertTrue(plugin.Extract(zipFilePath = direactoryPath  & '\Test1.zip', extractFiles = 'security.xml.cfm', useFolderNames= true, overwriteFiles = true),'something gone wrong');			
		</cfscript>
	</cffunction>
	
	<cffunction name="testList" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("zip");
			var direactoryPath = ExpandPath('/applications/coldbox/testing/tests/resources')  & '\Test1.zip';
			
			assertTrue(isQuery(plugin.List(zipFilePath = direactoryPath  & '\Test1.zip')),'something gone wrong');			
		</cfscript>
	</cffunction>
	
	<cffunction name="testgzipAddFile" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("zip");
			var direactoryPath = ExpandPath('/applications/coldbox/testing/tests/resources');
			
			assertTrue(plugin.gzipAddFile(gzipFilePath = direactoryPath, filePath = direactoryPath & '\security.xml.cfm'),'something gone wrong');			
		</cfscript>
	</cffunction>
	
	<cffunction name="testgzipExtract" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("zip");
			var direactoryPath = ExpandPath('/applications/coldbox/testing/tests/resources');
			
			assertTrue(plugin.gzipExtract(gzipFilePath = direactoryPath & '\security.xml.cfm.gzip', filePath = direactoryPath & '\t1\security.xml.cfm'),'something gone wrong');			
		</cfscript>
	</cffunction>
		
</cfcomponent>
