/**
 * Fixture for EVENT_CACHE_SUFFIX closure specs. It lives apart from `eventcaching.cfc`
 * because the suffix is handler-global and would change the cache keys of every spec
 * that uses that handler.
 */
component output="false"{

	// Evaluated per request: the cache key suffix carries the incoming slug
	this.EVENT_CACHE_SUFFIX = function( eventHandlerBean, event ){
		return arguments.event.getValue( "slug", "none" )
	}

	// cacheInclude="" keeps the rc hash constant, so only the suffix varies the cache key
	function index( event, rc, prc ) cache="true" cacheTimeout="10" cacheInclude=""{
		prc.data = { when : now() }
		return prc.data
	}

}
