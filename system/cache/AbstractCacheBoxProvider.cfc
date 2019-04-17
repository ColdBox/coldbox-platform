/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ----
 * An abstract CacheBox Provider
 * Properties
 * - name : The cache name
 * - enabled : Boolean flag if cache is enabled
 * - reportingEnabled: Boolean falg if cache can report
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
		variables.name 				= "";
		// enabled flag
		variables.enabled 			= false;
		// reporting flag
		variables.reportingEnabled 	= false;
		// stats reference will go here
		variables.stats   			= "";
		// configuration structure
		variables.configuration 	= {};
		// cache factory instance
		variables.cacheFactory 		= "";
		// event manager instance
		variables.eventManager		= "";
		// cache internal identifier
		variables.cacheID			= createObject( 'java','java.lang.System' ).identityHashCode( this );
		// ColdBox Utility
		variables.utility			= new coldbox.system.core.util.Util();
		// our UUID creation helper
		variables.uuidHelper		= createobject( "java", "java.util.UUID" );

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
	 * Get the cache statistics object as coldbox.system.cache.util.ICacheStats
	 *
	 * @return coldbox.system.cache.util.ICacheStats
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

	/************************************ UTILITIES ************************************/

	/**
	 * Clear by key snippet
	 *
	 * @keySnippet The key snippet partial to clear out
	 * @regex Wethere to use regex matching or not, defaults to false
	 * @async To do this in async mode or sync mode, defaults to false
	 *
	 * @return LuceeProvider
	 */
	function clearByKeySnippet( required keySnippet, boolean regex=false, boolean async=false ){
		var threadName = "clearByKeySnippet_#replace( randomUUID(), "-", "", "all" )#";

		// Async? IF so, do checks
		if( arguments.async AND NOT inThread() ){
			thread name="#threadName#" keySnippet="#arguments.keySnippet#" regex="#arguments.regex#"{
				variables.elementCleaner.clearByKeySnippet( attribues.keySnippet, attribues.regex );
			}
		} else{
			variables.elementCleaner.clearByKeySnippet( arguments.keySnippet, arguments.regex );
		}

		return this;
	}

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
				detail 	= "The cache was being accessed without the configuration being complete",
				type 	= "IllegalStateException"
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
	   structAppend( variables.configuration, variables.DEFAULTS );
	   // Validate configuration values, if they don't exist, then default them to DEFAULTS
	   for( var key in variables.DEFAULTS ){
		   if( NOT len( variables.configuration[ key ] ) ){
			   variables.configuration[ key ] = variables.DEFAULTS[ key ];
		   }
	   }

	   return this;
   }

 }