component{

	function preHandler( event, rc, prc ) {
        event.noLayout();
    }

    function login( event, rc, prc ) {
        event.setView( "nolayout/login" );
    }

}