component output = "false" singleton{
	/**
	 * clear all event caching for tests.
	 */
	function clearAll( event, rc, prc ){
		getCache( "template" ).clearEvent( "eventcaching.index" );
		return cacheKeys( argumentCollection = arguments );
	}

	/**
	 * clear all for json
	 */
	function clearJSON( event, rc, prc ){
		getCache( "template" ).clearEvent( "eventcaching.index", "format=json" );
		return cacheKeys( argumentCollection = arguments );
	}

	function clearPartial( event, rc, prc ){
		getCache( "template" ).clearEvent( "eventcaching" );
		return cacheKeys( argumentCollection = arguments );
	}

	// Default Action
	function index( event, rc, prc ) cache="true" cacheTimeout="10"{

        prc.data = [
			{ id : createUUID(), name : "luis" },
			{ id : createUUID(), name : "lucas" },
			{ id : createUUID(), name : "fernando" }
		];

		event.renderData( data = prc.data, formats = "json,xml,pdf,html" );
	}

	// With Provider
	function withProvider( event, rc, prc )
		cache        ="true"
		cacheTimeout ="10"
		cacheProvider="default"
	{
		prc.data = [
			{ id : createUUID(), name : "luis" },
			{ id : createUUID(), name : "lucas" },
			{ id : createUUID(), name : "fernando" }
		];

		return prc.data;
	}

    // CacheInclude

    // Default (all keys used for cache)
	function withIncludeAllRcKeys( event, rc, prc )
        cache        ="true"
        cacheTimeout ="10"
    {

        prc.data = [
            { id : createUUID(), name : "luis" },
            { id : createUUID(), name : "lucas" },
            { id : createUUID(), name : "fernando" }
        ];

        return prc.data;
    }

    // cacheInclude (no keys)
    function withIncludeNoRcKeys( event, rc, prc )
        cache        ="true"
        cacheTimeout ="10"
        cacheInclude=""
    {

        prc.data = [
            { id : createUUID(), name : "luis" },
            { id : createUUID(), name : "lucas" },
            { id : createUUID(), name : "fernando" }
        ];

        return prc.data;
    }

    // cacheInclude (1 RC key)
    function withIncludeOneRcKey( event, rc, prc )
        cache        ="true"
        cacheTimeout ="10"
        cacheInclude="slug"
    {

        param rc.slug = "";

        prc.data = [
            { id : createUUID(), name : "luis" },
            { id : createUUID(), name : "lucas" },
            { id : createUUID(), name : "fernando" }
        ];

        return prc.data;
    }

    // cacheInclude (RC 2 keys)
    function withIncludeRcKeyList( event, rc, prc )
        cache        ="true"
        cacheTimeout ="10"
        cacheInclude="slug,id"
    {

        param rc.slug = "";
        param rc.id = "";

        prc.data = [
            { id : createUUID(), name : "luis" },
            { id : createUUID(), name : "lucas" },
            { id : createUUID(), name : "fernando" }
        ];

        return prc.data;
    }

    // CacheExclude

    // cacheExclude (nothing will be filtered)
    function withExcludeNoRcKeys( event, rc, prc )
        cache        ="true"
        cacheTimeout ="10"
        cacheExclude=""
    {

        prc.data = [
            { id : createUUID(), name : "luis" },
            { id : createUUID(), name : "lucas" },
            { id : createUUID(), name : "fernando" }
        ];

        return prc.data;
    }

    // cacheExclude (1 RC key)
    function withExcludeOneRcKey( event, rc, prc )
        cache        ="true"
        cacheTimeout ="10"
        cacheExclude="slug"
    {

        param rc.slug = "";

        prc.data = [
            { id : createUUID(), name : "luis" },
            { id : createUUID(), name : "lucas" },
            { id : createUUID(), name : "fernando" }
        ];

        return prc.data;
    }

    // cacheExclude (RC 2 keys)
    function withExcludeRcKeyList( event, rc, prc )
        cache        ="true"
        cacheTimeout ="10"
        cacheExclude="slug,id"
    {

        param rc.slug = "";
        param rc.id = "";

        prc.data = [
            { id : createUUID(), name : "luis" },
            { id : createUUID(), name : "lucas" },
            { id : createUUID(), name : "fernando" }
        ];

        return prc.data;
    }


    // cacheFilter (closure)
    function withFilterClosure( event, rc, prc ) 
        cache        ="true"
        cacheTimeout ="10"
        cacheFilter  = "filterUtmParams"
    {

        param rc.slug = "";

        prc.data = [
            { id : createUUID(), name : "luis" },
            { id : createUUID(), name : "lucas" },
            { id : createUUID(), name : "fernando" }
        ];

        return prc.data;
    }

    // cacheFilter (returns a closure with rcTarget as argument)
    private function filterUtmParams() {
        var ignoreKeys = [ "utm_source", "utm_medium", "utm_campaign" ];
        return ( rcTarget ) => {
            return rcTarget.filter( ( key, value ) => {
                // Filter out UTM parameters
                return !ignoreKeys.findNoCase( key );
            } );
        }
    }

    // all filters
    function withAllFilters( event, rc, prc ) 
        cache        ="true"
        cacheTimeout ="10"
        cacheFilter  ="filterMutateParams" // mutate params
        cacheInclude ="slug,id" // include slug and id
        cacheExclude ="id"  // exclude id
    {

        param rc.slug = "";

        prc.data = [
            { id : createUUID(), name : "luis" },
            { id : createUUID(), name : "lucas" },
            { id : createUUID(), name : "fernando" }
        ];

        return prc.data;
    }

    // cacheFilter: Returns a closure that mutates the rcTarget
    private function filterMutateParams() {
        return ( rcTarget ) => {
            rcTarget[ "slug" ] = createUuid(); // randomize slug
            rcTarget[ "id" ] = createUuid(); // randomize id
            return rcTarget;
        };
    }


    // withBadCacheFilter (returns something other than a closure)
    function withBadCacheFilter( event, rc, prc ) 
        cache        ="true"
        cacheTimeout ="10"
        cacheFilter  ="filterNoClosure" 
    {

        param rc.slug = "";

        prc.data = [
            { id : createUUID(), name : "luis" },
            { id : createUUID(), name : "lucas" },
            { id : createUUID(), name : "fernando" }
        ];

        return prc.data;
    }

    // filterNoClosure: returns something other than a closure
    private function filterNoClosure() {
        return {
            "slug" : "foo",
            "id"   : 1
        };
    }


	function cacheKeys( event, rc, prc ){
		var keys = {
			"template" : getCache( "template" ).getKeys(),
			"default"  : getCache( "default" ).getKeys()
		};

		return keys;
	}

	// widget event
	function widget( event, rc, prc, widget = true ){
		var data = [
			{ id : createUUID(), name : "luis" },
			{ id : createUUID(), name : "lucas" },
			{ id : createUUID(), name : "fernando" }
		];

		return { data : data, timestamp : now() };
	}

	/**
	 * Produces a non-throwing error by setting the status code to 500,
	 * This should not cache the output
	 */
	function produceError( event, rc, prc ) cache="true" cacheTimeout="10"{
		event.setHTTPHeader( statusCode = 500 );
		return {
			error    : false,
			messages : "Test",
			when     : now()
		};
	}

	function produceRenderData( event, rc, prc ) cache="True" cachetimeout="5"{
		var data = {
			error    : false,
			messages : "Test",
			when     : now()
		};

		event.renderData(
			type       = "json",
			data       = data,
			statusCode = 500
		);
	}
}
