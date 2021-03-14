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
	 * Constructor
	 *
	 * @state The name of the pool
	 */
	function init( required state ){
		// Create the event pool, start with 5 instead of 16 to save space
		variables.pool  = createObject( "java", "java.util.LinkedHashMap" ).init( 5 );
		variables.state = arguments.state;

		return this;
	}

	/**
	 * Stupid accessors in CF11 does not work.
	 */
	function getPool(){
		return variables.pool;
	}

	/**
	 * Register an object with this pool
	 *
	 * @key The key of the object
	 * @target The object
	 *
	 * @return EventPool
	 */
	function register( required key, required target ){
		variables.pool.put( lCase( arguments.key ), arguments.target );
		return this;
	}

	/**
	 * Unregister an object from this pool
	 *
	 * @key The key of the object
	 */
	boolean function unregister( required key ){
		arguments.key = lCase( arguments.key );
		if ( structKeyExists( variables.pool, arguments.key ) ) {
			variables.pool.remove( arguments.key );
			return true;
		}
		return false;
	}

	/**
	 * Check if a key exists in the pool
	 */
	boolean function exists( required key ){
		return structKeyExists( variables.pool, lCase( arguments.key ) );
	}

	/**
	 * Get an object from this event pool. Else return a blank structure if not found
	 */
	function getObject( required key ){
		arguments.key = lCase( arguments.key );
		if ( structKeyExists( variables.pool, arguments.key ) ) {
			return variables.pool[ arguments.key ];
		}
		return {};
	}

	/**
	 * Process this event pool according to it's name.
	 *
	 * @data The data used in the interception call
	 *
	 * @return EventPool
	 */
	function process( required data ){
		// Loop and execute each target object as registered in order
		for ( var key in variables.pool ) {
			// Invoke the execution point
			var stopChain = invoker( variables.pool[ key ], arguments.data );

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
	 * @data The data used in the interception call
	 *
	 */
	private function invoker( required target, required data ){
		var results = invoke(
			arguments.target,
			variables.state,
			{
				interceptData : arguments.data,
				data : arguments.data
			}
		);

		if ( !isNull( local.results ) && isBoolean( results ) ) {
			return results;
		}

		return false;
	}

}
