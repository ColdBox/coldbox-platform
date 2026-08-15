/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * The interception state is an event pool object.  It tracks all registered announcements by name
 * and can iterate and announce the state listeners for you.
 *
 */
component accessors="true" extends="coldbox.system.core.events.EventPool" {

	/**
	 * Controller reference
	 */
	property name="controller";

	/**
	 * Metadata map for objects
	 */
	property name="metadataMap";

	/**
	 * Interceptor chain
	 */
	property name="interceptorChain";

	/**
	 * Constructor
	 *
	 * @state      The interception state to model
	 * @logbox     LogBox reference
	 * @controller The ColdBox Controller
	 */
	function init(
		required state,
		required logbox,
		required controller
	){
		super.init( argumentCollection = arguments )

		// Controller
		variables.controller       = arguments.controller
		// md ref map
		variables.metadataMap      = {}
		// Ordered runtime chain for hot interception processing
		variables.interceptorChain = []
		// Utilities
		variables.utility          = arguments.controller.getUtil()
		// UUID Helper
		variables.uuidHelper       = createObject( "java", "java.util.UUID" )

		return this
	}

	/**
	 * Return the state's metadata map for it's registered interceptors
	 *
	 * @interceptorKey Pass a key and retrieve that interceptor's metadata map only
	 */
	function getMetadataMap( interceptorKey ){
		if ( !isNull( arguments.interceptorKey ) ) {
			return variables.metadataMap[ arguments.interceptorKey ]
		}
		return variables.metadataMap
	}

	/**
	 * Register an interceptor class with this state
	 *
	 * @interceptorKey The interceptor key class to register
	 * @interceptor    The interceptor reference from the cache.
	 * @interceptorMD  The interceptor state metadata.
	 */
	function register(
		required interceptorKey,
		required interceptor,
		required interceptorMD
	){
		// Register interceptor object
		super.register( arguments.interceptorKey, arguments.interceptor )
		// Register interceptor metadata
		variables.metadataMap[ arguments.interceptorKey ] = arguments.interceptorMD
		// Rebuild hot lookup chain
		rebuildInterceptorChain()

		return this
	}

	/**
	 * Unregister an interceptor class from this state
	 *
	 * @interceptorKey The interceptor key class to register
	 */
	function unregister( required interceptorKey ){
		// unregister object
		var results = super.unregister( arguments.interceptorKey )
		// unregister metadata map
		structDelete( variables.metadataMap, arguments.interceptorKey )
		// Rebuild hot lookup chain
		rebuildInterceptorChain()

		return results
	}

	/**
	 * Checks if the passed interceptor key already exists
	 *
	 * @interceptorKey The interceptor key class to verify it exists
	 */
	function exists( required interceptorKey ){
		return super.exists( arguments.interceptorKey )
	}

	/**
	 * Get an interceptor from this state. Else return a blank structure if not found
	 *
	 * @interceptorKey The interceptor key class to retrieve
	 */
	function getInterceptor( required interceptorKey ){
		return super.getObject( arguments.interceptorKey )
	}

	/**
	 * Process this state's interceptors. If you use the asynchronous facilities, you will get a thread structure report as a result.
	 * On the synchronous path (the default), returns true if an interceptor short-circuited the chain by returning true; false otherwise.
	 *
	 * @event            The event context object.
	 * @data             A data structure used to pass intercepted information.
	 * @async            If true, the entire interception chain will be ran in a separate thread.
	 * @asyncAll         If true, each interceptor in the interception chain will be ran in a separate thread and then joined together at the end.
	 * @asyncAllJoin     If true, each interceptor in the interception chain will be ran in a separate thread and joined together at the end by default.  If you set this flag to false then there will be no joining and waiting for the threads to finalize.
	 * @asyncPriority    The thread priority to be used. Either LOW, NORMAL or HIGH. The default value is NORMAL
	 * @asyncJoinTimeout The timeout in milliseconds for the join thread to wait for interceptor threads to finish.  By default there is no timeout.
	 * @buffer           hint="The request buffer object that can be used to produce output from interceptor chains
	 */
	function process(
		required event,
		required data,
		boolean async            = false,
		boolean asyncAll         = false,
		boolean asyncAllJoin     = true,
		string asyncPriority     = "NORMAL",
		numeric asyncJoinTimeout = 0,
		required buffer
	){
		if ( arguments.async AND !variables.utility.inThread() ) {
			return processAsync(
				event         = arguments.event,
				data          = arguments.data,
				asyncPriority = arguments.asyncPriority,
				buffer        = arguments.buffer
			)
		} else if ( arguments.asyncAll AND !variables.utility.inThread() ) {
			return processAsyncAll( argumentCollection = arguments )
		} else {
			return processSync(
				event  = arguments.event,
				data   = arguments.data,
				buffer = arguments.buffer
			)
		}
	}

	/**
	 * Process an execution asynchronously
	 *
	 * @event         The event context object.
	 * @data          A data structure used to pass intercepted information.
	 * @asyncPriority The thread priority to be used. Either LOW, NORMAL or HIGH. The default value is NORMAL
	 * @buffer        hint="The request buffer object that can be used to produce output from interceptor chains
	 */
	function processAsync(
		required event,
		required data,
		string asyncPriority = "NORMAL",
		required buffer
	){
		var threadName = "cbox_ichain_#replace(
			variables.uuidHelper.randomUUID(),
			"-",
			"",
			"all"
		)#"

		if ( getLogger().canDebug() ) {
			getLogger().debug(
				"Threading interceptor chain: '#getState()#' with thread name: #threadName#, priority: #arguments.asyncPriority#"
			)
		}

		// Store data so we don't have to duplicate via stupid cfthread
		request[ threadName ] = arguments.data

		thread
			name      ="#threadName#"
			action    ="run"
			priority  ="#arguments.asyncPriority#"
			threadName="#threadName#"
			buffer    ="#arguments.buffer#" {
			try {
				// Process it
				variables.processSync(
					// We do this, because the thread component in ACF/LUCEE duplicates everything: Dumb!
					event  = variables.controller.getRequestService().getContext(),
					data   = request[ attributes.threadName ],
					buffer = attributes.buffer
				);

				if ( getLogger().canDebug() ) {
					getLogger().debug(
						"Finished threaded interceptor chain: #getState()# with thread name: #attributes.threadName#",
						thread
					)
				}
			} catch ( any e ) {
				variables.controller.getInterceptorService().announce( "onException", { exception : e } )
				rethrow
			}
		}

		return cfthread[ threadName ]
	}

	/**
	 * Process an execution asynchronously
	 *
	 * @event            The event context object.
	 * @data             A data structure used to pass intercepted information.
	 * @asyncAllJoin     If true, each interceptor in the interception chain will be ran in a separate thread and joined together at the end by default.  If you set this flag to false then there will be no joining and waiting for the threads to finalize.
	 * @asyncPriority    The thread priority to be used. Either LOW, NORMAL or HIGH. The default value is NORMAL
	 * @asyncJoinTimeout The timeout in milliseconds for the join thread to wait for interceptor threads to finish.  By default there is no timeout.
	 * @buffer           hint="The request buffer object that can be used to produce output from interceptor chains
	 */
	function processAsyncAll(
		required event,
		required data,
		boolean asyncAllJoin     = true,
		string asyncPriority     = "NORMAL",
		numeric asyncJoinTimeout = 0,
		required buffer
	){
		var interceptors = getInterceptors()
		var threadnames  = []
		var threadData   = {}

		if ( getLogger().canDebug() ) {
			getLogger().debug(
				"AsyncAll interceptor chain starting for: '#getState()#' with join: #arguments.asyncAllJoin#, priority: #arguments.asyncPriority#, timeout: #arguments.asyncJoinTimeout#"
			)
		}

		var thisThreadGroup = "ichain_async_group_#replace(
			variables.uuidHelper.randomUUID(),
			"-",
			"",
			"all"
		)#"

		// Seed data into thread group request tracker to avoid stupid cfthread data duplication
		request[ thisThreadGroup ] = arguments.data

		for ( var key in structKeyArray( interceptors ) ) {
			var thisThreadName = "ichain_#key#_#replace(
				variables.uuidHelper.randomUUID(),
				"-",
				"",
				"all"
			)#"
			threadNames.append( thisThreadName )

			thread
				name       ="#thisThreadName#"
				action     ="run"
				priority   ="#arguments.asyncPriority#"
				threadName ="#thisThreadName#"
				threadGroup="#thisThreadGroup#"
				buffer     ="#arguments.buffer#"
				key        ="#key#" {
				try {
					// Retrieve interceptor to fire and local context
					var thisInterceptor = this.getInterceptors().get( attributes.key )
					var threadEvent     = variables.controller.getRequestService().getContext()

					// Check if we can execute this Interceptor
					if ( variables.isExecutable( thisInterceptor, threadEvent, attributes.key ) ) {
						var invocationArgs = {
							"event"         : threadEvent,
							"data"          : request[ attributes.threadGroup ],
							"interceptData" : request[ attributes.threadGroup ], // Remove by ColdBox 7 DEPRECATED
							"buffer"        : attributes.buffer,
							"rc"            : threadEvent.getCollection(),
							"prc"           : threadEvent.getPrivateCollection()
						}
						var canDebug = getLogger().canDebug()

						// Invoke the execution point
						variables.invoker(
							interceptor    = thisInterceptor,
							interceptorKey = attributes.key,
							invocationArgs = invocationArgs,
							canDebug       = canDebug,
							state          = this.getState(),
							log            = getLogger()
						)

						// Debug interceptions
						if ( canDebug ) {
							getLogger().debug(
								"Interceptor '#getMetadata( thisInterceptor ).name#' fired in asyncAll chain: '#this.getState()#'"
							)
						}
					}
				} catch ( any e ) {
					variables.controller.getInterceptorService().announce( "onException", { exception : e } )
					rethrow;
				}
			}
			// end thread
		}
		// end for loop

		if ( arguments.asyncAllJoin ) {
			if ( getLogger().canDebug() ) {
				getLogger().debug(
					"AsyncAll interceptor chain waiting for join: '#getState()#', timeout: #arguments.asyncJoinTimeout# "
				)
			}
			thread action="join" name="#arrayToList( threadNames )#" timeout="#arguments.asyncJoinTimeout#";
		}

		if ( getLogger().canDebug() ) {
			getLogger().debug(
				"AsyncAll interceptor chain ended for: '#getState()#' with join: #arguments.asyncAllJoin#, priority: #arguments.asyncPriority#, timeout: #arguments.asyncJoinTimeout#"
			)
		}

		for ( var threadIndex in threadNames ) {
			threadData[ threadIndex ] = cfthread[ threadIndex ]
		}

		return threadData
	}

	/**
	 * Process an execution synchronously
	 *
	 * @event  The event context object.
	 * @data   A data structure used to pass intercepted information.
	 * @buffer hint="The request buffer object that can be used to produce output from interceptor chains
	 *
	 * @return True if an interceptor short-circuited the chain by returning true; false otherwise
	 */
	boolean function processSync( required event, required data, required buffer ){
		var interceptorChain = variables.interceptorChain
		var interceptorCount = interceptorChain.len()
		var log              = getLogger()
		var canDebug         = log.canDebug()
		var state            = getState()

		// Debug interceptions
		if ( canDebug ) {
			log.debug( "Starting '#state#' chain with #interceptorCount# interceptors" )
		}

		if ( !interceptorCount ) {
			if ( canDebug ) {
				log.debug( "Finished '#state#' execution chain" )
			}
			return false
		}

		var currentEvent      = ""
		var wasShortCircuited = false
		var invocationArgs    = {
			"event"         : arguments.event,
			"data"          : arguments.data,
			"interceptData" : arguments.data, // Remove by ColdBox 7 DEPRECATED
			"buffer"        : arguments.buffer,
			"rc"            : arguments.event.getCollection(),
			"prc"           : arguments.event.getPrivateCollection()
		}

		// Loop and execute each interceptor as registered in order
		for ( var interceptorIndex = 1; interceptorIndex <= interceptorCount; interceptorIndex++ ) {
			var interceptorEntry = interceptorChain[ interceptorIndex ]
			var eventPattern     = interceptorEntry.eventPattern

			// Check if we can execute this Interceptor
			if ( len( eventPattern ) ) {
				if ( !len( currentEvent ) ) {
					currentEvent = arguments.event.getCurrentEvent()
				}

				if ( NOT reFindNoCase( eventPattern, currentEvent ) ) {
					if ( canDebug ) {
						log.debug(
							"Interceptor '#getMetadata( interceptorEntry.interceptor ).name#' did NOT fire in chain: '#state#' due to event pattern mismatch: #eventPattern#."
						)
					}
					continue;
				}
			}

			// Async Execution only if not in a thread already, no buffer sent for async calls
			if ( interceptorEntry.async AND NOT variables.utility.inThread() ) {
				invokerAsync(
					event          = arguments.event,
					data           = arguments.data,
					interceptorKey = interceptorEntry.key,
					asyncPriority  = interceptorEntry.asyncPriority,
					buffer         = arguments.buffer
				)
			}
			// Invoke the execution point synchronously
			else if (
				invoker(
					interceptor          = interceptorEntry.interceptor,
					interceptorKey       = interceptorEntry.key,
					interceptorIsClosure = interceptorEntry.isClosure,
					invocationArgs       = invocationArgs,
					canDebug             = canDebug,
					state                = state,
					log                  = log
				)
			) {
				wasShortCircuited = true
				break;
			}
		}

		// Debug interceptions
		if ( canDebug ) {
			log.debug( "Finished '#state#' execution chain" )
		}

		return wasShortCircuited
	}

	/**
	 * Checks if an interceptor is executable or not. Boolean
	 *
	 * @target    The target interceptor to check
	 * @event     The event context
	 * @targetKey The target interceptor key
	 */
	boolean function isExecutable(
		required target,
		required event,
		required targetKey
	){
		// Get interceptor metadata
		var iData = variables.metadataMap[ arguments.targetKey ]

		// Check if the event pattern matches the current event, else return false
		if (
			len( iData.eventPattern )
			AND
			NOT reFindNoCase( iData.eventPattern, arguments.event.getCurrentEvent() )
		) {
			// Log it
			if ( getLogger().canDebug() ) {
				getLogger().debug(
					"Interceptor '#getMetadata( arguments.target ).name#' did NOT fire in chain: '#getState()#' due to event pattern mismatch: #iData.eventPattern#."
				)
			}

			return false
		}

		// No event pattern found, we can execute.
		return true
	}

	/**
	 * Get the interceptors linked hash map
	 */
	function getInterceptors(){
		return super.getPool()
	}

	/**
	 * Rebuild the ordered runtime interceptor chain from the registered pool
	 */
	private function rebuildInterceptorChain(){
		var newChain           = []
		var interceptorEntries = getInterceptors().entrySet().iterator()

		while ( interceptorEntries.hasNext() ) {
			var interceptorEntry = interceptorEntries.next()
			var key              = interceptorEntry.getKey()
			var interceptor      = interceptorEntry.getValue()
			var metadata         = variables.metadataMap[ key ]

			newChain.append( {
				"key"           : key,
				"interceptor"   : interceptor,
				"metadata"      : metadata,
				"eventPattern"  : metadata.eventPattern,
				"async"         : metadata.async,
				"asyncPriority" : metadata.asyncPriority,
				"isClosure"     : isClosure( interceptor )
			} )
		}

		variables.interceptorChain = newChain

		return this
	}

	/**
	 * Execute an interceptor execution point asynchronously
	 *
	 * @event          The event context object.
	 * @data           A data structure used to pass intercepted information.
	 * @interceptorKey The interceptor key to invoke
	 * @asyncPriority  The thread priority for execution
	 * @buffer         hint="The request buffer object that can be used to produce output from interceptor chains
	 */
	private function invokerAsync(
		required event,
		required data,
		required interceptorKey,
		asyncPriority = "NORMAL",
		required buffer
	){
		var thisThreadName = "asyncInterceptor_#arguments.interceptorKey#_#replace(
			variables.uuidHelper.randomUUID(),
			"-",
			"",
			"all"
		)#";

		if ( getLogger().canDebug() ) {
			getLogger().debug(
				"Async interception starting for: '#getState()#', interceptor: #arguments.interceptorKey#, priority: #arguments.asyncPriority#"
			);
		}
		thread
			name      ="#thisThreadName#"
			action    ="run"
			priority  ="#arguments.asyncPriority#"
			data      ="#arguments.data#"
			threadName="#thisThreadName#"
			key       ="#arguments.interceptorKey#"
			buffer    ="#arguments.buffer#" {
			try {
				var threadEvent = variables.controller.getRequestService().getContext();

				var args = {
					"event"  : threadEvent,
					"data"   : attributes.data,
					"buffer" : attributes.buffer,
					"rc"     : threadEvent.getCollection(),
					"prc"    : threadEvent.getPrivateCollection()
				};

				invoke(
					this.getInterceptors().get( attributes.key ),
					this.getState(),
					args
				);

				if ( getLogger().canDebug() ) {
					getLogger().debug(
						"Async interception ended for: '#this.getState()#', interceptor: #attributes.key#, threadName: #attributes.threadName#"
					);
				}
			} catch ( any e ) {
				variables.controller.getInterceptorService().announce( "onException", { exception : e } );
				rethrow;
			}
		}
	}


	/**
	 * Execute an interceptor execution point synchronously
	 *
	 * @interceptor    The interceptor
	 * @event          The event context object.
	 * @data           A data structure used to pass intercepted information.
	 * @interceptorKey The interceptor key to invoke
	 * @buffer         hint="The request buffer object that can be used to produce output from interceptor chains
	 */
	private function invoker(
		required interceptor,
		required interceptorKey,
		boolean interceptorIsClosure = isClosure( arguments.interceptor ),
		required invocationArgs,
		required boolean canDebug,
		required state,
		required log
	){
		if ( arguments.canDebug ) {
			arguments.log.debug( "Interception started for: '#arguments.state#', key: #arguments.interceptorKey#" )
		}

		// Closure or object?
		if ( arguments.interceptorIsClosure ) {
			var results = arguments.interceptor( argumentCollection = arguments.invocationArgs )
		} else {
			var results = invoke(
				arguments.interceptor,
				arguments.state,
				arguments.invocationArgs
			)
		}

		if ( arguments.canDebug ) {
			arguments.log.debug( "Interception ended for: '#arguments.state#', key: #arguments.interceptorKey#" )
		}

		if ( !isNull( local.results ) and isBoolean( results ) ) {
			return results
		} else {
			return false
		}
	}

	/**
	 * Get the service logger
	 */
	function getLogger(){
		if ( isNull( variables.log ) ) {
			variables.log = variables.controller.getLogBox().getLogger( this )
		}
		return variables.log
	}

}
