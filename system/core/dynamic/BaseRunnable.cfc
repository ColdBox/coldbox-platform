/**
 * This base class is used to support our concrete implementations of Java Runnable:
 * - Runnable => To run CFCs as runnables
 * - RunnableClosure => To run closures/lambdas as runnables
 *
 * @see https://docs.oracle.com/javase/8/docs/api/java/lang/Runnable.html
 */
component{

	/**
	 * Base Constructor
	 *
	 * @debug Add debugging messages for monitoring
	 */
	function init( boolean debug=false ){
		// Store entities
		variables.system 	= createObject( "java", "java.lang.System" );
		variables.debug 	= arguments.debug;

		// Prepare Runnable for CF Contexts
		if( server.keyExists( "lucee" ) ){

		} else {
			// Get original fusion context
			variables.cfContext = getCFMLContext().getFusionContext().clone();
		}

		return this;
	}

	/**
	 * This function is used for the engine to compile the page context bif into the page scope,
	 * if not, we don't get access to it.
	 */
	function getCFMLContext(){
		return getPageContext();
	}

	/**
	 * Load the CFML Context for the runnable thread
	 */
	function loadCfmlContext(){
		if( server.keyExists( "lucee" ) ){

		} else {
			// Get Fusion Context loaded
			getCFMLContext().getFusionContext().setCurrent( variables.cfContext );
			getCFMLContext().setFusionContext( variables.cfContext );
		}
	}

	/**
	 * Utiliy to send to output to console from a runanble
	 *
	 * @var Variable/Message to send
	 */
	function out( required var ){
		writeDump( var=arguments.var, output="console" );
	}

}