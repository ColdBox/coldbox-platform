/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* This interceptor provides complete SES and URL mappings support to ColdBox Applications
*/
component extends="coldbox.system.Interceptor" accessors="true"{

	/**
	 * The routing table
	 */
	property name="routes" type="array";

	/**
	 * Modules Routing Table
	 */
	property name="moduleRoutingTable" type="struct";

	/**
	 * Namespace routing tables
	 */
	property name="namespaceRoutingTable" type="struct";

	/**
	 * Auto reload configuration file flag
	 */
	property name="autoReload" type="boolean" default="false";

	/**
	 * Flag to enable unique or not URLs
	 */
	property name="uniqueURLS" type="boolean" default="false";

	/**
	 * Flag to enable/disable routing
	 */
	property name="enabled" type="boolean" default="true";	

	/**
	 * Loose matching flag for regex matches
	 */
	property name="looseMatching" type="boolean" default="false";	

	/**
	 * Detect extensions flag, so it can place a 'format' variable on the rc
	 */
	property name="extensionDetection" type="boolean" default="true";

	/**
	 * Throw an exception when extension detection is invalid or not
	 */
	property name="throwOnInvalidExtension" type="boolean" default="false";

	/**
	 * Initialize the valid extensions to detect
	 */
	property name="validExtensions" type="string" default="json,jsont,xml,cfm,cfml,html,htm,rss,pdf";

	/**
	 * Base routing URL
	 */
	property name="baseURL" type="string";

	/**
	 * Constructor
	 */
	function configure(){
		// with closure
		variables.withClosure = {};
		// module closure
		variables.withModule	= "";

		// STATIC Reserved Keys as needed for cleanups
		variables.RESERVED_KEYS 			= "handler,action,view,viewNoLayout,module,moduleRouting,response,statusCode,statusText,condition";
		variables.RESERVED_ROUTE_ARGUMENTS 	= "constraints,pattern,regexpattern,matchVariables,packageresolverexempt,patternParams,valuePairTranslation,ssl,append";

		// STATIC Valid Extensions
		variables.VALID_EXTENSIONS 			= "json,jsont,xml,cfm,cfml,html,htm,rss,pdf";

		/************************************** ROUTING DEFAULTS *********************************************/

		// Main routes Routing Table
		variables.routes = [];
		// Module Routing Table
		variables.moduleRoutingTable = {};
		// Namespaces Routing Table
		variables.namespaceRoutingTable = {};
		// Loose matching flag for regex matches
		variables.looseMatching = false;
		// Flag to enable unique or not URLs
		variables.uniqueURLs = true;
		// Enable the interceptor by default
		variables.enabled = true;
		// Auto reload configuration file flag
		variables.autoReload = false;
		// Detect extensions flag, so it can place a 'format' variable on the rc
		variables.extensionDetection = true;
		// Throw an exception when extension detection is invalid or not
		variables.throwOnInvalidExtension = false;
		// Initialize the valid extensions to detect
		variables.validExtensions = variables.VALID_EXTENSIONS;
		// Base Routing URL
		variables.baseURL = "";

		/************************************** INTERNAL DEPENDENCIES *********************************************/
 
	 	variables.handlersPath 					= getSetting( "HandlersPath" );
		variables.handlersExternalLocationPath 	= getSetting( "HandlersExternalLocationPath" );
		variables.modules						= getSetting( "Modules" );
		variables.eventName						= getSetting( "EventName" );
		variables.defaultEvent					= getSetting( "DefaultEvent" );
		variables.requestService				= getController().getRequestService();

		//Import Configuration
		importConfiguration();

		// Save the base URL in the application settings
		setSetting( 'sesBaseURL', variables.baseURL );
		setSetting( 'htmlBaseURL', replacenocase( variables.baseURL, "index.cfm", "") );

		// Configure Context, Just in case
		controller.getRequestService().getContext()
			.setIsSES( variables.enabled )
			.setSESBaseURL( variables.baseURL );
	}

	// CF-11 include .cfm template can't access the methods which are only declare as property... (hack) have to create setter/getter methods
	// Remove this with new CFC approach. CFM files will have to upgrade to CFC capabilities once feature is complete.
	function setBaseURL( string baseURL ){
		variables.baseURL = arguments.baseURL;
		return this;
	}
	function getBaseURL(){
		return variables.baseURL;
	}

	function setUniqueURLS( boolean uniqueURLS ){
		variables.uniqueURLS = arguments.uniqueURLS;
		return this;
	}
	function getUniqueURLS(){
		return variables.uniqueURLS;
	}

	/**
	 * This is the route dispatch
	 * @event The event object
	 * @interceptData The data intercepted
	 */
	public void function onRequestCapture( required event, required interceptData ){
		// Find which route this URL matches
		var aRoute 		 = "";
		var key 		 = "";
		var routedStruct = structnew();
		var rc 			 = arguments.event.getCollection();
        var cleanedPaths = getCleanedPaths( rc, arguments.event );
		var HTTPMethod	 = arguments.event.getHTTPMethod();

		// Check if disabled or in proxy mode, if it is, then exit out.
		if ( NOT variables.enabled OR arguments.event.isProxyRequest() ){ return; }

		//Auto Reload, usually in dev? then reconfigure the interceptor.
		if( variables.autoReload ){ configure(); }

		// Set that we are in ses mode
		arguments.event.setIsSES( true );

		// Check for invalid URLs if in strict mode via unique URLs
		if( variables.uniqueURLs ){
			checkForInvalidURL( cleanedPaths[ "pathInfo" ] , cleanedPaths[ "scriptName" ], arguments.event );
		}

		// Extension detection if enabled, so we can do cool extension formats
		if( variables.extensionDetection ){
			cleanedPaths[ "pathInfo" ] = detectExtension( cleanedPaths[ "pathInfo" ], arguments.event );
		}

		// Find a route to dispatch
		aRoute = findRoute(action=cleanedPaths[ "pathInfo" ],event=arguments.event);

		// Now route should have all the key/pairs from the URL we need to pass to our event object for processing
		for( key in aRoute ){
			// Reserved Keys Check, only translate NON reserved keys
			if( not listFindNoCase( variables.RESERVED_KEYS, key ) ){
				rc[ key ] = aRoute[ key ];
				routedStruct[ key ] = aRoute[ key ];
			}
		}

		// Create Event To Dispatch if handler key exists
		if( structKeyExists( aRoute, "handler" ) ){
			// Check if using HTTP method actions via struct
			if( structKeyExists( aRoute, "action" ) && isStruct( aRoute.action ) ){
				// Verify HTTP method used is valid
				if( structKeyExists( aRoute.action, HTTPMethod ) ){
					aRoute.action = aRoute.action[ HTTPMethod ];
					// Send for logging in debug mode
					if( log.canDebug() ){
						log.debug( "Matched HTTP Method (#HTTPMethod#) to routed action: #aRoute.action#" );
					}
				} else {
					// Mark as invalid HTTP Exception
					aRoute.action = "onInvalidHTTPMethod";
					arguments.event.setIsInvalidHTTPMethod( true );
					if( log.canDebug() ){
						log.debug( "Invalid HTTP Method detected: #HTTPMethod#", aRoute );
					}
				}
			}
			// Create routed event
			rc[ variables.eventName ] = aRoute.handler;
			if( structKeyExists(aRoute,"action") ){
				rc[ variables.eventName ] &= "." & aRoute.action;
			}

			// Do we have a module? If so, create routed module event.
			if( len( aRoute.module ) ){
				rc[ variables.eventName ] = aRoute.module & ":" & rc[ variables.eventName ];
			}

		}// end if handler exists

		// See if View is Dispatched
		if( structKeyExists( aRoute, "view" ) ){
			// Dispatch the View
			arguments.event.setView(name=aRoute.view, noLayout=aRoute.viewNoLayout)
				.noExecution();
		}
		// See if Response is dispatched
		if( structKeyExists( aRoute, "response" ) ){
			renderResponse( aRoute, arguments.event );
		}

		// Save the Routed Variables so event caching can verify them
		arguments.event.setRoutedStruct( routedStruct );
	}

	/**
	 * Register modules routes in the specified position in the main routing table, and returns itself
	 * @pattern The pattern to match against the URL
	 * @module The module to load routes for
	 * @append Whether the module entry point route should be appended or pre-pended to the main routes array. By default we append to the end of the array
	 */
	SES function addModuleRoutes( required pattern, required module, boolean append=true ){
		var mConfig 	 = variables.modules;
		var args		 = structnew();

		// Verify module exists and loaded
		if( NOT structKeyExists( mConfig, arguments.module ) ){
			throw(
				message	= "Error loading module routes as the module requested '#arguments.module#' is not loaded.",
				detail	= "The loaded modules are: #structKeyList( mConfig )#",
				type	= "SES.InvalidModuleName"
			);
		}

		// Create the module routes container if it does not exist already
		if( NOT structKeyExists( variables.moduleRoutingTable, arguments.module ) ){
			variables.moduleRoutingTable[ arguments.module ] = [];
		}

		// Store the entry point for the module routes.
		addRoute( pattern=arguments.pattern, moduleRouting=arguments.module, append=arguments.append );

		// Iterate through module routes and process them
		for( var x=1; x lte ArrayLen( mConfig[ arguments.module ].routes ); x=x+1 ){
			// Verify if simple value, then treat it as an include
			if( isSimpleValue( mConfig[ arguments.module ].routes[ x ] ) ){
				// prepare module pivot
				variables.withModule = arguments.module;
				// Include it via conventions using declared route
				includeRoutes( location=mConfig[ arguments.module ].mapping & "/" & mConfig[ arguments.module ].routes[ x ] );
				// Remove pivot
				variables.withModule = "";
			}
			// else, normal routing
			else{
				args = mConfig[ arguments.module ].routes[ x ];
				args.module = arguments.module;
				addRoute( argumentCollection=args );
			}
		}

		return this;

	}

	/**
	 * Register a namespace in the specified position in the main routing table, and returns itself
	 * @pattern The pattern to match against the URL.
	 * @namespace The name of the namespace to register
	 * @append Whether the route should be appended or pre-pended to the array. By default we append to the end of the array
	 */
	SES function addNamespace( required string pattern, required string namespace, boolean append="true" ){
		// Create the namespace routes container if it does not exist already, as we could create many patterns that point to the same namespace
		if( NOT structKeyExists( variables.namespaceRoutingTable, arguments.namespace ) ){
			variables.namespaceRoutingTable[ arguments.namespace ] = [];
		}

		// Store the entry point for the namespace
		addRoute(
			pattern 			= arguments.pattern, 
			namespaceRouting 	= arguments.namespace, 
			append 				= arguments.append
		);

		return this;
	}

	/**
	 * Starts a with closure, where all arguments will be prefixed for the next concatenated addRoute() methods until an endWith() is called
	 * @pattern The pattern to match against the URL.
	 * @handler The handler to execute if pattern matched.
	 * @action The action in a handler to execute if a pattern is matched.  This can also be a structure based on the HTTP method(GET,POST,PUT,DELETE). ex: {GET:'show', PUT:'update', DELETE:'delete', POST:'save'}
	 * @packageResolverExempt If this is set to true, then the interceptor will not try to do handler package resolving. Else a package will always be resolved. Only works if :handler is in a pattern
	 * @matchVariables A string of name-value pair variables to add to the request collection when this pattern matches. This is a comma delimmitted list. Ex: spaceFound=true,missingAction=onTest
	 * @view The view to dispatch if pattern matches.  No event will be fired, so handler,action will be ignored.
	 * @viewNoLayout If view is choosen, then you can choose to override and not display a layout with the view. Else the view renders in the assigned layout.
	 * @valuePairTranslation Activate convention name value pair translations or not. Turned on by default
	 * @constraints A structure of regex constraint overrides for variable placeholders. The key is the name of the variable, the value is the regex to try to match.
	 * @module The module to add this route to
	 * @moduleRouting Called internally by addModuleRoutes to add a module routing route.
	 * @namespace The namespace to add this route to
	 * @namespaceRouting Called internally by addNamespaceRoutes to add a namespaced routing route.
	 * @ssl Makes the route an SSL only route if true, else it can be anything. If an ssl only route is hit without ssl, the interceptor will redirect to it via ssl
	 * @append Whether the route should be appended or pre-pended to the array. By default we append to the end of the array
	 */
	SES function with(
		string pattern, 
		string handler, 
		any action, 
		boolean packageResolverExempt, 
		string matchVariables, 
		string view, 
		boolean viewNoLayout, 
		boolean valuePairTranslation, 
		any constraints, 
		string module, 
		string moduleRouting, 
		string namespace, 
		string namespaceRouting, 
		boolean ssl, 
		boolean append
	){
		// set the withClosure
		variables.withClosure = arguments;
		return this;
	}

	/**
	 * End a with closure and returns itself
	 */
	SES function endWith(){
		variables.withClosure = {};
		return this;
	}

	/**
	 * process a with closure
	 * @args The arugments to process
	 */
	SES function processWith( required args ){
		var w 	= variables.withClosure;
		var key = "";

		// only process arguments once per addRoute() call.
		if( structKeyExists(args,"$$withProcessed") ){ return this; }

		for( key in w ){
			// Check if key exists in with closure
			if( structKeyExists(w,key) ){

				// Verify if the key does not exist in incoming but it does in with, so default it
				if ( NOT structKeyExists(args,key) ){
					args[key] = w[key];
				}
				// If it does exist in the incoming arguments and simple value, then we prefix, complex values are ignored.
				else if ( isSimpleValue( args[key] ) AND NOT isBoolean( args[key] ) ){
					args[key] = w[key] & args[key];
				}

			}
		}

		args.$$withProcessed = true;

		return this;
	}

	/**
	 * Includes a routes configuration file as an added import and returns itself after import
	 * @location The include location of the routes configuration template. Do not add '.cfm'
	 */
	SES function includeRoutes( required location ){
		// verify .cfm or not
		if( listLast(arguments.location,".") NEQ "cfm" ){
			arguments.location &= ".cfm";
		}

		// We are ready to roll
		try{
			// Try to remove pathInfoProvider, just in case
			structdelete(variables,"pathInfoProvider");
			structdelete(this,"pathInfoProvider");
			// Import configuration
			include arguments.location;
		}
		catch(Any e){
			throw(message="Error importing routes configuration file: #e.message# #e.detail#", detail=e.tagContext.toString(), type="SES.IncludeRoutingConfig");
		}
		return this;
	}

    /**
     * Create all RESTful routes for a resource. It will provide automagic mappings between HTTP verbs and URLs to event handlers and actions.
     * By convention, the name of the resource maps to the name of the event handler.
     * @resource 		The name of the resource, a list of resources or an array of resources
     * @handler 		The handler for the route. Defaults to the resource name.
     * @parameterName 	The name of the id/parameter for the resource. Defaults to `id`.
     * @only 			Limit routes created with only this list or array of actions, e.g. "index,show"
     * @except 			Exclude routes with an except list or array of actions, e.g. "show"
     * @restful 		If true, then we will only create API based routes. It wil not create a /new and /edit route.
     * @module 			If passed, the module these resources will be attached to.
     * @namespace 		If passed, the namespace these resources will be attached to.
     */
    function resources(
        required resource,
        handler=arguments.resource,
        parameterName="id",
        only=[],
        except=[],
        boolean restful=false,
        string module="",
        string namespace=""
    ){
        if ( ! isArray( arguments.only ) ) {
            arguments.only = listToArray( arguments.only );
        }

        if ( ! isArray( arguments.except ) ) {
            arguments.except = listToArray( arguments.except );
        }

        // Inflate incoming resource if simple
        if( isSimpleValue( arguments.resource ) ){
        	arguments.resource = listToArray( arguments.resource );
        }

        var actionSet = {};

        // Register all resources
        for( var thisResource in arguments.resource ){
        	
        	// Edit Route, only if NON Restful
	        if( !arguments.restful ){
	        	actionSet = filterRouteActions( { GET = "edit" }, arguments.only, arguments.except );
		        if ( ! structIsEmpty( actionSet ) ) {
		            addRoute(
		            	pattern		= "/#thisResource#/:#arguments.parameterName#/edit",
		            	handler		= arguments.handler,
		            	action 		= actionSet,
		            	module 		= arguments.module,
		            	namespace	= arguments.namespace
		            );
		        }
			}

	        // New Route, only if NON Restful
	        if( !arguments.restful ){
		        actionSet = filterRouteActions( { GET = "new" }, arguments.only, arguments.except );
		        if ( ! structIsEmpty( actionSet ) ) {
		            addRoute(
		            	pattern		= "/#thisResource#/new",
		            	handler		= arguments.handler,
		            	action		= actionSet,
		            	module 		= arguments.module,
		            	namespace	= arguments.namespace
		            );
		        }
		    }

	        // update, delete and show routes
	        actionSet = filterRouteActions( 
	        	{ PUT = "update", PATCH = "update", POST = "update", DELETE = "delete", GET = "show" }, 
	        	arguments.only, 
	        	arguments.except 
	        );
	        if ( ! structIsEmpty( actionSet ) ) {
	            addRoute(
	            	pattern		= "/#thisResource#/:#arguments.parameterName#",
	            	handler		= arguments.handler,
	            	action 		= actionSet,
		            module 		= arguments.module,
		            namespace	= arguments.namespace
	            );
	        }
	        // Index + Creation
	        actionSet = filterRouteActions( { GET = "index", POST = "create" }, arguments.only, arguments.except );
	        if ( ! structIsEmpty( actionSet ) ) {
	            addRoute(
	            	pattern		= "/#thisResource#",
	            	handler		= arguments.handler,
	            	action 		= actionSet,
		            module 		= arguments.module,
		            namespace	= arguments.namespace
	            );
	        }
        }

        return this;
    }

	/**
	 * Adds a route to dispatch and returns itself.
	 * @pattern  The pattern to match against the URL.
	 * @handler The handler to execute if pattern matched.
	 * @action The action in a handler to execute if a pattern is matched.  This can also be a structure based on the HTTP method(GET,POST,PUT,DELETE). ex: {GET:'show', PUT:'update', DELETE:'delete', POST:'save'}
	 * @packageResolverExempt If this is set to true, then the interceptor will not try to do handler package resolving. Else a package will always be resolved. Only works if :handler is in a pattern
	 * @matchVariables A string of name-value pair variables to add to the request collection when this pattern matches. This is a comma delimmitted list. Ex: spaceFound=true,missingAction=onTest
	 * @view The view to dispatch if pattern matches.  No event will be fired, so handler,action will be ignored.
	 * @viewNoLayout If view is choosen, then you can choose to override and not display a layout with the view. Else the view renders in the assigned layout.
	 * @valuePairTranslation  Activate convention name value pair translations or not. Turned on by default
	 * @constraints A structure of regex constraint overrides for variable placeholders. The key is the name of the variable, the value is the regex to try to match.
	 * @module The module to add this route to
	 * @moduleRouting Called internally by addModuleRoutes to add a module routing route.
	 * @namespace The namespace to add this route to
	 * @namespaceRouting Called internally by addNamespaceRoutes to add a namespaced routing route.
	 * @ssl Makes the route an SSL only route if true, else it can be anything. If an ssl only route is hit without ssl, the interceptor will redirect to it via ssl
	 * @append Whether the route should be appended or pre-pended to the array. By default we append to the end of the array
	 * @response An HTML response string to send back or a closure to be executed that should return the response. The closure takes in a 'params' struct of all matched params and the string will be parsed with the named value pairs as ${param}
	 * @statusCode The HTTP status code to send to the browser response.
	 * @statusText Explains the HTTP status code sent to the browser response.
	 * @condition A closure or UDF to execute that MUST return true to use route if matched or false and continue.
	 */
	function addRoute(
		required string pattern,
		string handler,
		any action,
		boolean packageResolverExempt="false",
		string matchVariables,
		string view,
		boolean viewNoLayout="false",
		boolean valuePairTranslation="true",
		any constraints="",
		string module="",
		string moduleRouting="",
		string namespace="",
		string namespaceRouting="",
		boolean ssl="false",
		boolean append="true",
		any response,
		numeric statusCode,
		string statusText,
		any condition
	){
		var thisRoute = structNew();
		var thisPattern = "";
		var thisPatternParam = "";
		var arg = 0;
		var x = 1;
		var thisRegex = 0;
		var patternType = "";

		// process a with closure if not empty
		if( NOT structIsEmpty( variables.withClosure ) ){
			processWith( arguments );
		}

		// module closure
		if( len( variables.withModule ) ){ arguments.module = variables.withModule; }

		// Process all incoming arguments into the route to store
		for(arg in arguments){
			if( structKeyExists(arguments,arg) ){ thisRoute[arg] = arguments[arg]; }
		}

		// Cleanup Route: Add trailing / to make it easier to parse
		if( right(thisRoute.pattern,1) IS NOT "/" ){
			thisRoute.pattern = thisRoute.pattern & "/";
		}
		// Cleanup initial /, not needed if found.
		if( left(thisRoute.pattern,1) IS "/" ){
			if( thisRoute.pattern neq "/" ){
				thisRoute.pattern = right(thisRoute.pattern,len(thisRoute.pattern)-1);
			}
		}

		// Check if we have optional args by looking for a ?
		if( findnocase("?",thisRoute.pattern) AND NOT findNoCase("regex:",thisRoute.pattern) ){
			processRouteOptionals(thisRoute);
			return this;
		}

		// Process json constraints?
		thisRoute.constraints = structnew();
		// Check if implicit struct
		if( isStruct(arguments.constraints) ){
			thisRoute.constraints = arguments.constraints;
		}

		// Init the matching variables
		thisRoute.regexPattern = "";
		thisRoute.patternParams = arrayNew(1);

		// Check for / pattern
		if( len(thisRoute.pattern) eq 1){
			thisRoute.regexPattern = "/";
		}

		// Process the route as a regex pattern
		for(x=1; x lte listLen(thisRoute.pattern,"/");x=x+1){

			// Pattern and Pattern Param
			thisPattern = listGetAt(thisRoute.pattern,x,"/");
			thisPatternParam = replace(listFirst(thisPattern,"-"),":","");

			// Detect Optional Types
			patternType = "alphanumeric";
			if( findnoCase("-numeric",thisPattern) ){ patternType = "numeric"; }
			if( findnoCase("-alpha",thisPattern) ){ patternType = "alpha"; }
			// This is a prefix like above to match a param (creates rc variable)
			if( findNoCase("-regex:",thisPattern) ){ patternType = "regexParam"; }
			// This is a placeholder for static text in the route
			else if( findNoCase("regex:",thisPattern) ){ patternType = "regex"; }

			// Pattern Type Regex
			switch(patternType){
				// CUSTOM REGEX for static route parts
				case "regex" : {
					thisRegex = replacenocase(thisPattern,"regex:","");
					break;
				}
				// CUSTOM REGEX for route param
				case "regexParam" : {
					// Pull out Regex Pattern
					thisRegex = REReplace(thisPattern, ":.*?-regex:", "");
					// Add Route Param
					arrayAppend(thisRoute.patternParams,thisPatternParam);
					break;
				}
				// ALPHANUMERICAL OPTIONAL
				case "alphanumeric" : {
					if( find(":",thisPattern) ){
						thisRegex = "(" & REReplace(thisPattern,":(.[^-]*)","[^/]");
						// Check Digits Repetions
						if( find("{",thisPattern) ){
							thisRegex = listFirst(thisRegex,"{") & "{#listLast(thisPattern,"{")#)";
							arrayAppend(thisRoute.patternParams,replace(listFirst(thisPattern,"{"),":",""));
						}
						else{
							thisRegex = thisRegex & "+?)";
							arrayAppend(thisRoute.patternParams,thisPatternParam);
						}
						// Override Constraints with your own REGEX
						if( structKeyExists(thisRoute.constraints,thisPatternParam) ){
							thisRegex = thisRoute.constraints[thisPatternParam];
						}
					}
					else{
						thisRegex = thisPattern;
					}
					break;
				}
				// NUMERICAL OPTIONAL
				case "numeric" : {
					// Convert to Regex Pattern
					thisRegex = "(" & REReplace(thisPattern, ":.*?-numeric", "[0-9]");
					// Check Digits
					if( find("{",thisPattern) ){
						thisRegex = listFirst(thisRegex,"{") & "{#listLast(thisPattern,"{")#)";
					}
					else{
						thisRegex = thisRegex & "+?)";
					}
					// Add Route Param
					arrayAppend(thisRoute.patternParams,thisPatternParam);
					break;
				}
				// ALPHA OPTIONAL
				case "alpha" : {
					// Convert to Regex Pattern
					thisRegex = "(" & REReplace(thisPattern, ":.*?-alpha", "[a-zA-Z]");
					// Check Digits
					if( find("{",thisPattern) ){
						thisRegex = listFirst(thisRegex,"{") & "{#listLast(thisPattern,"{")#)";
					}
					else{
						thisRegex = thisRegex & "+?)";
					}
					// Add Route Param
					arrayAppend(thisRoute.patternParams,thisPatternParam);
					break;
				}
			} //end pattern type detection switch

			// Add Regex Created To Pattern
			thisRoute.regexPattern = thisRoute.regexPattern & thisRegex & "/";

		} // end looping of pattern optionals

		// Add it to the corresponding routing table
		// MODULES
		if( len( arguments.module ) ){
			// Append or PrePend
			if( arguments.append ){	ArrayAppend(getModuleRoutes( arguments.module ), thisRoute); }
			else{ arrayPrePend(getModuleRoutes( arguments.module ), thisRoute); }
		}
		// NAMESPACES
		else if( len( arguments.namespace ) ){
			// Append or PrePend
			if( arguments.append ){	arrayAppend( getNamespaceRoutes( arguments.namespace ), thisRoute); }
			else{ arrayPrePend( getNamespaceRoutes(arguments.namespace), thisRoute); }
		}
		// Default Routing Table
		else{
			// Append or PrePend
			if( arguments.append ){	ArrayAppend(variables.routes, thisRoute); }
			else{ arrayPrePend(variables.routes, thisRoute); }
		}

		return this;
	}

	/**
	 * Get a namespace routes array
	 * @namespace The namespace to get
	 */
	array function getNamespaceRoutes( required namespace ){
		if( structKeyExists( variables.namespaceRoutingTable, arguments.namespace ) ){
			return variables.namespaceRoutingTable[ arguments.namespace ];
		}
		throw(
			message = "Namespace routes for #arguments.namespace# do not exists",
			detail 	= "Loaded namespace routes are #structKeyList( variables.namespaceRoutingTable )#",
			type 	= "SES.InvalidNamespaceException"
		);
	}

	/**
	 * Remove a namespace's routing table and registration points and return itself
	 * @namespace The namespace to remove
	 */
	SES function removeNamespaceRoutes( required namespace ){
		var routeLen = arrayLen( variables.routes );

		// remove all namespace routes
		structDelete( variables.namespaceRoutingTable, arguments.namespace );
		// remove namespace routing entry points
		for( var x = routeLen; x gte 1; x=x-1 ){
			if( variables.routes[ x ].namespaceRouting eq arguments.namespace ){
				arrayDeleteAt( variables.routes, x );
			}
		}

		return this;
	}

	/**
	 * Remove a module's routing table and registration points and return itself
	 * @module The module to remove
	 */
	SES function removeModuleRoutes( required module ){
		var routeLen = arrayLen( variables.routes );

		// remove all module routes
		structDelete( variables.moduleRoutingTable, arguments.module );
		// remove module routing entry point
		for( var x = routeLen; x gte 1; x=x-1 ){
			if( variables.routes[ x ].moduleRouting eq arguments.module ){
				arrayDeleteAt( variables.routes, x );
			}
		}

		return this;
	}

	/**
	 * Get a module's routes array
	 * @module The module to get
	 */
	array function getModuleRoutes( required module ){
		if( structKeyExists( variables.moduleRoutingTable, arguments.module ) ){
			return variables.moduleRoutingTable[ arguments.module ];
		}
		throw(
			message = "Module routes for #arguments.module# do not exists",
			detail 	= "Loaded module routes are #structKeyList( variables.moduleRoutingTable )#",
			type 	= "SES.InvalidModuleException"
		);
	}

	/**
	 * The cgi element facade method
	 * @cgiElement The element to take from CGI
	 * @event The event object
	 */
	function getCGIElement( required cgiElement, required event ){
		// Allow a UDF to manipulate the CGI.PATH_INFO value
		// in advance of route detection.
		if( arguments.cgielement EQ 'path_info' AND structKeyExists( variables, 'PathInfoProvider' ) ){
			return pathInfoProvider( event=arguments.Event );
		}
		return CGI[ arguments.CGIElement ];
	}
	
	/**
	 * Figures out which route matches this request and returns a routed structure
	 * @action The action evaluated by path_info
	 * @event The event object
	 * @module Incoming module
	 * @namespace Incoming namespace
	 */
	function findRoute(
		required action,
		required event, 
		module="",
		namespace=""
	){
		var requestString 		 = arguments.action;
		var packagedRequestString = "";
		var match 				 = structNew();
		var foundRoute 			 = structNew();
		var params 				 = structNew();
		var key					 = "";
		var i 					 = 1;
		var x 					 = 1 ;
		var rc 					 = event.getCollection();
		var _routes 			 = variables.routes;
		var _routesLength 		 = arrayLen( _routes );
		var contextRouting		 = {};

		// Module call? Switch routes
		if( len(arguments.module) ){
			_routes = getModuleRoutes( arguments.module );
			_routesLength = arrayLen(_routes);
		}
		// Namespace Call? Switch routes
		else if( len(arguments.namespace) ){
			_routes = getNamespaceRoutes( arguments.namespace );
			_routesLength = arrayLen(_routes);
		}

		//Remove the leading slash
		if( len(requestString) GT 1 AND left(requestString,1) eq "/" ){
			requestString = right(requestString,len(requestString)-1);
		}
		// Add ending slash
		if( right(requestString,1) IS NOT "/" ){
			requestString = requestString & "/";
		}

		// Let's Find a Route, Loop over all the routes array
		for(i=1; i lte _routesLength; i=i+1){

			// Match The route to request String
			match = reFindNoCase(_routes[i].regexPattern,requestString,1,true);
			if( (match.len[1] IS NOT 0 AND getLooseMatching())
			     OR
			    (NOT getLooseMatching() AND match.len[1] IS NOT 0 AND match.pos[1] EQ 1) ){

				// Verify condition matching
				if( structKeyExists( _routes[ i ], "condition" ) AND NOT isSimpleValue( _routes[ i ].condition ) AND NOT _routes[ i ].condition(requestString) ){
					// Debug logging
					if( log.canDebug() ){
						log.debug("SES Route matched but condition closure did not pass: #_routes[ i ].toString()# on routed string: #requestString#");
					}
					// Condition did not pass, move to next route
					continue;
				}

				// Setup the found Route
				foundRoute = _routes[i];
				// Is this namespace routing?
				if( len(arguments.namespace) ){
					arguments.event.setValue(name="currentRoutedNamespace",value=arguments.namespace,private=true);
				}
				// Debug logging
				if( log.canDebug() ){
					log.debug("SES Route matched: #foundRoute.toString()# on routed string: #requestString#");
				}
				break;
			}

		}//end finding routes

		// Check if we found a route, else just return empty params struct
		if( structIsEmpty(foundRoute) ){
			if( log.canDebug() ){
				log.debug("No SES routes matched on routed string: #requestString#");
			}
			return params;
		}

		// SSL Checks
		if( foundRoute.ssl AND NOT event.isSSL() ){
			setNextEvent(URL=event.getSESBaseURL() & reReplace(cgi.path_info, "^\/", ""), ssl=true, statusCode=302, queryString=cgi.query_string);
		}

		// Check if the match is a module Routing entry point or a namespace entry point or not?
		if( len( foundRoute.moduleRouting ) OR len( foundRoute.namespaceRouting ) ){
			// build routing argument struct
			contextRouting = { action=reReplaceNoCase(requestString,foundRoute.regexpattern,""), event=arguments.event };
			// add module or namespace
			if( len( foundRoute.moduleRouting ) ){
				contextRouting.module = foundRoute.moduleRouting;
			}
			else{
				contextRouting.namespace = foundRoute.namespaceRouting;
			}

			// Try to Populate the params from the module pattern if any
			for(x=1; x lte arrayLen(foundRoute.patternParams); x=x+1){
				params[foundRoute.patternParams[x]] = mid(requestString, match.pos[x+1], match.len[x+1]);
			}

			// Save Found URL
			arguments.event.setValue(name="currentRoutedURL",value=requestString,private=true);
			// process context find
			structAppend(params, findRoute(argumentCollection=contextRouting), true);

			// Return if parameters found.
			if( NOT structIsEmpty(params) ){
				return params;
			}
		}

		// Save Found Route
		arguments.event.setValue(name="currentRoute",value=foundRoute.pattern,private=true);

		// Save Found URL if NOT Found already
		if( NOT arguments.event.valueExists(name="currentRoutedURL",private=true) ){
			arguments.event.setValue(name="currentRoutedURL",value=requestString,private=true);
		}

		// Do we need to do package resolving
		if( NOT foundRoute.packageResolverExempt ){
			// Resolve the packages
			packagedRequestString = packageResolver(requestString,foundRoute.patternParams,arguments.module);
			// reset pattern matching, if packages found.
			if( compare(packagedRequestString,requestString) NEQ 0 ){
				// Log package resolved
				if( log.canDebug() ){
					log.debug("SES Package Resolved: #packagedRequestString#");
				}
				// Return found Route recursively.
				return findRoute( action=packagedRequestString, event=arguments.event, module=arguments.module );
			}
		}

		// Populate the params, with variables found in the request string
		for(x=1; x lte arrayLen(foundRoute.patternParams); x=x+1){
			params[foundRoute.patternParams[x]] = mid(requestString, match.pos[x+1], match.len[x+1]);
		}

		// Process Convention Name-Value Pairs
		if( foundRoute.valuePairTranslation ){
			findConventionNameValuePairs(requestString,match,params);
		}

		// Now setup all found variables in the param struct, so we can return
		for(key in foundRoute){
			// Check that the key is not a reserved route argument and NOT already routed
			if( NOT listFindNoCase(variables.RESERVED_ROUTE_ARGUMENTS,key)
				AND NOT structKeyExists(params, key) ){
				params[key] = foundRoute[key];
			}
			else if (key eq "matchVariables"){
				for(i=1; i lte listLen(foundRoute.matchVariables); i = i+1){
					// Check if the key does not exist in the routed params yet.
					if( NOT structKeyExists(params, listFirst(listGetAt(foundRoute.matchVariables,i),"=") ) ){
						params[listFirst(listGetAt(foundRoute.matchVariables,i),"=")] = listLast(listGetAt(foundRoute.matchVariables,i),"=");
					}
				}
			}
		}

		return params;
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
			if( listFindNoCase( variables.validExtensions, extension ) ){
				// set the format request collection variable
				event.setValue( "format", extension );
				// debug logging
				if( log.canDebug() ){
					log.debug( "Extension: #extension# detected and set in rc.format" );
				}
				// remove it from the string and return string for continued parsing.
				return left( requestString, len( arguments.requestString ) - extensionLen - 1 );
			} else if( variables.throwOnInvalidExtension ){
				getUtil().throwInvalidHTTP(
					className 	= "SES",
					detail 		= "Invalid Request Format Extension Detected: #extension#. Valid extensions are: #variables.validExtensions#",
					statusText 	= "Invalid Requested Format Extension: #extension#",
					statusCode 	= "406"
				);
			}
		}
		// check accepts headers for the best match
		else{
			var match = "";
			for( var accept in listToArray( event.getHTTPHeader( "Accept", "" ), "," ) ){
				for( var extension in variables.validExtensions ){
					if( findNoCase( extension, accept ) > 0 ){
						match = extension;
						break;
					}
				}
				if( len( match ) ){
					break;
				}
			}

			if( len( match ) ){
				// if the user passed in format via the query string,
				// we'll assume that's the value they actually wanted.
				event.paramValue( 'format', lcase( match ) );
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

		// standardize status codes
		if( !structKeyExists( aRoute, "statusCode") ){ aRoute.statusCode = 200; }
		if( !structKeyExists( aRoute, "statusText") ){ aRoute.statusText = ""; }

		// simple values
		if( isSimpleValue( aRoute.response ) ){
			// setup default response
			theResponse = aRoute.response;
			// String replacements
			replacements = reMatchNoCase( "{[^{]+?}", aRoute.response );
			for( thisReplacement in replacements ){
				thisKey = reReplaceNoCase( thisReplacement, "({|})", "", "all" );
				if( event.valueExists( thisKey ) ){
					theResponse = replace( aRoute.response, thisReplacement, event.getValue( thisKey ), "all");
				}
			}

		}
		// Closure
		else{
			theResponse = aRoute.response( event.getCollection() );
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
		var routeParamsLen 	= arrayLen(arguments.routeParams);
		var rString 		= arguments.routingString;
		var returnString 	= arguments.routingString;
		var isModule		= len(arguments.module) GT 0;

		// Verify if we have a handler on the route params
		if( findnocase("handler", arrayToList(arguments.routeParams)) ){

			// Cleanup routing string to position of :handler
			for(x=1; x lte routeParamsLen; x=x+1){
				if( arguments.routeParams[x] neq "handler" ){
					rString = replace(rString,listFirst(rString,"/") & "/","");
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
			for(x=1; x lte listLen(rString,"/"); x=x+1){

				// Get Folder from first part of string
				thisFolder = listgetAt(rString,x,"/");

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
				returnString = replacenocase(returnString, replace( replace(newEvent,":","/","all") ,".","/","all"), newEvent);
			}
		}//end if handler found

		// Module Cleanup
		if( isModule ){
			return replaceNoCase(returnString, arguments.module & ":", "");
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
		  		rc[variables.eventName] NEQ variables.defaultEvent
		  		OR
		  		( structKeyExists( url, variables.eventName ) AND rc[ variables.eventName ] EQ variables.defaultEvent )
			)
		){

			//  New Pathing Calculations if not the default event. If default, relocate to the domain. 
			if ( rc[variables.eventName] != variables.defaultEvent ) {
				//  Clean for handler & Action 
				if ( StructKeyExists(rc, variables.eventName) ) {
					handler = reReplace(rc[variables.eventName],"\.[^.]*$","");
					action = ListLast( rc[variables.eventName], "." );
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
			if( NOT ListFindNoCase( "route,handler,action, #variables.eventName#" , key ) ){
				vars = ListAppend( vars, "#lcase( key )#=#rc[ key ]#", "&" );
			}
		}

		if( len( vars ) eq 0 ){
			return "";
		}

		return "?" & vars;
	}

	/**
	 * Clean up some IIS funkyness
	 * @requestString the incoming request string
	 * @rc The request collection struct
	 */
	private function fixIISURLVars( required requestString, required rc ){
		// Find a Matching position of IIS ?
		var varMatch = REFind( "\?.*=", arguments.requestString, 1, "TRUE" );
		if( varMatch.pos[ 1 ] ){
			// Copy values to the RC
			var qsValues 	= REreplacenocase( arguments.requestString, "^.*\?", "", "all" );
			var qsVal 		= 0;
			// loop and create
			for( var x=1; x lte listLen( qsValues, "&" ); x=x+1 ){
				qsVal = listGetAt( qsValues, x, "&" );
				if( listlen( qsVal, '=' ) > 1 ) {
					arguments.rc[ URLDecode( listFirst( qsVal, "=" ) ) ] = URLDecode( listLast( qsVal, "=" ) );
				} else {
					arguments.rc[ URLDecode( listFirst( qsVal, "=" ) ) ] = '';
				}
			}
			// Clean the request string
			arguments.requestString = Mid( arguments.requestString, 1, ( varMatch.pos[ 1 ] -1 ) );
		}

		return arguments.requestString;
	}

	/**
	 * Find the convention name value pairs
	 * @requestString the incoming request string
	 * @match The regex matcher object
	 * @params The incoming parameter struct
	 */
	private function findConventionNameValuePairs( required string requestString, required any match, required struct params ){
		//var leftOverLen = len(arguments.requestString)-(arguments.match.pos[arraylen(arguments.match.pos)]+arguments.match.len[arrayLen(arguments.match.len)]-1);
		var leftOverLen = len(arguments.requestString) - arguments.match.len[1];
		var conventionString = 0;
		var conventionStringLen = 0;
		var tmpVar = 0;
		var i = 1;

		if( leftOverLen gt 0 ){
			// Cleanup remaining string
			conventionString 	= right(arguments.requestString,leftOverLen).split("/");
			conventionStringLen = arrayLen(conventionString);

			// If conventions found, continue parsing
			for(i=1; i lte conventionStringLen; i=i+1){
				if( i mod 2 eq 0 ){
					// Even: Means Variable Value
					arguments.params[tmpVar] = conventionString[i];
				}
				else{
					// ODD: Means variable name
					tmpVar = trim(conventionString[i]);
					// Verify it is a valid variable Name
					if ( NOT isValid("variableName",tmpVar) ){
						tmpVar = "_INVALID_VARIABLE_NAME_POS_#i#_";
					}
					else{
						// Default Value of empty
						arguments.params[tmpVar] = "";
					}
				}
			}//end loop over pairs
		}//end if convention name value pairs

	}

	/**
	 * Get and Clean the path_info and script names structure
	 */
	private function getCleanedPaths( required rc, required event ){
		var items = structnew();

		// Get path_info & script name
		// Replace any duplicate slashes with 1 just in case
		items[ "pathInfo" ]		= trim( reReplace( getCGIElement( 'path_info', arguments.event ), "\/{2,}", "/", "all" ) );
		items[ "scriptName" ] 	= trim( reReplacenocase( getCGIElement( 'script_name', arguments.event ), "[/\\]index\.cfm", "" ) );

		// Clean ContextRoots
		if( len( getContextRoot() ) ){
			//items[ "pathInfo" ] 	= replacenocase(items[ "pathInfo" ],getContextRoot(),"");
			items[ "scriptName" ] = replacenocase( items[ "scriptName" ], getContextRoot(),"" );
		}

		// Clean up the path_info from index.cfm
		items[ "pathInfo" ] = trim( reReplacenocase( items[ "pathInfo" ], "^[/\\]index\.cfm", "" ) );
		// Clean the scriptname from the pathinfo if it is the first item in case this is a nested application
		if( len( items[ "scriptName" ] ) ){
			items["pathInfo"] = reReplaceNocase(items["pathInfo"], "^#items["scriptName"]#","");
		}

		// clean 1 or > / in front of route in some cases, scope = one by default
		items[ "pathInfo" ] = reReplaceNoCase( items[ "pathInfo" ], "^/+", "/" );

		// fix URL vars after ?
		items[ "pathInfo" ] = fixIISURLVars( items[ "pathInfo" ], arguments.rc );

		return items;
	}

	/**
	 * Process route optionals
	 * @thisRoute The route structure
	 */
	private function processRouteOptionals( required struct thisRoute ){
		var x=1;
		var thisPattern = 0;
		var base = "";
		var optionals = "";
		var routeList = "";

		// Parse our base & optionals
		for(x=1; x lte listLen(arguments.thisRoute.pattern,"/"); x=x+1){
			thisPattern = listgetAt(arguments.thisRoute.pattern,x,"/");
			// Check for ?
			if( not findnocase("?",thisPattern) ){
				base = base & thisPattern & "/";
			}
			else{
				optionals = optionals & replacenocase(thisPattern,"?","","all") & "/";
			}
		}
		// Register our routeList
		routeList = base & optionals;
		// Recurse and register in reverse order
		for(x=1; x lte listLen(optionals,"/"); x=x+1){
			// Create new route
			arguments.thisRoute.pattern = routeList;
			// Register route
			addRoute(argumentCollection=arguments.thisRoute);
			// Remove last bit
			routeList = listDeleteat(routeList,listlen(routeList,"/"),"/");
		}
		// Setup the base route again
		arguments.thisRoute.pattern = base;
		// Register the final route
		addRoute(argumentCollection=arguments.thisRoute);
	}

	/**
	 * Import the routing configuration file
	 */
	private function importConfiguration(){
		var appLocPrefix 	= "/";
		var configFilePath 	= "";
		var refLocal 		= structnew();
		var appMapping 		= getSetting('AppMapping');

		// Verify the config file, else set it to our convention in the config/Routes.cfm
		if( not propertyExists('configFile') ){
			setProperty('configFile','config/Routes.cfm');
		}

		//App location prefix
		if( len(appMapping) ){
			appLocPrefix = appLocPrefix & appMapping & "/";
		}

		// Setup the config Path for relative location first.
		configFilePath = appLocPrefix & reReplace(getProperty('ConfigFile'),"^/","");
		if( NOT fileExists(expandPath(configFilePath)) ){
			//Check absolute location as not found inside our app
			configFilePath = getProperty('ConfigFile');
			if( NOT fileExists(expandPath(configFilePath)) ){
				throw(message="Error locating routes file: #configFilePath#",type="SES.ConfigFileNotFound");
			}
		}

		// Include configuration
		includeRoutes( configFilePath );

		// Validate the base URL
		if ( len( getBaseURL() ) eq 0 ){
			throw('The baseURL property has not been defined. Please define it using the setBaseURL() method.','','interceptors.SES.invalidPropertyException');
		}
	}

	/**
	 * Get a ColdBox Utility object
	 */
	private function getUtil(){
		return new coldbox.system.core.util.Util();
	}


    /**
     * Get the correct route actions based on only and except lists
     * @initial The initial set of route actions
     * @only 	Limit actions with only
     * @except 	Exclude actions with except
     */
    private struct function filterRouteActions( required struct initial, array only = [], array except = [] ) {
        var actionSet = arguments.initial;

        if ( structKeyExists( arguments, "only" ) && ! isNull( arguments.only ) && ! arrayIsEmpty( arguments.only ) ) {
            actionSet = {};
            for( var HTTPVerb in arguments.initial ){
                var methodName = arguments.initial[ HTTPVerb ];
                for( var onlyAction in arguments.only ){
                    if ( compareNoCase( methodName, onlyAction ) == 0 ) {
                        structInsert( actionSet, HTTPVerb, onlyAction );
                    }
                }
            }
        }

        if ( structKeyExists( arguments, "except" ) && ! isNull( arguments.except ) && ! arrayIsEmpty( arguments.except ) ) {
            for( var HTTPVerb in arguments.initial ){
                var methodName = arguments.initial[ HTTPVerb ];
                for( var exceptAction in arguments.except ){
                    if ( compareNoCase( methodName, exceptAction ) == 0 ) {
                        structDelete( actionSet, HTTPVerb );
                    }
                }
            }   
        }

        return actionSet;
    }

}
