/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This cfc acts as an URL/FORM facade for event caching.  The associated cache
 * will have to implement the IColdboxApplicationCache in order to retrieve the right
 * prefix keys.
 */
component accessors="true" {

	// Connected Provider
	property name="cacheProvider";

	/**
	 * Constructor
	 *
	 * @cacheProvider Provider to connect to
	 */
	function init( required cacheProvider ){
		variables.cacheProvider = arguments.cacheProvider;
		variables.jTreeMap      = createObject( "java", "java.util.TreeMap" );
		return this;
	}

	/**
	 * Build an app link via the request context object
	 */
	string function buildAppLink(){
		return variables.cacheProvider
			.getColdBox()
			.getRequestService()
			.getContext()
			.getSesBaseUrl();
	}

	/**
	 * Build a unique hash from an incoming request context
	 *
	 * @event A request context object
	 */
	string function getUniqueHash( required event ){
		var rcTarget = arguments.event
			.getCollection()
			.filter( function( key, value ){
				// Remove event, not needed for hashing purposes
				return ( key != "event" );
			} );

		// systemOutput( "=====> uniquehash-rcTarget: #variables.jTreeMap.init( rcTarget ).toString()#", true );
		// systemOutput( "=====> uniquehash-rcTargetHash: #hash( variables.jTreeMap.init( rcTarget ).toString() )#", true );

		var targetMixer = {
			// Get the original incoming context hash
			"incomingHash" : hash( variables.jTreeMap.init( rcTarget ).toString() ),
			// Multi-Host support
			"cgihost"      : buildAppLink()
		};

		// Incorporate Routed Structs
		structAppend(
			targetMixer,
			arguments.event.getRoutedStruct(),
			true
		);

		// Return unique identifier
		return hash( targetmixer.toString() );
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

		// systemOutput( "=====> buildHash-virtualRC: #variables.jTreeMap.init( virtualRC ).toString()#", true );
		// systemOutput( "=====> buildHash-virtualRCHash: #hash( variables.jTreeMap.init( virtualRC ).toString() )#", true );

		var myStruct = {
			// Get the original incoming context hash according to incoming arguments
			"incomingHash" : hash( variables.jTreeMap.init( virtualRC ).toString() ),
			// Multi-Host support
			"cgihost"      : buildAppLink()
		};

		// systemOutput( "=====> buildHash-mixer: #myStruct.toString()#", true );
		// systemOutput( "=====> buildHash-mixerhash: #hash( myStruct.toString() )#", true );

		// return hash from cache key struct
		return hash( myStruct.toString() );
	}

	/**
	 * Build an event key according to passed in params
	 *
	 * @keySuffix     The key suffix used in the cache key
	 * @targetEvent   The targeted ColdBox event executed
	 * @targetContext The targeted request context object
	 */
	string function buildEventKey(
		required keySuffix,
		required targetEvent,
		required targetContext
	){
		return buildBasicCacheKey( argumentCollection = arguments ) & getUniqueHash( arguments.targetContext );
	}

	/**
	 * Build an event key according to passed in params
	 *
	 * @keySuffix   The key suffix used in the cache key
	 * @targetEvent The targeted ColdBox event executed
	 * @targetArgs  A query string based argument collection like a query string
	 */
	string function buildEventKeyNoContext(
		required keySuffix,
		required targetEvent,
		required targetArgs
	){
		return buildBasicCacheKey( argumentCollection = arguments ) & buildHash( arguments.targetArgs );
	}

	/**
	 * Builds a basic cache key without the hash component
	 *
	 * @keySuffix   The key suffix used
	 * @targetEvent The targeted ColdBox event string
	 */
	string function buildBasicCacheKey( required keySuffix, required targetEvent ){
		return lCase(
			variables.cacheProvider.getEventCacheKeyPrefix() & arguments.targetEvent & "-" & arguments.keySuffix & "-"
		);
	}

}
