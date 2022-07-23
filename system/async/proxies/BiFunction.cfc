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
		loadContext();
		try {
			lock name="#getConcurrentEngineLockName()#" type="exclusive" timeout="60" {
				return variables.target(
					isNull( arguments.t ) ? javacast( "null", "" ) : arguments.t,
					isNull( arguments.u ) ? javacast( "null", "" ) : arguments.u
				);
			}
		} catch ( any e ) {
			// Log it, so it doesn't go to ether
			err( "Error running BiFunction: #e.message & e.detail#" );
			err( "Stacktrace for BiFunction: #e.stackTrace#" );
			rethrow;
		} finally {
			unLoadContext();
		}
	}

	function andThen( required after ){
	}

}
