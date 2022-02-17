/**
 * Base helper for the async specs
 */
component extends="testbox.system.BaseSpec" skip="true" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	/**
	 * Send output to the console
	 */
	private function toConsole( required var ){
		writeDump( var = arguments.var, output = "console" );
		return this;
	}

	/**
	 * Get the current thread name
	 */
	private function getThreadName(){
		return getCurrentThread().getName();
	}

	/**
	 * Get the current thread java object
	 */
	private function getCurrentThread(){
		return createObject( "java", "java.lang.Thread" ).currentThread();
	}

}
