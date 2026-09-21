/**
 * Only declares the mandatory-action convention route, mirroring how
 * ContentBox's contentbox-admin module declares its routes. ColdBox must
 * still auto-inject the optional-action ("/:handler/:action?") convention
 * route so a handler-only URL segment (e.g. "/mconventions/home") resolves.
 */
component {

	function configure(){
		route( "/:handler/:action" ).end();
	}

}
