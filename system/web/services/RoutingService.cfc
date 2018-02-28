/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* This service is in charge of URL routing in ColdBox
*/
component extends="coldbox.system.web.services.BaseService" accessors="true"{

	/**
	 * A ColdBox Router this routing service configures with.
	 * @doc_generic coldbox.system.web.routing.Router
	 */
	property name="router";

	/**
	 * Constructor
	 */
	function init( required controller ){
		setController( arguments.controller );

		return this;
	}

	/**
	 * Once configuration loads prepare for operation
	 */
	function onConfigurationLoad(){
		// Prepare dependencies
		variables.log 							= variables.controller.getLogBox().getLogger( this );
		variables.handlersPath 					= controller.getSetting( "HandlersPath" );
		variables.handlersExternalLocationPath 	= controller.getSetting( "HandlersExternalLocationPath" );
		variables.modules						= controller.getSetting( "Modules" );
		variables.eventName						= controller.getSetting( "EventName" );
		variables.defaultEvent					= controller.getSetting( "DefaultEvent" );
		variables.requestService				= controller.getRequestService();
		variables.wirebox 						= controller.getWireBox();

		// Routing AppMapping Determinations
		variables.routingAppMapping = ( len( controller.getSetting( 'AppMapping' ) lte 1 ) ? controller.getSetting( 'AppMapping' ) & "/" : "" );
		variables.routingAppMapping = left( variables.routingAppMapping, 1 ) == "/" ? variables.routingAppMapping : "/#variables.routingAppMapping#";

		// Store routing appmapping
		controller.setSetting( "routingAppMapping", variables.routingAppMapping );

		// Register as an interceptor to listen to pre processes for routing
		variables.controller.getInterceptorService()
			.registerInterceptor( interceptorObject = this );

		// Load the Application Router: Interceptors are online and modules are registered but not activated
		loadRouter();
	}

	/****************************************************************************************************************************/
	/*												COMPATIBILIITY SHIM															*/
	/****************************************************************************************************************************/

	/**
	 * Passthrough for legacy support of calling Router methods.  This will be removed in future versions.
	 */
	function onMissingMethod( missingMethodName, missingMethodArguments={} ){
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
	 * Import a Router into this interceptor.
	 * This leverages first the legacy option of `routes.cfm` and if not found looks at `Router.cfc`
	 */
	private function loadRouter(){
		var routerFile = "config/Routes.cfm";

		// Validate file location: relative or absolute
		var configFilePath = variables.routingAppMapping & reReplace( routerFile, "^/", "" );
		if( NOT fileExists( expandPath( configFilePath ) ) ){
			// Check absolute location as not found inside our app
			configFilePath = routerFile;
			if( NOT fileExists( expandPath( configFilePath ) ) ){
				throw( message="Error locating routes file: #configFilePath#", type="SES.ConfigFileNotFound" );
			}
		}

		// Load Router by style: legacy or modern
		if( listLast( configFilePath, "." ) == "cfm" ){
			// Register basic router
			wirebox.registerNewInstance( name="router@coldbox", instancePath="coldbox.system.web.routing.Router" );
			// Process legacy Routes.cfm. Create a basic Router
			variables.router = wirebox.getInstance( "router@coldbox" )
				// Load up legacy template
				.includeRoutes( configFilePath );
		} else {
			// Process as a Router.cfc with virtual inheritance
			wirebox.registerNewInstance( name="router@coldbox", instancePath=invocationPath )
				.setVirtualInheritance( "coldbox.system.web.routing.Router" )
				.addDIConstructorArgument( name="controller", value=controller )
				.setThreadSafe( true )
				.setScope(
					wirebox.getBinder().SCOPES.SINGLETON
				);
			// Create the Router
			variables.router = wirebox.getInstance( "Router@coldbox" );
			// Process it
			variables.router.configure();
		}

		// Startup the Router for operation
		variables.router.startup();

		return this;
	}

	/****************************************************************************************************************************/
	/* 													INTERCEPTION EVENT 														*/
	/****************************************************************************************************************************/

	/**
	 * This is the route dispatcher called upon the request is captured.
	 */
	public void function onRequestCapture( event, interceptData, rc, prc, buffer ){
		// Find which route this URL matches
		var routedStruct = {};
        var cleanedPaths = getCleanedPaths( rc, arguments.event );
		var HttpMethod	 = arguments.event.getHttpMethod();

		// Check if disabled or in proxy mode, if it is, then exit out.
		if( ! variables.router.getEnabled() OR arguments.event.isProxyRequest() ){
			return;
		}

		// Activate and record the incoming URL for multi-domain hosting
		arguments.event
			.setSESEnabled( true )
			.setSESBaseURL(
				"http" &
				( event.isSSL() ? "s" : "" ) &
				"://#cgi.HTTP_HOST#/#variables.routingAppMapping#" &
				( variables.router.getFullRewrites() ? "" : "index.cfm" )
			);

		// Check for invalid URLs if in strict mode via unique URLs
		if( variables.router.getUniqueURLs() ){
			checkForInvalidURL( cleanedPaths[ "pathInfo" ] , cleanedPaths[ "scriptName" ], arguments.event );
		}

		// Extension detection if enabled, so we can do cool extension formats
		if( variables.router.getExtensionDetection() ){
			cleanedPaths[ "pathInfo" ] = detectExtension( cleanedPaths[ "pathInfo" ], arguments.event );
        }

		// Find a route to dispatch
		var targetRoute = findRoute(
			action = cleanedPaths[ "pathInfo" ],
			event  = arguments.event,
			domain = cleanedPaths[ "domain" ]
		);

		// Now route should have all the key/pairs from the URL we need to pass to our event object for processing
		targetRoute.each( function( key, value ){
			// Reserved Keys Check, only translate NON reserved keys
			if( !variables.router.RESERVED_KEYS.listFindNoCase( key ) ){
				rc[ key ] 			= value;
				routedStruct[ key ] = value;
			}
		} );

		// Process Redirects
		if( !isNull( targetRoute.redirect ) ){
			if( targetRoute.redirect.findNoCase( "http" ) ){
				relocate( URL=targetRoute.redirect, statusCode=targetRoute.statusCode ?: 301 );
			} else {
				relocate( event=targetRoute.redirect, statusCode=targetRoute.statusCode ?: 301 );
			}
		}

		// Process Handler/Actions
		if( structKeyExists( targetRoute, "handler" ) ){
			// Check if using HTTP method actions via struct
			if( structKeyExists( targetRoute, "action" ) && isStruct( targetRoute.action ) ){
				// Verify HTTP method used is valid
				if( structKeyExists( targetRoute.action, HTTPMethod ) ){
					targetRoute.action = targetRoute.action[ HTTPMethod ];
					// Send for logging in debug mode
					if( log.canDebug() ){
						log.debug( "Matched HTTP Method (#HTTPMethod#) to routed action: #targetRoute.action#" );
					}
				} else {
					// Mark as invalid HTTP Exception
					targetRoute.action = "onInvalidHTTPMethod";
					arguments.event.setIsInvalidHTTPMethod( true );
					if( log.canDebug() ){
						log.debug( "Invalid HTTP Method detected: #HTTPMethod#", targetRoute );
					}
				}
			}

			// Create routed event
			rc[ variables.eventName ] = targetRoute.handler;
			if( structKeyExists( targetRoute, "action" ) ){
				rc[ variables.eventName ] &= "." & targetRoute.action;
			}

			// Do we have a module? If so, create routed module event.
			if( len( targetRoute.module ) ){
				rc[ variables.eventName ] = targetRoute.module & ":" & rc[ variables.eventName ];
			}

		} // end if handler exists

		// See if View is Dispatched
		if( structKeyExists( targetRoute, "view" ) ){
			// Dispatch the View
			arguments.event
				.setView( name=targetRoute.view, noLayout=targetRoute.viewNoLayout )
				.noExecution();
		}

		// See if Response is dispatched
		if( structKeyExists( targetRoute, "response" ) ){
			renderResponse( targetRoute, arguments.event );
		}

		// Save the Routed Variables so event caching can verify them
		arguments.event.setRoutedStruct( routedStruct );
	}

	/****************************************************************************************************************************/
	/* 											ROUTE DISPATCHING METHODS														*/
	/****************************************************************************************************************************/

	/**
	 * Figures out which route matches this request and returns a routed structure
	 *
	 * @action The action evaluated by path_info
	 * @event The event object
	 * @module Incoming module
	 * @namespace Incoming namespace
     * @domain Incoming domain
	 */
	function findRoute(
		required action,
		required event,
		module="",
        namespace="",
        domain=""
	){
		var requestString 		 = arguments.action;
		var params 				 = {};
		var rc 					 = event.getCollection();

		// Start with global routes
		var _routes 			 = variables.router.getRoutes();
		// Module call? Switch routes
		if( len( arguments.module ) ){
			_routes 		= variables.router.getModuleRoutes( arguments.module );
			_routesLength 	= _routes.len();
		}
		// Namespace Call? Switch routes
		if( len( arguments.namespace ) ){
			_routes 		= variables.router.getNamespaceRoutes( arguments.namespace );
		}

		// Process routing length
		var _routesLength 	= _routes.len();

		// Remove the leading slash
		if( len( requestString ) GT 1 AND left( requestString, 1 ) eq "/" ){
			requestString = right( requestString, len( requestString ) - 1 );
		}
		// Add ending slash
		if( right( requestString, 1 ) IS NOT "/" ){
			requestString = requestString & "/";
		}

		// Let's Find a Route, Loop over all the routes array
		var foundRoute = {};
		for( var i=1; i lte _routesLength; i++ ){

			// Match The route to request String
			var match = reFindNoCase( _routes[ i ].regexPattern, requestString, 1, true );
			if( ( match.len[ 1 ] IS NOT 0 AND variables.router.getLooseMatching())
			     OR
				( NOT variables.router.getLooseMatching() AND match.len[ 1 ] IS NOT 0 AND match.pos[ 1 ] EQ 1 )
			){

				// Verify condition matching
				if( structKeyExists( _routes[ i ], "condition" ) AND NOT
					isSimpleValue( _routes[ i ].condition ) AND NOT
					_routes[ i ].condition( requestString )
				){
					// Debug logging
					if( log.canDebug() ){
						log.debug( "SES Route matched but condition closure did not pass: #_routes[ i ].toString()# on routed string: #requestString#" );
					}
					// Condition did not pass, move to next route
					continue;
                }

                // Verify domain if exists
                if( structKeyExists( _routes[ i ], "domain" ) AND isSimpleValue( _routes[ i ].domain ) ){
                    var domainMatch = reFindNoCase( _routes[ i ].regexDomain, domain, 1, true );
                    if( domainMatch.len[ 1 ] == 0 ){
                        continue;
                    }
                }

				// Setup the found Route
				foundRoute = _routes[ i ];

				// Is this namespace routing?
				if( len( arguments.namespace ) ){
					arguments.event.setPrivateValue( "currentRoutedNamespace", arguments.namespace );
				}

				// Debug logging
				if( log.canDebug() ){
					log.debug( "SES Route matched: #foundRoute.toString()# on routed string: #requestString#" );
				}

				break;
			}
		}//end finding routes

		// Check if we found a route, else just return empty params struct
		if( structIsEmpty( foundRoute ) ){
			if( log.canDebug() ){
				log.debug( "No URL routes matched on routed string: #requestString#" );
			}
			return params;
		}

		// SSL Checks
		if( foundRoute.ssl AND NOT event.isSSL() ){
			relocate(
				URL         = event.getSESBaseURL() & reReplace( cgi.path_info, "^\/", "" ),
				ssl         = true,
				statusCode  = 302,
				queryString = cgi.query_string
			);
		}

		// Check if the match is a module Routing entry point or a namespace entry point or not?
		if( len( foundRoute.moduleRouting ) OR len( foundRoute.namespaceRouting ) ){
			// build routing argument struct
			var contextRouting = {
				action = reReplaceNoCase( requestString, foundRoute.regexpattern, "" ),
				event  = arguments.event
			};
			// add module or namespace
			if( len( foundRoute.moduleRouting ) ){
				contextRouting.module = foundRoute.moduleRouting;
			} else {
				contextRouting.namespace = foundRoute.namespaceRouting;
			}

			// Try to Populate the params from the module pattern if any
			for( var x=1; x lte arrayLen( foundRoute.patternParams ); x++ ){
				params[ foundRoute.patternParams[ x ] ] = mid( requestString, match.pos[ x + 1 ], match.len[ x + 1 ] );
			}

			// Save Found URL
			arguments.event.setPrivateValue( "currentRoutedURL", requestString );
			// process context find
			structAppend( params, findRoute( argumentCollection=contextRouting ), true );

			// Return if parameters found.
			if( NOT structIsEmpty( params ) ){
				return params;
			}
		}

		// Save Found Route + Name
		arguments.event
			.setPrivateValue( "currentRoute", 		foundRoute.pattern )
			.setPrivateValue( "currentRouteName",	foundRoute.name );

		// Save Found URL if NOT Found already
		if( NOT arguments.event.privateValueExists( "currentRoutedURL" ) ){
			arguments.event.setPrivateValue( "currentRoutedURL", requestString );
		}

		// Do we need to do package resolving
		if( NOT foundRoute.packageResolverExempt ){
			// Resolve the packages
			var packagedRequestString = packageResolver( requestString, foundRoute.patternParams, arguments.module );
			// reset pattern matching, if packages found.
			if( compare( packagedRequestString, requestString ) NEQ 0 ){
				// Log package resolved
				if( log.canDebug() ){
					log.debug( "URL Routing Package Resolved: #packagedRequestString#" );
				}
				// Return found Route recursively.
				return findRoute( action=packagedRequestString, event=arguments.event, module=arguments.module );
			}
		}

		// Populate the params, with variables found in the request string
		for( var x=1; x lte arrayLen( foundRoute.patternParams ); x++ ){
			params[ foundRoute.patternParams[ x ] ] = mid( requestString, match.pos[ x + 1 ], match.len[ x + 1 ] );
        }

		// Populate the params, with variables found in the domain string
        for( var x=1; x lte arrayLen( foundRoute.domainParams ); x++ ){
            params[ foundRoute.domainParams[ x ] ] = listGetAt( domain, x, "." );
        }

		// Process Convention Name-Value Pairs
		if( foundRoute.valuePairTranslation ){
			findConventionNameValuePairs( requestString, match, params );
		}

		// Now setup all found variables in the param struct, so we can return
		for( var key in foundRoute ){
			// Check that the key is not a reserved route argument and NOT already routed
			if( ! variables.router.RESERVED_ROUTE_ARGUMENTS.listFindNoCase( key )
				AND ! params.keyExists( key )
			){
				params[ key ] = foundRoute[ key ];
			}
			else if ( key eq "matchVariables" ){
				for( var i=1; i lte listLen( foundRoute.matchVariables ); i++ ){
					// Check if the key does not exist in the routed params yet.
					if( NOT structKeyExists( params, listFirst( listGetAt( foundRoute.matchVariables, i ), "=" ) ) ){
						params[ listFirst( listGetAt( foundRoute.matchVariables, i ), "=" ) ] = listLast( listGetAt( foundRoute.matchVariables, i ), "=" );
					}
				}
			}
		}

		return params;
	}

	/**
	 * The cgi element facade method
	 * @cgiElement The element to take from CGI
	 * @event The event object
	 */
	function getCgiElement( required cgiElement, required event ){
		// Allow a UDF to manipulate the CGI.PATH_INFO value
		// in advance of route detection.
		if( arguments.cgiElement EQ 'path_info' AND structKeyExists( variables.router, 'PathInfoProvider' ) ){
			return variables.router.pathInfoProvider( event=arguments.event );
		}
		return CGI[ arguments.CGIElement ];
	}

	/****************************************** PRIVATE ************************************************/

	/**
	 * Detect extensions from the incoming request
	 * @requestString The incoming request string
	 * @event The event object
	 */
	private function detectExtension( required requestString, required event ){
		var extension 		= listLast( arguments.requestString, "." );
		var extensionLen	= len( extension );

		// cleanup of extension, just in case rewrites add garbage.
		extension = lcase( reReplace( extension, "/$", "", "all" ) );

		// check if extension found
		if( listLen( arguments.requestString, "." ) GT 1 AND len( extension ) AND NOT find( "/", extension ) ){
			// Check if extension is valid?
			if( variables.router.isValidExtension( extension ) ){
				// set the format request collection variable
				event.setValue( "format", extension );
				// debug logging
				if( log.canDebug() ){
					log.debug( "Extension: #extension# detected and set in rc.format" );
				}
				// remove it from the string and return string for continued parsing.
				return left( requestString, len( arguments.requestString ) - extensionLen - 1 );
			} else if( variables.router.getThrowOnInvalidExtension() ){
				event.setHTTPHeader(
					statusText = "Invalid Requested Format Extension: #extension#",
					statusCode = 406
				);
				throw(
					message = "Invalid requested format extendion: #extension#",
					detail	= "Invalid Request Format Extension Detected: #extension#. Valid extensions are: #variables.router.getValidExtensions()#",
					type 	= "InvalidRequestedFormatExtension"
				);
			}
		}
		// check accepts headers for the best match
		else{
			// Process Accept Headers
			var match = event.getHTTPHeader( "Accept", "" ).listToArray()
				// Discover the matching extension
				.reduce( function( previous, thisAccept ){
					// If we found, just return
					if( previous.len() ){
						return previous;
					}
					// Match towards system valid extensions
					return variables.router.getValidExtensions()
						.listFilter( function( thisExtension ) {
							return ( thisAccept.findNoCase( thisExtension ) );
						} )
						.listFirst();
				}, "" );

			if( match.len() && match.findNoCase( "htm" ) ){
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
	 * @route The route response
	 * @event The event object
	 */
	private any function renderResponse( required route, required event ){
		var aRoute 			= arguments.route;
		var replacements 	= "";
		var thisReplacement = "";
		var thisKey			= "";
		var theResponse		= "";

		// standardize status codes if not found.
		if( !structKeyExists( aRoute, "statusCode" ) ){ aRoute.statusCode = 200; }
		if( !structKeyExists( aRoute, "statusText" ) ){ aRoute.statusText = "Ok"; }

		// simple values
		if( isSimpleValue( aRoute.response ) ){
			// setup default response
			theResponse = aRoute.response;
			// String replacements
			replacements = reMatchNoCase( "{[^{]+?}", aRoute.response );
			for( thisReplacement in replacements ){
				thisKey = reReplaceNoCase( thisReplacement, "({|})", "", "all" );
				if( event.valueExists( thisKey ) ){
					theResponse = replace( aRoute.response, thisReplacement, event.getValue( thisKey ), "all" );
				}
			}
		}
		// Closure/Lambda
		else{
			theResponse = aRoute.response( event, event.getCollection(), event.getPrivateCollection() );
		}

		// render it out
		event.renderdata(
			data 		= theResponse,
			statusCode 	= aRoute.statusCode,
			statusText 	= aRoute.statusText
		).noExecution();
	}

	/**
	 * Resolve handler/module packages
	 *
	 * @routingString The incoming routing string
	 * @routeParams The incoming route parameters
	 * @module Module route or not
	 */
	private function packageResolver( required routingString, required routeParams, module="" ){
		var root 			= variables.handlersPath;
		var extRoot 		= variables.handlersExternalLocationPath;
		var x 				= 1;
		var newEvent 		= "";
		var thisFolder 		= "";
		var foundPaths 		= "";
		var routeParamsLen 	= arrayLen( arguments.routeParams );
		var rString 		= arguments.routingString;
		var returnString 	= arguments.routingString;
		var isModule		= len( arguments.module ) GT 0;

		// Verify if we have a handler on the route params
		if( findnocase( "handler", arrayToList( arguments.routeParams ) ) ){

			// Cleanup routing string to position of :handler
			for(x=1; x lte routeParamsLen; x=x+1){
				if( arguments.routeParams[ x ] neq "handler" ){
					rString = replace(rString,listFirst(rString,"/" ) & "/","" );
				}
				else{
					break;
				}
			}

			// Pre-Pend if already a module explicit call and switch the root
			// Module has already been resolved
			if( isModule ){
				// Setup the module entry point
				newEvent = arguments.module & ":";
				// Change Physical Path to module now, module detected
				root = variables.modules[ arguments.module ].handlerPhysicalPath;
				// Pre Pend The module to the path, so it can wipe it cleanly later.
				returnString = arguments.module & "/" & returnString;
			}

			// Now Find Packaging in our stripped rString
			for(x=1; x lte listLen(rString,"/" ); x=x+1){

				// Get Folder from first part of string
				thisFolder = listgetAt(rString,x,"/" );

				// Check if package exists in convention OR external location
				if( directoryExists(root & "/" & foundPaths & thisFolder)
					OR
				    ( len(extRoot) AND directoryExists(extRoot & "/" & foundPaths & thisFolder) )
				){
					// Save Found Paths
					foundPaths = foundPaths & thisFolder & "/";

					// Save new Event
					if(len(newEvent) eq 0){
						newEvent = thisFolder & ".";
					}
					else{
						newEvent &= thisFolder & ".";
					}
				}//end if folder found
				// Module check second, if the module is in the URL
				else if( structKeyExists(variables.modules, thisFolder) ){
					// Setup the module entry point
					newEvent = thisFolder & ":";
					// Change Physical Path to module now, module detected
					root = variables.modules[thisFolder].handlerPhysicalPath;
				}
				else{
					//newEvent = newEvent & "." & thisFolder;
					break;
				}//end not a folder or module

			}//end for loop

			// Replace Return String if new event packaged found
			if( len(newEvent) ){
				// module/event replacement
				returnString = replacenocase(returnString, replace( replace(newEvent,":","/","all" ) ,".","/","all" ), newEvent);
			}
		}//end if handler found

		// Module Cleanup
		if( isModule ){
			return replaceNoCase( returnString, arguments.module & ":", "" );
		}

		return returnString;
	}

	/**
	 * Check for invalid URL's
	 * @route The incoming route
	 * @script_name The cgi script name
	 * @event The event object
	 */
	private function checkForInvalidURL( required route, required script_name, required event ){
		var handler 		= "";
		var action 			= "";
		var newpath 		= "";
		var httpRequestData = getHttpRequestData();
		var rc 				= event.getCollection();

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
		){

			//  New Pathing Calculations if not the default event. If default, relocate to the domain.
			if ( rc[ variables.eventName ] != variables.defaultEvent ) {
				//  Clean for handler & Action
				if ( StructKeyExists( rc, variables.eventName ) ) {
					handler = reReplace( rc[ variables.eventName ], "\.[^.]*$", "" );
					action = ListLast( rc[ variables.eventName ], "." );
				}
				//  route a handler
				if ( len(handler) ) {
					newpath = "/" & handler;
				}
				//  route path with handler + action if not the default event action
				if ( len(handler) && len(action) ) {
					newpath = newpath & "/" & action;
				}
			}

			// Debugging
			if( log.canDebug() ){
				log.debug( "SES Invalid URL detected. Route: #arguments.route#, script_name: #arguments.script_name#" );
			}

			// Relocation Headers
			if( httpRequestData.method eq "GET" ){
				getPageContext().getResponse().addIntHeader(
					javaCast( "string", "Moved permanently" ),
					javaCast( "int", 301 )
				);
			} else {
				getPageContext().getResponse().addIntHeader(
					javaCast( "string", "See Other" ),
					javaCast( "int", 303 )
				);
			}

			// Send location
			getPageContext().getResponse().addHeader(
				javaCast( "string", "Location" ),
				javaCast( "string", "#arguments.event.getSESbaseURL()##newpath##serializeURL( httpRequestData.content, arguments.event )#" )
			);

			abort;
		}
	}

	/**
	 * Serialize a URL when invalid
	 * @formVars The incoming form variables
	 * @event The event object
	 */
	private function serializeURL( formVars="", required event ){
		var vars 	= arguments.formVars;
		var rc 		= arguments.event.getCollection();

		for( var key in rc ){
			if( NOT ListFindNoCase( "route,handler,action,#variables.eventName#", key ) ){
				vars = ListAppend( vars, "#lcase( key )#=#rc[ key ]#", "&" );
			}
		}

		if( len( vars ) eq 0 ){
			return "";
		}

		return "?" & vars;
	}

	/**
	 * Clean up some IIS funkyness where query string is found in the path info. We basically clean it up and add the query string into the RC scope
	 *
	 * @requestString the incoming request string
	 * @rc The request collection struct
	 */
	private function fixIISURLVars( required requestString, required rc ){
		// Find a Matching position of IIS ?
		if( reFind( "\?.*=", arguments.requestString ) ){
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
	 * Find the convention name value pairs in the incoming request string
	 *
	 * @requestString the incoming request string
	 * @match The regex matcher object
	 * @params The incoming parameter struct
	 */
	private function findConventionNameValuePairs( required string requestString, required any match, required struct params ){
		var leftOverLen = len( arguments.requestString ) - arguments.match.len[ 1 ];
		if( leftOverLen gt 0 ){
			// Cleanup remaining string
			var conventionString 	= right( arguments.requestString, leftOverLen ).split( "/" );
			var conventionStringLen = arrayLen( conventionString );

			// If conventions found, continue parsing
			for( var i=1; i lte conventionStringLen; i++ ){
				if( i mod 2 eq 0 ){
					// Even: Means Variable Value
					arguments.params[ tmpVar ] = conventionString[ i ];
				} else {
					// ODD: Means variable name
					var tmpVar = trim( conventionString[ i ] );
					// Verify it is a valid variable Name
					if ( NOT isValid( "variableName", tmpVar ) ){
						tmpVar = "_INVALID_VARIABLE_NAME_POS_#i#_";
					} else {
						// Default Value of empty
						arguments.params[ tmpVar ] = "";
					}
				}
			}//end loop over pairs
		} //end if convention name value pairs
	}

	/**
	 * Get and Clean the path_info and script names structure
	 *
	 * @rc The incoming request collection
	 * @event The event object
	 *
	 * @return struct { pathInfo, scriptName, domain }
	 */
	private function getCleanedPaths( required rc, required event ){
		var results = {};

		// Get path_info & script name
        // Replace any duplicate slashes with 1 just in case
		results[ "pathInfo" ]		= trim( reReplace( getCGIElement( 'path_info', arguments.event ), "\/{2,}", "/", "all" ) );
        results[ "scriptName" ] 	= trim( reReplacenocase( getCGIElement( 'script_name', arguments.event ), "[/\\]index\.cfm", "" ) );
		results[ "domain" ]			= trim( reReplace( getCGIElement( 'server_name', arguments.event ), "\/{2,}", "/", "all" ) );

		// Clean ContextRoots
		if( len( getContextRoot() ) ){
			results[ "scriptName" ] = replacenocase( results[ "scriptName" ], getContextRoot(),"" );
		}

		// Clean up the path_info from index.cfm
		results[ "pathInfo" ] = reReplacenocase( results[ "pathInfo" ], "^[/\\]index\.cfm", "" );

		// Clean the scriptname from the pathinfo if it is the first item in case this is a nested application
		if( len( results[ "scriptName" ] ) ){
			results[ "pathInfo" ] = reReplaceNocase( results[ "pathInfo" ], "^#results[ "scriptName" ]#\/", "" );
		}

		// clean 1 or > / in front of route in some cases, scope = one by default
		results[ "pathInfo" ] = reReplaceNoCase( results[ "pathInfo" ], "^/+", "/" );

		// fix URL vars after ?
		results[ "pathInfo" ] = fixIISURLVars( results[ "pathInfo" ], arguments.rc );

		return results;
	}


}
