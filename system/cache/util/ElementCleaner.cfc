/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 *
 * A ColdBox utility to help clean cached objects for ColdBox Application Caches
 *
 * @author Luis Majano
 */
component accessors="true" serializable="false" {

	/**
	 * Constructor
	 *
	 * @cacheProvider             The associated cache manager/provider of type: coldbox.system.cache.providers.ICacheProvider
	 * @cacheProvider.doc_generic coldbox.system.cache.providers.ICacheProvider
	 */
	ElementCleaner function init( required cacheProvider ){
		variables.cacheProvider = arguments.cacheProvider;
		return this;
	}

	/**
	 * Get the associated cache provider/manager of type: coldbox.system.cache.providers.ICacheProvider
	 *
	 * @return coldbox.system.cache.providers.ICacheProvider
	 */
	function getAssociatedCache(){
		return variables.cacheProvider;
	}

	/**
	 * Clears keys using the passed in object key snippet
	 *
	 * @keySnippet The cache key snippet to use
	 * @regex      Use regex or not, defaults to false
	 */
	ElementCleaner function clearByKeySnippet( required keySnippet, boolean regex ){
		var cacheKeys       = variables.cacheProvider.getKeys();
		var cacheKeysLength = arrayLen( cacheKeys );

		// sort array
		arraySort( cacheKeys, "textnocase" );

		for ( var x = 1; x lte cacheKeysLength; x++ ) {
			// Get List Value
			var thisKey = cacheKeys[ x ];

			// Using Regex
			if ( arguments.regex ) {
				var tester = reFindNoCase( arguments.keySnippet, thisKey );
			} else {
				var tester = findNoCase( arguments.keySnippet, thisKey );
			}

			// Test Evaluation
			if ( tester ) {
				variables.cacheProvider.clear( thisKey );
			}
		}

		return this;
	}

	/**
	 * Clears all the event permutations from the cache according to snippet and querystring.
	 * Be careful when using incomplete event name with query strings as partial event names are not guaranteed to match with query string permutations
	 *
	 * @eventsnippet The event snippet to clear on. Can be partial or full
	 * @queryString  If passed in, it will create a unique hash out of it. For purging purposes
	 */
	ElementCleaner function clearEvent( required eventsnippet, queryString = "" ){
		// .*- = the cache suffix and appendages for regex to match
		var cacheKey = variables.cacheProvider.getEventCacheKeyPrefix() & ".*" & replace(
			arguments.eventsnippet,
			".",
			"\.",
			"all"
		) & ".*-.*";

		// Check if we are purging with query string
		if ( len( arguments.queryString ) neq 0 ) {
			cacheKey &= "-" & variables.cacheProvider.getEventURLFacade().buildHash( arguments.queryString );
		}

		// systemOutput( "cachekey: #cacheKey#, hash:#variables.cacheProvider.getEventURLFacade().buildHash( arguments.queryString )#" , true );

		// Clear All Events by Criteria
		return clearByKeySnippet( keySnippet = cacheKey, regex = true );
	}

	/**
	 * Clears all the event permutations from the cache according to the list of snippets and querystrings.
	 * Be careful when using incomplete event name with query strings as partial event names are not guaranteed to match with query string permutations
	 *
	 * @eventsnippets The comma-delimited list event snippet to clear on. Can be partial or full
	 * @queryString   The comma-delimited list of queryStrings passed in. If passed in, it will create a unique hash out of it. For purging purposes.  If passed in the list length must be equal to the list length of the event snippets passed in
	 */
	ElementCleaner function clearEventMulti( required eventsnippets, queryString = "" ){
		var regexCacheKey  = "";
		var keyPrefix      = variables.cacheProvider.getEventCacheKeyPrefix();
		var eventURLFacade = variables.cacheProvider.getEventURLFacade();

		// normalize snippets
		if ( isArray( arguments.eventSnippets ) ) {
			arguments.eventsnippets = arrayToList( arguments.eventsnippets );
		}

		// Loop on the incoming snippets
		for ( var x = 1; x lte listLen( arguments.eventsnippets ); x++ ) {
			// .*- = the cache suffix and appendages for regex to match
			var cacheKey = keyPrefix & ".*" & replace(
				listGetAt( arguments.eventsnippets, x ),
				".",
				"\.",
				"all"
			) & "-.*";

			// Check if we are purging with query string
			if ( len( arguments.queryString ) neq 0 ) {
				cacheKey = cacheKey & "-" & eventURLFacade.buildHash( listGetAt( arguments.queryString, x ) );
			}
			regexCacheKey &= cacheKey;

			// check that we aren't at the end of the list, and the | char to the regex as the OR statement
			if ( x NEQ listLen( arguments.eventsnippets ) ) {
				regexCacheKey = regexCacheKey & "|";
			}
		}

		// Clear All Events by Criteria
		return clearByKeySnippet( keySnippet = regexCacheKey, regex = true );
	}

	/**
	 * Clears all events from the cache
	 */
	ElementCleaner function clearAllEvents(){
		var cacheKey = variables.cacheProvider.getEventCacheKeyPrefix();
		// Clear All Events
		return clearByKeySnippet( keySnippet = cacheKey, regex = false );
	}

	/**
	 * Clears all view name permutations from the cache according to the view name
	 *
	 * @viewSnippet The view name snippet to purge from the cache
	 */
	ElementCleaner function clearView( required viewSnippet ){
		var cacheKey = variables.cacheProvider.getViewCacheKeyPrefix() & arguments.viewSnippet;

		// Clear All View snippets
		return clearByKeySnippet( keySnippet = cacheKey, regex = false );
	}

	/**
	 * Clears all view name permutations from the cache according to the view name.
	 *
	 * @viewSnippet The comma-delimited list or array of view snippet to clear on. Can be partial or full
	 */
	ElementCleaner function clearViewMulti( required viewSnippets ){
		var regexCacheKey = "";
		var x             = 1;
		var cacheKey      = "";
		var keyPrefix     = variables.cacheProvider.getViewCacheKeyPrefix();

		// normalize snippets
		if ( isArray( arguments.viewSnippets ) ) {
			arguments.viewSnippets = arrayToList( arguments.viewSnippets );
		}

		// Loop on the incoming snippets
		for ( x = 1; x lte listLen( arguments.viewSnippets ); x = x + 1 ) {
			// .*- = the cache suffix and appendages for regex to match
			cacheKey = keyPrefix & replace(
				listGetAt( arguments.viewSnippets, x ),
				".",
				"\.",
				"all"
			) & "-.*";

			// Check if we are purging with query string
			regexCacheKey = regexCacheKey & cacheKey;

			// check that we aren't at the end of the list, and the | char to the regex as the OR statement
			if ( x NEQ listLen( arguments.viewSnippets ) ) {
				regexCacheKey = regexCacheKey & "|";
			}
		}

		// Clear All Events by Criteria
		return clearByKeySnippet( keySnippet = regexCacheKey, regex = true );
	}

	/**
	 * Clears all views from the cache.
	 */
	ElementCleaner function clearAllViews(){
		var cacheKey = variables.cacheProvider.getViewCacheKeyPrefix();
		// Clear All the views
		return clearByKeySnippet( keySnippet = cacheKey, regex = false );
	}

}
