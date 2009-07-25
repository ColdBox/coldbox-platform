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
	     handlersIndexAutoReload = true,
	     configAutoReload = false,
	     handlerCaching = true,
	     eventCaching = true
	};
	
	// Environments, name must match a method on this cfc
	environments = {
		dev = "jfetmac, localhost",
		stg = "stg.jfetmac"
	};
	
	// Custom Conventions
	conventions = {
		handlersLocation = "",
		pluginsLocation = "",
		layoutsLocation = "",
		viewsLocation = "",
		modelsLocation = "",
		eventAction = "index"
	};
		
	// Implicit Events
	events = {
	     defaultEvent = "general.index",
	     applicationStartHandler = "main.onAppInit"
	};
	
	// Debugger
	debugger = {
	     debugMode = true,
	     TracerPanel = { show = true, expanded = true },
	     InfoPanel = { show = true, expanded = true }
	};
	
	// Model Integration
	models = {
	     objectCaching = false,
	     definitionFile = "config/ModelMappings.cfm",
	     setterInjection = false,
	     debugLevel = LOGLEVELS.INFO
	};
	// Layouts
	layouts = {
	     defaultLayout = "layout.main.cfm"
	};
	
	conventions = {
		handlersLocation = "monitor/handlers",
		layoutsLocation = "monitor/layouts",
		viewsLocation = "monitor/views"
	};
	
	// Cache Configuration
	cache = {
	     EvictionPolicy = "coldbox.system.cache.policies.LRU" //change this to class anywhere.
	};
	
	// Register Interceptors
	interceptor(name="autowire",class="coldbox.system.interceptors.Autowire");
	interceptor(name="deploy",
				class="coldbox.system.interceptors.Deploy",
				configFile="config/.deploytag",
				commandObject=$("appMapping") & "model.deploy");
	interceptor(name="TransferLoader",
				class="coldbox.system.orm.transfer.TransferLoader",
				configPath = "/#$("AppMapping")#/config/transfer.xml.cfm",
				definitionPath="/#$("AppMapping")#/config/definitions",
				datasourceAlias="blog");
	
	//OR do a new LogBox DSL structure
	logBox = {
		appenders = {
			fileLog = {
				class="coldbox.system.logging.appenders.RollingFileAppender",
				layout="myLayout",
				properties={
					filePath=$("ApplicationPath") & "/monitor/logs",
					filename = $("AppName")
				}
			},
			console = { class="coldbox.system.logging.appenders.ConsoleAppender" }
		},
		root = { appenders = "*"},
		error = "category1, category2",
		info = "category2, category3"
	};
</cfscript>
</cffunction>

<cffunction name="dev" output="false" returntype="void">
<cfscript>
	// Override any configuration part.
</cfscript>
</cffunction>

<cffunction name="detectEnvironment" output="false" returntype="string">
<cfscript>
	// Override to detect your own environment, returns the name of the environment found.
	
	return "dev";
</cfscript>
</cffunction>



</cfcomponent>
