/**
 * Module Config
 */
component {

	// Module Properties
	this.title             = "Module Service Test Module";
	// Model Namespace
	this.modelNamespace    = "mserv";
	// Engine Mapping
	this.classMapping         = "mserv";
	// Auto-map models
	this.autoMapModels     = true;

	function configure(){
		variables.settings = {
			"foo" : "bar"
		}
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
