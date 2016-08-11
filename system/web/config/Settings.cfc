/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* ColdBox Main Configuration Defaults
*/
component{

	// Release Metadata
	this.codename 		= "ColdBox SEEK";
	this.author			= "Ortus Solutions";
	this.authorEmail 	= "coldbox@ortussolutions.com";
	this.authorWebsite	= "http://www.ortussolutions.com";
	this.suffix			= "Nehemiah";
	this.version		= "@version.number@+@build.number@";
	this.description	= "This is the ColdBox Platform for ColdFusion Powered Web Applications.";

	// Operation Defaults
	this.eventName 		= "event";
	this.defaultEvent 	= "main.index";
	this.defaultLayout 	= "Main.cfm";

	// flash scope defaults
	this.flash = {
		scope = "session",
		properties = {},
		inflateToRC = true,
		inflateToPRC = false,
		autoPurge = true,
		autoSave = true
	};

    // Conventions
    this.handlersConvention	= "handlers";
	this.layoutsConvention	= "layouts";
	this.viewsConvention	= "views";
	this.eventAction		= "index";
	this.modelsConvention	= "models";
	this.configConvention	= "config.Coldbox";
	this.modulesConvention	= "modules";
	this.includesConvention = "includes";


	function configure(){}
}