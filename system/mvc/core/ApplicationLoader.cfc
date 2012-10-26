/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 		: Luis Majano
Description		:
Loads a coldbox CFC configuration file
*/
component accessors="true"{

	// The ColdBox controller
	property name="controller";

	/************************************** CONSTRUCTOR *********************************************/

	function init(required controller){
		// setup local variables
		variables.controller = arguments.controller;
		return this;
	}
	/************************************** PUBLIC *********************************************/
	
	/**
	* Load a ColdBox Configuration File
	* @overrideAppMapping.hint The direct location of the application in the web server.
	*/
	function loadConfiguration(overrideAppMapping=""){
		//Create Config Structure
		var configStruct		= structNew();
		var appRootPath 		= controller.getAppRootPath();
		var configCFCLocation 	= controller.getConfigLocation();
		var configCreatePath 	= "";
		var oConfig 			= "";
		var appMappingAsDots	= "";

		//Is incoming app mapping set, or do we auto-calculate
		if( NOT len( arguments.overrideAppMapping ) ){
			//AutoCalculate
			calculateAppMapping( configStruct );
		}
		else{
			configStruct.appMapping = arguments.overrideAppMapping;
		}

		//Default Locations for ROOT based apps, which is the default
		//Parse out the first / to create the invocation Path
		if ( left( configStruct["AppMapping"],1 ) eq "/" ){
			configStruct["AppMapping"] = removeChars( configStruct["AppMapping"] , 1, 1 );
		}
		//AppMappingInvocation Path
		appMappingAsDots = getAppMappingAsDots( configStruct.appMapping );

		// Config Create Path if not overriding and there is an appmapping
		if( len( appMappingAsDots ) AND NOT controller.getConfigLocationOverride() ){
			configCreatePath = appMappingAsDots & "." & configCFCLocation;
		}
		// Config create path if overriding or no app mapping
		else{
			configCreatePath = configCFCLocation;
		}

		//Create config Object
		oConfig = createObject("component", configCreatePath);

		//Decorate It
		oConfig.injectPropertyMixin = controller.getUtil().getMixerUtil().injectPropertyMixin;
		oConfig.getPropertyMixin 	= controller.getUtil().getMixerUtil().getPropertyMixin;

		//MixIn Variables
		oConfig.injectPropertyMixin("controller", controller);
		oConfig.injectPropertyMixin("appMapping", configStruct.appMapping);

		//Configure it
		oConfig.configure();

		//Environment detection
		detectEnvironment( oConfig, configStruct );

		/* ::::::::::::::::::::::::::::::::::::::::: APP LOCATION OVERRIDES :::::::::::::::::::::::::::::::::::::::::::: */

		// Setup Default Application Path from main controller
		configStruct.applicationPath = controller.getAppRootPath();
		// Check for Override of AppMapping
		if( len( trim( arguments.overrideAppMapping ) ) ){
			configStruct.applicationPath = expandPath( arguments.overrideAppMapping ) & "/";
		}

		/* ::::::::::::::::::::::::::::::::::::::::: GET COLDBOX SETTINGS  :::::::::::::::::::::::::::::::::::::::::::: */
		parseColdboxSettings(oConfig, configStruct, arguments.overrideAppMapping);

		/* ::::::::::::::::::::::::::::::::::::::::: YOUR SETTINGS LOADING :::::::::::::::::::::::::::::::::::::::::::: */
		parseYourSettings(oConfig, configStruct);

		/* ::::::::::::::::::::::::::::::::::::::::: HANDLER-MODELS-PLUGIN INVOCATION PATHS :::::::::::::::::::::::::::::::::::::::::::: */
		parseInvocationPaths(oConfig,configStruct);

		/* ::::::::::::::::::::::::::::::::::::::::: LAYOUT VIEW FOLDER SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
		parseLayoutsViews(oConfig,configStruct);

		/* ::::::::::::::::::::::::::::::::::::::::: WIREBOX Configuration :::::::::::::::::::::::::::::::::::::::::::: */
		parseWireBox(oConfig,configStruct);

		/* ::::::::::::::::::::::::::::::::::::::::: CONFIG FILE LAST MODIFIED SETTING :::::::::::::::::::::::::::::::::::::::::::: */
		configStruct.configTimeStamp = controller.getUtil().fileLastModified( controller.getConfigLocation() );

		// Store config object
		configStruct.coldboxConfig = oConfig;
		
		// Store the settings back in the controller.
		controller.setConfigSettings( configStruct );
	}

	function calculateAppMapping(required configStruct){
		// Get the web path from CGI.
		var	webPath = replacenocase( cgi.script_name, getFileFromPath( cgi.script_name ), "" );
		// Cleanup the template path
		var localPath = getDirectoryFromPath( replacenocase( getTemplatePath(), "\","/","all" ) );
		// Verify Path Location
		var pathLocation = findnocase( webPath, localPath );

		if ( pathLocation ){
			arguments.configStruct.appMapping = mid( localPath, pathLocation, len( webPath ) );
		}
		else{
			arguments.configStruct.appMapping = webPath;
		}

		//Clean last /
		if ( right( arguments.configStruct.AppMapping, 1 ) eq "/" ){
			if ( len( arguments.configStruct.AppMapping ) -1 gt 0)
				arguments.configStruct.AppMapping = left( arguments.configStruct.AppMapping, len( arguments.configStruct.AppMapping )-1);
			else
				arguments.configStruct.AppMapping = "";
		}

		//Clean j2ee context
		if( len( getContextRoot() ) ){
			arguments.configStruct.AppMapping = replacenocase( arguments.configStruct.AppMapping, getContextRoot(), "" );
		}
    }

	function parseColdboxSettings(required oConfig, required config, overrideAppMapping=""){
		var configStruct 	= arguments.config;
		var coldboxSettings = arguments.oConfig.getPropertyMixin( "coldbox", "variables", structnew() );

		// check if settings are available
		if( structIsEmpty( coldboxSettings ) ){
			throw(message="ColdBox settings empty, cannot continue", type="CFCApplicationLoader.ColdBoxSettingsEmpty");
		}

		// collection append
		structAppend( configStruct, coldboxSettings, true);

		// Common Structures
		configStruct.layoutsRefMap 	= structnew();
		configStruct.viewsRefMap	= structnew();

		/* ::::::::::::::::::::::::::::::::::::::::: COLDBOX SETTINGS VALIDATION :::::::::::::::::::::::::::::::::::::::::::: */

		//Check for AppName or throw
		if ( not StructKeyExists(configStruct, "AppName") )
			configStruct["AppName"] = controller.getAppHash();
		//Check for Default Event
		if ( not StructKeyExists(configStruct, "DefaultEvent") OR !len( configStruct.defaultEvent ) )
			configStruct["DefaultEvent"] = controller.COLDBOX.DefaultEvent;
		//Check for Event Name
		if ( not StructKeyExists(configStruct, "EventName") )
			configStruct["EventName"] = controller.COLDBOX.eventName;
		//Check for Application Start Handler
		if ( not StructKeyExists(configStruct, "ApplicationStartHandler") )
			configStruct["ApplicationStartHandler"] = "";
		//Check for Application End Handler
		if ( not StructKeyExists(configStruct, "ApplicationEndHandler") )
			configStruct["applicationEndHandler"] = "";
		//Check for Request End Handler
		if ( not StructKeyExists(configStruct, "RequestStartHandler") )
			configStruct["RequestStartHandler"] = "";
		//Check for Application Start Handler
		if ( not StructKeyExists(configStruct, "RequestEndHandler") )
			configStruct["RequestEndHandler"] = "";
		//Check for Session Start Handler
		if ( not StructKeyExists(configStruct, "SessionStartHandler") )
			configStruct["SessionStartHandler"] = "";
		//Check for Session End Handler
		if ( not StructKeyExists(configStruct, "SessionEndHandler") )
			configStruct["SessionEndHandler"] = "";
		//Check for InvalidEventHandler
		if ( not StructKeyExists(configStruct, "onInvalidEvent") )
			configStruct["onInvalidEvent"] = "";
		//Check for Implicit Views
		if ( not StructKeyExists(configStruct, "ImplicitViews") OR not isBoolean(configStruct.implicitViews) )
			configStruct["ImplicitViews"] = true;
		//Check for ReinitPassword
		if ( not structKeyExists(configStruct, "ReinitPassword") ){ configStruct["ReinitPassword"] = ""; }
		else if( len(configStruct["ReinitPassword"]) ){ configStruct["ReinitPassword"] = hash(configStruct["ReinitPassword"]); }
		//Check For CustomErrorTemplate
		if ( not StructKeyExists(configStruct, "CustomErrorTemplate") )
			configStruct["CustomErrorTemplate"] = "";
		//Check for HandlersIndexAutoReload, default = false
		if ( not structkeyExists(configStruct, "HandlersIndexAutoReload") or not isBoolean(configStruct.HandlersIndexAutoReload) )
			configStruct["HandlersIndexAutoReload"] = false;
		//Check for ExceptionHandler if found
		if ( not structkeyExists(configStruct, "ExceptionHandler") )
			configStruct["ExceptionHandler"] = "";
		//Check for Handler Caching
		if ( not structKeyExists(configStruct, "HandlerCaching") or not isBoolean(configStruct.HandlerCaching) )
			configStruct["HandlerCaching"] = true;
		//Check for Missing Template Handler
		if ( not StructKeyExists(configStruct, "MissingTemplateHandler") )
			configStruct["MissingTemplateHandler"] = "";
	}

	function parseYourSettings(required oConfig, required config){
		var configStruct = arguments.config;
		var settings = arguments.oConfig.getPropertyMixin("settings","variables",structnew());
		//append it
		structAppend(configStruct,settings,true);
	}
	
	function parseInvocationPaths(required oConfig, required config){
		var configStruct 		= arguments.config;
		var appMappingAsDots 	= "";

		// Handler Registration
		configStruct["HandlersInvocationPath"] = reReplace( controller.COLDBOX.handlersConvention,"(/|\\)", ".", "all");
		configStruct["HandlersPath"] = configStruct.ApplicationPath & controller.COLDBOX.handlersConvention;
		// Models Registration
		configStruct["ModelsInvocationPath"] = reReplace( controller.COLDBOX.ModelsConvention, "(/|\\)", ".", "all");
		configStruct["ModelsPath"] = configStruct.ApplicationPath & controller.COLDBOX.ModelsConvention;

		//Set the Handlers,Models, & Custom Plugin Invocation & Physical Path for this Application
		if( len( configStruct["AppMapping"] ) ){
			appMappingAsDots = reReplace( configStruct["AppMapping"], "(/|\\)", ".", "all" );
			// Handler Path Registrations
			configStruct["HandlersInvocationPath"] = appMappingAsDots & ".#reReplace(controller.COLDBOX.handlersConvention,"(/|\\)",".","all")#";
			configStruct["HandlersPath"] = "/" & configStruct.AppMapping & "/#controller.COLDBOX.handlersConvention#";
			configStruct["HandlersPath"] = expandPath(configStruct["HandlersPath"]);
			// Model Registrations
			configStruct["ModelsInvocationPath"] = appMappingAsDots & ".#reReplace(controller.COLDBOX.ModelsConvention,"(/|\\)",".","all")#";
			configStruct["ModelsPath"] = "/" & configStruct.AppMapping & "/#controller.COLDBOX.ModelsConvention#";
			configStruct["ModelsPath"] = expandPath( configStruct["ModelsPath"] );
		}

	}

	function parseLayoutsViews(required oConfig, required config){
		var configStruct 		= arguments.config;
		var	LayoutViewStruct 	= CreateObject("java","java.util.LinkedHashMap").init();
		var	LayoutFolderStruct 	= CreateObject("java","java.util.LinkedHashMap").init();
		var key 				= "";
		var layoutSettings 		= arguments.oConfig.getPropertyMixin( "layoutSettings", "variables", structnew() );
		var layouts 			= arguments.oConfig.getPropertyMixin( "layouts", "variables", arrayNew(1) );
		var i 					= 1;
		var x 					= 1;
		var thisLayout			= "";
		var layoutsArray 		= arrayNew(1);

		// defaults
		configStruct.defaultLayout 		= controller.COLDBOX.defaultLayout;
		configStruct.registeredLayouts  = structnew();

		// Register layout settings
		structAppend( configStruct, layoutSettings );

		// registered layouts
		if( isStruct( layouts ) ){
			// process structure into array
			for( key in layouts ){
				thisLayout = layouts[key];
				thisLayout.name = key;
				arrayAppend( layoutsArray, thisLayout );
			}
		}
		else{
			layoutsArray = layouts;
		}

		// Process layouts
		for(x=1; x lte ArrayLen( layoutsArray ); x++){
			thisLayout = layoutsArray[x];

			// register file with alias
			configStruct.registeredLayouts[ thisLayout.name ] = thisLayout.file;

			// register views
			if( structKeyExists( thisLayout, "views" ) ){
				for(i=1; i lte listLen( thislayout.views ); i++){
					if( not StructKeyExists( LayoutViewStruct, lcase( listGetAt( thisLayout.views, i ) ) ) ){
						LayoutViewStruct[ lcase( listGetAt( thisLayout.views, i ) ) ] = thisLayout.file;
					}
				}
			}

			// register folders
			if( structKeyExists( thisLayout, "folders" ) ){
				for(i=1; i lte listLen( thisLayout.folders ); i++){
					if( not StructKeyExists( LayoutFolderStruct, lcase( listGetAt( thisLayout.folders, i ) ) ) ){
						LayoutFolderStruct[ lcase( listGetAt( thisLayout.folders, i ) ) ] = thisLayout.file;
					}
				}
			}
		}

		// Register extra layout/view/folder combos
		configStruct.ViewLayouts   = LayoutViewStruct;
		configStruct.FolderLayouts = LayoutFolderStruct;
	}
	
	function parseWireBox(required oConfig, required config){
		var wireBoxDSL = structnew();

		// Default Config Structure
		arguments.config.wirebox 			= structnew();
		arguments.config.wirebox.enabled	= true;
		arguments.config.wirebox.binder		= "";
		arguments.config.wirebox.binderPath	= "";
		arguments.config.wirebox.singletonReload = false;

		// Check if we have defined DSL first in application config
		wireBoxDSL = arguments.oConfig.getPropertyMixin("wireBox","variables",structnew());

		// Get Binder Paths
		if( structKeyExists(wireBoxDSL,"binder") ){
			arguments.config.wirebox.binderPath = wireBoxDSL.binder;
		}
		// Check if WireBox.cfc exists in the config conventions, if so create binder
		else if( fileExists( controller.getAppRootPath() & "config/WireBox.cfc") ){
			arguments.config.wirebox.binderPath = "config.WireBox";
			if( len( arguments.config.appMapping ) ){
				arguments.config.wirebox.binderPath = arguments.config.appMapping & ".#arguments.config.wirebox.binderPath#";
			}
		}
		// Singleton reload
		if( structKeyExists( wireBoxDSL, "singletonReload" ) ){
			arguments.config.wirebox.singletonReload = wireBoxDSL.singletonReload;
		}
	}

	/************************************** PRIVATE *********************************************/
	
	private function detectEnvironment(required oConfig, required config){
		var environments = arguments.oConfig.getPropertyMixin( "environments", "variables", structnew() );
		var configStruct = arguments.config;
		var key = "";
		var i = 1;

		// Set default to production
		configStruct.environment = "production";

		// is detection is custom
		if( structKeyExists( arguments.oConfig, "detectEnvironment" ) ){
			//detect custom environment
			configStruct.environment = arguments.oConfig.detectEnvironment();
		}
		else{
			// loop over environments and do coldbox environment detection
			for(key in environments){
				// loop over patterns
				for(i=1; i lte listLen( environments[ key ] ); i++){
					if( reFindNoCase( listGetAt( environments[ key ] ,i ), cgi.http_host) ){
						// set new environment
						configStruct.environment = key;
					}
				}
			}
		}

		// call environment method if exists
		if( structKeyExists( arguments.oConfig, configStruct.environment ) ){
			evaluate("arguments.oConfig.#configStruct.environment#()");
		}
	}

	private function getAppMappingAsDots(required appMapping){
		return reReplace( arguments.appMapping, "(/|\\)", ".", "all" );
	}
	
}