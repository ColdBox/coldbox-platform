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
	 * @loadAppContext By default, we load the Application context into the running thread. If you don't need it, then don't load it.
	 */
	function init( required runnable, method="run", boolean debug=false, boolean loadAppContext=true ){
		// Store entities
		variables.runnable 	= arguments.runnable;
		variables.method 	= arguments.method;

		// Super init
		super.init( argumentCollection=arguments );

		return this;
	}

	/**
	 * Runnable execution
	 */
	function run(){
		var threadName = getThreadName();

		if( variables.debug ){
			out( "===> Starting to run runnable: " &  threadName );
		}

		// Load the CFML context
		loadCfmlContext();

		//out( "App Data: " );
		//out( getApplicationMetadata() );

		try{
			// Execute the runnable CFC and method
			invoke( variables.runnable, variables.method );

		} catch( any e ){
			err( "Error running runnable #threadName# : #e.message#" );
			err( e.stackTrace );
		}

		if( variables.debug ){
			out( "===> Finished running runnable: " & threadName );
		}
	}

}