component{

	function init(){
		return this;
	}

	/**
	 * Creates a runnable proxy from the incoming CFC or closure/lambda and then executes it as a background thread.
	 *
	 * @runnable A CFC or closure/lambda to execute async
	 * @method If the runnable is a CFC, then it executes a method on the CFC asynchronously. Defaults to the `run()` method
	 * @debug Add debugging outputs to the console
	 * @loadAppContext By default it laods the entire CFML app environment to the threads. If you do not need it, then disable it
	 */
	function run(
		required runnable,
		method="run",
		boolean debug=false,
		boolean loadAppContext=true
	){
		if( isClosure( arguments.runnable ) || isCustomFunction( arguments.runnable ) ){
			var oThread = createRunnableClosure( argumentCollection=arguments );
		} else {
			var oThread = createRunnable( argumentCollection=arguments );
		}

		// Start the runnable Thread
		//oThread.start();

		// Return it as a Future wrapper, so you can start it
		return new Future( oThread );
	}

	/**
	 * Creates a runnable proxy from the incoming CFC and then executes it as a background thread.
	 *
	 * @runnable A runnable CFC instance
	 * @method The method to execute on the CFC asynchronously, defautls to the `run()` method
	 * @debug Add debugging outputs to the console
	 * @loadAppContext By default it laods the entire CFML app environment to the threads. If you do not need it, then disable it
	 */
	any function createRunnable(
		required runnable,
		method="run",
		boolean debug=false,
		boolean loadAppContext=true
	){
		// Create the runnable proxy
		return createObject( "java", "java.lang.Thread" ).init(
			createDynamicProxy(
				new coldbox.system.core.async.Runnable(
					runnable       = arguments.runnable,
					method         = arguments.method,
					debug          = arguments.debug,
					loadAppContext = arguments.loadAppContext
				),
				[ "java.lang.Runnable" ]
			),
			newThreadName()
		);
	}

	/**
	 * Creates a runnable proxy from the incoming closure/lambda and then executes it as a background thread.
	 *
	 * @runnable A runnable CFC instance
	 * @debug Add debugging outputs to the console
	 * @loadAppContext By default it laods the entire CFML app environment to the threads. If you do not need it, then disable it
	 */
	any function createRunnableClosure(
		required runnable,
		boolean debug=false,
		boolean loadAppContext=true
	){

		// Create the runnable proxy
		return createObject( "java", "java.lang.Thread" ).init(
			createDynamicProxy(
				new coldbox.system.core.async.RunnableClosure(
					runnable       = arguments.runnable,
					debug          = arguments.debug,
					loadAppContext = arguments.loadAppContext
				),
				[ "java.lang.Runnable" ]
			),
			newThreadName()
		);
	}

	/**
	 * Get a new thread name using our patterns
	 */
	private function newThreadName(){
		return "cbasync-#createUUID()#";
	}

}