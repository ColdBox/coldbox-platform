/**
 * Functional interface that maps to java.util.function.BiFunction
 * See https://docs.oracle.com/javase/8/docs/api/java/util/function/BiFunction.html
 */
component extends="BaseProxy" {

	/**
	 * Constructor
	 *
	 * @f a function to be applied to to the previous element to produce a new element
	 */
	function init( required f ){
		super.init( arguments.f );
		return this;
	}

	/**
	 * Functional interface for the apply functional interface
	 * See https://docs.oracle.com/javase/8/docs/api/java/util/function/BiFunction.html#apply-T-U-
	 */
	function apply( t, u ){
		return execute(
			( struct args ) => {
				return variables.target(
					isNull( args.t ) ? javacast( "null", "" ) : args.t,
					isNull( args.u ) ? javacast( "null", "" ) : args.u
				);
			},
			"BiFunction",
			arguments
		);
	}

}
