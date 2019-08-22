component{

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
	this.entrypoint			= "conventionsTest";
	this.modelNamespace 	= "MyConventionsTest";
	// Application helpers
	this.applicationHelper 	= [ "helpers/app.cfm" ];

	function configure(){

		// SES Routes
		routes = [
			{ pattern="/", handler="test", action="index" },
			{
				pattern = "/search",
				handler = "search",
				action  = {
					"OPTIONS" : "options",
					"HEAD"    : "index",
					"GET"     : "index",
					"POST"    : "index"
				}
			},
			{ pattern="/:handler/:action?" }
		];

		// Module Conventions
		conventions = {
			handlersLocation = "system/handlers",
			viewsLocation = "system/views",
			modelsLocation = "system/model"
		};

	}

}