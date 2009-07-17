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
<cfcomponent name="zipTest" extends="coldbox.system.extras.testing.baseMXUnitTest" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox/testharness");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
		
		//Call the super setup method to setup the app.
		super.setup();
		
		this.directoryPath = getDirectoryFromPath(getMetaData(this).path);
		</cfscript>
	</cffunction>
	
	<cffunction name="testPlugin" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("zip");

			AssertTrue( isObject(plugin) );
		</cfscript>
	</cffunction>
	
	<cffunction name="testMethods" access="public" returntype="void" output="false">
		<!--- test methods --->
		<cfscript>
			var plugin		    = getController().getPlugin("zip");
			
			assertTrue(plugin.AddFiles(zipFilePath = this.directoryPath  & 'Test1.zip', directory = this.directoryPath, savePaths = true),'AddFiles() something gone wrong');
			
			assertTrue(plugin.Extract(zipFilePath = this.directoryPath  & 'Test1.zip', extractFiles = 'security.xml.cfm', useFolderNames= true, overwriteFiles = true),'Extract() something gone wrong');
			
			assertTrue(plugin.DeleteFiles(zipFilePath = this.directoryPath  & 'Test1.zip', files = 'security.xml.cfm'),'DeleteFiles() something gone wrong');
			
			assertTrue(isQuery(plugin.List(zipFilePath = this.directoryPath  & 'Test1.zip')),'List() something gone wrong');
			
			assertFalse(plugin.gzipAddFile(gzipFilePath = this.directoryPath, filePath = this.directoryPath & 'security.xml.cfm'),'gzipAddFile() something gone wrong');
			
			assertFalse(plugin.gzipExtract(gzipFilePath = this.directoryPath & 'security.xml.cfm.gz', filePath = this.directoryPath),'gzipExtract() something gone wrong');	
		</cfscript>
		
	</cffunction>

	<cffunction name="tearDown" output="false" access="public" returntype="void" hint="delete generated zip files">
		<cfif fileExists(this.directoryPath & "Test1.zip")>
		<cffile action="delete" file="#this.directoryPath#Test1.zip">
		</cfif>
		
		<cfif fileExists(this.directoryPath & "security.xml.cfm.gz")>
		<cffile action="delete" file="#this.directoryPath#security.xml.cfm.gz">
		</cfif> 
	</cffunction>
		
</cfcomponent>
