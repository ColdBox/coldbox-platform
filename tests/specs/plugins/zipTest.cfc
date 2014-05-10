<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	April 03, 2008
Description :
	zipTest
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BasePluginTest" plugin="coldbox.system.plugins.Zip">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		super.setup();
		
		plugin.init();
		
		this.directoryPath = getDirectoryFromPath(getMetaData(this).path);
		
		debug(this.directoryPath);
		</cfscript>
	</cffunction>
	
	<cffunction name="testMethods" access="public" returntype="void" output="false">
		<!--- test methods --->
		<cfscript>
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
