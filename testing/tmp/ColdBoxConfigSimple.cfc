<cfcomponent output="false">

<!--- 
	This component will be decorated at runtime with the following:
	this.controller = the coldbox controller
	this.logLevels = the levels to use for logBox
	this.layout() - to add layouts
	this.interceptor() - to add interceptors
	this.getConfiguration() - to retrieve all the variables in the variables scope for configuration.
 --->

<cffunction name="configure" returntype="void" output="false">
<cfscript>
	// ColdBox Configuration
	coldbox = {
	     appName = "My App",
	     appMapping = "/myApp",
	     reinitPassword = "",
	     handlerCaching = true,
	     eventCaching = true
	};

	// Implicit Events
	events = {
	     defaultEvent = "general.index",
	     requestStartHandler = "main.rs",
	     requestEndHandler = "main.re",
	     applicationStartHandler = "main.as",
	     applicationEndHandler ="main.ae"
	};

	// Debugger
	debugger = {
	     debugMode = true
	};
	
	// Model Integration
	models = {
	     objectCaching = true,
	     definitionFile = "config/ModelMappings.cfm",
	     setterInjection = false,
	     debugLevel = LOGLEVELS.INFO
	};

	// Layouts
	layouts = {
	     defaultLayout = "Layout.Main.cfm"
	};

	// Register Interceptors
	interceptor(name="autowire",class="coldbox.system.interceptors.Autowire");
	interceptor(name="ses",class="coldbox.system.interceptors.ses",configFile="config/routes.cfm");
</cfscript>
</cffunction>

</cfcomponent>
