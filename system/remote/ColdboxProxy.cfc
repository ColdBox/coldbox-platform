/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This object is a proxy object that can be used by components to tap into ColdBox MVC.
 * It can be used when building RESTful/SOAP/Services or ORM Event handling,etc.
 *
 * It's intent is to provide a way for ANY cfc to talk to a running ColdBox application or even start one up.
 *
 * @author Luis Majano
 */
component serializable="false" accessors="true" {

	/**
	 * Internal key used to track the location in the application scope
	 */
	property name="COLDBOX_APP_KEY";

	// Remote proxies are created by the CFML engine without calling init(),
	// so autowire in here in the pseduo constructor
	selfAutowire();

	/****************************************************************
	 * Private Methods *
	 ****************************************************************/

	/**
	 * Get the ColdBox app key used in the application scope.
	 */
	private function getColdboxAppKey(){
		if ( !isNull( application.cbBootstrap ) ) {
			return application.cbBootstrap.getCOLDBOX_APP_KEY();
		}
		return "cbController";
	}

	/**
	 * Process a remote call into ColdBox's event model and return data/objects back.
	 *
	 * @return If no results where found, this method returns null/void
	 *
	 * @throws ColdBoxProxy.NoEventDetected - When no passed even is incoming via arguments[ "event" ]
	 */
	private any function process(){
		var refLocal = {};

		cfsetting( showdebugoutput = "false" );

		try {
			// Locate ColdBox Controller
			var cbController = getController();
			// Load Module CF Mappings
			cbController.getModuleService().loadMappings();
			// Create the request context
			var event = cbController.getRequestService().requestCapture();

			// Test event Name in the arguments.
			if ( not structKeyExists( arguments, event.getEventName() ) ) {
				throw(
					message = "Event not detected",
					detail  = "The #event.geteventName()# variable does not exist in the arguments.",
					type    = "ColdBoxProxy.NoEventDetected"
				);
			}

			// Append the arguments to the collection
			event.collectionAppend( arguments, true );
			// Set that this is a proxy request.
			event.setProxyRequest();

			// Execute a pre process interception.
			cbController.getInterceptorService().announce( "preProcess" );

			// Request Start Handler if defined
			if ( cbController.getSetting( "RequestStartHandler" ) neq "" ) {
				cbController.runEvent( cbController.getSetting( "RequestStartHandler" ), true );
			}

			// Execute the Event if not demarcated to not execute
			if ( NOT event.getIsNoExecution() ) {
				refLocal.results = cbController.runEvent( defaultEvent = true );
			}

			// Request END Handler if defined
			if ( cbController.getSetting( "RequestEndHandler" ) neq "" ) {
				cbController.runEvent( cbController.getSetting( "RequestEndHandler" ), true );
			}

			// Execute the post process interceptor
			cbController.getInterceptorService().announce( " postProcess" );
		} catch ( any e ) {
			handleException( e );
			rethrow;
		}

		// Determine what to return via the setting for proxy calls, no preProxyReturn because we can just listen to the collection
		if ( cbController.getSetting( "ProxyReturnCollection" ) ) {
			// Return request collection
			return event.getCollection();
		}

		// Check for Marshalling
		refLocal.marshalData = event.getRenderData();
		if ( not structIsEmpty( refLocal.marshalData ) ) {
			// Marshal Data
			refLocal.results = cbController
				.getDataMarshaller()
				.marshallData( argumentCollection = refLocal.marshalData );

			// Set output content header
			event.setHTTPHeader( name: "content-type", value: refLocal.marshalData.type );

			// Set Return Format according to Marshalling Type if not incoming
			if ( not structKeyExists( arguments, "returnFormat" ) ) {
				arguments.returnFormat = refLocal.marshalData.type;
			}
		}

		// Return results from handler only if found, else method will produce a null result
		if ( !isNull( local.refLocal.results ) ) {
			// preProxyResults interception call
			cbController.getInterceptorService().announce( "preProxyResults", { "proxyResults" : local.refLocal } );

			// Return The results
			return local.refLocal.results;
		}
	}

	/**
	 * Announce an interception
	 *
	 * @state The interception state to announce
	 * @data  A data structure used to pass intercepted information.
	 */
	private boolean function announce( required state, struct data = {} ){
		try {
			// Backwards Compat: Remove by ColdBox 7
			if ( !isNull( arguments.interceptData ) ) {
				arguments.data = arguments.interceptData;
			}
			getController().getInterceptorService().announce( arguments.state, arguments.data );
		} catch ( any e ) {
			handleException( e );
			rethrow;
		}

		return true;
	}

	/**
	 * @deprecated Please use the new `emit()` function
	 */
	private function announceInterception(
		required state,
		struct interceptData     = {},
		boolean async            = false,
		boolean asyncAll         = false,
		boolean asyncAllJoin     = true,
		asyncPriority            = "NORMAL",
		numeric asyncJoinTimeout = 0
	){
		arguments.data = arguments.interceptData;
		return announce( argumentCollection = arguments );
	}

	/**
	 * Handle a ColdBox Proxy Exception
	 *
	 * @exceptionObject The exception object to handle
	 */
	private void function handleException( required exceptionObject ){
		// Intercept Exception
		getController()
			.getInterceptorService()
			.announce( "onException", { "exception" : arguments.exceptionObject } );

		// Log Exception
		getLogger( this ).error(
			"ColdBox Proxy Exception: #arguments.exceptionObject.message# #arguments.exceptionObject.detail#",
			arguments.exceptionObject
		);
	}

	/**
	 * Verify the coldbox app exists in application scope
	 *
	 * @throws ControllerIllegalState - If app not found and throwOnNotExist = true
	 */
	private boolean function verifyColdBox( boolean throwOnNotExist = true ){
		// Verify the coldbox app is ok, else throw
		if ( not structKeyExists( application, getColdboxAppKey() ) ) {
			if ( arguments.throwOnNotExist ) {
				throw(
					message = "ColdBox Controller Not Found",
					detail  = "The coldbox main controller has not been initialized",
					type    = "ColdBoxProxy.ControllerIllegalState"
				);
			} else {
				return false;
			}
		} else {
			return true;
		}
	}

	/**
	 * Get the running ColdBox Controller instance
	 *
	 * @throws ControllerIllegalState - If app not found
	 */
	private any function getController(){
		// Verify ColdBox
		verifyColdBox();
		return application[ getColdboxAppKey() ];
	}

	/**
	 * Get the running app CacheBox instance
	 */
	private any function getCacheBox(){
		return getController().getCacheBox();
	}

	/**
	 * Get the running app WireBox instance
	 */
	private any function getWireBox(){
		return getController().getWireBox();
	}

	/**
	 * Get the running app LogBox instance
	 */
	private any function getLogBox(){
		return getController().getLogBox();
	}

	/**
	 * Get the running app root logger instance
	 */
	private any function getRootLogger(){
		return getLogBox().getRootLogger();
	}

	/**
	 * Get a named logger reference.
	 *
	 * @category The category name to use in this logger or pass in the target object will log from and we will inspect the object and use its metadata name
	 */
	private any function getLogger( required category ){
		return getLogBox().getLogger( arguments.category );
	}

	/**
	 * Locates, Creates, Injects and Configures an object model instance
	 *
	 * @name          The mapping name or CFC instance path to try to build up
	 * @initArguments The constructor structure of arguments to passthrough when initializing the instance
	 * @dsl           The dsl string to use to retrieve the instance model object, mutually exclusive with 'name
	 * @targetObject  The object requesting the dependency, usually only used by DSL lookups
	 * @injector      The child injector to use when retrieving the instance
	 *
	 * @return The requested instance
	 *
	 * @throws InstanceNotFoundException - When the requested instance cannot be found
	 * @throws InvalidChildInjector      - When you request an instance from an invalid child injector name
	 **/
	private function getInstance(
		name,
		struct initArguments = {},
		dsl,
		targetObject = "",
		injector
	){
		return getWireBox().getInstance( argumentCollection = arguments );
	}

	/**
	 * Get an interceptor
	 */
	private any function getInterceptor( string interceptorName, boolean deepSearch = "false" ){
		return getController().getInterceptorService().getInterceptor( argumentCollection = arguments );
	}


	/**
	 * Get a CacheBox Cache Provider
	 */
	private any function getCache( string cacheName = "default" ){
		return getController().getCache( arguments.cacheName );
	}

	/**
	 * Load a coldbox application, and place the coldbox controller in application scope for usage. If the application is already running, then it will not re-do it,
	 * unless you specify the reload argument or the application expired.
	 *
	 * @appMapping     The app to load via mapping
	 * @configLocation The config cfc to load else use by convention config/Coldboc.cfc
	 * @reloadApp      To reload the app if running
	 * @appKey         The running app key in application scope
	 */
	private void function loadColdbox(
		required string appMapping,
		string configLocation  = "",
		boolean reloadApp      = false,
		required string appKey = getColdboxAppKey()
	){
		var appHash = hash( getBaseTemplatePath() );

		//  Reload Checks
		if (
			!structKeyExists( application, arguments.appKey ) || !application[ arguments.appKey ].getColdboxInitiated() || arguments.reloadApp
		) {
			lock type="exclusive" name="#appHash#" timeout="30" throwontimeout="true" {
				if (
					not structKeyExists( application, arguments.appKey ) || !application[ arguments.appKey ].getColdboxInitiated() || arguments.reloadApp
				) {
					// Cleanup, Just in Case
					structDelete( application, arguments.appKey );
					// Load it Up baby!!
					var cbController = createObject( "component", "coldbox.system.web.Controller" ).init(
						expandPath( arguments.appMapping ),
						arguments.appKey
					);
					// Put in Scope
					application[ arguments.appKey ] = cbController;
					// Setup Calls
					cbController
						.getLoaderService()
						.loadApplication( arguments.configLocation, arguments.appMapping );
				}
			}
		}
	}

	/**
	 * Create and return the ColdBox utility object
	 *
	 * @return coldbox.system.core.util.Util
	 */
	private any function getUtil(){
		if ( isNull( variables.util ) ) {
			variables.util = new coldbox.system.core.util.Util();
		}
		return variables.util;
	}

	/**
	 * Get a reference to the ColdBox Remoting utility class
	 *
	 * @return coldbox.system.remote.RemotingUtil
	 */
	private function getRemotingUtil(){
		if ( isNull( variables.remotingUtil ) ) {
			variables.remotingUtil = new coldbox.system.remote.RemotingUtil();
		}
		return variables.remotingUtil;
	}

	/**
	 * Autowire the proxy on creation. This references the super class only, we use cgi information to get the actual proxy component path
	 */
	private function selfAutoWire(){
		var scriptName = CGI.SCRIPT_NAME;
		// Only process this logic if hitting a remote proxy CFC directly and if ColdBox exists.
		if ( len( scriptName ) < 5 || right( scriptName, 4 ) != ".cfc" || !verifyColdBox( throwOnNotExist = false ) ) {
			return;
		}

		// Find the path of the proxy component being called
		var contextRoot   = getContextRoot();
		var componentPath = replaceNoCase(
			mid(
				scriptName,
				len( contextRoot ) + 2,
				len( scriptName ) - len( contextRoot ) - 5
			),
			"/",
			".",
			"all"
		);

		var injector = getWirebox();
		var binder   = injector.getBinder();
		var mapping  = "";

		// Prevent recursive object creation in Lucee
		if ( !structKeyExists( request, "proxyAutowire" ) ) {
			request.proxyAutowire = true;

			// If a mapping for this proxy doesn't exist, create it.
			if ( !binder.mappingExists( componentPath ) ) {
				// First one only, please
				lock name="ColdBoxProxy.createMapping.#hash( componentPath )#" type="exclusive" timeout="20" {
					// Double check
					if ( !binder.mappingExists( componentPath ) ) {
						// Get its metadata
						var md = getUtil().getInheritedMetaData( componentPath );

						// register new mapping instance
						injector.registerNewInstance( componentPath, componentPath );
						// get Mapping created
						mapping = binder.getMapping( componentPath );
						// process it with the correct metadata
						mapping.process(
							binder   = binder,
							injector = injector,
							metadata = md
						);
					}
				}
				// End lock
			}
			// End outer exists check

			// Guaranteed to exist now
			mapping = binder.getMapping( componentPath );

			// Autowire ourself based on the mapping
			getWirebox().autowire(
				target          = this,
				mapping         = mapping,
				annotationCheck = true
			);
		}
	}

}
