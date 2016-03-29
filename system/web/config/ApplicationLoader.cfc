<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	 		: Luis Majano
Date     		: September 23, 2005
Description		:

Loads a coldbox cfc configuration file

----------------------------------------------------------------------->
<cfcomponent hint="Loads a coldbox configuration file" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="any" hint="constructor">
		<cfargument name="controller" 			type="any" 		required="true" default="" hint="The coldbox application to load the settings into"/>
		<cfscript>
			// setup local variables
			instance.controller = arguments.controller;
			instance.util 		= createObject( "component","coldbox.system.core.util.Util" );
			// Coldbox Settings
			instance.coldboxSettings = arguments.controller.getColdBoxSettings();

			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>

	<cffunction name="loadConfiguration" access="public" returntype="void" output="false" hint="Parse the application configuration file.">
		<!--- ************************************************************* --->
		<cfargument name="overrideAppMapping" required="false" default="" hint="The direct location of the application in the web server."/>
		<!--- ************************************************************* --->
		<cfscript>
		//Create Config Structure
		var configStruct		= structNew();
		var coldboxSettings 	= instance.coldboxSettings;
		var appRootPath 		= instance.controller.getAppRootPath();
		var configCFCLocation 	= coldboxSettings[ "ConfigFileLocation" ];
		var configCreatePath 	= "";
		var oConfig 			= "";
		var logBoxConfigHash  	= hash( instance.controller.getLogBox().getConfig().getMemento().toString() );
		var appMappingAsDots	= "";

		//Is incoming app mapping set, or do we auto-calculate
		if( NOT len( arguments.overrideAppMapping ) ){
			//AutoCalculate
			calculateAppMapping( configStruct );
		} else {
			configStruct.appMapping = arguments.overrideAppMapping;
		}

		//Default Locations for ROOT based apps, which is the default
		//Parse out the first / to create the invocation Path
		if ( left( configStruct[ "AppMapping" ],1) eq "/" ){
			configStruct[ "AppMapping" ] = removeChars( configStruct[ "AppMapping" ], 1, 1 );
		}
		//AppMappingInvocation Path
		appMappingAsDots = getAppMappingAsDots( configStruct.appMapping );

		// Config Create Path if not overriding and there is an appmapping
		if( len( appMappingAsDots ) AND NOT coldboxSettings.ConfigFileLocationOverride ){
			configCreatePath = appMappingAsDots & "." & configCFCLocation;
		}
		// Config create path if overriding or no app mapping
		else{
			configCreatePath = configCFCLocation;
		}

		// Check for non-config apps
		if( !len( configCFCLocation ) ){
			configCreatePath = "coldbox.system.web.config.Settings";
		}

		//Create config Object
		oConfig = createObject( "component", configCreatePath);

		//Decorate It
		oConfig.injectPropertyMixin = instance.util.getMixerUtil().injectPropertyMixin;
		oConfig.getPropertyMixin 	= instance.util.getMixerUtil().getPropertyMixin;

		//MixIn Variables
		oConfig.injectPropertyMixin( "controller",instance.controller);
		oConfig.injectPropertyMixin( "logBoxConfig",instance.controller.getLogBox().getConfig());
		oConfig.injectPropertyMixin( "appMapping",configStruct.appMapping);

		//Configure it
		oConfig.configure();

		//Environment detection
		detectEnvironment( oConfig, configStruct );

		/* ::::::::::::::::::::::::::::::::::::::::: APP LOCATION OVERRIDES :::::::::::::::::::::::::::::::::::::::::::: */

		// Setup Default Application Path from main controller
		configStruct.applicationPath = instance.controller.getAppRootPath();
		// Check for Override of AppMapping
		if( len( trim( arguments.overrideAppMapping ) ) ){
			configStruct.applicationPath = expandPath( arguments.overrideAppMapping ) & "/";
		}

		/* ::::::::::::::::::::::::::::::::::::::::: GET COLDBOX SETTINGS  :::::::::::::::::::::::::::::::::::::::::::: */
		parseColdboxSettings( oConfig, configStruct,arguments.overrideAppMapping );

		/* ::::::::::::::::::::::::::::::::::::::::: YOUR SETTINGS LOADING :::::::::::::::::::::::::::::::::::::::::::: */
		parseYourSettings( oConfig, configStruct );

		/* ::::::::::::::::::::::::::::::::::::::::: YOUR CONVENTIONS LOADING :::::::::::::::::::::::::::::::::::::::::::: */
		parseConventions( oConfig, configStruct );

		/* ::::::::::::::::::::::::::::::::::::::::: MODULE SETTINGS  :::::::::::::::::::::::::::::::::::::::::::: */
		parseModules( oConfig, configStruct );

		/* ::::::::::::::::::::::::::::::::::::::::: HANDLER-MODELS INVOCATION PATHS :::::::::::::::::::::::::::::::::::::::::::: */
		parseInvocationPaths( oConfig, configStruct );

		/* ::::::::::::::::::::::::::::::::::::::::: EXTERNAL LAYOUTS/VIEWS LOCATION :::::::::::::::::::::::::::::::::::::::::::: */
		parseExternalLocations( oConfig, configStruct );

		/* ::::::::::::::::::::::::::::::::::::::::: DATASOURCES SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
		parseDatasources( oConfig, configStruct );

		/* ::::::::::::::::::::::::::::::::::::::::: LAYOUT VIEW FOLDER SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
		parseLayoutsViews( oConfig, configStruct );

		/* :::::::::::::::::::::::::::::::::::::::::  CACHE SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
		parseCacheBox( oConfig, configStruct );

		/* ::::::::::::::::::::::::::::::::::::::::: INTERCEPTOR SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
		parseInterceptors( oConfig, configStruct );

		/* ::::::::::::::::::::::::::::::::::::::::: LOGBOX Configuration :::::::::::::::::::::::::::::::::::::::::::: */
		parseLogBox( oConfig, configStruct, logBoxConfigHash );

		/* ::::::::::::::::::::::::::::::::::::::::: WIREBOX Configuration :::::::::::::::::::::::::::::::::::::::::::: */
		parseWireBox( oConfig, configStruct );

		/* ::::::::::::::::::::::::::::::::::::::::: Flash Scope Configuration :::::::::::::::::::::::::::::::::::::::::::: */
		parseFlashScope( oConfig, configStruct );

		/* ::::::::::::::::::::::::::::::::::::::::: CONFIG FILE LAST MODIFIED SETTING :::::::::::::::::::::::::::::::::::::::::::: */
		configStruct.configTimeStamp = instance.util.fileLastModified( coldboxSettings[ "ConfigFileLocation" ]);

		//finish by loading configuration
		configStruct.coldboxConfig = oConfig;
		instance.controller.setConfigSettings( configStruct);
		</cfscript>
	</cffunction>

	<!--- calculateAppMapping --->
    <cffunction name="calculateAppMapping" output="false" access="public" returntype="void" hint="Calculate the AppMapping">
    	<cfargument name="configStruct" 	type="any" required="true" hint="The config struct"/>
		<cfscript>
			// Get the web path from CGI.
			var	webPath = replacenocase( cgi.script_name,getFileFromPath( cgi.script_name),"" );
			// Cleanup the template path
			var localPath = getDirectoryFromPath(replacenocase(getTemplatePath(),"\","/","all" ));
			// Verify Path Location
			var pathLocation = findnocase(webPath, localPath);

			if ( pathLocation ){
				arguments.configStruct.appMapping = mid(localPath,pathLocation,len(webPath));
			}
			else{
				arguments.configStruct.appMapping = webPath;
			}

			//Clean last /
			if ( right(arguments.configStruct.AppMapping,1) eq "/" ){
				if ( len(arguments.configStruct.AppMapping) -1 gt 0)
					arguments.configStruct.AppMapping = left(arguments.configStruct.AppMapping,len(arguments.configStruct.AppMapping)-1);
				else
					arguments.configStruct.AppMapping = "";
			}

			//Clean j2ee context
			if( len(getContextRoot()) ){
				arguments.configStruct.AppMapping = replacenocase(arguments.configStruct.AppMapping,getContextRoot(),"" );
			}
    	</cfscript>
    </cffunction>

	<!--- parseColdboxSettings --->
	<cffunction name="parseColdboxSettings" output="false" access="public" returntype="void" hint="Parse ColdBox Settings">
		<cfargument name="oConfig" 				type="any" 		required="true" hint="The config object"/>
		<cfargument name="config" 				type="any" 	required="true" hint="The config struct"/>
		<cfargument name="overrideAppMapping" required="false" type="any" default="" hint="The direct location of the application in the web server."/>
		<cfscript>
			var configStruct 		= arguments.config;
			var fwSettingsStruct 	= instance.coldboxSettings;
			var coldboxSettings 	= arguments.oConfig.getPropertyMixin( "coldbox", "variables", structnew() );

			// collection append
			structAppend( configStruct, coldboxSettings, true );

			// Common Structures
			configStruct.layoutsRefMap 	= structnew();
			configStruct.viewsRefMap	= structnew();

			/* ::::::::::::::::::::::::::::::::::::::::: COLDBOX SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */

			//Check for AppName
			if ( not structKeyExists( configStruct, "AppName" ) ){
				configStruct[ "AppName" ] = application.applicationName;
			}
			//Check for Default Event
			if ( not structKeyExists( configStruct, "DefaultEvent" ) OR NOT len( configStruct[ "DefaultEvent" ] ) ){
				configStruct[ "DefaultEvent" ] = fwSettingsStruct[ "DefaultEvent" ];
			}
			//Check for Event Name
			if ( not structKeyExists( configStruct, "EventName" ) ){
				configStruct[ "EventName" ] = fwSettingsStruct[ "EventName" ] ;
			}
			//Check for Application Start Handler
			if ( not structKeyExists( configStruct, "ApplicationStartHandler" ) ){
				configStruct[ "ApplicationStartHandler" ] = "";
			}
			//Check for Application End Handler
			if ( not structKeyExists( configStruct, "ApplicationEndHandler" ) ){
				configStruct[ "applicationEndHandler" ] = "";
			}
			//Check for Request End Handler
			if ( not structKeyExists( configStruct, "RequestStartHandler" ) ){
				configStruct[ "RequestStartHandler" ] = "";
			}
			//Check for Application Start Handler
			if ( not structKeyExists( configStruct, "RequestEndHandler" ) ){
				configStruct[ "RequestEndHandler" ] = "";
			}
			//Check for Session Start Handler
			if ( not structKeyExists( configStruct, "SessionStartHandler" ) ){
				configStruct[ "SessionStartHandler" ] = "";
			}
			//Check for Session End Handler
			if ( not structKeyExists( configStruct, "SessionEndHandler" ) ){
				configStruct[ "SessionEndHandler" ] = "";
			}
			//Check for InvalidEventHandler
			if ( not structKeyExists( configStruct, "onInvalidEvent" ) ){
				configStruct[ "onInvalidEvent" ] = "";
			}
			//Check for Implicit Views
			if ( not structKeyExists( configStruct, "ImplicitViews" ) OR not isBoolean( configStruct.implicitViews) ){
				configStruct[ "ImplicitViews" ] = true;
			}
			//Check for ReinitPassword
			if ( not structKeyExists( configStruct, "ReinitPassword" ) ){ 
				configStruct[ "ReinitPassword" ] = hash( createUUID() ); 
			}
			else if( len( configStruct[ "ReinitPassword" ]) ){ 
				configStruct[ "ReinitPassword" ] = hash( configStruct[ "ReinitPassword" ] ); 
			}
			//Check For ApplicationHelper
			if ( not structKeyExists( configStruct, "applicationHelper" ) ){
				configStruct[ "applicationHelper" ] = [];
			}
			// inflate if needed to array
			if( isSimpleValue( configStruct[ "applicationHelper" ] ) ){
				configStruct[ "applicationHelper" ] = listToArray( configStruct[ "applicationHelper" ] );
			}
			//Check For viewsHelper
			if ( not structKeyExists( configStruct, "viewsHelper" ) ){
				configStruct[ "viewsHelper" ] = "";
			}
			//Check For CustomErrorTemplate
			if ( not structKeyExists( configStruct, "CustomErrorTemplate" ) ){
				configStruct[ "CustomErrorTemplate" ] = "";
			}
			//Check for HandlersIndexAutoReload, default = false
			if ( not structKeyExists( configStruct, "HandlersIndexAutoReload" ) or not isBoolean( configStruct.HandlersIndexAutoReload ) ){
				configStruct[ "HandlersIndexAutoReload" ] = false;
			}
			//Check for ExceptionHandler if found
			if ( not structKeyExists( configStruct, "ExceptionHandler" ) ){
				configStruct[ "ExceptionHandler" ] = "";
			}
			//Check for Handler Caching
			if ( not structKeyExists( configStruct, "HandlerCaching" ) or not isBoolean( configStruct.HandlerCaching ) ){
				configStruct[ "HandlerCaching" ] = true;
			}
			//Check for Event Caching
			if ( not structKeyExists( configStruct, "eventCaching" ) or not isBoolean( configStruct.eventCaching ) ){
				configStruct[ "eventCaching" ] = true;
			}
			//Check for View Caching
			if ( not structKeyExists( configStruct, "viewCaching" ) or not isBoolean( configStruct.viewCaching ) ){
				configStruct[ "viewCaching" ] = true;
			}
			//RequestContextDecorator
			if ( not structKeyExists( configStruct, "RequestContextDecorator" ) or len( configStruct[ "RequestContextDecorator" ] ) eq 0 ){
				configStruct[ "RequestContextDecorator" ] = "";
			}
			//ControllerDecorator
			if ( not structKeyExists( configStruct, "ControllerDecorator" ) or len( configStruct[ "ControllerDecorator" ] ) eq 0 ){
				configStruct[ "ControllerDecorator" ] = "";
			}
			//Check for ProxyReturnCollection
			if ( not structKeyExists( configStruct, "ProxyReturnCollection" ) or not isBoolean( configStruct.ProxyReturnCollection ) ){
				configStruct[ "ProxyReturnCollection" ] = false;
			}
			//Check for External Handlers Location
			if ( not structKeyExists( configStruct, "HandlersExternalLocation" ) or len( configStruct[ "HandlersExternalLocation" ] ) eq 0 ){
				configStruct[ "HandlersExternalLocation" ] = "";
			}
			//Check for Missing Template Handler
			if ( not structKeyExists( configStruct, "MissingTemplateHandler" ) ){
				configStruct[ "MissingTemplateHandler" ] = "";
			}
			//Modules Configuration
			if( not structKeyExists( configStruct,"ModulesExternalLocation" ) ){
				configStruct.ModulesExternalLocation = arrayNew(1);
			}
			if( isSimpleValue( configStruct.ModulesExternalLocation) ){
				configStruct.ModulesExternalLocation = listToArray( configStruct.ModulesExternalLocation );
			}
		</cfscript>
	</cffunction>

	<!--- parseYourSettings --->
	<cffunction name="parseYourSettings" output="false" access="public" returntype="void" hint="Parse Your Settings">
		<cfargument name="oConfig" 	type="any" 	  required="true" hint="The config object"/>
		<cfargument name="config" 	type="any" required="true" hint="The config struct"/>
		<cfscript>
			var configStruct = arguments.config;
			var settings = arguments.oConfig.getPropertyMixin( "settings","variables",structnew());

			//append it
			structAppend( configStruct,settings,true);
		</cfscript>
	</cffunction>

	<!--- parseConventions --->
	<cffunction name="parseConventions" output="false" access="public" returntype="void" hint="Parse Conventions">
		<cfargument name="oConfig" 	type="any" 	  required="true" hint="The config object"/>
		<cfargument name="config" 	type="any" required="true" hint="The config struct"/>
		<cfscript>
			var configStruct = arguments.config;
			var fwSettingsStruct = instance.coldboxSettings;
			var conventions = arguments.oConfig.getPropertyMixin( "conventions","variables",structnew());

			// Override conventions on a per found basis.
			if( structKeyExists( conventions,"handlersLocation" ) ){ fwSettingsStruct[ "handlersConvention" ] = trim( conventions.handlersLocation); }
			if( structKeyExists( conventions,"layoutsLocation" ) ){ fwSettingsStruct[ "LayoutsConvention" ] = trim( conventions.layoutsLocation); }
			if( structKeyExists( conventions,"viewsLocation" ) ){ fwSettingsStruct[ "ViewsConvention" ] = trim( conventions.viewsLocation); }
			if( structKeyExists( conventions,"eventAction" ) ){ fwSettingsStruct[ "eventAction" ] = trim( conventions.eventAction); }
			if( structKeyExists( conventions,"modelsLocation" ) ){ fwSettingsStruct[ "ModelsConvention" ] = trim( conventions.modelsLocation); }
			if( structKeyExists( conventions,"modulesLocation" ) ){ fwSettingsStruct[ "ModulesConvention" ] = trim( conventions.modulesLocation); }
		</cfscript>
	</cffunction>

	<!--- parseInvocationPaths --->
	<cffunction name="parseInvocationPaths" output="false" access="public" returntype="void" hint="Parse Invocation paths">
		<cfargument name="oConfig" 	type="any" 	  required="true" hint="The config object"/>
		<cfargument name="config" 	type="any" required="true" hint="The config struct"/>
		<cfscript>
			var configStruct = arguments.config;
			var fwSettingsStruct = instance.coldboxSettings;
			var appMappingAsDots = "";

			// Handler Registration
			configStruct[ "HandlersInvocationPath" ] = reReplace(fwSettingsStruct.handlersConvention,"(/|\\)",".","all" );
			configStruct[ "HandlersPath" ] = fwSettingsStruct.ApplicationPath & fwSettingsStruct.handlersConvention;
			// Models Registration
			configStruct[ "ModelsInvocationPath" ] = reReplace(fwSettingsStruct.ModelsConvention,"(/|\\)",".","all" );
			configStruct[ "ModelsPath" ] = fwSettingsStruct.ApplicationPath & fwSettingsStruct.ModelsConvention;

			//Set the Handlers, Models Invocation & Physical Path for this Application
			if( len( configStruct[ "AppMapping" ]) ){
				appMappingAsDots = reReplace( configStruct[ "AppMapping" ],"(/|\\)",".","all" );
				// Handler Path Registrations
				configStruct[ "HandlersInvocationPath" ] = appMappingAsDots & ".#reReplace(fwSettingsStruct.handlersConvention,"(/|\\)",".","all" )#";
				configStruct[ "HandlersPath" ] = "/" & configStruct.AppMapping & "/#fwSettingsStruct.handlersConvention#";
				configStruct[ "HandlersPath" ] = expandPath( configStruct[ "HandlersPath" ]);
				// Model Registrations
				configStruct[ "ModelsInvocationPath" ] = appMappingAsDots & ".#reReplace(fwSettingsStruct.ModelsConvention,"(/|\\)",".","all" )#";
				configStruct[ "ModelsPath" ] = "/" & configStruct.AppMapping & "/#fwSettingsStruct.ModelsConvention#";
				configStruct[ "ModelsPath" ] = expandPath( configStruct[ "ModelsPath" ]);
			}

			//Set the Handlers External Configuration Paths
			configStruct[ "HandlersExternalLocationPath" ] = "";
			if( len( configStruct[ "HandlersExternalLocation" ]) ){
				//Expand the external location to get a registration path
				configStruct[ "HandlersExternalLocationPath" ] = ExpandPath( "/" & replace( configStruct[ "HandlersExternalLocation" ],".","/","all" ));
			}

			//Configure the modules locations for the conventions not the external ones.
			if( len( configStruct.AppMapping) ){
				configStruct.ModulesLocation 		= "/#configStruct.AppMapping#/#fwSettingsStruct.ModulesConvention#";
				configStruct.ModulesInvocationPath	= appMappingAsDots & ".#reReplace(fwSettingsStruct.ModulesConvention,"(/|\\)",".","all" )#";
			}
			else{
				configStruct.ModulesLocation 		= "/#fwSettingsStruct.ModulesConvention#";
				configStruct.ModulesInvocationPath 	= reReplace(fwSettingsStruct.ModulesConvention,"(/|\\)",".","all" );
			}
			configStruct.ModulesPath = fwSettingsStruct.ApplicationPath & fwSettingsStruct.ModulesConvention;
		</cfscript>
	</cffunction>

	<!--- parseExternalLocations --->
	<cffunction name="parseExternalLocations" output="false" access="public" returntype="void" hint="Parse External locations">
		<cfargument name="oConfig" 	type="any" 	  required="true" hint="The config object"/>
		<cfargument name="config" 	type="any" required="true" hint="The config struct"/>
		<cfscript>
			var configStruct = arguments.config;
			var fwSettingsStruct = instance.coldboxSettings;

			// ViewsExternalLocation Setup
			if( structKeyExists( configStruct,"ViewsExternalLocation" ) and len( configStruct[ "ViewsExternalLocation" ]) ){
				// Verify the locations, do relative to the app mapping first
				if( directoryExists(fwSettingsStruct.ApplicationPath & configStruct[ "ViewsExternalLocation" ]) ){
					configStruct[ "ViewsExternalLocation" ] = "/" & configStruct[ "AppMapping" ] & "/" & configStruct[ "ViewsExternalLocation" ];
				}
				else if( not directoryExists(expandPath( configStruct[ "ViewsExternalLocation" ])) ){
					throw( "ViewsExternalLocation could not be found.","The directories tested was relative and expanded using #configStruct['ViewsExternalLocation']#. Please verify your setting.","XMLApplicationLoader.ConfigXMLParsingException" );
				}
				// Cleanup
				if ( right( configStruct[ "ViewsExternalLocation" ],1) eq "/" ){
					 configStruct[ "ViewsExternalLocation" ] = left( configStruct[ "ViewsExternalLocation" ],len( configStruct[ "ViewsExternalLocation" ])-1);
				}
			}
			else{
				configStruct[ "ViewsExternalLocation" ] = "";
			}

			// LayoutsExternalLocation Setup
			if( structKeyExists( configStruct,"LayoutsExternalLocation" ) and configStruct[ "LayoutsExternalLocation" ] neq "" ){
				// Verify the locations, do relative to the app mapping first
				if( directoryExists(fwSettingsStruct.ApplicationPath & configStruct[ "LayoutsExternalLocation" ]) ){
					configStruct[ "LayoutsExternalLocation" ] = "/" & configStruct[ "AppMapping" ] & "/" & configStruct[ "LayoutsExternalLocation" ];
				}
				else if( not directoryExists(expandPath( configStruct[ "LayoutsExternalLocation" ])) ){
					throw( "LayoutsExternalLocation could not be found.","The directories tested was relative and expanded using #configStruct['LayoutsExternalLocation']#. Please verify your setting.","XMLApplicationLoader.ConfigXMLParsingException" );
				}
				// Cleanup
				if ( right( configStruct[ "LayoutsExternalLocation" ],1) eq "/" ){
					 configStruct[ "LayoutsExternalLocation" ] = left( configStruct[ "LayoutsExternalLocation" ],len( configStruct[ "LayoutsExternalLocation" ])-1);
				}
			}
			else{
				configStruct[ "LayoutsExternalLocation" ] = "";
			}
		</cfscript>
	</cffunction>

	<!--- parseDatasources --->
	<cffunction name="parseDatasources" output="false" access="public" returntype="void" hint="Parse Datsources">
		<cfargument name="oConfig" 	  type="any" 	  required="true" hint="The config object"/>
		<cfargument name="config" 	type="any" required="true" hint="The config struct"/>
		<cfscript>
			var configStruct = arguments.config;
			var datasources = arguments.oConfig.getPropertyMixin( "datasources","variables",structnew());
			var key = "";

			// Defaults
			configStruct.datasources = structnew();

			//loop over datasources
			for( key in datasources ){

				if( NOT structKeyExists(datasources[key],"name" ) ){
					throw( "This datasource #key# entry's name cannot be blank","","CFCApplicationLoader.DatasourceException" );
				}
				// defaults
				if( NOT structKeyExists(datasources[key],"username" ) ){
					datasources[key].username = "";
				}
				if( NOT structKeyExists(datasources[key],"password" ) ){
					datasources[key].password = "";
				}
				if( NOT structKeyExists(datasources[key],"dbType" ) ){
					datasources[key].dbType = "";
				}
				// save datasoure definition
				configStruct.datasources[key] = datasources[key];
			}
		</cfscript>
	</cffunction>

	<!--- parseLayoutsViews --->
	<cffunction name="parseLayoutsViews" output="false" access="public" returntype="void" hint="Parse Layouts And Views">
		<cfargument name="oConfig" 	type="any" 	  required="true" hint="The config object"/>
		<cfargument name="config" 	type="any" required="true" hint="The config struct"/>
		<cfscript>
			var configStruct 		= arguments.config;
			var	LayoutViewStruct 	= CreateObject( "java","java.util.LinkedHashMap" ).init();
			var	LayoutFolderStruct 	= CreateObject( "java","java.util.LinkedHashMap" ).init();
			var key 				= "";
			var layoutSettings 		= arguments.oConfig.getPropertyMixin( "layoutSettings","variables",structnew());
			var layouts 			= arguments.oConfig.getPropertyMixin( "layouts","variables",arrayNew(1));
			var i 					= 1;
			var x 					= 1;
			var thisLayout			= "";
			var layoutsArray 		= arrayNew(1);
			var fwSettingsStruct 	= instance.coldboxSettings;

			// defaults
			configStruct.defaultLayout 		= fwSettingsStruct.defaultLayout;
			configStruct.defaultView 		= "";
			configStruct.registeredLayouts  = structnew();

			// Register layout settings
			structAppend( configStruct, layoutSettings );

			// Check blank defaultLayout
			if( !len( trim( configStruct.defaultLayout ) ) ){
				configStruct.defaultLayout = fwSettingsStruct.defaultLayout;
			}

			// registered layouts
			if( isStruct( layouts ) ){
				// process structure into array
				for( key in layouts ){
					thisLayout = layouts[ key ];
					thisLayout.name = key;
					arrayAppend( layoutsArray, thisLayout );
				}
			}
			else{
				layoutsArray = layouts;
			}

			// Process layouts
			for(x=1; x lte ArrayLen(layoutsArray); x=x+1){
				thisLayout = layoutsArray[x];

				// register file with alias
				configStruct.registeredLayouts[thisLayout.name] = thisLayout.file;

				// register views
				if( structKeyExists(thisLayout,"views" ) ){
					for(i=1; i lte listLen(thislayout.views); i=i+1){
						if ( not StructKeyExists(LayoutViewStruct, lcase( listGetAt(thisLayout.views,i) ) ) ){
							LayoutViewStruct[lcase( listGetAt(thisLayout.views,i) )] = thisLayout.file;
						}
					}
				}

				// register folders
				if( structKeyExists(thisLayout,"folders" ) ){
					for(i=1; i lte listLen(thisLayout.folders); i=i+1){
						if ( not StructKeyExists(LayoutFolderStruct, lcase( listGetAt(thisLayout.folders,i) ) ) ){
							LayoutFolderStruct[lcase( listGetAt(thisLayout.folders,i) )] = thisLayout.file;
						}
					}
				}
			}

			// Register extra layout/view/folder combos
			configStruct.ViewLayouts   = LayoutViewStruct;
			configStruct.FolderLayouts = LayoutFolderStruct;
		</cfscript>
	</cffunction>

	<!--- parseCacheBox --->
	<cffunction name="parseCacheBox" output="false" access="public" returntype="void" hint="Parse Cache Settings for CacheBox operation">
		<cfargument name="oConfig" 		type="any" 	   required="true" hint="The config object"/>
		<cfargument name="config" 	  	type="any"  required="true" hint="The config struct"/>
		<cfscript>
			var configStruct 		= arguments.config;
			var fwSettingsStruct 	= instance.coldboxSettings;

			// CacheBox Defaults
			configStruct.cacheBox				= structnew();
			configStruct.cacheBox.dsl  			= arguments.oConfig.getPropertyMixin( "cacheBox","variables",structnew());
			configStruct.cacheBox.xml  			= "";
			configStruct.cacheBox.configFile 	= "";

			// Check if we have defined DSL first in application config
			if( NOT structIsEmpty( configStruct.cacheBox.dsl) ){

				// Do we have a configFile key for external loading?
				if( structKeyExists( configStruct.cacheBox.dsl,"configFile" ) ){
					configStruct.cacheBox.configFile = configStruct.cacheBox.dsl.configFile;
				}

			}
			// Check if LogBoxConfig.cfc exists in the config conventions
			else if( fileExists( instance.controller.getAppRootPath() & "config/CacheBox.cfc" ) ){
				configStruct.cacheBox.configFile = loadCacheBoxByConvention( configStruct);
			}
			// else, load the default coldbox cachebox config
			else{
				configStruct.cacheBox.configFile = "coldbox.system.web.config.CacheBox";
			}
		</cfscript>
	</cffunction>

	<!--- parseInterceptors --->
	<cffunction name="parseInterceptors" output="false" access="public" returntype="void" hint="Parse Interceptors">
		<cfargument name="oConfig" 		type="any" 	   required="true" hint="The config object"/>
		<cfargument name="config" 		type="any"  required="true" hint="The config struct"/>
		<cfscript>
			var configStruct = arguments.config;
			var x = 1;
			var interceptorSettings = arguments.oConfig.getPropertyMixin( "interceptorSettings","variables",structnew());
			var interceptors = arguments.oConfig.getPropertyMixin( "interceptors","variables",arrayNew(1));

			//defaults
			configStruct.interceptorConfig = structnew();
			configStruct.interceptorConfig.interceptors = arrayNew(1);
			configStruct.interceptorConfig.throwOnInvalidStates = false;
			configStruct.interceptorConfig.customInterceptionPoints = "";

			//Append settings
			structAppend( configStruct.interceptorConfig,interceptorSettings,true);

			//Register interceptors
			for(x=1; x lte arrayLen(interceptors); x=x+1){
				//Name check
				if( NOT structKeyExists(interceptors[x],"name" ) ){
					interceptors[x].name = listLast(interceptors[x].class,"." );
				}
				//Properties check
				if( NOT structKeyExists(interceptors[x],"properties" ) ){
					interceptors[x].properties = structnew();
				}

				//Register it
				arrayAppend( configStruct.interceptorConfig.interceptors, interceptors[x]);
			}
		</cfscript>
	</cffunction>

	<!--- parseLogBox --->
	<cffunction name="parseLogBox" output="false" access="public" returntype="void" hint="Parse LogBox">
		<cfargument name="oConfig" 		type="any" 	   required="true" hint="The config object"/>
		<cfargument name="config" 		type="any"  required="true" hint="The config struct"/>
		<cfargument name="configHash"   type="any"  required="true" hint="The initial logBox config hash"/>
		<cfscript>
			var logBoxConfig 	  = instance.controller.getLogBox().getConfig();
			var newConfigHash 	  = hash(logBoxConfig.getMemento().toString());
			var logBoxDSL		  = structnew();
			var key				  = "";

			// Default Config Structure
			arguments.config[ "LogBoxConfig" ] = structnew();

			// Check if we have defined DSL first in application config
			logBoxDSL = arguments.oConfig.getPropertyMixin( "logBox","variables",structnew());
			if( NOT structIsEmpty(logBoxDSL) ){
				// Reset Configuration we have declared a configuration DSL
				logBoxConfig.reset();

				// Do we have a configFile key?
				if( structKeyExists(logBoxDSL,"configFile" ) ){
					// Load by file
					loadLogBoxByFile( logBoxConfig, logBoxDSL.configFile);
				}
				// Then we load via the DSL data.
				else{
					// Load the Data Configuration DSL
					logBoxConfig.loadDataDSL( logBoxDSL );
				}

				// Store for reconfiguration
				arguments.config[ "LogBoxConfig" ] = logBoxConfig.getMemento();
			}
			// Check if LogBoxConfig.cfc exists in the config conventions and load it.
			else if( fileExists( instance.controller.getAppRootPath() & "config/LogBox.cfc" ) ){
				loadLogBoxByConvention(logBoxConfig,arguments.config);
			}
			// Check if hash changed by means of programmatic object config
			else if( compare(arguments.configHash, newConfigHash) neq 0 ){
				arguments.config[ "LogBoxConfig" ] = logBoxConfig.getMemento();
			}
		</cfscript>
	</cffunction>

	<!--- parseWireBox --->
	<cffunction name="parseWireBox" output="false" access="public" returntype="void" hint="Parse WireBox">
		<cfargument name="oConfig" 		type="any" 	   required="true" hint="The config object"/>
		<cfargument name="config" 		type="any"  required="true" hint="The config struct"/>
		<cfscript>
			var wireBoxDSL		  = structnew();

			// Default Config Structure
			arguments.config.wirebox 			= structnew();
			arguments.config.wirebox.enabled	= true;
			arguments.config.wirebox.binder		= "";
			arguments.config.wirebox.binderPath	= "";
			arguments.config.wirebox.singletonReload = false;

			// Check if we have defined DSL first in application config
			wireBoxDSL = arguments.oConfig.getPropertyMixin( "wireBox","variables",structnew());

			// Get Binder Paths
			if( structKeyExists(wireBoxDSL,"binder" ) ){
				arguments.config.wirebox.binderPath = wireBoxDSL.binder;
			}
			// Check if WireBox.cfc exists in the config conventions, if so create binder
			else if( fileExists( instance.controller.getAppRootPath() & "config/WireBox.cfc" ) ){
				arguments.config.wirebox.binderPath = "config.WireBox";
				if( len(arguments.config.appMapping) ){
					arguments.config.wirebox.binderPath = arguments.config.appMapping & ".#arguments.config.wirebox.binderPath#";
				}
			}

			// Singleton reload
			if( structKeyExists(wireBoxDSL,"singletonReload" ) ){
				arguments.config.wirebox.singletonReload = wireBoxDSL.singletonReload;
			}
		</cfscript>
	</cffunction>

	<!--- parseFlashScope --->
	<cffunction name="parseFlashScope" output="false" access="public" returntype="void" hint="Parse ORM settings">
		<cfargument name="oConfig" 		type="any" 	   required="true" hint="The config object"/>
		<cfargument name="config" 		type="any"  required="true" hint="The config struct"/>
		<cfscript>
			var flashScopeDSL	  	= structnew();
			var fwSettingsStruct 	= instance.coldboxSettings;

			// Default Config Structure
			arguments.config.flash 	= fwSettingsStruct.flash;

			// Check if we have defined DSL first in application config
			flashScopeDSL = arguments.oConfig.getPropertyMixin( "flash","variables",structnew());

			// check if empty or not, if not, then append and override
			if( NOT structIsEmpty( flashScopeDSL ) ){
				structAppend( arguments.config.flash, flashScopeDSL, true);
			}
		</cfscript>
	</cffunction>

	<!--- parseModules --->
	<cffunction name="parseModules" output="false" access="public" returntype="void" hint="Parse Module Settings">
		<cfargument name="oConfig" 		type="any" 	   required="true" hint="The config object"/>
		<cfargument name="config" 	  	type="any"  required="true" hint="The config struct"/>
		<cfscript>
			var configStruct  = arguments.config;
			var modules 	  = arguments.oConfig.getPropertyMixin( "modules","variables",structnew());

			// Defaults
			configStruct.ModulesAutoReload  = false;
			configStruct.ModulesInclude		= arrayNew(1);
			configStruct.ModulesExclude		= arrayNew(1);
			configStruct.Modules 			= structNew();

			if( structKeyExists(modules,"autoReload" ) ){ configStruct.modulesAutoReload = modules.autoReload; }
			if( structKeyExists(modules,"include" ) ){ configStruct.modulesInclude = modules.include; }
			if( structKeyExists(modules,"exclude" ) ){ configStruct.modulesExclude = modules.exclude; }

		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>

	<cffunction name="detectEnvironment" access="private" returntype="void" hint="Detect the running environment and return the name" output="false" >
		<cfargument name="oConfig" 		type="any" 	    required="true" hint="The config object"/>
		<cfargument name="config" 		type="any" 	required="true" hint="The config struct"/>
		<cfscript>
			var environments = arguments.oConfig.getPropertyMixin( "environments","variables",structnew());
			var configStruct = arguments.config;
			var key = "";
			var i = 1;

			// Set default to production
			configStruct.environment = "production";

			// is detection is custom
			if( structKeyExists(arguments.oConfig,"detectEnvironment" ) ){
				//detect custom environment
				configStruct.environment = arguments.oConfig.detectEnvironment();
			}
			else{
				// loop over environments and do coldbox environment detection
				for(key in environments){
					// loop over patterns
					for(i=1; i lte listLen(environments[key]); i=i+1){
						if( reFindNoCase(listGetAt(environments[key],i), cgi.http_host) ){
							// set new environment
							configStruct.environment = key;
						}
					}
				}
			}

			// call environment method if exists
			if( structKeyExists(arguments.oConfig,configStruct.environment) ){
				evaluate( "arguments.oConfig.#configStruct.environment#()" );
			}
		</cfscript>
	</cffunction>

	<!--- loadLogBoxByConvention --->
    <cffunction name="loadLogBoxByConvention" output="false" access="private" returntype="void" hint="Load logBox by convention">
    	<cfargument name="logBoxConfig" type="any" required="true"/>
    	<cfargument name="config" 		type="any" required="true"/>
		<cfscript>
    		var appRootPath 	  = instance.controller.getAppRootPath();
			var appMappingAsDots  = "";
			var configCreatePath  = "config.LogBox";

			// Reset Configuration we have declared a configuration DSL
			arguments.logBoxConfig.reset();
			//AppMappingInvocation Path
			appMappingAsDots = getAppMappingAsDots(arguments.config.appMapping);
			//Config Create Path
			if( len(appMappingAsDots) ){
				configCreatePath = appMappingAsDots & "." & configCreatePath;
			}
			arguments.logBoxConfig.init( CFCConfigPath=configCreatePath).validate();
			arguments.config[ "LogBoxConfig" ] = arguments.logBoxConfig.getMemento();
		</cfscript>
    </cffunction>

	<!--- loadLogBoxByFile --->
    <cffunction name="loadLogBoxByFile" output="false" access="private" returntype="void" hint="Load logBox by file">
    	<cfargument name="logBoxConfig" type="any" 		required="true"/>
    	<cfargument name="filePath" 	type="any" 		required="true"/>
		<cfscript>
    		// Load according xml?
			if( listFindNoCase( "cfm,xml", listLast(arguments.filePath,"." )) ){
				arguments.logBoxConfig.init(XMLConfig=arguments.filePath).validate();
			}
			// Load according to CFC Path
			else{
				arguments.logBoxConfig.init( CFCConfigPath=arguments.filePath).validate();
			}
		</cfscript>
    </cffunction>

	<!--- loadCacheBoxByConvention --->
    <cffunction name="loadCacheBoxByConvention" output="false" access="private" returntype="any" hint="Basically get the right config file to load in place">
    	<cfargument name="config" type="any" required="true"/>
		<cfscript>
    		var appRootPath 	  = instance.controller.getAppRootPath();
			var appMappingAsDots  = "";
			var configCreatePath  = "config.CacheBox";

			//AppMappingInvocation Path
			appMappingAsDots = getAppMappingAsDots(arguments.config.appMapping);

			//Config Create Path
			if( len(appMappingAsDots) ){
				configCreatePath = appMappingAsDots & "." & configCreatePath;
			}

			return configCreatePath;
		</cfscript>
    </cffunction>

    <!--- getAppMappingAsDots --->
    <cffunction name="getAppMappingAsDots" output="false" access="private" returntype="any" hint="Get the App Mapping as Dots">
    	<cfargument name="appMapping" type="any" required="true" />
		<cfscript>
			return reReplace(arguments.appMapping,"(/|\\)",".","all" );
		</cfscript>
    </cffunction>

</cfcomponent>