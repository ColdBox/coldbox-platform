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
	     eventName = "event",
	     reinitPassword = "hello",
	     handlersIndexAutoReload = true,
	     configAutoReload = false,
	     handlerCaching = true,
	     eventCaching = true,
	     proxyReturnCollection = false,
	     flashURLpersistScope = "session",
	     messageBoxStyleOverride = true,
	     messageBoxStorageScope = "session"
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
	     requestStartHandler = "main.rs",
	     requestEndHandler = "main.re",
	     sessionStartHandler = "main.se",
	     sessionEndHandler = "main.se",
	     applicationStartHandler = "main.as",
	     applicationEndHandler ="main.ae",
	     onInvalidEvent = "",
	     exceptionHandler = ""
	};
	
	// Extension Points
	extensions = {
	     UDFLibraryFile = "includes/helpers/ApplicationHelper.cfm",
	     requestContextDecorator = "",
	     pluginsExternalLocation = "",
	     viewsExternalLocation = "",
	     layoutsExternalLocation = "",
	     handlersExternalLocation = "",
	     customErrorTemplate = ""
	};
	
	// Debugger
	debugger = {
	     debugMode = true,
	     debugPassword = "",
	     enableDumpVar = true,
	     enableBugReports = "",
	     bugEmails = "",
	     persistentTracers = true,
	     persistentRequestProfilers = true,
	     maxPersistentRequestProfilers = 30,
	     maxRCPanelQueryRows = 50,
	     TracerPanel = { show = true, expanded = true },
	     InfoPanel = { show = true, expanded = true },
	     CachePanel = { show = true, expanded = true },
	     RCPanel = { show = true, expanded = true }
	};
	
	// Model Integration
	models = {
	     objectCaching = false,
	     externalLocation = "",
	     definitionFile = "",
	     setterInjection = false,
	     stopRecursion = "",
	     debugLevel = LOGLEVELS.INFO
	};
	
	// IOC setup
	ioc = {
	     framework = "coldspring",
	     reload = false,
	     definitionFile = "config/services.xml",
	     objectCaching = false,
	     parentFramework = "",
	     parentDefinitionFile = "",
	     parentFrameworkCacheKey = "" //mutex with parentFramework, so you create it and store it in cache.
	};
	
	// Mail Settings
	mailSettings = {
	     server = "",
	     port = "",
	     username = "",
	     password = "",
	     from = ""
	};
	
	// Webservices
	webservices  = {
	     myCFC = "wsdl url",
		 anotherWebserice = "Wsld URL"
	};
	
	// Layouts
	layouts = {
	     defaultLayout = "",
	     defaultView = ""
	};
	// Register Layouts
	layout(name="pdf",file="layout.pdf.cfm",views="",folders="pdf");
	layout(name="word",file="layout.word.cfm",views="",folders="docs");
	
	// Datasources
	datsources = {
	     Alias = {name="", dbtype="", username="", password=""},
	     Alias2 = {name="", dbtype="", username="", password=""}
	};
	
	// Cache Configuration
	cache = {
	     objectDefaultTimeout = 60,
	     objectDefaultLastAccessTimeout = 30,
	     useLastAccessTimeout = true,
	     reapFrequency = 1,
	     maxObjects = 100,
	     freeMemoryPercentageThreshold = 0,
	     EvictionPolicy = "coldbox.system.cache.policies.LFU" //change this to class anywhere.
	};
	
	// i18n
	i18n = {
	     defaultResourceBundle = "",
	     defaultLocale = "en_US",
	     localeStorage = "session",
	     unknownTranslation = ""
	};
	
	// Interceptor Config
	interceptors = {
		throwOnInvalidStates = false,
		customInterceptionPoints = "onError, onList"
	};

	// Register Interceptors
	interceptor(name="autowire",class="coldbox.system.interceptors.Autowire");
	interceptor(name="ses",class="coldbox.system.interceptors.ses",configFile="config/routes.cfm");
	interceptor(name="deploy",
				class="coldbox.system.interceptors.Deploy",
				configFile="config/.deploytag",
				commandObject=$("appMapping") & "model.deploy");
	interceptor(name="TransferLoader",
				class="coldbox.system.orm.transfer.TransferLoader",
				configPath = "/#$("AppMapping")#/config/transfer.xml.cfm",
				definitionPath="/#$("AppMapping")#/config/definitions",
				datasourceAlias="blog");
	
	// LogBox Appenders
	logBox.appender(name="file",class="coldbox.system.logging.appenders.FileAppender");
	// Root Looger
	logBox.root(levelMin=0,levelMax=4, appenders="*");
	// Category definitions
	logBox.category(name="coldbox.system.interceptors",levelMax=logLevels.TRACE);
	logBox.category(name="coldbox.system.plugins",levelMax=logLevels.TRACE);
	// Category definitions by level
	logBox.OFF("category");
	logBox.FATAL("category");
	logBox.ERROR("category");	
	logBox.WAR("category");
	logBox.INFO("category");
	logBox.DEBUG("category");
	logBox.TRACE("category");
	
	//OR do a new LogBox DSL structure
	logBox = {
		appenders = {
			fileLog = {
				class="coldbox.system.logging.appenders.RollingFileAppender",
				layout="myLayout",
				properties={
						filePath="logs",
						autoExpand = true,
						filename = $("AppName")
					}
			},
			console = { class="coldbox.system.logging.appenders.ConsoleAppender" }
		},
		root = { levelMin="", levelMax="", appenders = "*"},
		categories = {
			"name" = {levelMin="", levelMax="", appenders=""},
			"myCat" = { levelMin="", levelMax="", appenders=""}
		},
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
