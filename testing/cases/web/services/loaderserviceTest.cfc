<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
Description :
	Some tests just are expecting to execute
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseTestCase" appMapping="/coldbox/testharness">
<cfscript>
	
	function setup(){
		super.setup();
		
		ls = getController().getLoaderService();
	}
	
	function testLoadApplication(){
		var context = "";
		
		getController().setSetting("dummyVar", true);
		
		ls.loadApplication(getConfigMapping(),getAppMapping());
		
		AssertFalse( getController().settingExists("dummyVar") );		
	}
	
	function testRegisterAspects(){
		var context = "";
		
		ls.registerAspects();
	}
	
	function testRegisterHandlers(){
		var context = "";
		var fs = "/";
		var dummyFile = getController().getSetting("HandlersPath") & fs & "dummy.cfc";
		
		createFile( dummyFile );
		getController().getHandlerService().registerHandlers();
		AssertTrue( listFindNocase(getController().getSetting("RegisteredHandlers"), "dummy") );
		removeFile( dummyFile );
	}
	
	function testProcessShutdown(){
		ls.processShutdown();
	}
</cfscript>
	
	
	<cffunction name="createFile" access="private" hint="Create a new empty fileusing java.io.File." returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="filename"	 		type="String"  required="yes" 	 hint="The absolute path of the file to create.">
		<!--- ************************************************************* --->
		<cfscript>
		var fileObj = createObject("java","java.io.File").init(JavaCast("string",arguments.filename));
		fileObj.createNewFile();
		</cfscript>
	</cffunction>	
	
	<cffunction name="removeFile" access="private" hint="Remove a file using java.io.File" returntype="boolean" output="false">
		<!--- ************************************************************* --->
		<cfargument name="filename"	 		type="string"  required="yes" 	 hint="The absolute path to the file.">
		<!--- ************************************************************* --->
		<cfscript>
		var fileObj = createObject("java","java.io.File").init(JavaCast("string",arguments.filename));
		return fileObj.delete();
		</cfscript>
	</cffunction>	

	
</cfcomponent>