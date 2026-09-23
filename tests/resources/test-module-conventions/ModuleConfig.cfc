/**
 * Module Config
 * A minimal module that declares only a mandatory-action convention route
 * ("/:handler/:action") in its own config/Router.cfc, to verify that ColdBox
 * still auto-registers the optional-action convention route ("/:handler/:action?")
 * so single-segment, handler-only URLs resolve within the module.
 */
component {

	this.title          = "Module Convention Routing Test Module";
	this.entryPoint     = "mconventions";
	this.modelNamespace = "mconventions";

	function configure(){
	}

}
