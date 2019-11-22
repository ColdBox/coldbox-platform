/**
 * The ColdBox Async Manager is in charge of creating runnable proxies based on
 * components or closures that can be spawned as native Java Threads.
 *
 * Once the runnables are created you will get back a ColdBox Future object
 * that can be used to interact with the running thread.
 */
component singleton{

	/**
	 * Constructor
	 *
	 * @debug Add debugging logs to System out, disabled by default
	 */
	function init( boolean debug=false ){
		variables.debug = arguments.debug;
		return this;
	}

	/****************************************************************
	 * Runnable Methods *
	 ****************************************************************/

	function allOf(){

	}

	function anyOf(){

	}


	/**
	 * Executes a runnable closure or component method via Java's CompletableFuture and gives you back a ColdBox Future
	 *
	 * @runnable A CFC instance or closure/lambda to execute async
	 * @method If the runnable is a CFC, then it executes a method on the CFC for you. Defaults to the `run()` method
	 * @debug Add debugging outputs to the console
	 * @loadAppContext By default it laods the entire CFML app environment to the threads. If you do not need it, then disable it
	 */
	Future function run(
		required runnable,
		method="run",
		boolean debug=variables.debug,
		boolean loadAppContext=true
	){
		return new Future().run( argumentCollection=arguments );
	}

	/****************************************************************
	 * Creation Methods *
	 ****************************************************************/

	function newFuture(){
		return new Future();
	}

	function newCompletedFuture( any value ){
		return new Future( arguments.value );
	}

	function newExecutor( type, numeric threads=10 ){

	}

}