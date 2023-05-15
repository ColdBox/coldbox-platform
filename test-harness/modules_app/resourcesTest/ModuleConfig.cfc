component {

	// Module Properties
	this.title              = "resourcesTest";
	this.author             = "";
	this.webURL             = "";
	this.description        = "";
	this.version            = "1.0.0";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup   = true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	// Module Entry Point
	this.entryPoint         = "resourcesTest";
	// Model Namespace
	this.modelNamespace     = "resourcesTest";
	// CF Mapping
	this.cfmapping          = "resourcesTest";
	// Auto-map models
	this.autoMapModels      = true;
	// Module Dependencies
	this.dependencies       = [];
	// Models mapped locally with no @resourcesTest
	this.moduleInjector = true;

	function configure(){
		// Custom Declared Points
		interceptorSettings = { customInterceptionPoints : "" };

		// Custom Declared Interceptors
		interceptors = [];

		// Executors
		executors = {
			"resourcesPool" : { type : "fixed" }
		};

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
