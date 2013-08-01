<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BasePluginTest" plugin="coldbox.system.plugins.FileUtils">
<cfscript>
	
	function setup(){
		super.setup();
		util = plugin;
	}
	
	function testMethods(){
		var direactoryPath = ExpandPath('/coldbox/testing/resources');
		
		util.createFile(direactoryPath & '\unittest.txt');

		util.saveFile(direactoryPath & '\unittest.txt', 'unitest-');
		
		util.appendFile(direactoryPath & '\unittest.txt', 'unitest');
		
		util.getAbsolutePath(direactoryPath);
		
		assertTrue(IsValid("date",util.FileLastModified(direactoryPath & '\unittest.txt')));
		
		assertTrue(IsValid("numeric",util.FileSize(direactoryPath & '\unittest.txt')));
		
		assertTrue(util.FileCanWrite(direactoryPath & '\unittest.txt'));
		
		assertTrue(util.FileCanRead(direactoryPath & '\unittest.txt'));
		
		assertTrue(util.isFile(direactoryPath & '\unittest.txt'));
		
		assertTrue(util.isDirectory(direactoryPath));
		
		AssertEquals(util.checkCharSet('iso-8859-1'),'iso-8859-1', 'checkCharSet() something gone wrong');
		
		AssertEquals(util.ripExtension('unittest.txt'),'unittest', 'ripExtension() something gone wrong');
		
		assertTrue(util.removeFile(direactoryPath & '\unittest.txt'));
		
	}
	
</cfscript>
</cfcomponent>
