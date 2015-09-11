/**
*********************************************************************************
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* Loads the framwork into memory and provides a ColdBox application.
* @author Luis Majano <lmajano@ortussolutions.com>
*/
component serializable="false" accessors="true"{

	/************************************** CONSTRUCTOR *********************************************/

	// Configuration File Override
	property name="COLDBOX_CONFIG_FILE";
	// Application root path
	property name="COLDBOX_APP_ROOT_PATH";
	// The key used in application scope to model this app
	property name="COLDBOX_APP_KEY";
	// The application mapping override, only used for Flex/SOAP apps, this is auto-calculated
	property name="COLDBOX_APP_MAPPING";
	// Lock Timeout for startup operations
	property name="lockTimeout";
	// The application hash used for locks
	property name="appHash";

	// param the properties with defaults
	param name="COLDBOX_CONFIG_FILE" 	default="";
	param name="COLDBOX_APP_ROOT_PATH" 	default="#getDirectoryFromPath( getbaseTemplatePath() )#";
	param name="COLDBOX_APP_KEY" 		default="cbController";
	param name="COLDBOX_APP_MAPPING" 	default="";
	param name="appHash"				default="#hash( getBaseTemplatePath() )#";
	param name="lockTimeout"			default="30" type="numeric";

	/**
	* Constructor, called by your Application CFC
	* @COLDBOX_CONFIG_FILE.hint The override location of the config file
	* @COLDBOX_APP_ROOT_PATH.hint The location of the app on disk
	* @COLDBOX_APP_KEY.hint The key used in application scope for this application
	* @COLDBOX_APP_MAPPING.hint The application mapping override, only used for Flex/SOAP apps, this is auto-calculated
	*/
	function init(
		required string COLDBOX_CONFIG_FILE,
		required string COLDBOX_APP_ROOT_PATH,
		string COLDBOX_APP_KEY,
		string COLDBOX_APP_MAPPING=""
	){
		// Set vars for two main locations
		setCOLDBOX_CONFIG_FILE( arguments.COLDBOX_CONFIG_FILE );
		setCOLDBOX_APP_ROOT_PATH( arguments.COLDBOX_APP_ROOT_PATH );
		setCOLDBOX_APP_MAPPING( arguments.COLDBOX_APP_MAPPING );

		// App Key Check
		if( structKeyExists( arguments, "COLDBOX_APP_KEY" ) AND len( trim( arguments.COLDBOX_APP_KEY ) ) ){
			setCOLDBOX_APP_KEY( arguments.COLDBOX_APP_KEY );
		}
		return this;
	}

	/**
	* Loads the framework into application scope and executes app start procedures
	*/
	function loadColdBox(){
		var appKey = locateAppKey();
		// Cleanup of old code, just in case
		if( structkeyExists( application, appKey ) ){
			structDelete( application, appKey );
		}
		// Create Brand New Controller
		application[ appKey ] = new coldbox.system.web.Controller( COLDBOX_APP_ROOT_PATH, appKey );
		// Setup the Framework And Application
		application[ appKey ].getLoaderService().loadApplication( COLDBOX_CONFIG_FILE, COLDBOX_APP_MAPPING );
		// Application Start Handler
		if ( len( application[ appKey ].getSetting( "ApplicationStartHandler" ) ) ){
			application[ appKey ].runEvent( event=application[ appKey ].getSetting( "ApplicationStartHandler" ) );
		}
		// Check if fwreinit is sent, if sent, ignore it, we are loading the framework
		if( structKeyExists( url, "fwreinit" ) ){
			structDelete( url, "fwreinit" );
		}

		return this;
	}

	/**
	* Request Reload procedures
	*/
	function reloadChecks(){
		var appKey 			= locateAppKey();
		var cbController 	= "";
		var needReinit 		= isfwReinit();

		// Initialize the Controller If Needed, double locked
		if( NOT structkeyExists( application, appkey ) OR NOT application[ appKey ].getColdboxInitiated() OR needReinit ){
			lock type="exclusive" name="#appHash#" timeout="#lockTimeout#" throwontimeout="true"{
				// double lock
				if( NOT structkeyExists( application, appkey ) OR NOT application[ appKey ].getColdboxInitiated() OR needReinit ){

					// Verify if we are Reiniting?
					if( structkeyExists( application, appKey ) AND application[ appKey ].getColdboxInitiated() AND needReinit ){
						// process preReinit interceptors
						application[ appKey ].getInterceptorService().processState( "preReinit" );
						// Shutdown the application services
						application[ appKey ].getLoaderService().processShutdown();
					}

					// Reload ColdBox
					loadColdBox();
					// Remove any context stragglers
					structDelete( request, "cb_requestContext" );
				}
			} // end lock
		}

		try{
			// Get Controller Reference
			lock type="readonly" name="#appHash#" timeout="#lockTimeout#" throwontimeout="true"{
				cbController = application[ appKey ];
			}
			// WireBox Singleton AutoReload
			if( cbController.getSetting( "Wirebox" ).singletonReload ){
				lock type="exclusive" name="#appHash#" timeout="#lockTimeout#" throwontimeout="true"{
					cbController.getWireBox().clearSingletons();
				}
			}
			// Modules AutoReload
			if( cbController.getSetting( "ModulesAutoReload" ) ){
				lock type="exclusive" name="#appHash#" timeout="#lockTimeout#" throwontimeout="true"{
					cbController.getModuleService().reloadAll();
				}
			}
			// Handler's Index Auto Reload
			if( cbController.getSetting( "HandlersIndexAutoReload" ) ){
				lock type="exclusive" name="#appHash#" timeout="#lockTimeout#" throwontimeout="true"{
					cbController.getHandlerService().registerHandlers();
				}
			}
		}
		catch(Any e){
			// process the exception
			writeOutput( processException( cbController, e ) );
			// abort it, something went really wrong.
			abort;
		}

		return this;
	}

	/**
	* Process a ColdBox Request
	*/
	function processColdBoxRequest() output="true"{
		// Get Controller Reference
		lock type="readonly" name="#variables.appHash#" timeout="#variables.lockTimeout#" throwontimeout="true"{
			var cbController = application[ locateAppKey() ];
		}
		// Local references
		var interceptorService 	= cbController.getInterceptorService();
		var templateCache		= cbController.getCacheBox().getCache( "template" );

		try{
			// set request time, for info purposes
			request.fwExecTime = getTickCount();
			// Load Module CF Mappings
			cbController.getModuleService().loadMappings();
			// Create Request Context & Capture Request
			var event = cbController.getRequestService().requestCapture();

			//****** PRE PROCESS *******/
			interceptorService.processState( "preProcess" );
			if( len( cbController.getSetting( "RequestStartHandler" ) ) ){
				cbController.runEvent( cbController.getSetting( "RequestStartHandler" ), true );
			}

			//****** EVENT CACHING CONTENT DELIVERY *******/
			var refResults = {};
			if( structKeyExists( event.getEventCacheableEntry(), "cachekey" ) ){
				refResults.eventCaching = templateCache.get( event.getEventCacheableEntry().cacheKey );
			}
			// Verify if cached content existed.
			if ( structKeyExists( refResults, "eventCaching" ) ){
				// check renderdata
				if( refResults.eventCaching.renderData ){
					refResults.eventCaching.controller = cbController;
					renderDataSetup( argumentCollection=refResults.eventCaching );
				}
				// Authoritative Header
				getPageContext().getResponse().setStatus( 203, "Non-Authoritative Information" );
				// Render Content as binary or just output
				if( refResults.eventCaching.isBinary ){
					cbController.getDataMarshaller().renderContent( type="#refResults.eventCaching.contentType#", variable="#refResults.eventCaching.renderedContent#" );
				} else {
					writeOutput( refResults.eventCaching.renderedContent );
				}
			} else {
				//****** EXECUTE MAIN EVENT *******/
				if( NOT event.isNoExecution() ){
					refResults.results = cbController.runEvent( defaultEvent=true );
				}
				//****** RENDERING PROCEDURES *******/
				if( not event.isNoRender() ){
					var renderedContent = "";
					// pre layout
					interceptorService.processState( "preLayout" );
					// Check for Marshalling and data render
					var renderData = event.getRenderData();
					// Rendering/Marshalling of content
					if( isStruct( renderData ) and not structisEmpty( renderData ) ){
						renderedContent = cbController.getDataMarshaller().marshallData( argumentCollection=renderData );
					}
					// Check for Event Handler return results
					else if( structKeyExists( refResults, "results" ) ){
						renderedContent = refResults.results;
					}
					// Render Layout/View pair via set variable to eliminate whitespace
					else {
						renderedContent = cbcontroller.getRenderer().renderLayout( module=event.getCurrentLayoutModule(), viewModule=event.getCurrentViewModule() );
					}

					//****** PRE-RENDER EVENTS *******/
					var interceptorData = {
						renderedContent = renderedContent
					};
					interceptorService.processState( "preRender", interceptorData );
					// replace back content in case of modification
					renderedContent = interceptorData.renderedContent;

					//****** EVENT CACHING *******/
					var eCacheEntry = event.getEventCacheableEntry();
					if( structKeyExists( eCacheEntry, "cacheKey") AND
					    structKeyExists( eCacheEntry, "timeout")  AND
					    structKeyExists( eCacheEntry, "lastAccessTimeout" )
					){
						lock type="exclusive" name="#variables.appHash#.caching.#eCacheEntry.cacheKey#" timeout="#variables.lockTimeout#" throwontimeout="true"{
							// prepare storage entry
							var cacheEntry = {
								renderedContent = renderedContent,
								renderData		= false,
								contentType 	= "",
								encoding		= "",
								statusCode		= "",
								statusText		= "",
								isBinary		= false
							};
							// is this a render data entry? If So, append data
							if( isStruct( renderData ) and not structisEmpty( renderData ) ){
								cacheEntry.renderData = true;
								structAppend( cacheEntry, renderData, true );
							}
							// Cache it
							templateCache.set( eCacheEntry.cacheKey,
											   cacheEntry,
											   eCacheEntry.timeout,
											   eCacheEntry.lastAccessTimeout );
						}

					} // end event caching

					// Render Data? With stupid CF whitespace stuff.
					if( isStruct( renderData ) and not structisEmpty( renderData ) ){/*
						*/renderData.controller = cbController;renderDataSetup(argumentCollection=renderData);/*
						// Binary
						*/if( renderData.isBinary ){ cbController.getDataMarshaller().renderContent( type="#renderData.contentType#", variable="#renderedContent#" ); }/*
						// Non Binary
						*/else{ writeOutput( renderedContent ); }
					}
					else{
						writeOutput( renderedContent );
					}

					// Post rendering event
					interceptorService.processState( "postRender" );
				} // end no render

			} // end normal rendering procedures

			//****** POST PROCESS *******/
			if( len( cbController.getSetting( "RequestEndHandler" ) ) ){
				cbController.runEvent(event=cbController.getSetting("RequestEndHandler"), prePostExempt=true);
			}
			interceptorService.processState( "postProcess" );
			//****** FLASH AUTO-SAVE *******/
			if( cbController.getSetting( "flash" ).autoSave ){
				cbController.getRequestService().getFlashScope().saveFlash();
			}

		}
		catch(Any e){
			// process the exception and render its report
			writeOutput( processException( cbController, e ) );
		}

		// Time the request
		request.fwExecTime = getTickCount() - request.fwExecTime;
	}

	/**
	* Verify if a reinit is sent
	*/
	boolean function isFWReinit(){
		var reinitPass 		= "";
		var incomingPass 	= "";
		var appKey 			= locateAppKey();

		// CF Parm Structures just in case
		param name="FORM" 	default="#structNew()#";
		param name="URL"	default="#structNew()#";

		// Check if app exists already in scope
		if( not structKeyExists( application, appKey ) ){
			return true;
		}

		// Verify the reinit key is passed
		if ( structKeyExists( url, "fwreinit" ) or structKeyExists( form, "fwreinit" ) ){

			// Check if we have a reinit password at hand.
			if ( application[ appKey ].settingExists( "ReinitPassword" ) ){
				reinitPass = application[ appKey ].getSetting( "ReinitPassword" );
			}

			// pass Checks
			if ( NOT len( reinitPass ) ){
				return true;
			}

			// Get the incoming pass from form or url
			if( structKeyExists( form, "fwreinit" ) ){
				incomingPass = form.fwreinit;
			} else {
				incomingPass = url.fwreinit;
			}

			// Compare the passwords
			if( compare( reinitPass, hash( incomingPass ) ) eq 0 ){
				return true;
			}

		}//else if reinit found.

		return false;
	}

	/************************************** APP.CFC FACADES *********************************************/

	/**
	* On request start
	*/
	boolean function onRequestStart( required targetPage ) output=true{
		// Verify Reloading
		reloadChecks();
		// Process A ColdBox Request Only
		if( findNoCase( 'index.cfm', listLast( arguments.targetPage, '/' ) ) ){
			processColdBoxRequest();
		}
		return true;
	}

	/**
	* ON missing template
	*/
	boolean function onMissingTemplate( required template ){
		// get reference
		lock type="readonly" name="#variables.appHash#" timeout="#variables.lockTimeout#" throwontimeout="true"{
			var cbController = application[ locateAppKey() ];
		}
		//Execute Missing Template Handler if it exists
		if ( len( cbController.getSetting( "MissingTemplateHandler" ) ) ){
			// Save missing template in RC and right handler for this call.
			var event = cbController.getRequestService().getContext();
			event.setValue( "missingTemplate", arguments.template )
				.setValue( cbController.getSetting( "EventName" ), cbController.getSetting( "MissingTemplateHandler" ) );
			//Process it
			onRequestStart( "index.cfm" );
			// Return processed
			return true;
		}

		return false;
	}

	/**
	* ON session start
	*/
	function onSessionStart(){
		// get reference
		lock type="readonly" name="#variables.appHash#" timeout="#variables.lockTimeout#" throwontimeout="true"{
			var cbController = application[ locateAppKey() ];
		}
		// Session start interceptors
		cbController.getInterceptorService().processState( "sessionStart", session );
		//Execute Session Start Handler
		if( len( cbController.getSetting( "SessionStartHandler" ) ) ){
			cbController.runEvent( event=cbController.getSetting( "SessionStartHandler" ), prePostExempt=true );
		}
	}

	/**
	* ON session end
	*/
	function onSessionEnd( required struct sessionScope, struct appScope ){
		var cbController = "";

		// Get reference
		lock type="readonly" name="#variables.appHash#" timeout="#variables.lockTimeout#" throwontimeout="true"{
			//Check for cb Controller
			if ( structKeyExists( arguments.appScope, locateAppKey() ) ){
				cbController = arguments.appScope.cbController;
			}
		}

		if( not isSimpleValue( cbController ) ){
			// Get Context
			var event = cbController.getRequestService().getContext();

			// Execute interceptors
			var iData = {
				sessionReference = arguments.sessionScope,
				applicationReference = arguments.appScope
			};
			cbController.getInterceptorService().processState( "sessionEnd", iData );

			// Execute Session End Handler
			if ( len( cbController.getSetting( "SessionEndHandler" ) ) ){
				//Place session reference on event object
				event.setValue( "sessionReference", arguments.sessionScope )
					.setValue( "applicationReference", arguments.appScope );
				//Execute the Handler
				cbController.runEvent( event=cbController.getSetting( "SessionEndHandler" ), prepostExempt=true );
			}
		}
	}

	/**
	* ON application start
	*/
	boolean function onApplicationStart(){
		//Load ColdBox
		loadColdBox();
		return true;
	}

	/**
	* ON applicaiton end
	*/
	function onApplicationEnd( struct appScope ){
		var cbController = arguments.appScope[ locateAppKey() ];

		// Execute Application End interceptors
		cbController.getInterceptorService().processState( "applicationEnd" );
		// Execute Application End Handler
		if( len( cbController.getSetting( "applicationEndHandler" ) ) ){
			cbController.runEvent( event=cbController.getSetting( "applicationEndHandler" ) ,prePostExempt=true );
		}

		// Controlled service shutdown operations
		cbController.getLoaderService().processShutdown();
	}

	/************************************** PRIVATE HELPERS *********************************************/

	/**
	* Process an exception and returns a rendered bug report
	* @controller.hint The ColdBox Controller
	* @exception.hint The ColdFusion exception
	*/
	private string function processException( required controller, required exception ){
		// prepare exception facade object + app logger
		var oException	= new coldbox.system.web.context.ExceptionBean( arguments.exception );
		var appLogger  	= arguments.controller.getLogBox().getLogger( this );
		var event		= arguments.controller.getRequestService().getContext();

		// Announce interception
		arguments.controller.getInterceptorService()
			.processState( "onException", { exception = arguments.exception } );

		// Store exception in private context
		event.setValue( "exception", oException, true );

		//Run custom Exception handler if Found, else run default exception routines
		if ( len( arguments.controller.getSetting( "ExceptionHandler" ) ) ){
			try{
				arguments.controller.runEvent( arguments.controller.getSetting( "Exceptionhandler" ) );
			}
			catch(Any e){
				// Log Original Error First
				appLogger.error( "Original Error: #arguments.exception.message# #arguments.exception.detail# ", arguments.exception );
				// Log Exception Handler Error
				appLogger.error( "Error running exception handler: #arguments.controller.getSetting( "ExceptionHandler" )# #e.message# #e.detail#", e );
				// rethrow error
				rethrow;
			}
		} else {
			// Log Error
			appLogger.error( "Error: #arguments.exception.message# #arguments.exception.detail# ", arguments.exception );
		}

		// Render out error via CustomErrorTemplate or Core
		var customErrorTemplate = arguments.controller.getSetting( "CustomErrorTemplate" );
		if( len( customErrorTemplate ) ){

			// Do we have right path already, test by expanding
			if( fileExists( expandPath( customErrorTemplate ) ) ){
				bugReportTemplatePath = customErrorTemplate;
			} else {
				var appLocation = "/";
				if( len( arguments.controller.getSetting( "AppMapping" ) ) ){
					appLocation = appLocation & arguments.controller.getSetting( "AppMapping" ) & "/";
				}
				// Bug report path
				var bugReportTemplatePath = appLocation & reReplace( customErrorTemplate, "^/", "" );
			}
			// Show Bug Report
			savecontent variable="local.exceptionReport"{
				include "#bugReportTemplatePath#";
			}
		} else {
			// Default ColdBox Error Template
			savecontent variable="local.exceptionReport"{
				include "/coldbox/system/includes/BugReport-Public.cfm";
			}
		}

		return local.exceptionReport;
	}

	/**
	* Process Stack trace for errors
	*/
	private function processStackTrace( str ){
		var aMatches = REMatchNoCase( "\(([^\)]+)\)", arguments.str );
		for( var aString in aMatches ){
			arguments.str = replacenocase( arguments.str, aString, "<span class='highlight'>#aString#</span>", "all" );
		}
		var aMatches = REMatchNoCase( "\[([^\]]+)\]", arguments.str );
		for( var aString in aMatches ){
			arguments.str = replacenocase( arguments.str, aString, "<span class='highlight'>#aString#</span>", "all" );
		}
		var aMatches = REMatchNoCase( "\$([^(\(|\:)]+)(\:|\()", arguments.str );
		for( var aString in aMatches ){
			arguments.str = replacenocase( arguments.str, aString, "<span class='method'>#aString#</span>", "all" );
		}
		arguments.str = replace( arguments.str, chr( 13 ) & chr( 10 ), chr( 13 ) , 'all' );
		arguments.str = replace( arguments.str, chr( 10 ), chr( 13 ) , 'all' );
		arguments.str = replace( arguments.str, chr( 13 ), '<br>' , 'all' );
		arguments.str = replaceNoCase( arguments.str, chr(9), repeatString( "&nbsp;", 4 ), "all" );
		return arguments.str;
	}

	/**
	* Process render data setup
	* @controller.hint The ColdBox controller
	* @statusCode.hint The status code to send
	* @statusText.hint The status text to send
	* @contentType.hint The content type to send
	* @encoding.hint The content encoding
	*/
	private Bootstrap function renderDataSetup(
		required controller,
		required statusCode,
		required statusText,
		required contentType,
		required encoding
	){
    	// Status Codes
		getPageContext().getResponse().setStatus( arguments.statusCode, arguments.statusText );
		// Render the Data Content Type
		controller.getDataMarshaller().renderContent( type=arguments.contentType, encoding=arguments.encoding, reset=true );
		return this;
	}

	/**
	* Locate the application key
	*/
	private function locateAppKey(){
		if( len( trim( COLDBOX_APP_KEY ) ) ){
			return COLDBOX_APP_KEY;
		}
		return "cbController";
	}
}
