component {

	// Module Properties
	this.title              = "Inception";
	this.author             = "Luis Majano";
	this.webURL             = "http://www.ortussolutions.com";
	this.description        = "Module inception test";
	this.version            = "1.0.0";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup   = true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	// Module Entry Point
	this.entryPoint         = "inception";
	// Model Namespace
	this.modelNamespace     = "";
	// Auto Map Models Directory
	this.autoMapModels      = true;
	// CF Mapping
	this.cfmapping          = "";

	function configure(){
		// parent settings
		parentSettings = {};

		// module settings - stored in modules.name.settings
		settings = {};

		// Layout Settings
		layoutSettings = { defaultLayout : "" };

		// datasources
		datasources = {};

		// SES Routes
		routes = [
			// Module Entry Point
			{
				pattern : "/",
				handler : "home",
				action  : "index"
			},
			// Convention Route
			{ pattern : "/:handler/:action?" }
		];

		// Custom Declared Points
		interceptorSettings = { customInterceptionPoints : "" };

		// Custom Declared Interceptors
		interceptors = [];

		// Binder Mappings
		// binder.map("Alias").to("#moduleMapping#.model.MyService");
	}

	/**
	 * Fired when the module is registered and activated.
	 */
	function onLoad(){
	}

	/**
	 * Fired when the module is unregistered and unloaded
	 */
	function onUnload(){
	}

}
