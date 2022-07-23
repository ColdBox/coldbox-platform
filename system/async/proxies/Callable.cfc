component extends="Supplier" {

	/**
	 * Functional interface for supplier to get a result
	 * See https://docs.oracle.com/javase/8/docs/api/java/util/function/Supplier.html
	 */
	function call(){
		loadContext();
		try {
			lock name="#getConcurrentEngineLockName()#" type="exclusive" timeout="60" {
				if ( isClosure( variables.target ) || isCustomFunction( variables.target ) ) {
					return variables.target();
				} else {
					return invoke( variables.target, variables.method );
				}
			}
		} catch ( any e ) {
			// Log it, so it doesn't go to ether
			err( "Error running Callable: #e.message & e.detail#" );
			err( "Stacktrace for Callable: #e.stackTrace#" );
			rethrow;
		} finally {
			unLoadContext();
		}
	}

}
