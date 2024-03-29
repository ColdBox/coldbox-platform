﻿component output="false" hint="A LogBox Configuration Data Object" {

	/**
	 * Configure LogBox, that's it!
	 */
	function configure(){
		logBox = {
			// Define Appenders
			appenders : {
				coldboxTracer : {
					class      : "coldbox.system.logging.appenders.ConsoleAppender",
					layout     : "coldbox.tests.specs.logging.MockLayout",
					properties : { name : "awesome" }
				}
			},
			// Root Logger
			root       : { levelmax : "INFO", levelMin : 0, appenders : "*" },
			// Categories
			categories : {
				"coldbox.system"              : { levelMax : "INFO" },
				"coldbox.system.interceptors" : { levelMin : 0, levelMax : "DEBUG", appenders : "*" },
				"hello.model"                 : { levelMax : 4, appenders : "*" }
			},
			debug : [ "coldbox.system", "models.system" ],
			info  : [ "hello.model", "yes.wow.wow" ],
			warn  : [ "hello.model", "yes.wow.wow" ],
			error : [ "hello.model", "yes.wow.wow" ],
			fatal : [ "hello.model", "yes.wow.wow" ],
			OFF   : [ "hello.model", "yes.wow.wow" ]
		};
	}

}
