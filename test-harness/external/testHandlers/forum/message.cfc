component{

	/**
	 * This is a test handler for external testing
	 */
	function dspExternal( event, rc ){
		rc.message = "This is an external test handler";
		event.setView( "vwExternalHandler" );
	}

}