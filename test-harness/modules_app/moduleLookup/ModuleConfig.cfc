component{
	// Module Properties
	this.title              = "Module Lookup";
	this.author             = "Luis Majano";
	this.webURL             = "http://www.coldbox.org";
	this.description        = "A module-first lookup";
	this.version            = "1.0";
	this.viewParentLookup   = false;
	this.layoutParentLookup = false;
	this.entryPoint         = "moduleLookup";

	/**
	 * Configure the ForgeBox Module
	 */
	function configure(){
		settings = { version : "0.1" };

		// SES Routes ORDER MATTERS
		routes = [
			{
				pattern : "/",
				handler : "main",
				action  : "index"
			},
			{
				pattern : ":handler/:action"
			}
		];
	}

	/**
	 * Called when the module is activated and application has loaded
	 */
	function onLoad(){
		if ( controller.settingExists( "sesBaseURL" ) ) {
			this.entryPoint = "moduleLookup:main";
		}
	}
}
