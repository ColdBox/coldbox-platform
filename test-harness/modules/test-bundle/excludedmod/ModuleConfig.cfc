component{
	
	// Module Properties
	this.title 				= "Excluded Mod";
	this.author 			= "Luis Majano";
	this.webURL 			= "http://www.coldbox.org";
	this.description 		= "An excluded module";
	this.version			= "1.0.0";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	this.entryPoint			= "excludedmod";
	// CFML Mapping for this module, the path will be the module root. If empty, none is registered.

	function configure(){

		// parent settings
		parentSettings = {
		};

		// module settings - stored in modules.name.settings
		settings = {
		};

		// SES Routes
		routes = [
			{ pattern="/:handler/:action?" }
		];

		// Interceptor Config
		interceptorSettings = {
		};
		// All declared interceptor
		interceptors = [
		];

	}

	function onLoad(){
	}

	function onUnload(){
	}

}