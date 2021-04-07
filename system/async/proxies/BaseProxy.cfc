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
	 * Are we unloading the context or not, default is true. Usually this is set to false for adobe tasks so they can recur.
	 */
	property name="unloadAppContext" type="boolean";

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
	 * @unloadAppContext By default we unload the context if set. You can turn this off if you want to leave a task with the context loaded.
	 */
	function init(
		required target,
		boolean debug          = false,
		boolean loadAppContext = true,
		boolean unloadAppContext = true
	){
		variables.System          = createObject( "java", "java.lang.System" );
		variables.Thread          = createObject( "java", "java.lang.Thread" );
		variables.debug           = arguments.debug;
		variables.target          = arguments.target;
		variables.UUID            = createUUID();
		variables.loadAppContext  = arguments.loadAppContext;
		variables.unloadAppContext = arguments.unloadAppContext;
		variables.contextIsLoaded = false;

		// If loading App context or not
		if ( arguments.loadAppContext ) {
			if ( server.keyExists( "lucee" ) ) {
				variables.cfContext   = getCFMLContext().getApplicationContext();
				variables.pageContext = getCFMLContext();
			} else {
				variables.DataSrcImplStatic		= createObject( "java", "coldfusion.sql.DataSrcImpl" );
				variables.fusionContextStatic   = createObject( "java", "coldfusion.filter.FusionContext" );
				variables.originalFusionContext = fusionContextStatic.getCurrent();
				variables.originalPageContext   = getCFMLContext();
				variables.originalPage          = variables.originalPageContext.getPage();
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

		// If the context is already load it, don't try again
		if( variables.contextIsLoaded ){
			//out( "=====> EXITING, CONTEXT IS LOADED ALREADY!" );
			return;
		}

		// out( "==> Context NOT loaded for thread: #getCurrentThread().toString()# loading it..." );

		try{
			// Lucee vs Adobe Implementations
			if ( server.keyExists( "lucee" ) ) {
				getCFMLContext().setApplicationContext( variables.cfContext );
			} else {
				var fusionContext = variables.originalFusionContext.clone();
				var pageContext   = variables.originalPageContext.clone();
				pageContext.resetLocalScopes();
				var page             = variables.originalPage._clone();
				page.pageContext     = pageContext;
				fusionContext.parent = page;

				variables.fusionContextStatic.setCurrent( fusionContext );
				fusionContext.pageContext = pageContext;
				pageContext.setFusionContext( fusionContext );
				pageContext.initializeWith(
					page,
					pageContext,
					pageContext.getVariableScope()
				);
			}
			variables.contextIsLoaded = true;
		} catch( any e ){
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

		//out( "==> Removing context for thread: #getCurrentThread().toString()#." );

		try{
			// Lucee vs Adobe Implementations
			if ( server.keyExists( "lucee" ) ) {
				// Nothing right now
				if( variables.unloadAppContext ){
				}
			} else {
				// Ensure any DB connections used get returned to the connection pool. Without clearSqlProxy an executor will hold onto any connections it touched while running and they will not timeout/close, and no other code can use the connection except for the executor that last touched it.   Credit to Brad Wood for finding this!
				variables.DataSrcImplStatic.clearSqlProxy();

				// Unload the fusion context only if marked, else ignore on ADOBE
				// Adobe kills the tasks if you do this for periodic tasks.
				if( variables.unloadAppContext ){
					variables.fusionContextStatic.setCurrent( javacast( "null", "" ) );
				}
			}
		} catch( any e ){
			err( "Error Unloading context #e.toString()#" );
		}
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

	/**
	 * Engine-specific lock name. For Adobe, lock is shared for this CFC instance.  On Lucee, it is random (i.e. not locked).
	 * This singlethreading on Adobe is to workaround a thread safety issue in the PageContext that needs fixed.
	 * Ammend this check once Adobe fixes this in a later update
	 */
	function getConcurrentEngineLockName(){
		if ( server.keyExists( "lucee" ) ) {
			return createUUID();
		} else {
			return variables.UUID;
		}
	}

}
