<cfcomponent output="false" hint="My App Configuration">
<cfscript>
	
	// Module Properties
	this.title 				= "My Test Conventions module";
	this.author 			= "Luis Majano";
	this.webURL 			= "http://www.coldbox.org";
	this.description 		= "A funky conventions test module";
	this.version			= "1.0";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	
	function configure(){
		
		// SES Routes
		routes = [
			{pattern="/api-docs", handler="api",action="index"}		
		];		
	
		// Module Conventions
		conventions = {
			handlersLocation = "system/handlers",
			viewsLocation = "system/views",
			pluginsLocation = "system/plugins",
			modelsLocation = "system/model"
		};
	
		// Model Mappings
		modelMappings = {
			"Simple@conventionsTest" = {
				path = "Simple"
			}
		};	
	}
</cfscript>
</cfcomponent>