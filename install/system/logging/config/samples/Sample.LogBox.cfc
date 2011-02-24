<cfcomponent output="false" hint="A LogBox Configuration Data Object">
<cfscript>
	/**
	* Configure LogBox, that's it!
	*/
	function configure(){
		logBox = {
			// Define Appenders
			appenders = {
				coldboxTracer = { 
					class="shared.frameworks.coldbox_3_00.system.logging.appenders.ColdboxTracerAppender",
					layout="coldbox.testing.cases.logging.MockLayout", 
					properties = {
						name = "awesome"
					}
				}
			},
			// Root Logger
			root = { levelmax="INFO", levelMin=0, appenders="*" },
			// Categories
			categories = {
				"shared.frameworks.coldbox_3_00.system" = { levelMax="INFO" },
				"shared.frameworks.coldbox_3_00.system.interceptors" = { levelMin=0, levelMax="DEBUG", appenders="*" },
				"hello.model" = {levelMax=4, appenders="*" }
			},
			debug  = [ "shared.frameworks.coldbox_3_00.system", "model.system" ],
			info = [ "hello.model", "yes.wow.wow" ],
			warn = [ "hello.model", "yes.wow.wow" ],
			error = [ "hello.model", "yes.wow.wow" ],
			fatal = [ "hello.model", "yes.wow.wow" ],
			OFF = [ "hello.model", "yes.wow.wow" ] 
		};
	}
</cfscript>
</cfcomponent>
