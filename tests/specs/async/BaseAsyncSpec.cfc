/**
 * Base helper for the async specs
 */
component extends="testbox.system.BaseSpec" skip="true"{

	/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
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