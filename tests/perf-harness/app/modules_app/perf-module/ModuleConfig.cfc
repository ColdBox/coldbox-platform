/**
 * Performance test module — exercises HMVC module routing and module-scoped DI.
 */
component {

	this.title          = "Perf Module"
	this.author         = "Ortus Solutions"
	this.description    = "HMVC module for ColdBox performance testing"
	this.version        = "1.0.0"
	this.entrypoint     = "perf-module"
	this.modelNamespace = "perf-module"
	this.autoMapModels  = true

	function configure(){
		routes = [
			{ pattern : "/items", handler : "Items", action : "index" },
			{ pattern : "/",      handler : "Items", action : "index" }
		]
	}

}
