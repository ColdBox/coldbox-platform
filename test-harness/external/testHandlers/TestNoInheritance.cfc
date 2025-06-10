component{

	/**
	 * This is a test handler that does not inherit from the base handler.
	 * It is used to test the behavior of handlers without inheritance.
	 */
	function dspExternal( event, rc, prc ){
		event.setView( "vwExternalHandler" );
	}

}
