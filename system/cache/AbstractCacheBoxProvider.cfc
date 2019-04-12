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
	 * Clear the cache statistics
	 */
	AbstractCacheBoxProvider function clearStatistics(){
		variables.stats.clearStatistics();
		return this;
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
	 * Set the cache factory reference for this cache
	 * @cacheFactory.doc_Generic coldbox.system.cache.CacheFactory
	 */
	void function setCacheFactory( required cacheFactory ){
		variables.cacheFactory = arguments.cacheFactory;
	}

	/************************************ PRIVATE ************************************/

	/**
	 * Get a utility reference
	 */
	private function getUtil(){
		return new coldbox.system.core.util.Util();
	}

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

 }