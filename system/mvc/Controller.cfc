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
	property name="appKey" 					type="string";
	property name="appRootPath" 			type="string";
	property name="appHash" 				type="string";
	property name="coldboxSettings"			type="struct" setter="false";
	property name="configSettings" 			type="struct";
	property name="configLocation" 			type="string";
	property name="configLocationOverride" 	type="boolean";
	property name="logBox" 					type="any";
	property name="wireBox" 				type="any";
	property name="cacheBox" 				type="any";
	property name="dataMarshaller"			type="any";
	property name="util"					type="any";

	/************************************** STATIC CONSTANTS *********************************************/

	// Release Static Metadata
	this.COLDBOX.codename 		= "ColdBox LITE";
	this.COLDBOX.author			= "Ortus Solutions";
	this.COLDBOX.authorEmail 	= "coldbox@ortussolutions.com";
	this.COLDBOX.authorWebsite	= "http://www.ortussolutions.com";
	this.COLDBOX.suffix			= "Gideon+Judges 6:15";
	this.COLDBOX.version		= "1.0.0";
	this.COLDBOX.description	= "This is the ColdBox LITE MVC Framework.";
	
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
		// Create Util
		util = new coldbox.system.core.util.Util();
		
		// Create & Configure LogBox
		var logBoxConfig = new coldbox.system.logging.config.LogBoxConfig()
			.appender(name="console", class="coldbox.system.logging.appenders.ConsoleAppender")
			.root(appenders="*");
		logBox = new coldbox.system.logging.LogBox( logBoxConfig, this );
		// Create WireBox only, no init
		wireBox	= createObject("component","coldbox.system.ioc.Injector");
		// CacheBox is Empty not used in Lite version
		cacheBox = "";
		// Create Data Marshaller
		dataMarshaller = new coldbox.system.core.conversion.DataMarshaller();
		
		return this;
	}
	
	function loadApplication(overrideConfigFile="", overrideAppMapping=""){
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
			throw(message="Config file not located in conventions: #this.COLDBOX.configConvention#", detail="", type="LoaderService.ConfigFileNotFound");
		}

		// Load Application Settings
		createObject("component","coldbox.system.mvc.core.ApplicationLoader")
			.init( this )
			.loadConfiguration( arguments.overrideAppMapping );
		
		// Configure WireBox
		wirebox.init( configSettings.wirebox.binderPath, configSettings, this);
		// Register System Handlers
		registerHandlers();
		// ColdBox Initiated
		coldboxInitiated = true;
		// feed the base event handler class
		wirebox.registerNewInstance(name="coldbox.system.mvc.EventHandler", instancePath="coldbox.system.mvc.EventHandler")
			.addDIConstructorArgument(name="controller", value=this);
		return this;
	}
	
	/************************************** DESTRUCTOR *********************************************/
	
	function processShutdown(){
		// Shutdown WireBox
		if( isObject( wireBox ) ){
			wireBox.shutdown();
		}
	}
	
	/************************************** APP SETTING METHODS *********************************************/

	struct function getSettingStructure(boolean FWSetting=false, boolean deepCopyFlag=false){
		if( arguments.FWSetting ){
			return ( arguments.deepCopyFlag ? duplicate( coldboxSettings ) : coldboxSettings );
		}
		return ( arguments.deepCopyFlag ? duplicate( configSettings ) : configSettings );
	}
	
	function getSetting(required name, boolean FWSetting=false, defaultValue){
		var target = ( arguments.FWSetting ? coldboxSettings : configSettings );
		
		// Exists?
		if ( settingExists(arguments.name, arguments.FWSetting) ){
			return target[ arguments.name ];
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
		return ( arguments.FWSetting ? structKeyExists( coldboxSettings, arguments.name ) :  structKeyExists( configSettings, arguments.name ) );
	}
		
	function setSetting(required name, required value){
		configSettings[ arguments.name ] = arguments.value;
		return this;
	}

	/************************************** RELOCATIONS *********************************************/
	
	function setNextEvent(event=getSetting("DefaultEvent"), queryString="", boolean addToken=false, boolean ssl, baseURL="", boolean postProcessExempt=false, URL, URI, numeric statusCode=0){
		// Determine the type of relocation
		var relocationType  = "EVENT";
		var relocationURL   = "";
		var eventName	    = configSettings["EventName"];
		var frontController = listlast( cgi.script_name,"/" );
		var oRequestContext = getContext();
		var routeString     = 0;

		// Determine relocation type
		if( structKeyExists(arguments,"URL") ){ relocationType = "URL"; }
		if( structKeyExists(arguments,"URI") ){ relocationType = "URI"; }

		// Cleanup event string to default if not sent in
		if( len( trim( arguments.event ) ) eq 0 ){ arguments.event = configSettings.defaultEvent; }
		// Overriding Front Controller via baseURL argument
		if( len( trim( arguments.baseURL ) ) ){ frontController = arguments.baseURL; }

		// Relocation Types
		switch( relocationType ){
			// FULL URL relocations
			case "URL" : {
				relocationURL = arguments.URL;
				// Check SSL?
				if( structKeyExists(arguments, "ssl") ){
					relocationURL = updateSSL( relocationURL, arguments.ssl );
				}
				// Query String?
				if( len( trim( arguments.queryString ) ) ){ relocationURL = relocationURL & "?#arguments.queryString#"; }
				break;
			}

			// URI relative relocations
			case "URI" : {
				relocationURL = arguments.URI;
				// Query String?
				if( len( trim( arguments.queryString ) ) ){ relocationURL = relocationURL & "?#arguments.queryString#"; }
				break;
			}

			// Default event relocations
			case "SES" : {
				// Route String start by converting event syntax to / syntax
				routeString = replace( arguments.event, ".", "/", "all" );
				// Convert Query String to convention name value-pairs
				if( len( trim( arguments.queryString ) ) ){
					// If the routestring ends with '/' we do not want to
					// double append '/'
					if( right( routeString, 1 ) NEQ "/" ){
						routeString = routeString & "/" & replace(arguments.queryString,"&","/","all");
					} else {
						routeString = routeString & replace(arguments.queryString,"&","/","all");
					}
					routeString = replace(routeString,"=","/","all");
				}

				// Get Base relocation URL from context
				relocationURL = oRequestContext.getSESBaseURL();
				if( right( relocationURL, 1 ) neq "/" ){ relocationURL = relocationURL & "/"; }

				// Check SSL?
				if( structKeyExists( arguments, "ssl" ) ){
					relocationURL = updateSSL( relocationURL, arguments.ssl );
				}

				// Finalize the URL
				relocationURL = relocationURL & routeString;

				break;
			}
			default :{
				// Basic URL Relocation
				relocationURL = "#frontController#?#eventName#=#arguments.event#";
				// Check SSL?
				if( structKeyExists( arguments, "ssl" ) ){
					relocationURL = updateSSL( relocationURL, arguments.ssl );
				}
				// Query String?
				if( len( trim( arguments.queryString ) ) ){ relocationURL = relocationURL & "&#arguments.queryString#"; }
			}
		}

		// Send Relocation
		sendRelocation(URL=relocationURL, addToken=arguments.addToken, statusCode=arguments.statusCode);

		return this;
	}
	
	/************************************** EXECUTIONS *********************************************/

	function runEvent(event="", boolean prePostExempt=false, boolean private=false, boolean defaultEvent=false, struct eventArguments={}){
		var oRequestContext 	= getContext();
		var ehBean 				= "";
		var oHandler 			= "";
		var loc					= structnew();

		// Check if event empty, if empty then use default event on request context
		if( NOT len( trim( arguments.event ) ) ){
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
		structAppend( loc.argsMain, arguments.eventArguments );

		// Validate the incoming event and get a handler bean to continue execution
		ehBean = getRegisteredHandler( arguments.event );

		// Validate this is not a view dispatch, else return for rendering
		if( ehBean.getViewDispatch() ){	return;	}

		// Is this a private event execution?
		ehBean.setIsPrivate( arguments.private );
		// Now get the correct handler to execute
		oHandler = getHandler( ehBean, oRequestContext );
		// Validate again this is not a view dispatch as the handler might exist but not the action
		if( ehBean.getViewDispatch() ){	return;	}

		try{
			// Determine if it is An allowed HTTP method to execute, else throw error
			if( NOT structIsEmpty( oHandler.allowedMethods ) AND
				structKeyExists( oHandler.allowedMethods, ehBean.getMethod() ) AND
				NOT listFindNoCase( oHandler.allowedMethods[ ehBean.getMethod() ], oRequestContext.getHTTPMethod() ) ){

				// Throw Exceptions
				util.throwInvalidHTTP(className="Controller",
									  detail="The requested event: #arguments.event# cannot be executed using the incoming HTTP request method '#oRequestContext.getHTTPMethod()#'",
									  statusText="Invalid HTTP Method: '#oRequestContext.getHTTPMethod()#'",
									  statusCode="405");
			}

			// PRE ACTIONS
			if( NOT arguments.prePostExempt ){

				// Execute Pre Handler if it exists and valid?
				if( oHandler._actionExists( "preHandler" ) AND validateAction( ehBean.getMethod(), oHandler.PREHANDLER_ONLY, oHandler.PREHANDLER_EXCEPT ) ){
					oHandler.preHandler(event=oRequestContext, rc=loc.args.rc, prc=loc.args.prc, action=ehBean.getMethod(), eventArguments=arguments.eventArguments);
				}

				// Execute pre{Action}? if it exists and valid?
				if( oHandler._actionExists( "pre#ehBean.getMethod()#" ) ){
					oHandler._privateInvoker( "pre#ehBean.getMethod()#", loc.args );
				}
			}

			// Verify if event was overriden
			if( arguments.defaultEvent AND arguments.event NEQ oRequestContext.getCurrentEvent() ){
				// Validate the overriden event
				ehBean = getRegisteredHandler( oRequestContext.getCurrentEvent() );
				// Get new handler to follow execution
				oHandler = getHandler( ehBean, oRequestContext );
			}

			// Invoke onMissingAction event
			if( ehBean.isMissingAction() ){
				loc.results	= oHandler.onMissingAction(event=oRequestContext, rc=loc.args.rc, prc=loc.args.prc, missingAction=ehBean.getMissingAction(), eventArguments=arguments.eventArguments);
			}
			// Invoke main event
			else{

				// Around {Action} Advice Check?
				if( oHandler._actionExists( "around#ehBean.getMethod()#" ) ){
					// Add target Action to loc.args
					loc.args.targetAction = oHandler[ ehBean.getMethod() ];
					loc.results = oHandler._privateInvoker( "around#ehBean.getMethod()#", loc.args );
					// Cleanup: Remove target action from loc.args for post events
					structDelete(loc.args, "targetAction");
				}
				// Around Handler Advice Check?
				else if( oHandler._actionExists( "aroundHandler" ) AND validateAction( ehBean.getMethod(), oHandler.aroundHandler_only, oHandler.aroundHandler_except ) ){
					loc.results = oHandler.aroundHandler(event=oRequestContext, rc=loc.args.rc, prc=loc.args.prc, targetAction=oHandler[ ehBean.getMethod() ], eventArguments=arguments.eventArguments);
				}
				else{
					// Normal execution
					loc.results = oHandler._privateInvoker( ehBean.getMethod(), loc.argsMain );
				}
			}

			// POST ACTIONS
			if( NOT arguments.prePostExempt ){

				// Execute post{Action}?
				if( oHandler._actionExists( "post#ehBean.getMethod()#" ) ){
					oHandler._privateInvoker( "post#ehBean.getMethod()#", loc.args );
				}

				// Execute postHandler()?
				if( oHandler._actionExists( "postHandler" ) AND validateAction( ehBean.getMethod(), oHandler.POSTHANDLER_ONLY, oHandler.POSTHANDLER_EXCEPT ) ){
					oHandler.postHandler(event=oRequestContext, rc=loc.args.rc, prc=loc.args.prc, action=ehBean.getMethod(), eventArguments=arguments.eventArguments);
				}

			}// end if prePostExempt
			
		}// end try statement
		catch(Any e){
			// Check if onError exists?
			if( oHandler._actionExists("onError") ){
				loc.results = oHandler.onError(event=oRequestContext,rc=loc.args.rc,prc=loc.args.prc,faultAction=ehBean.getmethod(),exception=cfcatch,eventArguments=arguments.eventArguments);
			}
			else{
				rethrow;
			}
		}
		// Check if sending back results
		if( structKeyExists(loc,"results") ){
			return loc.results;
		}
	}
	
	/************************************** REQUEST METHODS *********************************************/
	
	coldbox.system.mvc.core.RequestContext function requestCapture(){
		var context 	= getContext();
		var rc			= context.getCollection();
		var prc 		= context.getCollection(private=true);
		var eventName	= configSettings.eventName;
		
		// Capture FORM/URL
		if( isDefined("FORM") ){ structAppend( rc, FORM ); }
		if( isDefined("URL")  ){ structAppend( rc, URL ); }
		
		// Take snapshot of incoming collection
		prc[ "cbox_incomingContextHash" ] = hash( rc.toString() );
		// Default Event Determination
		if ( NOT structKeyExists( rc, eventName ) OR !len( rc[ eventName ] ) ){
			rc[ eventName ] = configSettings.defaultEvent;
		}
		// Event More Than 1 Check, grab the first event instance, other's are discarded
		if ( listLen( rc[ eventName ] ) GTE 2 ){
			rc[ eventName ] = getToken( rc[ eventName ], 2, ",");
		}
		// Default Event Action Checks
		defaultEventCheck( context );
		
		return context;
	}
	
	coldbox.system.mvc.core.RequestContext function getContext(){
		return ( structKeyExists( request, "cb_requestContext" ) ? request.cb_requestContext : createContext() );
	}
	
	function removeContext(){
		structDelete( request, "cb_requestContext" );
		return this;
	}
	
	private coldbox.system.mvc.core.RequestContext function createContext(){
		//Create the original request context
		request.cb_requestContext = new coldbox.system.mvc.core.RequestContext( configSettings );
		//Return Created Context
		return request.cb_requestContext;
	}
	
	function getRenderer(){
		return wirebox.getInstance(name="coldbox.system.mvc.core.Renderer", initArguments={controller=this});
	}
	
	/************************************** HANDLER METHODS *********************************************/
	
	function registerHandlers(){
		// Get recursive Array listing
		var handlerArray = getHandlerListing( configSettings.handlersPath );
		// Set registered Handlers
		setSetting( name="registeredHandlers", value=arrayToList( handlerArray ) );
		// Verify it
		if ( arrayLen( HandlerArray ) eq 0 ){
			throw(Message="No handlers were found in: #HandlersPath#, so I have no clue how you are going to run this application.", type="NoHandlersFoundException");
		}
		return this;
	}
	
	function defaultEventCheck(required event){
		var currentEvent = arguments.event.getCurrentEvent();
		// Do a Default Action Test First, if default action desired.
		if( listFindNoCase( configSettings.registeredHandlers, currentEvent ) ){
			// Append the default event action
			currentEvent &= "." & this.COLDBOX.eventAction;
			// Save it as the current Event
			event.setValue( configSettings.eventName, currentEvent );
		}
	}
	
	function getRegisteredHandler(required event){
		var handlerIndex 			= 0;
		var handlerReceived 		= "";
		var methodReceived 			= "";
		var handlerBean 			= createObject("component","coldbox.system.mvc.core.EventHandlerBean").init( configSettings.handlersInvocationPath );

		// Rip the handler and method
		handlerReceived = listLast( reReplace( arguments.event, "\.[^.]*$", "" ), ":" );
		methodReceived 	= listLast( arguments.event, "." );
		
		// Try to do list localization in the registry for full event string.
		handlerIndex = listFindNoCase( configSettings.registeredHandlers, handlerReceived );
		// Check for conventions location
		if ( handlerIndex ){
			return handlerBean
				.setHandler( listgetAt( configSettings.registeredHandlers, handlerIndex ) )
				.setMethod( methodReceived );
		}

		// Do View Dispatch Check Procedures
		if( isViewDispatch( arguments.event, handlerBean ) ){
			return handlerBean;
		}

		// Run invalid event procedures, handler not found
		invalidEvent( arguments.event, handlerBean );

		// If we get here, then invalid event handler is active and we need to
		// return an event handler bean that matches it
		return getRegisteredHandler( handlerBean.getFullEvent() );
	}
	
	function getHandler(required ehBean, required requestContext){
		// Create Runnable Object
		var oEventHandler = newHandler( arguments.ehBean.getRunnable() );
		// Does requested method/action of execution exist in handler?
		if ( NOT oEventHandler._actionExists( arguments.ehBean.getMethod() ) ){

			// Check if the handler has an onMissingAction() method, virtual Events
			if( oEventHandler._actionExists( "onMissingAction" ) ){
				// Override the method of execution
				arguments.ehBean.setMissingAction( arguments.ehBean.getMethod() );
				// Let's go execute our missing action
				return oEventHandler;
			}

			// Test for Implicit View Dispatch
			if( configSettings.implicitViews AND isViewDispatch( arguments.ehBean.getFullEvent(), arguments.ehBean ) ){
				return oEventHandler;
			}

			// Invalid Event procedures
			invalidEvent( arguments.ehBean.getFullEvent(), arguments.ehBean );

			// If we get here, then the invalid event kicked in and exists, else an exception is thrown
			// Go retrieve the handler that will handle the invalid event so it can execute.
			return getHandler( getRegisteredHandler( arguments.ehBean.getFullEvent() ), arguments.requestContext );

		}//method check finalized.
		return oEventHandler;
	}
	
	function newHandler(required invocationPath){
		// Check if handler mapped?
		if( NOT wirebox.getBinder().mappingExists( arguments.invocationPath ) ){
			// extra attributes
			var attribs = {
				handlerPath = arguments.invocationPath,
				isHandler	= true
			};
			// feed this handler to wirebox with virtual inheritance just in case, use registerNewInstance so its thread safe
			var mapping = wirebox.registerNewInstance(name=arguments.invocationPath, instancePath=arguments.invocationPath)
				.setVirtualInheritance( "coldbox.system.mvc.EventHandler" )
				.addDIConstructorArgument(name="controller", value=this)
				.setThreadSafe( true )
				.setScope( wirebox.getBinder().SCOPES.SINGLETON )
				.setExtraAttributes( attribs );
			// Are we caching or not handlers?
			if ( NOT configSettings.handlerCaching ){ 
				mapping.setScope( wirebox.getBinder().SCOPES.NOSCOPE ); 
			}
		}
		// retrieve, build and wire from wirebox
		return wirebox.getInstance( arguments.invocationPath );
	}
	
	private function invalidEvent(required event, required ehBean){
		// If onInvalidEvent is registered, use it
		if( len( trim( configSettings.onInvalidEvent ) ) ){

			// Test for invalid Event Error
			if ( compareNoCase( configSettings.onInvalidEvent, arguments.event ) eq 0 ){
				throw(message="The onInvalid event is also invalid",
					  detail="The onInvalidEvent setting is also invalid: #configSettings.onInvalidEvent#. Please check your settings",
					  type="onInValidEventSettingException");
			}

			// Store Invalid Event in PRC
			getContext().setValue( "invalidevent", arguments.event, true );

			// Override Event With On Invalid Event
			arguments.ehBean.setHandler( reReplace( configSettings.onInvalidEvent, "\.[^.]*$", "" ) )
				.setMethod( listLast( configSettings.onInvalidEvent, "." ) );
			return;
		}
		// Throw Exception
		throw(message="The event: #arguments.event# is not valid registered event.", type="EventHandlerNotRegisteredException");
	}
	
	private function getHandlerListing(required directory){
		var fileArray 	= [];
		var util	  	= getUtil();
		var files 		= directoryList( arguments.directory, true, "query", "*.cfc");
		// Convert windows \ to java /
		arguments.directory = replace( arguments.directory, "\", "/", "all" );
		// Iterate, clean and register
		for (var i=1; i lte files.recordcount; i++ ){
			// prepare paths
			var thisAbsolutePath = replace( files.directory[ i ], "\", "/", "all" ) & "/";
			var cleanHandler 	 = replacenocase( thisAbsolutePath, arguments.directory, "", "all" ) & files.name[ i ];
			// Clean OS separators to dot notation.
			cleanHandler = removeChars( replacenocase( cleanHandler, "/", ".", "all" ), 1, 1 );
			//Clean Extension
			cleanHandler = util.ripExtension( cleanhandler );
			//Add data to array
			ArrayAppend( fileArray, cleanHandler );
		}
		return fileArray;
	}
	
	private function isViewDispatch(required event, required ehBean){
		// Cleanup of . to / for lookups
		var cEvent = lcase( replace( arguments.event, ".", "/", "all" ) );
		// Locate view
		var targetView = getRenderer().locateView( cEvent );
		// Validate Target View
		if( fileExists( expandPath( targetView & ".cfm" ) ) ){
			arguments.ehBean.setViewDispatch( true );
			return true;
		}
		return false;
	}
	
	// No interceptors in lite version, WireBox listeners only
	function getInterceptorService(){ return ""; }

	/************************************** PRIVATE UTIL *********************************************/
	
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