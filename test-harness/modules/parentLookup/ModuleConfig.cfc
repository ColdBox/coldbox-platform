component{

	// Module Properties
	this.title 				= "Parent Lookup";
	this.author 			= "Luis Majano";
	this.webURL 			= "http://www.coldbox.org";
	this.description 		= "A parent-first lookup";
	this.version			= "1.0";
	this.viewParentLookup 	= true;
	this.layoutParentLookup = true;
	this.entryPoint			= "parentLookup";

	/**
	* Configure the ForgeBox Module
	*/
	function configure(){

		settings = {
			version = "0.1"
		};

		// SES Routes ORDER MATTERS
		routes = [
			{pattern="/", handler="main",action="index"}
		];
	}

	/**
	* Called when the module is activated and application has loaded
	*/
	function onLoad(){
		if( controller.settingExists("sesBaseURL") ){
			this.entryPoint = "parentLookup:main";
		}
	}

}