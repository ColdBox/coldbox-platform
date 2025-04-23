component{

	function prehandler( event, rc, prc, eventArguments ){
		event.noLayout();
	}

	function login( event, rc, prc ){
		event.setView( "security/login" );
	}

}