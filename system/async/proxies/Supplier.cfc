component extends="BaseProxy" {

	/**
	 * Constructor
	 *
	 * @supplier The lambda or closure that will supply the elements
	 * @method An optional method in case the supplier is a CFC instead of a closure
	 * @debug Add debugging or not
	 * @loadAppContext By default, we load the Application context into the running thread. If you don't need it, then don't load it.
	 * @unloadAppContext By default we unload the context if set. You can turn this off if you want to leave a task with the context loaded.
	 */
	function init(
		required supplier,
		method                 = "run",
		boolean debug          = false,
		boolean loadAppContext = true,
		boolean unloadAppContext = true
	){
		super.init(
			arguments.supplier,
			arguments.debug,
			arguments.loadAppContext,
			arguments.unloadAppContext
		);
		variables.method = arguments.method;
		return this;
	}

	/**
	 * Functional interface for supplier to get a result
	 * See https://docs.oracle.com/javase/8/docs/api/java/util/function/Supplier.html
	 */
	function get(){
		loadContext();
		try {
			lock name="#getConcurrentEngineLockName()#" type="exclusive" timeout="60" {
				if ( isClosure( variables.target ) || isCustomFunction( variables.target ) ) {
					return variables.target();
				} else {
					return invoke( variables.target, variables.method );
				}
			}
		} finally {
			unLoadContext();
		}
	}

}
