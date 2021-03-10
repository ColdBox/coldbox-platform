/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A simple DB appender for MySQL, MSSQL, Oracle, PostgreSQL
 *
 * Properties:
 * - dsn : the dsn to use for logging
 * - table : the table to store the logs in
 * - schema : which schema the table exists in (Optional)
 * - columnMap : A column map for aliasing columns. (Optional)
 * - autocreate : if true, then we will create the table. Defaults to false (Optional)
 * - ensureChecks : if true, then we will check the dsn and table existence.  Defaults to true (Optional)
 *
 * The columns needed in the table are
 *
 * - id : UUID
 * - severity : string
 * - category : string
 * - logdate : timestamp
 * - appendername : string
 * - message : string
 * - extrainfo : string
 *
 * If you are building a mapper, the map must have the above keys in it.
**/
component accessors="true" extends="coldbox.system.logging.AbstractAppender" {

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

		// valid columns
		variables.columns = "id,severity,category,logdate,appendername,message,extrainfo";
		// UUID generator
		variables.uuid = createobject( "java", "java.util.UUID" );

		// Verify properties
		if( NOT propertyExists( 'dsn' ) ){
			throw( message="No dsn property defined", type="DBAppender.InvalidProperty" );
		}
		if( NOT propertyExists( 'table' ) ){
			throw( message="No table property defined", type="DBAppender.InvalidProperty" );
		}
		if( NOT propertyExists( 'autoCreate' ) OR NOT isBoolean( getProperty( 'autoCreate' ) ) ){
			setProperty( 'autoCreate', false );
		}
		if( NOT propertyExists( 'defaultCategory' ) ){
			setProperty( "defaultCategory", arguments.name );
		}
		if( propertyExists( "columnMap" ) ){
			checkColumnMap();
		}
		if( NOT propertyExists( "ensureChecks" ) ){
			setProperty( "ensureChecks", true );
		}
		if( NOT propertyExists( "rotate" ) ){
			setProperty( "rotate", true );
		}
		if( NOT propertyExists( "rotationDays" ) ){
			setProperty( "rotationDays", 30 );
		}
		if( NOT propertyExists( "rotationFrequency" ) ){
			setProperty( "rotationFrequency", 5 );
		}
		if( NOT propertyExists( "schema" ) ){
			setProperty( "schema", "" );
		}

		// DB Rotation Time
		variables.lastDBRotation = "";
		return this;
	}

	/**
	 * Runs on registration
	 */
	function onRegistration(){
		if( getProperty( "ensureChecks" ) ){
			// Table Checks
			ensureTable();
		}
		return this;
	}

    /**
	 * Write an entry into the appender. You must implement this method yourself.
	 *
	 * @logEvent The logging event to log
	 */
	function logMessage( required coldbox.system.logging.LogEvent logEvent ){
		var category = getProperty( "defaultCategory" );

		// Check Category Sent?
		if( NOT arguments.logEvent.getCategory() eq "" ){
			category = arguments.logEvent.getCategory();
		}

		queueMessage( {
			severity 	: severityToString( arguments.logEvent.getseverity() ),
			category 	: left( category, 100 ),
			timestamp 	: arguments.logEvent.getTimestamp(),
			message 	: arguments.logEvent.getMessage(),
			extraInfo 	: arguments.logEvent.getExtraInfoAsString()
		} );

		return this;
	}

	/**
	 * Rotation checks
	 */
	function rotationCheck(){
		// Verify if in rotation frequency
		if( !getProperty( "rotate" ) OR ( isDate( variables.lastDBRotation ) AND dateDiff( "n",  variables.lastDBRotation, now() ) LTE getProperty( "rotationFrequency" ) ) ){
			return;
		}

		// Rotations
		this.doRotation();

		// Store last profile time
		variables.lastDBRotation = now();
	}

	/**
	 * Do the rotation
	 */
	function doRotation(){
		var qLogs 		= "";
		var cols 		= variables.columns;
		var targetDate 	= dateAdd( "d", "-#getProperty( "rotationDays" )#", now() );

		queryExecute(
			"DELETE
				FROM #getTable()#
				WHERE #listgetAt( cols,4)# < :datetime
			",
			{
				datetime = { cfsqltype="#getDateTimeDBType()#", value="#dateFormat( targetDate, 'mm/dd/yyyy' )#" }
			},
			{
				datasource = getProperty( "dsn" )
			}
		);

		return this;
	}

	/**
	 * Fired once the listener starts queue processing
	 *
	 * @queueContext A struct of data attached to this processing queue thread
	 */
	function onLogListenerStart( required struct queueContext ){
	}

	/**
	 * Fired once the listener will go to sleep
	 *
	 * @queueContext A struct of data attached to this processing queue thread
	 */
	function onLogListenerSleep( required struct queueContext ){
		this.rotationCheck();
	}

	/**
	 * Processes a queue element to a destination
	 * This method is called by the log listeners asynchronously.
	 *
	 * @data The data element the queue needs processing
	 * @queueContext The queue context in process
	 *
	 * @return ConsoleAppender
	 */
	function processQueueElement( required data, required queueContext ){
		// Column Maps
		if( propertyExists( 'columnMap' ) ){
			var cmap = getProperty( 'columnMap' );
			var cols = "#cmap.id#,#cmap.severity#,#cmap.category#,#cmap.logdate#,#cmap.appendername#,#cmap.message#,#cmap.extrainfo#";
		} else {
			var cols = variables.columns;
		}

		// Insert into table
		queryExecute(
			"INSERT INTO #getTable()# (#cols#)
				VALUES (
					:uuid,
					:severity,
					:category,
					:timestamp,
					:name,
					:message,
					:extraInfo
				)
			",
			{
				uuid      = { cfsqltype="cf_sql_varchar", 	value="#variables.uuid.randomUUID().toString()#" },
				severity  = { cfsqltype="cf_sql_varchar", 	value="#arguments.data.severity#" },
				category  = { cfsqltype="cf_sql_varchar", 	value="#arguments.data.category#" },
				timestamp = { cfsqltype="cf_sql_timestamp", value="#arguments.data.timestamp#" },
				name      = { cfsqltype="cf_sql_varchar", 	value="#left( getName(), 100 )#" },
				message   = { cfsqltype="cf_sql_varchar", 	value="#arguments.data.message#" },
				extraInfo = { cfsqltype="cf_sql_varchar", 	value="#arguments.data.extraInfo#" }
			},
			{
				datasource = getProperty( "dsn" )
			}
		);
		return this;
	}

	/**
	 * Fired once the listener stops queue processing
	 *
	 * @queueContext A struct of data attached to this processing queue thread
	 */
	function onLogListenerEnd( required struct queueContext ){
	}

	/************************************************ PRIVATE ************************************************/

	/**
	 * Return the table name with the schema included if found.
	 */
	private function getTable(){
		if( len( getProperty( 'schema' ) ) ){
			return getProperty( 'schema' ) & "." & getProperty( 'table' );
		}
		return getProperty( 'table' );
	}

	/**
	 * Verify or create the logging table
	 */
	private function ensureTable(){
		var dsn 			= getProperty( "dsn" );
		var qTables 		= 0;
		var tableFound 		= false;
		var qCreate 		= "";
		var cols 			= variables.columns;

		if( getProperty( "autoCreate" ) ){
			// Get Tables on this DSN
			cfdbinfo( datasource="#dsn#", name="qTables", type="tables" );

			for( var thisRecord in qTables ){
				if( thisRecord.table_name == getProperty( "table" ) ){
					tableFound = true;
					break;
				}
			}

			if( NOT tableFound ){
				queryExecute(
					"CREATE TABLE #getTable()# (
						#listgetAt( cols, 1 )# VARCHAR(36) NOT NULL,
						#listgetAt( cols, 2 )# VARCHAR(10) NOT NULL,
						#listgetAt( cols, 3 )# VARCHAR(100) NOT NULL,
						#listgetAt( cols, 4 )# #getDateTimeColumnType()# NOT NULL,
						#listgetAt( cols, 5 )# VARCHAR(100) NOT NULL,
						#listgetAt( cols, 6 )# #getTextColumnType()#,
						#listgetAt( cols, 7 )# #getTextColumnType()#,
						PRIMARY KEY (id)
					)",
					{},
					{
						datasource = getProperty( "dsn" )
					}
				);
			}
		}
	}

	/**
	 * Check a column map definition
	 *
	 * @throws DBAppender.InvalidColumnMapException
	 */
	private function checkColumnMap(){
		var map = getProperty( 'columnMap' );

		for( var key in map ){
			if( NOT listFindNoCase( variables.columns, key ) ){
				throw(
					message = "Invalid column map key: #key#",
					detail 	= "The available keys are #variables.columns#",
					type 	= "DBAppender.InvalidColumnMapException"
				);
			}
		}
	}

	/**
	 * Get db specific date time column type
	 */
	private function getDateTimeDBType(){
		var qResults = "";

		cfdbinfo( type="Version", name="qResults", datasource="#getProperty( 'dsn' )#" );

		switch( qResults.database_productName ){
			case "PostgreSQL" : {
				return "cf_sql_timestamp";
			}
			case "MySQL" : {
				return "cf_sql_timestamp";
			}
			case "Microsoft SQL Server" : {
				return "cf_sql_date";
			}
			case "Oracle" :{
				return "cf_sql_timestamp";
			}
			default : {
				return "cf_sql_timestamp";
			}
		}
	}

	/**
	 * Get db specific text column type
	 */
	private function getTextColumnType(){
		var qResults = "";

		cfdbinfo( type="Version", name="qResults", datasource="#getProperty( 'dsn' )#" );

		switch( qResults.database_productName ){
			case "PostgreSQL" : {
				return "TEXT";
			}
			case "MySQL" : {
				return "LONGTEXT";
			}
			case "Microsoft SQL Server" : {
				return "TEXT";
			}
			case "Oracle" :{
				return "LONGTEXT";
			}
			default : {
				return "TEXT";
			}
		}
	}

	/**
	 * Get db specific text column type
	 */
	private function getDateTimeColumnType(){
		var qResults = "";

		cfdbinfo( type="Version", name="qResults", datasource="#getProperty( 'dsn' )#" );

		switch( qResults.database_productName ){
			case "PostgreSQL" : {
				return "TIMESTAMP";
			}
			case "MySQL" : {
				return "DATETIME";
			}
			case "Microsoft SQL Server" : {
				return "DATETIME";
			}
			case "Oracle" :{
				return "DATE";
			}
			default : {
				return "DATETIME";
			}
		}
	}

}