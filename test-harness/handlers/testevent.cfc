component output="false"{

	function index( event, rc, prc ){
		
		event.setView("runevent/index");
	}

	// testing run event ...
	private void function info( event, rc, prc ){
		prc.layout = {};
		prc.layout.someinfo = "some text";
		prc.layout.bio = "some more text";
	}

}	