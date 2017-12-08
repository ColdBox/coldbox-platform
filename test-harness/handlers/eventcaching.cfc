component output="false" singleton{

	// Default Action
	function index( event, rc, prc ) cache="true" cacheTimeout="10"{
		prc.data = [
			{ id = createUUID(), name = "luis" },
			{ id = createUUID(), name = "lucas" },
			{ id = createUUID(), name = "fernando" }
		];

		event.renderData( data=prc.data, formats="json,xml,pdf,html" );
	}

	// With Provider
	function withProvider( event, rc, prc ) cache="true" cacheTimeout="10" cacheProvider="default"{
		prc.data = [
			{ id = createUUID(), name = "luis" },
			{ id = createUUID(), name = "lucas" },
			{ id = createUUID(), name = "fernando" }
		];

		return prc.data;
	}

	function cacheKeys( event, rc, prc ){
		var keys = {
			"template" = getCache( "template" ).getKeys(),
			"default" = getCache( "default" ).getKeys()
		};

		return keys;
	}

	// widget event
	function widget( event, rc, prc, widget=true ){

		var data = [
			{ id = createUUID(), name = "luis" },
			{ id = createUUID(), name = "lucas" },
			{ id = createUUID(), name = "fernando" }
		];

		return { data = data, timestamp = now() };
	}

	function produceError( event, rc, prc ) cache="true" cacheTimeout="10"{
		event.setHTTPHeader( statusCode=500, statusText="error" );
		return {
			error = false,
			messages = "Test",
			when = now()
		};
	}

}