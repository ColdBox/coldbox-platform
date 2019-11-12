/**
 * This class models a Runnable Java class
 *
 * @see https://docs.oracle.com/javase/8/docs/api/java/lang/Runnable.html
 */
component{

	/**
	 * Constructor
	 *
	 * @runnable A CFC to execute async via Runnable interface in Java, this CFC must implement the `run()` function or bypass it via the method argument
	 * @method The method to execute in the CFC async, defaults to `run()`
	 * @debug Add debugging messages for monitoring
	 */
	function init( required runnable, method="run", boolean debug=false ){
		variables.runnable 	= arguments.runnable;
		variables.method 	= arguments.method;
		variables.system 	= createObject( "java", "java.lang.System" );
		variables.debug 	= arguments.debug;
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

		try{
			// Execute the runnable closure
			invoke( variables.runnable, variables.method );

		} catch( any e ){
			out( "Error running runnable #threadname# : #e.message#" );
			out( e.detail );
			out( e.stackTrace );
		}

		if( variables.debug ){
			out( "Finished running runnable: " & threadname );
		}
	}

	/**
	 * Utiliy to send to output to console.
	 *
	 * @message Message to send
	 * @addNewLine Add a line break or not, default is yes
	 */
	private function out( required message, boolean addNewLine=true ){
		if( arguments.addNewLine ){
			arguments.message &= chr( 13 ) & chr( 10 );
		}

		variables.system.out.println( arguments.message );
		return this;
	}

}