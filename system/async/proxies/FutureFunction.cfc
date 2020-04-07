/**
 * Functional Interface that maps to java.util.function.Function
 * but will return the native future which is expected in the result
 * of the called target
 */
component extends="Function" {

	/**
	 * Represents a function that accepts one argument and produces a result.
	 */
	function apply( t ){
		var results = super.apply( arguments.t );

		if( isNull( results ) || !structKeyExists( results, "getNative" ) ){
			throw(
				type="IllegalFutureException",
				message="The return of the function is NOT a ColdBox Future"
			);
		}

		return results.getNative();
	}

}