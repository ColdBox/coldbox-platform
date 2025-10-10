component{

	function preHandler( event, rc, prc ) {
        event.noLayout();
    }

	function index( event, rc, prc ) {
		login( event, rc, prc );
	}

    function login( event, rc, prc ) {
        event.setView( "nolayout/login" );
    }

}