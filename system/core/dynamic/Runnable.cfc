/**
 * This class makes any CFC run as a Runnable Java class via dynamic proxies and context loading
 *
 * @see https://docs.oracle.com/javase/8/docs/api/java/lang/Runnable.html
 */
component extends="BaseRunnable"{

	/**
	 * Constructor
	 *
	 * @runnable A CFC to execute async via Runnable interface in Java, this CFC must implement the `run()` function or bypass it via the method argument
	 * @method The method to execute in the CFC async, defaults to `run()`
	 * @debug Add debugging messages for monitoring
	 */
	function init( required runnable, method="run", boolean debug=false ){
		// Store entities
		variables.runnable 	= arguments.runnable;
		variables.method 	= arguments.method;

		// Super init
		super.init( argumnentCollection=arguments );

		return this;
	}

	/**
	 * Runnable execution
	 */
	function run(){
		var threadname = createObject( "java", "java.lang.Thread" ).currentThread().getName();

		if( variables.debug ){
			out( "Starting to run runnable: " &  threadname );
		}

		// Load the CFML context
		loadCfmlContext();

		try{
			// Execute the runnable closure
			invoke( variables.runnable, variables.method );
		} catch( any e ){
			out( "Error running runnable #threadname# : #e.message#" );
			out( e );
		}

		if( variables.debug ){
			out( "Finished running runnable: " & threadname );
		}
	}

}