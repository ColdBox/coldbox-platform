/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This service is in charge of URL routing in ColdBox
 */
component extends="coldbox.system.web.services.BaseService" accessors="true" {

	/**
	 * A ColdBox Router this routing service configures with.
	 *
	 * @doc_generic coldbox.system.web.routing.Router
	 */
	property name="router";

	/**
	 * Constructor
	 */
	function init( required controller ){
		setController( arguments.controller );

		variables.RESERVED_PATTERNS = [ "handler", "action" ];

		return this;
	}

	/**
	 * Once configuration loads prepare for operation
	 */
	function onConfigurationLoad(){
		// Prepare references for faster access
		variables.log                          = variables.controller.getLogBox().getLogger( this );
		variables.handlersPath                 = controller.getSetting( "HandlersPath" );
		variables.handlersExternalLocationPath = controller.getSetting( "HandlersExternalLocationPath" );
		variables.modules                      = controller.getSetting( "Modules" );
		variables.eventName                    = controller.getSetting( "EventName" );
		variables.defaultEvent                 = controller.getSetting( "DefaultEvent" );
		variables.requestService               = controller.getRequestService();
		variables.wirebox                      = controller.getWireBox();

		// Routing AppMapping Determinations
		variables.appMapping        = controller.getSetting( "AppMapping" );
		variables.routingAppMapping = ( len( variables.appMapping ) ? variables.appMapping & "/" : "" );
		// Make sure it's prefixed with /
		variables.routingAppMapping = left( variables.routingAppMapping, 1 ) == "/" ? variables.routingAppMapping : "/#variables.routingAppMapping#";

		// Store routing appmapping
		controller.setSetting( "routingAppMapping", variables.routingAppMapping );

		// Register as an interceptor to listen to pre processes for routing
		variables.controller.getInterceptorService().registerInterceptor( interceptorObject = this );

		// Load the Application Router
		loadRouter();
	}

	/****************************************************************************************************************************/
	/*												COMPATIBILIITY SHIM															*/
	/****************************************************************************************************************************/

	/**
	 * Passthrough for legacy support of calling Router methods.  This will be removed in future versions.
	 */
	function onMissingMethod( missingMethodName, missingMethodArguments = {} ){
		return invoke(
			variables.router,
			arguments.missingMethodName,
			arguments.missingMethodArguments
		);
	}

	/****************************************************************************************************************************/
	/*												LOAD ROUTER		 															*/
	/****************************************************************************************************************************/

	/**
	 * Load a ColdBox Router CFC or a legacy router CFM template.
	 */
	private function loadRouter(){
		// Declare types of routers to discover
		var legacyRouter = "config/Routes.cfm"; // TODO: Decpreated, remove by ColdBox 7
		var modernRouter = "config.Router";
		var baseRouter   = "coldbox.system.web.routing.Router";

		// Modern Router?
		var configFilePath = variables.routingAppMapping & modernRouter.replace( ".", "/", "all" ) & ".cfc";
		var routerType     = "modern";
		if ( !fileExists( expandPath( configFilePath ) ) ) {
			// Legacy Router?
			configFilePath = variables.routingAppMapping & legacyRouter;
			routerType     = "legacy";
			if ( !fileExists( expandPath( configFilePath ) ) ) {
				// Base Router?
				routerType = "base";
			}
		}

		// Check if base router mapped?
		if ( NOT wirebox.getBinder().mappingExists( baseRouter ) ) {
			// feed the base class
			wirebox.registerNewInstance( name = baseRouter, instancePath = baseRouter );
		}

		// Load Router
		switch ( routerType ) {
			case "modern": {
				// Log it
				variables.log.info( "Loading Modern Router at: #modernRouter#" );
				var modernRouterPath = (
					variables.appMapping.len() ? "#variables.appMapping#.#modernRouter#" : modernRouter
				);
				// Process as a Router.cfc with virtual inheritance
				wirebox
					.registerNewInstance( name = "router@coldbox", instancePath = modernRouterPath )
					.setVirtualInheritance( baseRouter )
					.setThreadSafe( true )
					.setScope( wirebox.getBinder().SCOPES.SINGLETON )
					.addDIConstructorArgument( name = "controller", value = controller );
				// Create the Router
				variables.router = wirebox.getInstance( "router@coldbox" );
				// Register the Router as an Interceptor as well.
				variables.controller
					.getInterceptorService()
					.registerInterceptor( interceptorObject = variables.router );
				// Process it
				variables.router.configure();
				break;
			}
			case "legacy": {
				// Log it
				variables.log.info( "Loading Legacy Router at: #legacyRouter#" );
				// Register basic router
				wirebox
					.registerNewInstance( name = "router@coldbox", instancePath = baseRouter )
					.setScope( wirebox.getBinder().SCOPES.SINGLETON );
				// Process legacy Routes.cfm. Create a basic Router
				variables.router = wirebox
					.getInstance( "router@coldbox" )
					// Load up legacy template
					.includeRoutes( configFilePath );
				break;
			}
			default: {
				// Log it
				variables.log.info( "Loading Base ColdBox Router" );
				// Register basic router with default routing
				wirebox
					.registerNewInstance( name = "router@coldbox", instancePath = baseRouter )
					.setScope( wirebox.getBinder().SCOPES.SINGLETON );
				variables.router = wirebox
					.getInstance( "router@coldbox" )
					.addRoute( pattern = "/:handler/:action?" );
			}
		}

		// Startup the Router for operation
		variables.router.startup();

		return this;
	}

	/**
	 * This is the route dispatcher called upon the request is captured.
	 *
	 * @event The ColdBox Request context
	 */
	public void function requestCapture( required event ){
		var rc  = event.getCollection();
		var prc = event.getPrivateCollection();

		// Clean incoming paths
		var cleanedPaths = getCleanedPaths( rc, arguments.event );

		// Check if disabled or in proxy mode, if it is, then exit out.
		if ( !variables.router.getEnabled() OR arguments.event.isProxyRequest() ) {
			return;
		}

		// Activate and record the incoming URL for multi-domain hosting ONLY
		if ( variables.router.getMultiDomainDiscovery() ) {
			arguments.event.setSESBaseURL( variables.router.composeRoutingUrl() );
		}

		// Check for invalid URLs if in strict mode via unique URLs
		if ( variables.router.getUniqueURLs() ) {
			checkForInvalidURL(
				cleanedPaths[ "pathInfo" ],
				cleanedPaths[ "scriptName" ],
				arguments.event
			);
		}

		// Extension detection if enabled, so we can do cool extension formats
		if ( variables.router.getExtensionDetection() ) {
			cleanedPaths[ "pathInfo" ] = detectExtension( cleanedPaths[ "pathInfo" ], arguments.event );
		}

		// Find a route to dispatch
		var routeResults = findRoute(
			action = cleanedPaths[ "pathInfo" ],
			event  = arguments.event,
			domain = cleanedPaths[ "domain" ]
		);

		// Process the route
		var discoveredEvent = processRoute( routeResults, event, rc, prc );

		// Do we use the discovered event?
		if ( !isNull( local.discoveredEvent ) and discoveredEvent.len() ) {
			rc[ variables.eventName ] = discoveredEvent;
		}
	}

	/**
	 * Process a route result to be used by the request
	 *
	 * @routeResults The route results a <code>findRoute()</code> method returns
	 * @event        The ColdBox Request context
	 * @rc           The requset collection
	 * @prc          The private request collection
	 *
	 * @return An event string that can be used for execution. Empty if using something else
	 */
	function processRoute(
		required struct routeResults,
		required event,
		required rc,
		required prc
	){
		var httpMethod      = arguments.event.getHttpMethod();
		var discoveredEvent = "";

		// Check if we found a route, else most likely it is the default event
		if ( routeResults.route.isEmpty() ) {
			return;
		}

		// Process :handler :action pattern params by convention
		if ( routeresults.params.count() ) {
			variables.RESERVED_PATTERNS.each( function( item ){
				if ( routeResults.params.keyExists( item ) ) {
					routeResults.route[ item ] = routeResults.params[ item ];
					structDelete( routeResults.params, item );
				}
			} );
		}

		// Now route should have all the key/pairs from the URL we need to pass to our event object for processing
		rc.append( routeResults.params, true );
		// Incorporate RC variables without overrides
		rc.append( routeResults.route.rc, false );
		// Incorporate PRC variables without overrides
		prc.append( routeResults.route.prc, false );

		/****************** Start Processing Route ******************/

		// Process Redirects
		if (
			isClosure( routeResults.route.redirect ) ||
			isCustomFunction( routeResults.route.redirect ) ||
			routeResults.route.redirect.len()
		) {
			// Debugging
			return processRedirect( routeResults, event );
		}

		// Process SSL Redirects
		if ( routeResults.route.ssl AND NOT event.isSSL() ) {
			controller.relocate(
				URL         = event.getSESBaseURL() & reReplace( CGI.PATH_INFO, "^\/", "" ),
				ssl         = true,
				statusCode  = 302,
				queryString = CGI.QUERY_STRING
			);
			return;
		}

		// Process Direct Event
		if ( routeResults.route.event.len() ) {
			discoveredEvent = routeResults.route.event;
			// Do we have a module? If so, prefix it
			if ( routeResults.route.module.len() ) {
				discoveredEvent = routeResults.route.module & ":" & discoveredEvent;
			}
			// Process HTTP Verbs
			if (
				routeResults.route.verbs.len()
				and
				!routeResults.route.verbs.listFindNoCase( httpMethod )
			) {
				// Mark as invalid HTTP Exception
				arguments.event.setIsInvalidHTTPMethod( true );
				if ( variables.log.canDebug() ) {
					variables.log.debug( "Invalid HTTP Method detected: #httpMethod#", routeResults.route );
				}
			}
		}

		// Process Handler/Actions
		if ( routeResults.route.handler.len() ) {
			// Create routed event
			discoveredEvent = routeResults.route.handler;
			// Do we have a module? If so, prefix it
			if ( routeResults.route.module.len() ) {
				discoveredEvent = routeResults.route.module & ":" & discoveredEvent;
			}
		}

		// Process HTTP Verbs
		if (
			routeResults.route.verbs.len()
			and
			!routeResults.route.verbs.listFindNoCase( httpMethod )
		) {
			// Mark as invalid HTTP Exception
			arguments.event.setIsInvalidHTTPMethod( true );
			if ( variables.log.canDebug() ) {
				variables.log.debug( "Invalid HTTP Method detected: #httpMethod#", routeResults.route );
			}
		}

		// If the struct is empty, reset it to an empty string so it goes down the correct code path later on.
		if ( isStruct( routeResults.route.action ) && structIsEmpty( routeResults.route.action ) ) {
			routeResults.route.action = "";
		}

		// Check if using HTTP method actions via struct
		if ( isStruct( routeResults.route.action ) ) {
			// Verify HTTP method used is valid
			if ( structKeyExists( routeResults.route.action, httpMethod ) ) {
				discoveredEvent &= ( discoveredEvent == "" ? "" : "." ) & "#routeResults.route.action[ httpMethod ]#";
				// Send for logging in debug mode
				if ( variables.log.canDebug() ) {
					variables.log.debug(
						"Matched HTTP Method (#HTTPMethod#) to routed action: #routeResults.route.action[ httpMethod ]#"
					);
				}
			} else {
				// Mark as invalid HTTP Exception
				discoveredEvent &= ".onInvalidHTTPMethod";
				arguments.event.setIsInvalidHTTPMethod( true );
				if ( variables.log.canDebug() ) {
					variables.log.debug( "Invalid HTTP Method detected: #httpMethod#", routeResults.route );
				}
			}
		}
		// Simple value action
		else if ( !isStruct( routeREsults.route.action ) && routeResults.route.action.len() ) {
			discoveredEvent &= ( discoveredEvent == "" ? "" : "." ) & "#routeResults.route.action#";
		}
		// end if action exists

		// See if View is Dispatched
		if ( routeResults.route.view.len() ) {
			// Dispatch the View
			arguments.event
				.setView(
					view     = routeResults.route.view,
					noLayout = routeResults.route.viewNoLayout,
					module   = routeResults.route.viewModule
				)
				.noExecution();

			// Layout?
			if ( routeResults.route.layout.len() ) {
				arguments.event.setLayout(
					name   = routeResults.route.layout,
					module = routeResults.route.layoutModule
				);
			}
		}

		// Process Response Headers
		routeResults.route.headers.each( function( key, value ){
			event.setHTTPHeader( name = key, value = value );
		} );

		// See if Response is dispatched
		if (
			isClosure( routeResults.route.response ) || isCustomFunction( routeResults.route.response ) || routeResults.route.response.len()
		) {
			renderResponse( routeResults.route, arguments.event );
		}

		// Save the Routed Variables so event caching can verify them
		arguments.event.setRoutedStruct( routeResults.params );

		return discoveredEvent;
	}

	/****************************************************************************************************************************/
	/* 											ROUTE DISPATCHING METHODS														*/
	/****************************************************************************************************************************/

	/**
	 * Figures out which route matches this request and returns a routed structure containing
	 * the `route` it discovered or an empty structure and the `params` structure which represents
	 * URL placeholders, convention name value pairs, matching variables, etc.
	 *
	 * @action    The action evaluated by path_info
	 * @event     The event object
	 * @module    Incoming module
	 * @namespace Incoming namespace
	 * @domain    Incoming domain
	 * @result    Struct: { route: found route or empty struct, params: translated params }
	 */
	struct function findRoute(
		required action,
		required event,
		module    = "",
		namespace = "",
		domain    = ""
	){
		var requestString = arguments.action;
		var rc            = event.getCollection();
		var results       = { "route" : {}, "params" : {} };

		// Start with global routes
		var _routes = variables.router.getRoutes();
		// Module call? Switch routes
		if ( len( arguments.module ) ) {
			_routes       = variables.router.getModuleRoutes( arguments.module );
			_routesLength = _routes.len();
		}
		// Namespace Call? Switch routes
		if ( len( arguments.namespace ) ) {
			_routes = variables.router.getNamespaceRoutes( arguments.namespace );
		}

		// Process routing length
		var _routesLength = _routes.len();

		// Remove the leading slash
		if ( len( requestString ) GT 1 AND left( requestString, 1 ) eq "/" ) {
			requestString = right( requestString, len( requestString ) - 1 );
		}
		// Add ending slash
		if ( right( requestString, 1 ) IS NOT "/" ) {
			requestString = requestString & "/";
		}

		// Let's Find a Route, Loop over all the routes array
		for ( var i = 1; i lte _routesLength; i++ ) {
			// Match The route to request String
			var match = reFindNoCase(
				_routes[ i ].regexPattern,
				requestString,
				1,
				true
			);
			if (
				( match.len[ 1 ] IS NOT 0 AND variables.router.getLooseMatching() )
				OR
				( NOT variables.router.getLooseMatching() AND match.len[ 1 ] IS NOT 0 AND match.pos[ 1 ] EQ 1 )
			) {
				// Verify condition matching
				if (
					( isClosure( _routes[ i ].condition ) || isCustomFunction( _routes[ i ].condition ) )
					AND NOT _routes[ i ].condition( requestString )
				) {
					// Debug logging
					if ( variables.log.canDebug() ) {
						variables.log.debug(
							"SES Route matched but condition closure did not pass: #_routes[ i ].toString()# on routed string: #requestString#"
						);
					}
					// Condition did not pass, move to next route
					continue;
				}

				// Verify domain if exists
				if ( _routes[ i ].domain.len() ) {
					var domainMatch = reFindNoCase(
						_routes[ i ].regexDomain,
						arguments.domain,
						1,
						true
					);
					if ( domainMatch.len[ 1 ] == 0 ) {
						continue;
					}
				}

				// Setup the found Route: we dup to avoid reference collisions
				results.route = duplicate( _routes[ i ] );

				// Is this namespace routing?
				if ( len( arguments.namespace ) ) {
					arguments.event.setPrivateValue( "currentRoutedNamespace", arguments.namespace );
				}

				// Debug logging
				if ( variables.log.canDebug() ) {
					variables.log.debug(
						"Route matched: #results.route.toString()# on routed string: #requestString#"
					);
				}

				break;
			}
		}
		// end finding routes

		// Check if we found a route, else just return empty params struct
		if ( results.route.isEmpty() ) {
			if ( variables.log.canDebug() ) {
				variables.log.debug( "No URL routes matched on routed string: #requestString#" );
			}
			return results;
		}

		// Check if the match is a module Routing entry point or a namespace entry point or not?
		if ( len( results.route.moduleRouting ) OR len( results.route.namespaceRouting ) ) {
			// build routing argument struct based on module/namespace context
			var contextRouting = {
				action : reReplaceNoCase( requestString, results.route.regexpattern, "" ),
				event  : arguments.event
			};
			// add module or namespace
			if ( len( results.route.moduleRouting ) ) {
				contextRouting.module = results.route.moduleRouting;
			} else {
				contextRouting.namespace = results.route.namespaceRouting;
			}

			// Try to Populate the params from the module pattern if any
			results.route.patternParams.each( function( item, index ){
				results.params[ item ] = mid(
					requestString,
					match.pos[ index + 1 ],
					match.len[ index + 1 ]
				);
			} );

			// Save Found URL
			arguments.event.setPrivateValue( "currentRoutedURL", requestString );

			// process context discovery of incoming pattern
			var contextRoute = findRoute( argumentCollection = contextRouting );

			// Return if route Not found.
			if ( !contextRoute.route.isEmpty() ) {
				return contextRoute;
			}
		}

		// Save current routed details in PRC
		arguments.event
			.setPrivateValue( "currentRouteRecord", results.route )
			.setPrivateValue( "currentRoute", results.route.pattern )
			.setPrivateValue( "currentRouteName", results.route.name )
			.setPrivateValue( "currentRoutedModule", results.route.module )
			.setPrivateValue( "currentRouteMeta", results.route.meta );

		// Save Found URL if NOT Found already
		if ( NOT arguments.event.privateValueExists( "currentRoutedURL" ) ) {
			arguments.event.setPrivateValue( "currentRoutedURL", requestString );
		}

		// Do we need to do package resolving
		if ( NOT results.route.packageResolverExempt ) {
			// Resolve the packages
			var packagedRequestString = packageResolver(
				requestString,
				results.route.patternParams,
				arguments.module
			);
			// reset pattern matching, if packages found.
			if ( compare( packagedRequestString, requestString ) NEQ 0 ) {
				// Log package resolved
				if ( variables.log.canDebug() ) {
					variables.log.debug( "URL Routing Package Resolved: #packagedRequestString#" );
				}
				// Return found Route recursively.
				return findRoute(
					action = packagedRequestString,
					event  = arguments.event,
					module = arguments.module
				);
			}
		}

		// Populate the params, with variables found in the request string
		results.route.patternParams.each( function( item, index ){
			results.params[ item ] = mid(
				requestString,
				match.pos[ index + 1 ],
				match.len[ index + 1 ]
			);
		} );

		// Populate the params, with variables found in the domain string
		results.route.domainParams.each( function( item, index ){
			results.params[ item ] = listGetAt( domain, index, "." );
		} );

		// Process Convention Name-Value Pairs into discovered params
		if ( results.route.valuePairTranslation ) {
			findConventionNameValuePairs( requestString, match, results.params );
		}

		// Process legacy match-variables to incorporate to discovered params
		results.route.matchVariables
			.listToArray()
			.each( function( item ){
				// Only set if not incoming.
				if ( !results.params.keyExists( item.getToken( 1, "=" ) ) ) {
					results.params[ item.getToken( 1, "=" ) ] = item.getToken( 2, "=" );
				}
			} );

		return results;
	}

	/**
	 * The cgi element facade method, created so we can do useful mocking
	 *
	 * @cgiElement The element to take from CGI
	 * @event      The request context object
	 *
	 * @return The cgi element value
	 */
	function getCgiElement( required cgiElement, required event ){
		// Allow a UDF to manipulate the CGI.PATH_INFO value
		// in advance of route detection.
		if ( arguments.cgiElement EQ "path_info" AND structKeyExists( variables.router, "PathInfoProvider" ) ) {
			return variables.router.pathInfoProvider( event = arguments.event );
		}
		return CGI[ arguments.CGIElement ];
	}

	/****************************************** PRIVATE ************************************************/

	/**
	 * Process a route redirection
	 *
	 * @routeResults The { params, route } that matched
	 * @event        The request context
	 */
	private function processRedirect( required routeResults, required event ){
		var redirectTo = "";

		// Determine closure or string relocation string
		if (
			isClosure( arguments.routeResults.route.redirect ) || isCustomFunction(
				arguments.routeResults.route.redirect
			)
		) {
			redirectTo = routeResults.route.redirect(
				arguments.routeResults.route,
				arguments.routeResults.params,
				arguments.event
			);
		} else {
			redirectTo = routeResults.route.redirect;
		}

		// Absolute or relative relocation
		if ( redirectTo.findNoCase( "http" ) ) {
			variables.controller.relocate(
				URL       : redirectTo,
				statusCode: (
					arguments.routeResults.route.keyExists( "statusCode" ) ? arguments.routeResults.route.statusCode : 301
				)
			);
		} else {
			variables.controller.relocate(
				event     : redirectTo,
				statusCode: (
					arguments.routeResults.route.keyExists( "statusCode" ) ? arguments.routeResults.route.statusCode : 301
				)
			);
		}

		return;
	}

	/**
	 * Detect extensions from the incoming request
	 *
	 * @requestString The incoming request string
	 * @event         The event object
	 */
	private function detectExtension( required requestString, required event ){
		var extension    = listLast( arguments.requestString, "." );
		var extensionLen = len( extension );

		// cleanup of extension, just in case rewrites add garbage.
		extension = lCase( reReplace( extension, "/$", "", "all" ) );

		// check if extension found
		if ( listLen( arguments.requestString, "." ) GT 1 AND len( extension ) AND NOT find( "/", extension ) ) {
			// Check if extension is valid?
			if ( variables.router.isValidExtension( extension ) ) {
				// set the format request collection variable
				event.setValue( "format", extension );
				// debug logging
				if ( variables.log.canDebug() ) {
					variables.log.debug( "Extension: #extension# detected and set in rc.format" );
				}
				// remove it from the string and return string for continued parsing.
				return left( requestString, len( arguments.requestString ) - extensionLen - 1 );
			} else if ( variables.router.getThrowOnInvalidExtension() ) {
				event.setHTTPHeader(
					statusText = "Invalid Requested Format Extension: #extension#",
					statusCode = 406
				);
				throw(
					message = "Invalid requested format extendion: #extension#",
					detail  = "Invalid Request Format Extension Detected: #extension#. Valid extensions are: #variables.router.getValidExtensions()#",
					type    = "InvalidRequestedFormatExtension"
				);
			}
		}
		// check accepts headers for the best match
		else {
			// Process Accept Headers
			var acceptHeader = event.getHTTPHeader( "Accept", "" ) ?: "";
			var match        = acceptHeader
				.listToArray()
				// Discover the matching extension
				.reduce( function( previous, thisAccept ){
					// If we found, just return
					if ( previous.len() ) {
						return previous;
					}
					// Match towards system valid extensions
					return variables.router
						.getValidExtensions()
						.listFilter( function( thisExtension ){
							return ( thisAccept.findNoCase( thisExtension ) );
						} )
						.listFirst();
				}, "" );

			if ( match.len() && !match.findNoCase( "htm" ) ) {
				// if the user passed in format via the query string,
				// we'll assume that's the value they actually wanted.
				event.paramValue( "format", match.lcase() );
			}
		}

		// return the same request string, extension not found
		return requestString;
	}

	/**
	 * Render a RESTFul response
	 *
	 * @route The route response
	 * @event The event object
	 */
	private any function renderResponse( required route, required event ){
		var aRoute      = arguments.route;
		var theResponse = "";

		// standardize status codes if not found.
		if ( !structKeyExists( aRoute, "statusCode" ) ) {
			aRoute.statusCode = 200;
		}
		if ( !structKeyExists( aRoute, "statusText" ) ) {
			aRoute.statusText = "Ok";
		}

		// simple values
		if ( isSimpleValue( aRoute.response ) ) {
			// setup default response
			theResponse      = aRoute.response;
			// String replacements
			var replacements = reMatchNoCase( "{[^{]+?}", aRoute.response );
			for ( var thisReplacement in replacements ) {
				var thisKey = reReplaceNoCase( thisReplacement, "({|})", "", "all" );
				if ( event.valueExists( thisKey ) ) {
					theResponse = replace(
						aRoute.response,
						thisReplacement,
						event.getValue( thisKey ),
						"all"
					);
				}
			}
		}
		// Closure/Lambda
		else {
			theResponse = aRoute.response(
				event,
				event.getCollection(),
				event.getPrivateCollection()
			);
		}

		// render it out
		event
			.renderdata(
				type       = isSimpleValue( theResponse ) ? "HTML" : "JSON",
				data       = theResponse,
				statusCode = aRoute.statusCode,
				statusText = aRoute.statusText
			)
			.noExecution();
	}

	/**
	 * Resolve handler/module packages
	 *
	 * @routingString The incoming routing string
	 * @routeParams   The incoming route parameters
	 * @module        Module route or not
	 */
	private function packageResolver(
		required routingString,
		required routeParams,
		module = ""
	){
		var root           = variables.handlersPath;
		var extRoot        = variables.handlersExternalLocationPath;
		var x              = 1;
		var newEvent       = "";
		var thisFolder     = "";
		var foundPaths     = "";
		var routeParamsLen = arrayLen( arguments.routeParams );
		var rString        = arguments.routingString;
		var returnString   = arguments.routingString;
		var isModule       = len( arguments.module ) GT 0;

		// Verify if we have a handler on the route params
		if ( findNoCase( "handler", arrayToList( arguments.routeParams ) ) ) {
			// Cleanup routing string to position of :handler
			for ( x = 1; x lte routeParamsLen; x = x + 1 ) {
				if ( arguments.routeParams[ x ] neq "handler" ) {
					rString = replace( rString, listFirst( rString, "/" ) & "/", "" );
				} else {
					break;
				}
			}

			// Pre-Pend if already a module explicit call and switch the root
			// Module has already been resolved
			if ( isModule ) {
				// Setup the module entry point
				newEvent     = arguments.module & ":";
				// Change Physical Path to module now, module detected
				root         = variables.modules[ arguments.module ].handlerPhysicalPath;
				// Pre Pend The module to the path, so it can wipe it cleanly later.
				returnString = arguments.module & "/" & returnString;
			}

			// Now Find Packaging in our stripped rString
			for ( x = 1; x lte listLen( rString, "/" ); x = x + 1 ) {
				// Get Folder from first part of string
				thisFolder = listGetAt( rString, x, "/" );

				// Check if package exists in convention OR external location
				if (
					directoryExists( root & "/" & foundPaths & thisFolder )
					OR
					( len( extRoot ) AND directoryExists( extRoot & "/" & foundPaths & thisFolder ) )
				) {
					// Save Found Paths
					foundPaths = foundPaths & thisFolder & "/";

					// Save new Event
					if ( len( newEvent ) eq 0 ) {
						newEvent = thisFolder & ".";
					} else {
						newEvent &= thisFolder & ".";
					}
				}
				// end if folder found
				// Module check second, if the module is in the URL
				else if ( !isModule && structKeyExists( variables.modules, thisFolder ) ) {
					// Setup the module entry point
					newEvent = thisFolder & ":";
					// Change Physical Path to module now, module detected
					root     = variables.modules[ thisFolder ].handlerPhysicalPath;
				} else {
					// newEvent = newEvent & "." & thisFolder;
					break;
				}
				// end not a folder or module
			}
			// end for loop

			// Replace Return String if new event packaged found
			if ( len( newEvent ) ) {
				// module/event replacement
				returnString = replaceNoCase(
					returnString,
					replace(
						replace( newEvent, ":", "/", "all" ),
						".",
						"/",
						"all"
					),
					newEvent
				);
			}
		}
		// end if handler found

		// Module Cleanup
		if ( isModule ) {
			return replaceNoCase( returnString, arguments.module & ":", "" );
		}

		return returnString;
	}

	/**
	 * Check for invalid URL's
	 *
	 * @route       The incoming route
	 * @script_name The cgi script name
	 * @event       The event object
	 */
	private function checkForInvalidURL(
		required route,
		required script_name,
		required event
	){
		var handler = "";
		var action  = "";
		var newpath = "";
		var rc      = event.getCollection();

		/**
		Verify we have uniqueURLs ON, the event var exists, route is empty or index.cfm
		AND
		if the incoming event is not the default OR it is the default via the URL.
		**/
		if (
			structKeyExists( rc, variables.eventName )
			AND
			( arguments.route EQ "/index.cfm" or arguments.route eq "" )
			AND
			(
				rc[ variables.eventName ] NEQ variables.defaultEvent
				OR
				( structKeyExists( url, variables.eventName ) AND rc[ variables.eventName ] EQ variables.defaultEvent )
			)
		) {
			//  New Pathing Calculations if not the default event. If default, relocate to the domain.
			if ( rc[ variables.eventName ] != variables.defaultEvent ) {
				//  Clean for handler & Action
				if ( structKeyExists( rc, variables.eventName ) ) {
					handler = reReplace( rc[ variables.eventName ], "\.[^.]*$", "" );
					action  = listLast( rc[ variables.eventName ], "." );
				}
				//  route a handler
				if ( len( handler ) ) {
					newpath = "/" & handler;
				}
				//  route path with handler + action if not the default event action
				if ( len( handler ) && len( action ) ) {
					newpath = newpath & "/" & action;
				}
			}

			// Debugging
			if ( variables.log.canDebug() ) {
				variables.log.debug(
					"SES Invalid URL detected. Route: #arguments.route#, script_name: #arguments.script_name#"
				);
			}

			// Setup Relocation
			var httpRequestData = getHTTPRequestData();
			var relocationUrl   = "#arguments.event.getSESbaseURL()##newpath##serializeURL( httpRequestData.content, arguments.event )#";

			if ( httpRequestData.method eq "GET" ) {
				cflocation( url = relocationUrl, statusCode = 301 );
			} else {
				cflocation( url = relocationUrl, statusCode = 303 );
			}
		}
	}

	/**
	 * Serialize a URL when invalid
	 *
	 * @formVars The incoming form variables
	 * @event    The event object
	 */
	private function serializeURL( formVars = "", required event ){
		var vars = arguments.formVars;
		var rc   = arguments.event.getCollection();

		for ( var key in rc ) {
			if ( NOT listFindNoCase( "route,handler,action,#variables.eventName#", key ) ) {
				vars = listAppend( vars, "#lCase( key )#=#rc[ key ]#", "&" );
			}
		}

		if ( len( vars ) eq 0 ) {
			return "";
		}

		return "?" & vars;
	}

	/**
	 * Clean up some IIS funkyness where query string is found in the path info. We basically clean it up and add the query string into the RC scope
	 *
	 * @requestString the incoming request string
	 * @rc            The request collection struct
	 */
	private function fixIISURLVars( required requestString, required rc ){
		// Find a Matching position of IIS ?
		if ( reFind( "\?.*=", arguments.requestString ) ) {
			// Process the Query String
			reReplace( arguments.requestString, "^.*\?", "", "all" )
				.listToArray( "&" )
				.each( function( item ){
					rc[ item.getToken( 1, "=" ) ] = item.getToken( 2, "=" );
				} );
			// Cleanup the query string
			arguments.requestString = reReplace( arguments.requestString, "\?.*$", "", "all" );
		}
		return arguments.requestString;
	}

	/**
	 * Find the convention name value pairs in the incoming request string, if found, we will incorporate them into the incoming `params` arguments
	 *
	 * @requestString the incoming request string
	 * @match         The regex matcher object
	 * @params        The incoming parameter struct
	 */
	private function findConventionNameValuePairs(
		required string requestString,
		required any match,
		required struct params
	){
		var leftOverLen = len( arguments.requestString ) - arguments.match.len[ 1 ];
		if ( leftOverLen GT 0 ) {
			// Process Name/Value Pairs
			var currentKey = "";
			right( arguments.requestString, leftOverLen )
				.listToArray( "/" )
				.each( function( item, index ){
					// Odd index means variable assignment
					if ( index mod 2 neq 0 ) {
						// Validate incoming Item
						if ( !isValid( "variableName", item ) ) {
							item = "INVALID_VARIABLE_NAME-#item#";
						}
						// Set pivot point
						currentKey           = item;
						// Set it to default empty value
						params[ currentKey ] = "";
					}
					// Odd index means the
					else {
						params[ currentKey ] = item;
					}
				} );
		}
		// end if convention name value pairs
	}

	/**
	 * Get and Clean the path_info and script names structure
	 *
	 * @rc    The incoming request collection
	 * @event The event object
	 *
	 * @return struct { pathInfo, scriptName, domain }
	 */
	private function getCleanedPaths( required rc, required event ){
		var results = {};

		// Get path_info & script name
		// Replace any duplicate slashes with 1 just in case
		results[ "pathInfo" ] = trim(
			reReplace(
				getCGIElement( "path_info", arguments.event ),
				"\/{2,}",
				"/",
				"all"
			)
		);
		results[ "scriptName" ] = trim(
			reReplaceNoCase(
				getCGIElement( "script_name", arguments.event ),
				"[/\\]index\.cfm",
				""
			)
		);
		results[ "domain" ] = trim(
			reReplace(
				getCGIElement( "server_name", arguments.event ),
				"\/{2,}",
				"/",
				"all"
			)
		);

		// Clean ContextRoots
		if ( len( getContextRoot() ) ) {
			results[ "scriptName" ] = replaceNoCase( results[ "scriptName" ], getContextRoot(), "" );
		}

		// Clean up the path_info from index.cfm
		results[ "pathInfo" ] = reReplaceNoCase( results[ "pathInfo" ], "^[/\\]index\.cfm", "" );

		// Clean the scriptname from the pathinfo if it is the first item in case this is a nested application
		if ( len( results[ "scriptName" ] ) ) {
			results[ "pathInfo" ] = reReplaceNoCase(
				results[ "pathInfo" ],
				"^#results[ "scriptName" ]#\/",
				""
			);
		}

		// clean 1 or > / in front of route in some cases, scope = one by default
		results[ "pathInfo" ] = reReplaceNoCase( results[ "pathInfo" ], "^/+", "/" );

		// fix URL vars after ?
		results[ "pathInfo" ] = fixIISURLVars( results[ "pathInfo" ], arguments.rc );

		return results;
	}

}
