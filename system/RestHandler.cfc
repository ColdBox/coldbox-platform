/**
 * ********************************************************************************
 * Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ********************************************************************************
 * This specialized handler is to be used for Restful applications.
 * It wraps around functions to provide consistency and an opinionated approach to RESTing!
 */
component extends="EventHandler" {

	// Default REST Security for ColdBox Resources
	this.allowedMethods = {
		"index"  : "GET",
		"new"    : "GET",
		"get"    : "GET",
		"create" : "POST",
		"show"   : "GET",
		"list"   : "GET",
		"edit"   : "GET",
		"update" : "POST,PUT,PATCH",
		"delete" : "DELETE"
	};

	/**
	 * Our Rest handler adds a nice around handler that will be active for all handlers
	 * that leverage it.  So it can add uniformity, exception handling, tracking and more.
	 *
	 * @event The request context
	 * @rc The rc reference
	 * @prc The prc reference
	 * @targetAction The action UDF to execute
	 * @eventArguments The original event arguments
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
		catch ( "EntityNotFound,RecordNotFound" e ) {
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
	 * Implicit action that detects exceptions on your handlers and processes them
	 *
	 * @event The request context
	 * @rc The rc reference
	 * @prc The prc reference
	 * @faultAction The action that blew up
	 * @exception The thrown exception
	 * @eventArguments The original event arguments
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

		// Setup General Error Response
		arguments.event
			.getResponse()
				.setError( true )
				.addMessage( "Base Handler Application Error: #arguments.exception.message#" )
				.setStatusCode( arguments.event.STATUS.INTERNAL_ERROR )
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
	 * Action that can be used when validation exceptions ocur.  Can be called manually or automatically
	 * via thrown exceptions in the around handler
	 *
	 * @event The request context
	 * @rc The rc reference
	 * @prc The prc reference
	 * @eventArguments The original event arguments
	 * @exception The thrown exception
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
		arguments.event
			.getResponse()
				.setError( true )
				.setData( deserializeJSON( arguments.exception.extendedInfo ) )
				.addMessage( "Validation exceptions occurred, please see the data" )
				.setStatusCode( arguments.event.STATUS.BAD_REQUEST )
				.setStatusText( "Invalid Request" );

		// Render Error Out
		arguments.event.renderData(
			type        = arguments.prc.response.getFormat(),
			data        = arguments.prc.response.getDataPacket( reset = true ),
			contentType = arguments.prc.response.getContentType(),
			statusCode  = arguments.prc.response.getStatusCode(),
			statusText  = arguments.prc.response.getStatusText(),
			location    = arguments.prc.response.getLocation(),
			isBinary    = arguments.prc.response.getBinary()
		);
	}

	/**
	 * Action that can be used when an entity or record is not found. Can be called manually or automatically
	 * via thrown exceptions in the around handler
	 *
	 * @event The request context
	 * @rc The rc reference
	 * @prc The prc reference
	 * @eventArguments The original event arguments
	 * @exception The thrown exception
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
		arguments.event
			.getResponse()
				.setError( true )
				.setData( rc.id ?: "" )
				.addMessage( "The record you requested cannot be found in this system" )
				.setStatusCode( arguments.event.STATUS.NOT_FOUND )
				.setStatusText( "Not Found" );

		// Render Error Out
		arguments.event.renderData(
			type        = arguments.prc.response.getFormat(),
			data        = arguments.prc.response.getDataPacket( reset = true ),
			contentType = arguments.prc.response.getContentType(),
			statusCode  = arguments.prc.response.getStatusCode(),
			statusText  = arguments.prc.response.getStatusText(),
			location    = arguments.prc.response.getLocation(),
			isBinary    = arguments.prc.response.getBinary()
		);
	}

	/**
	 * Action used when the framework detects and Invalid HTTP method for the action
	 *
	 * @event The request context
	 * @rc The rc reference
	 * @prc The prc reference
	 * @faultAction The action that was secured
	 * @eventArguments The original event arguments
	 */
	function onInvalidHTTPMethod(
		event,
		rc,
		prc,
		faultAction,
		eventArguments
	){
		// Log it
		log.warn(
			"InvalidHTTPMethod Execution of (#arguments.faultAction#): #arguments.event.getHTTPMethod()#",
			getHTTPRequestData()
		);

		// Setup Response
		arguments.event
			.getResponse()
				.setError( true )
				.addMessage( "InvalidHTTPMethod Execution of (#arguments.faultAction#): #arguments.event.getHTTPMethod()#" )
				.setStatusCode( arguments.event.STATUS.NOT_ALLOWED )
				.setStatusText( "Invalid HTTP Method" );

		// Render Error Out
		arguments.event.renderData(
			type        = arguments.prc.response.getFormat(),
			data        = arguments.prc.response.getDataPacket( reset = true ),
			contentType = arguments.prc.response.getContentType(),
			statusCode  = arguments.prc.response.getStatusCode(),
			statusText  = arguments.prc.response.getStatusText(),
			location    = arguments.prc.response.getLocation(),
			isBinary    = arguments.prc.response.getBinary()
		);
	}

	/**
	 * Action used when the original action does not exist in a handler.
	 *
	 * @event The request context
	 * @rc The rc reference
	 * @prc The prc reference
	 * @missingAction The missing action
	 * @eventArguments The original event arguments
	 */
	function onMissingAction(
		event,
		rc,
		prc,
		missingAction,
		eventArguments
	){
		// Setup Response
		arguments.event
			.getResponse()
				.setError( true )
				.addMessage( "Action '#arguments.missingAction#' could not be found" )
				.setStatusCode( arguments.event.STATUS.NOT_ALLOWED )
				.setStatusText( "Invalid Action" );

		// Render Error Out
		arguments.event.renderData(
			type        = arguments.prc.response.getFormat(),
			data        = arguments.prc.response.getDataPacket( reset = true ),
			contentType = arguments.prc.response.getContentType(),
			statusCode  = arguments.prc.response.getStatusCode(),
			statusText  = arguments.prc.response.getStatusText(),
			location    = arguments.prc.response.getLocation(),
			isBinary    = arguments.prc.response.getBinary()
		);
	}

	/**
	 * Action that can be used for authentication failures. You can point to this action from cbsecurity, cbauth, etc or
	 * call it a-la-carte.
	 *
	 * It also monitors cbsecurity convention of validator results for setting error messages into the data packet
	 *
	 * @event The request context
	 * @rc The rc reference
	 * @prc The prc reference
	 *
	 * @return 403
	 */
	function onAuthenticationFailure(
		event = getRequestContext(),
		rc    = getRequestCollection(),
		prc   = getRequestCollection( private = true ),
		abort = false
	){
		// case when the a jwt token was valid, but expired
		if (
			!isNull( arguments.prc.cbSecurity_validatorResults ) &&
			arguments.prc.cbSecurity_validatorResults.messages CONTAINS "expired"
		) {
			arguments.event
				.getResponse()
					.setError( true )
					.setStatusCode( arguments.event.STATUS.NOT_AUTHENTICATED )
					.setStatusText( "Expired Authentication Credentials" )
					.addMessage( "Expired Authentication Credentials" );
			return;
		}

		arguments.event
			.getResponse()
				.setError( true )
				.setStatusCode( arguments.event.STATUS.NOT_AUTHENTICATED )
				.setStatusText( "Invalid or Missing Credentials" )
				.addMessage( "Invalid or Missing Authentication Credentials" );
	}

	/**
	 * Action that can be used for authorization failures. You can point to this action from cbsecurity, cbauth, etc or
	 * call it a-la-carte.
	 *
	 * It will check for cbsecurity validation results and set the appropriate error messages
	 *
	 * @event The request context
	 * @rc The rc reference
	 * @prc The prc reference
	 * @abort Hard abort the request if passed, defaults to false
	 */
	function onAuthorizationFailure(
		event = getRequestContext(),
		rc    = getRequestCollection(),
		prc   = getRequestCollection( private = true ),
		abort = false
	){
		arguments.event
			.getResponse()
				.setError( true )
				.setStatusCode( arguments.event.STATUS.NOT_AUTHORIZED )
				.setStatusText( "Unauthorized Resource" )
				.addMessage( "You are not allowed to access this resource" );

		// Check for validator results
		if ( !isNull( arguments.prc.cbSecurity_validatorResults ) ) {
			arguments.prc.response.addMessage( arguments.prc.cbSecurity_validatorResults.messages );
		}

		/**
		 * When you need a really hard stop to prevent further execution ( use as last resort )
		 */
		if ( arguments.abort ) {
			event.setHTTPHeader( name = "Content-Type", value = "application/json" );
			event.setHTTPHeader( statusCode = "#arguments.event.STATUS.NOT_AUTHORIZED#", statusText = "Not Authorized" );

			writeOutput( serializeJSON( prc.response.getDataPacket( reset = true ) ) );

			flush;
			abort;
		}
	}

	/**
	 * Action for when a route is invalid or not found. Usually you use this in your router
	 * as a catch all.
	 *
	 * <pre>
	 * // Catch All Resource
	 * route( "/:anything" ).to( "MyHandler.onInvalidRoute" );
	 * </pre>
	 *
	 * @event The request context
	 * @rc The rc reference
	 * @prc The prc reference
	 *
	 * @returns 404:Not Found
	 */
	function onInvalidRoute( event, rc, prc ){
		arguments.event
			.getResponse()
				.setError( true )
				.setStatusCode( arguments.event.STATUS.NOT_FOUND )
				.setStatusText( "Not Found" )
				.addMessage( "The resource requested (#event.getCurrentRoutedURL()#) could not be found" );
	}

	/**************************** RESTFUL UTILITIES ************************/

	/**
	 * Utility method for when an expectation of the request fails ( e.g. an expected parameter is not provided )
	 * - It will output a 417 status code (event.STATUS.EXPECTATION_FAILED)
	 * - Add the error flag
	 * - Add an failure message to the data packet which you can customize
	 *
	 * @event The request context
	 * @rc The rc reference
	 * @prc The prc reference
	 * @message The failure message sent in the request packge
	 *
	 * @returns 417:Expectation Failed
	 */
	private function onExpectationFailed(
		event = getRequestContext(),
		rc    = getRequestCollection(),
		prc   = getRequestCollection( private=true ),
		message = "An expectation for the request failed. Could not proceed"
	){
		arguments.event
			.getResponse()
				.setError( true )
				.setStatusCode( arguments.event.STATUS.EXPECTATION_FAILED )
				.setStatusText( "Expectation Failed" )
				.addMessage( arguments.message );
	}

}
