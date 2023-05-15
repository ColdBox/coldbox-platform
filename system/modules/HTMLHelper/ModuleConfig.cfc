/**
 * Module Config
 */
component {

	// Module Properties
	this.title             = "HTML Helper";
	// Model Namespace
	this.modelNamespace    = "HTMLHelper";
	// CF Mapping
	this.cfmapping         = "HTMLHelper";
	// Auto-map models
	this.autoMapModels     = true;
	// Helpers
	this.applicationHelper = [ "helpers/Mixins.cfm" ];

	function configure(){
		// module settings - stored in modules.name.settings
		settings = {
			// The base path of JS assets
			js_path      : "/includes/js/",
			// The base path of CSS assets
			css_path     : "/includes/css/",
			// Encode values on all dynamically generated tags in the HTML Helper
			encodeValues : false
		};

		// Map HTML Helper to provide continuity from previous ColdBox apps
		binder.map( "HTMLHelper@coldbox" ).to( "#moduleMapping#.models.HTMLHelper" );
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

	/**
	 * Listen when the renderer is ready
	 */
	function afterRendererInit( event, data ){
		arguments.data.variables.html = variables.wireBox.getInstance( "HTMLHelper@HTMLHelper" );
	}

}
