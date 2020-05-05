/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * ColdBox Main Configuration Defaults
 */
component {

	// Release Metadata
	this.codename      = "ColdBox Perseverance";
	this.author        = "Ortus Solutions";
	this.authorEmail   = "info@ortussolutions.com";
	this.authorWebsite = "https://www.ortussolutions.com";
	this.suffix        = "Isaiah 40:29";
	this.version       = "@build.version@+@build.number@";
	this.description   = "This is the ColdBox Platform for ColdFusion Powered Web Applications.";

	// ColdBox Operational Defaults
	this.coldbox = {
		// Global Settings
		"appName"                  : application.applicationName,
		"eventName"                : "event",
		"reinitPassword"           : hash( createUUID() ),
		"reinitKey"                : "fwreinit",
		"proxyReturnCollection"    : false,
		"jsonPayloadToRC"          : true,
		"autoMapModels"            : true,
		"environment"              : "production",
		// Caching
		"handlersIndexAutoReload"  : false,
		"handlerCaching"           : true,
		"eventCaching"             : true,
		"viewCaching"              : true,
		// Default Operations
		"defaultEvent"             : "main.index",
		"defaultLayout"            : "Main.cfm",
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

}
