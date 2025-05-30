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

    // cacheIncludeRcKeys (all keys)
	function withIncludeAllRcKeys( event, rc, prc )
        cache        ="true"
        cacheTimeout ="10"
        cacheIncludeRcKeys="*"
    {

        prc.data = [
            { id : createUUID(), name : "luis" },
            { id : createUUID(), name : "lucas" },
            { id : createUUID(), name : "fernando" }
        ];

        return prc.data;
    }

    // cacheIncludeRcKeys (no keys)
    function withIncludeNoRcKeys( event, rc, prc )
        cache        ="true"
        cacheTimeout ="10"
        cacheIncludeRcKeys=""
    {

        prc.data = [
            { id : createUUID(), name : "luis" },
            { id : createUUID(), name : "lucas" },
            { id : createUUID(), name : "fernando" }
        ];

        return prc.data;
    }

    // cacheIncludeRcKeys (1 RC key)
    function withIncludeOneRcKey( event, rc, prc )
        cache        ="true"
        cacheTimeout ="10"
        cacheIncludeRcKeys="slug"
    {

        param rc.slug = "";

        prc.data = [
            { id : createUUID(), name : "luis" },
            { id : createUUID(), name : "lucas" },
            { id : createUUID(), name : "fernando" }
        ];

        return prc.data;
    }

    // cacheIncludeRcKeys (RC 2 keys)
    function withIncludeRcKeyList( event, rc, prc )
        cache        ="true"
        cacheTimeout ="10"
        cacheIncludeRcKeys="slug,id"
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
