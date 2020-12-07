/**
 * My Event Handler Hint
 */
component extends="coldbox.system.EventHandler" {

	/**
	 * Index
	 */
	any function index( event, rc, prc ){
		event.sendFile( file = expandPath( "/cbtestharness/robots.txt" ), name = "MyRobots" );
	}

	/**
	 * Index
	 */
	any function binary( event, rc, prc ){
		event.sendFile(
			file      = fileReadBinary( expandPath( "/cbtestharness/includes/coldbox.pdf" ) ),
			name      = "coldbox",
			extension = "pdf"
		);
	}

}
