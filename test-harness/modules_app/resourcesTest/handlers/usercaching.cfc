component output = "false" singleton{
	/**
	 * clear all event caching for tests.
	 */
	function clearAll( event, rc, prc ){
		getCache( "template" ).clearEvent( "usercaching" );
		return cacheKeys( argumentCollection = arguments );
	}

	function clearWithQueryString( event, rc, prc ){
		getCache( "template" ).clearEvent( "usercaching.index", rc.qs ?: "" );
		return cacheKeys( argumentCollection = arguments );
	}

	function clearPartial( event, rc, prc ){
		getCache( "template" ).clearEvent( "user" );
		return cacheKeys( argumentCollection = arguments );
	}

	// Default Action
	function index( event, rc, prc ) cache="true" cacheTimeout="10"{
		prc.data = [
			{ id : createUUID(), name : "luis" },
			{ id : createUUID(), name : "lucas" },
			{ id : createUUID(), name : "fernando" }
		];

		return prc.data
	}

	function cacheKeys( event, rc, prc ){
		var keys = {
			"template" : getCache( "template" ).getKeys(),
			"default"  : getCache( "default" ).getKeys()
		};

		return keys;
	}

}
