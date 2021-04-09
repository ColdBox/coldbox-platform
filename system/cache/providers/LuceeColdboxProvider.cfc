/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * @author Luis Majano
 *
 * This CacheBox provider communicates with the built in caches in the Lucee Engine for ColdBox Apps
 */
component
	accessors="true"
	serializable="false"
	implements="coldbox.system.cache.providers.IColdBoxProvider"
	extends="coldbox.system.cache.providers.LuceeProvider"
{

	// Cache Prefixes
	this.VIEW_CACHEKEY_PREFIX 	= "lucee_view-";
	this.EVENT_CACHEKEY_PREFIX 	= "lucee_event-";

	/**
	 * Constructor
	 */
	LuceeColdBoxProvider function init(){
		super.init();

		// URL Facade Utility
		variables.eventURLFacade = new coldbox.system.cache.util.EventURLFacade( this );

		return this;
	}

	/**
	 * Get the cached view key prefix which is necessary for view caching
	 */
	function getViewCacheKeyPrefix(){
		return this.VIEW_CACHEKEY_PREFIX;
	};

	/**
	 * Get the event cache key prefix which is necessary for event caching
	 */
	function getEventCacheKeyPrefix(){
		return this.EVENT_CACHEKEY_PREFIX;
	}

	/**
	 * Get the coldbox application reference as coldbox.system.web.Controller
	 *
	 * @return coldbox.system.web.Controller
	 */
	function getColdbox(){
		return variables.coldbox;
	}

	/**
	 * Set the ColdBox linkage into the provider
	 *
	 * @coldbox The ColdBox controller
	 * @coldbox.doc_generic coldbox.system.web.Controller
	 *
	 * @return IColdboxApplicationCache
	 */
	function setColdBox( required coldbox ){
		variables.coldbox = arguments.coldbox;
		return this;
	}

	/**
	 * Get the event caching URL facade utility that determines event caching
	 *
	 * @return coldbox.system.cache.util.EventURLFacade
	 */
	function getEventURLFacade(){
		return variables.eventURLFacade;
	}

	/**
	 * Clears all events from the cache.
	 *
	 * @async If implemented, determines async or sync clearing.
	 *
	 * @return IColdboxApplicationCache
	 */
	function clearAllEvents( boolean async=false ){
		var threadName = "clearAllEvents_#replace(variables.uuidHelper.randomUUID(),"-","","all")#";

		// Async? IF so, do checks
		if( arguments.async AND NOT variables.utility.inThread() ){
			thread name="#threadName#"{
				variables.elementCleaner.clearAllEvents();
			}
		}
		else{
			variables.elementCleaner.clearAllEvents();
		}
		return this;
	}

	/**
	 * Clears all the event permutations from the cache according to snippet and querystring. Be careful when using incomplete event name with query strings as partial event names are not guaranteed to match with query string permutations
	 *
	 * @eventSnippet The event snippet to clear on. Can be partial or full
	 * @queryString If passed in, it will create a unique hash out of it. For purging purposes
	 *
	 * @return IColdboxApplicationCache
	 */
	function clearEvent( required eventSnippet, queryString="" ){
		variables.elementCleaner.clearEvent( arguments.eventsnippet, arguments.queryString );
		return this;
	}

	/**
	 * Clears all views from the cache.
	 *
	 * @async Run command asynchronously or not
	 *
	 * @return IColdboxApplicationCache
	 */
	function clearAllViews( boolean async=false ){
		var threadName = "clearAllViews_#replace(variables.uuidHelper.randomUUID(),"-","","all")#";

		// Async? IF so, do checks
		if( arguments.async AND NOT variables.utility.inThread() ){
			thread name="#threadName#"{
				variables.elementCleaner.clearAllViews();
			}
		}
		else{
			variables.elementCleaner.clearAllViews();
		}
		return this;
	}

	/**
	 * Clears all the event permutations from the cache according to the list of snippets and querystrings. Be careful when using incomplete event name with query strings as partial event names are not guaranteed to match with query string permutations
	 *
	 * @eventSnippet The comma-delimited list event snippet to clear on. Can be partial or full
	 * @queryString The comma-delimited list of queryStrings passed in. If passed in, it will create a unique hash out of it. For purging purposes.  If passed in the list length must be equal to the list length of the event snippets passed in
	 *
	 * @return IColdboxApplicationCache
	 */
	function clearEventMulti( required eventsnippets, queryString="" ){
		variables.elementCleaner.clearEventMulti(arguments.eventsnippets,arguments.queryString);
		return this;
	}

	/**
	 * Clears all view name permutations from the cache according to the view name
	 *
	 * @viewSnippet The view name snippet to purge from the cache
	 *
	 * @return IColdboxApplicationCache
	 */
	function clearView( required viewSnippet ){
		variables.elementCleaner.clearView(arguments.viewSnippet);
		return this;
	}

	/**
	 * Clears all view name permutations from the cache according to the view name.
	 *
	 * @viewSnippets The comma-delimited list or array of view snippet to clear on. Can be partial or full
	 *
	 * @return IColdboxApplicationCache
	 */
	function clearViewMulti( required viewSnippets ){
		variables.elementCleaner.clearView(arguments.viewsnippets);
		return this;
	}

}