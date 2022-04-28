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
	 * Interception States that represent the unique points
	 */
	property name="interceptionStates" type="struct";

	/**
	 * Interceptor Service Configuration
	 */
	property name="interceptorConfig" type="struct";

	// Interceptor base class
	INTERCEPTOR_BASE_CLASS = "coldbox.system.Interceptor";

	/**
	 * Constructor
	 */
	InterceptorService function init( required controller ){
		setController( arguments.controller );

		// Register the interception points ENUM
		variables.interceptionPoints = [
			// Application startup points
			"afterConfigurationLoad",
			"afterAspectsLoad",
			"cbLoadInterceptorHelpers",
			"preReinit",
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
		];

		// Init Container of interception states
		variables.interceptionStates           = {};
		// Default Logging
		variables.log                          = controller.getLogBox().getLogger( this );
		// Setup Default Configuration
		variables.interceptorConfig            = {};
		variables.onLoadInterceptionPointsHash = "";

		return this;
	}

	/**
	 * Configure the service
	 */
	InterceptorService function configure(){
		// Reconfigure Logging With Application Configuration Data
		variables.log               = controller.getLogBox().getLogger( this );
		// Setup Configuration
		variables.interceptorConfig = controller.getSetting( "InterceptorConfig" );
		// Register CFC Configuration Object
		registerInterceptor(
			interceptorObject = controller.getSetting( "coldboxConfig" ),
			interceptorName   = "coldboxConfig"
		);

		return this;
	}

	/**
	 * Run once config loads
	 *
	 * @return InterceptorService
	 */
	function onConfigurationLoad(){
		// WireBox is loaded now, set it for performance.
		variables.wirebox = controller.getWireBox();
		// Register All Application Interceptors
		registerInterceptors();
		// Store hash of loaded points
		variables.onLoadInterceptionPointsHash = hash( arrayToList( variables.interceptionPoints ) );
		return this;
	}

	/**
	 * Fired by the loader service in case modules registered interception points
	 *
	 * @return InterceptorService
	 */
	function rescanInterceptors(){
		if ( variables.onLoadInterceptionPointsHash != hash( arrayToList( variables.interceptionPoints ) ) ) {
			variables.log.info( "Re-scanning interceptors as modules have contributed interception points" );
			registerInterceptors();
		}
		return this;
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
			appendInterceptionPoints( variables.interceptorConfig.customInterceptionPoints );
			variables.log.info(
				"Registering custom interception points: #variables.interceptorConfig.customInterceptionPoints.toString()#"
			);
		}

		// Loop over the Interceptor Array, to begin registration
		variables.interceptorConfig.interceptors.each( function( item ){
			registerInterceptor(
				interceptorClass      = item.class,
				interceptorProperties = item.properties,
				interceptorName       = item.name
			);
		} );

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
	 * @deprecated please use `announce()` instead
	 */
	public any function processState(
		required any state,
		any interceptData        = structNew(),
		boolean async            = false,
		boolean asyncAll         = false,
		boolean asyncAllJoin     = true,
		string asyncPriority     = "NORMAL",
		numeric asyncJoinTimeout = 0
	){
		arguments.data = arguments.interceptData;
		return announce( argumentCollection = arguments );
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
	 * Register a closure listener as an interceptor on a specific point
	 *
	 * @target The closure/lambda to register
	 * @point  The interception point to register the listener to
	 */
	void function listen( required target, required point ){
		// Append Custom Points
		appendInterceptionPoints( arguments.point );
		// Register the listener
		registerInterceptionPoint(
			interceptorKey = "closure-#arguments.point#-#hash( arguments.target.toString() )#",
			state          = arguments.point,
			oInterceptor   = arguments.target
		);
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
	 *
	 * @return InterceptorService
	 */
	function registerInterceptor(
		interceptorClass,
		interceptorObject,
		struct interceptorProperties = {},
		customPoints                 = "",
		interceptorName
	){
		// determine registration names
		var objectName   = "";
		var oInterceptor = "";

		// Do we have a class path?
		if ( !isNull( arguments.interceptorClass ) ) {
			objectName = listLast( arguments.interceptorClass, "." );
			if ( !isNull( arguments.interceptorName ) ) {
				objectName = arguments.interceptorName;
			}
		}
		// Else we have an object?
		else if ( !isNull( arguments.interceptorObject ) ) {
			// Determine object name
			if ( !isNull( arguments.interceptorName ) ) {
				objectName = arguments.interceptorName;
			} else {
				objectName = listLast( getMetadata( arguments.interceptorObject ).name, "." );
			}
			oInterceptor = arguments.interceptorObject;
		} else {
			throw(
				message = "Invalid registration.",
				detail  = "You did not send in an interceptorClass or interceptorObject argument for registration",
				type    = "InterceptorService.InvalidRegistration"
			);
		}

		lock
			name          ="interceptorService.#getController().getAppHash()#.registerInterceptor.#objectName#"
			type          ="exclusive"
			throwontimeout="true"
			timeout       ="30" {
			// Did we send in a class to instantiate
			if ( !isNull( arguments.interceptorClass ) ) {
				// Create the Interceptor Class
				try {
					oInterceptor = createInterceptor(
						interceptorClass,
						objectName,
						interceptorProperties
					);
				} catch ( Any e ) {
					variables.log.error(
						"Error creating interceptor: #arguments.interceptorClass#. #e.detail# #e.message# #e.stackTrace#",
						e.tagContext
					);
					rethrow;
				}

				// Configure the Interceptor
				oInterceptor.configure();
			}
			// end if class is sent.

			// Append Custom Points
			appendInterceptionPoints( arguments.customPoints );

			// Parse Interception Points
			parseMetadata( getMetadata( oInterceptor ), {} ).each( function( stateKey, stateValue ){
				// Register the point
				registerInterceptionPoint(
					interceptorKey = objectName,
					state          = arguments.stateKey,
					oInterceptor   = oInterceptor,
					interceptorMD  = arguments.stateValue
				);
				// Debug log
				if ( variables.log.canDebug() ) {
					variables.log.debug( "Registering #objectName# on '#arguments.stateKey#' interception point" );
				}
			} );

			// Register Core Internal ColdBox Points
			// We do this manually as CFML Engines do not add mixins to metadata when using virtual inheritance
			if ( structKeyExists( oInterceptor, "cbLoadInterceptorHelpers" ) ) {
				// Register the point
				registerInterceptionPoint(
					interceptorKey = objectName,
					state          = "cbLoadInterceptorHelpers",
					oInterceptor   = oInterceptor
				);
			}
		}
		// end lock

		return this;
	}

	/**
	 * Create a new interceptor object with ColdBox pizzaz
	 *
	 * @interceptorClass      The class path to instantiate
	 * @interceptorName       The unique name of the object
	 * @interceptorProperties Construction properties
	 *
	 * @return The newly created interceptor
	 */
	function createInterceptor(
		required interceptorClass,
		required interceptorName,
		struct interceptorProperties = {}
	){
		// Check if interceptor mapped?
		if ( NOT variables.wirebox.getBinder().mappingExists( "interceptor-" & arguments.interceptorName ) ) {
			// wirebox lazy load checks
			wireboxSetup();
			// feed this interceptor to wirebox with virtual inheritance just in case, use registerNewInstance so its thread safe
			variables.wirebox
				.registerNewInstance(
					name         = "interceptor-" & arguments.interceptorName,
					instancePath = arguments.interceptorClass
				)
				.setScope( variables.wirebox.getBinder().SCOPES.SINGLETON )
				.setThreadSafe( true )
				.setVirtualInheritance( "coldbox.system.Interceptor" )
				.addDIConstructorArgument( name = "controller", value = controller )
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
	 *
	 * @return The current interception points
	 */
	array function appendInterceptionPoints( required customPoints ){
		// Inflate custom points
		if ( isSimpleValue( arguments.customPoints ) ) {
			arguments.customPoints = listToArray( arguments.customPoints );
		}

		for ( var thisPoint in arguments.customPoints ) {
			if ( !arrayFindNoCase( variables.interceptionPoints, thisPoint ) ) {
				variables.interceptionPoints.append( thisPoint );
			}
		}

		return variables.interceptionPoints;
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
	 * Verifies the setup for interceptor classes is online
	 */
	private InterceptorService function wireboxSetup(){
		// Check if handler mapped?
		if ( NOT variables.wirebox.getBinder().mappingExists( variables.INTERCEPTOR_BASE_CLASS ) ) {
			// feed the base class
			variables.wirebox
				.registerNewInstance(
					name         = variables.INTERCEPTOR_BASE_CLASS,
					instancePath = variables.INTERCEPTOR_BASE_CLASS
				)
				.addDIConstructorArgument( name = "controller", value = controller )
				.addDIConstructorArgument( name = "properties", value = {} )
				.setAutowire( false );
		}

		return this;
	}

	/**
	 * I get a components valid interception points
	 */
	private struct function parseMetadata( required metadata, required points ){
		var x           = 1;
		var pointsFound = arguments.points;
		var currentList = arrayToList( variables.interceptionPoints );

		// Register local functions only
		if ( structKeyExists( arguments.metadata, "functions" ) ) {
			var fncLen = arrayLen( arguments.metadata.functions );
			for ( var x = 1; x lte fncLen; x++ ) {
				// Verify the @interceptionPoint annotation so the function can be registered as an interception point
				if ( structKeyExists( arguments.metadata.functions[ x ], "interceptionPoint" ) ) {
					// Register the point by convention and annotation
					currentList = arrayToList( appendInterceptionPoints( arguments.metadata.functions[ x ].name ) );
				}

				// verify its an interception point by comparing it to the local defined interception points
				// Also verify it has not been found already
				if (
					listFindNoCase( currentList, arguments.metadata.functions[ x ].name ) AND
					NOT structKeyExists( pointsFound, arguments.metadata.functions[ x ].name )
				) {
					// Create point record
					var pointRecord = newPointRecord();

					// Discover point information
					if ( structKeyExists( arguments.metadata.functions[ x ], "async" ) ) {
						pointRecord.async = true;
					}
					if ( structKeyExists( arguments.metadata.functions[ x ], "asyncPriority" ) ) {
						pointRecord.asyncPriority = arguments.metadata.functions[ x ].asyncPriority;
					}
					if ( structKeyExists( arguments.metadata.functions[ x ], "eventPattern" ) ) {
						pointRecord.eventPattern = arguments.metadata.functions[ x ].eventPattern;
					}

					// Insert to metadata struct of points found
					structInsert(
						pointsFound,
						arguments.metadata.functions[ x ].name,
						pointRecord
					);
				}
			}
			// loop over functions
		}

		// Start Registering inheritances
		if (
			structKeyExists( arguments.metadata, "extends" )
			&&
			arguments.metadata.extends.name neq "coldbox.system.EventHandler"
		) {
			// Recursive lookup
			parseMetadata( arguments.metadata.extends, pointsFound );
		}

		// return the interception points found
		return pointsFound;
	}

}
