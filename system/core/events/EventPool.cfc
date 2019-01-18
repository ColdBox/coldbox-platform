/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This object models an event driven pool of objects
*/
component accessors="true"{

	/**
	 * The collection of listeners in the pool backed by a linked hashmap which is synchornized for threading
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
		variables.pool 	= createObject( "java", "java.util.LinkedHashMap" ).init( 5 );
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
		variables.pool.put( lcase( arguments.key ), arguments.target );
		return this;
	}

	/**
	 * Unregister an object from this pool
	 *
	 * @key The key of the object
	 */
	boolean function unregister( required key ){
		arguments.key = lcase( arguments.key );
		if( structKeyExists( variables.pool, arguments.key ) ){
			variables.pool.remove( arguments.key );
			return true;
		}
		return false;
	}

	/**
	 * Check if a key exists in the pool
	 */
	boolean function exists( required key ){
		return structKeyExists( variables.pool, lcase( arguments.key ) );
	}

	/**
	 * Get an object from this event pool. Else return a blank structure if not found
	 */
	function getObject( required key ){
		arguments.key = lcase( arguments.key );
		if( structKeyExists( variables.pool, arguments.key ) ){
			return variables.pool[ arguments.key ];
		}
		return {};
	}

	/**
	 * Process this event pool according to it's name.
	 *
	 * @interceptData The data used in the interception call
	 * @interceptData.doc_generic struct
	 *
	 * @return EventPool
	 */
	function process( required interceptData ){
		// Loop and execute each target object as registered in order
		for( var key in variables.pool ){
			// Invoke the execution point
			var stopChain = invoker( variables.pool[ key ], arguments.interceptData );

			// Check for results
			if( stopChain ){ break; }
		}

		return this;
	}

	/**
	 * Execute the interception point, returns a value if the chain should be stopped (true) or ignored (void/false)
	 *
	 * @target The target object
	 * @interceptData The data used in the interception call
	 * @interceptData.doc_generic struct
	 *
	 */
	private function invoker( required target, required interceptData ){
		var results = invoke(
			arguments.target,
			variables.state,
			{ interceptData = arguments.interceptData }
		);

		if( !isNull( results ) && isBoolean( results ) ){
			return results;
		}

		return false;
	}

}