/**
 * This base class is used to support our concrete implementations of Java Runnable:
 * - Runnable => To run CFCs as runnables
 * - RunnableClosure => To run closures/lambdas as runnables
 *
 * @see https://docs.oracle.com/javase/8/docs/api/java/lang/Runnable.html
 */
component accessors="true"{

	/**
	 * java.lang.System
	 */
	property name="System";

	/**
	 * java.lang.Thread
	 */
	property name="Thread";

	/**
	 * Debug Mode or not
	 */
	property name="debug" type="boolean";

	/**
	 * Are we loading the CFML app context or not, default is true
	 */
	property name="loadAppContext" type="boolean";

	/**
	 * Base Constructor
	 *
	 * @debug Add debugging messages for monitoring
	 * @loadAppContext By default, we load the Application context into the running thread. If you don't need it, then don't load it.
	 */
	function init( boolean debug=false, boolean loadAppContext=true ){
		// Store entities
		variables.System 			= createObject( "java", "java.lang.System" );
		variables.Thread 			= createObject( "java", "java.lang.Thread" );
		variables.debug 			= arguments.debug;
		variables.oneHundredYears 	= ( 60 * 60 * 24 * 365 * 100 );
		variables.loadAppContext 	= arguments.loadAppContext;
		variables.contextRoot 		= expandPath( "/" );
		variables.hostName 			= cgi.server_name;

		if( arguments.loadAppContext ){
			// Prepare Runnable for CF Contexts
			if( server.keyExists( "lucee" ) ){
				variables.cfContext = getCFMLContext().getApplicationContext();
			} else {
				// Get original fusion context
				variables.cfContext = getCFMLContext().getFusionContext().clone();
			}
		}

		return this;
	}

	/**
	 * Get the current thread java object
	 */
	function getCurrentThread(){
		return variables.Thread.currentThread();
	}

	/**
	 * Get the current thread name
	 */
	function getThreadName(){
		return getCurrentThread().getName();
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
		// Are we loading the context or not?
		if( !variables.loadAppContext ){
			return;
		}

		// Perpetuate the timeout to avoid engine killing.
		cfsetting( requesttimeout=oneHundredYears );

		if( server.keyExists( "lucee" ) ){
			getCFMLContext().setApplicationContext( variables.cfContext );
		} else {
			// Get Fusion Context loaded
			getCFMLContext().getFusionContext().setCurrent( variables.cfContext );
			getCFMLContext().setFusionContext( variables.cfContext );
		}

		if( variables.debug ){
			out( "===> Loaded CFML App Context for #getThreadName()#" );
		}
	}

	/**
	 * Call back to release a cfml page context, if any
	 */
	function releaseCfmlContext(){
	}

	/**
	 * Utiliy to send to output to console from a runanble
	 *
	 * @var Variable/Message to send
	 */
	function out( required var ){
		variables.System.out.println( arguments.var.toString() );
	}

	/**
	 * Utiliy to send to output to console from a runanble via the error stream
	 *
	 * @var Variable/Message to send
	 */
	function err( required var ){
		variables.System.err.println( arguments.var.toString() );
	}

}