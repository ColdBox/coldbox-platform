/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A basic schema interrogator useful for any database introspection.
 * This class is meant to be used as a static helper.
 */
component singleton {

	/**
	 * Verify if a table exists or not
	 *
	 * @targetTable The table to check
	 * @dsn         The datasource name
	 * @username    The username to use
	 * @password    The password to use
	 */
	boolean function hasTable(
		required string table,
		required string dsn,
		string username = "",
		string password = ""
	){
		return arrayLen( getTables( argumentCollection = arguments ) ) > 0;
	}

	/**
	 * Verify if a table has a column or not
	 *
	 * @targetTable  The table to check
	 * @targetcolumn The column to check
	 * @dsn          The datasource name
	 * @username     The username to use
	 * @password     The password to use
	 */
	boolean function hasColumn(
		required targetTable,
		required targetColumn,
		required string dsn,
		username = "",
		password = ""
	){
		// Check for column created
		cfdbinfo(
			name       = "local.qSettingColumns",
			type       = "columns",
			table      = arguments.targetTable,
			datasource = "#arguments.dsn#",
			username   = "#arguments.username#",
			password   = "#arguments.password#"
		);

		if (
			qSettingColumns.filter( ( thisRow ) => {
				// systemOutput( thisRow, true );
				return thisRow.column_name == targetColumn
			} ).recordCount > 0
		) {
			return true;
		}
		return false;
	}

	/**
	 * Get all the tables for a specific datasource
	 *
	 * @dsn      The datasource name
	 * @table    If you want to filter by a specific table
	 * @username The username to use
	 * @password The password to use
	 *
	 * @return An array of table struct data
	 */
	public array function getTables(
		required string dsn,
		string table    = "",
		string username = "",
		string password = ""
	){
		var qResults = "";

		cfdbinfo(
			type       = "tables",
			name       = "qResults",
			datasource = "#arguments.dsn#",
			username   = "#arguments.username#",
			password   = "#arguments.password#"
		);

		// Table filter
		if ( arguments.table != "" ) {
			qResults = qResults.filter( ( row ) => row.table_name == table );
		}

		return qResults.reduce( ( results, row ) => results.append( row ), [] );
	}

	/**
	 * Get's the database version for a specific datasource
	 *
	 * @dsn      The datasource name
	 * @username The username to use
	 * @password The password to use
	 *
	 * @return A struct with the database version, product name, and product version
	 */
	public struct function getDatabaseInfo(
		required string dsn,
		username = "",
		password = ""
	){
		var qResults = "";

		cfdbinfo(
			type       = "Version",
			name       = "qResults",
			datasource = "#arguments.dsn#",
			username   = "#arguments.username#",
			password   = "#arguments.password#"
		);

		return qResults.reduce( ( results, row ) => results.append( row ), {} );
	}



	/**
	 * Get's the column type for a specific datasource for a text column
	 *
	 * @dsn      The datasource name
	 * @username The username to use
	 * @password The password to use
	 */
	public string function getTextColumnType(
		required string dsn,
		username = "",
		password = ""
	){
		var dbInfo = getDatabaseInfo( argumentCollection = arguments );
		switch ( dbInfo.database_productName ) {
			case "PostgreSQL": {
				return "TEXT";
			}
			case "MySQL": {
				return "LONGTEXT";
			}
			case "Microsoft SQL Server": {
				return "TEXT";
			}
			case "Oracle": {
				return "LONGTEXT";
			}
			default: {
				return "TEXT";
			}
		}
	}

	/**
	 * Get's the column type for a specific datasource for a date/time column
	 *
	 * @dsn      The datasource name
	 * @username The username to use
	 * @password The password to use
	 */
	public string function getDateTimeColumnType(
		required string dsn,
		username = "",
		password = ""
	){
		var dbInfo = getDatabaseInfo( argumentCollection = arguments );
		switch ( dbInfo.database_productName ) {
			case "PostgreSQL": {
				return "TIMESTAMP";
			}
			case "MySQL": {
				return "DATETIME";
			}
			case "Microsoft SQL Server": {
				return "DATETIME";
			}
			case "Oracle": {
				return "DATE";
			}
			default: {
				return "DATETIME";
			}
		}
	}

	/**
	 * Get the query param type for a specific datasource for a date/time column
	 *
	 * @dsn      The datasource name
	 * @username The username to use
	 * @password The password to use
	 */
	public string function getQueryParamDateTimeType(
		required string dsn,
		username = "",
		password = ""
	){
		var dbInfo = getDatabaseInfo( argumentCollection = arguments );
		switch ( dbInfo.database_productName ) {
			case "PostgreSQL": {
				return "cf_sql_timestamp";
			}
			case "MySQL": {
				return "cf_sql_timestamp";
			}
			case "Microsoft SQL Server": {
				return "cf_sql_datetime";
			}
			case "Oracle": {
				return "cf_sql_timestamp";
			}
			default: {
				return "cf_sql_timestamp";
			}
		}
	}

}
