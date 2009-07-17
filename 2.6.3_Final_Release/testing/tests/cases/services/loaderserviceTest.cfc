<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
Description :
	loaderserviceTest
----------------------------------------------------------------------->
<cfcomponent name="loaderserviceTest" extends="coldbox.system.extras.testing.baseMXUnitTest" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox/testharness");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
		//Call the super setup method to setup the app.
		super.setup();
		</cfscript>
	</cffunction>
	
	<cffunction name="testSetupCalls" access="public" returntype="void" output="false">
		<cfscript>
		var service = getController().getservice("loader");
		var context = "";
		
		getController().setSetting("dummyVar", true);
		
		service.setupCalls(getConfigMapping(),getAppMapping());
		
		AssertFalse( getController().settingExists("dummyVar") );		
		
		</cfscript>
	</cffunction>	
	
	<cffunction name="testRegisterAspects" access="public" returntype="void" output="false">
		<cfscript>
		var service = getController().getservice("loader");
		var context = "";
		
		service.registerAspects();
		
		</cfscript>
	</cffunction>	
	
	<cffunction name="testRegisterHandlers" access="public" returntype="void" output="false">
		<cfscript>
		var service = getController().getservice("loader");
		var context = "";
		var fs = getController().getSetting("OSFileSeparator",true);
		var dummyFile = getController().getSetting("HandlersPath") & fs & "dummy.cfc";
		
		createFile( dummyFile );
		getController().getHandlerService().registerHandlers();
		AssertTrue( listFindNocase(getController().getSetting("RegisteredHandlers"), "dummy") );
		removeFile( dummyFile );
		
		</cfscript>
	</cffunction>		
	
	
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