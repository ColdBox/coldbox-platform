/**
 * Functional interface that maps to java.util.function.Consumer
 * See https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/util/function/Consumer.html
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
	 * See https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/util/function/Consumer.html#accept-T-U-
	 */
	function accept( required t ){
		loadContext();
		try {
			lock name="#getConcurrentEngineLockName()#" type="exclusive" timeout="60" {
				variables.target( arguments.t );
			}
		} finally {
			unLoadContext();
		}
	}

	function andThen( required after ){
	}

}
