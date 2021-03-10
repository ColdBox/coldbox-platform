/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * @author Luis Majano
 *
 * The main interface to produce a ColdBox Application cache.
 */
interface extends="coldbox.system.cache.providers.ICacheProvider"{

	/**
	 * Get the cached view key prefix which is necessary for view caching
	 */
	function getViewCacheKeyPrefix();

	/**
	 * Get the event cache key prefix which is necessary for event caching
	 */
	function getEventCacheKeyPrefix();

	/**
	 * Get the coldbox application reference as coldbox.system.web.Controller
	 *
	 * @return coldbox.system.web.Controller
	 */
	function getColdbox();

	/**
	 * Set the ColdBox linkage into the provider
	 *
	 * @coldbox The ColdBox controller
	 * @coldbox.doc_generic coldbox.system.web.Controller
	 *
	 * @return IColdboxApplicationCache
	 */
	function setColdBox( required coldbox );

	/**
	 * Get the event caching URL facade utility that determines event caching
	 *
	 * @return coldbox.system.cache.util.EventURLFacade
	 */
	function getEventURLFacade();

	/**
	 * Clears all events from the cache.
	 *
	 * @async If implemented, determines async or sync clearing.
	 *
	 * @return IColdboxApplicationCache
	 */
	function clearAllEvents( boolean async );

	/**
	 * Clears all the event permutations from the cache according to snippet and querystring. Be careful when using incomplete event name with query strings as partial event names are not guaranteed to match with query string permutations
	 *
	 * @eventSnippet The event snippet to clear on. Can be partial or full
	 * @queryString If passed in, it will create a unique hash out of it. For purging purposes
	 *
	 * @return IColdboxApplicationCache
	 */
	function clearEvent( required eventSnippet, queryString="" );

	/**
	 * Clears all the event permutations from the cache according to the list of snippets and querystrings. Be careful when using incomplete event name with query strings as partial event names are not guaranteed to match with query string permutations
	 *
	 * @eventSnippet The comma-delimited list event snippet to clear on. Can be partial or full
	 * @queryString The comma-delimited list of queryStrings passed in. If passed in, it will create a unique hash out of it. For purging purposes.  If passed in the list length must be equal to the list length of the event snippets passed in
	 *
	 * @return IColdboxApplicationCache
	 */
	function clearEventMulti( required eventsnippets, queryString="" );

	/**
	 * Clears all view name permutations from the cache according to the view name
	 *
	 * @viewSnippet The view name snippet to purge from the cache
	 *
	 * @return IColdboxApplicationCache
	 */
	function clearView( required viewSnippet );

	/**
	 * Clears all view name permutations from the cache according to the view name.
	 *
	 * @viewSnippets The comma-delimited list or array of view snippet to clear on. Can be partial or full
	 *
	 * @return IColdboxApplicationCache
	 */
	function clearViewMulti( required viewSnippets );

	/**
	 * Clears all views from the cache.
	 *
	 * @async Run command asynchronously or not
	 *
	 * @return IColdboxApplicationCache
	 */
	function clearAllViews( boolean async );

}