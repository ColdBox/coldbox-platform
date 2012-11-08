/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Description :
	This is the base component used to provide Application.cfc support.
*/
component serializable="false" accessors="true"{

	/************************************** CONSTRUCTOR *********************************************/

	// Global ColdBox properties
	property name="COLDBOX_CONFIG_FILE";
	property name="COLDBOX_APP_ROOT_PATH";
	property name="COLDBOX_APP_KEY";
	property name="COLDBOX_APP_MAPPING";
	// Lock Timeout
	property name="lockTimeout";
	property name="appHash";

	// param the propreties
	param name="COLDBOX_CONFIG_FILE" 	default="" type="string";
	param name="COLDBOX_APP_ROOT_PATH" 	default="#getDirectoryFromPath( getbaseTemplatePath() )#" type="string";
	param name="COLDBOX_APP_KEY" 		default="cbController" type="string";
	param name="COLDBOX_APP_MAPPING" 	default="" type="string";
	param name="lockTimeout"			default="30";
	param name="appHash"				default="#hash( getBaseTemplatePath() )#";

	function init(required COLDBOX_CONFIG_FILE, required COLDBOX_APP_ROOT_PATH, COLDBOX_APP_KEY, COLDBOX_APP_MAPPING=""){
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
	
	function loadColdBox(){
		var appKey = locateAppKey();
		// Cleanup of old code
		if( structkeyExists( application, appKey ) ){
			structDelete( application, appKey );
		}
		// Setup Lite Bit
		application.cblite = true;
		// Create Brand New Controller
		application[ appKey ] = CreateObject("component","coldbox.system.mvc.Controller").init( COLDBOX_APP_ROOT_PATH, appKey );
		// Setup the Framework And Application
		application[ appKey ].loadApplication( COLDBOX_CONFIG_FILE, COLDBOX_APP_MAPPING );
		// Application Start Handler
		if ( len( application[ appKey ].getSetting( "ApplicationStartHandler" ) ) ){
			application[ appKey ].runEvent( event=application[ appKey ].getSetting("ApplicationStartHandler"), prepostExempt=true );
		}
		
		return this;
	}
	
	function reloadChecks(){
		var exceptionService = "";
		var ExceptionBean 	= "";
		var appKey 			= locateAppKey();
		var cbController 	= 0;
		var needReinit 		= isfwReinit();

		// Initialize the Controller If Needed, double locked
		if( NOT structkeyExists( application, appkey ) OR NOT application[ appKey ].getColdboxInitiated() OR needReinit ){
			lock type="exclusive" name="#appHash#" timeout="#lockTimeout#" throwontimeout="true"{
				
				if( NOT structkeyExists( application, appkey ) OR NOT application[ appKey ].getColdboxInitiated() OR needReinit ){

					// Verify if we are Reiniting?
					if( structkeyExists(application,appKey) AND application[appKey].getColdboxInitiated() AND needReinit ){
						// Shutdown the application services
						application[ appKey ].processShutdown();
					}

					// Reload ColdBox
					loadColdBox();
					structDelete( request, "cb_requestContext" );
				}
				
			}
			return this;
		}

		try{
			// Get Controller Reference
			lock type="readonly" name="#appHash#" timeout="#lockTimeout#" throwontimeout="true"{
				cbController = application[ appKey ];
			}

			// WireBox Singleton AutoReload
			if( cbController.getSetting("Wirebox").singletonReload ){
				lock type="exclusive" name="#appHash#" timeout="#lockTimeout#" throwontimeout="true"{
					cbController.getWireBox().clearSingletons();
				}
			}
			// Handler's Index Auto Reload
			if( cbController.getSetting("HandlersIndexAutoReload") ){
				lock type="exclusive" name="#appHash#" timeout="#lockTimeout#" throwontimeout="true"{
					cbController.registerHandlers();
				}
			}

		}
		catch(Any e){
			// process the exception
			processException( cbController, e );
			// If we get here, no custom template was chosen, so just throw exception back
			rethrow;
		}
		
		return this;
	}

	function processColdBoxRequest() output="true"{
		var cbController 		= 0;
		var event 				= 0;
		var exceptionService 	= 0;
		var exceptionBean 		= 0;
		var renderedContent  	= "";
		var eventCacheEntry  	= 0;
		var renderData 	    	= structnew();
		var refResults 			= structnew();
		var debugPanel			= "";

		// Start Application Requests
		lock type="readonly" name="#appHash#" timeout="#lockTimeout#" throwontimeout="true"{
			cbController = application[ locateAppKey() ];
		}

		try{
			// set request time
			request.fwExecTime = getTickCount();

			// Create Request Context & Capture Request
			event = cbController.requestCapture();

			// IF Found in config, run onRequestStart Handler
			if( len( cbController.getSetting( "RequestStartHandler" ) ) ){
				cbController.runEvent( cbController.getSetting( "RequestStartHandler" ), true );
			}

			// Run Default/Set Event not executing an event
			if( NOT event.isNoExecution() ){
				refResults.results = cbController.runEvent( defaultEvent=true );
			}

			// No Render Test
			if( not event.isNoRender() ){
				
				// Check for Marshalling and data render
				renderData = event.getRenderData();

				// Rendering/Marshalling of content
				if( isStruct( renderData ) and not structisEmpty( renderData ) ){
					renderedContent = cbController.getDataMarshaller().marshallData(argumentCollection=renderData);
				}
				// Check for Event Handler return results
				else if( structKeyExists( refResults, "results" ) ){
					renderedContent = refResults.results;
				}
				else{
					// Render Layout/View pair via set variable to eliminate whitespace
					renderedContent = cbController.getRenderer().renderLayout();
				}

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

			}


			// If Found in config, run onRequestEnd Handler
			if( len( cbController.getSetting( "RequestEndHandler" ) ) ){
				cbController.runEvent(event=cbController.getSetting("RequestEndHandler"), prePostExempt=true);
			}

		}
		catch(Any e){
			// process the exception
			processException( cbController, e );
			// If we get here, no custom template was chosen, so just throw exception back
			rethrow;
		}

		// Time the request
		request.fwExecTime = getTickCount() - request.fwExecTime;

	}
	
	/************************************** APP.CFC FACADES *********************************************/
	
	boolean function onRequestStart(required targetPage) output=true{
		reloadChecks();
		// Process A ColdBox Request Only
		if( findNoCase('index.cfm', listLast( arguments.targetPage, '/' ) ) ){
			processColdBoxRequest();
		}
		return true;
	}

	boolean function onMissingTemplate(required template){
		var cbController = "";
		var event = "";
		var interceptData = structnew();

		lock type="readonly" name="#appHash#" timeout="#lockTimeout#" throwontimeout="true"{
			cbController = application[ locateAppKey() ];
		}
		//Execute Missing Template Handler if it exists
		if ( len(cbController.getSetting("MissingTemplateHandler")) ){
			// Save missing template in RC and right handler for this call.
			event = cbController.getContext();
			event.setValue( "missingTemplate", arguments.template );
			event.setValue( cbController.getSetting( "EventName" ), cbController.getSetting( "MissingTemplateHandler" ) );

			//Process it
			onRequestStart( "index.cfm" );

			// Return processed
			return true;
		}

		return false;
	}

	function onSessionStart(){
		var cbController = "";

		lock type="readonly" name="#getAppHash()#" timeout="#lockTimeout#" throwontimeout="true"{
			cbController = application[ locateAppKey() ];
		}
		//Execute Session Start Handler
		if( len( cbController.getSetting( "SessionStartHandler" ) ) ){
			cbController.runEvent( event=cbController.getSetting( "SessionStartHandler" ), prePostExempt=true);
		}
	}

	function onSessionEnd(required struct sessionScope, struct appScope){
		var cbController = "";
		var event = "";

		lock type="readonly" name="#getAppHash()#" timeout="#lockTimeout#" throwontimeout="true"{
			//Check for cb Controller
			if ( structKeyExists( arguments.appScope, locateAppKey() ) ){
				cbController = arguments.appScope.cbController;
			}
		}

		if ( not isSimpleValue( cbController ) ){
			// Get Context
			event = cbController.getContext();

			//Execute Session End Handler
			if ( len( cbController.getSetting("SessionEndHandler") ) ){
				//Place session reference on event object
				event.setValue( "sessionReference", arguments.sessionScope );
				//Place app reference on event object
				event.setValue( "applicationReference", arguments.appScope );
				//Execute the Handler
				cbController.runEvent( event=cbController.getSetting("SessionEndHandler"), prepostExempt=true );
			}
		}
	}

	boolean function onApplicationStart(){
		//Load ColdBox
		loadColdBox();
		return true;
	}

	function onApplicationEnd(struct appScope){
		var cbController = arguments.appScope[ locateAppKey() ];

		// Execute Application End Handler
		if( len( cbController.getSetting( 'applicationEndHandler' ) ) ){
			cbController.runEvent( event=cbController.getSetting( "applicationEndHandler" ) ,prePostExempt=true );
		}

		// Controlled service shutdown operations
		cbController.processShutdown();
	}

	/************************************** HELPERS *********************************************/
	
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
			}
			else{
				incomingPass = url.fwreinit;
			}

			// Compare the passwords
			if( compare( reinitPass, hash( incomingPass ) ) eq 0 ){
				return true;
			}
			
		}//else if reinit found.

		return false;
	}
	
	private function processException(required controller, required exception){
		//Run custom Exception handler if Found, else run default exception routines
		if ( len( arguments.controller.getSetting("ExceptionHandler") ) ){
			try{
				arguments.controller.getContext().setValue("exception", e);
				arguments.controller.runEvent( arguments.controller.getSetting("Exceptionhandler") );
			}
			catch(Any e){
				throw(message="Error running exception handler: #e.message#", detail="#e.detail# #e.stackTrace#", type="ExceptionHandlerKapoot");
			}
		}
		
		// Custom Error Template?
		var customErrorTemplate = arguments.controller.getSetting("CustomErrorTemplate");
		if( len( customErrorTemplate ) ){
			var appLocation = "/";
			if( len( arguments.controller.getSetting("AppMapping") ) ){
				appLocation = appLocation & arguments.controller.getSetting("AppMapping") & "/";
			}
			// Bug report path
			var bugReportTemplatePath = appLocation & reReplace( customErrorTemplate, "^/", "" );
			// Show Bug Report
			include "#bugReportTemplatePath#";
			abort;
		}
		
	}
	
	private function renderDataSetup(required controller, required statusCode, required statusText, required contentType, required encoding){ 
    	// Status Codes
		getPageContext().getResponse().setStatus( arguments.statusCode, arguments.statusText );
		// Render the Data Content Type
		controller.getDataMarshaller().renderContent(type=arguments.contentType, encoding=arguments.encoding, reset=true);
	}

	private function locateAppKey(){
		if( len( trim( COLDBOX_APP_KEY ) ) ){
			return COLDBOX_APP_KEY;
		}
		return "cbController";
	}
}