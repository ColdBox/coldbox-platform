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
	this.suffix			= "Gideon";
	this.version		= "4.0.0.@build.number@";
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
