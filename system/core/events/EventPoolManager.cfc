/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A basic event pool manager for observed event pools. This event manager will manage 1 or more event pools.
 * The manager will inspect target objects for implemented functions and match them to event states.
 * However, if a function has the metadata attribute of 'observe=true' on it, then it will also add it
 * as a custom state
 */
component accessors="true" {

	/**
	 * Event states to listen for
	 */
	property name="eventStates";

	/**
	 * Stop recursion classes
	 */
	property name="stopRecursionClasses";

	/**
	 * Pool container struct
	 */
	property name="eventPoolContainer" type="struct";

	/**
	 * Constructor
	 *
	 * @eventStates          The event states to listen for
	 * @stopRecursionClasses The classes (comma-delim) to not inspect for events
	 */
	function init( required array eventStates, stopRecursionClasses = "" ){
		// Setup properties of the event manager
		variables.eventStates          = arguments.eventStates;
		variables.stopRecursionClasses = arguments.stopRecursionClasses;
		// class id code
		variables.classID              = createUUID();
		// Init event pool container
		variables.eventPoolContainer   = structNew();

		return this;
	}

	/**
	 * Process a state announcement. If the state does not exist it will ignore it.
	 *
	 * @state The state to process
	 * @data  The data to pass into the interception event
	 *
	 * @return EventPoolManager
	 */
	function announce( required state, struct data = {} ){
		if ( variables.eventPoolContainer.keyExists( arguments.state ) ) {
			variables.eventPoolContainer.find( arguments.state ).process( arguments.data );
		}

		return this;
	}

	/**
	 * Register an object in an event pool. If the target object is already in a state, it will not be added again.
	 * The object get's inspected for registered states or you can even send custom states in.
	 * Also, you can annotate the methods in the target object with 'observe=true' and we will register that state also.
	 *
	 * @target       The target object to register in an event pool
	 * @name         The name to use when registering the object.  If not passed, the name will be used from the object's metadata
	 * @customStates A comma delimited list of custom states, if the object or class sent in observes them
	 *
	 * @return EventPoolManager
	 */
	function register( required target, name = "", customStates = "" ){
		var md = getMetadata( arguments.target );

		// Check if name sent? If not, get the name from the last part of its name
		if ( NOT len( trim( arguments.name ) ) ) {
			arguments.name = listLast( md.name, "." );
		}

		lock
			name          ="EventPoolManager.#variables.classID#.RegisterObject.#arguments.name#"
			type          ="exclusive"
			throwontimeout="true"
			timeout       ="30" {
			// Append Custom Statess
			appendInterceptionPoints( arguments.customStates );

			// Register this target's event observation states with its appropriate interceptor/observation state
			parseMetadata( md, {} ).each( function( item ){
				registerInEventState( name, item, target );
			} );
		}

		return this;
	}

	/**
	 * Register an object with a specified event observation state.
	 *
	 * @key    The key to use when storing the object
	 * @state  The event state pool to save the object in
	 * @target The object to register
	 *
	 * @return EventPoolManager
	 */
	function registerInEventState( required key, required state, required target ){
		var eventPool = "";

		// Verify if the event state doesn't exist in the evnet pool, else create it
		if ( not structKeyExists( variables.eventPoolContainer, arguments.state ) ) {
			// Create new event pool
			eventPool                                       = new coldbox.system.core.events.EventPool( arguments.state );
			// Register it with this pool manager
			variables.eventPoolContainer[ arguments.state ] = eventPool;
		} else {
			// Get the State we need to register in
			eventPool = variables.eventPoolContainer[ arguments.state ];
		}

		// Verify if the target object is already in the state
		if ( NOT eventPool.exists( arguments.key ) ) {
			// Register it
			eventPool.register( arguments.key, arguments.target );
		}

		return this;
	}

	/**
	 * Get an object from the pool
	 *
	 * @name The name of the object
	 *
	 * @throws EventPoolManager.ObjectNotFound
	 */
	function getObject( required name ){
		for ( var key in variables.eventPoolContainer ) {
			if ( structFind( variables.eventPoolContainer, key ).exists( arguments.name ) ) {
				return structFind( variables.eventPoolContainer, key ).getObject( arguments.name );
			}
		}

		// Throw Exception
		throw(
			message = "Object: #arguments.name# not found in any event pool state: #structKeyList( variables.eventPoolContainer )#.",
			type    = "EventPoolManager.ObjectNotFound"
		);
	}

	/**
	 * Append a list of custom interception points to the CORE interception points and returns the points
	 *
	 * @customStates A comma delimited list or array of custom interception states to append. If they already exists, then they will not be added again.
	 *
	 * @return The current interception points
	 */
	array function appendInterceptionPoints( required customStates ){
		// Inflate custom points
		if ( isSimpleValue( arguments.customStates ) ) {
			arguments.customStates = listToArray( arguments.customStates );
		}

		for ( var thisPoint in arguments.customStates ) {
			if ( !arrayFindNoCase( variables.eventStates, thisPoint ) ) {
				variables.eventStates.append( thisPoint );
			}
		}

		return variables.eventStates;
	}

	/**
	 * Get an event pool by state name, if not found, it returns an empty structure
	 *
	 * @state The state to retrieve
	 */
	function getEventPool( required state ){
		if ( variables.eventPoolContainer.keyExists( arguments.state ) ) {
			return variables.eventPoolContainer[ arguments.state ];
		}
		return {};
	}

	/**
	 * Unregister an object form an event pool state. If no event state is passed, then we will unregister the object from ALL the pools the object exists in.
	 *
	 * @name  The name of the object to unregister
	 * @state The state to unregister from. If not passed, then we will unregister from ALL pools
	 */
	boolean function unregister( required name, state = "" ){
		var unregistered = false;

		// Unregister the object
		for ( var key in variables.eventPoolContainer ) {
			if ( len( arguments.state ) eq 0 OR arguments.state eq key ) {
				structFind( variables.eventPoolContainer, key ).unregister( arguments.name );
				unregistered = true;
			}
		}

		return unregistered;
	}

	/**
	 * I get a component's valid observation states for registration.
	 */
	private struct function parseMetadata( required metadata, required struct eventsFound ){
		// Register local functions
		if ( structKeyExists( arguments.metadata, "functions" ) ) {
			for ( var thisFunction in arguments.metadata.functions ) {
				// Verify observe annotation
				if ( thisFunction.keyExists( "interceptionPoint" ) ) {
					// Register the observation point just in case
					appendInterceptionPoints( thisFunction.name );
				}

				// verify it's an observation state and Not Registered already
				if (
					arrayFindNoCase( variables.eventStates, thisFunction.name )
					&&
					!arguments.eventsFound.keyExists( thisFunction.name )
				) {
					// Observation Event Found
					arguments.eventsFound[ thisFunction.name ] = true;
				}
			}
		}

		// Start Registering inheritances?
		if (
			structKeyExists( arguments.metadata, "extends" )
			AND
			NOT listFindNoCase( getStopRecursionClasses(), arguments.metadata.extends.name )
		) {
			parseMetadata( arguments.metadata.extends, arguments.eventsFound );
		}

		// return the event states found
		return arguments.eventsFound;
	}

	/**
	 * Get ColdBox utility object
	 */
	private function getUtil(){
		return new coldbox.system.core.util.Util();
	}

}
