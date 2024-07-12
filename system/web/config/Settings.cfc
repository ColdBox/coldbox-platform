/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * ColdBox Main Configuration Defaults
 */
component {

	// Release Metadata
	this.codename      = "ColdBox Restore";
	this.author        = "Ortus Solutions";
	this.authorEmail   = "info@ortussolutions.com";
	this.authorWebsite = "https://www.ortussolutions.com";
	this.suffix        = "Psalm 23:3";
	this.version       = "@build.version@+@build.number@";
	this.description   = "The Human Way to Build ColdFusion CFML apps!";

	// ColdBox Operational Defaults
	this.coldbox = {
		// Global Operational Settings
		"appName"                  : application.applicationName,
		"eventName"                : "event",
		"reinitPassword"           : hash( createUUID() ),
		"reinitKey"                : "fwreinit",
		"proxyReturnCollection"    : false,
		"jsonPayloadToRC"          : true,
		"autoMapModels"            : true,
		"environment"              : "production",
		"identifierProvider"       : "",
		"debugMode"                : false,
		"exceptionEditor"          : "vscode",
		// Caching Settings
		"handlersIndexAutoReload"  : false,
		"handlerCaching"           : true,
		"eventCaching"             : true,
		"viewCaching"              : true,
		// Default Conventions Events + Views
		"defaultEvent"             : "main.index",
		"defaultLayout"            : "Main",
		"defaultView"              : "",
		// Implicit Events
		"applicationStartHandler"  : "",
		"applicationEndHandler"    : "",
		"requestStartHandler"      : "",
		"requestEndHandler"        : "",
		"sessionStartHandler"      : "",
		"sessionEndHandler"        : "",
		"missingTemplateHandler"   : "",
		"invalidHTTPMethodHandler" : "",
		// Exception Handling
		"invalidEventHandler"      : "",
		"exceptionHandler"         : "",
		"customErrorTemplate"      : "",
		// Helpers and Rendering Settings
		"implicitViews"            : true,
		"applicationHelper"        : [],
		"viewsHelper"              : "",
		// Extensions
		"requestContextDecorator"  : "",
		"controllerDecorator"      : "",
		"handlersExternalLocation" : "",
		"viewsExternalLocation"    : "",
		"layoutsExternalLocation"  : "",
		"modulesExternalLocation"  : []
	};

	// flash scope defaults
	this.flash = {
		"scope"        : "session",
		"properties"   : {},
		"inflateToRC"  : true,
		"inflateToPRC" : false,
		"autoPurge"    : true,
		"autoSave"     : true
	};

	// Conventions
	this.handlersConvention = "handlers";
	this.layoutsConvention  = "layouts";
	this.viewsConvention    = "views";
	this.eventAction        = "index";
	this.modelsConvention   = "models";
	this.configConvention   = "config.Coldbox";
	this.modulesConvention  = "modules";
	this.includesConvention = "includes";

	// Async Configs
	this.async = { "schedulerThreads" : 20 };

	/**
	 * Configuration for non-config apps
	 */
	function configure(){
	}

}
