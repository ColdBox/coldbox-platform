<cfcomponent output="false" hint="My App Configuration">
<cfscript>
	// Module Properties
	this.title 				= "My Test Module";
	this.aliases			= "cbtest1";
	this.author 			= "Luis Majano";
	this.webURL 			= "http://www.coldbox.org";
	this.description 		= "A funky test module";
	this.version			= "1.0";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	this.entryPoint			= "test1";
	// CFML Mapping for this module, the path will be the module root. If empty, none is registered.
	this.cfmapping			= "cbModuleTest1";

	function configure(){

		// parent settings
		parentSettings = {
			woot = "Module set it!"
		};

		// module settings - stored in modules.name.settings
		settings = {
			display = "core"
		};

		// datasources
		datasources = {
			mysite   = {name="mySite", dbType="mysql", username="root", password="root"}
		};

		// SES Routes
		routes = [
			{ pattern="/", handler="test",action="index" },
			{ pattern="/:handler/:action?" }
		];

		// Interceptor Config
		interceptorSettings = {
			customInterceptionPoints = "onPio"
		};
		// All declared interceptor
		interceptors = [
			{class="#moduleMapping#.interceptors.Simple"}
		];

		// i18n
		i18n = {
			defaultLocale = "es_SV",
			resourceBundles = {
				"module@test1" = "#moduleMapping#/includes/module"
			}
		};

	}

	function onLoad(){
		controller.getLogBox().getLogger(this).info("onLoad called on module: #getMetadata(this).name#");
	}

	function onUnload(){
		controller.getLogBox().getLogger(this).info("onUnload called on module: #getMetadata(this).name#");
	}

	// This object can also act as an interceptor
	function preProcess(event,interceptData){
		controller.getLogBox().getLogger(this).info("I can now listen on preprocess from the Test1 Module");
	}

	/**
	* @interceptionPoint
	*/
	function onPio(event, interceptData){
		controller.getLogBox().getLogger(this).info("I can now listen onPio");
	}

</cfscript>
</cfcomponent>