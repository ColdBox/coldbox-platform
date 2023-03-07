/**
 * Module Config
 */
component {

	// Module Properties
	this.title             = "Module Service Test Module";
	// Model Namespace
	this.modelNamespace    = "mserv";
	// CF Mapping
	this.cfmapping         = "mserv";
	// Auto-map models
	this.autoMapModels     = true;

	function configure(){
		settings = {
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
