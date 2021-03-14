/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ----
 * An abstract CacheBox Provider
 * Properties
 * - name : The cache name
 * - enabled : Boolean flag if cache is enabled
 * - reportingEnabled: Boolean flag if cache can report
 * - stats : The statistics object
 * - configuration : The configuration structure
 * - cacheFactory : The linkage to the cachebox factory
 * - eventManager : The linkage to the event manager
 * - cacheID : The unique identity code of this CFC
 **/
 component accessors=true serializable=false{

	/**
	 * The name of this cache provider
	 */
	property name="name" default="";
	/**
	 * Is the cache enabled or not for operation
	 */
	property name="enabled" type="boolean" default="false";
	/**
	 * Can this cache do reporting
	 */
	property name="reportingEnabled" type="boolean" default="false";
	/**
	 * The stats object linkage if any
	 */
	property name="stats" default="";
	/**
	 * The cache configuration struct
	 */
	property name="configuration" type="struct";
	/**
	 * The cache factory linkage
	 */
	property name="cacheFactory" default="";
	/**
	 * The event manager linkage
	 */
	property name="eventManager" default="";
	/**
	 * The internal cache Id
	 */
	property name="cacheId" default="";
	/**
	 * ColdBox Utility object
	 * @doc_generic coldbox.system.core.util.Util
	 */
	property name="utility";
	/**
	 * A Java utility to generate UUIDs
	 */
	property name="uuidHelper";

	// Defaults static construct: implemented by caches
	variables.DEFAULTS = {};

	/**
	 * Constructor
	 */
	function init(){
		// cache provider name
		variables.name            = "";
		// enabled flag
		variables.enabled         = false;
		// reporting flag
		variables.reportingEnabled= false;
		// stats reference will go here
		variables.stats           = "";
		// configuration structure
		variables.configuration   = {};
		// cache factory instance
		variables.cacheFactory    = "";
		// event manager instance
		variables.eventManager    = "";
		// cache internal identifier
		variables.cacheID         = createObject( 'java','java.lang.System' ).identityHashCode( this );
		// ColdBox Utility
		variables.utility         = new coldbox.system.core.util.Util();
		// our UUID creation helper
		variables.uuidHelper      = createobject( "java", "java.util.UUID" );

		return this;
	}

	/**
	 * Get the name of this cache
	 */
	function getName(){
		return variables.name;
	}

	/**
	 * Set the cache name
	 *
	 * @name The name to set
	 *
	 * @return ICacheProvider
	 */
	function setName( required name ){
		variables.name = arguments.name;
		return this;
	}

	/**
	 * Returns a flag indicating if the cache is ready for operation
	 */
	boolean function isEnabled(){
		return variables.enabled;
	}
	/**
	 * Returns a flag indicating if the cache has reporting enabled
	 */
	boolean function isReportingEnabled(){
		return variables.reportingEnabled;
	}

	/**
	 * Get the cache statistics object as coldbox.system.cache.util.IStats
	 *
	 * @return coldbox.system.cache.util.IStats
	 */
	function getStats(){
		return variables.stats;
	}

	/**
	 * Clear the cache statistics
	 *
	 * @return ICacheProvider
	 */
	function clearStatistics(){
		variables.stats.clearStatistics();
		return this;
	}

	/**
	 * Get the structure of configuration parameters for the cache
	 */
	struct function getConfiguration(){
		return variables.configuration;
	}

	/**
	 * Set the entire configuration structure for this cache
	 *
	 * @configuration The cache configuration
	 *
	 * @return ICacheProvider
	 */
	function setConfiguration( required struct configuration ){
		variables.configuration = arguments.configuration;
		return this;
	}

	/**
	 * Get the cache factory reference this cache provider belongs to
	 */
	coldbox.system.cache.CacheFactory function getCacheFactory(){
		return variables.cacheFactory;
	}

	/**
	 * Set the cache factory reference for this cache
	 *
	 * @cacheFactory The cache factory
	 * @cacheFactory.doc_generic coldbox.system.cache.CacheFactory
	 *
	 * @return ICacheProvider
	 */
	function setCacheFactory( required cacheFactory ){
		variables.cacheFactory = arguments.cacheFactory;
		return this;
	}

	/**
	 * Get this cache managers event listener manager
	 */
	function getEventManager(){
		return variables.eventManager;
	}

	/**
	 * Set the event manager for this cache
	 *
	 * @eventManager The event manager to set
	 *
	 * @return ICacheProvider
	 */
	function setEventManager( required eventManager ){
		variables.eventManager = arguments.eventManager;
	}

	/************************************ CACHING UTILITIES ************************************/

	/**
	 * Sets Multiple Objects in the cache. Sets might be expensive. If the JVM threshold is used and it has been reached, the object won't be cached. If the pool is at maximum it will expire using its eviction policy and still cache the object. Cleanup will be done later.
	 *
	 * @mapping The structure of name value pairs to cache
	 * @timeout The timeout to use on the object (if any, provider specific)
	 * @lastAccessTimeout The idle timeout to use on the object (if any, provider specific)
	 * @prefix A prefix to prepend to the keys
	 */
	function setMulti(
		required struct mapping,
		timeout          ="",
		lastAccessTimeout="",
		prefix           =""
	){
		arguments.mapping.each( function( key, value ){
			// Cache these puppies
			set(
				objectKey         = prefix & arguments.key,
				object            = arguments.value,
				timeout           = timeout,
				lastAccessTimeout = lastAccessTimeout
			);
		} );
	}

	/**
	 * Clears objects from the cache by using its cache key. The returned value is a structure of name-value pairs of all the keys that where removed from the operation.
	 *
	 * @keys The comma delimited list or array of keys to retrieve from the cache
	 * @prefix A prefix to prepend to the keys
	 */
	struct function clearMulti( required keys, prefix="" ){
		if( isSimpleValue( arguments.keys ) ){
			arguments.keys = listToArray( arguments.keys );
		}

		return arguments.keys
			// prefix keys
			.map( function( item ){
				return prefix & item;
			})
			// reduce to struct of lookups
			.reduce( function( result, key ){
				result[ key ] = clear( key );
				return result;
			}, {} );
	}

	/**
	 * The returned value is a structure of name-value pairs of all the keys that where found or not
	 *
	 * @keys The comma delimited list or an array of keys to lookup in the cache
	 * @prefix A prefix to prepend to the keys with, if any
	 *
	 * @struct {key:boolean}
	 */
	struct function lookupMulti( required keys, prefix="" ){
		if( isSimpleValue( arguments.keys ) ){
			arguments.keys = listToArray( arguments.keys );
		}

		return arguments.keys
			// prefix keys
			.map( function( item ){
				return prefix & item;
			})
			// reduce to struct of lookups
			.reduce( function( result, key ){
				result[ key ] = lookup( key );
				return result;
			}, {} );
	}

	/**
	 * The returned value is a structure of name-value pairs of all the keys that where found. Not found values will be in the mapping as null
	 *
	 * @keys The comma delimited list or an array of keys to lookup in the cache
	 * @prefix A prefix to prepend to the keys with, if any
	 *
	 * @struct {key:boolean}
	 */
	struct function getMulti( required keys, prefix="" ){
		if( isSimpleValue( arguments.keys ) ){
			arguments.keys = listToArray( arguments.keys );
		}

		return arguments.keys
			// prefix keys
			.map( function( item ){
				return prefix & item;
			})
			// reduce to struct of lookups
			.reduce( function( result, key ){
				result[ key ] = get( key );
				return result;
			}, {} );
	}

	/**
	 * Get the cached object's metadata structure. If the object does not exist, it returns an empty structure.
	 *
	 * @keys The comma delimited list or array of keys to retrieve from the cache
	 * @prefix A prefix to prepend to the keys
	 */
	struct function getCachedObjectMetadataMulti( required keys, prefix="" ){
		if( isSimpleValue( arguments.keys ) ){
			arguments.keys = listToArray( arguments.keys );
		}

		return arguments.keys
			// prefix keys
			.map( function( item ){
				return prefix & item;
			})
			// reduce to struct of lookups
			.reduce( function( result, key ){
				result[ key ] = getCachedObjectMetadata( key );
				return result;
			}, {} );
	}

	/**
	 * Clear by key snippet
	 *
	 * @keySnippet The key snippet partial to clear out
	 * @regex Whether to use regex matching or not, defaults to false
	 * @async To do this in async mode or sync mode, defaults to false
	 *
	 * @return LuceeProvider
	 */
	function clearByKeySnippet( required keySnippet, boolean regex=false, boolean async=false ){
		var threadName = "clearByKeySnippet_#replace( randomUUID(), "-", "", "all" )#";

		// Async? IF so, do checks
		if( arguments.async AND NOT inThread() ){
			thread
				name      ="#threadName#"
				keySnippet="#arguments.keySnippet#"
				regex     ="#arguments.regex#"
			{
				variables.elementCleaner.clearByKeySnippet(
					attributes.keySnippet,
					attributes.regex
				);
			}
		} else {
			variables.elementCleaner.clearByKeySnippet(
				arguments.keySnippet,
				arguments.regex
			);
		}

		return this;
	}

	/**
     * Tries to get an object from the cache, if not found, it calls the 'produce' closure to produce the data and cache it
	 *
	 * @objectKey The object cache key
	 * @produce The producer closure/lambda
	 * @timeout The timeout to use on the object (if any, provider specific)
	 * @lastAccessTimeout The idle timeout to use on the object (if any, provider specific)
	 * @extra A map of name-value pairs to use as extra arguments to pass to a providers set operation
	 *
	 * @return The cached or produced data/object
     */
    any function getOrSet(
    	required any objectKey,
		required any produce,
		any timeout          ="",
		any lastAccessTimeout="",
		any extra            ={}
	){

		// Verify if it exists? if so, return it.
		var target = get( arguments.objectKey );
		if( !isNull( local.target ) ){
			return target;
		}

		// else, produce it
		lock name="GetOrSet.#variables.cacheID#.#arguments.objectKey#" type="exclusive" timeout="45" throwonTimeout="true"{
			// double lock, due to race conditions
			var target = get( arguments.objectKey );
			if( isNull( local.target ) ){
				// produce it
				target = arguments.produce();
				// store it
				set(
					objectKey         = arguments.objectKey,
					object            = target,
					timeout           = arguments.timeout,
					lastAccessTimeout = arguments.lastAccessTimeout,
					extra             = arguments.extra
				);
			}
		}

		return target;
	}

	/************************************ UTILITIES ************************************/

	/**
	 * Produce a fast random UUID
	 */
	function randomUUID(){
		return variables.uuidHelper.randomUUID();
	}

	/**
	 * A quick snapshot of the state
	 */
	struct function getMemento(){
		return variables.filter( function( k, v ){
			return ( !isCustomFunction( v ) );
		} );
	}

	/**
	 * Verifies if the request is in the current thread or another spawned thread
	 */
	boolean function inThread(){
		return variables.utility.inThread();
	}

	/************************************ PRIVATE ************************************/

	/**
	 * Check if the cache is operational, else throw exception
	 *
	 * @throws IllegalStateException
	 */
	private AbstractCacheBoxProvider function statusCheck(){
		if( !isEnabled ){
			throw(
				message = "The cache #getName()# is not yet enabled",
				detail  = "The cache was being accessed without the configuration being complete",
				type    = "IllegalStateException"
			);
		}
	}

	/**
	 * Validate the incoming configuration and make necessary defaults
	 *
	 * @return AbstractCacheProvider
	 **/
	 private function validateConfiguration(){
		// Add in settings not discovered
	   structAppend( variables.configuration, variables.DEFAULTS, false );
	   // Validate configuration values, if they don't exist, then default them to DEFAULTS
	   for( var key in variables.DEFAULTS ){
		   if( NOT len( variables.configuration[ key ] ) ){
			   variables.configuration[ key ] = variables.DEFAULTS[ key ];
		   }
	   }

	   return this;
   }

 }