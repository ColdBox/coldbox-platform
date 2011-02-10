<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	January 10, 2010
Description :
The forgebox manager handler

----------------------------------------------------------------------->
<cfcomponent output="false" hint="My App Configuration">
<cfscript>
/**
Module Directives as public properties
this.title 				= "Title of the module";
this.author 			= "Author of the module";
this.webURL 			= "Web URL for docs purposes";
this.description 		= "Module description";
this.version 			= "Module Version"

Optional Properties
this.viewParentLookup   = (true) [boolean] (Optional) // If true, checks for views in the parent first, then it the module.If false, then modules first, then parent.
this.layoutParentLookup = (true) [boolean] (Optional) // If true, checks for layouts in the parent first, then it the module.If false, then modules first, then parent.
this.entryPoint  		= "" (Optional) // If set, this is the default event (ex:forgebox:manager.index) or default route (/forgebox) the framework
									       will use to create an entry link to the module. Similar to a default event.

structures to create for configuration
- parentSettings : struct (will append and override parent)
- settings : struct
- datasources : struct (will append and override parent)
- webservices : struct (will append and override parent)
- interceptorSettings : struct of the following keys ATM
	- customInterceptionPoints : string list of custom interception points
- interceptors : array
- routes : array Allowed keys are same as the addRoute() method of the SES interceptor.
- layoutSettings : struct (will allow to define a defaultLayout for the module)
- modelMappings : structure of model mappings. Allowed keys are the alias and path, same as normal model mappings.

Available objects in variable scope
- controller
- appMapping (application mapping)
- moduleMapping (include,cf path)
- modulePath (absolute path)
- log (A pre-configured logBox logger object for this object)
- binder (The wirebox instance binder for DI configuration)

Required Methods
- configure() : The method ColdBox calls to configure the module.

Optional Methods
- onLoad() 		: If found, it is fired once the module is fully loaded
- onUnload() 	: If found, it is fired once the module is unloaded

*/

	// Module Properties
	this.title 				= "ForgeBox";
	this.author 			= "Luis Majano";
	this.webURL 			= "http://www.coldbox.org";
	this.description 		= "A module that interacts with forgebox";
	this.version			= "1.2";
	this.viewParentLookup 	= true;
	this.layoutParentLookup = true;
	this.entryPoint			= "forgebox";

	/**
	* Configure the ForgeBox Module
	*/
	function configure(){

		settings = {
			version = this.version
		};

		// Layout Settings
		layoutSettings = {
			defaultLayout = "forgebox.main.cfm"
		};
	
		// SES Routes ORDER MATTERS
		routes = [
			{pattern="/", handler="manager",action="index", orderby="POPULAR"},
			{pattern="/install/results/:entrySlug", handler="manager", action="installResults"},
			{pattern="/install", handler="manager", action="install"},
			{pattern="/manager/:orderby/:typeSlug?", handler="manager",action="index"}
		];

		// WireBox Binder configuration
		binder.map("forgeService@forgebox").to("#moduleMapping#.model.ForgeService");
	}

	/**
	* Called when the module is activated and application has loaded
	*/
	function onLoad(){
		if( controller.settingExists("sesBaseURL") ){
			this.entryPoint = "forgebox:manager";
		}
	}
</cfscript>
</cfcomponent>