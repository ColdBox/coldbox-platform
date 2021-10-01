/**
 * Functional Interface that maps to java.lang.Runnable
 * See https://docs.oracle.com/javase/8/docs/api/java/lang/Runnable.html
 */
component extends="BaseProxy" {

	/**
	 * Constructor
	 *
	 * @target The lambda or closure that will be the task
	 * @method An optional method in case the supplier is a CFC instead of a closure
	 * @debug Add debugging or not
	 * @loadAppContext By default, we load the Application context into the running thread. If you don't need it, then don't load it.
	 */
	function init(
		required target,
		method                 = "run",
		boolean debug          = false,
		boolean loadAppContext = true
	){
		super.init(
			arguments.target,
			arguments.debug,
			arguments.loadAppContext
		);
		variables.method = arguments.method;
		return this;
	}

	function run(){
		loadContext();
		try {
			lock name="#getConcurrentEngineLockName()#" type="exclusive" timeout="60" {
				if ( isClosure( variables.target ) || isCustomFunction( variables.target ) ) {
					variables.target();
				} else {
					invoke( variables.target, variables.method );
				}
			}
		} finally {
			unLoadContext();
		}
	}

}
