<cfcomponent name="mssql">
	
	<cffunction name="init" access="public" output="false" returntype="mysql">
		<cfset variables.dsn = "" />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getTables" access="public" output="false" returntype="query">
		<cfset var qAllTables = "" />
		
		<cfif not len(variables.dsn)>
			<cfthrow errorcode="you must provide a dsn" />
		</cfif>
		<cfquery name="qAllTables" datasource="#variables.dsn#">
			SELECT database() as DATABASE_NAME, TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE
			FROM information_schema.TABLES
			WHERE TABLE_SCHEMA = database()
		</cfquery>
		<cfreturn qAllTables />
	</cffunction>
	
	<cffunction name="setDSN" access="public" output="false" returntype="void">
		<cfargument name="dsn" type="string" required="true" />
		<cfset variables.dsn = arguments.dsn />
	</cffunction>
	<cffunction name="setComponentPath" access="public" output="false" returntype="void">
		<cfargument name="componentPath" type="string" required="true" />
		<cfset variables.componentPath = arguments.componentPath />
	</cffunction>
	<cffunction name="setTable" access="public" output="false" returntype="void">
		<cfargument name="table" type="string" required="true" />
		
		<cfset variables.table = arguments.table />
		<cfset setTableMetadata() />
		<cfset setPrimaryKeyList() />
	</cffunction>
	
	<!--- these functions are modified from reactor v0.1 --->
	<cffunction name="translateCfSqlType" hint="I translate the MSSQL data type names into ColdFusion cf_sql_xyz names" output="false" returntype="string">
		<cfargument name="typeName" hint="I am the type name to translate" required="yes" type="string" />
		
		<cfswitch expression="#arguments.typeName#">
			<cfcase value="bigint">
				<cfreturn "cf_sql_bigint" />
			</cfcase>
			<cfcase value="binary">
				<cfreturn "cf_sql_binary" />
			</cfcase>
			<cfcase value="bit">
				<cfreturn "cf_sql_bit" />
			</cfcase>
			<cfcase value="char">
				<cfreturn "cf_sql_char" />
			</cfcase>
			<cfcase value="datetime">
				<cfreturn "cf_sql_date" />
			</cfcase>
			<cfcase value="decimal">
				<cfreturn "cf_sql_decimal" />
			</cfcase>
			<cfcase value="float">
				<cfreturn "cf_sql_float" />
			</cfcase>
			<cfcase value="image">
				<cfreturn "cf_sql_longvarbinary" />
			</cfcase>
			<cfcase value="int">
				<cfreturn "cf_sql_integer" />
			</cfcase>
			<cfcase value="money">
				<cfreturn "cf_sql_money" />
			</cfcase>
			<cfcase value="nchar">
				<cfreturn "cf_sql_char" />
			</cfcase>
			<cfcase value="ntext">
				<cfreturn "cf_sql_longvarchar" />
			</cfcase>
			<cfcase value="numeric">
				<cfreturn "cf_sql_varchar" />
			</cfcase>
			<cfcase value="nvarchar">
				<cfreturn "cf_sql_varchar" />
			</cfcase>
			<cfcase value="real">
				<cfreturn "cf_sql_real" />
			</cfcase>
			<cfcase value="smalldatetime">
				<cfreturn "cf_sql_date" />
			</cfcase>
			<cfcase value="smallint">
				<cfreturn "cf_sql_smallint" />
			</cfcase>
			<cfcase value="smallmoney">
				<cfreturn "cf_sql_decimal" />
			</cfcase>
			<cfcase value="text">
				<cfreturn "cf_sql_longvarchar" />
			</cfcase>
			<cfcase value="timestamp">
				<cfreturn "cf_sql_timestamp" />
			</cfcase>
			<cfcase value="tinyint">
				<cfreturn "cf_sql_tinyint" />
			</cfcase>
			<cfcase value="uniqueidentifier">
				<cfreturn "cf_sql_idstamp" />
			</cfcase>
			<cfcase value="varbinary">
				<cfreturn "cf_sql_varbinary" />
			</cfcase>
			<cfcase value="varchar">
				<cfreturn "cf_sql_varchar" />
			</cfcase>
		</cfswitch>
	</cffunction>
	
	<cffunction name="translateDataType" hint="I translate the MSSQL data type names into ColdFusion data type names" output="false" returntype="string">
		<cfargument name="typeName" hint="I am the type name to translate" required="yes" type="string" />
		
		<cfswitch expression="#arguments.typeName#">
			<cfcase value="bigint">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="binary">
				<cfreturn "binary" />
			</cfcase>
			<cfcase value="bit">
				<cfreturn "boolean" />
			</cfcase>
			<cfcase value="char">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="datetime">
				<cfreturn "date" />
			</cfcase>
			<cfcase value="decimal">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="float">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="image">
				<cfreturn "binary" />
			</cfcase>
			<cfcase value="int">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="money">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="nchar">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="ntext">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="numeric">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="nvarchar">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="real">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="smalldatetime">
				<cfreturn "date" />
			</cfcase>
			<cfcase value="smallint">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="smallmoney">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="text">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="timestamp">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="tinyint">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="uniqueidentifier">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="varbinary">
				<cfreturn "binary" />
			</cfcase>
			<cfcase value="varchar">
				<cfreturn "string" />
			</cfcase>
		</cfswitch>
	</cffunction>
	
	<cffunction name="setTableMetadata" access="public" output="false" returntype="void">
		<cfset var qTable = "" />
		<!--- get table column info, borrowed from Reactor --->
		<cfquery name="qTable" datasource="#variables.dsn#">
			SELECT COLUMN_NAME,
			CASE
				WHEN IS_NULLABLE = 'Yes' THEN 'true'
				ELSE 'false'
			END as nullable,
			DATA_TYPE as type_name,
			CASE
				WHEN CHARACTER_MAXIMUM_LENGTH IS NULL THEN 0
				ELSE CHARACTER_MAXIMUM_LENGTH
			END as length,
			CASE
				WHEN EXTRA = 'auto_increment' THEN 'true'
				ELSE 'false'
			END as identity
			FROM information_schema.COLUMNS
			WHERE TABLE_SCHEMA = Database() AND TABLE_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" scale="128" value="#variables.table#" />
		</cfquery>
		<cfset variables.tableMetadata = qTable />
	</cffunction>
	<cffunction name="getTableMetaData" access="public" output="false" returntype="query">
		<cfreturn variables.tableMetadata />
	</cffunction>
	
	<cffunction name="setPrimaryKeyList" access="public" output="false" returntype="void">
		<cfset var qPrimaryKeys = "" />
		<cfset var lstPrimaryKeys = "" />
		<cfquery name="qPrimaryKeys" datasource="#variables.dsn#">
			SELECT COLUMN_NAME
			FROM information_schema.COLUMNS
			WHERE TABLE_SCHEMA = Database()
			AND TABLE_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" scale="128" value="#variables.table#" />
			AND	COLUMN_KEY = <cfqueryparam cfsqltype="cf_sql_varchar" value="PRI" />
		</cfquery>
		<cfset lstPrimaryKeys = valueList(qPrimaryKeys.column_name) />
		<cfset variables.primaryKeyList = lstPrimaryKeys />
	</cffunction>
	<cffunction name="getPrimaryKeyList" access="public" output="false" returntype="string">
		<cfreturn variables.primaryKeyList />
	</cffunction>

	<cffunction name="getTableXML" access="public" output="false" returntype="xml">
		<cfset var xmlTable = "" />
		<!--- convert the table data into an xml format --->
		<cfxml variable="xmlTable">
		<cfoutput>
		<root>
			<bean name="#listLast(variables.componentPath,'.')#" path="#variables.componentPath#">
				<dbtable name="#variables.table#">
				<cfloop query="variables.tableMetadata">
					<column name="#variables.tableMetadata.column_name#"
							type="<cfif variables.tableMetadata.type_name EQ 'char' AND variables.tableMetadata.length EQ 35 AND listFind(variables.primaryKeyList,variables.tableMetadata.column_name)>uuid<cfelse>#translateDataType(variables.tableMetadata.type_name)#</cfif>"
							cfSqlType="#translateCfSqlType(variables.tableMetadata.type_name)#"
							required="#yesNoFormat(variables.tableMetadata.nullable-1)#"
							length="#variables.tableMetadata.length#"
							primaryKey="#yesNoFormat(listFind(variables.primaryKeyList,variables.tableMetadata.column_name))#"
							identity="#variables.tableMetadata.identity#" />
				</cfloop>
				</dbtable>
			</bean>
		</root>
		</cfoutput>
		</cfxml>
		<cfreturn xmlTable />
	</cffunction>
</cfcomponent>