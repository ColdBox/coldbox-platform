/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Manages all the routing definitions for the application and exposes the
 * ColdBox Routing DSL
 */
component
	accessors="true"
	extends  ="coldbox.system.FrameworkSupertype"
	threadsafe
{

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
	 * Flag to enable unique or not URLs
	 */
	property
		name   ="uniqueURLS"
		type   ="boolean"
		default="false";

	/**
	 * Flag to enable/disable routing
	 */
	property
		name   ="enabled"
		type   ="boolean"
		default="true";

	/**
	 * Loose matching flag for regex matches
	 */
	property
		name   ="looseMatching"
		type   ="boolean"
		default="false";

	/**
	 * Detect extensions flag, so it can place a 'format' variable on the rc
	 */
	property
		name   ="extensionDetection"
		type   ="boolean"
		default="true";

	/**
	 * Throw an exception when extension detection is invalid or not
	 */
	property
		name   ="throwOnInvalidExtension"
		type   ="boolean"
		default="false";

	/**
	 * Initialize the valid extensions to detect
	 */
	property
		name   ="validExtensions"
		type   ="string"
		default="json,jsont,xml,cfm,cfml,html,htm,rss,pdf";

	/**
	 * Base routing URL
	 */
	property name="baseURL" type="string";

	/**
	 * This flag denotes if full URL rewrites are enabled or not. Meaning if the `index.cfm` is in the path of the rewriter or not.
	 * The default value is **false**.
	 */
	property
		name   ="fullRewrites"
		type   ="boolean"
		default="false";

	/**
	 * This flag denotes that the routing service will discover the incoming base URL from the host + ssl + environment.
	 * If off, then it will use whatever the base URL was set in the router.
	 */
	property
		name   ="multiDomainDiscovery"
		type   ="boolean"
		default="true";


	/**
	 * ColdBox Controller
	 */
	property name="controller";

	/**
	 * Fluent route construct
	 */
	property name="thisRoute" type="struct";

	/**
	 * Fluent route construct for modules
	 */
	property name="thisModule" type="string";

	/**
	 * Fluent route construct for with routing
	 */
	property name="withClosure" type="struct";

	/**
	 * Constructor
	 *
	 * @controller The ColdBox controller linkage
	 * @controller.inject coldbox
	 */
	function init( required controller ){
		// Setup Internal Work Objects
		variables.controller = arguments.controller;
		variables.wirebox    = arguments.controller.getWireBox();
		variables.cachebox   = arguments.controller.getCacheBox();
		variables.logBox     = arguments.controller.getLogBox();
		variables.log        = variables.logBox.getLogger( this );
		variables.flash      = arguments.controller.getRequestService().getFlashScope();

		/************************************** FLUENT CONSTRUCTS *********************************************/

		// With closure
		variables.withClosure = {};
		// Module closure
		variables.thisModule  = "";
		// Groupt Pivot
		variables.onGroup     = false;
		// Routing pointer
		variables.thisRoute   = initRouteDefinition();

		/************************************** CONSTANTS *********************************************/

		// STATIC Valid Extensions
		variables.VALID_EXTENSIONS = "json,jsont,xml,cfm,cfml,html,htm,rss,pdf";

		/************************************** ROUTING DEFAULTS: Due to ACF11 Bugs on Properties *********************************************/

		// Main routes Routing Table
		variables.routes                  = [];
		// Module Routing Table
		variables.moduleRoutingTable      = {};
		// Namespaces Routing Table
		variables.namespaceRoutingTable   = {};
		// Loose matching flag for regex matches
		variables.looseMatching           = false;
		// Flag to enable unique or not URLs
		variables.uniqueURLs              = false;
		// Enable the interceptor by default
		variables.enabled                 = true;
		// Detect extensions flag, so it can place a 'format' variable on the rc
		variables.extensionDetection      = true;
		// Throw an exception when extension detection is invalid or not
		variables.throwOnInvalidExtension = false;
		// Initialize the valid extensions to detect
		variables.validExtensions         = variables.VALID_EXTENSIONS;
		// Initialize the base URL as empty in case the user overrides it in their own router.
		variables.baseUrl                 = "";
		// Are full rewrites enabled
		variables.fullRewrites            = false;
		variables.multiDomainDiscovery    = true;

		return this;
	}


	/**
	 * This method is to be implemented by the application router you create.
	 * This is where you will define all your routing.
	 */
	function configure(){
	}

	/**
	 * This method is called by the Routing Services to make sure the router is ready for operation.
	 * This is ONLY called by the routing services and only ONCE in the Application Life-Cycle
	 */
	function startup(){
		// Verify baseUrl is still empty to default it for operation
		if ( !len( variables.baseUrl ) ) {
			variables.baseUrl = composeRoutingUrl();
		}

		// Check if rewrites turned off. If so, append the `index.cfm` to it.
		if ( !variables.fullRewrites AND !findNoCase( "index.cfm", variables.baseURL ) ) {
			variables.baseURL &= "/index.cfm";
		}

		// Remove any double slashes: sometimes proxies can interfere
		variables.baseURL = reReplace( variables.baseURL, "\/\/$", "/", "all" );

		// Save the base URIs and Paths in the application settings
		variables.controller
			.setSetting( "SESBaseURL", variables.baseURL )
			.setSetting( "SESBasePath", composeRoutingPath() )
			.setSetting( "HTMLBaseURL", replaceNoCase( variables.baseURL, "index.cfm", "" ) )
			.setSetting( "HTMLBasePath", replaceNoCase( composeRoutingPath(), "index.cfm", "" ) );
	}

	/**
	 * A quick snapshot of the router state
	 */
	struct function getMemento(){
		return variables.filter( function( k, v ){
			return ( !isCustomFunction( v ) && !isObject( v ) );
		} );
	}

	/**
	 * Verifies if an extension is valid in the Router
	 * @extension The extension to validate
	 */
	boolean function isValidExtension( required extension ){
		return variables.validExtensions.listFindNoCase( arguments.extension ) > 0;
	}

	/**
	 * @deprecated Please use `getModuleRoutingTable()` instead.
	 * A quick ColdBox4 compatibility wrapper
	 */
	struct function getModulesRoutingTable(){
		return getModuleRoutingTable();
	}

	/****************************************************************************************************************************/
	// DEPRECATED FUNCTIONALITY: Remove in later release

	/**
	 * @deprecated Please use the Routes.cfc approach instead
	 *
	 * Includes a routes configuration file as an added import and returns itself after import
	 *
	 * @location The include location of the routes configuration template. Do not add '.cfm'
	 *
	 * @return Router
	 */
	function includeRoutes( required location ){
		// verify .cfm or not
		if ( listLast( arguments.location, "." ) NEQ "cfm" ) {
			arguments.location &= ".cfm";
		}

		// We are ready to roll
		try {
			// Try to remove pathInfoProvider, just in case
			structDelete( variables, "pathInfoProvider" );
			structDelete( this, "pathInfoProvider" );
			// Import configuration
			include arguments.location;
		} catch ( Any e ) {
			throw(
				message = "Error importing routes configuration file: #e.message# #e.detail#",
				detail  = e.tagContext.toString(),
				type    = "SES.IncludeRoutingConfig"
			);
		}
		return this;
	}

	/****************************************************************************************************************************/
	// CF-11/2016 include .cfm template can't access the methods which are only declare as property... (hack) have to create setter/getter methods
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
	function setValidExtensions( required extensions ){
		variables.validExtensions = arguments.extensions;
	}
	function setFullRewrites( boolean target ){
		variables.fullRewrites = arguments.target;
		return this;
	}
	function getFullRewrites(){
		return variables.fullRewrites;
	}
	function setMultiDomainDiscovery( boolean target ){
		variables.multiDomainDiscovery = arguments.target;
		return this;
	}
	function getMultiDomainDiscovery(){
		return variables.multiDomainDiscovery;
	}

	/****************************************************************************************************************************/
	/* 											ROUTING TABLE METHODS															*/
	/****************************************************************************************************************************/

	/**
	 * Register modules routes in the specified position in the main routing table, and returns itself
	 * @pattern The pattern to match against the URL
	 * @module The module to load routes for
	 * @append Whether the module entry point route should be appended or pre-pended to the main routes array. By default we append to the end of the array
	 *
	 * @return Router
	 */
	function addModuleRoutes(
		required pattern,
		required module,
		boolean append = true
	){
		var mConfig = variables.controller.getSetting( "modules" );

		// Verify module exists and loaded
		if ( NOT structKeyExists( mConfig, arguments.module ) ) {
			throw(
				message = "Error loading module routes as the module requested '#arguments.module#' is not loaded.",
				detail  = "The loaded modules are: #structKeyList( mConfig )#",
				type    = "SES.InvalidModuleName"
			);
		}

		// Create the module routes container if it does not exist already
		if ( NOT structKeyExists( variables.moduleRoutingTable, arguments.module ) ) {
			variables.moduleRoutingTable[ arguments.module ] = [];
		}

		// Store the entry point for the module routes.
		addRoute(
			pattern       = arguments.pattern,
			moduleRouting = arguments.module,
			append        = arguments.append
		);

		// Process module resources
		mConfig
			.find( arguments.module )
			.resources
			.each( function( item ){
				item.module = module;
				resources( argumentCollection = item );
			} );

		// Process module routes
		mConfig
			.find( arguments.module )
			.routes
			.each( function( item ){
				if ( isSimpleValue( item ) ) {
					// prepare module pivot
					variables.thisModule = module;
					// Include it via conventions using declared route
					includeRoutes( location = mConfig[ module ].mapping & "/" & item );
					// Remove pivot
					variables.thisModule = "";
				} else {
					item.module = module;
					addRoute( argumentCollection = item );
				}
			} );

		return this;
	}

	/**
	 * Remove a module's routing table and registration points and return itself
	 * @module The module to remove
	 *
	 * @return Router
	 */
	function removeModuleRoutes( required module ){
		// remove all module routes
		structDelete( variables.moduleRoutingTable, arguments.module );
		// remove module routing entry point
		variables.routes = variables.routes.filter( function( item ){
			return ( item.moduleRouting != module );
		} );

		return this;
	}

	/**
	 * Get a module's routes array
	 * @module The module to get
	 */
	array function getModuleRoutes( required module ){
		if ( structKeyExists( variables.moduleRoutingTable, arguments.module ) ) {
			return variables.moduleRoutingTable[ arguments.module ];
		}
		throw(
			message = "Module routes for #arguments.module# do not exists",
			detail  = "Loaded module routes are #structKeyList( variables.moduleRoutingTable )#",
			type    = "SES.InvalidModuleException"
		);
	}

	/**
	 * Register a namespace in the specified position in the main routing table, and returns itself
	 * @pattern The pattern to match against the URL.
	 * @namespace The name of the namespace to register
	 * @append Whether the route should be appended or pre-pended to the array. By default we append to the end of the array
	 *
	 * @return Router
	 */
	function addNamespace(
		required pattern,
		required namespace,
		boolean append = "true"
	){
		// Create the namespace routes container if it does not exist already, as we could create many patterns that point to the same namespace
		if ( NOT structKeyExists( variables.namespaceRoutingTable, arguments.namespace ) ) {
			variables.namespaceRoutingTable[ arguments.namespace ] = [];
		}

		// Store the entry point for the namespace
		addRoute(
			pattern          = arguments.pattern,
			namespaceRouting = arguments.namespace,
			append           = arguments.append
		);

		return this;
	}

	/**
	 * Get a namespace routes array
	 * @namespace The namespace to get
	 */
	array function getNamespaceRoutes( required namespace ){
		if ( structKeyExists( variables.namespaceRoutingTable, arguments.namespace ) ) {
			return variables.namespaceRoutingTable[ arguments.namespace ];
		}

		throw(
			message = "Namespace routes for #arguments.namespace# do not exists",
			detail  = "Loaded namespace routes are #structKeyList( variables.namespaceRoutingTable )#",
			type    = "SES.InvalidNamespaceException"
		);
	}

	/**
	 * Remove a namespace's routing table and registration points and return itself
	 * @namespace The namespace to remove
	 *
	 * @return Router
	 */
	function removeNamespaceRoutes( required namespace ){
		// remove all namespace routes
		structDelete( variables.namespaceRoutingTable, arguments.namespace );

		// remove namespace routing entry points
		variables.routes = variables.routes.filter( function( item ){
			return ( item.namespaceRouting != namespace );
		} );

		return this;
	}

	/****************************************************************************************************************************/
	/* 											ROUTE REGISTRATION METHODS														*/
	/****************************************************************************************************************************/

	/**
	 * @deprecated This has been deprecated in favor of the <code>group()</code> function.
	 *
	 * Starts a with closure, where all arguments will be prefixed for the next concatenated addRoute() methods until an endWith() is called
	 *
	 * @pattern The pattern to match against the URL.
	 * @handler The handler to execute if pattern matched.
	 * @action The action in a handler to execute if a pattern is matched.  This can also be a structure based on the HTTP method(GET,POST,PUT,DELETE). ex: {GET:'show', PUT:'update', DELETE:'delete', POST:'save'}
	 * @packageResolverExempt If this is set to true, then the interceptor will not try to do handler package resolving. Else a package will always be resolved. Only works if :handler is in a pattern
	 * @matchVariables A string of name-value pair variables to add to the request collection when this pattern matches. This is a comma delimited list. Ex: spaceFound=true,missingAction=onTest
	 * @view The view to dispatch if pattern matches.  No event will be fired, so handler,action will be ignored.
	 * @viewNoLayout If view is chosen, then you can choose to override and not display a layout with the view. Else the view renders in the assigned layout.
	 * @valuePairTranslation Activate convention name value pair translations or not. Turned on by default
	 * @constraints A structure of regex constraint overrides for variable placeholders. The key is the name of the variable, the value is the regex to try to match.
	 * @module The module to add this route to
	 * @moduleRouting Called internally by addModuleRoutes to add a module routing route.
	 * @namespace The namespace to add this route to
	 * @namespaceRouting Called internally by addNamespaceRoutes to add a namespaced routing route.
	 * @ssl Makes the route an SSL only route if true, else it can be anything. If an ssl only route is hit without ssl, the interceptor will redirect to it via ssl
	 * @append Whether the route should be appended or pre-pended to the array. By default we append to the end of the array
	 * @domain The domain to match, including wildcards
	 *
	 * @return Router
	 */
	function with(
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
		boolean append,
		string domain
	){
		// set the withClosure
		variables.withClosure.append( arguments );
		return this;
	}

	/**
	 * @deprecated This has been deprecated in favor of the <code>group()</code> function.
	 *
	 * End a with closure and returns itself
	 *
	 * @return Router
	 */
	function endWith(){
		variables.withClosure = {};
		return this;
	}

	/**
	 * process a with closure
	 *
	 * @args The arguments to process
	 *
	 * @return Router
	 */
	function processWith( required args ){
		// only process arguments once per addRoute() call.
		if ( structKeyExists( arguments.args, "$$withProcessed" ) ) {
			return this;
		}

		variables.withClosure
			.filter( function( key, value ){
				return !isNull( arguments.value );
			} )
			.each( function( key, value ){
				// Verify if the key does not exist in incoming but it does in with, so default it
				if ( NOT structKeyExists( args, key ) ) {
					args[ key ] = value;
				}
				// If it does exist in the incoming arguments and simple value, then we prefix, complex values are ignored.
				else if ( isSimpleValue( args[ key ] ) AND NOT isBoolean( args[ key ] ) ) {
					args[ key ] = value & args[ key ];
				}
			} );

		args.$$withProcessed = true;

		return this;
	}

	/**
	 * This is the new approach to the <code>with</code> closure approach which has been marked as deprecated.
	 * You can pass any route option via the <code>options</code> structure and those values will be prefixed against
	 * any routing values done within the <code>body</code> closure.
	 *
	 * <pre>
	 * group( { pattern="/api", target="api", handler="api" }, function( options ){
	 * 	route( "/", "main.index" );
	 *  route( "/echo", "echo" );
	 * 	route( "/users/:id" ).withAction( { get : "index", post : "save" } ).toHandler( "users" );
	 * } )
	 * </pre>
	 *
	 * @options The route options that match routing, look at the <code>addRoute()</code> method
	 * @body The closure or lambda to contain all the routing methods to be grouped with the options data.
	 */
	function group( struct options = {}, body ){
		// Mark the group
		variables.onGroup = true;

		// set the withClosure
		variables.withClosure.append( arguments.options );
		// Execute the body
		arguments.body( arguments.options );

		// Pivot out of the group and do cleanup
		variables.onGroup     = false;
		variables.withClosure = {};

		return this;
	}

	/**
	 * Create all RESTful routes for a resource. It will provide automagic mappings between HTTP verbs and URLs to event handlers and actions.
	 * By convention, the name of the resource maps to the name of the event handler.
	 * Example: `resource = photos` Then we will create the following routes:
	 * - `/photos` : `GET` -> `photos.index` Display a list of photos
	 * - `/photos/new` : `GET` -> `photos.new` Returns an HTML form for creating a new photo
	 * - `/photos` : `POST` -> `photos.create` Create a new photo
	 * - `/photos/:id` : `GET` -> `photos.show` Display a specific photo
	 * - `/photos/:id/edit` : `GET` -> `photos.edit` Return an HTML form for editing a photo
	 * - `/photos/:id` : `PUT/PATCH` -> `photos.update` Update a specific photo
	 * - `/photos/:id` : `DELETE` -> `photos.delete` Delete a specific photo
	 *
	 * @resource The name of a single resource or a list of resources or an array of resources
	 * @handler The handler for the route. Defaults to the resource name.
	 * @parameterName The name of the id/parameter for the resource. Defaults to `id`.
	 * @only Limit routes created with only this list or array of actions, e.g. "index,show"
	 * @except Exclude routes with an except list or array of actions, e.g. "show"
	 * @module If passed, the module these resources will be attached to.
	 * @namespace If passed, the namespace these resources will be attached to.
	 * @pattern If passed, the actual URL pattern to use, else it defaults to `/#arguments.resource#` the name of the resource.
	 * @meta A struct of metadata to store with ALL the routes created from this resource
	 */
	function resources(
		required resource,
		handler,
		parameterName    = "id",
		only             = [],
		except           = [],
		string module    = "",
		string namespace = "",
		string pattern   = "",
		struct meta      = {}
	){
		// Inflate incoming arguments if not arrays
		if ( !isArray( arguments.only ) ) {
			arguments.only = listToArray( arguments.only );
		}
		if ( !isArray( arguments.except ) ) {
			arguments.except = listToArray( arguments.except );
		}
		if ( isSimpleValue( arguments.resource ) ) {
			arguments.resource = listToArray( arguments.resource );
		}

		var actionSet = {};

		// Register all resources
		for ( var thisResource in arguments.resource ) {
			// Default pattern or look at the incoming pattern sent?
			var thisPattern = ( len( arguments.pattern ) ? arguments.pattern : "/#thisResource#" );

			// Edit Routes
			actionSet = filterRouteActions(
				{ GET : "edit" },
				arguments.only,
				arguments.except
			);
			if ( !structIsEmpty( actionSet ) ) {
				addRoute(
					pattern  : "#thisPattern#/:#arguments.parameterName#/edit",
					handler  : isNull( arguments.handler ) ? thisResource : arguments.handler,
					action   : actionSet,
					module   : arguments.module,
					namespace: arguments.namespace,
					meta     : arguments.meta
				);
			}

			// New Routes
			actionSet = filterRouteActions(
				{ GET : "new" },
				arguments.only,
				arguments.except
			);
			if ( !structIsEmpty( actionSet ) ) {
				addRoute(
					pattern  : "#thisPattern#/new",
					handler  : isNull( arguments.handler ) ? thisResource : arguments.handler,
					action   : actionSet,
					module   : arguments.module,
					namespace: arguments.namespace,
					meta     : arguments.meta
				);
			}

			// update, delete and show routes
			actionSet = filterRouteActions(
				{
					PUT    : "update",
					PATCH  : "update",
					DELETE : "delete",
					GET    : "show"
				},
				arguments.only,
				arguments.except
			);
			if ( !structIsEmpty( actionSet ) ) {
				addRoute(
					pattern  : "#thisPattern#/:#arguments.parameterName#",
					handler  : isNull( arguments.handler ) ? thisResource : arguments.handler,
					action   : actionSet,
					module   : arguments.module,
					namespace: arguments.namespace,
					meta     : arguments.meta
				);
			}

			// Index + Creation
			actionSet = filterRouteActions(
				{ GET : "index", POST : "create" },
				arguments.only,
				arguments.except
			);
			if ( !structIsEmpty( actionSet ) ) {
				addRoute(
					pattern  : "#thisPattern#",
					handler  : isNull( arguments.handler ) ? thisResource : arguments.handler,
					action   : actionSet,
					module   : arguments.module,
					namespace: arguments.namespace,
					meta     : arguments.meta
				);
			}
		}

		return this;
	}

	/**
	 * Adds a route to dispatch and returns itself.
	 *
	 * @pattern  The pattern to match against the URL.
	 * @handler The handler to execute if pattern matched.
	 * @action The action in a handler to execute if a pattern is matched.  This can also be a structure based on the HTTP method(GET,POST,PUT,DELETE). ex: {GET:'show', PUT:'update', DELETE:'delete', POST:'save'}
	 * @packageResolverExempt If this is set to true, then the interceptor will not try to do handler package resolving. Else a package will always be resolved. Only works if :handler is in a pattern
	 * @matchVariables DEPRECATED: Use RC or PRC structs instead. A string of name-value pair variables to add to the request collection when this pattern matches. This is a comma delimited list. Ex: spaceFound=true,missingAction=onTest
	 * @view The view to dispatch if pattern matches.  No event will be fired, so handler,action will be ignored.
	 * @viewNoLayout If view is chosen, then you can choose to override and not display a layout with the view. Else the view renders in the assigned layout.
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
	 * @name The name of the route
	 * @domain The domain to match, including wildcards
	 * @redirect If used, then the route will dispatch a relocation to this value as the new route using the `statuCode` default of 301 (Permanent) or if you define a `statusCode` we will use that.
	 * @event The event to execute if route matches
	 * @verbs The allowed HTTP Verbs for the route
	 * @layout The view layout to use
	 * @headers The HTTP headers to attach to the response if route matches
	 * @rc The RC name value pairs to attach if the response matches
	 * @prc The PRC name value pairs to attach if the response matches
	 * @viewModule The module the view belongs to
	 * @layoutModule The module the layout belongs to
	 * @meta Additional metadata to add to the incoming route
	 *
	 * @return SES
	 */
	function addRoute(
		required string pattern,
		string handler                = "",
		any action                    = "",
		boolean packageResolverExempt = "false",
		string matchVariables         = "",
		string view                   = "",
		boolean viewNoLayout          = "false",
		boolean valuePairTranslation  = "true",
		any constraints               = structNew(),
		string module                 = "",
		string moduleRouting          = "",
		string namespace              = "",
		string namespaceRouting       = "",
		boolean ssl                   = "false",
		boolean append                = "true",
		any response                  = "",
		numeric statusCode            = 200,
		string statusText             = "",
		any condition                 = "",
		string name                   = "",
		string domain                 = "",
		redirect                      = "",
		string event                  = "",
		string verbs                  = "",
		string layout                 = "",
		struct headers                = {},
		struct rc                     = {},
		struct prc                    = {},
		string viewModule             = "",
		string layoutModule           = "",
		struct meta                   = {}
	){
		// The route construct we will save
		var thisRoute = {};
		var thisRegex = 0;

		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() && !variables.onGroup ) {
			processWith( arguments );
		}

		// module pivot point
		if ( len( variables.thisModule ) ) {
			arguments.module = variables.thisModule;
		}

		// Process all incoming arguments into the route to store
		thisRoute.append( arguments );

		// Cleanup Route: Add trailing / to make it easier to parse
		if ( right( thisRoute.pattern, 1 ) IS NOT "/" ) {
			thisRoute.pattern = thisRoute.pattern & "/";
		}

		// Cleanup initial /, not needed if found.
		if ( left( thisRoute.pattern, 1 ) IS "/" ) {
			if ( thisRoute.pattern neq "/" ) {
				thisRoute.pattern = right( thisRoute.pattern, len( thisRoute.pattern ) - 1 );
			}
		}

		// Check for existing route matches
		var matchingRoutes = variables.routes.filter( function( route ){
			return (
				// Always register a new route when a condition is specified on either route
				isSimpleValue( thisRoute.condition ) && isSimpleValue( route.condition )
				&&
				route.pattern == thisRoute.pattern
				&&
				route.domain == thisRoute.domain
				&&
				route.module == thisRoute.module
				&&
				route.namespace == thisRoute.namespace
			);
		} );
		if ( !matchingRoutes.isEmpty() ) {
			var matchingRoute   = matchingRoutes[ 1 ];
			// collect action:
			var actions         = {};
			var matchingActions = isStruct( matchingRoute.action ) ? matchingRoute.action : {};
			structAppend( actions, matchingActions, true );
			for ( var verb in matchingRoute.verbs ) {
				structInsert( actions, verb, matchingRoute.event );
			}
			var thisRouteActions = isStruct( thisRoute.action ) ? thisRoute.action : {};
			structAppend( actions, thisRouteActions, true );
			for ( var verb in thisRoute.verbs ) {
				structInsert( actions, verb, thisRoute.event );
			}
			matchingRoute.action = actions;
			matchingRoute.verbs  = "";
			return this;
		}

		// Check if we have optional args by looking for a ?
		if ( findNoCase( "?", thisRoute.pattern ) AND NOT findNoCase( "regex:", thisRoute.pattern ) ) {
			processRouteOptionals( thisRoute );
			return this;
		}

		// Init the matching variables and pattern parameters
		thisRoute[ "regexPattern" ]  = "";
		thisRoute[ "patternParams" ] = [];

		// Check for / pattern
		if ( len( thisRoute.pattern ) eq 1 ) {
			thisRoute.regexPattern = "/";
		}

		// Process the route as a regex pattern
		for ( var x = 1; x lte listLen( thisRoute.pattern, "/" ); x++ ) {
			// Pattern and Pattern Param
			var thisPattern      = listGetAt( thisRoute.pattern, x, "/" );
			var thisPatternParam = replace( listFirst( thisPattern, "-" ), ":", "" );

			// Detect Optional Types
			var patternType = "alphanumeric";
			if ( findNoCase( "-numeric", thisPattern ) ) {
				patternType = "numeric";
			}
			if ( findNoCase( "-alpha", thisPattern ) ) {
				patternType = "alpha";
			}
			if ( findNoCase( "-regex:", thisPattern ) ) {
				patternType = "regexParam";
			} else if ( findNoCase( "regex:", thisPattern ) ) {
				patternType = "regex";
			}

			// Pattern Type Regex
			switch ( patternType ) {
				// CUSTOM REGEX for static route parts
				case "regex": {
					thisRegex = replaceNoCase( thisPattern, "regex:", "" );
					break;
				}

				// CUSTOM REGEX for route param
				case "regexParam": {
					// Pull out Regex Pattern
					thisRegex = reReplace( thisPattern, ":.*?-regex:", "" );
					// Add Route Param
					arrayAppend( thisRoute.patternParams, thisPatternParam );
					break;
				}

				// ALPHANUMERICAL OPTIONAL
				case "alphanumeric": {
					if ( find( ":", thisPattern ) ) {
						thisRegex = "(" & reReplace( thisPattern, ":(.[^-]*)", "[^/]" );
						// Check Digits Repetions
						if ( find( "{", thisPattern ) ) {
							thisRegex = listFirst( thisRegex, "{" ) & "{#listLast( thisPattern, "{" )#)";
							arrayAppend( thisRoute.patternParams, replace( listFirst( thisPattern, "{" ), ":", "" ) );
						} else {
							thisRegex = thisRegex & "+?)";
							arrayAppend( thisRoute.patternParams, thisPatternParam );
						}
						// Override Constraints with your own REGEX
						if ( structKeyExists( thisRoute.constraints, thisPatternParam ) ) {
							thisRegex = thisRoute.constraints[ thisPatternParam ];
						}
					} else {
						thisRegex = thisPattern;
					}
					break;
				}

				// NUMERICAL OPTIONAL
				case "numeric": {
					// Convert to Regex Pattern
					thisRegex = "(" & reReplace( thisPattern, ":.*?-numeric", "[0-9]" );
					// Check Digits
					if ( find( "{", thisPattern ) ) {
						thisRegex = listFirst( thisRegex, "{" ) & "{#listLast( thisPattern, "{" )#)";
					} else {
						thisRegex = thisRegex & "+?)";
					}
					// Add Route Param
					arrayAppend( thisRoute.patternParams, thisPatternParam );
					break;
				}

				// ALPHA OPTIONAL
				case "alpha": {
					// Convert to Regex Pattern
					thisRegex = "(" & reReplace( thisPattern, ":.*?-alpha", "[a-zA-Z]" );
					// Check Digits
					if ( find( "{", thisPattern ) ) {
						thisRegex = listFirst( thisRegex, "{" ) & "{#listLast( thisPattern, "{" )#)";
					} else {
						thisRegex = thisRegex & "+?)";
					}
					// Add Route Param
					arrayAppend( thisRoute.patternParams, thisPatternParam );
					break;
				}
			}
			// end pattern type detection switch

			// Add Regex Created To Pattern
			thisRoute.regexPattern = thisRoute.regexPattern & thisRegex & "/";
		}
		// end looping of pattern optionals

		// Process Sub-Domain Routing
		thisRoute[ "domainParams" ] = [];
		thisRoute[ "regexDomain" ]  = "^";
		if ( structKeyExists( thisRoute, "domain" ) ) {
			// Process the route as a regex pattern
			for ( var x = 1; x lte listLen( thisRoute.domain, "." ); x++ ) {
				// Pattern and Pattern Param
				var thisDomain      = listGetAt( thisRoute.domain, x, "." );
				var thisDomainParam = replace( listFirst( thisDomain, "-" ), ":", "" );

				// Detect Optional Types
				patternType = "alphanumeric";
				if ( findNoCase( "-numeric", thisDomain ) ) {
					patternType = "numeric";
				}
				if ( findNoCase( "-alpha", thisDomain ) ) {
					patternType = "alpha";
				}
				// This is a prefix like above to match a param (creates rc variable)
				if ( findNoCase( "-regex:", thisDomain ) ) {
					patternType = "regexParam";
				}
				// This is a placeholder for static text in the route
				else if ( findNoCase( "regex:", thisDomain ) ) {
					patternType = "regex";
				}

				// Pattern Type Regex
				switch ( patternType ) {
					// CUSTOM REGEX for static route parts
					case "regex": {
						thisRegex = replaceNoCase( thisDomain, "regex:", "" );
						break;
					}
					// CUSTOM REGEX for route param
					case "regexParam": {
						// Pull out Regex Pattern
						thisRegex = reReplace( thisDomain, ":.*?-regex:", "" );
						// Add Route Param
						arrayAppend( thisRoute.domainParams, thisDomainParam );
						break;
					}
					// ALPHANUMERICAL OPTIONAL
					case "alphanumeric": {
						if ( find( ":", thisDomain ) ) {
							thisRegex = "(" & reReplace( thisDomain, ":(.[^-]*)", "[^\/\.]" );
							// Check Digits Repetions
							if ( find( "{", thisDomain ) ) {
								thisRegex = listFirst( thisRegex, "{" ) & "{#listLast( thisDomain, "{" )#)";
								arrayAppend( thisRoute.domainParams, replace( listFirst( thisDomain, "{" ), ":", "" ) );
							} else {
								thisRegex = thisRegex & "+?)";
								arrayAppend( thisRoute.domainParams, thisDomainParam );
							}
							// Override Constraints with your own REGEX
							if ( structKeyExists( thisRoute.constraints, thisDomainParam ) ) {
								thisRegex = thisRoute.constraints[ thisDomainParam ];
							}
						} else {
							thisRegex = thisDomain;
						}
						break;
					}
					// NUMERICAL OPTIONAL
					case "numeric": {
						// Convert to Regex Pattern
						thisRegex = "(" & reReplace( thisDomain, ":.*?-numeric", "[0-9]" );
						// Check Digits
						if ( find( "{", thisDomain ) ) {
							thisRegex = listFirst( thisRegex, "{" ) & "{#listLast( thisDomain, "{" )#)";
						} else {
							thisRegex = thisRegex & "+?)";
						}
						// Add Route Param
						arrayAppend( thisRoute.domainParams, thisDomainParam );
						break;
					}
					// ALPHA OPTIONAL
					case "alpha": {
						// Convert to Regex Pattern
						thisRegex = "(" & reReplace( thisDomain, ":.*?-alpha", "[a-zA-Z]" );
						// Check Digits
						if ( find( "{", thisDomain ) ) {
							thisRegex = listFirst( thisRegex, "{" ) & "{#listLast( thisDomain, "{" )#)";
						} else {
							thisRegex = thisRegex & "+?)";
						}
						// Add Route Param
						arrayAppend( thisRoute.domainParams, thisDomainParam );
						break;
					}
				}
				// end pattern type detection switch

				// Add Regex Created To Pattern
				thisRoute.regexDomain = thisRoute.regexDomain & thisRegex & ".";
			}
			// end looping of pattern optionals
			if ( right( thisRoute.regexDomain, 1 ) == "." ) {
				thisRoute.regexDomain = left( thisRoute.regexDomain, len( thisRoute.regexDomain ) - 1 );
			}
		}

		// Add it to the corresponding routing table
		// MODULES
		if ( len( arguments.module ) ) {
			// Append or PrePend
			if ( arguments.append ) {
				getModuleRoutes( arguments.module ).append( thisRoute );
			} else {
				getModuleRoutes( arguments.module ).prePend( thisRoute );
			}
		}
		// NAMESPACES
		else if ( len( arguments.namespace ) ) {
			// Append or PrePend
			if ( arguments.append ) {
				getNamespaceRoutes( arguments.namespace ).append( thisRoute );
			} else {
				getNamespaceRoutes( arguments.namespace ).prePend( thisRoute );
			}
		}
		// Default Routing Table
		else {
			// Append or PrePend
			if ( arguments.append ) {
				variables.routes.append( thisRoute );
			} else {
				variables.routes.prePend( thisRoute );
			}
		}

		return this;
	}

	/****************************************************************************************************************************/
	/* 													NEW ROUTING DSL														*/
	/****************************************************************************************************************************/

	/**
	 * Construct a route definition construct
	 */
	private struct function initRouteDefinition(){
		// Reset a group with closure
		if ( !variables.onGroup ) {
			variables.withClosure = {};
		}
		// Return a new route definition
		return {
			"action"                : "", // The action to execute
			"append"                : true, // Was this route appended or pre/prended
			"condition"             : "", // The condition closure which must be true for the route to match
			// TODO: Consider deprecating this since now we have a `-regex()` placeholder
			"constraints"           : {}, // If we have any regex constraints on placeholders.
			"domain"                : "", // The domain attached to the route
			"event"                 : "", // The full event syntax to execute
			"handler"               : "", // The handler to execute
			"headers"               : {}, // The HTTP response headers to respond with
			"layout"                : "", // The layout to proxy to
			"layoutModule"          : "", // If the layout comes from a module
			"meta"                  : {}, // Route metadata if any
			"module"                : "", // The module event we must execute
			"moduleRouting"         : "", // This routes to a module
			"name"                  : "", // The named route
			"namespace"             : "", // The namespace this route belongs to
			"namespaceRouting"      : "", // This routes to a namespace
			"packageResolverExempt" : false, // If true, it does not resolve packages by convention, by default we do
			"pattern"               : "", // The regex pattern used for matching
			"prc"                   : {}, // The PRC params to add incorporate if matched
			"rc"                    : {}, // The RC params to add incorporate if matched
			"redirect"              : "", // The redirection location
			"response"              : "", // Do we have an inline response closure
			"ssl"                   : false, // Are we forcing SSL
			"statusCode"            : 200, // The response status code
			"statusText"            : "Ok", // The response status text
			"valuePairTranslation"  : true, // If we translate name-value pairs in the URL by convention
			"verbs"                 : "", // The HTTP Verbs allowed
			"view"                  : "", // The view to proxy to
			"viewModule"            : "", // If the view comes from a module
			"viewNoLayout"          : false // If we use a layout or not
		};
	}

	/**
	 * Initiate a new route registration.  Please note that you must finalize the registration by calling a terminator
	 * fluently.  Unless, you pass in a target which can be a response closure/lambda or an event string.
	 *
	 * <pre>
	 * // with terminator
	 * route( "/home" ).to( "main.index" )
	 * // with inline lambda
	 * route( "/home", function( event, rc, prc ){ return "hello"; }  )
	 * // with inline event
	 * route( "/home", "main.index" )
	 * // with inline event + name
	 * route( "/home", "main.index", "home" )
	 * </pre>
	 *
	 * @pattern The pattern to register
	 * @target A response closure/lambda or an event string to execute
	 * @name The name of the route
	 */
	function route( required pattern, target, name = "" ){
		// inline termination
		if ( !isNull( arguments.target ) ) {
			// process a with closure if not empty
			if ( !variables.withClosure.isEmpty() ) {
				processWith( arguments );
			}
			// Prepare Routing Structure
			var args = {};
			// Simple => Event
			if ( isSimpleValue( arguments.target ) ) {
				args = {
					pattern : arguments.pattern,
					event   : arguments.target,
					verbs   : ( variables.thisRoute.keyExists( "verbs" ) ? variables.thisRoute.verbs : "" ),
					name    : arguments.name
				};
			}
			// Closure/Lambda => Response
			else {
				args = {
					pattern  : arguments.pattern,
					response : arguments.target,
					verbs    : ( variables.thisRoute.keyExists( "verbs" ) ? variables.thisRoute.verbs : "" ),
					name     : arguments.name
				};
			}

			// Inline terminator, finish it off!
			addRoute( argumentCollection = args );
			variables.thisRoute = initRouteDefinition();
			return this;
		} else {
			// process a with closure if not empty
			if ( !variables.withClosure.isEmpty() ) {
				processWith( arguments );
			}

			// Store data and continue
			variables.thisRoute.pattern = arguments.pattern;
			variables.thisRoute.name    = arguments.name;

			// Add a Handler in if it exists
			variables.thisRoute.handler = arguments.handler ?: "";

			return this;
		}
	}

	/**
	 * Register a route with GET restriction. Same as calling the following
	 * <pre>
	 * route( "/hello", "hello" ).withVerbs( "GET" )
	 * </pre>
	 *
	 * @pattern The pattern to register
	 * @target A response closure/lambda or an event string to execute
	 */
	function get( required pattern, target ){
		variables.thisRoute.verbs = "GET";
		return route( argumentCollection = arguments );
	}

	/**
	 * Register a route with POST restriction. Same as calling the following
	 * <pre>
	 * route( "/hello", "hello" ).withVerbs( "POST" )
	 * </pre>
	 *
	 * @pattern The pattern to register
	 * @target A response closure/lambda or an event string to execute
	 */
	function post( required pattern, target ){
		variables.thisRoute.verbs = "POST";
		return route( argumentCollection = arguments );
	}

	/**
	 * Register a route with PUT restriction. Same as calling the following
	 * <pre>
	 * route( "/hello", "hello" ).withVerbs( "PUT" )
	 * </pre>
	 *
	 * @pattern The pattern to register
	 * @target A response closure/lambda or an event string to execute
	 */
	function put( required pattern, target ){
		variables.thisRoute.verbs = "PUT";
		return route( argumentCollection = arguments );
	}

	/**
	 * Register a route with DELETE restriction. Same as calling the following
	 * <pre>
	 * route( "/hello", "hello" ).withVerbs( "DELETE" )
	 * </pre>
	 *
	 * @pattern The pattern to register
	 * @target A response closure/lambda or an event string to execute
	 */
	function delete( required pattern, target ){
		variables.thisRoute.verbs = "DELETE";
		return route( argumentCollection = arguments );
	}

	/**
	 * Register a route with PATHC restriction. Same as calling the following
	 * <pre>
	 * route( "/hello", "hello" ).withVerbs( "PATHC" )
	 * </pre>
	 *
	 * @pattern The pattern to register
	 * @target A response closure/lambda or an event string to execute
	 */
	function patch( required pattern, target ){
		variables.thisRoute.verbs = "PATCH";
		return route( argumentCollection = arguments );
	}

	/**
	 * Register a route with OPTIONS restriction. Same as calling the following
	 * <pre>
	 * route( "/hello", "hello" ).withVerbs( "OPTIONS" )
	 * </pre>
	 *
	 * @pattern The pattern to register
	 * @target A response closure/lambda or an event string to execute
	 */
	function options( required pattern, target ){
		variables.thisRoute.verbs = "OPTIONS";
		return route( argumentCollection = arguments );
	}

	/****************************************************************************************************************************/
	/* 													MODIFIERS																*/
	/****************************************************************************************************************************/

	/**
	 * Add a header to a route
	 * <pre>
	 * route( "hello", "main.index" ).header( "name", "hello" )
	 * </pre>
	 *
	 * @name The header name
	 * @value The header value
	 * @overwrite Overwrite if already defined
	 */
	function header(
		required name,
		required value,
		boolean overwrite = true
	){
		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}

		variables.thisRoute.headers.insert(
			arguments.name,
			arguments.value,
			arguments.overwrite
		);
		return this;
	}

	/**
	 * Appends a collection of header name-values to a pattern
	 * <pre>
	 * route( "hello" ).headers( { ... } ).to( "main.index" )
	 * </pre>
	 *
	 * @map The structure of headers to issue
	 * @overwrite Overwrite the elements
	 */
	function headers( required map, boolean overwrite = true ){
		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}
		variables.thisRoute.headers.append( arguments.map, arguments.overwrite );
		return this;
	}

	/**
	 * Appends a collection of metadata name-values to a pattern
	 * <pre>
	 * route( "hello" ).meta( { secure : true, perms : [] } ).to( "main.index" )
	 * </pre>
	 *
	 * @map The structure of metadata to store within the route
	 * @overwrite Overwrite the elements
	 */
	function meta( required map, boolean overwrite = true ){
		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}
		variables.thisRoute.meta.append( arguments.map, arguments.overwrite );
		return this;
	}

	/**
	 * Registers the route as a named route
	 * <pre>
	 * route( "hello", "main.index" ).as( "main" )
	 * </pre>
	 *
	 * @name The name to use for the route
	 */
	function as( required name ){
		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}
		variables.thisRoute.name = arguments.name;
		return this;
	}

	/**
	 * Register a request collection name-value pair if the route matches
	 * <pre>
	 * route( "hello", "main.index" ).rc( "private", true )
	 * </pre>
	 *
	 * @name The key name
	 * @value The value
	 * @overwrite Overwrite the value
	 */
	function rc(
		required name,
		required value,
		boolean overwrite = true
	){
		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}
		variables.thisRoute.rc.insert(
			arguments.name,
			arguments.value,
			arguments.overwrite
		);
		return this;
	}

	/**
	 * Appends a collection of name-values to the RC if the route matches
	 * <pre>
	 * route( "hello", "main.index" ).rcAppend( { ... } )
	 * </pre>
	 *
	 * @map The structure to append
	 * @overwrite Overwrite elements, default behavior
	 */
	function rcAppend( required map, boolean overwrite = true ){
		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}
		variables.thisRoute.rc.append( arguments.map, arguments.overwrite );
		return this;
	}

	/**
	 * Register a private request collection name-value pair if the route matches
	 * <pre>
	 * route( "hello", "main.index" ).prc( "private", true )
	 * </pre>
	 *
	 * @name The key name
	 * @value The value
	 * @overwrite Overwrite the value
	 */
	function prc(
		required name,
		required value,
		boolean overwrite = true
	){
		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}
		variables.thisRoute.prc.insert(
			arguments.name,
			arguments.value,
			arguments.overwrite
		);
		return this;
	}

	/**
	 * Appends a collection of name-values to the PRC if the route matches
	 * <pre>
	 * route( "hello", "main.index" ).prcAppend( { ... } )
	 * </pre>
	 *
	 * @map The structure to append
	 * @overwrite Overwrite elements, default behavior
	 */
	function prcAppend( required map, boolean overwrite = true ){
		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}
		variables.thisRoute.prc.append( arguments.map, arguments.overwrite );
		return this;
	}

	/**
	 * Register a struct of constraints for the route
	 * <pre>
	 * route( "hello", "main.index" ).constraints( { ... } )
	 * </pre>
	 *
	 * @map A structure of regex constraint overrides for variable placeholders. The key is the name of the variable, the value is the regex to try to match.
	 */
	function constraints( required map ){
		variables.thisRoute.constraints = arguments.map;
		return this;
	}

	/**
	 * Registers a pattern into a specific handler for execution. The handler string can include dot notations for folder paths or even
	 * a module `:` designator. Usually this is called if you want to delegate a route to a specific action terminator `toAction()`.
	 * This action can be a single action or a struct of HTTP Verbs to action maps. Please note that this is NOT the same as using
	 * the `toHandler()` terminator, which terminates the route addition to a specific handler.
	 * <br>
	 * Please see examples below:
	 * <pre>
	 * route( "api/user" ).withHandler( "User" ).toAction( { get : "index", delete : "delete" } );
	 * route( "api/user/details" ).withHandler( "User" ).toAction( "details" );
	 * </pre>
	 *
	 * @handler The handler syntax
	 */
	function withHandler( required handler ){
		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}
		variables.thisRoute.handler = arguments.handler;
		return this;
	}

	/**
	 * Registers a pattern into a specific action for execution. The action string can be a single action or a struct of
	 * HTTP Verb to actions map. Usually this is called to keep track of actions throughout a route definition and then follow
	 * it with a handler terminator or the global terminator: `end()`
	 * <br>
	 * Please see examples below:
	 * <pre>
	 * route( "api/user" ).\withAction( { get : "index", delete : "delete" } ).toHandler( "User" );
	 * route( "api/user/details" ).withAction( "details" ).toHandler( "User" );
	 * route( "api/:handler" ).withAction( "index" ).end();
	 * </pre>
	 *
	 * @action The action string or the action struct of HTTP verbs matching an action
	 */
	function withAction( required action ){
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}
		variables.thisRoute.action = arguments.action;
		return this;
	}

	/**
	 * Registers a pattern into a specific module routing table
	 * <pre>
	 * route( "hello", "main.index" ).withModule( "explorer" )
	 * </pre>
	 *
	 * @name The module name
	 */
	function withModule( required name ){
		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}
		variables.thisRoute.module = arguments.name;
		return this;
	}

	/**
	 * Registers a pattern into a specific Namespace routing table
	 * <pre>
	 * route( "hello", "main.index" ).withNamespace( "myAPI" )
	 * </pre>
	 *
	 * @name The namespace name
	 */
	function withNamespace( required name ){
		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}
		variables.thisRoute.namespace = arguments.name;
		return this;
	}

	/**
	 * Forces SSL on the route
	 * <pre>
	 * route( "hello", "main.index" ).withSSL()
	 * </pre>
	 */
	function withSSL(){
		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}
		variables.thisRoute.ssl = true;
		return this;
	}

	/**
	 * Registers a closure/lambda that will be called once the route matches to verify if we can proceed and execute its terminators.
	 * The closure/lambda must return boolean
	 * <pre>
	 * route( "hello", "main.index" ).withCondition( () => return false )
	 * </pre>
	 *
	 * @condition closure or lambda
	 */
	function withCondition( required condition ){
		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}
		variables.thisRoute.condition = arguments.condition;
		return this;
	}

	/**
	 * Registers a pattern that must exist under a domain pattern
	 * <pre>
	 * route( "hello", "main.index" ).withDomain( ":username.forgebox.dev" )
	 * </pre>
	 *
	 * @domain The domain construct
	 */
	function withDomain( required domain ){
		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}
		variables.thisRoute.domain = arguments.domain;
		return this;
	}

	/**
	 * Turn package resolver on/off
	 * <pre>
	 * route( "hello", "main.index" ).packageResolver( false );
	 * </pre>
	 *
	 * @toggle The boolean toggle
	 */
	function packageResolver( required boolean toggle ){
		variables.thisRoute.packageResolver = arguments.toggle;
		return this;
	}

	/**
	 * Turns on/off the value pair translator from extra metadata in a URL
	 * <pre>
	 * route( "hello", "main.index" ).valuePairTranslation( false );
	 * </pre>
	 *
	 * @toggle The boolean toggle
	 */
	function valuePairTranslation( required boolean toggle ){
		variables.thisRoute.valuePairTranslation = arguments.toggle;
		return this;
	}

	/**
	 * Prepends the route to the routing table. By default all routes are appended.
	 * <pre>
	 * route( "hello", "main.index" ).prepend();
	 * </pre>
	 */
	function prepend(){
		variables.thisRoute.append = false;
		return this;
	}

	/**
	 * Appends the route to the routing table. By default all routes are appended.
	 * <pre>
	 * route( "hello", "main.index" ).append();
	 * </pre>
	 */
	function append(){
		variables.thisRoute.append = true;
		return this;
	}

	/**
	 * Restricts the route to specific HTTP Verbs. Just pass a list of allowed verbs
	 * <pre>
	 * route( "hello", "main.index" ).withVerbs( "GET,POST,PUT" );
	 * </pre>
	 *
	 * @verbs The list of HTTP Verbs
	 */
	function withVerbs( required verbs ){
		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}
		variables.thisRoute.verbs = arguments.verbs;
		return this;
	}

	/****************************************************************************************************************************/
	/* 													TERMINATORS																*/
	/****************************************************************************************************************************/

	/**
	 * This is a global route definition terminator. It will grab whatever the fluent API collected and create a route from it.
	 * <pre>
	 * route( "hello" ).withHandler( "luis" ).withAction( "hello" ).end();
	 * </pre>
	 */
	function end(){
		// register the route
		addRoute( argumentCollection = variables.thisRoute );
		// reinit
		variables.thisRoute = initRouteDefinition();
		return this;
	}

	/**
	 * Send a route to a view/layout combo
	 * <pre>
	 * route( "hello", "main.index" ).toView( "hello" );
	 * route( "hello", "main.index" ).toView( view="hello", layout="rest" );
	 * route( "hello", "main.index" ).toView( view="hello", noLayout=true );
	 * </pre>
	 *
	 * @view The view to render
	 * @layout The layout to use or default one
	 * @noLayout Use only the view or attach the layout
	 * @viewModule The module the view comes from
	 * @layoutModule The module the layout comes from
	 */
	function toView(
		required view,
		layout           = "",
		boolean noLayout = false,
		viewModule       = "",
		layoutModule     = ""
	){
		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}
		// Construct Arguments
		variables.thisRoute.append(
			{
				view         : arguments.view,
				layout       : arguments.layout,
				viewNoLayout : arguments.nolayout,
				viewModule   : arguments.viewModule,
				layoutModule : arguments.layoutModule
			},
			true
		);
		// register the route
		addRoute( argumentCollection = variables.thisRoute );
		// reinit
		variables.thisRoute = initRouteDefinition();
		return this;
	}

	/**
	 * Redirects to a route or full HTTP URL if the pattern matched
	 * <pre>
	 * route( "old" ).toRedirect( "/api/new" );
	 * route( "old" ).toRedirect( "/api/new", 302 );
	 * route( "old" ).toRedirect( "https://www.ortussolutions.com");
	 * route( "/users/:id" ).toRedirect( function( route, params, event ){
	 * 	return "/api/users/#params.id#";
	 * })
	 * </pre>
	 *
	 * @target The target URI
	 * @statusCode The statusCode to use, defaults to 301
	 */
	function toRedirect( required target, statusCode = 301 ){
		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}
		// Construct arguments
		variables.thisRoute.append(
			{
				redirect   : arguments.target,
				statusCode : arguments.statusCode
			},
			true
		);
		// register the route
		addRoute( argumentCollection = variables.thisRoute );
		// reinit
		variables.thisRoute = initRouteDefinition();
		return this;
	}

	/**
	 * Terminates the route to execute an event
	 * <pre>
	 * route( "old" ).to( "main.index" );
	 * route( "old" ).to( "main" );
	 * route( "old" ).to( "api:main.index" );
	 * </pre>
	 *
	 * @event The event to execute
	 */
	function to( required event ){
		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}
		// Store event
		variables.thisRoute.event = arguments.event;
		// register the route
		addRoute( argumentCollection = variables.thisRoute );
		// reinit
		variables.thisRoute = initRouteDefinition();
		return this;
	}

	/**
	 * Terminates the route to execute a specific handler. Usually this will be done if the action is coming via the URL as a `:action` placeholder
	 * or you want the default `index` action to execute.
	 * <pre>
	 * route( "about/:action" ).toHandler( "static" )
	 * route( "users/:action?" ).toHandler( "users" )
	 * </pre>
	 *
	 * @handler The handler to send this route to for processing
	 */
	function toHandler( required handler ){
		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}
		// Store handler
		variables.thisRoute.handler = arguments.handler;
		// register the route
		addRoute( argumentCollection = variables.thisRoute );
		// reinit
		variables.thisRoute = initRouteDefinition();
		return this;
	}

	/**
	 * Terminates the route to execute a specific action or action struct. Usually the handler has already been defined beforehand.
	 * <pre>
	 * route( "about/:handler" ).toAction( "index" )
	 * route( "/api/v1/users" ).withHandler( "users" ).toAction( { GET : "index", POST : "save" } )
	 * </pre>
	 *
	 * @action The action string or the action struct of HTTP verbs matching an action
	 */
	function toAction( required action ){
		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}
		// Store action
		variables.thisRoute.action = arguments.action;
		// register the route
		addRoute( argumentCollection = variables.thisRoute );
		// reinit
		variables.thisRoute = initRouteDefinition();
		return this;
	}

	/**
	 * Terminates the route to execute a response closure with optional status codes and texts
	 * <pre>
	 * route( "old" ).toResponse( ( event, rc, prc ) => {
	 * 	...
	 *  return "html/data"
	 * } );
	 * </pre>
	 *
	 * @body The body of the response a lambda or closure
	 * @statusCode The status code to use, defaults to 200
	 * @statusText The status text to use, defaults to 'OK'
	 *
	 * @throws InvalidArgumentException
	 */
	function toResponse(
		required body,
		numeric statusCode = 200,
		statusText         = "Ok"
	){
		// Arg Check
		if ( !isClosure( arguments.body ) && !isCustomFunction( arguments.body ) && !isSimpleValue( arguments.body ) ) {
			throw( type: "InvalidArgumentException", message: "The 'body' argument is not of type closure or string" );
		}
		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}
		// Construct arguments
		variables.thisRoute.append(
			{
				response   : arguments.body,
				statusCode : arguments.statusCode,
				statusText : arguments.statusText
			},
			true
		);
		// register the route
		addRoute( argumentCollection = variables.thisRoute );
		// reinit
		variables.thisRoute = initRouteDefinition();
		return this;
	}

	/**
	 * Terminate the route to be the entry point for module routing
	 * <pre>
	 * route( "/api/v1" ).toModuleRouting( "API" );
	 * </pre>
	 *
	 * @module The module to send the route to
	 */
	function toModuleRouting( required module ){
		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}
		// Construct arguments
		variables.thisRoute.append( { moduleRouting : arguments.module }, true );
		// register the route
		addRoute( argumentCollection = variables.thisRoute );
		// reinit
		variables.thisRoute = initRouteDefinition();
		return this;
	}

	/**
	 * Terminate the route to be the entry point for namespace routing
	 * <pre>
	 * route( "/api/v1" ).toNamespaceRouting( "API" );
	 * </pre>
	 *
	 * @namespace The namespace to send the route to
	 */
	function toNamespaceRouting( required namespace ){
		// process a with closure if not empty
		if ( !variables.withClosure.isEmpty() ) {
			processWith( arguments );
		}
		// Register route to namespace
		addNamespace( pattern = variables.thisRoute.pattern, namespace = arguments.namespace );

		// reinit
		variables.thisRoute = initRouteDefinition();
		return this;
	}

	/**
	 * Composes the base URL for the server using the following composition:
	 * - protocol
	 * - host + port
	 * - routing app mapping
	 * - full Url routing or front controller routing
	 */
	string function composeRoutingUrl(){
		return (
			// Protocol
			variables.controller
				.getRequestService()
				.getContext()
				.isSSL() ? "https://" : "http://"
		) &
		CGI.HTTP_HOST & // multi-host
		composeRoutingPath(); // Routing Path
	}

	/**
	 * Composes the base routing path with no host or protocol
	 */
	string function composeRoutingPath(){
		return variables.controller.getSetting( "RoutingAppMapping" ) & // routing app mapping
		( variables.fullRewrites ? "" : "index.cfm" ); // full or controller routing
	}

	/*****************************************************************************************/
	/************************************ PRIVATE ********************************************/
	/*****************************************************************************************/

	/**
	 * Get the correct route actions based on only and except lists
	 * @initial The initial set of route actions
	 * @only 	Limit actions with only
	 * @except 	Exclude actions with except
	 */
	private struct function filterRouteActions(
		required struct initial,
		array only   = [],
		array except = []
	){
		var actionSet = arguments.initial;

		if ( structKeyExists( arguments, "only" ) && !isNull( arguments.only ) && !arrayIsEmpty( arguments.only ) ) {
			actionSet = {};
			for ( var HTTPVerb in arguments.initial ) {
				var methodName = arguments.initial[ HTTPVerb ];
				for ( var onlyAction in arguments.only ) {
					if ( compareNoCase( methodName, onlyAction ) == 0 ) {
						structInsert( actionSet, HTTPVerb, onlyAction );
					}
				}
			}
		}

		if ( structKeyExists( arguments, "except" ) && !isNull( arguments.except ) && !arrayIsEmpty( arguments.except ) ) {
			for ( var HTTPVerb in arguments.initial ) {
				var methodName = arguments.initial[ HTTPVerb ];
				for ( var exceptAction in arguments.except ) {
					if ( compareNoCase( methodName, exceptAction ) == 0 ) {
						structDelete( actionSet, HTTPVerb );
					}
				}
			}
		}

		return actionSet;
	}

	/**
	 * Process route optionals
	 *
	 * @thisRoute The route structure
	 */
	private function processRouteOptionals( required struct thisRoute ){
		var base      = "";
		var optionals = "";

		// Parse our base & optionals strings
		arguments.thisRoute.pattern
			.listToArray( "/" )
			.each( function( item ){
				// Check for ?
				if ( not findNoCase( "?", item ) ) {
					base = base & item & "/";
				} else {
					optionals = optionals & replaceNoCase( item, "?", "", "all" ) & "/";
				}
			} );

		// Register our optionals
		var routeList = base & optionals;
		optionals
			.listToArray( "/" )
			.each( function( item ){
				// Create new route
				thisRoute.pattern = routeList;
				// Register route
				addRoute( argumentCollection = thisRoute );
				// Remove last bit
				routeList = listDeleteAt( routeList, listLen( routeList, "/" ), "/" );
			} );

		// Setup the base route again
		arguments.thisRoute.pattern = base;
		// Register the final route
		addRoute( argumentCollection = arguments.thisRoute );
	}

}
