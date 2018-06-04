/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This cfc acts as an URL/FORM facade for event caching.  The associated cache
 * will have to implement the IColdboxApplicationCache in order to retrieve the right
 * prefix keys.
 */
component accessors="true"{

	// Connected Provider
	property name="cacheProvider";

	/**
	 * Constructor
	 * @cacheProvider Provider to connect to
	 */
	function init( required cacheProvider ){
		variables.cacheProvider = arguments.cacheProvider;
		return this;
	}

	/**
	 * Build a unique hash from an incoming request context
	 *
	 * @event A request context object
	 */
	string function getUniqueHash( required event ){
		var incomingHash = hash(
			arguments.event.getCollection().filter( function( key, value ){
				// Remove event, not needed for hashing purposes
				return ( key != "event" );
			} ).toString()
		);
		var targetMixer	= {
			// Get the original incoming context hash
			"incomingHash" 	= incomingHash,
			// Multi-Host support
			"cgihost" 		= cgi.http_host
		};

		// Incorporate Routed Structs
		structAppend( targetMixer, arguments.event.getRoutedStruct(), true );

		// Return unique identifier
		return hash( targetMixer.toString() );
	}

	/**
	 * Build a unique hash according to an incoming query string, mostly used when calling the clear functions of
	 * cache providers
	 *
	 * @args A querystring based argument collection
	 */
	function buildHash( required string args ){
		var virtualRC = {};
		arguments.args
			.listToArray( "&" )
			.each( function( item ){
				virtualRC[ item.getToken( 1, "=" ).trim() ] = urlDecode( item.getToken( 2, "=" ).trim() );
			} );

		//writeDump( var = "==> Hash Args Struct: #virtualRC.toString()#", output="console" );
		var myStruct = {
			// Get the original incoming context hash according to incoming arguments
			"incomingHash" 	= hash( virtualRC.toString() ),
			// Multi-Host support
			"cgihost" 		= cgi.http_host
		};

		// return hash from cache key struct
		return hash( myStruct.toString() );
	}

	/**
	 * Build an event key according to passed in params
	 *
	 * @keySuffix The key suffix used in the cache key
	 * @targetEvent The targeted ColdBox event executed
	 * @targetContext The targeted request context object
	 */
	string function buildEventKey( required keySuffix, required targetEvent, required targetContext ){
		return buildBasicCacheKey( argumentCollection=arguments ) & getUniqueHash( arguments.targetContext );
	}

	/**
	 * Build an event key according to passed in params
	 *
	 * @keySuffix The key suffix used in the cache key
	 * @targetEvent The targeted ColdBox event executed
	 * @targetArgs A query string based argument collection like a query string
	 */
	string function buildEventKeyNoContext( required keySuffix, required targetEvent, required targetArgs ){
		return buildBasicCacheKey( argumentCollection=arguments ) & buildHash( arguments.targetArgs );
	}

	/**
	 * Builds a basic cache key without the hash component
	 * @keySuffix The key suffix used
	 * @targetEvent The targetged ColdBox event string
	 */
	string function buildBasicCacheKey( required keySuffix, required targetEvent ){
		return variables.cacheProvider.getEventCacheKeyPrefix() & arguments.targetEvent & "-" & arguments.keySuffix & "-";
	}


}