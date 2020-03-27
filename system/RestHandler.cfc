/**
 * ********************************************************************************
 * Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ********************************************************************************
 * Base RESTFul handler spice up as needed.
 * This handler will create a Response model and prepare it for your actions to use
 * to produce RESTFul responses.
 */
component extends="EventHandler" {

	// Global DI
	property name="cbpaginator" inject="Pagination@cbpaginator";

	// Pseudo "constants" used in API Response/Method parsing
	property name="METHODS";
	property name="STATUS";

	// Verb aliases - in case we are dealing with legacy browsers or servers ( e.g. IIS7 default )
	METHODS = {
		"HEAD"   : "HEAD",
		"GET"    : "GET",
		"POST"   : "POST",
		"PATCH"  : "PATCH",
		"PUT"    : "PUT",
		"DELETE" : "DELETE"
	};

	// HTTP STATUS CODES
	STATUS = {
		"CREATED"            : 201,
		"ACCEPTED"           : 202,
		"SUCCESS"            : 200,
		"NO_CONTENT"         : 204,
		"RESET"              : 205,
		"PARTIAL_CONTENT"    : 206,
		"BAD_REQUEST"        : 400,
		"NOT_AUTHORIZED"     : 403,
		"NOT_AUTHENTICATED"  : 401,
		"NOT_FOUND"          : 404,
		"NOT_ALLOWED"        : 405,
		"NOT_ACCEPTABLE"     : 406,
		"TOO_MANY_REQUESTS"  : 429,
		"EXPECTATION_FAILED" : 417,
		"INTERNAL_ERROR"     : 500,
		"NOT_IMPLEMENTED"    : 501
	};

	// OPTIONAL HANDLER PROPERTIES
	this.prehandler_only      = "";
	this.prehandler_except    = "";
	this.posthandler_only     = "";
	this.posthandler_except   = "";
	this.aroundHandler_only   = "";
	this.aroundHandler_except = "";

	// REST Allowed HTTP Methods Ex: this.allowedMethods = {delete='#METHODS.POST#,#METHODS.DELETE#',index='#METTHOD.GET#'}
	this.allowedMethods = {
		"index"  : METHODS.GET,
		"new"    : METHODS.GET,
		"get"    : METHODS.GET,
		"create" : METHODS.POST,
		"show"   : METHODS.GET,
		"list"   : METHODS.GET,
		"edit"   : METHODS.GET,
		"update" : METHODS.POST & "," & METHODS.PUT & "," & METHODS.PATCH,
		"delete" : METHODS.DELETE
	};

	/**
	 * Around handler for all actions it inherits
	 */
	function aroundHandler(
		event,
		rc,
		prc,
		targetAction,
		eventArguments
	){
		try {
			// start a resource timer
			var stime    = getTickCount();
			// prepare our response object
			prc.response = getModel( "Response@api" );
			// prepare argument execution
			var args     = {
				event : arguments.event,
				rc    : arguments.rc,
				prc   : arguments.prc
			};
			structAppend( args, arguments.eventArguments );
			// Incoming Format Detection
			if ( !isNull( rc.format ) ) {
				prc.response.setFormat( rc.format );
			}
			// Execute action
			var actionResults = arguments.targetAction( argumentCollection = args );
		}
		// Auth Issues
		catch ( "InvalidCredentials" e ) {
			this.onAuthenticationFailure( argumentCollection = arguments );
		}
		// Validation Exceptions
		catch ( "ValidationException" e ) {
			arguments.exception = e;
			this.onValidationException( argumentCollection = arguments );
		}
		// Entity Not Found Exceptions
		catch ( "EntityNotFound" e ) {
			arguments.exception = e;
			this.onEntityNotFoundException( argumentCollection = arguments );
		} catch ( Any e ) {
			// Log Locally
			log.error(
				"Error calling #event.getCurrentEvent()#: #e.message# #e.detail#",
				{
					"_stacktrace" : e.stacktrace,
					"httpData"    : getHTTPRequestData()
				}
			);
			// Setup General Error Response
			prc.response
				.setError( true )
				.addMessage( "General application error: #e.message#" )
				.setStatusCode( STATUS.INTERNAL_ERROR )
				.setStatusText( "General application error" );

			// Development additions
			if ( getSetting( "environment" ) eq "development" ) {
				prc.response
					.addMessage( "Detail: #e.detail#" )
					.addMessage( "StackTrace: #e.stacktrace#" );
			}
		}

		// Development additions
		if ( getSetting( "environment" ) eq "development" ) {
			prc.response
				.addHeader( "x-current-route", event.getCurrentRoute() )
				.addHeader( "x-current-routed-url", event.getCurrentRoutedURL() )
				.addHeader( "x-current-routed-namespace", event.getCurrentRoutedNamespace() )
				.addHeader( "x-current-event", event.getCurrentEvent() );
		}
		// end timer
		prc.response.setResponseTime( getTickCount() - stime );

		// Did the controllers set a view to be rendered? If not use renderdata, else just delegate to view.
		if (
			isNull( actionResults )
			AND
			!event.getCurrentView().len()
			AND
			event.getRenderData().isEmpty()
		) {
			// Get response data
			var responseData = prc.response.getDataPacket();
			// If we have an error flag, render our messages and omit any marshalled data
			if ( prc.response.getError() ) {
				responseData = prc.response.getDataPacket( reset = true );
			}
			// Magical renderings
			event.renderData(
				type            = prc.response.getFormat(),
				data            = responseData,
				contentType     = prc.response.getContentType(),
				statusCode      = prc.response.getStatusCode(),
				statusText      = prc.response.getStatusText(),
				location        = prc.response.getLocation(),
				isBinary        = prc.response.getBinary(),
				jsonCallback    = prc.response.getJsonCallback(),
				jsonQueryFormat = prc.response.getJsonQueryFormat()
			);
		}

		// Global Response Headers
		prc.response
			.addHeader( "x-response-time", prc.response.getResponseTime() )
			.addHeader( "x-cached-response", prc.response.getCachedResponse() );

		// Response Headers
		for ( var thisHeader in prc.response.getHeaders() ) {
			event.setHTTPHeader( name = thisHeader.name, value = thisHeader.value );
		}

		// If results detected, just return them, controllers requesting to return results
		if ( !isNull( actionResults ) ) {
			return actionResults;
		}
	}

	/**
	 * on localized errors
	 */
	function onError(
		event,
		rc,
		prc,
		faultAction,
		exception,
		eventArguments
	){
		// Log Locally
		log.error(
			"Error in base handler (#arguments.faultAction#): #arguments.exception.message# #arguments.exception.detail#",
			{
				"_stacktrace" : arguments.exception.stacktrace,
				"httpData"    : getHTTPRequestData()
			}
		);

		// Verify response exists, else create one
		if ( !structKeyExists( prc, "Response" ) ) {
			prc.response = getModel( "Response@api" );
		}

		// Setup General Error Response
		prc.response
			.setError( true )
			.addMessage( "Base Handler Application Error: #arguments.exception.message#" )
			.setStatusCode( STATUS.INTERNAL_ERROR )
			.setStatusText( "General application error" );

		// Development additions
		if ( getSetting( "environment" ) eq "development" ) {
			prc.response
				.addMessage( "Detail: #arguments.exception.detail#" )
				.addMessage( "StackTrace: #arguments.exception.stacktrace#" );
		}

		// If in development, then it will show full trace error template, else render data
		if ( getSetting( "environment" ) neq "development" ) {
			// Render Error Out
			event.renderData(
				type        = prc.response.getFormat(),
				data        = prc.response.getDataPacket( reset = true ),
				contentType = prc.response.getContentType(),
				statusCode  = prc.response.getStatusCode(),
				statusText  = prc.response.getStatusText(),
				location    = prc.response.getLocation(),
				isBinary    = prc.response.getBinary()
			);
		}
	}

	/**
	 * on validation errors via cbValidation
	 */
	function onValidationException(
		event,
		rc,
		prc,
		eventArguments,
		exception
	){
		// Log Locally
		if ( log.canDebug() ) {
			log.debug(
				"ValidationException Execution of (#arguments.event.getCurrentEvent()#)",
				arguments.exception.extendedInfo
			);
		}

		// Setup Response
		prc.response = getModel( "Response@api" )
			.setError( true )
			.setData( deserializeJSON( arguments.exception.extendedInfo ) )
			.addMessage( "Validation exceptions occurred, please see the data" )
			.setStatusCode( STATUS.BAD_REQUEST )
			.setStatusText( "Invalid Request" );

		// Render Error Out
		event.renderData(
			type        = prc.response.getFormat(),
			data        = prc.response.getDataPacket( reset = true ),
			contentType = prc.response.getContentType(),
			statusCode  = prc.response.getStatusCode(),
			statusText  = prc.response.getStatusText(),
			location    = prc.response.getLocation(),
			isBinary    = prc.response.getBinary()
		);
	}

	/**
	 * on entity not found exception
	 */
	function onEntityNotFoundException(
		event,
		rc,
		prc,
		eventArguments,
		exception
	){
		// Log Locally
		if ( log.canDebug() ) {
			log.debug(
				"Record not found in execution of (#arguments.event.getCurrentEvent()#)",
				arguments.exception.extendedInfo
			);
		}

		// Setup Response
		prc.response = getModel( "Response@api" )
			.setError( true )
			.setData( rc.id ?: "" )
			.addMessage( "The record you requested cannot be found in this system" )
			.setStatusCode( STATUS.NOT_FOUND )
			.setStatusText( "Not Found" );

		// Render Error Out
		event.renderData(
			type        = prc.response.getFormat(),
			data        = prc.response.getDataPacket( reset = true ),
			contentType = prc.response.getContentType(),
			statusCode  = prc.response.getStatusCode(),
			statusText  = prc.response.getStatusText(),
			location    = prc.response.getLocation(),
			isBinary    = prc.response.getBinary()
		);
	}

	/**
	 * on invalid http verbs
	 */
	function onInvalidHTTPMethod(
		event,
		rc,
		prc,
		faultAction,
		eventArguments
	){
		// Log Locally
		log.warn(
			"InvalidHTTPMethod Execution of (#arguments.faultAction#): #event.getHTTPMethod()#",
			getHTTPRequestData()
		);

		// Setup Response
		prc.response = getModel( "Response@api" )
			.setError( true )
			.addMessage( "InvalidHTTPMethod Execution of (#arguments.faultAction#): #event.getHTTPMethod()#" )
			.setStatusCode( STATUS.NOT_ALLOWED )
			.setStatusText( "Invalid HTTP Method" );

		// Render Error Out
		event.renderData(
			type        = prc.response.getFormat(),
			data        = prc.response.getDataPacket( reset = true ),
			contentType = prc.response.getContentType(),
			statusCode  = prc.response.getStatusCode(),
			statusText  = prc.response.getStatusText(),
			location    = prc.response.getLocation(),
			isBinary    = prc.response.getBinary()
		);
	}

	/**
	 * When missing actions are executed
	 */
	function onMissingAction(
		event,
		rc,
		prc,
		missingAction,
		eventArguments
	){
		// Setup Response
		prc.response = getModel( "Response@api" )
			.setError( true )
			.addMessage( "Action '#arguments.missingAction#' could not be found" )
			.setStatusCode( STATUS.NOT_ALLOWED )
			.setStatusText( "Invalid Action" );

		// Render Error Out
		event.renderData(
			type        = prc.response.getFormat(),
			data        = prc.response.getDataPacket( reset = true ),
			contentType = prc.response.getContentType(),
			statusCode  = prc.response.getStatusCode(),
			statusText  = prc.response.getStatusText(),
			location    = prc.response.getLocation(),
			isBinary    = prc.response.getBinary()
		);
	}

	/**
	 * Executed on authentication failures
	 */
	function onAuthenticationFailure(
		event = getRequestContext(),
		rc    = getRequestCollection(),
		prc   = getPrivateCollection(),
		abort = false
	){
		if ( !structKeyExists( prc, "Response" ) ) {
			prc.response = getModel( "Response@api" );
		}

		// case when the a jwt token was valid, but expired
		if (
			!isNull( prc.cbSecurity_validatorResults ) &&
			prc.cbSecurity_validatorResults.messages CONTAINS "expired"
		) {
			prc.response
				.setError( true )
				.setStatusCode( STATUS.NOT_AUTHENTICATED )
				.setStatusText( "Expired Authentication Credentials" )
				.addMessage( "Expired Authentication Credentials" );
			return;
		}

		prc.response
			.setError( true )
			.setStatusCode( STATUS.NOT_AUTHENTICATED )
			.setStatusText( "Invalid or Missing Credentials" )
			.addMessage( "Invalid or Missing Authentication Credentials" );
	}

	/**
	 * Executed on authorization failures
	 */
	function onAuthorizationFailure(
		event = getRequestContext(),
		rc    = getRequestCollection(),
		prc   = getPrivateCollection(),
		abort = false
	){
		if ( !structKeyExists( prc, "Response" ) ) {
			prc.response = getModel( "Response@api" );
		}

		prc.response
			.setError( true )
			.setStatusCode( STATUS.NOT_AUTHORIZED )
			.setStatusText( "Unauthorized Resource" )
			.addMessage( "Your permissions do not allow this operation" );

		// Check for validator results
		if ( !isNull( prc.cbSecurity_validatorResults ) ) {
			prc.response.addMessage( prc.cbSecurity_validatorResults.messages );
		}

		/**
		 * When you need a really hard stop to prevent further execution ( use as last resort )
		 */
		if ( arguments.abort ) {
			event.setHTTPHeader( name = "Content-Type", value = "application/json" );

			event.setHTTPHeader( statusCode = "#STATUS.NOT_AUTHORIZED#", statusText = "Not Authorized" );

			writeOutput( serializeJSON( prc.response.getDataPacket( reset = true ) ) );

			flush;
			abort;
		}
	}

	/**
	 * Resource Not Found
	 */
	function onInvalidRoute( event, rc, prc ){
		if ( !structKeyExists( prc, "Response" ) ) {
			prc.response = getModel( "Response@api" );
		}

		prc.response
			.setError( true )
			.setStatusCode( STATUS.NOT_FOUND )
			.setStatusText( "Not Found" )
			.addMessage( "The resource requested (#event.getCurrentRoutedURL()#) could not be found" );
	}

	/**************************** RESTFUL UTILITIES ************************/

	/**
	 * Utility method for when an expectation of the request failes ( e.g. an expected paramter is not provided )
	 */
	private function onExpectationFailed(
		event = getRequestContext(),
		rc    = getRequestCollection(),
		prc   = getRequestCollection( private = true )
	){
		if ( !structKeyExists( prc, "Response" ) ) {
			prc.response = getModel( "Response@api" );
		}

		prc.response
			.setError( true )
			.setStatusCode( STATUS.EXPECTATION_FAILED )
			.setStatusText( "Expectation Failed" )
			.addMessage( "An expectation for the request failed. Could not proceed" );
	}

}
