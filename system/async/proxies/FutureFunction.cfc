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
		return execute(
			( struct args ) => {
				var oFuture = variables.target( args.t );
				if (
					isNull( local.oFuture ) || !isStruct( oFuture ) || !structKeyExists(
						local.oFuture,
						"getNative"
					)
				) {
					throw(
						type    = "IllegalFutureException",
						message = "The return of the function [#oFuture.getClass().getName() ?: "null"#] is NOT a ColdBox Future"
					);
				}
				return local.oFuture.getNative();
			},
			"FutureFunction",
			arguments
		);
	}

}
