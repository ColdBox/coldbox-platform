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
				if ( isNull( oFuture ) || !structKeyExists( oFuture, "getNative" ) ) {
					throw(
						type    = "IllegalFutureException",
						message = "The return of the function is NOT a ColdBox Future"
					);
				}
				return oFuture.getNative();
			}
		} finally {
			unLoadContext();
		}
	}

}
