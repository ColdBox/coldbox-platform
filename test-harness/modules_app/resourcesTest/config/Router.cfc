component {

	function configure(){
		// Module Entry Point
		route( "/", "home.index" );

		// SES Resources
		resources( "photos" );
		resources( "users" );

		// Conventions based routing
		route( ":handler/:action?" ).end();
	}

}
