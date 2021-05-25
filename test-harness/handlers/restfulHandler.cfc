component extends="coldbox.system.RestHandler" {

	function index( event, rc, prc ) cache=true{
		event.getResponse().setData( {
			"timestamp" : now(),
			"message" : "hello"
		} );
	}

	function showCache( event, rc, prc ){
		writeDump( var=getcache( "template" ).getKeys() );

		getcache( "template" ).clearEvent( "ful" );

		writeDump( var=getcache( "template" ).getKeys() );
		return "";
	}

	function showCacheWithRC( event, rc, prc ){
		writeDump( var=getcache( "template" ).getKeys() );

		getcache( "template" ).clearEvent( "dex", "key=1&name=luis" );

		writeDump( var=getcache( "template" ).getKeys() );
		return "";
	}

	function returnData( event, rc, prc ){
		return "hola";
	}

	function renderData( event, rc, prc ){
		event.renderData( type = "json", data = [ "luis majano" ] );
	}

	function setView( event, rc, prc ){
		event.setView( "simpleview" );
	}

	function invalidCredentials( event, rc, prc ){
		throw( type = "InvalidCredentials" );
	}

	function ValidationException( event, rc, prc ){
		throw( type = "ValidationException" );
	}

	function EntityNotFound( event, rc, prc ){
		throw( type = "EntityNotFound" );
	}

	function RecordNotFound( event, rc, prc ){
		throw( type = "RecordNotFound" );
	}

}
