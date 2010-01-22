<cfcomponent output="false" hint="My App Configuration">
<cfscript>
/**
public properties to set:
this.title = "Title of the module";
this.author = "Author of the module";
this.webURL = "Web URL for docs purposes";
this.description = "Module description";
this.version = "Module Version"
this.viewParentLookup = true [boolean] // If true, checks for views in the parent first, then it the module.If false, then modules first, then parent.

structures to create for configuration
- parentSettings : struct (will append and override parent)
- settings : struct
- datasources : struct (will append and override parent)
- webservices : struct (will append and override parent)
- customInterceptionPoints : string list of custom interception points
- interceptors : array
- routes : array

Available objects in variable scope
- controller
- appMapping (application mapping)
- moduleMapping (include,cf path)
- modulePath (absolute path)

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
	this.version			= "1.0";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	
	function configure(){
		// module settings - stored in modules.name.settings
		settings = {
			
		};
		
		// SES Routes
		routes = [
			{pattern="/docs", handler="api",action="index"}		
		];		
		
		interceptors = [];
		
		modelMappings = {
			
		};
	}
</cfscript>
</cfcomponent>