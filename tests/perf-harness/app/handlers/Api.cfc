/**
 * REST API handler — tests DI + JSON serialization pipeline.
 */
component extends="coldbox.system.EventHandler" {

	property name="userService" inject="UserService";

	// JSON list — injects UserService and renders JSON
	function list( event, rc, prc ){
		var data = {
			status   : "success",
			count    : 10,
			engine   : server.keyExists( "coldfusion" ) ? "Adobe CF" : ( server.keyExists( "lucee" ) ? "Lucee" : "BoxLang" ),
			users    : userService.getUsers( 10 ),
			metadata : {
				generated : now(),
				framework : "ColdBox"
			}
		}
		event.renderData( type="json", data=data )
	}

}
