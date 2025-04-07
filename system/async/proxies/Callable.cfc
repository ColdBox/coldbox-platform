component extends="Supplier" {

	/**
	 * Functional interface for supplier to get a result
	 * See https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Callable.html
	 */
	function call(){
		return execute(
			( struct args ) => {
				if ( isClosure( variables.target ) || isCustomFunction( variables.target ) ) {
					return variables.target();
				} else {
					return invoke( variables.target, variables.method );
				}
			},
			"Callable",
			arguments
		);
	}

}
