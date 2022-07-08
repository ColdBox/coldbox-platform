/**
 * Functional Interface that maps to java.util.function.Function
 * but will return the native future which is expected in the result
 * of the called target
 */
component extends="Function" {

	/**
	 * Represents a function that accepts one argument and produces a result.
	 * I have to use it like this because `super` does not work on ACF in a proxy
	 */
	function apply( t ){
		loadContext();
		try {
			lock name="#getConcurrentEngineLockName()#" type="exclusive" timeout="60" {
				var oFuture = variables.target( arguments.t );
				if ( isNull( local.oFuture ) || !structKeyExists( local.oFuture, "getNative" ) ) {
					throw(
						type    = "IllegalFutureException",
						message = "The return of the function is NOT a ColdBox Future"
					);
				}
				return local.oFuture.getNative();
			}
		} catch ( any e ) {
			// Log it, so it doesn't go to ether
			err( "Error running FutureFunction: #e.message & e.detail#" );
			err( "Stacktrace for FutureFunction: #e.stackTrace#" );
			rethrow;
		} finally {
			unLoadContext();
		}
	}

}
