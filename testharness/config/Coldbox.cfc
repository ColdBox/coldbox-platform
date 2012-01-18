<cfcomponent output="false" hint="My App Configuration">
<cfscript>
	
	// Configure ColdBox Application
	function configure(){
	
		// coldbox directives
		coldbox = {
			//Application Setup
			appName 				= "ColdBox Test Harness",
			eventName 				= "event",
			
			//Development Settings
			debugMode				= true,
			debugPassword			= "",
			reinitPassword			= "",
			handlersIndexAutoReload = true,
			
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
			proxyReturnCollection 	= false	
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
			testingModelPath = "coldbox.testing.testmodel",
			javaloader_libpath = controller.getAppRootPath() & "model/java"
		};
		
		// Modules Configuration
		modules = {
			autoReload = false,
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
		
		// WireBox
		wireBox = { 
			enabled = true,
			//binder="coldbox.testHarness.config.WireBox", 
			singletonReload=true 
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
			showRCPanel = false,
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
		*/
	
		//Interceptor Settings
		interceptorSettings = {
			throwOnInvalidStates = false,
			customInterceptionPoints = "customOutput"
		};
		
		//Register interceptors as an array, we need order
		interceptors = [
			// ses 
			{class="coldbox.system.interceptors.SES",
			  properties={configFile="config/routes.cfm"}},
			 
			//Observers
			{class="#variables.appMapping#.interceptors.errorObserver"},
				 
			//security
			{class="coldbox.system.interceptors.Security",
			 properties={
			 	rulesSource = "xml",
			  	rulesFile = "config/security.xml.cfm"}},
			  
			//Execution tracer
			{class="#variables.appMapping#.interceptors.executionTracer"}
		];
		
		// ORM
		orm = {
			// entity injection
			injection = {
				// enable it
				enabled = true,
				// the include list for injection
				include = "",
				// the exclude list for injection
				exclude = ""
			}
		};
		
		//LogBox DSL
		logBox = {
			// Define Appenders
			appenders = {
				coldboxTracer = { class="coldbox.system.logging.appenders.ColdboxTracerAppender", levelMin="FATAL", levelMax="DEBUG" },
				myConsole     = { class="coldbox.system.logging.appenders.ConsoleAppender" },
				fileAppender  = { class="coldbox.system.logging.appenders.RollingFileAppender",
								  properties = {
								  	filePath="logs", fileName=coldbox.appName, autoExpand=true, fileMaxSize="100"
								 }}
			},
			// Root Logger
			root = { levelmax="INFO", appenders="*" },
			debug = ["coldbox.system.aop"] 
		};
	}
	
	function development(){
	
	}
	
	// CFC is also an interceptor
	function afterConfigurationLoad(event,interceptData){
		var logger = controller.getLogBox().getLogger(this);
		logger.info("My application just loaded and this message is from the config object");
	}
	
</cfscript>

</cfcomponent>