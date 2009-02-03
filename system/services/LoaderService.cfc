<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	This cfc takes care of debugging settings.

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="LoaderService" output="false" hint="The application and framework loader service" extends="coldbox.system.services.BaseService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="LoaderService" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			setController(arguments.controller);
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Setup Calls --->
	<cffunction name="setupCalls" returntype="void" access="public" hint="I execute the framework and application loading scripts" output="false">
		<!--- ************************************************************* --->
		<cfargument name="overrideConfigFile" type="string" required="false" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file.">
		<cfargument name="overrideAppMapping" type="string" required="false" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file."/>
		<!--- ************************************************************* --->
		<cfscript>
			//execute the configLoader
			configLoader(argumentCollection=arguments);
			//execute the handler registrations after configurations loaded
			getController().getHandlerService().registerHandlers();
		</cfscript>
	</cffunction>

	<!--- Config Loader Method --->
	<cffunction name="configLoader" returntype="void" access="Public" hint="I Load the configurations only, init the framework variables and more." output="false">
		<!--- ************************************************************* --->
		<cfargument name="overrideConfigFile" required="false" type="string" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file.">
		<cfargument name="overrideAppMapping" type="string" required="false" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file."/>
		<!--- ************************************************************* --->
		<cfscript>
			var XMLParser = "";
			var CacheConfigBean = CreateObject("Component","coldbox.system.cache.config.CacheConfigBean");
			var DebuggerConfigBean = CreateObject("Component","coldbox.system.beans.debuggerConfigBean");
			var FrameworkSettings = structNew();
			var ConfigSettings = structNew();
			
			/* Clear the Cache Dictionaries */
			controller.getPluginService().clearDictionary();
			controller.getHandlerService().clearDictionaries();
			
			//Prepare Parser
			XMLParser = controller.getPlugin("XMLParser");
			
			//Load Coldbox Config Settings Structure
			FrameworkSettings = XMLParser.loadFramework(arguments.overrideConfigFile);
			controller.setColdboxSettings(FrameworkSettings);
			
			//Create the Cache Config Bean with data from the framework's settings.xml
			CacheConfigBean.populate(FrameworkSettings);
			//Configure the Object Cache for first usage.
			controller.getColdboxOCM().configure(CacheConfigBean);
			
			//Load Application Config Settings Now that framework has been loaded.
			ConfigSettings = XMLParser.parseConfig(arguments.overrideAppMapping);
			controller.setConfigSettings(ConfigSettings);
			
			//Check for Cache OVerride Settings in Config
			if ( ConfigSettings.CacheSettings.OVERRIDE ){
				//Recreate the Config Bean
				CacheConfigBean = CacheConfigBean.init(ConfigSettings.CacheSettings.ObjectDefaultTimeout,
													   ConfigSettings.CacheSettings.ObjectDefaultLastAccessTimeout,
													   ConfigSettings.CacheSettings.ReapFrequency,
													   ConfigSettings.CacheSettings.MaxObjects,
													   ConfigSettings.CacheSettings.FreeMemoryPercentageThreshold,
													   ConfigSettings.CacheSettings.UseLastAccessTimeouts,
													   ConfigSettings.CacheSettings.EvictionPolicy);
				//Re-Configure the Object Cache.
				controller.getColdboxOCM().configure(CacheConfigBean);
			}
			
			/* Populate Debugger with settings from the framework */
			DebuggerConfigBean.populate(FrameworkSettings);
			
			/* Check for Debugger Override, if true, then overpopulate with configuration settings overriding framework settings. */
			if( ConfigSettings.DebuggerSettings.OVERRIDE ){
				DebuggerConfigBean.populate(ConfigSettings.DebuggerSettings);
			}
			
			/* Configure the Debugger with framework wide settings.*/
			controller.getDebuggerService().setDebuggerConfigBean(DebuggerConfigBean);
			
			/* Register The Interceptors */
			controller.getInterceptorService().registerInterceptors();
			
			/* Flag the initiation, Framework is ready to serve requests. Praise be to GOD. */
			controller.setColdboxInitiated(true);
			
			/* Execute afterConfigurationLoad */
			controller.getInterceptorService().processState("afterConfigurationLoad");
			
			/* Register Aspects */
			registerAspects();
			
			/* Execute afterAspectsLoad */
			controller.getInterceptorService().processState("afterAspectsLoad");			
		</cfscript>
	</cffunction>

	<!--- Register the Aspects --->
	<cffunction name="registerAspects" access="public" returntype="void" hint="I Register the current Application's Aspects" output="false" >
		<cfscript>
		/* Initialize Logging if requested. */
		if ( controller.getSetting("EnableColdboxLogging") ){
			controller.getPlugin("logger").initLogLocation();
		}
		
		/* IoC Plugin Manager Configuration */
		if ( controller.getSetting("IOCFramework") neq "" ){
			//Create IoC Factory and configure it.
			controller.getPlugin("ioc").configure();
		}

		/* Load i18N if application is using it. */
		if ( controller.getSetting("using_i18N") ){
			//Create i18n Plugin and configure it.
			controller.getPlugin("i18n").init_i18N(controller.getSetting("DefaultResourceBundle"),controller.getSetting("DefaultLocale"));
		}		
		
		/* Set Debugging Mode according to configuration File */
		controller.getDebuggerService().setDebugMode(controller.getSetting("DebugMode"));
		
		/* Flag the aspects inited. */
		controller.setAspectsInitiated(true);
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->

	

</cfcomponent>