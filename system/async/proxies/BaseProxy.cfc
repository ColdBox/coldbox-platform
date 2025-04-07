/**
 * Functional interface base dynamically compiled via dynamic proxy
 */
component accessors="true" {

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
	 * The target function to be applied via dynamic proxy to the required Java interface(s)
	 */
	property name="target";

	/**
	 * Constructor
	 *
	 * @target         The target function to be applied via dynamic proxy to the required Java interface(s)
	 * @debug          Add debugging messages for monitoring
	 * @loadAppContext By default, we load the Application context into the running thread. If you don't need it, then don't load it.
	 */
	function init(
		required target,
		boolean debug          = false,
		boolean loadAppContext = true
	){
		variables.System         = createObject( "java", "java.lang.System" );
		variables.Thread         = createObject( "java", "java.lang.Thread" );
		variables.debug          = arguments.debug;
		variables.target         = arguments.target;
		variables.UUID           = createUUID();
		variables.loadAppContext = arguments.loadAppContext;
		variables.threadHashCode = getCurrentThread().hashCode();

		variables.isBoxLang = server.keyExists( "boxlang" );
		variables.isAdobe   = !variables.isBoxLang && server.keyExists( "coldfusion" ) && server.coldfusion.keyExists( "productName" ) && server.coldfusion.productName.findNocase( "ColdFusion" ) > 0;
		variables.isLucee   = !variables.isBoxLang && server.keyExists( "lucee" );

		// If loading App context or not
		if ( arguments.loadAppContext ) {
			if ( variables.isLucee ) {
				variables.cfContext   = getCFMLContext().getApplicationContext();
				variables.pageContext = getCFMLContext();
			} else if ( variables.isAdobe ) {
				variables.DataSrcImplStatic     = createObject( "java", "coldfusion.sql.DataSrcImpl" );
				variables.fusionContextStatic   = createObject( "java", "coldfusion.filter.FusionContext" );
				variables.originalFusionContext = fusionContextStatic.getCurrent().clone();
				variables.productVersion        = listFirst( server.coldfusion.productVersion );
				variables.originalAppScope      = variables.originalFusionContext.getAppHelper().getAppScope();
				variables.originalPageContext   = getCFMLContext();
				variables.originalPage          = variables.originalPageContext.getPage();
			} else if ( variables.isBoxLang ) {
				variables.boxContext = getBoxContext();
			}
			// out( "==> Storing contexts for thread: #getCurrentThread().toString()#." );
		}

		return this;
	}

	/**
	 * Wrapper for the actual execution of each proxy to consolidate logic
	 * and error handling
	 *
	 * @callback  The callback to execute (receives the args)
	 * @className The name of the class being executed (for error handling/logging)
	 * @args      The arguments to pass to the callback
	 */
	private function execute(
		required Function callback,
		required string className,
		struct args = {}
	){
		try {
			if ( isAdobe ) {
				return executeAdobe( () => callback( args ) );
			} else if ( isLucee ) {
				return executeLucee( () => callback( args ) );
			} else if ( isBoxLang ) {
				return executeBoxLang( () => callback( args ) );
			} else {
				throw( "Unsupported CFML engine" );
			}
		} catch ( any e ) {
			// Log it, so it doesn't go to ether
			err( "Error running #className#: #e.message & e.detail#" );
			err( "Stacktrace for #className#: #e.stackTrace#" );
			sendExceptionToLogBoxIfAvailable( e );
			sendExceptionToOnExceptionIfAvailable( e );
			rethrow;
		}
	}

	private function executeLucee( required Function callback ){
		if ( performContextManagement() ) {
			getCFMLContext().setApplicationContext( variables.cfContext );
			// TODO: We're not setting the page context, so no request variables are available.
			// There were initially issues with thread safety in cloning the page context. We should revisit that.
		}
		return callback();
		// Lucee has no "unload" logic
	}

	private function executeAdobe( required Function callback ){
		/*
		 * Engine-specific lock name. For Adobe, lock is shared for this CFC instance.  On Lucee, it is random (i.e. not locked).
		 * This singlethreading on Adobe is to workaround a thread safety issue in the PageContext that needs fixed.
		 * Amend this check once Adobe fixes this in a later update
		 */
		lock name="#variables.UUID#" type="exclusive" timeout="60" {
			if ( !performContextManagement() ) {
				return callback();
			}
			try {
				// Set the current thread's class loader from the CF space to avoid
				// No class defined issues in thread land.
				getCurrentThread().setContextClassLoader(
					variables.originalFusionContext.getClass().getClassLoader()
				);

				// Prepare a new context in ACF for the thread
				var fusionContext = variables.originalFusionContext.clone();
				variables.fusionContextStatic.setCurrent( fusionContext );
				// Create a new page context for the thread
				var pageContext = variables.originalPageContext.clone();
				// Reset it's scopes, else bad things happen
				pageContext.resetLocalScopes();
				// Set the cf context into it
				pageContext.setFusionContext( fusionContext );
				fusionContext.pageContext = pageContext;
				if ( !isNull( variables.originalAppScope ) ) {
					fusionContext.SymTab_setApplicationScope( variables.originalAppScope );
				}

				// Create a fake page to run this thread in and link it to the fake page context and fusion context
				var page             = variables.originalPage._clone();
				page.pageContext     = pageContext;
				fusionContext.parent = page;

				// Set the current context of execution now
				pageContext.setPage( page );
				pageContext.initializeWith(
					page,
					pageContext,
					pageContext.getVariableScope()
				);
				fusionContext.setAsyncThread( true );

				return callback();
			} finally {
				// Ensure any DB connections used get returned to the connection pool. Without clearSqlProxy an executor will hold onto any connections it touched while running and they will not timeout/close, and no other code can use the connection except for the executor that last touched it.   Credit to Brad Wood for finding this!
				variables.DataSrcImplStatic.clearSqlProxy();
				variables.fusionContextStatic.setCurrent( javacast( "null", "" ) );
			}
		}
	}

	private function executeBoxLang( required Function callback ){
		if ( !performContextManagement() ) {
			return callback();
		}
		return runThreadInContext( context = variables.boxContext, callback = arguments.callback );
	}

	/**
	 * Get the current thread java object
	 */
	function getCurrentThread(){
		return variables.Thread.currentThread();
	}

	Boolean function performContextManagement(){
		return variables.loadAppContext && variables.threadHashCode != getCurrentThread().hashCode();
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
	 * Utility to send to output to console from a runnable
	 *
	 * @var Variable/Message to send
	 */
	function out( required var ){
		variables.System.out.println( arguments.var.toString() );
	}

	/**
	 * Utility to send to output to console from a runnable via the error stream
	 *
	 * @var Variable/Message to send
	 */
	function err( required var ){
		variables.System.err.println( arguments.var.toString() );
	}

	/**
	 * Check if your are using the fork join pool or cfthread.
	 */
	boolean function inForkJoinPool(){
		return ( findNoCase( "ForkJoinPool", getThreadName() ) NEQ 0 );
	}

	void function sendExceptionToLogBoxIfAvailable( required any exception ){
		if ( !variables.loadAppContext ) {
			return;
		}

		if ( !structKeyExists( application, "wirebox" ) ) {
			return;
		}

		try {
			application.wirebox
				.getLogBox()
				.getRootLogger()
				.error( arguments.exception.message, arguments.exception );
		} catch ( any e ) {
			err( "Error trying to send exception to LogBox: #e.message & e.detail#" );
			err( "Stacktrace trying to send exception to LogBox: #e.stackTrace#" );
		}
	}

	void function sendExceptionToOnExceptionIfAvailable( required any exception ){
		if ( !variables.loadAppContext ) {
			return;
		}

		if ( !structKeyExists( application, "wirebox" ) ) {
			return;
		}

		try {
			application.wirebox.getEventManager().announce( "onException", { exception : arguments.exception } );
		} catch ( any e ) {
			err(
				"Error trying to announce exception to the ColdBox onException interception point: #e.message & e.detail#"
			);
			err( "Stacktrace announcing exception to the ColdBox onException interception point: #e.stackTrace#" );
		}
	}

}
