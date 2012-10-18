/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 		: Luis Majano
Description		:
This is the ColdBox Front Controller that dispatches events and manages your ColdBox application.
Only one instance of a specific ColdBox application exists.
**/
component serializable="false" accessors="true"{

	/************************************** APPLICATION PROPERTIES *********************************************/
	
	property name="coldboxInitiated" 		type="boolean";
	property name="aspectsInitiated" 		type="boolean";
	property name="appKey" 					type="string";
	property name="appRootPath" 			type="string";
	property name="appHash" 				type="string";
	property name="coldboxSettings"			type="struct" setter="false";
	property name="configSettings" 			type="struct";
	property name="configLocation" 			type="string";
	property name="configLocationOverride" 	type="boolean";
	property name="logBox" 					type="any";
	property name="log" 					type="any";
	property name="wireBox" 				type="any";

	/************************************** STATIC CONSTANTS *********************************************/

	// Release Static Metadata
	this.COLDBOX.codename 		= "ColdBox LITE";
	this.COLDBOX.author			= "Ortus Solutions";
	this.COLDBOX.authorEmail 	= "coldbox@ortussolutions.com";
	this.COLDBOX.authorWebsite	= "http://www.ortussolutions.com";
	this.COLDBOX.suffix			= "Jeremiah 29:13";
	this.COLDBOX.version		= "1.0.0";
	this.COLDBOX.description	= "This is the ColdBox Lite MVC Framework.";

	// Operation Static Defaults
	this.COLDBOX.eventName 		= "event";
	this.COLDBOX.eventAction	= "index";
	this.COLDBOX.defaultEvent 	= "main.index";
	this.COLDBOX.defaultLayout	= "main.cfm";

	// Static Conventions
    this.COLDBOX.handlersConvention	= "handlers";
	this.COLDBOX.layoutsConvention	= "layouts";
	this.COLDBOX.viewsConvention	= "views";
	this.COLDBOX.modelsConvention	= "model";
	this.COLDBOX.configConvention	= "config.Coldbox";
	
	/************************************** CONSTRUCTOR *********************************************/
	
	function init(required appRootPath, required appKey){

		// Set Main Application Properties
		coldboxInitiated 		= false;
		aspectsInitiated 		= false;
		variables.appKey		= arguments.appKey;
		//Fix Application Path to last / standard.
		if( NOT reFind("(/|\\)$",arguments.appRootPath) ){
			arguments.appRootPath = appRootPath & "/";
		}                                                  
		variables.appRootPath	= arguments.appRootPath;
		appHash					= hash( arguments.appRootPath );
		// ColdBox Settings
		coldboxSettings 		= this.COLDBOX;
		// Config Settings
		configSettings 			= structNew();
		configLocation			= "";
		configLocationOverride 	= false;

		// LogBox Default Configuration & Creation
		logBox = services.loaderService.createDefaultLogBox();
		log 	= logBox.getLogger( this );

		// WireBox Instance
		wireBox	= createObject("component","coldbox.system.ioc.Injector");

		return this;
	}
	
	function loadApplication(overrideConfigFile=""){
		// verify coldbox.cfc exists in convention: /app/config/Coldbox.cfc
		if( fileExists( appRootPath & replace( this.COLDBOX.configConvention, ".", "/", "all") & ".cfc" ) ){
			configLocation = this.COLDBOX.configConvention;
		}

		// Overriding the config file location? Maybe unit testing?
		if( len( arguments.overrideConfigFile ) ){
			configLocation 			= arguments.overrideConfigFile;
			configLocationOverride 	= true;
		}

		// If no config file location throw exception
		if( NOT len( configLocation ) ){
			getUtil().throwit(message="Config file not located in conventions: #this.COLDBOX.configConvention#",detail="",type="LoaderService.ConfigFileNotFound");
		}

		// Load Application Settings
		createObject("component","coldbox.system.lite.core.ApplicationLoader").init( this );
	}
	
	/************************************** PUBLIC *********************************************/

	struct function getSettingStructure(boolean FWSetting=false, boolean deepCopyFlag=false){
		if( arguments.FWSetting ){
			if (arguments.deepCopyFlag){
				return duplicate( coldboxSettings );
			}
			return coldboxSettings;
		}
		else{
			if( arguments.deepCopyFlag ){
				return duplicate( configSettings );
			}
			return configSettings;
		}
	}
	
	function getSetting(required name, boolean FWSetting=false, defaultValue){
		var target = configSettings;

		if( arguments.FWSetting ){ target = coldboxSettings; }

		if ( settingExists(arguments.name,arguments.FWSetting) ){
			return target[arguments.name];
		}

		// Default value
		if( structKeyExists(arguments, "defaultValue") ){
			return arguments.defaultValue;
		}

		throw(message="The setting #arguments.name# does not exist.",
			  detail="FWSetting flag is #arguments.FWSetting#",
			  type="Controller.SettingNotFoundException");
		
	}
	
	function settingExists(required name, boolean FWSetting=false){
		if (arguments.FWSetting){
			return structKeyExists(coldboxSettings,arguments.name);
		}
		return structKeyExists(configSettings, arguments.name);
	}
		
	function setSetting(required name, required value){
		configSettings['#arguments.name#'] = arguments.value;
		return this;
	}


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
			var eventName	    = configSettings["EventName"];
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
			if( configSettings.flash.autoSave ){
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

	/************************************** PRIVATE *********************************************/
	
	private function validateAction(required action, inclusion="", exclusion=""){
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
	}

	private function getUtil(){
		return CreateObject("component","coldbox.system.core.util.Util");
	}
    
	private function sendRelocation(required url, boolean addToken=false, numeric statusCode=0){
		if( arguments.statusCode NEQ 0 ){
			location(url=arguments.url, addToken=arguments.addToken, statusCode=arguments.statusCode);		
		}
		else{
			location(url=arguments.url, addToken=arguments.addToken);
		}
	}

	private function updateSSL(required inURL, required ssl){
		// Check SSL?
		if( arguments.ssl ){  arguments.inURL = replacenocase(arguments.inURL,"http:","https:"); }
		else{ arguments.inURL = replacenocase(arguments.inURL,"https:","http:"); }
		return arguments.inURL;
	}

}