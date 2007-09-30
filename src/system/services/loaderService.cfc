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
<cfcomponent name="loaderService" output="false" hint="The application and framework loader service" extends="baseService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="loaderService" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			setController(arguments.controller);
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Setup Calls --->
	<cffunction name="setupCalls" returntype="void" access="public" hint="I execute the configuration and configuration.." output="false">
		<!--- ************************************************************* --->
		<cfargument name="overrideConfigFile" type="string" required="false" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file.">
		<cfargument name="overrideAppMapping" type="string" required="false" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file."/>
		<!--- ************************************************************* --->
		<cfscript>
			//execute the configLoader
			configLoader(argumentCollection=arguments);
			//execute the handler registrations
			registerHandlers();
		</cfscript>
	</cffunction>

	<!--- Config Loader Method --->
	<cffunction name="configLoader" returntype="void" access="Public" hint="I Load the configurations, init the framework variables and more." output="false">
		<!--- ************************************************************* --->
		<cfargument name="overrideConfigFile" required="false" type="string" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file.">
		<cfargument name="overrideAppMapping" type="string" required="false" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file."/>
		<!--- ************************************************************* --->
		<cfscript>
			var XMLParser = controller.getPlugin("XMLParser");
			var CacheConfigBean = CreateObject("Component","coldbox.system.beans.cacheConfigBean");
			var FrameworkSettings = structNew();
			var ConfigSettings = structNew();
	
			//Load Coldbox Config Settings Structure
			FrameworkSettings = XMLParser.loadFramework(arguments.overrideConfigFile);
			controller.setColdboxSettings(FrameworkSettings);
	
			//Create the Cache Config Bean with data from the framework's settings.xml
			CacheConfigBean = CacheConfigBean.init(FrameworkSettings.CacheObjectDefaultTimeout,
												   FrameworkSettings.CacheObjectDefaultLastAccessTimeout,
												   FrameworkSettings.CacheReapFrequency,
												   FrameworkSettings.CacheMaxObjects,
												   FrameworkSettings.CacheFreeMemoryPercentageThreshold);
			
			//Configure the Object Cache for first usage.
			controller.getColdboxOCM().configure(CacheConfigBean);
	
			//Load Application Config Settings Now that framework has been loaded.
			ConfigSettings =XMLParser.parseConfig(arguments.overrideAppMapping);
			controller.setConfigSettings(ConfigSettings);
			
			//Check for Cache OVerride Settings in Config
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
			
			//Register The Interceptors
			getController().getInterceptorService().registerInterceptors();
			
			//Execute afterConfigurationLoad
			getController().getInterceptorService().processState("afterConfigurationLoad");
			
			//Register Aspects
			registerAspects();
	
			//Execute afterAspectsLoad
			getController().getInterceptorService().processState("afterAspectsLoad");
			
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
	
	<!--- Register the Aspects --->
	<cffunction name="registerAspects" access="public" returntype="void" hint="Register the Aspects" output="false" >
		<cfscript>
		//IoC Plugin Manager Configuration
		if ( controller.getSetting("IOCFramework") neq "" ){
			//Create IoC Factory and configure it.
			controller.getPlugin("ioc").configure();
		}

		//Load i18N if application is using it.
		if ( controller.getSetting("using_i18N") ){
			//Create i18n Plugin and configure it.
			controller.getPlugin("i18n").init_i18N(controller.getSetting("DefaultResourceBundle"),controller.getSetting("DefaultLocale"));
		}

		//Initialize AOP Logging if requested.
		if ( controller.getSetting("EnableColdboxLogging") ){
			controller.getPlugin("logger").initLogLocation();
		}

		//Set Debugging Mode according to configuration File
		controller.getDebuggerService().setDebugMode(controller.getSetting("DebugMode"));
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- Recursive Registration of Handler Directories --->
	<cffunction name="recurseListing" access="private" output="false" returntype="array" hint="Recursive creation of handlers in a directory.">
		<!--- ************************************************************* --->
		<cfargument name="fileArray" 	type="array"  required="true">
		<cfargument name="Directory" 	type="string" required="true">
		<cfargument name="HandlersPath" type="string" required="true">
		<!--- ************************************************************* --->
		<cfscript>
		var oDirectory = CreateObject("java","java.io.File").init(arguments.Directory);
		var Files = oDirectory.list();
		var i = 1;
		var tempfile = "";
		var cleanHandler = "";

		//Loop Through listing if any files found.
		for (; i lte arrayLen(Files); i=i+1 ){
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
				cleanHandler = controller.getPlugin("Utilities").ripExtension(cleanhandler);
				//Add data to array
				ArrayAppend(arguments.fileArray,cleanHandler);
			}
		}
		return arguments.fileArray;
		</cfscript>
	</cffunction>

</cfcomponent>