/**
 * This class models a Runnable Java class
 *
 * @see https://docs.oracle.com/javase/8/docs/api/java/lang/Runnable.html
 */
component{

	/**
	 * Constructor
	 *
	 * @runnable A closure to execute async via Runnable interface in Java
	 * @debug Add debugging messages for monitoring
	 */
	function init( required runnable, boolean debug=false ){
		variables.runnable 	= arguments.runnable;
		variables.debug 	= arguments.debug;

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
			out( "Starting to run runnable closure: " &  threadname );
		}

		try{
			// Execute the runnable closure
			variables.runnable();

		} catch( any e ){
			out( "Error running runnable closure #threadname# : #e.message#" );
			out( e.detail );
			out( e.stackTrace );
		}

		if( variables.debug ){
			out( "Finished running runnable closure: " & threadname );
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