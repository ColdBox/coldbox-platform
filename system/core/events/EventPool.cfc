/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This object models an event driven pool of objects
 */
component accessors="true" {

	/**
	 * The collection of listeners in the pool backed by a linked hashmap which is synchronized for threading
	 */
	property name="pool" doc_generic="java.util.LinkedHashMap";

	/**
	 * The event pool state name
	 */
	property name="state";

	/**
	 * Ordered hot chain array for fast iteration during processing.
	 * Rebuilt on every register/unregister to avoid map lookups in the hot path.
	 */
	property name="listenerChain" type="array";

	/**
	 * Constructor
	 *
	 * @state The name of the pool
	 */
	function init( required state ){
		// Create the event pool, start with 5 instead of 16 to save space
		variables.pool = createObject( "java", "java.util.Collections" ).synchronizedMap(
			createObject( "java", "java.util.LinkedHashMap" ).init( 5 )
		)
		variables.state         = arguments.state
		// Ordered hot chain for fast processing iteration
		variables.listenerChain = []

		return this
	}

	/**
	 * Register an object with this pool
	 *
	 * @key    The key of the object, will be lowercased to conform to non-case sensitivity
	 * @target The object
	 *
	 * @return EventPool
	 */
	function register( required key, required target ){
		variables.pool.put( lCase( arguments.key ), arguments.target )
		// Rebuild hot lookup chain
		rebuildListenerChain()
		return this
	}

	/**
	 * Unregister an object from this pool
	 *
	 * @key The key of the object, will be lowercased to conform to non-case sensitivity
	 */
	boolean function unregister( required key ){
		var results = variables.pool.remove( lCase( arguments.key ) )
		// Rebuild hot lookup chain
		rebuildListenerChain()
		return isNull( results ) ? false : true
	}

	/**
	 * Check if a key exists in the pool
	 */
	boolean function exists( required key ){
		return variables.pool.containsKey( lCase( arguments.key ) )
	}

	/**
	 * Get an object from this event pool. Else return a blank structure if not found
	 *
	 * @key The key name of the object
	 *
	 * @return The requested object or an empty structure
	 */
	any function getObject( required key ){
		return variables.pool.getOrDefault( lCase( arguments.key ), {} )
	}

	/**
	 * Process this event pool according to it's name.
	 *
	 * @data The data used in the interception call
	 *
	 * @return EventPool
	 */
	function process( required data ){
		var listenerChain = variables.listenerChain
		var listenerCount  = listenerChain.len()
		var state          = variables.state

		// Loop and execute each target object as registered in order
		for ( var listenerIndex = 1; listenerIndex <= listenerCount; listenerIndex++ ) {
			var listenerEntry = listenerChain[ listenerIndex ]
			// Invoke the execution point
			var stopChain = invoker(
				target = listenerEntry.target,
				data   = arguments.data,
				state  = state
			)

			// Check for results
			if ( stopChain ) {
				break;
			}
		}

		return this;
	}

	/**
	 * Execute the interception point, returns a value if the chain should be stopped (true) or ignored (void/false)
	 *
	 * @target The target object
	 * @data   The data used in the interception call
	 * @state  The state name to invoke
	 *
	 * @return A boolean indicator that the interception chain needs to be broken or not.
	 */
	private boolean function invoker(
		required target,
		required data,
		required state
	){
		var results = invoke(
			arguments.target,
			arguments.state,
			{ interceptData : arguments.data, data : arguments.data }
		)

		if ( !isNull( local.results ) && isBoolean( local.results ) ) {
			return results
		}

		return false
	}

	/**
	 * Rebuild the ordered runtime listener chain from the registered pool
	 */
	private function rebuildListenerChain(){
		var newChain           = []
		var listenerEntries = variables.pool.entrySet().iterator()

		while ( listenerEntries.hasNext() ) {
			var listenerEntry = listenerEntries.next()
			var key           = listenerEntry.getKey()
			var target        = listenerEntry.getValue()

			newChain.append( {
				"key"    : key,
				"target" : target
			} )
		}

		variables.listenerChain = newChain

		return this
	}

}
