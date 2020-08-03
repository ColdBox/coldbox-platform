/**
 * My Event Handler Hint
 */
component extends="coldbox.system.EventHandler"{

	/**
	 * Index
	 */
	any function index( event, rc, prc ){
		event.paramValue( "layout", "module-level" );
		event.paramValue( "view", "module-level" );
		event.setLayout( rc.layout );
		event.setView( rc.view );
	}

	function onInvalidEvent( event, rc, prc ){
		event.renderData( data = "<h1>Invalid Module Page</h1>", statusCode = 404 );
	}

}
