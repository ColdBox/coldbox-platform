/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * @author Luis Majano
 *
 * I am a cool cool JDBC Store for CacheBox
 * You need to create the table first with the following columns
 *
 * id 					- varchar(100) PK
 * objectKey 			- varchar(255)
 * objectValue			- clob, longtext, etc
 * hits					- integer
 * timeout				- integer
 * lastAccessTimeout 	- integer
 * created				- datetime or timestamp
 * lastAccessed			- datetime or timestamp
 * isExpired			- tinyint or boolean
 * isSimple				- tinyint or boolean
 *
 * We also recommend indexes for: hits, created, lastAccessed, timeout and isExpired columns.
 *
 * Or look in the /coldbox/system/cache/store/sql/*.sql for you sql script for your DB.
 */
component implements="coldbox.system.cache.store.IObjectStore" accessors="true"{

	/**
	 * The cache provider reference
	 */
	property name="cacheProvider" doc_generic="coldbox.system.cache.providers.ICacheProvider";

	/**
	 * The human store name
	 */
	property name="storeID";

	/**
	 * The metadata indexer object
	 */
	property name="indexer" doc_generic="coldbox.system.cache.store.indexers.MetadataIndexer";

	/**
	 * The object serializer and deserializer utility
	 */
	property name="converter" doc_generic="coldbox.system.core.conversion.ObjectMarshaller";

	/**
	 * The datasource to use for the connection
	 */
	property name="dsn";
	/**
	 * The table to use for storage
	 */
	property name="table";
	/**
	 * The username to use for the connection, if any
	 */
	property name="dsnUsername";
	/**
	 * The password to use for the connection, if any
	 */
	property name="dsnPassword";
	/**
	 * Auto create the table or just use it
	 */
	property name="tableAutoCreate" type="boolean" default="true";

	/**
	 * Constructor
	 *
	 * @cacheProvider The associated cache provider as coldbox.system.cache.providers.ICacheProvider
	 * @cacheprovider.doc_generic coldbox.system.cache.providers.ICacheProvider
	 */
	function init( required cacheProvider ){
		// Store Fields
		var fields = "objectKey,hits,timeout,lastAccessTimeout,created,lastAccessed,isExpired,isSimple";
		var config = arguments.cacheProvider.getConfiguration();

		// Prepare instance
		variables.cacheProvider   	= arguments.cacheProvider;
		variables.storeID 			= createObject( 'java', 'java.lang.System' ).identityHashCode( this );
		variables.converter 		= new coldbox.system.core.conversion.ObjectMarshaller();
		variables.indexer 			= new coldbox.system.cache.store.indexers.JDBCMetadataIndexer( fields, config, this );

		// Get Extra config data
		variables.dsn 	= config.dsn;
		variables.table	= config.table;

		// Check credentials
		if( isNull( config.dsnUsername ) ){
			config.dsnUsername = "";
		}
		if( isNull( config.dsnPassword ) ){
			config.dsnPassword = "";
		}
		variables.dsnUsername = config.dsnUsername;
		variables.dsnPassword = config.dsnPassword;

		// Check autoCreate
		if( isNull( config.tableAutoCreate ) ){
			config.tableAutoCreate = true;
		}
		variables.tableAutoCreate = config.tableAutoCreate;

		// ensure the table
		if( variables.tableAutoCreate ){
			ensureTable();
		}

		variables.isLucee = server.keyExists( "lucee" );

		return this;
	}

	/**
     * Flush the store to a permanent storage
     */
    void function flush(){
        return;
    }

	/**
	 * Reap the storage
	 */
	void function reap(){
		return;
	}

	/**
     * Get the store's pool metadata indexer structure
	 *
	 * @return coldbox.system.cache.store.indexers.MetadataIndexer
     */
    function getIndexer(){
        return variables.indexer;
	}

	/**
	 * Clear all the elements in the store
	 */
	void function clearAll(){
		queryExecute(
			"TRUNCATE TABLE #variables.table#",
			{},
			{
				datsource 	= variables.dsn,
				username 	= variables.dsnUsername,
				password 	= variables.dsnPassword
			}
		);
	}

	/**
     * Get all the store's object keys array
	 *
	 * @return array
     */
    function getKeys(){
		var qResults = queryExecute(
			"SELECT objectKey FROM #variables.table# ORDER BY objectKey ASC",
			{},
			{
				datsource 	= variables.dsn,
				username 	= variables.dsnUsername,
				password 	= variables.dsnPassword
			}
		);

		return (
			variables.isLucee ?
			queryColumnData( qResults, "objectKey" ) :
			listToArray( valueList( qResults.objectKey ) )
		);
	}

	/**
	 * Check if an object is in the store
	 *
	 * @objectKey The key to lookup
	 *
	 * @return boolean
	 */
	function lookup( required objectKey ){
		var q = lookupQuery( arguments.objectKey );
		return ( q.recordCount AND NOT q.isExpired ? true : false );
	}

	/**
	 * Get an object from the store with metadata tracking, or null if not found
	 *
	 * @objectKey The key to retrieve
	 */
	function get( required objectKey ){
		var normalizedID = getNormalizedID( arguments.objectKey );

		transaction{
			// select entry
			var q = queryExecute(
				"SELECT *
				 FROM #variables.table#
				 WHERE id = ?
				",
				[ normalizedID ],
				{
					datsource 	= variables.dsn,
					username 	= variables.dsnUsername,
					password 	= variables.dsnPassword
				}
			);

			// Update stats if found
			if( q.recordCount ){
				// Setup SQL
				var targetSql = "UPDATE #variables.table#
									SET lastAccessed = :lastAccessed,
										hits  = hits + 1
								  WHERE id = :id";

				// Is resetTimeoutOnAccess enabled? If so, jump up the creation time to increase the timeout
				if( variables.cacheProvider.getConfiguration().resetTimeoutOnAccess ){
					var targetSql = "UPDATE #variables.table#
										SET lastAccessed = :lastAccessed,
											hits  = hits + 1,
											created = :created
									  WHERE id = :id";
				}

				var qStats = queryExecute(
					"#targetSQL#",
					{
						lastAccessed 	: { value="#now()#",		cfsqltype="timestamp" },
						id 				: { value="#normalizedID#", cfsqltype="varchar" },
						created 		: { value="#now()#",		cfsqltype="timestamp" }
					},
					{
						datsource 	= variables.dsn,
						username 	= variables.dsnUsername,
						password 	= variables.dsnPassword
					}
				);
			}
		} // end transaction

		// Just return if records found, else null
		if( q.recordCount ){
			return ( q.isSimple ? q.objectValue : variables.converter.deserializeObject( binaryObject=q.objectValue ) );
		}
	}

	/**
	 * Get an object from cache with no metadata tracking
	 *
	 * @objectKey The key to retrieve
	 */
	function getQuiet( required objectKey ){
		// select entry
		var q = queryExecute(
			"SELECT *
				FROM #variables.table#
				WHERE id = ?
			",
			[ getNormalizedID( arguments.objectKey ) ],
			{
				datsource 	= variables.dsn,
				username 	= variables.dsnUsername,
				password 	= variables.dsnPassword
			}
		);

		// Just return if records found, else null
		if( q.recordCount ){
			return ( q.isSimple ? q.objectValue : variables.converter.deserializeObject( binaryObject=q.objectValue ) );
		}
	}

	/**
	 * Expire an object
	 *
	 * @objectKey The key to expire
	 */
	void function expireObject( required objectKey ){
		// select entry
		var q = queryExecute(
			"UPDATE #variables.table#
				SET isExpired = ?
			  WHERE id = ?
			",
			[ 1, getNormalizedID( arguments.objectKey ) ],
			{
				datsource 	= variables.dsn,
				username 	= variables.dsnUsername,
				password 	= variables.dsnPassword
			}
		);
	}

	/**
	 * Expire check
	 *
	 * @objectKey The key to check
	 *
	 * @return boolean
	 */
	function isExpired( required objectKey ){
		// select entry
		var q = queryExecute(
			"SELECT isExpired
			   FROM #variables.table#
			  WHERE id = ?
			",
			[ getNormalizedID( arguments.objectKey ) ],
			{
				datsource 	= variables.dsn,
				username 	= variables.dsnUsername,
				password 	= variables.dsnPassword
			}
		);

		return ( q.recordCount && q.isExpired ? true : false );
	}

	/**
	 * Sets an object in the storage
	 *
	 * @objectKey The object key
	 * @object The object to save
	 * @timeout Timeout in minutes
	 * @lastAccessTimeout Idle Timeout in minutes
	 * @extras A map of extra name-value pairs to store alongside the object
	 */
	void function set(
		required objectKey,
		required object,
		timeout="0",
		lastAccessTimeout="0",
		extras={}
	){
		var normalizedId 	= getNormalizedID( arguments.objectKey );
		var isSimple		= true;

		// Test if not simple to serialize
		if( !isSimpleValue( arguments.object ) ){
			isSimple = false;
			arguments.object = variables.converter.serializeObject( arguments.object );
		}

		transaction{
			if( !lookupQuery( arguments.objectKey ).recordCount ){
				var q = queryExecute(
					"INSERT INTO #variables.table# (id,objectKey,objectValue,hits,timeout,lastAccessTimeout,created,lastAccessed,isExpired,isSimple)
					VALUES (
						:id,
						:objectKey,
						:objectValue,
						:hits,
						:timeout,
						:lastAccessTimeout,
						:now,
						:now,
						:isExpired,
						:isSimple
					)
					",
					{
						id                	= { value="#normalizedId#",                	cfsqltype="varchar" },
						objectKey         	= { value="#arguments.objectKey#",         	cfsqltype="varchar" },
						objectValue       	= { value="#arguments.object#",            	cfsqltype="longvarchar" },
						hits           		= { value="1",           					cfsqltype="integer" },
						timeout           	= { value="#arguments.timeout#",           	cfsqltype="integer" },
						lastAccessTimeout 	= { value="#arguments.lastAccessTimeout#", 	cfsqltype="integer" },
						now               	= { value=now(),                           	cfsqltype="timestamp" },
						now               	= { value=now(),                           	cfsqltype="timestamp" },
						isExpired         	= { value="0",                    			cfsqltype="bit" },
						isSimple          	= { value="#isSimple#",                    	cfsqltype="bit" }
					},
					{
						datsource 	= variables.dsn,
						username 	= variables.dsnUsername,
						password 	= variables.dsnPassword
					}
				);

				return;
			}

			var q = queryExecute(
				"UPDATE #variables.table#
					SET objectKey 			= :objectKey,
						objectValue			= :objectValue,
						hits				= :hits,
						timeout				= :timeout,
						lastAccessTimeout	= :lastAccessTimeout,
						created				= :now,
						lastAccessed		= :now,
						isExpired			= :isExpired,
						isSimple			= :isSimple
					WHERE id = :id
				",
				{
					id                	= { value="#normalizedId#",                	cfsqltype="varchar" },
					objectKey         	= { value="#arguments.objectKey#",         	cfsqltype="varchar" },
					objectValue       	= { value="#arguments.object#",            	cfsqltype="longvarchar" },
					hits           		= { value="1",           					cfsqltype="integer" },
					timeout           	= { value="#arguments.timeout#",           	cfsqltype="integer" },
					lastAccessTimeout 	= { value="#arguments.lastAccessTimeout#", 	cfsqltype="integer" },
					now               	= { value=now(),                           	cfsqltype="timestamp" },
					now               	= { value=now(),                           	cfsqltype="timestamp" },
					isExpired         	= { value="0",                    			cfsqltype="bit" },
					isSimple          	= { value="#isSimple#",                    	cfsqltype="bit" }
				},
				{
					datsource 	= variables.dsn,
					username 	= variables.dsnUsername,
					password 	= variables.dsnPassword
				}
			);
		}
	}

	/**
	 * Clears an object from the storage
	 *
	 * @objectKey The object key to clear
	 */
	function clear( required objectKey ){
		queryExecute(
			"DELETE
			   FROM #variables.table#
			  WHERE id = ?
			",
			[ getNormalizedID( arguments.objectKey ) ],
			{
				datsource 	= variables.dsn,
				username 	= variables.dsnUsername,
				password 	= variables.dsnPassword,
				result 		= "local.q"
			}
		);

		return ( q.recordCount ? true : false );
	}

	/**
	 * Get the size of the store
	 */
	function getSize(){
		var q = queryExecute(
			"SELECT count( id ) as totalCount
			   FROM #variables.table#
			",
			{},
			{
				datsource 	= variables.dsn,
				username 	= variables.dsnUsername,
				password 	= variables.dsnPassword
			}
		);

		return q.totalCount;
	}

	/**
	 * Get the cached normalized id as we store it
	 *
	 * @objectKey The object key
	 */
	function getNormalizedId( required objectKey ){
		return hash( arguments.objectKey );
	}

	//********************************* PRIVATE ************************************//

	/**
	 * Get the id and isExpired from the object
	 *
	 * @objectKey The key of the object
	 */
	private query function lookupQuery( required objectKey ){
		return queryExecute(
			"SELECT id, isExpired
			 FROM #variables.table#
			 WHERE id = ?
			",
			[ getNormalizedID( arguments.objectKey ) ],
			{
				datsource 	= variables.dsn,
				username 	= variables.dsnUsername,
				password 	= variables.dsnPassword
			}
		);
	}

	/**
	 * Create the caching table if necessary
	 */
	private function ensureTable(){
		var qCreate 	= "";
		var tableFound 	= false;
		var create		= {
			afterCreate = "",
			afterLastProperty = ""
		};

		cfdbinfo( datasource="#variables.dsn#", name="local.qDBInfo", type="version" );

		// Get Tables on this DSN
		cfdbinfo( datasource="#variables.dsn#", name="local.qTables", type="tables" );

		// Choose Text Type
		switch( qDBInfo.database_productName ){
			case "PostgreSQL" : {
				create.valueType	= "text";
				create.timeType 	= "timestamp";
				create.intType 		= "integer";
				create.booleanType	= "boolean";
				break;
			}
			case "MySQL" : {
				create.valueType   			= "longtext";
				create.afterCreate 			= "ENGINE=InnoDB DEFAULT CHARSET=utf8";
				create.timeType 			= "datetime";
				create.intType 	 			= "int";
				create.booleanType 			= "tinyint";
				create.afterLastProperty 	= "INDEX `hits` (`hits`),INDEX `created` (`created`),INDEX `lastAccessed` (`lastAccessed`),INDEX `timeout` (`timeout`),INDEX `isExpired` (`isExpired`)";
				break;
			}
			case "Microsoft SQL Server" : {
				create.valueType 	= "ntext";
				create.timeType  	= "datetime";
				create.intType 		= "int";
				create.booleanType 	= "tinyint";
				break;
			}
			case "Oracle" : {
				create.valueType 	= "clob";
				create.timeType 	= "timestamp";
				create.intType 		= "int";
				create.booleanType 	= "boolean";
				break;
			}
			default : {
				create.valueType 	= "text";
				create.timeType 	= "timestamp";
				create.intType 		= "integer";
				create.booleanType 	= "tinyint";
				break;
			}
		}

		if(
			listToArray( valueList( qTables.table_name ) )
				.findNoCase( variables.table ) == 0
		){
			queryExecute(
				"CREATE TABLE #variables.table# (
					id VARCHAR(100) NOT NULL,
					objectKey VARCHAR(255) NOT NULL,
					objectValue #create.valueType# NOT NULL,
					hits #create.intType# NOT NULL DEFAULT '1',
					timeout #create.intType# NOT NULL,
					lastAccessTimeout integer NOT NULL,
					created #create.timeType# NOT NULL,
					lastAccessed #create.timeType# NOT NULL,
					isExpired #create.booleanType# NOT NULL DEFAULT '1',
					isSimple #create.booleanType# NOT NULL DEFAULT '0',
					PRIMARY KEY (id)
				) #create.afterCreate#
				",
				{},
				{
					datsource 	= variables.dsn,
					username 	= variables.dsnUsername,
					password 	= variables.dsnPassword
				}
			);
		}
	}

}