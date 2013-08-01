<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BasePluginTest" output="false" plugin="coldbox.system.plugins.JavaLoader">
<cfscript>
	function setup(){
		super.setup();
		
		// alias test
		javaloader = plugin;
		javaloader.setStaticIDKey("cbox-javaloader-#hash(getCurrentTemplatePath())#");
		
		testJarsr = expandPath('/coldbox/testing/resources');
		
		javaLoader.$("settingExists",true);
		javaLoader.$("getSetting").$args("javaloader_libpath").$results(testJarsr);
		
		mockController.$("getAppHash",hash(now()));
		javaLoader.init(mockController);
		
		assertTrue( structKeyExists(server, javaloader.getStaticIDKey()) , "Javaloader in scope");
	}
	function tearDown(){
		structDelete(server,javaloader.getStaticIDKey());
	}
	
	function testMethods(){
		var myClass = "";
		
		// Create it
		try{
			myClass = javaloader.create("HelloWorld").init();
		}
		catch(Any e){
			fail(e.toString());
		}
		
		assertEquals( myClass.hello(), "Hello World", "Saying Hello");
	}
	function testgetLoadedURLs(){
		urls = javaloader.getLoadedURLs();
		assertTrue( arrayLen(urls) );
	}
	function testappendPaths(){
		javaloader.appendPaths(expandPath("/coldbox/testing/resources/javalib"));
		urls = javaloader.getLoadedURLs();
		debug(urls);
		assertTrue( findNoCase("hello.jar", urls[1]));
	}
</cfscript>
	
</cfcomponent>