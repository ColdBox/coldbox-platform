<cfcomponent name="Oracle">
	
	<cffunction name="init" access="public" output="false" returntype="Oracle">
		<cfset variables.dsn = "" />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getTables" access="public" output="false" returntype="query">
		<cfset var qAllTables = "" />
		
		<cfif not len(variables.dsn)>
			<cfthrow message="you must provide a dsn" />
		</cfif>
		<cfquery name="qAllTables" datasource="#form.dsn#">
			SELECT owner
        ,  TABLE_NAME
        , 'TABLE'   TABLE_TYPE
			FROM all_tables
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
	
	<!--- these functions are modified from reactor --->
	<cffunction name="translateCfSqlType" hint="I translate the Oracle data type names into ColdFusion cf_sql_xyz names" output="false" returntype="string">
		<cfargument name="typeName" hint="I am the type name to translate" required="yes" type="string" />
		<cfswitch expression="#lcase(arguments.typeName)#">
        <!--- misc --->
			<cfcase value="rowid">
				<cfreturn "cf_sql_varchar" />
			</cfcase>
			<!--- time --->
			<cfcase value="date">
				<cfreturn "cf_sql_timestamp" />
			</cfcase>
			<cfcase value="timestamp(6)">
				<cfreturn "cf_sql_date" />
			</cfcase>
         <!--- strings --->
			<cfcase value="char">
				<cfreturn "cf_sql_char" />
			</cfcase>
			<cfcase value="nchar">
				<cfreturn "cf_sql_char" />
			</cfcase>
			<cfcase value="varchar">
				<cfreturn "cf_sql_varchar" />
			</cfcase>
			<cfcase value="varchar2">
				<cfreturn "cf_sql_varchar" />
			</cfcase>
			<cfcase value="nvarchar2">
				<cfreturn "cf_sql_varchar" />
			</cfcase>
			<!--- long types --->
			<!---   @@Note: bfile  not supported --->
			<cfcase value="blob">
				<cfreturn "cf_sql_blob" />
			</cfcase>
			<cfcase value="clob">
				<cfreturn "cf_sql_clob" />
			</cfcase>
			<cfcase value="nclob">
				<cfreturn "cf_sql_clob" />
			</cfcase>
			<cfcase value="long">
				<cfreturn "cf_sql_longvarchar" />
			</cfcase>
			   <!--- @@Note: may need "tobinary(ToBase64(x))" when updating --->
			<cfcase value="long raw">
				<cfreturn "cf_sql_longvarbinary" />
			</cfcase>
			<cfcase value="raw">
			   <!--- @@Note: may need "tobinary(ToBase64(x))" when updating --->
				<cfreturn "cf_sql_varbinary" />
			</cfcase>
			<!--- numerics --->
			<cfcase value="float">
				<cfreturn "cf_sql_float" />
			</cfcase>
			<cfcase value="integer">
				<cfreturn "cf_sql_numeric" />
			</cfcase>
			<cfcase value="number">
				<cfreturn "cf_sql_numeric" />
			</cfcase>
			<cfcase value="real">
				<cfreturn "cf_sql_numeric" />
			</cfcase>
		</cfswitch>
		<cfthrow message="Unsupported (or incorrectly supported) database datatype: #arguments.typeName#." />
	</cffunction>
	
	<cffunction name="translateDataType" hint="I translate the Oracle data type names into ColdFusion data type names" output="false" returntype="string">
		<cfargument name="typeName" hint="I am the type name to translate" required="yes" type="string" />
		<cfswitch expression="#arguments.typeName#">
        <!--- misc --->
			<cfcase value="rowid">
				<cfreturn "string" />
			</cfcase>
			<!--- time --->
			<cfcase value="date">
				<cfreturn "date" />
			</cfcase>
			<cfcase value="timestamp(6)">
				<cfreturn "date" />
			</cfcase>
            <!--- strings --->
			<cfcase value="char">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="nchar">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="varchar">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="varchar2">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="nvarchar2">
				<cfreturn "string" />
			</cfcase>
			<!--- long --->
			<!---   @@Note: bfile  not supported --->
			<cfcase value="blob">
				<cfreturn "binary" />
			</cfcase>
			<cfcase value="clob">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="nclob">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="long">
				<cfreturn "string" />
			</cfcase>
		   <cfcase value="long raw">
				<cfreturn "binary" />
			</cfcase>
			<cfcase value="raw">
				<cfreturn "binary" />
			</cfcase>
			<!--- numerics --->
			<cfcase value="float">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="integer">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="number">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="real">
				<cfreturn "numeric" />
			</cfcase>
		</cfswitch>

		<cfthrow message="Unsupported (or incorrectly supported) database datatype: #arguments.typeName#." />

	</cffunction>
	
	<cffunction name="setTableMetadata" access="public" output="false" returntype="void">
		<cfset var qTable = "" />
		<!--- get table column info --->
		<!--- This is a modified version of the query in sp_columns --->
		<cfquery name="qTable" datasource="#variables.dsn#">
			 SELECT
             	    col.COLUMN_NAME       as COLUMN_NAME,
                  /* Oracle has no equivalent to autoincrement or  identity */
                  'false'                     AS "IDENTITY",                    
                  CASE
                        WHEN col.NULLABLE = 'Y' THEN 1
                        ELSE 0
                  END                  as NULLABLE,
                 col.DATA_TYPE         as TYPE_NAME,
                  case
                    /* 26 is the length of now() in ColdFusion (i.e. {ts '2006-06-26 13:10:14'})*/
                    when col.data_type = 'DATE'   then 26
                    else col.data_length
                  end                 as length,
                  col.DATA_DEFAULT      as "DEFAULT"
            FROM  all_tab_columns   col,
                  ( select  colCon.column_name,
                 			  colcon.table_name
                  from    all_cons_columns  colCon,
                         all_constraints   tabCon
                  where tabCon.table_name = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="128" value="#variables.table#" />
                       AND colCon.CONSTRAINT_NAME = tabCon.CONSTRAINT_NAME
                       AND colCon.TABLE_NAME      = tabCon.TABLE_NAME
                       AND 'P'                    = tabCon.CONSTRAINT_TYPE
                 ) primaryConstraints
            where col.table_name = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="128" value="#variables.table#" />
            		and col.COLUMN_NAME        = primaryConstraints.COLUMN_NAME (+)
                  AND col.TABLE_NAME       = primaryConstraints.TABLE_NAME (+)
        order by col.column_id
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
      select    colCon.column_name,
           		  colcon.CONSTRAINT_NAME  AS PK_NAME
        from    user_cons_columns  colCon,
                user_constraints   tabCon
        where tabCon.table_name = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="128" value="#variables.table#" />
        AND colCon.CONSTRAINT_NAME = tabCon.CONSTRAINT_NAME
        AND colCon.TABLE_NAME      = tabCon.TABLE_NAME
        AND 'P'                    = tabCon.CONSTRAINT_TYPE
        order by colcon.POSITION
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
		<!--- added listfirst to the sql_type because identity is sometimes appended --->
		<cfxml variable="xmlTable">
		<cfoutput>
		<root>
			<bean name="#listLast(variables.componentPath,'.')#" path="#variables.componentPath#">
				<dbtable name="#variables.table#">
				<cfloop query="variables.tableMetadata">
					<column name="#variables.tableMetadata.column_name#"
							type="<cfif variables.tableMetadata.type_name EQ 'varchar2' AND variables.tableMetadata.length EQ 35 AND listFind(variables.primaryKeyList,variables.tableMetadata.column_name)>uuid<cfelse>#translateDataType(listFirst(variables.tableMetadata.type_name," "))#</cfif>"
							cfSqlType="#translateCfSqlType(listFirst(variables.tableMetadata.type_name," "))#"
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