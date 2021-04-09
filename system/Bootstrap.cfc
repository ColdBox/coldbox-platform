/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * @author Luis Majano <lmajano@ortussolutions.com>
 * Loads the framwork into memory and provides a ColdBox application.
 */
component serializable="false" accessors="true" {

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
	// By default if an app is reiniting and a request hits it, we will fail fast with a message
	property name="COLDBOX_FAIL_FAST";

	// param the properties with defaults
	param name="COLDBOX_CONFIG_FILE"   default="";
	param name="COLDBOX_APP_ROOT_PATH" default="#getDirectoryFromPath( getBaseTemplatePath() )#";
	param name="COLDBOX_APP_KEY"       default="cbController";
	param name="COLDBOX_APP_MAPPING"   default="";
	param name="appHash"               default="#hash( getBaseTemplatePath() )#";
	param name="lockTimeout" default="30" type="numeric";
	param name="COLDBOX_FAIL_FAST" default="true";

	/**
	 * Constructor, called by your Application CFC
	 * @COLDBOX_CONFIG_FILE The override location of the config file
	 * @COLDBOX_APP_ROOT_PATH The location of the app on disk
	 * @COLDBOX_APP_KEY The key used in application scope for this application
	 * @COLDBOX_APP_MAPPING The application mapping override, only used for Flex/SOAP apps, this is auto-calculated
	 * @COLDBOX_FAIL_FAST By default if an app is reiniting and a request hits it, we will fail fast with a message. This can be a boolean indicator or a closure.
	 */
	Bootstrap function init(
		required string COLDBOX_CONFIG_FILE,
		required string COLDBOX_APP_ROOT_PATH,
		string COLDBOX_APP_KEY,
		string COLDBOX_APP_MAPPING = "",
		any COLDBOX_FAIL_FAST      = true
	){
		// Set vars for two main locations
		setCOLDBOX_CONFIG_FILE( arguments.COLDBOX_CONFIG_FILE );
		setCOLDBOX_APP_ROOT_PATH( arguments.COLDBOX_APP_ROOT_PATH );
		setCOLDBOX_APP_MAPPING( arguments.COLDBOX_APP_MAPPING );
		setCOLDBOX_FAIL_FAST( arguments.COLDBOX_FAIL_FAST );

		// App Key Check
		if ( structKeyExists( arguments, "COLDBOX_APP_KEY" ) AND len( trim( arguments.COLDBOX_APP_KEY ) ) ) {
			setCOLDBOX_APP_KEY( arguments.COLDBOX_APP_KEY );
		}

		return this;
	}

	/**
	 * Loads the framework into application scope and executes app start procedures
	 *
	 * @throws InvalidColdBoxMapping
	 */
	function loadColdBox(){
		var appKey = locateAppKey();

		// Cleanup of old code, just in case
		if ( structKeyExists( application, appKey ) ) {
			structDelete( application, appKey );
		}

		// Verify Mapping
		if ( !fileExists( expandPath( "/coldbox/system/web/Controller.cfc" ) ) ) {
			var coldboxDirectory = reReplaceNoCase(
				getDirectoryFromPath( getCurrentTemplatePath() ),
				"[\\/]system",
				""
			);
			throw(
				message = "Cannot find the '/'coldbox' mapping",
				detail  = "It seems that you do not have a '/coldbox' mapping in your application and we cannot continue to process the request.
				The good news is that you can easily resolve this by either creating a mapping in your Admnistrator or in this application's
				Application.cfc that points to this directory: '#coldboxDirectory#'.  You can also copy the code snippet
				below to add to your Application.cfc's pseudo constructor: this.mappings[ '/coldbox' ] = '#coldboxDirectory#'",
				type = "InvalidColdBoxMapping"
			);
		}

		// Create Brand New Controller
		application[ appKey ] = new coldbox.system.web.Controller( COLDBOX_APP_ROOT_PATH, appKey );
		// Setup the Framework And Application
		application[ appKey ].getLoaderService().loadApplication( COLDBOX_CONFIG_FILE, COLDBOX_APP_MAPPING );
		// Get the reinit key
		// Application Start Handler
		try {
			if ( len( application[ appKey ].getSetting( "ApplicationStartHandler" ) ) ) {
				application[ appKey ].runEvent(
					event = application[ appKey ].getSetting( "ApplicationStartHandler" )
				);
			}
		} catch ( any e ) {
			// process the exception
			writeOutput( processException( application[ appKey ], e ) );
			// abort it, something went really wrong.
			abort;
		}

		// Check if fwreinit is sent, if sent, ignore it, we are loading the framework
		var reinitKey = application[ appKey ].getSetting( "reinitKey", "fwreinit" );
		if ( structKeyExists( url, reinitKey ) ) {
			structDelete( url, reinitKey );
		}

		return this;
	}

	/**
	 * Request Reload procedures
	 */
	function reloadChecks(){
		var appKey     = locateAppKey();
		var needReinit = isfwReinit();

		// Initialize the Controller If Needed, double locked
		if (
			NOT structKeyExists( application, appkey ) OR NOT application[ appKey ].getColdboxInitiated() OR needReinit
		) {
			lock type="exclusive" name="#appHash#" timeout="#lockTimeout#" throwontimeout="true" {
				// double lock
				if (
					NOT structKeyExists( application, appkey ) OR NOT application[ appKey ].getColdboxInitiated() OR needReinit
				) {
					try {
						// Tell the word we are reiniting
						application.fwReinit = true;
						// Verify if we are Reiniting?
						if (
							structKeyExists( application, appKey ) AND application[ appKey ].getColdboxInitiated() AND needReinit
						) {
							// Load Module CF Mappings so modules can unload properly
							application[ appKey ].getModuleService().loadMappings();
							// process preReinit interceptors
							application[ appKey ].getInterceptorService().announce( "preReinit" );
							// Shutdown the application services
							application[ appKey ].getLoaderService().processShutdown();
						}
						// Reload ColdBox
						loadColdBox();
						// Remove any context stragglers
						structDelete( request, "cb_requestContext" );
					} catch ( any e ) {
						rethrow;
					} finally {
						application.fwReinit = false;
					}
				}
			}
			// end lock
		}

		try {
			// Get Controller Reference
			var cbController = application[ appKey ];
			// WireBox Singleton AutoReload
			if ( cbController.getSetting( "Wirebox" ).singletonReload ) {
				lock type="exclusive" name="#appHash#" timeout="#lockTimeout#" throwontimeout="true" {
					cbController.getWireBox().clearSingletons();
				}
			}
			// Handler's Index Auto Reload
			if ( cbController.getSetting( "HandlersIndexAutoReload" ) ) {
				lock type="exclusive" name="#appHash#" timeout="#lockTimeout#" throwontimeout="true" {
					cbController.getHandlerService().registerHandlers();
				}
			}
		} catch ( Any e ) {
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
		lock type="readonly" name="#variables.appHash#" timeout="#variables.lockTimeout#" throwontimeout="true" {
			var cbController = application[ locateAppKey() ];
		}
		// Local references
		var interceptorService = cbController.getInterceptorService();
		var cacheBox           = cbController.getCacheBox();

		try {
			// set request time, for info purposes
			request.fwExecTime = getTickCount();
			// Load Module CF Mappings
			cbController.getModuleService().loadMappings();
			// Create Request Context & Capture Request
			var event = cbController.getRequestService().requestCapture();

			// ****** PRE PROCESS *******/
			interceptorService.announce( "preProcess" );
			if ( len( cbController.getSetting( "RequestStartHandler" ) ) ) {
				cbController.runEvent(
					event        : cbController.getSetting( "RequestStartHandler" ),
					prePostExempt: true
				);
			}

			// ****** EVENT CACHING CONTENT DELIVERY *******/
			var refResults  = {};
			var eCacheEntry = event.getEventCacheableEntry();

			// Verify if event caching item is in selected cache
			if ( eCacheEntry.keyExists( "cachekey" ) ) {
				// Get cache element.
				refResults.eventCaching = cacheBox.getCache( eCacheEntry.provider ).get( eCacheEntry.cacheKey );
			}

			// Verify if cached content existed.
			if ( !isNull( refresults.eventCaching ) ) {
				// check renderdata
				if ( refResults.eventCaching.renderData ) {
					refResults.eventCaching.controller = cbController;
					renderDataSetup( argumentCollection = refResults.eventCaching );
				}

				// Caching Header Identifier
				getPageContextResponse().setHeader( "x-coldbox-cache-response", "true" );

				// Stop Gap for upgrades, remove by 4.2
				if ( isNull( refResults.eventCaching.responseHeaders ) ) {
					refResults.eventCaching.responseHeaders = {};
				}
				// Response Headers that were cached
				refResults.eventCaching.responseHeaders.each( function( key, value ){
					event.setHTTPHeader( name = key, value = value );
				} );

				// Render Content as binary or just output
				if ( refResults.eventCaching.isBinary ) {
					cbController
						.getDataMarshaller()
						.renderContent(
							type     = "#refResults.eventCaching.contentType#",
							variable = "#refResults.eventCaching.renderedContent#"
						);
				} else {
					cbController
						.getDataMarshaller()
						.renderContent( type = "#refResults.eventCaching.contentType#", reset = true );
					writeOutput( refResults.eventCaching.renderedContent );
				}
			} else {
				// ****** EXECUTE MAIN EVENT *******/
				if ( NOT event.getIsNoExecution() ) {
					refResults.results = cbController.runEvent( defaultEvent = true );
				}
				// ****** RENDERING PROCEDURES *******/
				if ( not event.isNoRender() ) {
					var renderedContent = "";

					// pre layout
					interceptorService.announce( "preLayout" );

					// Check for Marshalling and data render
					var renderData = event.getRenderData();

					// Rendering/Marshalling of content
					if ( !structIsEmpty( renderData ) ) {
						renderedContent = cbController
							.getDataMarshaller()
							.marshallData( argumentCollection = renderData );
					}
					// Check if handler returned results
					else if ( !isNull( refResults.results ) ) {
						// If simple, just return it back, evaluates to HTML
						if ( isSimpleValue( refResults.results ) ) {
							renderedContent = refResults.results;
						}
						// ColdBox does native JSON if you return a complex object.
						else {
							renderedContent = serializeJSON( refResults.results, true );
							getPageContextResponse().setContentType( "application/json" );
						}
					}
					// Render Layout/View pair via set variable to eliminate whitespace
					else {
						renderedContent = cbcontroller
							.getRenderer()
							.renderLayout(
								module     = event.getCurrentLayoutModule(),
								viewModule = event.getCurrentViewModule()
							);
					}

					// ****** PRE-RENDER EVENTS *******/
					var interceptorData = { renderedContent : renderedContent };
					interceptorService.announce( "preRender", interceptorData );
					// replace back content in case of modification, strings passed by value
					renderedContent = interceptorData.renderedContent;

					// ****** EVENT CACHING *******/
					var eCacheEntry = event.getEventCacheableEntry();
					if (
						eCacheEntry.keyExists( "cacheKey" ) AND
						getPageContextResponse().getStatus() neq 500 AND
						(
							renderData.isEmpty()
							OR
							(
								renderData.keyExists( "statusCode" ) and
								renderdata.statusCode neq 500
							)
						)
					) {
						lock
							type                  ="exclusive"
							name                  ="#variables.appHash#.caching.#eCacheEntry.cacheKey#"
							timeout               ="#variables.lockTimeout#"
							throwontimeout        ="true" {
							// Try to discover the content type
							var defaultContentType= "text/html";
							// Discover from event caching first.
							if ( !structIsEmpty( renderData ) ) {
								defaultContentType = renderData.contentType;
							} else {
								// Else, ask the engine
								defaultContentType = getPageContextResponse().getContentType();
							}

							// prepare storage entry
							var cacheEntry = {
								renderedContent : renderedContent,
								renderData      : false,
								contentType     : defaultContentType,
								encoding        : "",
								statusCode      : "",
								statusText      : "",
								isBinary        : false,
								responseHeaders : event.getResponseHeaders()
							};

							// is this a render data entry? If So, append data
							if ( !structIsEmpty( renderData ) ) {
								cacheEntry.renderData = true;
								structAppend( cacheEntry, renderData, true );
							}

							// Cache it
							cacheBox
								.getCache( eCacheEntry.provider )
								.set(
									eCacheEntry.cacheKey,
									cacheEntry,
									eCacheEntry.timeout,
									eCacheEntry.lastAccessTimeout
								);
						}
					}
					// end event caching

					// Render Data? With stupid CF whitespace stuff.
					if ( !structIsEmpty( renderData ) ) {
						renderData.controller = cbController;
						renderDataSetup( argumentCollection = renderData );
						// Binary
						if ( renderData.isBinary ) {
							cbController
								.getDataMarshaller()
								.renderContent( type = "#renderData.contentType#", variable = "#renderedContent#" );
						}
						// Non Binary
						else {
							writeOutput( renderedContent );
						}
					} else {
						writeOutput( renderedContent );
					}

					// Post rendering event
					interceptorService.announce( "postRender" );
				}
				// end no render
			}
			// end normal rendering procedures

			// ****** POST PROCESS *******/
			if ( len( cbController.getSetting( "RequestEndHandler" ) ) ) {
				cbController.runEvent(
					event         = cbController.getSetting( "RequestEndHandler" ),
					prePostExempt = true
				);
			}
			interceptorService.announce( "postProcess" );

			// ****** FLASH AUTO-SAVE *******/
			if ( cbController.getSetting( "flash" ).autoSave ) {
				cbController
					.getRequestService()
					.getFlashScope()
					.saveFlash();
			}
		} catch ( Any e ) {
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
		var appKey = locateAppKey();

		// CF Parm Structures just in case
		param name="FORM" default="#structNew()#";
		param name="URL"  default="#structNew()#";

		// Check if app exists already in scope
		if ( not structKeyExists( application, appKey ) ) {
			return true;
		}

		// Verify the reinit key is passed
		var reinitKey = application[ appKey ].getSetting( "reinitKey", "fwreinit" );
		if ( structKeyExists( url, reinitKey ) or structKeyExists( form, reinitKey ) ) {
			// Check if we have a reinit password at hand.
			var reinitPass = application[ appKey ].getSetting( name = "reinitPassword", defaultValue = "" );

			// pass Checks
			if ( NOT len( reinitPass ) ) {
				return true;
			}

			// Get the incoming pass from form or url
			var incomingPass = "";
			if ( structKeyExists( form, reinitKey ) ) {
				incomingPass = form[ reinitKey ];
			} else {
				incomingPass = url[ reinitKey ];
			}

			// Compare the passwords
			if ( compare( reinitPass, hash( incomingPass ) ) eq 0 ) {
				return true;
			} else {
				application[ appKey ].getLog().warn( "The incoming reinit password is not valid." );
			}
		}
		// else if reinit found.

		return false;
	}

	/************************************** APP.CFC FACADES *********************************************/

	/**
	 * On request start
	 */
	boolean function onRequestStart( required targetPage ) output=true{
		// Global flag to denote if we are in mid reinit or not.
		cfparam( name = "application.fwReinit", default = false );

		// Fail fast so users coming in during a reinit just get a please try again message.
		if ( application.fwReinit ) {
			// Closure or UDF
			if ( isClosure( variables.COLDBOX_FAIL_FAST ) || isCustomFunction( variables.COLDBOX_FAIL_FAST ) ) {
				variables.COLDBOX_FAIL_FAST();
				return false;
			}
			// Core Fail Fast Option
			else if ( isBoolean( variables.COLDBOX_FAIL_FAST ) && variables.COLDBOX_FAIL_FAST ) {
				writeOutput( "Oops! Seems ColdBox is still not ready to serve requests, please try again." );
				// You don't have to return a 500, I just did this so JMeter would report it differently than a 200
				cfheader( statusCode = "503", statustext = "ColdBox Not Available Yet!" );
				// Break up!
				return false;
			}
		}

		// Verify Reloading
		reloadChecks();

		// Process A ColdBox Request Only
		if ( findNoCase( "index.cfm", listLast( arguments.targetPage, "/" ) ) ) {
			processColdBoxRequest();
		}
		return true;
	}

	/**
	 * ON missing template
	 */
	boolean function onMissingTemplate( required template ){
		// get reference
		lock type="readonly" name="#variables.appHash#" timeout="#variables.lockTimeout#" throwontimeout="true" {
			var cbController = application[ locateAppKey() ];
		}
		// Execute Missing Template Handler if it exists
		if ( len( cbController.getSetting( "MissingTemplateHandler" ) ) ) {
			// Save missing template in RC and right handler for this call.
			var event = cbController.getRequestService().getContext();
			event
				.setValue( "missingTemplate", arguments.template )
				.setValue(
					cbController.getSetting( "EventName" ),
					cbController.getSetting( "MissingTemplateHandler" )
				);
			// Process it
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
		lock type="readonly" name="#variables.appHash#" timeout="#variables.lockTimeout#" throwontimeout="true" {
			var cbController = application[ locateAppKey() ];
		}
		// Session start interceptors
		cbController.getInterceptorService().announce( "sessionStart", session );
		// Execute Session Start Handler
		if ( len( cbController.getSetting( "SessionStartHandler" ) ) ) {
			cbController.runEvent( event = cbController.getSetting( "SessionStartHandler" ), prePostExempt = true );
		}
	}

	/**
	 * ON session end
	 */
	function onSessionEnd( required struct sessionScope, struct appScope ){
		var cbController = "";

		// Get reference
		lock type="readonly" name="#variables.appHash#" timeout="#variables.lockTimeout#" throwontimeout="true" {
			// Check for cb Controller
			if ( structKeyExists( arguments.appScope, locateAppKey() ) ) {
				cbController = arguments.appScope.cbController;
			}
		}

		if ( not isSimpleValue( cbController ) ) {
			// Get Context
			var event = cbController.getRequestService().getContext();

			// Execute interceptors
			var iData = {
				sessionReference     : arguments.sessionScope,
				applicationReference : arguments.appScope
			};
			cbController.getInterceptorService().announce( "sessionEnd", iData );

			// Execute Session End Handler
			if ( len( cbController.getSetting( "SessionEndHandler" ) ) ) {
				// Place session reference on event object
				event
					.setValue( "sessionReference", arguments.sessionScope )
					.setValue( "applicationReference", arguments.appScope );
				// Execute the Handler
				cbController.runEvent(
					event         = cbController.getSetting( "SessionEndHandler" ),
					prepostExempt = true
				);
			}
		}
	}

	/**
	 * ON application start
	 */
	boolean function onApplicationStart(){
		// Load ColdBox
		loadColdBox();
		return true;
	}

	/**
	 * ON application end
	 */
	function onApplicationEnd( struct appScope ){
		var cbController = arguments.appScope[ locateAppKey() ];

		// Execute Application End interceptors
		cbController.getInterceptorService().announce( "applicationEnd" );
		// Execute Application End Handler
		if ( len( cbController.getSetting( "applicationEndHandler" ) ) ) {
			cbController.runEvent(
				event         = cbController.getSetting( "applicationEndHandler" ),
				prePostExempt = true
			);
		}

		// Controlled service shutdown operations
		cbController.getLoaderService().processShutdown();
	}

	/************************************** PRIVATE HELPERS *********************************************/

	/**
	 * Process an exception and returns a rendered bug report
	 * @controller The ColdBox Controller
	 * @exception The ColdFusion exception
	 */
	private string function processException( required controller, required exception ){
		// prepare exception facade object + app logger
		var oException = new coldbox.system.web.context.ExceptionBean( arguments.exception );
		var appLogger  = arguments.controller.getLogBox().getLogger( this );
		var event      = arguments.controller.getRequestService().getContext();
		var rc         = event.getCollection();
		var prc        = event.getPrivateCollection();

		// Announce interception
		arguments.controller.getInterceptorService().announce( "onException", { exception : arguments.exception } );

		// Store exception in private context
		event.setPrivateValue( "exception", oException );

		// Set Exception Header
		getPageContextResponse().setStatus( 500, "Internal Server Error" );

		// Run custom Exception handler if Found, else run default exception routines
		if ( len( arguments.controller.getSetting( "ExceptionHandler" ) ) ) {
			try {
				arguments.controller.runEvent( arguments.controller.getSetting( "Exceptionhandler" ) );
			} catch ( Any e ) {
				// Log Original Error First
				appLogger.error(
					"Original Error: #arguments.exception.message# #arguments.exception.detail# ",
					arguments.exception
				);
				// Log Exception Handler Error
				appLogger.error(
					"Error running exception handler: #arguments.controller.getSetting( "ExceptionHandler" )# #e.message# #e.detail#",
					e
				);
				// rethrow error
				rethrow;
			}
		} else {
			// Log Error
			appLogger.error(
				"Error: #arguments.exception.message# #arguments.exception.detail# ",
				arguments.exception
			);
		}

		// Render out error via CustomErrorTemplate or Core
		var customErrorTemplate = arguments.controller.getSetting( "CustomErrorTemplate" );
		if ( len( customErrorTemplate ) ) {
			// Get app location path
			var appLocation = "/";
			if ( len( arguments.controller.getSetting( "AppMapping" ) ) ) {
				appLocation = appLocation & arguments.controller.getSetting( "AppMapping" ) & "/";
			}
			var bugReportRelativePath = appLocation & reReplace( customErrorTemplate, "^/", "" );
			var bugReportAbsolutePath = customErrorTemplate;

			// Show Bug Report
			savecontent variable="local.exceptionReport" {
				// Do we have right path already, test by expanding
				if ( fileExists( expandPath( bugReportRelativePath ) ) ) {
					include "#bugReportRelativePath#";
				} else {
					include "#bugReportAbsolutePath#";
				}
			}
		} else {
			// Default ColdBox Error Template
			savecontent variable="local.exceptionReport" {
				include "/coldbox/system/exceptions/BugReport-Public.cfm";
			}
		}

		return local.exceptionReport;
	}

	/**
	 * Process render data setup
	 * @controller The ColdBox controller
	 * @statusCode The status code to send
	 * @statusText The status text to send
	 * @contentType The content type to send
	 * @encoding The content encoding
	 */
	private Bootstrap function renderDataSetup(
		required controller,
		required statusCode,
		required statusText,
		required contentType,
		required encoding
	){
		// Status Codes
		getPageContextResponse().setStatus( arguments.statusCode, arguments.statusText );
		// Render the Data Content Type
		controller
			.getDataMarshaller()
			.renderContent(
				type     = arguments.contentType,
				encoding = arguments.encoding,
				reset    = true
			);
		return this;
	}

	/**
	 * Locate the application key
	 */
	private function locateAppKey(){
		if ( len( trim( COLDBOX_APP_KEY ) ) ) {
			return COLDBOX_APP_KEY;
		}
		return "cbController";
	}

	/**
	 * Helper method to deal with ACF2016's overload of the page context response, come on Adobe, get your act together!
	 **/
	private function getPageContextResponse(){
		var response = getPageContext().getResponse();
		try {
			response.getStatus();
			return response;
		} catch ( any e ) {
			return response.getResponse();
		}
	}

}
