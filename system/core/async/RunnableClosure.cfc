/**
 * This class models a Runnable Java class for closures/lambdas
 *
 * @see https://docs.oracle.com/javase/8/docs/api/java/lang/Runnable.html
 */
component extends="BaseRunnable"{

	/**
	 * Constructor
	 *
	 * @runnable A closure to execute async via Runnable interface in Java
	 * @debug Add debugging messages for monitoring
	 * @loadAppContext By default, we load the Application context into the running thread. If you don't need it, then don't load it.
	 */
	function init( required runnable, boolean debug=false, boolean loadAppContext=true ){
		variables.runnable 	= arguments.runnable;

		// Super init
		super.init( argumnentCollection=arguments );

		return this;
	}

	/**
	 * Runnable execution
	 */
	function run(){
		var threadname = getThreadName();

		if( variables.debug ){
			out( "Starting to run runnable closure: " &  threadName );
		}

		// Load the CFML context
		loadCfmlContext();

		try{

			// Execute the runnable closure
			variables.runnable();

		} catch( any e ){
			out( "Error running runnable closure : #e.message#" );
			err( e.stackTrace );
		}

		if( variables.debug ){
			out( "Finished running runnable closure: " & threadName );
		}
	}

}