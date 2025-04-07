/**
 * Functional interface that maps to java.util.function.BiFunction
 * See https://docs.oracle.com/javase/8/docs/api/java/util/function/BiConsumer.html
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
	 * Performs this operation on the given arguments.
	 * See https://docs.oracle.com/javase/8/docs/api/java/util/function/BiConsumer.html#accept-T-U-
	 */
	function accept( t, u ){
		return execute(
			( struct args ) => {
				variables.target( args.t ?: javacast( "null", "" ), args.u ?: javacast( "null", "" ) );
			},
			"BiConsumer",
			arguments
		);
	}

}
