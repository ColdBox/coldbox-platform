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
	
	<cffunction name="testMethods" access="public" returntype="void" output="false">
		<!--- test methods --->
		<cfscript>
			var plugin		    = getController().getPlugin("zip");
			var pluginUtility	= getController().getPlugin("Utilities");
			var direactoryPath = ExpandPath('/applications/coldbox/testing/tests/resources');
			
			assertTrue(plugin.AddFiles(zipFilePath = direactoryPath  & '\Test1.zip', directory = direactoryPath, savePaths = true),'AddFiles() something gone wrong');
			
			assertTrue(plugin.Extract(zipFilePath = direactoryPath  & '\Test1.zip', extractFiles = 'security.xml.cfm', useFolderNames= true, overwriteFiles = true),'Extract() something gone wrong');
			
			assertTrue(plugin.DeleteFiles(zipFilePath = direactoryPath  & '\Test1.zip', files = 'security.xml.cfm'),'DeleteFiles() something gone wrong');
			
			assertTrue(isQuery(plugin.List(zipFilePath = direactoryPath  & '\Test1.zip')),'List() something gone wrong');
			
			assertTrue(plugin.gzipAddFile(gzipFilePath = direactoryPath, filePath = direactoryPath & '\security.xml.cfm'),'gzipAddFile() something gone wrong');
			
			assertTrue(plugin.gzipExtract(gzipFilePath = direactoryPath & '\security.xml.cfm.gz', filePath = direactoryPath),'gzipExtract() something gone wrong');
			
			assertTrue(pluginUtility.removeFile(direactoryPath & '\Test1.zip'));
			assertTrue(pluginUtility.removeFile(direactoryPath & '\security.xml.cfm.gz'));		
		</cfscript>
		
	</cffunction>

	<!--- tearDown ..... its funny but its runs before the other methods --->
	<!--- <cffunction name="tearDown" output="false" access="public" returntype="void" hint="delete generated zip files">
		<cffile action="delete" file="#ExpandPath('/applications/coldbox/testing/tests/resources')#\Test1.zip">
		<cffile action="delete" file="#ExpandPath('/applications/coldbox/testing/tests/resources')#\security.xml.cfm.gz"> 
	</cffunction> --->
		
</cfcomponent>
