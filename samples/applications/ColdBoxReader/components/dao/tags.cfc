<cfcomponent name="tags" extends="basedao">
	
	<!--- ******************************************************************************** --->
	
	<cffunction name="init" access="public" returntype="any" output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="dsnBean" required="true" type="coldbox.system.beans.datasourceBean">
		<!--- ******************************************************************************** --->
		<cfset super.init(arguments.dsnBean)>
		<cfset setTablename("coldboxreader_feed_tags")>
		<cfset setIDFieldName("FeedID")>
		<cfset setFieldNameList("Tag, COUNT(*) AS TagCount")>
		<cfset setDefaultSortBy("Tag")>
		<cfset setDefaultSort("DESC")>
		<cfset setGroupFieldList("Tag")>
		<cfreturn this />
	</cffunction>
	
	<!--- ******************************************************************************** --->
	
	<cffunction name="create" access="public" returntype="void">
		<!--- ******************************************************************************** --->
		<cfargument name="argc" type="struct" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">

		<cfquery name="qry" datasource="#instance.dsn#" username="#instance.username#" password="#instance.password#">
			INSERT INTO #instance.tableName# (feed_tagID, feedID, tag, CreatedBy, CreatedOn)
				VALUES (
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.argc.newID#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.argc.feedID#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.argc.TagName#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.argc.userID#">,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
				)
		</cfquery>		
	</cffunction>
	
	<!--- ******************************************************************************** --->

</cfcomponent>