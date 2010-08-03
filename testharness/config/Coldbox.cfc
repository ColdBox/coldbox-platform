<cfcomponent output="false" hint="My App Configuration">
<cfscript>
/**
structures to create for configuration

- coldbox
- settings
- conventions
- environments
- ioc
- models
- debugger
- mailSettings
- i18n
- bugTracers
- webservices
- datasources
- layoutSettings
- layouts
- cacheEngine
- interceptorSettings
- interceptors
- modules

Special Placeholders
@AppMapping@

Available objects in variable scope
- controller
- logBoxConfig
- appMapping (auto calculated by ColdBox)

Required Methods
- configure() : The method ColdBox calls to configure the application.
Optional Methods
- detectEnvironment() : If declared the framework will call it and it must return the name of the environment you are on.
- {environment}() : The name of the environment found and called by the framework.

*/
	
	// Configure ColdBox Application
	function configure(){
	
		// coldbox directives
		coldbox = {
			//Application Setup
			appName 				= "ColdBox Test Harness",
			eventName 				= "event",
			
			//Development Settings
			debugMode				= false,
			debugPassword			= "",
			reinitPassword			= "",
			handlersIndexAutoReload = true,
			configAutoReload		= false,
			
			//Implicit Events
			defaultEvent			= "ehGeneral.dspHello",
			requestStartHandler		= "",
			requestEndHandler		= "",
			applicationStartHandler = "main.onApplicationStart",
			applicationEndHandler	= "",
			sessionStartHandler 	= "main.onSessionStart",
			sessionEndHandler		= "main.onSessionEnd",
			missingTemplateHandler	= "",
			
			//Extension Points
			UDFLibraryFile 			= "includes/udf.cfm",
			coldboxExtensionsLocation = "coldbox.testharness.extensions",
			pluginsExternalLocation = "coldbox.testing.testplugins",
			viewsExternalLocation	= "/coldbox/testing/testviews",
			layoutsExternalLocation = "/#appMapping#/extlayouts",
			handlersExternalLocation  = "coldbox.testing.testhandlers",
			requestContextDecorator = "coldbox.testharness.model.myRequestContextDecorator",
			modulesExternalLocation = ["/coldbox/testing/testModules","/coldbox/testing/testModules2"],
			
			//Error/Exception Handling
			exceptionHandler		= "",
			onInvalidEvent			= "",
			customErrorTemplate		= "",
				
			//Application Aspects
			handlerCaching 			= false,
			eventCaching			= true,
			proxyReturnCollection 	= false,
			flashURLPersistScope	= "session"	
		};
	
		// custom settings
		settings = {
			myStruct  = {name="Luis majano", email="info@email.com", active=true},
			myArray   = [1,2,3,4,5,6],
			myBaseURL = "apps.jfetmac",
			// rss reader
			feedReader_useCache = true,
			feedReader_cacheType = "ram",
			feedReader_cacheTimeout = 10,
			coldboxSideBar = true,
			testingModelPath = "coldbox.testing.testmodel",
			javaloader_libpath = controller.getAppRootPath() & "model/java"
		};
		
		// Modules Configuration
		modules = {
			autoReload = true,
			exclude    = [],
			include    = []
		};
		
		//Conventions
		conventions = {
			handlersLocation = "handlers",
			pluginsLocation = "plugins",
			viewsLocation = "views",
			layoutsLocation = "layouts",
			modelsLocation = "model",
			eventAction = "index"
		};
		
		// environment settings, create a detectEnvironment() method to detect it yourself.
		// create a function with the name of the environment so it can be executed if that environment is detected
		environments = {
			development = "^cf8.*,^railo.*",
			staging		= "test"
		};
		
		//IOC Integration
		ioc = {
			framework 		= "lightwire",
			reload 	  	  	= true,
			objectCaching 	= false,
			definitionFile  = "config/coldspring.xml.cfm",
			parentFactory 	= {
				framework = "coldspring",
				definitionFile = "config/parent.xml.cfm"
			}
		};
		
		//Model Integration
		models = {
			objectCaching = true,
			definitionFile = "config/modelMappings.cfm",
			externalLocation = "coldbox.testing.testmodel",
			SetterInjection = false,
			DICompleteUDF = "onDIComplete",
			StopRecursion = "",
			parentFactory 	= {
				framework = "coldspring",
				definitionFile = "config/parent.xml.cfm"
			}
		};
		
		//Debugger Settings
		debugger = {
			enableDumpVar = false,
			persistentRequestProfilers = true,
			maxPersistentRequestProfilers = 10,
			maxRCPanelQueryRows = 50,
			//Panels
			showTracerPanel = true,
			expandedTracerPanel = true,
			showInfoPanel = true,
			expandedInfoPanel = true,
			showCachePanel = true,
			expandedCachePanel = true,
			showRCPanel = true,
			expandedRCPanel = true
		};
		
		//Mailsettings
		mailSettings = {
			server = "",
			username = "",
			password = "",
			port = 25
		};
		
		//i18n & Localization
		i18n = {
			defaultResourceBundle = "includes/main",
			defaultLocale = "en_US",
			localeStorage = "session",
			unknownTranslation = "**NOT FOUND**"		
		};
		
		//bug tracers
		bugTracers = {
			enabled = false,
			bugEmails = "",
			mailFrom = "",
			customEmailBugReport = ""
		};
	
		//webservices
		webservices = {
			testWS = "http://www.test.com/test.cfc?wsdl",
			AnotherTestWS = "http://www.coldbox.org/distribution/updatews.cfc?wsdl"	
		};
		
		//Datasources
		datasources = {
			mysite   = {name="mySite", dbType="mysql", username="root", password="pass"},
			blog_dsn = {name="myBlog", dbType="oracle", username="root", password="pass"}
		};
	
		//Layout Settings
		layoutSettings = {
			defaultLayout = "Layout.Main.cfm",
			defaultView   = ""
		};
		
		//Register Layouts
		layouts = {
			login = {
				file = "Layout.tester.cfm",
				views = "vwLogin,test",
				folders = "tags,pdf/single"
			}
		};
	
		//cacheEngine
		/*
		*/
		cacheEngine = {
			objectDefaultTimeout = 60,
			objectDefaultLastAccessTimeout = 20,
			reapFrequency = 1,
			freeMemoryPercentageThreshold = 0,
			useLastAccessTimeouts = true,
			evictionPolicy = "LFU",
			evictCount = 5,
			maxObjects = 100
		};
	
		//Interceptor Settings
		interceptorSettings = {
			throwOnInvalidStates = false,
			customInterceptors = ""
		};
		
		//Register interceptors as an array, we need order
		interceptors = [
			//Deploy
			{name="Deploy", 
			 class="coldbox.system.interceptors.Deploy",
			 properties = {
			 	tagFile = "config/_deploy.tag",
			 	deployCommandObject = "coldbox.testharness.model.DeployCleanup",
			 	deployCommandModel = "DeployCommand"}},
			 
			 //Autowire
			 {class="coldbox.system.interceptors.Autowire",
			  properties = {
			  	entityInjection = true
			  }
			  },
			 
			 //SES
			 {class="coldbox.system.interceptors.SES",
			  properties={configFile="config/routes.cfm"}},
			 
			 //Observers
			 {class="#variables.appMapping#.interceptors.errorObserver"},
			 {class="#variables.appMapping#.interceptors.iocObserver"},
			 
			 //security
			 {class="coldbox.system.interceptors.Security",
			  properties={
			  	rulesSource = "xml",
			  	rulesFile = "config/security.xml.cfm"}},
			  
			  //Execution tracer
			  {class="#variables.appMapping#.interceptors.executionTracer"}
		];
		
		//LogBox DSL
		logBox = {
			// Define Appenders
			appenders = {
				coldboxTracer = { class="coldbox.system.logging.appenders.ColdboxTracerAppender", levelMin="FATAL", levelMax="DEBUG" },
				myConsole     = { class="coldbox.system.logging.appenders.ConsoleAppender" },
				fileAppender  = { class="coldbox.system.logging.appenders.RollingFileAppender",
								  properties = {
								  	filePath="logs", fileName=coldbox.appName, autoExpand=true
								 }}
			},
			// Root Logger
			root = { levelmax="DEBUG", appenders="*" } 
		};
	}
	
	function development(){
	
	}
	
</cfscript>

</cfcomponent>