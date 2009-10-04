<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">
<cfscript>
	function setup(){
		javaloader = getMockBox().createMock(className="coldbox.system.plugins.JavaLoader");
		javaloader.setStaticIDKey("cbox-javaloader-#hash(getCurrentTemplatePath())#");
		
		testJarsr = expandPath('/coldbox/testing/resources/helloworld.jar');
		javaloader.setup( listToArray(testJarsr) );
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
	}
</cfscript>
	
</cfcomponent>