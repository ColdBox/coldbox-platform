component resthandler {

	function index( event, rc, prc ){
		event.getResponse().setData( "hello" );
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
