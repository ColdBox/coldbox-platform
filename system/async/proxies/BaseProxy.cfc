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
	 * @target The target function to be applied via dynamic proxy to the required Java interface(s)
	 * @debug Add debugging messages for monitoring
	 * @loadAppContext By default, we load the Application context into the running thread. If you don't need it, then don't load it.
	 */
	function init(
		required target,
		boolean debug            = false,
		boolean loadAppContext   = true
	){
		variables.System           = createObject( "java", "java.lang.System" );
		variables.Thread           = createObject( "java", "java.lang.Thread" );
		variables.debug            = arguments.debug;
		variables.target           = arguments.target;
		variables.UUID             = createUUID();
		variables.loadAppContext   = arguments.loadAppContext;

		// If loading App context or not
		if ( arguments.loadAppContext ) {
			if ( server.keyExists( "lucee" ) ) {
				variables.cfContext   = getCFMLContext().getApplicationContext();
				variables.pageContext = getCFMLContext();
			} else {
				variables.DataSrcImplStatic     = createObject( "java", "coldfusion.sql.DataSrcImpl" );
				variables.fusionContextStatic   = createObject( "java", "coldfusion.filter.FusionContext" );
				variables.originalFusionContext = fusionContextStatic.getCurrent().clone();
				variables.productVersion        = listFirst( server.coldfusion.productVersion );
				if ( variables.productVersion > 2016 ) {
					variables.originalAppScope = variables.originalFusionContext.getApplicationScope();
				} else {
					variables.originalAppScope = variables.originalFusionContext.getAppHelper().getAppScope();
				}
				variables.originalPageContext = getCFMLContext();
				variables.originalPage        = variables.originalPageContext.getPage();
			}
			// out( "==> Storing contexts for thread: #getCurrentThread().toString()#." );
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
	 * Ability to load the context into the running thread
	 */
	function loadContext(){
		// Are we loading the context or not?
		if ( !variables.loadAppContext ) {
			return;
		}

		// out( "==> Context NOT loaded for thread: #getCurrentThread().toString()# loading it..." );

		try {
			// Lucee vs Adobe Implementations
			if ( server.keyExists( "lucee" ) ) {
				getCFMLContext().setApplicationContext( variables.cfContext );
			} else {
				// Set the current thread's class loader from the CF space to avoid
				// No class defined issues in thread land.
				getCurrentThread().setContextClassLoader( variables.originalFusionContext.getClass().getClassLoader() );

				// Prepare a new context in ACF for the thread
				var fusionContext = variables.originalFusionContext.clone();
				// Create a new page context for the thread
				var pageContext   = variables.originalPageContext.clone();
				// Reset it's scopes, else bad things happen
				pageContext.resetLocalScopes();
				// Set the cf context into it
				pageContext.setFusionContext( fusionContext );
				fusionContext.pageContext = pageContext;
				fusionContext.SymTab_setApplicationScope( variables.originalAppScope );

				// Create a fake page to run this thread in and link it to the fake page context and fusion context
				var page             = variables.originalPage._clone();
				page.pageContext     = pageContext;
				fusionContext.parent = page;

				// Set the current context of execution now
				variables.fusionContextStatic.setCurrent( fusionContext );
				pageContext.initializeWith(
					page,
					pageContext,
					pageContext.getVariableScope()
				);
			}
		} catch ( any e ) {
			err( "Error loading context #e.toString()#" );
		}
	}

	/**
	 * Ability to unload the context out of the running thread
	 */
	function unLoadContext(){
		// Are we loading the context or not?
		if ( !variables.loadAppContext ) {
			return;
		}

		// out( "==> Removing context for thread: #getCurrentThread().toString()#." );

		try {
			// Lucee vs Adobe Implementations
			if ( server.keyExists( "lucee" ) ) {
			} else {
				// Ensure any DB connections used get returned to the connection pool. Without clearSqlProxy an executor will hold onto any connections it touched while running and they will not timeout/close, and no other code can use the connection except for the executor that last touched it.   Credit to Brad Wood for finding this!
				variables.DataSrcImplStatic.clearSqlProxy();
				variables.fusionContextStatic.setCurrent( javacast( "null", "" ) );
			}
		} catch ( any e ) {
			err( "Error Unloading context #e.toString()#" );
		}
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
	 * Engine-specific lock name. For Adobe, lock is shared for this CFC instance.  On Lucee, it is random (i.e. not locked).
	 * This singlethreading on Adobe is to workaround a thread safety issue in the PageContext that needs fixed.
	 * Amend this check once Adobe fixes this in a later update
	 */
	function getConcurrentEngineLockName(){
		if ( server.keyExists( "lucee" ) ) {
			return createUUID();
		} else {
			return variables.UUID;
		}
	}

}
