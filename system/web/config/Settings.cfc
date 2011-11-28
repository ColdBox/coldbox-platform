<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Description :
ColdBox Default Configuration
----------------------------------------------------------------------->
<cfcomponent output="false" hint="ColdBox Default Configuration">
<cfscript>
	
	// Release Metadata
	this.codename 		= "ColdBox SEEK";
	this.author			= "Ortus Solutions";
	this.authorEmail 	= "coldbox@ortussolutions.com";
	this.authorWebsite	= "http://www.ortussolutions.com";
	this.suffix			= "BETA - Jeremiah 29:13";
	this.version		= "3.5.0";
	this.description	= "This is the ColdBox Platform for ColdFusion Powered Web Applications.";
	
	// Operation Defaults
	this.eventName 				= "event";
	
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
	this.enableDumpVar = "true";
    this.persistentRequestProfiler = "true";
    this.maxPersistentRequestProfilers = "10";
    this.maxRCPanelQueryRows = "50";
    this.showTracerPanel = "true";
    this.expandedTracerPanel = "true";
    this.showInfoPanel = "true";
    this.expandedInfoPanel = "true";
    this.showCachePanel = "true";
    this.expandedCachePanel = "false";
    this.showRCPanel = "true";
    this.expandedRCPanel = "false";  
    this.showModulesPanel = "true";
    this.expandedModulesPanel = "false";  
    
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
