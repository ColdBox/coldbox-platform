/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* This object models an interception state
*/
component accessors="true" {


	/**
	* Controller reference
	*/
	property name="controller";

	/**
	* Metadata map for objects
	*/
	property name="metadataMap";


	/**
	 * Constructor
	 *
	 * @state The interception state to model
	 * @logbox LogBox reference
	 * @controller The ColdBox Controller
	 */
	function init( required state, required logbox, required controller ){
		// instance pool
		variables.pool     = [];
		// pool size
		variables.poolSize = 0;
		// state
		variables.state    = arguments.state;
		// Controller
		variables.controller  = arguments.controller;
		// md ref map
		variables.metadataMap = structnew();
		// java system
		variables.javaSystem  = createObject( "java", "java.lang.System" );
		// Utilities
		variables.utility     = new coldbox.system.core.util.Util();
		// UUID Helper
		variables.uuidHelper  = createobject( "java", "java.util.UUID" );
		// Logger Object
		variables.log         = arguments.logbox.getLogger( this );

		return this;
	}

	/**
	 * Return the state's metadata map for it's registered interecptors
	 *
	 * @interceptorKey Pass a key and retrieve that interceptor's metadata map only
	 */
	function getMetadataMap( interceptorKey ){
		if ( !IsNull( arguments.interceptorKey ) && StructKeyExists( arguments, "interceptorKey" ) ) {
			return variables.metadataMap[ arguments.interceptorKey ];
		}

		return variables.metadataMap;
	}

	/**
	 * Register an interceptor class with this state
	 *
	 * @interceptorKey The interceptor key class to register
	 * @interceptor The interceptor reference from the cache.
	 * @interceptorMD The interceptor state metadata.
	 */
	function register( required interceptorKey, required interceptor, required interceptorMD ){
		ArrayAppend( variables.pool, { key=arguments.interceptorKey, target=arguments.interceptor } );
		variables.poolSize = ArrayLen( variables.pool );
		variables.metadataMap[ arguments.interceptorKey ] = arguments.interceptorMd;

		return this;
	}

	/**
	 * Unregister an interceptor class from this state
	 *
	 * @interceptorKey The interceptor key class to register
	 */
	function unregister( required interceptorKey ){
		var unregistered = false;

		for( var i=variables.pool.len(); i>0; i-- ) {
			if ( variables.pool[ i ].key == arguments.interceptorKey ) {
				ArrayDeleteAt( variables.pool, i );
				unregistered = true;
			}
		}

		StructDelete( variables.metadataMap, arguments.interceptorKey );
		variables.poolSize = ArrayLen( variables.pool );

		return unregistered;
	}

	/**
	 * Checks if the passed interceptor key already exists
	 *
	 * @interceptorKey The interceptor key class to verify it exists
	 */
	function exists( required interceptorKey ){
		return StructKeyExists( variables.metadataMap, arguments.interceptorKey );
	}

	/**
	 * Get an interceptor from this state. Else return a blank structure if not found
	 *
	 * @interceptorKey The interceptor key class to retrieve
	 */
	function getInterceptor( required interceptorKey ){
		var i = 0;
		for( i=1; i<=variables.poolSize; i++ ) {
			if ( variables.pool[ i ].key == arguments.interceptorKey ) {
				return variables.pool[ i ].target;
			}
		}
	}

	public string function getState() {
		return variables.state;
	}


	/**
	 * Process this state's interceptors. If you use the asynchronous facilities, you will get a thread structure report as a result
	 *
	 * @interceptorKey The interceptor key class to retrieve
	 * @event The event context object.
	 * @interceptData A data structure used to pass intercepted information.
	 * @async If true, the entire interception chain will be ran in a separate thread.
	 * @asyncAll If true, each interceptor in the interception chain will be ran in a separate thread and then joined together at the end.
	 * @asyncAllJoin If true, each interceptor in the interception chain will be ran in a separate thread and joined together at the end by default.  If you set this flag to false then there will be no joining and waiting for the threads to finalize.
	 * @asyncPriority The thread priority to be used. Either LOW, NORMAL or HIGH. The default value is NORMAL
	 * @asyncJoinTimeout The timeout in milliseconds for the join thread to wait for interceptor threads to finish.  By default there is no timeout.
	 * @buffer  hint="The request buffer object that can be used to produce output from interceptor chains
	 */
	function process(
		required event,
		required interceptData,
		boolean async=false,
		boolean asyncAll=false,
		boolean asyncAllJoin=true,
		string asyncPriority="NORMAL",
		numeric asyncJoinTimeout=0,
		required buffer
	){
		if ( arguments.async && !variables.utility.inThread() ) {
			return processAsync(
				  event         = arguments.event
				, interceptData = arguments.interceptData
				, asyncPriority = arguments.asyncPriority
				, buffer        = arguments.buffer
			);
		} else if ( arguments.asyncAll AND NOT variables.utility.inThread() ) {
			return processAsyncAll( argumentCollection=arguments );
		} else {
			processSync( event=arguments.event, interceptData=arguments.interceptData, buffer=arguments.buffer );
		}
	}

	/**
	 * Process an execution asynchronously
	 *
	 * @event The event context object.
	 * @interceptData A data structure used to pass intercepted information.
	 * @asyncPriority The thread priority to be used. Either LOW, NORMAL or HIGH. The default value is NORMAL
	 * @buffer  hint="The request buffer object that can be used to produce output from interceptor chains
	 */
	function processAsync(
		required event,
		required interceptData,
		string asyncPriority="NORMAL",
		required buffer
	){
		var threadName = "cbox_ichain_#replace( variables.uuidHelper.randomUUID(), "-", "", "all" )#";

		if ( variables.log.canDebug() ) {
			variables.log.debug("Threading interceptor chain: '#getState()#' with thread name: #threadName#, priority: #arguments.asyncPriority#" );
		}

		thread name          = threadName
		       action        = "run"
		       priority      = arguments.asyncPriority
		       interceptData = arguments.interceptData
		       threadName    = threadName
		       buffer        = arguments.buffer {

		    variables.processSync(
				event 			= variables.controller.getRequestService().getContext(),
				interceptData	= attributes.interceptData,
				buffer 			= attributes.buffer
			);

			if ( variables.log.canDebug() ) {
				variables.log.debug( "Finished threaded interceptor chain: #getState()# with thread name: #attributes.threadName#", thread );
			}
		}

		return cfthread[ threadName ];
	}

	/**
	 * Process an execution asynchronously
	 *
	 * @event The event context object.
	 * @interceptData A data structure used to pass intercepted information.
	 * @asyncAllJoin If true, each interceptor in the interception chain will be ran in a separate thread and joined together at the end by default.  If you set this flag to false then there will be no joining and waiting for the threads to finalize.
	 * @asyncPriority The thread priority to be used. Either LOW, NORMAL or HIGH. The default value is NORMAL
	 * @asyncJoinTimeout The timeout in milliseconds for the join thread to wait for interceptor threads to finish.  By default there is no timeout.
	 * @buffer  hint="The request buffer object that can be used to produce output from interceptor chains
	 */
	function processAsyncAll(
		required event,
		required interceptData,
		boolean asyncAllJoin=true,
		string asyncPriority="NORMAL",
		numeric asyncJoinTimeout=0,
		required buffer
	){
		var threadNames    = [];
		var thisThreadName = "";
		var key            = "";
		var threadData     = {};
		var threadIndex    = "";
		var i              = 0;

		if ( variables.log.canDebug() ) {
			variables.log.debug("AsyncAll interceptor chain starting for: '#getState()#' with join: #arguments.asyncAllJoin#, priority: #arguments.asyncPriority#, timeout: #arguments.asyncJoinTimeout#" );
		}

		for( i=1; i<=poolSize; i++ ){
			var key             = variables.pool[ i ].key;

			thisThreadName = "ichain_#key#_#replace( variables.uuidHelper.randomUUID(), "-", "", "all" )#";
			ArrayAppend( threadNames, thisThreadName );

			thread name          = thisThreadName
			       action        = "run"
			       priority      = arguments.asyncPriority
			       interceptData = arguments.interceptData
			       threadName    = thisThreadName
			       buffer        = arguments.buffer
			       key           = key {

				var thisInterceptor = this.getInterceptor( attributes.key );

				if( variables.isExecutable( thisInterceptor, attributes.event, attributes.key ) ){
					variables.invoker(
						interceptor 	= thisInterceptor,
						event 			= variables.controller.getRequestService().getContext(),
						interceptData 	= attributes.interceptData,
						interceptorKey 	= attributes.key,
						buffer 			= attributes.buffer
					);

					if( variables.log.canDebug() ){
						variables.log.debug( "Interceptor '#getMetadata( thisInterceptor ).name#' fired in asyncAll chain: '#this.getState()#'" );
					}
				}
			}
		}

		if ( arguments.asyncAllJoin ) {
			if ( variables.log.canDebug() ) {
				variables.log.debug("AsyncAll interceptor chain waiting for join: '#getState()#', timeout: #arguments.asyncJoinTimeout# " );
			}

			thread action="join" name=ArrayToList( threadNames ) timeout=arguments.asyncJoinTimeout;
		}

		if ( variables.log.canDebug() ) {
			variables.log.debug("AsyncAll interceptor chain ended for: '#getState()#' with join: #arguments.asyncAllJoin#, priority: #arguments.asyncPriority#, timeout: #arguments.asyncJoinTimeout#" );
		}

		for( var threadIndex in threadNames ) {
			threadData[ threadIndex ] = cfthread[ threadIndex ];
		}

		return threadData;
	}

    /**
	 * Process an execution synchronously
	 *
	 * @event The event context object.
	 * @interceptData A data structure used to pass intercepted information.
	 * @buffer  hint="The request buffer object that can be used to produce output from interceptor chains
	 */
	function processSync(
		required event,
		required interceptData,
		required buffer
	){
		var i = 0;

		if ( variables.log.canDebug() ){
			variables.log.debug( "Starting '#getState()#' chain with #structCount( interceptors )# interceptors" );
		}

		for( i=1; i<=variables.poolSize; i++ ){
			var key             = variables.pool[ i ].key;
			var thisInterceptor = variables.pool[ i ].target;

			if( isExecutable( thisInterceptor, arguments.event, key ) ){
				if ( variables.metadataMap[ key ].async && !variables.utility.inThread() ){
					invokerAsync(
						  event          = arguments.event
						, interceptData  = arguments.interceptData
						, interceptorKey = key
						, asyncPriority  = variables.metadataMap[ key ].asyncPriority
						, buffer         = arguments.buffer
					);
				} else if(
					invoker(
						  interceptor    = thisInterceptor
						, event          = arguments.event
						, interceptData  = arguments.interceptData
						, interceptorKey = key
						, buffer         = arguments.buffer
					)
				){
					break;
				}
			}
		}

		if( variables.log.canDebug() ){
			variables.log.debug( "Finished '#getState()#' execution chain" );
		}

	}

	/**
	 * Checks if an interceptor is executable or not. Boolean
	 *
	 * @target The target interceptor to check
	 * @event The event context
	 * @targetKey The target interceptor key
	 */
	boolean function isExecutable( required target, required event, required targetKey ){
		// Get interceptor metadata
		var iData = variables.metadataMap[ arguments.targetKey ];

		// Check if the event pattern matches the current event, else return false
		if( len( iData.eventPattern )
			AND
			NOT reFindNoCase( iData.eventPattern, arguments.event.getCurrentEvent() )
		){

			// Log it
			if( variables.log.canDebug() ){
				variables.log.debug("Interceptor '#getMetadata( arguments.target ).name#' did NOT fire in chain: '#getState()#' due to event pattern mismatch: #iData.eventPattern#.");
			}

			return false;
		}

		// No event pattern found, we can execute.
		return true;
	}

	/**
	 * Get the interceptors linked hash map
	 */
	function getInterceptors(){
		return variables.pool;
	}

	/**
	 * Execute an interceptor execution point asynchronously
	 *
	 * @event The event context object.
	 * @interceptData A data structure used to pass intercepted information.
	 * @interceptorKey The interceptor key to invoke
	 * @asyncPriority The thread priority for execution
	 * @buffer  hint="The request buffer object that can be used to produce output from interceptor chains
	 */
	private function invokerAsync(
		required event,
		required interceptData,
		required interceptorKey,
		asyncPriority="NORMAL",
		required buffer
	){
		var thisThreadName = "asyncInterceptor_#arguments.interceptorKey#_#replace( variables.uuidHelper.randomUUID(), "-", "", "all" )#";

		if ( variables.log.canDebug() ) {
			variables.log.debug("Async interception starting for: '#getState()#', interceptor: #arguments.interceptorKey#, priority: #arguments.asyncPriority#" );
		}

		thread name          = thisThreadName
		       action        = "run"
		       priority      = arguments.asyncPriority
		       event         = arguments.event
		       interceptData = arguments.interceptData
		       threadName    = thisThreadName
		       key           = arguments.interceptorKey
		       buffer        = arguments.buffer {

			var args = {
				"event" 		= attributes.event,
				"interceptData" = attributes.interceptData,
				"buffer" 		= attributes.buffer,
				"rc" 			= attributes.event.getCollection(),
				"prc" 			= attributes.event.getPrivateCollection()
			};

			invoke( this.getInterceptor( attributes.key ), this.getState(), args );

			if( variables.log.canDebug() ){
				variables.log.debug( "Async interception ended for: '#this.getState()#', interceptor: #attributes.key#, threadName: #attributes.threadName#" );
			}
		}

	}


	/**
	 * Execute an interceptor execution point asynchronously
	 *
	 * @interceptor The interceptor
	 * @event The event context object.
	 * @interceptData A data structure used to pass intercepted information.
	 * @interceptorKey The interceptor key to invoke
	 * @buffer  hint="The request buffer object that can be used to produce output from interceptor chains
	 */
	private function invoker(
		required interceptor,
		required event,
		required interceptData,
		required interceptorKey,
		required buffer
	){
		var refLocal = {};

		if ( variables.log.canDebug() ) {
			variables.log.debug( "Interception started for: '#getState()#', key: #arguments.interceptorKey#" );
		}


		refLocal.results = invoke( arguments.interceptor, getState(), {
			  event         = arguments.event
			, interceptData = arguments.interceptData
			, buffer        = arguments.buffer
			, rc            = arguments.event.getCollection()
			, prc           = arguments.event.getPrivateCollection()
		} );

		if ( variables.log.canDebug() ) {
			variables.log.debug( "Interception ended for: '#getState()#', key: #arguments.interceptorKey#" );
		}


		if ( StructKeyExists( refLocal, "results" ) && IsBoolean( refLocal.results ) ) {
			return refLocal.results;
		}

		return false;

	}

}