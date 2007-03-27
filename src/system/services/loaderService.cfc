<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	This cfc takes care of debugging settings.

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="loaderService" output="false" hint="The application and framework loader service">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="loaderService" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			variables.controller = arguments.controller;
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Setup Calls --->
	<cffunction name="setupCalls" returntype="void" access="public" hint="I run the configLoader and register handlers.">
		<cfscript>
			//execute the configLoader
			configLoader();
			//execute the handler registrations
			registerHandlers();
		</cfscript>
	</cffunction>

	<!--- Config Loader Method --->
	<cffunction name="configLoader" returntype="void" access="Public" hint="I Load the configurations and init the framework variables." output="false">
		<cfscript>
		var XMLParser = controller.getPlugin("XMLParser");
		var CacheConfigBean = CreateObject("Component","coldbox.system.beans.cacheConfigBean");
		var FrameworkSettings = structNew();
		var ConfigSettings = structNew();

		//Load Coldbox Config Settings Structure
		FrameworkSettings = XMLParser.loadFramework();
		controller.setColdboxSettings(FrameworkSettings);

		//Create the Cache Config Bean with data from the settings.xml
		CacheConfigBean = CacheConfigBean.init(FrameworkSettings.CacheObjectDefaultTimeout,
											   FrameworkSettings.CacheObjectDefaultLastAccessTimeout,
											   FrameworkSettings.CacheReapFrequency,
											   FrameworkSettings.CacheMaxObjects,
											   FrameworkSettings.CacheFreeMemoryPercentageThreshold);
		//Configure the Object Cache.
		controller.getColdboxOCM().configure(CacheConfigBean);

		//Load Application Config Settings
		ConfigSettings =XMLParser.parseConfig();
		controller.setConfigSettings(ConfigSettings);
		//Check for Cache OVerride Settings
		if ( ConfigSettings.CacheSettings.OVERRIDE ){
			//Recreate the Config Bean
			CacheConfigBean = CacheConfigBean.init(ConfigSettings.CacheSettings.ObjectDefaultTimeout,
											   ConfigSettings.CacheSettings.ObjectDefaultLastAccessTimeout,
											   ConfigSettings.CacheSettings.ReapFrequency,
											   ConfigSettings.CacheSettings.MaxObjects,
											   ConfigSettings.CacheSettings.FreeMemoryPercentageThreshold);
			//Re-Configure the Object Cache.
			controller.getColdboxOCM().configure(CacheConfigBean);
		}
		//IoC Plugin Manager
		if ( ConfigSettings.IOCFramework neq "" ){
			//Create IoC Factory and configure it.
			controller.getPlugin("ioc");
		}

		//Load i18N if application is using it.
		if ( ConfigSettings.using_i18N ){
			//Create i18n Plugin and configure it.
			controller.getPlugin("i18n").init_i18N(ConfigSettings.DefaultResourceBundle,ConfigSettings.DefaultLocale);
		}

		//Initialize AOP Logging if requested.
		if ( ConfigSettings.EnableColdboxLogging ){
			controller.getPlugin("logger").initLogLocation();
		}

		//Set Debugging Mode according to configuration
		controller.getDebuggerService().setDebugMode(ConfigSettings.DebugMode);

		// Flag the initiation, Framework is ready to serve requests. Praise be to GOD.
		controller.setColdboxInitiated(true);
		</cfscript>
	</cffunction>

	<!--- Handler Registration System --->
	<cffunction name="registerHandlers" access="public" returntype="void" hint="I register your application's event handlers" output="false">
		<cfscript>
		var HandlersPath = controller.getSetting("HandlersPath");
		var HandlerArray = Arraynew(1);

		//Check for Handlers Directory Location
		if ( not directoryExists(HandlersPath) )
			controller.throw("The handlers directory: #handlerspath# does not exist please check your application structure or your Application Mapping.","","Framework.loaderService.HandlersDirectoryNotFoundException");

		//Get recursive Array listing
		HandlerArray = recurseListing(HandlerArray, HandlersPath, HandlersPath);

		//Verify it
		if ( ArrayLen(HandlerArray) eq 0 )
			controller.throw("No handlers were found in: #HandlerPath#. So I have no clue how you are going to run this application.","","Framework.loaderService.NoHandlersFoundException");

		//Sort The Array
		ArraySort(HandlerArray,"text");

		//Set registered Handlers
		controller.setSetting("RegisteredHandlers",arrayToList(HandlerArray));
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<cffunction name="recurseListing" access="private" output="false" returntype="array">
		<cfargument name="fileArray" type="array"  required="true">
		<cfargument name="Directory" type="string" required="true">
		<cfargument name="HandlersPath" type="string" required="true">
		<cfscript>
		var oDirectory = CreateObject("java","java.io.File").init(arguments.Directory);
		var Files = oDirectory.list();
		var i = 1;
		var tempfile = "";
		var cleanHandler = "";

		//Loop Through listing if any files found.
		for ( i=1; i lte arrayLen(Files); i=i+1 ){
			//get first reference as File Object
			tempFile = CreateObject("java","java.io.File").init(oDirectory,Files[i]);
			//Directory Check for recursion
			if ( tempFile.isDirectory() ){
				//recurse, directory found.
				arguments.fileArray = recurseListing(arguments.fileArray,tempFile.getPath(), arguments.HandlersPath);
			}
			else{
				//Filter only cfc's
				if ( listlast(tempFile.getName(),".") neq "cfc" )
					continue;
				//Clean entry by using Handler Path
				cleanHandler = replacenocase(tempFile.getAbsolutePath(),arguments.handlersPath,"","all");
				//Clean OS separators
				if ( controller.getSetting("OSFileSeparator",1) eq "/")
					cleanHandler = removeChars(replacenocase(cleanHandler,"/",".","all"),1,1);
				else
					cleanHandler = removeChars(replacenocase(cleanHandler,"\",".","all"),1,1);
				//Clean Extension
				cleanHandler = controller.getPlugin("fileUtilities").ripExtension(cleanhandler);
				//Add data to array
				ArrayAppend(arguments.fileArray,cleanHandler);
			}
		}
		return arguments.fileArray;
		</cfscript>
	</cffunction>


	<cffunction name="dump" access="private" hint="Facade for cfmx dump" returntype="void">
		<cfargument name="var" required="yes" type="any">
		<cfdump var="#var#">
	</cffunction>
	<cffunction name="abort" access="private" hint="Facade for cfabort" returntype="void" output="false">
		<cfabort>
	</cffunction>
</cfcomponent>