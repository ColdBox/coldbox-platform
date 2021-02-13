/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A simple Scope Appender that logs to a specified scope.
 * Properties:
 * - scope : the scope to persist to, defaults to request (optional)
 * - key   : the key to use in the scope, it defaults to the name of the Appender (optional)
 * - limit : a limit to the amount of logs to rotate. Defaults to 0, unlimited (optional)
**/
component accessors="true" extends="coldbox.system.logging.AbstractAppender"{

    /**
	 * Constructor
	 *
	 * @name The unique name for this appender.
	 * @properties A map of configuration properties for the appender"
	 * @layout The layout class to use in this appender for custom message rendering.
	 * @levelMin The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN
	 * @levelMax The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARN
	 */
	function init(
		required name,
		struct properties={},
		layout="",
		levelMin=0,
		levelMax=4
	){
        // Init supertype
		super.init( argumentCollection=arguments );

		// Verify properties
		if( NOT propertyExists( "scope" ) ){
			setProperty( "scope", "request" );
		}
		if( NOT propertyExists( "key" ) ){
			setProperty( "key", getName() );
		}
		if( NOT propertyExists( "limit" ) OR NOT isNumeric( getProperty( "limit" ) ) ){
			setProperty( "limit", 0 );
		}

		// Scope storage
		variables.scopeStorage = new coldbox.system.core.collections.ScopeStorage();
		// Scope Checks
		variables.scopeStorage.scopeCheck( getproperty( "scope" ) );
		// UUID generator
		variables.uuid = createobject( "java", "java.util.UUID" );

		return this;
    }

    /**
	 * Write an entry into the appender. You must implement this method yourself.
	 *
	 * @logEvent The logging event to log
	 */
	function logMessage( required coldbox.system.logging.LogEvent logEvent ){
		var entry    = structnew();
		var limit    = getProperty( "limit" );
		var loge     = arguments.logEvent;

		// Verify storage
		ensureStorage();

		// Check Limits
		var logStack = getStorage();

		if( limit GT 0 and arrayLen( logStack ) GTE limit ){
			// pop one out, the oldest
			arrayDeleteAt( logStack, 1 );
		}

		// Log Away
		entry.id           = variables.uuid.randomUUID().toString();
		entry.logDate      = loge.getTimeStamp();
		entry.appenderName = getName();
		entry.severity     = severityToString( loge.getseverity() );
		entry.message      = loge.getMessage();
		entry.extraInfo    = loge.getextraInfo();
		entry.category     = loge.getCategory();

		// Save Storage
		arrayAppend( logStack, entry );
		saveStorage( logStack );

		return this;
	}

	/************************************ PRIVATE ***************************************/

	/**
	 * Get the storage
	 */
	private any function getStorage(){
		lock name="#getname()#.scopeoperation" type="exclusive" timeout="20" throwOnTimeout="true"{
			return variables.scopeStorage.get( getProperty( "key" ), getProperty( "scope" ) );
		}
	}

	/**
	 * Save Storage
	 *
	 * @data The data to store
	 */
	private function saveStorage( required data ){
		lock name="#getname()#.scopeoperation" type="exclusive" timeout="20" throwOnTimeout="true"{
			variables.scopeStorage.put( getProperty( "key" ), arguments.data, getProperty( "scope" ) );
		}
		return this;
	}

	/**
	 * Ensure the first storage in the scope
	 */
	private function ensureStorage(){
		if( NOT variables.scopeStorage.exists( getProperty( "key" ), getproperty( "scope" ) ) ){
			variables.scopeStorage.put( getProperty( "key" ), [], getProperty( "scope" ) );
		}
		return this;
	}

}