/**
 * My Interceptor Hint
 */
component extends="coldbox.system.Interceptor"{

	/**
	 * Configure the interceptor
	 */
	void function configure(){

	}

	function unitTest( event, data ){
		arguments.event.setValue( "unittest", true );
	}

}