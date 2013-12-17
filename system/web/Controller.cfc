<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 		: Luis Majano
Description		:

This is the ColdBox Front Controller that dispatches events and manages your ColdBox application.
Only one instance of a specific ColdBox application exists.

----------------------------------------------------------------------->
<cfcomponent hint="This is the ColdBox Front Controller that dispatches events and manages your ColdBox application." output="false" serializable="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" returntype="any" access="public" hint="Constructor" output="false" colddoc:generic="coldbox.system.web.Controller">
		<cfargument name="appRootPath" 	type="any" required="true" hint="The application root path"/>
		<cfargument name="appKey"		type="any" required="true" hint="The application registered application key"/>
		<cfscript>
			// local members scope
			instance = structnew();
			// services scope
			services = createObject("java","java.util.LinkedHashMap").init( 7 );

			// CFML Engine Utility
			instance.CFMLEngine = CreateObject("component","coldbox.system.core.util.CFMLEngine").init();
			// Set Main Application Properties
			instance.coldboxInitiated 		= false;
			instance.aspectsInitiated 		= false;
			instance.appKey					= arguments.appKey;
			//Fix Application Path to last / standard.
			if( NOT reFind("(/|\\)$",arguments.appRootPath) ){
				arguments.appRootPath = appRootPath & "/";
			}
			instance.appHash				= hash( arguments.appRootPath );
			instance.appRootPath			= arguments.appRootPath;
			instance.configSettings 		= structNew();
			instance.coldboxSettings		= structNew();

			// Load up default ColdBox Settings
			createObject("component","coldbox.system.web.loader.FrameworkLoader").init().loadSettings( this );

			// Setup the ColdBox Services
			services.loaderService 		= CreateObject("component", "coldbox.system.web.services.LoaderService").init( this );

			// LogBox Default Configuration & Creation
			instance.logBox = services.loaderService.createDefaultLogBox();
			instance.log 	= instance.logBox.getLogger( this );

			// Setup the ColdBox Services
			services.requestService 	= CreateObject("component","coldbox.system.web.services.RequestService").init( this );
			services.debuggerService 	= CreateObject("component","coldbox.system.web.services.DebuggerService").init( this );
			services.handlerService 	= CreateObject("component", "coldbox.system.web.services.HandlerService").init( this );
			services.pluginService 		= CreateObject("component","coldbox.system.web.services.PluginService").init( this );
			services.moduleService 		= CreateObject("component", "coldbox.system.web.services.ModuleService").init( this );
			services.interceptorService = CreateObject("component", "coldbox.system.web.services.InterceptorService").init( this );

			// CacheBox Instance
			instance.cacheBox 	= createObject("component","coldbox.system.cache.CacheFactory");
			// WireBox Instance
			instance.wireBox	= createObject("component","coldbox.system.ioc.Injector");
			// Validation Manager
			instance.validationManager = "";

			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- Get instance memento --->
	<cffunction name="getMemento" access="public" returntype="any" output="false" hint="Get the controller's internal state">
		<cfset var memento = {
			instance = instance, services = services
		}>
		<cfreturn memento>
	</cffunction>

	<!--- Get The CFMLEngine object --->
	<cffunction name="getCFMLEngine" access="public" returntype="any" output="false" hint="Get the CFMLEngine utility(coldbox.system.core.util.CFMLEngine)" coldoc:generic="coldbox.system.core.util.CFMLEngine">
		<cfreturn instance.CFMLEngine>
	</cffunction>

	<!--- Get Set Validation Manager --->
	<cffunction name="getValidationManager" access="public" returntype="any" output="false" hint="Get the validation manager for the application">
    	<cfreturn instance.validationManager>
    </cffunction>
    <cffunction name="setValidationManager" access="public" returntype="any" output="false" hint="Store the validation manager for the application">
    	<cfargument name="validationManager" type="any" required="true">
    	<cfset instance.validationManager = arguments.validationManager>
		<cfreturn this>
    </cffunction>

	<!--- getSetCacheBox --->
	<cffunction name="getCacheBox" access="public" returntype="any" output="false" hint="Get the application's CacheBox instance as coldbox.system.cache.CacheFactory" colddoc:generic="coldbox.system.cache.CacheFactory">
    	<cfreturn instance.cacheBox>
    </cffunction>
    <cffunction name="setCacheBox" access="public" returntype="any" output="false" hint="Set the application's CacheBox instance">
    	<cfargument name="cacheBox" required="true" hint="As coldbox.system.cache.CacheFactory" colddoc:generic="coldbox.system.cache.CacheFactory">
    	<cfset instance.cacheBox = arguments.cacheBox>
		<cfreturn this>
    </cffunction>

	<!--- getLogBox --->
	<cffunction name="getLogBox" output="false" access="public" returntype="any" hint="Get the application's LogBox instance" colddoc:generic="coldbox.system.logging.LogBox">
		<cfreturn instance.logBox>
	</cffunction>
	<cffunction name="setLogBox" output="false" access="public" returntype="any" hint="Set the logBox instance">
		<cfargument name="logBox" required="true" hint="The logBox instance" colddoc:generic="coldbox.system.logging.LogBox"/>
		<cfset instance.logBox = arguments.logBox>
		<cfreturn this>
	</cffunction>

	<!--- getwireBox --->
	<cffunction name="getWireBox" output="false" access="public" returntype="any" hint="Get the application's LogBox instance" colddoc:generic="coldbox.system.logging.LogBox">
		<cfreturn instance.wireBox>
	</cffunction>
	<cffunction name="setWireBox" output="false" access="public" returntype="any" hint="Set the WireBox instance">
		<cfargument name="wireBox" required="true" hint="The WireBox instance" colddoc:generic="coldbox.system.ioc.Injector"/>
		<cfset instance.wireBox = arguments.wireBox>
		<cfreturn this>
	</cffunction>

	<!--- setLog --->
	<cffunction name="setLog" output="false" access="public" returnType="any" hint="Set the class logger object">
		<cfargument name="logger" required="true">
		<cfset instance.log = arguments.logger>
		<cfreturn this>
	</cffunction>

	<!--- getServices --->
	<cffunction name="getServices" output="false" access="public" returntype="any" hint="Get all the registered services structure" colddoc:generic="coldbox">
		<cfreturn services>
	</cffunction>
	
	<!--- AppKey --->
	<cffunction name="getAppKey" access="public" returntype="any" output="false" hint="Get this application's key in memory space (application scope)">
		<cfreturn instance.appKey>
	</cffunction>

	<!--- AppRootPath --->
	<cffunction name="getAppRootPath" access="public" returntype="any" output="false" hint="Get this application's physical path">
		<cfreturn instance.appRootPath>
	</cffunction>
	<cffunction name="setAppRootPath" access="public" returntype="any" output="false" hint="Set this application's physical path.">
		<cfargument name="appRootPath" required="true">
		<cfset instance.appRootPath = arguments.appRootPath>
		<cfreturn this>
	</cffunction>

	<!--- ColdBox Cache Manager --->
	<cffunction name="getColdboxOCM" access="public" output="false" returntype="any" hint="Get ColdboxOCM: coldbox.system.cache.CacheManager or new CacheBox providers coldbox.system.cache.IColdboxApplicationCache" colddoc:generic="coldbox.system.cache.IColdboxApplicationCache">
		<cfargument name="cacheName" type="any" required="false" default="default" hint="The cache name to retrieve"/>
		<cfscript>
			return instance.cacheBox.getCache( arguments.cacheName );
		</cfscript>
	</cffunction>
	<cffunction name="setColdboxOCM" access="public" output="false" returntype="any" hint="Set ColdboxOCM">
		<cfargument name="coldboxOCM" type="any" required="true" hint="coldbox.system.cache.CacheManager"/>
		<cfset instance.coldboxOCM = arguments.coldboxOCM/>
		<cfreturn this>
	</cffunction>

	<!--- Loader Service --->
	<cffunction name="getLoaderService" access="public" output="false" returntype="any" hint="Get LoaderService: coldbox.system.web.services.LoaderService">
		<cfreturn services.loaderService/>
	</cffunction>
	<cffunction name="setLoaderService" access="public" output="false" returntype="any" hint="Set LoaderService">
		<cfargument name="loaderService" type="any" required="true"/>
		<cfset services.loaderService = arguments.loaderService/>
		<cfreturn this>
	</cffunction>

	<!--- Module Service --->
	<cffunction name="getModuleService" access="public" returntype="any" output="false" hint="Get ModuleService: coldbox.system.web.services.ModuleService">
		<cfreturn services.moduleService>
	</cffunction>
	<cffunction name="setModuleService" access="public" returntype="any" output="false" hint="Set ModuleService">
		<cfargument name="moduleService" type="any" required="true">
		<cfset services.moduleService = arguments.moduleService>
		<cfreturn this>
	</cffunction>

	<!--- Exception Service --->
	<cffunction name="getExceptionService" access="public" output="false" returntype="any" hint="Get ExceptionService: coldbox.system.web.services.ExceptionService">
		<cfreturn CreateObject("component", "coldbox.system.web.services.ExceptionService").init( this )/>
	</cffunction>

	<!--- Request Service --->
	<cffunction name="getRequestService" access="public" output="false" returntype="any" hint="Get RequestService: coldbox.system.web.services.RequestService">
		<cfreturn services.requestService/>
	</cffunction>
	<cffunction name="setRequestService" access="public" output="false" returntype="any" hint="Set RequestService">
		<cfargument name="requestService" type="any" required="true"/>
		<cfset services.requestService = arguments.requestService/>
		<cfreturn this>
	</cffunction>

	<!--- Debugger Service --->
	<cffunction name="getDebuggerService" access="public" output="false" returntype="any" hint="Get DebuggerService: coldbox.system.web.services.DebuggerService">
		<cfreturn services.debuggerService/>
	</cffunction>
	<cffunction name="setDebuggerService" access="public" output="false" returntype="any" hint="Set DebuggerService">
		<cfargument name="debuggerService" type="any" required="true"/>
		<cfset services.debuggerService = arguments.debuggerService/>
		<cfreturn this>
	</cffunction>

	<!--- Plugin Service --->
	<cffunction name="getPluginService" access="public" output="false" returntype="any" hint="Get PluginService: coldbox.system.web.services.PluginService">
		<cfreturn services.pluginService/>
	</cffunction>
	<cffunction name="setPluginService" access="public" output="false" returntype="any" hint="Set PluginService">
		<cfargument name="pluginService" type="Any" required="true"/>
		<cfset services.pluginService = arguments.pluginService/>
		<cfreturn this>
	</cffunction>

	<!--- Interceptor Service --->
	<cffunction name="getInterceptorService" access="public" output="false" returntype="any" hint="Get interceptorService: coldbox.system.web.services.InterceptorService">
		<cfreturn services.interceptorService/>
	</cffunction>
	<cffunction name="setInterceptorService" access="public" output="false" returntype="any" hint="Set interceptorService">
		<cfargument name="interceptorService" type="any" required="true"/>
		<cfset services.interceptorService = arguments.interceptorService/>
		<cfreturn this>
	</cffunction>

	<!--- Handler Service --->
	<cffunction name="getHandlerService" access="public" output="false" returntype="any" hint="Get HandlerService: coldbox.system.web.services.HandlerService">
		<cfreturn services.handlerService/>
	</cffunction>
	<cffunction name="setHandlerService" access="public" output="false" returntype="any" hint="Set HandlerService">
		<cfargument name="handlerService" type="any" required="true"/>
		<cfset services.handlerService = arguments.handlerService/>
		<cfreturn this>
	</cffunction>

	<!--- Getter & Setter Internal Configuration Structures --->
	<cffunction name="getConfigSettings" access="public" returntype="any" output="false" hint="I retrieve the Config Settings Structure by Reference" colddoc:generic="struct">
		<cfreturn instance.configSettings>
	</cffunction>
	<cffunction name="setConfigSettings" access="public" output="false" returntype="any" hint="Set ConfigSettings">
		<cfargument name="configSettings" required="true" colddoc:generic="struct"/>
		<cfset instance.configSettings = arguments.configSettings/>
		<cfreturn this>
	</cffunction>
	<cffunction name="getColdboxSettings" access="public" returntype="any" output="false" hint="I retrieve the ColdBox Settings Structure by Reference" colddoc:generic="struct">
		<cfreturn instance.coldboxSettings>
	</cffunction>
	<cffunction name="setColdboxSettings" access="public" output="false" returntype="any" hint="Set ColdboxSettings">
		<cfargument name="coldboxSettings" required="true" colddoc:generic="struct"/>
		<cfset instance.coldboxSettings = arguments.coldboxSettings/>
		<cfreturn this>
	</cffunction>

	<!--- ColdBox Initiation Flag --->
	<cffunction name="getColdboxInitiated" access="public" output="false" returntype="any" hint="Get ColdboxInitiated: Boolean">
		<cfreturn instance.coldboxInitiated/>
	</cffunction>
	<cffunction name="setColdboxInitiated" access="public" output="false" returntype="any" hint="Set ColdboxInitiated">
		<cfargument name="coldboxInitiated" required="true"/>
		<cfset instance.coldboxInitiated = arguments.coldboxInitiated/>
		<cfreturn this>
	</cffunction>

	<!--- Aspects Initiated Flag --->
	<cffunction name="getAspectsInitiated" access="public" output="false" returntype="any" hint="Get AspectsInitiated" colddoc:generic="boolean">
		<cfreturn instance.aspectsInitiated/>
	</cffunction>
	<cffunction name="setAspectsInitiated" access="public" output="false" returntype="any" hint="Set AspectsInitiated">
		<cfargument name="aspectsInitiated" required="true"/>
		<cfset instance.aspectsInitiated = arguments.aspectsInitiated/>
		<cfreturn this>
	</cffunction>

	<!--- App hash --->
	<cffunction name="getAppHash" access="public" output="false" returntype="any" hint="Get AppHash">
		<cfreturn instance.appHash/>
	</cffunction>
	<cffunction name="setAppHash" access="public" output="false" returntype="any" hint="Set AppHash">
		<cfargument name="appHash" required="true"/>
		<cfset instance.appHash = arguments.appHash/>
		<cfreturn this>
	</cffunction>

	<!--- Config Structures Accessors/Mutators --->
	<cffunction name="getSettingStructure" hint="Compatability & Utility Method. By default I retrieve the Config Settings. You can change this by using the FWSetting flag." access="public" returntype="any" output="false" colddoc:generic="struct">
		<!--- ************************************************************* --->
		<cfargument name="FWSetting"  	type="any" required="false"  hint="Boolean Flag. If true, it will retrieve from the fwSettingsStruct else the configStruct. Default is false." default="false">
		<cfargument name="deepCopyFlag" type="any" required="false" default="false" hint="Default is false. True, creates a deep copy of the structure.">
		<!--- ************************************************************* --->
		<cfscript>
		if (arguments.FWSetting){
			if (arguments.deepCopyFlag){
				return duplicate(instance.coldboxSettings);
			}
			return instance.coldboxSettings;
		}
		else{
			if (arguments.deepCopyFlag){
				return duplicate(instance.configSettings);
			}
			return instance.configSettings;
		}
		</cfscript>
	</cffunction>
	<cffunction name="getSetting" hint="I get a setting from the FW Config structures. Use the FWSetting boolean argument to retrieve from the fwSettingsStruct." access="public" returntype="any" output="false">
		<!--- ************************************************************* --->
		<cfargument name="name" 	    type="any"   	hint="Name of the setting key to retrieve"  >
		<cfargument name="FWSetting"  	type="any" 	 	required="false"  hint="Boolean Flag. If true, it will retrieve from the fwSettingsStruct else from the configStruct. Default is false." default="false">
		<cfargument name="defaultValue"	type="any" 		required="false" hint="Default value to return if not found.">
		<!--- ************************************************************* --->
		<cfscript>
			var target = instance.configSettings;

			if( arguments.FWSetting ){ target = instance.coldboxSettings; }

			if ( settingExists(arguments.name,arguments.FWSetting) ){
				return target[arguments.name];
			}

			// Default value
			if( structKeyExists(arguments, "defaultValue") ){
				return arguments.defaultValue;
			}

			getUtil().throwit(message="The setting #arguments.name# does not exist.",
							  detail="FWSetting flag is #arguments.FWSetting#",
							  type="Controller.SettingNotFoundException");
			</cfscript>
	</cffunction>
	<cffunction name="settingExists" returntype="any" access="public"	hint="I Check if a value exists in the configstruct or the fwsettingsStruct." output="false" colddoc:generic="boolean">
		<!--- ************************************************************* --->
		<cfargument name="name" 		type="any" required="true" 	hint="Name of the setting to find.">
		<cfargument name="FWSetting"  	type="any" required="false" hint="Boolean Flag. If true, it will retrieve from the fwSettingsStruct else from the configStruct. Default is false." default="false">
		<!--- ************************************************************* --->
		<cfscript>
		if (arguments.FWSetting){
			return structKeyExists(instance.coldboxSettings,arguments.name);
		}
		return structKeyExists(instance.configSettings, arguments.name);
		</cfscript>
	</cffunction>
	<cffunction name="setSetting" access="public" returntype="any" hint="I set a Global Coldbox setting variable in the configstruct, if it exists it will be overrided. This only sets in the ConfigStruct" output="false">
		<!--- ************************************************************* --->
		<cfargument name="name"  type="any"   hint="The name of the setting" >
		<cfargument name="value" type="any"   hint="The value of the setting (Can be simple or complex)">
		<!--- ************************************************************* --->
		<cfscript>
		instance.configSettings['#arguments.name#'] = arguments.value;
		return this;
		</cfscript>
	</cffunction>

	<!--- Plugin Factories --->
	<cffunction name="getPlugin" access="Public" returntype="any" hint="I am the Plugin cfc object factory." output="false">
		<!--- ************************************************************* --->
		<cfargument name="plugin" 		type="any"  required="true"  hint="The Plugin object's name to instantiate" >
		<cfargument name="customPlugin" type="any"  required="false" default="false" hint="Used internally to create custom plugins. Boolean">
		<cfargument name="newInstance"  type="any"  required="false" default="false" hint="If true, it will create and return a new plugin. No caching or persistance.">
		<cfargument name="module" 		type="any" 	required="false" default="" hint="The module to retrieve the plugin from"/>
		<cfargument name="init" 		type="any"  required="false" default="true" hint="Auto init() the plugin upon construction, Boolean"/>
		<!--- ************************************************************* --->
		<cfscript>
		if ( arguments.newInstance ){
			return services.pluginService.new(arguments.plugin,arguments.customPlugin,arguments.module,arguments.init);
		}
		return services.pluginService.get(arguments.plugin,arguments.customPlugin,arguments.module,arguments.init);
		</cfscript>
	</cffunction>

	<!--- Set Next Event --->
	<cffunction name="setNextEvent" access="public" returntype="any" hint="I Set the next event to run and relocate the browser to that event. If you are in SES mode, this method will use routing instead. You can also use this method to relocate to an absolute URL or a relative URI"  output="false">
		<!--- ************************************************************* --->
		<cfargument name="event"  				required="false" type="string"  default="#getSetting("DefaultEvent")#" hint="The name of the event to run, if not passed, then it will use the default event found in your configuration file.">
		<cfargument name="queryString"  		required="false" type="string"  default="" hint="The query string to append, if needed. If in SES mode it will be translated to convention name value pairs">
		<cfargument name="addToken"				required="false" type="boolean" default="false"	hint="Wether to add the tokens or not. Default is false">
		<cfargument name="persist" 				required="false" type="string"  default="" hint="What request collection keys to persist in flash ram">
		<cfargument name="persistStruct" 		required="false" type="struct"  default="#structnew()#" hint="A structure key-value pairs to persist in flash ram.">
		<cfargument name="ssl"					required="false" type="boolean" hint="Whether to relocate in SSL or not. You need to explicitly say TRUE or FALSE if going out from SSL. If none passed, we look at the even's SES base URL (if in SES mode)">
		<cfargument name="baseURL" 				required="false" type="string"  default="" hint="Use this baseURL instead of the index.cfm that is used by default. You can use this for ssl or any full base url you would like to use. Ex: https://mysite.com/index.cfm"/>
		<cfargument name="postProcessExempt"    required="false" type="boolean" default="false" hint="Do not fire the postProcess interceptors">
		<cfargument name="URL"  				required="false" type="string"  hint="The full URL you would like to relocate to instead of an event: ex: URL='http://www.google.com'"/>
		<cfargument name="URI"  				required="false" type="string"  hint="The relative URI you would like to relocate to instead of an event: ex: URI='/mypath/awesome/here'"/>
		<cfargument name="statusCode" 			required="false" type="numeric" default="0" hint="The status code to use in the relocation"/>
		<!--- ************************************************************* --->
		<cfscript>
			// Determine the type of relocation
			var relocationType  = "EVENT";
			var relocationURL   = "";
			var eventName	    = instance.configSettings["EventName"];
			var frontController = listlast(cgi.script_name,"/");
			var oRequestContext = services.requestService.getContext();
			var routeString     = 0;

			// Determine relocation type
			if( oRequestContext.isSES() ){ relocationType = "SES"; }
			if( structKeyExists(arguments,"URL") ){ relocationType = "URL"; }
			if( structKeyExists(arguments,"URI") ){ relocationType = "URI"; }

			// Cleanup event string to default if not sent in
			if( len(trim(arguments.event)) eq 0 ){ arguments.event = getSetting("DefaultEvent"); }
			// Overriding Front Controller via baseURL argument
			if( len(trim(arguments.baseURL)) ){ frontController = arguments.baseURL; }

			// Relocation Types
			switch( relocationType ){
				// FULL URL relocations
				case "URL" : {
					relocationURL = arguments.URL;
					// Check SSL?
					if( structKeyExists(arguments, "ssl") ){
						relocationURL = updateSSL(relocationURL,arguments.ssl);
					}
					// Query String?
					if( len(trim(arguments.queryString)) ){ relocationURL = relocationURL & "?#arguments.queryString#"; }
					break;
				}

				// URI relative relocations
				case "URI" : {
					relocationURL = arguments.URI;
					// Query String?
					if( len(trim(arguments.queryString)) ){ relocationURL = relocationURL & "?#arguments.queryString#"; }
					break;
				}

				// Default event relocations
				case "SES" : {
					// Route String start by converting event syntax to / syntax
					routeString = replace(arguments.event,".","/","all");
					// Convert Query String to convention name value-pairs
					if( len(trim(arguments.queryString)) ){
						// If the routestring ends with '/' we do not want to
						// double append '/'
						if (right(routeString,1) NEQ "/")
						{
							routeString = routeString & "/" & replace(arguments.queryString,"&","/","all");
						} else {
							routeString = routeString & replace(arguments.queryString,"&","/","all");
						}
						routeString = replace(routeString,"=","/","all");
					}

					// Get Base relocation URL from context
					relocationURL = oRequestContext.getSESBaseURL();
					//if the sesBaseURL is nothing, set it to the setting
					if(!len(relocationURL)){relocationURL = getSetting('sesBaseURL');}
					//add the trailing slash if there isnt one
					if( right(relocationURL,1) neq "/" ){ relocationURL = relocationURL & "/"; }

					// Check SSL?
					if( structKeyExists(arguments, "ssl") ){
						relocationURL = updateSSL(relocationURL,arguments.ssl);
					}

					// Finalize the URL
					relocationURL = relocationURL & routeString;

					break;
				}
				default :{
					// Basic URL Relocation
					relocationURL = "#frontController#?#eventName#=#arguments.event#";
					// Check SSL?
					if( structKeyExists(arguments, "ssl") ){
						relocationURL = updateSSL(relocationURL,arguments.ssl);
					}
					// Query String?
					if( len(trim(arguments.queryString)) ){ relocationURL = relocationURL & "&#arguments.queryString#"; }
				}
			}

			// persist Flash RAM
			persistVariables(argumentCollection=arguments);

			// push Debugger Timers
			pushTimers();

			// Post Processors
			if( NOT arguments.postProcessExempt ){
				services.interceptorService.processState("postProcess");
			}

			// Save Flash RAM
			if( instance.configSettings.flash.autoSave ){
				services.requestService.getFlashScope().saveFlash();
			}

			// Send Relocation
			sendRelocation(URL=relocationURL,addToken=arguments.addToken,statusCode=arguments.statusCode);

			return this;
		</cfscript>
	</cffunction>

	<!--- Event Service Locator Factory --->
	<cffunction name="runEvent" returntype="any" access="Public" hint="I am an event handler runnable factory. If no event is passed in then it will run the default event from the config file." output="false">
		<!--- ************************************************************* --->
		<cfargument name="event"         	type="any" 	required="false" default="" 	 hint="The event to run as a string. If no current event is set, use the default event from the config.xml. This is a string">
		<cfargument name="prepostExempt" 	type="any" 	required="false" default="false" hint="If true, pre/post handlers will not be fired. Boolean" colddoc:generic="boolean">
		<cfargument name="private" 		 	type="any" 	required="false" default="false" hint="Execute a private event or not, default is false. Boolean" colddoc:generic="boolean">
		<cfargument name="default" 		 	type="any" 	required="false" default="false" hint="The flag that let's this service now if it is the default set event running or not. USED BY THE FRAMEWORK ONLY. Boolean" colddoc:generic="boolean">
		<cfargument name="eventArguments" 	type="any"  required="false" default="#structNew()#" hint="A collection of arguments to passthrough to the calling event handler method. Struct" colddoc:generic="struct"/>
		<!--- ************************************************************* --->
		<cfscript>

			var oRequestContext 	= services.requestService.getContext();
			var debuggerService	 	= services.debuggerService;
			var ehBean 				= "";
			var oHandler 			= "";
			var iData				= structnew();
			var loc					= structnew();

			// Check if event empty, if empty then use default event
			if(NOT len(trim(arguments.event)) ){
				arguments.event = oRequestContext.getCurrentEvent();
			}

			// Setup Invoker args
			loc.args 			= structnew();
			loc.args.event 		= oRequestContext;
			loc.args.rc			= oRequestContext.getCollection();
			loc.args.prc		= oRequestContext.getCollection(private=true);
			loc.args.eventArguments = arguments.eventArguments;

			// Setup Main Invoker Args
			loc.argsMain 			= structnew();
			loc.argsMain.event		= oRequestContext;
			loc.argsMain.rc			= loc.args.rc;
			loc.argsMain.prc		= loc.args.prc;
			structAppend(loc.argsMain, arguments.eventArguments);

			// Setup interception data
			iData.processedEvent 	= arguments.event;
			iData.eventArguments	= arguments.eventArguments;

			// Validate the incoming event and get a handler bean to continue execution
			ehBean = services.handlerService.getRegisteredHandler(arguments.event);

			// Validate this is not a view dispatch, else return for rendering
			if( ehBean.getViewDispatch() ){	return;	}

			// Is this a private event execution?
			ehBean.setIsPrivate(arguments.private);
			// Now get the correct handler to execute
			oHandler = services.handlerService.getHandler(ehBean,oRequestContext);
			// Validate again this is not a view dispatch as the handler might exist but not the action
			if( ehBean.getViewDispatch() ){	return;	}
		</cfscript>

		<!--- break cfscript here because we need to <cfrethrow> at the end --->
		<cftry>
			<cfscript>
				// Determine if it is An allowed HTTP method to execute, else throw error
				if( NOT structIsEmpty(oHandler.allowedMethods) AND
					structKeyExists(oHandler.allowedMethods,ehBean.getMethod()) AND
					NOT listFindNoCase(oHandler.allowedMethods[ehBean.getMethod()],oRequestContext.getHTTPMethod()) ){

					// Throw Exceptions
					getUtil().throwInvalidHTTP(className="Controller",
											   detail="The requested event: #arguments.event# cannot be executed using the incoming HTTP request method '#oRequestContext.getHTTPMethod()#'",
											   statusText="Invalid HTTP Method: '#oRequestContext.getHTTPMethod()#'",
											   statusCode="405");
				}

				// PRE ACTIONS
				if( NOT arguments.prePostExempt ){

					// PREEVENT Interceptor
					services.interceptorService.processState("preEvent",iData);
					
					// Verify if event was overriden
					if( arguments.event NEQ iData.processedEvent ){
						// Validate the overriden event
						ehBean = services.handlerService.getRegisteredHandler( iData.processedEvent );
						// Get new handler to follow execution
						oHandler = services.handlerService.getHandler( ehBean, oRequestContext );
					}

					// Execute Pre Handler if it exists and valid?
					if( oHandler._actionExists("preHandler") AND validateAction(ehBean.getMethod(),oHandler.PREHANDLER_ONLY,oHandler.PREHANDLER_EXCEPT) ){
						loc.tHash = services.debuggerService.timerStart("invoking runEvent [preHandler] for #arguments.event#");

						oHandler.preHandler(event=oRequestContext,rc=loc.args.rc,prc=loc.args.prc,action=ehBean.getMethod(),eventArguments=arguments.eventArguments);

						services.debuggerService.timerEnd(loc.tHash);
					}

					// Execute pre{Action}? if it exists and valid?
					if( oHandler._actionExists("pre#ehBean.getMethod()#") ){
						loc.tHash = services.debuggerService.timerStart("invoking runEvent [pre#ehBean.getMethod()#] for #arguments.event#");

						invoker(oHandler,"pre#ehBean.getMethod()#",loc.args);

						services.debuggerService.timerEnd(loc.tHash);
					}
				}

				// Verify if event was overriden
				if( arguments.default and arguments.event NEQ oRequestContext.getCurrentEvent() ){
					// Validate the overriden event
					ehBean = services.handlerService.getRegisteredHandler(oRequestContext.getCurrentEvent());
					// Get new handler to follow execution
					oHandler = services.handlerService.getHandler(ehBean,oRequestContext);
				}

				// Execute Main Event or Missing Action Event
				if( arguments.private)
					loc.tHash 	= services.debuggerService.timerStart("invoking PRIVATE runEvent [#arguments.event#]");
				else
					loc.tHash 	= services.debuggerService.timerStart("invoking runEvent [#arguments.event#]");

				// Invoke onMissingAction event
				if( ehBean.isMissingAction() ){
					loc.results	= oHandler.onMissingAction(event=oRequestContext,rc=loc.args.rc,prc=loc.args.prc,missingAction=ehBean.getMissingAction(),eventArguments=arguments.eventArguments);
				}
				// Invoke main event
				else{

					// Around {Action} Advice Check?
					if( oHandler._actionExists("around#ehBean.getMethod()#") ){
						loc.tHash = services.debuggerService.timerStart("invoking runEvent [around#ehBean.getMethod()#] for #arguments.event#");

						// Add target Action to loc.args
						loc.args.targetAction  	= oHandler[ehBean.getMethod()];

						loc.results = invoker(oHandler, "around#ehBean.getMethod()#", loc.args);

						// Cleanup: Remove target action from loc.args for post events
						structDelete(loc.args, "targetAction");

						services.debuggerService.timerEnd(loc.tHash);
					}
					// Around Handler Advice Check?
					else if( oHandler._actionExists("aroundHandler") AND validateAction(ehBean.getMethod(),oHandler.aroundHandler_only,oHandler.aroundHandler_except) ){
						loc.tHash = services.debuggerService.timerStart("invoking runEvent [aroundHandler] for #arguments.event#");

						loc.results = oHandler.aroundHandler(event=oRequestContext,rc=loc.args.rc,prc=loc.args.prc,targetAction=oHandler[ehBean.getMethod()],eventArguments=arguments.eventArguments);

						services.debuggerService.timerEnd(loc.tHash);
					}
					else{
						// Normal execution
						loc.results = invoker(oHandler, ehBean.getMethod(), loc.argsMain, arguments.private);
					}
				}

				// finalize execution timer of main event
				services.debuggerService.timerEnd(loc.tHash);

				// POST ACTIONS
				if( NOT arguments.prePostExempt ){

					// Execute post{Action}?
					if( oHandler._actionExists("post#ehBean.getMethod()#") ){
						loc.tHash = services.debuggerService.timerStart("invoking runEvent [post#ehBean.getMethod()#] for #arguments.event#");
						invoker(oHandler,"post#ehBean.getMethod()#",loc.args);
						services.debuggerService.timerEnd(loc.tHash);
					}

					// Execute postHandler()?
					if( oHandler._actionExists("postHandler") AND validateAction(ehBean.getMethod(),oHandler.POSTHANDLER_ONLY,oHandler.POSTHANDLER_EXCEPT) ){
						loc.tHash = services.debuggerService.timerStart("invoking runEvent [postHandler] for #arguments.event#");
						oHandler.postHandler(event=oRequestContext,rc=loc.args.rc,prc=loc.args.prc,action=ehBean.getMethod(),eventArguments=arguments.eventArguments);
						services.debuggerService.timerEnd(loc.tHash);
					}

					// Execute POSTEVENT interceptor
					services.interceptorService.processState("postEvent",iData);

				}// end if prePostExempt
			</cfscript>
			<cfcatch>
				<!--- Check if onError exists? --->
				<cfif oHandler._actionExists("onError")>
					<cfset loc.results = oHandler.onError(event=oRequestContext,rc=loc.args.rc,prc=loc.args.prc,faultAction=ehBean.getmethod(),exception=cfcatch,eventArguments=arguments.eventArguments)>
				<cfelse>
					<!--- rethrow not supported in cfscript <cfthrow object="e"> doesn't work properly as we lose context --->
					<cfrethrow>
				</cfif>
			</cfcatch>
		</cftry>

		<cfscript>
			// Check if sending back results
			if( structKeyExists(loc,"results") ){
				return loc.results;
			}
		</cfscript>
	</cffunction>

	<!--- Flash Perist variables. --->
	<cffunction name="persistVariables" access="public" returntype="any" hint="@deprecated DO NOT USE ANYMORE. Persist variables for flash redirections, it can use a structure of name-value pairs or keys from the request collection. Use the flash object instead, this method will auto-save all persistence automatically." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="persist" 	 		required="false" default="" hint="What request collection keys to persist in the relocation. Keys must exist in the relocation">
		<cfargument name="persistStruct" 	required="false" hint="A structure of key-value pairs to persist." colddoc:generic="struct">
		<!--- ************************************************************* --->
		<cfscript>
			var flash = getRequestService().getFlashScope();

			// persist persistStruct if passed
			if( structKeyExists(arguments, "persistStruct") ){
				flash.putAll(map=arguments.persistStruct,saveNow=true);
			}

			// Persist RC keys if passed.
			if( len(trim(arguments.persist)) ){
				flash.persistRC(include=arguments.persist,saveNow=true);
			}
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- validateAction --->
	<cffunction name="validateAction" output="false" access="private" returntype="any" hint="Checks if an action can be executed according to inclusion/exclusion lists. Boolean">
		<cfargument name="action" 		type="any" required="true" 	default="" hint="The action to check"/>
		<cfargument name="inclusion" 	type="any" required="false" default="" hint="inclusion list"/>
		<cfargument name="exclusion" 	type="any" required="false" default="" hint="exclusion list"/>
		<cfscript>
			if( (
					(len(arguments.inclusion) AND listfindnocase(arguments.inclusion,arguments.action))
				     OR
				    (NOT len(arguments.inclusion))
				 )
				 AND
				 ( listFindNoCase(arguments.exclusion,arguments.action) EQ 0 )
			){
				return true;
			}

			return false;
		</cfscript>
	</cffunction>

	<!--- Get the util object --->
	<cffunction name="getUtil" access="private" output="false" returntype="any" hint="Create and return a util object" colddoc:generic="coldbox.system.core.util.Util">
		<cfreturn CreateObject("component","coldbox.system.core.util.Util")/>
	</cffunction>

	<!--- invoker --->
	<cffunction name="invoker" output="false" access="private" returntype="any" hint="Method Invoker">
		<cfargument name="target" 			type="any" 		required="true" hint=""/>
		<cfargument name="method" 			type="any" 		required="true" hint=""/>
		<cfargument name="argCollection" 	type="any" 		required="false" default="#structNew()#" hint="The argument collection to pass"/>
		<cfargument name="private" 			type="any" 		required="false" default="false" hint="Private method or not? Boolean"/>
		<cfset var refLocal = structnew()>

		<cfif arguments.private>
			<!--- Call Private Event --->
			<cfinvoke component="#arguments.target#" method="_privateInvoker" returnvariable="refLocal.results">
				<cfinvokeargument name="method" 		value="#arguments.method#">
				<cfinvokeargument name="argCollection" 	value="#arguments.argCollection#">
			</cfinvoke>
		<cfelse>
			<cfinvoke component="#arguments.target#"
					  method="#arguments.method#"
					  returnvariable="refLocal.results"
				  	  argumentcollection="#arguments.argCollection#">
		</cfif>

		<cfif structKeyExists(refLocal,"results")><cfreturn refLocal.results></cfif>
	</cffunction>

	<!--- Push Timers --->
	<cffunction name="pushTimers" access="private" returntype="any" hint="Push timers into stack" output="false" >
		<cfset services.debuggerService.recordProfiler()>
		<cfreturn this>
	</cffunction>

	<!--- sendRelocation --->
    <cffunction name="sendRelocation" output="false" access="private" returntype="any" hint="Send a CF relocation via ColdBox">
    	<cfargument name="url" 			required="true"  hint="The URL to relocate to"/>
		<cfargument name="addtoken"		required="false" default="false" hint="Add the CF tokens or not" colddoc:generic="boolean">
    	<cfargument name="statusCode" 	required="false" default="0" hint="The status code to use" colddoc:generic="numeric">

    	<!--- Relocate --->
		<cfif arguments.statusCode neq 0>
    		<cflocation url="#arguments.url#" addtoken="#addtoken#" statuscode="#arguments.statusCode#">
		<cfelse>
			<cflocation url="#arguments.url#" addtoken="#addtoken#">
		</cfif>

		<cfreturn this>
    </cffunction>

	<!--- updateSSL --->
    <cffunction name="updateSSL" output="false" access="private" returntype="any" hint="Update SSL or not on a request string">
    	<cfargument name="inURL" required="true">
		<cfargument name="ssl"	 required="true">
		<cfscript>
			// Check SSL?
			if( arguments.ssl ){  arguments.inURL = replacenocase(arguments.inURL,"http:","https:"); }
			else{ arguments.inURL = replacenocase(arguments.inURL,"https:","http:"); }
			return arguments.inURL;
		</cfscript>
    </cffunction>

</cfcomponent>
