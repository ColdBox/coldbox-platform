<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Description :
ColdBox Default Configuration
----------------------------------------------------------------------->
<cfcomponent output=false hint="ColdBox Default Configuration">
<cfscript>

	// Release Metadata
	this.codename 		= "ColdBox SEEK";
	this.author			= "Ortus Solutions";
	this.authorEmail 	= "coldbox@ortussolutions.com";
	this.authorWebsite	= "http://www.ortussolutions.com";
	this.suffix			= "1 John 5:12-13";
	this.version		= "3.6.0";
	this.description	= "This is the ColdBox Platform for ColdFusion Powered Web Applications.";

	// Operation Defaults
	this.eventName 	= "event";
	this.defaultEvent = "main.index";
	this.defaultLayout = "Main.cfm";

	// flash scope defaults
	this.flash = {
		scope = "session",
		properties = {},
		inflateToRC = true,
		inflateToPRC = false,
		autoPurge = true,
		autoSave = true
	};

	// Debugger Defaults
	this.debuggerSettings = {
		enableDumpVar = true,
	    persistentRequestProfiler = true,
	    maxPersistentRequestProfilers = 10,
	    maxRCPanelQueryRows = 50,
	    showTracerPanel = true,
	    expandedTracerPanel = true,
	    showInfoPanel = true,
	    expandedInfoPanel = true,
	    showCachePanel = true,
	    expandedCachePanel = false,
	    showRCPanel = true,
	    expandedRCPanel = false,
	    showModulesPanel = true,
	    expandedModulesPanel = false,
	    showRCSnapshots = false
    };

    // Conventions
    this.handlersConvention	= "handlers";
	this.pluginsConvention	= "plugins";
	this.layoutsConvention	= "layouts";
	this.viewsConvention	= "views";
	this.eventAction		= "index";
	this.modelsConvention	= "model";
	this.configConvention	= "config.Coldbox";
	this.modulesConvention	= "modules";

</cfscript>
</cfcomponent>
