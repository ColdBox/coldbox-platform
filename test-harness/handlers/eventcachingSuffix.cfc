/**
 * Fixture for EVENT_CACHE_SUFFIX closure specs. It lives apart from `eventcaching.cfc`
 * because the suffix is handler-global and would change the cache keys of every spec
 * that uses that handler.
 */
component output="false" {

	// Evaluated per request: the suffix carries the incoming slug (proves per-request
	// re-evaluation) and a custom action annotation read off the bean (proves the bean it
	// receives has its action metadata loaded - reading it falls back to "missing" instead
	// of "present" if metadata isn't loaded, which is silent otherwise).
	this.EVENT_CACHE_SUFFIX = function( eventHandlerBean, event ){
		return arguments.event.getValue( "slug", "none" ) & "-" & arguments.eventHandlerBean.getActionMetadata(
			"suffixTag",
			"missing"
		)
	}

	// cacheInclude="" keeps the rc hash constant, so only the suffix varies the cache key
	function index( event, rc, prc )
		cache       ="true"
		cacheTimeout="10"
		cacheInclude=""
		suffixTag   ="present"
	{
		prc.data = { when : now() }
		return prc.data
	}

}
