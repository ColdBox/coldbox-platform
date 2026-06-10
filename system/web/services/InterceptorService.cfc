/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This service takes care of all events and interceptions in ColdBox
 */
component extends="coldbox.system.web.services.BaseService" accessors="true" {

	/**
	 * Interception Points which can be announced
	 */
	property name="interceptionPoints" type="array";

	/**
	 * Interception Points metadata index
	 */
	property name="interceptionPointIndex" type="struct";

	/**
	 * Interception States that represent the unique points
	 */
	property name="interceptionStates" type="struct";

	/**
	 * Interceptor Service Configuration
	 */
	property name="interceptorConfig" type="struct";

	/**
	 * Startup dirty flag for interception point changes after configuration load
	 */
	property name="interceptionPointsChanged" type="boolean";

	// Interceptor base class
	INTERCEPTOR_BASE_CLASS = "coldbox.system.Interceptor";

	/**
	 * Constructor
	 */
	InterceptorService function init( required controller ){
		// controller reference
		variables.controller = arguments.controller
		// Register the interception points ENUM
		variables.interceptionPoints = [
			// Application startup points
			"afterConfigurationLoad",
			"afterAspectsLoad",
			"cbLoadInterceptorHelpers",
			"preReinit",
			// Rest Handler Exceptions
			"onAuthenticationFailure",
			"onAuthorizationFailure",
			"onValidationException",
			"onEntityNotFoundException",
			// On Actions
			"onException",
			"onRequestCapture",
			"onInvalidEvent",
			"onColdBoxShutdown",
			// Life-cycle
			"applicationEnd",
			"sessionStart",
			"sessionEnd",
			"preProcess",
			"preEvent",
			"postEvent",
			"postProcess",
			"preProxyResults",
			// Layout-View Events
			"preLayout",
			"preRender",
			"postRender",
			"preViewRender",
			"postViewRender",
			"preLayoutRender",
			"postLayoutRender",
			"afterRendererInit",
			// Module Events
			"preModuleLoad",
			"postModuleLoad",
			"preModuleUnload",
			"postModuleUnload",
			"preModuleRegistration",
			"postModuleRegistration",
			// Module Global Events
			"afterModuleRegistrations",
			"afterModuleActivations"
		]
		// Init interception point metadata index
		variables.interceptionPointIndex = {}
		for ( var thisPoint in variables.interceptionPoints ) {
			indexInterceptionPoint(
				name   = thisPoint,
				core   = true
			)
		}
		// Init Container of interception states
		variables.interceptionStates           = {}
		// Setup Default Configuration
		variables.interceptorConfig            = {}
		variables.interceptionPointsChanged    = false

		return this
	}

	/**
	 * Configure the service
	 */
	InterceptorService function configure(){
		// Setup Configuration
		variables.interceptorConfig = variables.controller.getSetting( "InterceptorConfig" )
		return this
	}

	/**
	 * Run once config loads
	 *
	 * @return InterceptorService
	 */
	function onConfigurationLoad(){
		// WireBox is loaded now, set it for performance.
		variables.wirebox = variables.controller.getWireBox()
		// Register the ColdBox Config as an interceptor
		registerInterceptor(
			interceptorObject = variables.controller.getSetting( "coldboxConfig" ),
			interceptorName   = "coldboxConfig"
		)
		// Register All Core App Interceptors
		registerInterceptors()
		// Reset startup dirty flag after the initial interceptor registration pass
		variables.interceptionPointsChanged = false

		return this
	}

	/**
	 * Fired by the loader service in case modules registered interception points
	 *
	 * @return InterceptorService
	 */
	function rescanInterceptors(){
		if ( variables.interceptionPointsChanged ) {
			getLogger().info( "Re-scanning interceptors as interception points changed during startup" )
			registerInterceptors()
		}
		return this
	}


	/**
	 * Registers all the interceptors configured and found in the configuration files
	 *
	 * @return InterceptorService
	 */
	function registerInterceptors(){
		// if simple, inflate
		if ( isSimpleValue( variables.interceptorConfig.customInterceptionPoints ) ) {
			variables.interceptorConfig.customInterceptionPoints = listToArray(
				variables.interceptorConfig.customInterceptionPoints
			);
		}

		// Check if we have custom interception points, and register them if we do
		if ( arrayLen( variables.interceptorConfig.customInterceptionPoints ) ) {
			appendInterceptionPoints( variables.interceptorConfig.customInterceptionPoints )
			getLogger().info(
				"Registering custom interception points: #variables.interceptorConfig.customInterceptionPoints.toString()#"
			);
		}

		// Loop over the Interceptor Array, to begin registration
		for ( var item in variables.interceptorConfig.interceptors ) {
			registerInterceptor(
				interceptorClass      = item.class,
				interceptorProperties = item.properties,
				interceptorName       = item.name
			)
		}

		return this;
	}

	/**
	 * Announce an interception to the system. If you use the asynchronous facilities, you will get a thread structure report as a result.
	 *
	 * This is needed so interceptors can write to the page output buffer
	 *
	 * @output           true
	 * @state            An interception state to process
	 * @data             A data structure used to pass intercepted information.
	 * @async            If true, the entire interception chain will be ran in a separate thread.
	 * @asyncAll         If true, each interceptor in the interception chain will be ran in a separate thread and then joined together at the end.
	 * @asyncAllJoin     If true, each interceptor in the interception chain will be ran in a separate thread and joined together at the end by default.  If you set this flag to false then there will be no joining and waiting for the threads to finalize.
	 * @asyncPriority    The thread priority to be used. Either LOW, NORMAL or HIGH. The default value is NORMAL
	 * @asyncJoinTimeout The timeout in milliseconds for the join thread to wait for interceptor threads to finish.  By default there is no timeout
	 */
	public any function announce(
		required any state,
		any data                 = {},
		boolean async            = false,
		boolean asyncAll         = false,
		boolean asyncAllJoin     = true,
		string asyncPriority     = "NORMAL",
		numeric asyncJoinTimeout = 0
	){
		// Backwards Compat: Remove by ColdBox 7
		if ( !isNull( arguments.interceptData ) ) {
			arguments.data = arguments.interceptData;
		}

		// Process The State if it exists, else just exit out
		if ( structKeyExists( variables.interceptionStates, arguments.state ) ) {
			arguments.event  = controller.getRequestService().getContext();
			arguments.buffer = getLazyBuffer();

			// Execute Interception
			var results = variables.interceptionStates
				.find( arguments.state )
				.process( argumentCollection = arguments );

			// If buffer has a builder, then content was lazyly produced, output it
			if ( arguments.buffer.keyExists( "builder" ) ) {
				writeOutput( arguments.buffer.getString() );
			}

			// Any results
			if ( !isNull( local.results ) ) {
				return results;
			}
		}
	}

	/**
	 * Produce a lazy buffer for performance considerations
	 *
	 * @return { get(), clear(), append(), length(), getString() }
	 */
	struct function getLazyBuffer(){
		var buffer = {
			get : function(){
				if ( !buffer.keyExists( "builder" ) ) {
					buffer.builder = createObject( "java", "java.lang.StringBuilder" ).init( "" );
				}
				return buffer.builder;
			},
			clear : function(){
				buffer.get().setLength( 0 );
				return buffer;
			},
			append : function( required str ){
				buffer.get().append( arguments.str );
				return buffer;
			},
			length : function(){
				return buffer.get().length();
			},
			getString : function(){
				return buffer.get().toString();
			}
		};
		return buffer;
	}

	/**
	 * Unregister the given closure from a specific interception point
	 *
	 * @target The closure/lambda to unregister
	 * @point  The interception point from which to unregister the listener
	 *
	 * @return True if interception point found and unregistered; else false.
	 */
	boolean function unlisten( required target, required point ){
		arguments = normalizeListenArguments( argumentCollection = arguments );
		return unregister( "closure-#arguments.point#-#hash( arguments.target.toString() )#" );
	}

	/**
	 * Register a closure listener as an interceptor on a specific point
	 *
	 * @target The closure/lambda to register
	 * @point  The interception point to register the listener to
	 */
	void function listen( required target, required point ){
		arguments = normalizeListenArguments( argumentCollection = arguments );
		// Append Custom Points
		appendInterceptionPoints( arguments.point )
		// Register the listener
		registerInterceptionPoint(
			interceptorKey = "closure-#arguments.point#-#hash( arguments.target.toString() )#",
			state          = arguments.point,
			oInterceptor   = arguments.target
		);
	}

	/**
	 * Allow point-first arguments when calling listen() or unlisten().
	 *
	 * Basically flips the `target` and `point` arguments if the former is found to be a string instead of closure.
	 *
	 * @target Could be the target closure... could be the listen point.
	 * @point  Could be the interception point... could be the target closure
	 */
	private struct function normalizeListenArguments( required target, required point ){
		if ( isSimpleValue( arguments.target ) ) {
			var closure      = arguments.point;
			arguments.point  = arguments.target;
			arguments.target = closure;
		}
		return arguments;
	}

	/**
	 * To satisfy event manager interface
	 *
	 * @target       The target object to register in an event pool
	 * @name         The name to use when registering the object.  If not passed, the name will be used from the object's metadata
	 * @customStates A comma delimited list of custom states, if the object or class sent in observes them
	 *
	 * @return InterceptorService
	 */
	function register( required target, name = "", customStates = "" ){
		return registerInterceptor(
			interceptorObject: arguments.target,
			interceptorName  : arguments.name,
			customPoints     : arguments.customStates
		);
	}

	/**
	 * Register a new interceptor in ColdBox
	 *
	 * @interceptorClass      Mutex with interceptorObject, this is the qualified class of the interceptor to register
	 * @interceptorObject     Mutex with interceptor Class, this is used to register an already instantiated object as an interceptor
	 * @interceptorProperties The structure of properties to register this interceptor with.
	 * @customPoints          A comma delimited list or array of custom interception points, if the object or class sent in observes them.
	 * @interceptorName       The name to use for the interceptor when stored. If not used, we will use the name found in the object's class
	 * @injector              The passed injector to use for construction
	 *
	 * @return InterceptorService
	 */
	function registerInterceptor(
		interceptorClass,
		interceptorObject,
		struct interceptorProperties = {},
		customPoints                 = "",
		interceptorName,
		injector
	){
		// determine registration names
		var objectName   = ""
		var oInterceptor = ""

		// Do we have a class path?
		if ( !isNull( arguments.interceptorClass ) ) {
			objectName = listLast( arguments.interceptorClass, "." )
			if ( !isNull( arguments.interceptorName ) ) {
				objectName = arguments.interceptorName
			}
		}
		// Else we have an object?
		else if ( !isNull( arguments.interceptorObject ) ) {
			// Determine object name
			if ( !isNull( arguments.interceptorName ) ) {
				objectName = arguments.interceptorName
			} else {
				objectName = listLast( getMetadata( arguments.interceptorObject ).name, "." )
			}
			oInterceptor = arguments.interceptorObject
		} else {
			throw(
				message = "Invalid registration.",
				detail  = "You did not send in an interceptorClass or interceptorObject argument for registration",
				type    = "InterceptorService.InvalidRegistration"
			)
		}

		// Did we send in a class to instantiate
		if ( !isNull( arguments.interceptorClass ) ) {
			// Create the Interceptor Class
			try {
				oInterceptor = createInterceptor(
					interceptorClass,
					objectName,
					interceptorProperties,
					isNull( arguments.injector ) ? variables.wirebox : arguments.injector
				)
			} catch ( Any e ) {
				getLogger().error(
					"Error creating interceptor: #arguments.interceptorClass#. #e.detail# #e.message# #e.stackTrace#",
					e.tagContext
				)
				rethrow;
			}

			// Configure the Interceptor
			oInterceptor.configure()
		}
		// end if class is sent.

		// Append Custom Points
		appendInterceptionPoints( arguments.customPoints )

		// Parse Interception Points
		var parsedMeta = parseMetadata( getMetadata( oInterceptor ), {} )
		for ( var stateKey in parsedMeta ) {
			var stateValue = parsedMeta[ stateKey ]
			// Register the point
			registerInterceptionPoint(
				interceptorKey = objectName,
				state          = stateKey,
				oInterceptor   = oInterceptor,
				interceptorMD  = stateValue
			)
			// Debug log
			if ( getLogger().canDebug() ) {
				getLogger().debug( "Registering #objectName# on '#stateKey#' interception point" )
			}
		}

		// Register Core Internal ColdBox Points
		// We do this manually as CFML Engines do not add mixins to metadata when using virtual inheritance
		if ( structKeyExists( oInterceptor, "cbLoadInterceptorHelpers" ) ) {
			// Register the point
			registerInterceptionPoint(
				interceptorKey = objectName,
				state          = "cbLoadInterceptorHelpers",
				oInterceptor   = oInterceptor
			)
		}

		return this
	}

	/**
	 * Create a new interceptor object with ColdBox pizzaz
	 *
	 * @interceptorClass      The class path to instantiate
	 * @interceptorName       The unique name of the object
	 * @interceptorProperties Construction properties
	 * @injector              The WireBox injector to use
	 *
	 * @return The newly created interceptor
	 */
	function createInterceptor(
		required interceptorClass,
		required interceptorName,
		struct interceptorProperties = {},
		injector                     = variables.wirebox
	){
		// Check if interceptor mapped?
		if ( NOT arguments.injector.getBinder().mappingExists( "interceptor-" & arguments.interceptorName ) ) {
			// wirebox lazy load checks
			injectorSeedBaseClasses( arguments.injector );
			// feed this interceptor to wirebox with virtual inheritance just in case, use registerNewInstance so its thread safe
			arguments.injector
				.registerNewInstance(
					name        : "interceptor-" & arguments.interceptorName,
					instancePath: arguments.interceptorClass
				)
				.setScope( arguments.injector.getBinder().SCOPES.SINGLETON )
				.setThreadSafe( true )
				.setVirtualInheritance( "coldbox.system.Interceptor" )
				.addDIConstructorArgument( name = "properties", value = arguments.interceptorProperties );
		}

		// retrieve, build and wire from wirebox
		return getInterceptor( arguments.interceptorName );
	}

	/**
	 * Retrieve an interceptor from the system by name, if not found, this method will throw an exception
	 *
	 * @interceptorName The name to retrieve
	 */
	function getInterceptor( required interceptorName ){
		return variables.wirebox.getInstance( "interceptor-" & arguments.interceptorName );
	}

	/**
	 * Append a list of custom interception points to the CORE interception points and returns itself
	 *
	 * @customPoints A comma delimited list or array of custom interception points to append. If they already exists, then they will not be added again.
	 * @module       The module contributing these interception points, if any. This is used for indexing and debugging purposes.
	 *
	 * @return The current interception points
	 */
	array function appendInterceptionPoints( required customPoints, module = "" ){
		// Inflate custom points
		if ( isSimpleValue( arguments.customPoints ) ) {
			arguments.customPoints = listToArray( arguments.customPoints )
		}

		for ( var thisPoint in arguments.customPoints ) {
			appendInterceptionPoint( point = thisPoint, module = arguments.module )
		}

		return variables.interceptionPoints
	}

	/**
	 * Get a State Container, it will return a blank structure if the state is not found.
	 *
	 * @state The state to retrieve
	 */
	function getStateContainer( required state ){
		if ( structKeyExists( variables.interceptionStates, arguments.state ) ) {
			return variables.interceptionStates[ arguments.state ];
		}

		return {};
	}

	/**
	 * Unregister an interceptor from an interception state or all states. If the state does not exists, it returns false
	 *
	 * @interceptorName The interceptor to unregister
	 * @state           The state to unregister from, if not, passed, then from all states
	 */
	boolean function unregister( required interceptorName, state = "" ){
		var unregistered = false;

		// Else, unregister from all states
		for ( var thisState in variables.interceptionStates ) {
			if ( !len( arguments.state ) OR arguments.state eq thisState ) {
				structFind( variables.interceptionStates, thisState ).unregister( arguments.interceptorName );
				unregistered = true;
			}
		}

		return unregistered;
	}

	/**
	 * Register an Interception point into a new or created interception state
	 *
	 * @interceptorKey The interceptor key to use for lookups in the state
	 * @state          The state to create
	 * @oInterceptor   The interceptor to register
	 * @interceptorMD  The metadata about the interception point: {async, asyncPriority, eventPattern}
	 */
	function registerInterceptionPoint(
		required interceptorKey,
		required state,
		required oInterceptor,
		interceptorMD
	){
		var oInterceptorState = "";

		// Init md if not passed
		if ( isNull( arguments.interceptorMD ) ) {
			arguments.interceptorMD = newPointRecord();
		}

		// Verify if state doesn't exist, create it
		if ( NOT structKeyExists( variables.interceptionStates, arguments.state ) ) {
			oInterceptorState = new coldbox.system.web.context.InterceptorState(
				state      = arguments.state,
				logbox     = controller.getLogBox(),
				controller = controller
			);
			variables.interceptionStates[ arguments.state ] = oInterceptorState;
		} else {
			// Get the State we need to register in
			oInterceptorState = variables.interceptionStates[ arguments.state ];
		}

		// Verify if the interceptor is already in the state
		if ( NOT oInterceptorState.exists( arguments.interceptorKey ) ) {
			// Register it
			oInterceptorState.register(
				interceptorKey = arguments.interceptorKey,
				interceptor    = arguments.oInterceptor,
				interceptorMD  = arguments.interceptorMD
			);
		}

		return this;
	}

	/****************************** PRIVATE *********************************/

	/**
	 * Create a new interception point record
	 */
	private struct function newPointRecord(){
		return {
			async         : false,
			asyncPriority : "normal",
			eventPattern  : ""
		};
	}

	/**
	 * Index an interception point with source metadata.
	 *
	 * @name   The interception point name
	 * @core   True if the point is a ColdBox core point
	 * @module The module that contributed the point, if any
	 *
	 * @return InterceptorService
	 */
	private function indexInterceptionPoint(
		required name,
		boolean core = false,
		module       = ""
	){
		variables.interceptionPointIndex[ arguments.name ] = {
			name   : arguments.name,
			core   : arguments.core,
			module : arguments.module,
			order  : variables.interceptionPoints.len()
		}

		return this
	}

	/**
	 * Append a single interception point if it has not been indexed already
	 *
	 * @point  The interception point name
	 * @module The module contributing the point, if any
	 *
	 * @return True if the point was added, else false
	 */
	private boolean function appendInterceptionPoint( required point, module = "" ){
		if ( structKeyExists( variables.interceptionPointIndex, arguments.point ) ) {
			return false
		}

		variables.interceptionPoints.append( arguments.point )
		indexInterceptionPoint(
			name   = arguments.point,
			core   = false,
			module = arguments.module
		)
		variables.interceptionPointsChanged = true

		return true
	}

	/**
	 * Verifies setup of base handler classes in WireBox
	 *
	 * @injector The injector to seed and verify
	 *
	 * @return InterceptorService
	 */
	private function injectorSeedBaseClasses( required injector ){
		// Check if handler mapped?
		if ( NOT arguments.injector.getBinder().mappingExists( variables.INTERCEPTOR_BASE_CLASS ) ) {
			// feed the base class
			arguments.injector
				.registerNewInstance(
					name        : variables.INTERCEPTOR_BASE_CLASS,
					instancePath: variables.INTERCEPTOR_BASE_CLASS
				)
				.setScope( "singleton" );
		}

		return this;
	}

	/**
	 * I get a components valid interception points
	 *
	 * @metadata The metadata struct of the component to parse for interception points
	 * @points   The interception points found so far in the recursive lookup, this is used
	 *
	 * @return The interception points found in the metadata and its inheritances
	 */
	private struct function parseMetadata( required metadata, required points ){
		var pointsFound             = arguments.points
		var currentMetadata         = arguments.metadata
		var interceptionPointIndex  = variables.interceptionPointIndex
		var functionMetadata        = []
		var functionCount           = 0
		var thisFunction            = {}
		var pointName               = ""
		var pointRecord             = {}

		while ( isStruct( currentMetadata ) ) {
			// Register local functions only
			if ( structKeyExists( currentMetadata, "functions" ) ) {
				functionMetadata = currentMetadata.functions
				functionCount    = arrayLen( functionMetadata )

				for ( var x = 1; x lte functionCount; x++ ) {
					thisFunction = functionMetadata[ x ]
					pointName    = thisFunction.name

					// Register the point by convention and annotation
					if ( structKeyExists( thisFunction, "interceptionPoint" ) ) {
						appendInterceptionPoint( point = pointName )
					}

					// verify its an interception point by comparing it to the local defined interception points
					// Also verify it has not been found already
					if (
						structKeyExists( interceptionPointIndex, pointName ) AND
						NOT structKeyExists( pointsFound, pointName )
					) {
						pointRecord = newPointRecord()

						// Discover point information
						if ( structKeyExists( thisFunction, "async" ) ) {
							pointRecord.async = true
						}
						if ( structKeyExists( thisFunction, "asyncPriority" ) ) {
							pointRecord.asyncPriority = thisFunction.asyncPriority
						}
						if ( structKeyExists( thisFunction, "eventPattern" ) ) {
							pointRecord.eventPattern = thisFunction.eventPattern
						}

						pointsFound[ pointName ] = pointRecord
					}
				}
			}

			if (
				!structKeyExists( currentMetadata, "extends" ) OR
				currentMetadata.extends.isEmpty() OR
				currentMetadata.extends.name eq variables.INTERCEPTOR_BASE_CLASS
			) {
				break;
			}

			currentMetadata = currentMetadata.extends
		}

		return pointsFound
	}

}
