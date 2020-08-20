component {

	function index( event, rc, prc ){
		var simple = getInstance( "Simple@MyConventionsTest" );
		rc.data    = simple.getData();
		event.setView( "test/index" );
	}

}
