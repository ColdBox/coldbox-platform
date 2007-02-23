<cfcomponent name="baseDAO" output="false">

	<!--- ******************************************************************************** --->

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="any" output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="dsnBean" required="true" type="coldbox.system.beans.datasourceBean">
		<!--- ******************************************************************************** --->
		<cfset variables.instance = structnew()>
		<cfset variables.instance.dsn = arguments.dsnBean.getName()>
		<cfset variables.instance.username = arguments.dsnBean.getUsername()>
		<cfset variables.instance.password = arguments.dsnBean.getPassword()>
		<cfset variables.instance.TableName = "">
		<cfset variables.instance.IDFieldName = "">
		<cfset variables.instance.FieldNameList = "">
		<cfset variables.instance.DefaultSortBy = "">
		<cfset variables.instance.DefaultSort = "ASC">
		<cfset variables.instance.GroupFieldList = "">
		<cfreturn this />
	</cffunction>

	<!--- ******************************************************************************** --->

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="setTableName" access="public" returntype="void" output="false">
		<cfargument name="TableName" type="string" required="true">
		<cfset instance.TableName = arguments.TableName>
	</cffunction>

	<cffunction name="setIDFieldName" access="public" returntype="void" output="false">
		<cfargument name="IDFieldName" type="string" required="true">
		<cfset instance.IDFieldName = arguments.IDFieldName>
	</cffunction>

	<cffunction name="setFieldNameList" access="public" returntype="void" output="false">
		<cfargument name="FieldNameList" type="string" required="true">
		<cfset instance.FieldNameList = arguments.FieldNameList>
	</cffunction>

	<cffunction name="setDefaultSortBy" access="public" returntype="void" output="false">
		<cfargument name="DefaultSortBy" type="string" required="true">
		<cfset instance.DefaultSortBy = arguments.DefaultSortBy>
	</cffunction>

	<cffunction name="setDefaultSort" access="public" returntype="void" output="false">
		<cfargument name="DefaultSort" type="string" required="true">
		<cfset instance.DefaultSort = arguments.DefaultSort>
	</cffunction>

	<cffunction name="setGroupFieldList" access="public" returntype="void" output="false">
		<cfargument name="GroupFieldList" type="string" required="true">
		<cfset instance.GroupFieldList = arguments.GroupFieldList>
	</cffunction>

	<!--- ******************************************************************************** --->

	<cffunction name="getAll" access="public" returntype="query" output="false">
		<cfset var qResults = "">
		<cfquery name="qResults" datasource="#instance.dsn#" username="#instance.username#" password="#instance.password#">
			SELECT #instance.FieldNameList#
				FROM #instance.TableName#
				<cfif len(instance.GroupFieldList)>
				GROUP BY #instance.GroupFieldList#
				</cfif>
				<cfif len(instance.DefaultSortBy)>
				ORDER BY #instance.DefaultSortBy# #instance.DefaultSort#
				</cfif>
		</cfquery>
		<cfreturn qResults>
	</cffunction>

	<!--- ******************************************************************************** --->

	<cffunction name="getbyID" access="public" returntype="query" output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="IDValue"		required="true"  type="string">
		<!--- ******************************************************************************** --->
		<cfset var qResults = "">
		<cfquery name="qResults" datasource="#instance.dsn#" username="#instance.username#" password="#instance.password#">
			SELECT *
				FROM #instance.TableName#
				WHERE #instance.IDFieldName# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.IDValue#">
				<cfif len(instance.DefaultSortBy)>
				ORDER BY #instance.DefaultSortBy# #instance.DefaultSort#
				</cfif>
		</cfquery>
		<cfreturn qResults>
	</cffunction>

	<!--- ******************************************************************************** --->

	<cffunction name="delete" access="public" returntype="query" output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="IDValue"		required="true"  type="string">
		<!--- ******************************************************************************** --->
		<cfset var qResults = "">
		<cfquery name="qResults" datasource="#instance.dsn#" username="#instance.username#" password="#instance.password#">
			DELETE FROM #instance.TableName#
			      WHERE #instance.IDFieldName# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.IDValue#">
		</cfquery>
	</cffunction>

	<!--- ******************************************************************************** --->

<!------------------------------------------- PRIVATE ------------------------------------------->

	<cffunction name="dump" access="private" hint="Facade for cfmx dump" returntype="void">
		<!--- ************************************************************* --->
		<cfargument name="var" required="yes" type="any">
		<!--- ************************************************************* --->
		<cfdump var="#var#">
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="abort" access="private" hint="Facade for cfabort" returntype="void" output="false">
		<cfabort>
	</cffunction>

	<!--- ************************************************************* --->


</cfcomponent>