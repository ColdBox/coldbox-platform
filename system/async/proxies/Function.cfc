/**
 * Functional Interface that maps to java.util.function.Function
 * See https://docs.oracle.com/javase/8/docs/api/java/util/function/Function.html
 */
component extends="BaseProxy" {

	/**
	 * Constructor
	 *
	 * @f              The lambda or closure to be used in the <code>apply()</code> method
	 * @debug          Add debugging or not
	 * @loadAppContext By default, we load the Application context into the running thread. If you don't need it, then don't load it.
	 */
	function init(
		required f,
		boolean debug          = false,
		boolean loadAppContext = true
	){
		super.init(
			arguments.f,
			arguments.debug,
			arguments.loadAppContext
		);
		return this;
	}

	/**
	 * Represents a function that accepts one argument and produces a result.
	 */
	function apply( t ){
		return execute(
			( struct args ) => {
				if ( isNull( args.t ) ) {
					return variables.target();
				}
				return variables.target( args.t );
			},
			"Function",
			arguments
		);
	}

}
