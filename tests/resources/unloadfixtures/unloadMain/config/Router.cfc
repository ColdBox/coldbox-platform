/**
 * Test fixture: a module router that also listens to an interception point.
 */
component {

	function configure(){
		route( "/", "home.index" );
	}

	function postProcess( event, data, buffer, rc, prc ){
	}

}
