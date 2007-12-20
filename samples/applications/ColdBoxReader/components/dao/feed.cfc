<cfcomponent name="feed" extends="basedao">

	<!--- ******************************************************************************** --->

	<cffunction name="init" access="public" returntype="any" output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="dsnBean" required="true" type="coldbox.system.beans.datasourceBean">
		<!--- ******************************************************************************** --->
		<cfset super.init(arguments.dsnBean)>
		<cfset setTablename("coldboxreader_feed")>
		<cfset setIDFieldName("FeedID")>
		<cfset setFieldNameList("*")>
		<cfset setDefaultSortBy("CreatedOn")>
		<cfset setDefaultSort("")>
		<cfreturn this />
	</cffunction>
	
	<!--- ******************************************************************************** --->
	
	<cffunction name="getAll" access="public" returntype="query">
		<!--- ******************************************************************************** --->
		<cfargument name="userID" required="false" type="string" default="0">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		<cfquery name="qry" datasource="#instance.dsn#" username="#instance.username#" password="#instance.password#">
			SELECT FeedID, FeedName, FeedURL, FeedAuthor, Description, ImgURL, SiteURL, f.CreatedOn, f.CreatedBy, u.UserName,Views
				FROM #instance.TableName# f
					INNER JOIN coldboxreader_users u ON f.CreatedBy = u.UserID
					<cfif arguments.userID neq 0>
					 WHERE u.UserID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#">
					</cfif>
				ORDER BY f.CreatedOn DESC
		</cfquery>
		<cfreturn qry>
	</cffunction>

	<!--- ******************************************************************************** --->
	
	<cffunction name="getFeedInfo" access="public" returntype="query">
		<cfargument name="feedID" required="true" type="string">
		<cfset var qry = "">
		<cfquery name="qry" datasource="#instance.dsn#" username="#instance.username#" password="#instance.password#">
			SELECT f.*, u.UserName, u.Email
				FROM #instance.TableName# f, coldboxreader_users u
				WHERE f.#instance.IDFieldName# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.feedID#"> and
				      f.CreatedBy = u.UserID
		</cfquery>
		<cfreturn qry>
	</cffunction>

	<!--- ******************************************************************************** --->
	
	<!--- ******************************************************************************** --->
	
	<cffunction name="getFeedByUsersURL" access="public" returntype="query">
		<cfargument name="feedURL" required="true" type="string">
		<cfargument name="userID"  required="true" type="string">
		<cfset var qry = "">
		<cfquery name="qry" datasource="#instance.dsn#" username="#instance.username#" password="#instance.password#">
			SELECT FeedID
				FROM #instance.tablename#
			   WHERE FeedURL = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.feedURL#"> AND
			   		 CreatedBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#">
		</cfquery>
		<cfreturn qry>
	</cffunction>

	<!--- ******************************************************************************** --->
	
	<cffunction name="updateFeedStat" access="public" returntype="void">
		<!--- ******************************************************************************** --->
		<cfargument name="feedID" 			required="true" type="string">
		<cfargument name="lastRefreshFlag"  required="false" type="boolean" default="false">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		<!--- update stats --->
		<cfquery name="qry" datasource="#instance.dsn#" username="#instance.username#" password="#instance.password#">
			UPDATE #instance.TableName#
				SET Views = Views + 1
				<cfif arguments.lastRefreshFlag>
				,LastRefreshedOn = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
				</cfif>
			  WHERE #instance.IDFieldName# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.feedID#">
		</cfquery>
	</cffunction>
	

	<!--- ******************************************************************************** --->

	<cffunction name="create" access="public" returntype="void">
		<!--- ******************************************************************************** --->
		<cfargument name="argc" type="struct" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		<cfquery name="qry" datasource="#instance.dsn#" username="#instance.username#" password="#instance.password#">
			INSERT INTO #instance.tableName# (FeedID, FeedName, FeedURL, FeedAuthor, Description, ImgURL, SiteURL, CreatedOn, CreatedBy, LastRefreshedOn)
				VALUES (
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.argc.feedID#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.argc.feedName#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.argc.feedURL#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.argc.feedAuthor#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.argc.description#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.argc.imgURL#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.argc.siteURL#">,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.argc.userID#">,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
						)
		</cfquery>
	</cffunction>

	<!--- ******************************************************************************** --->

	<cffunction name="update" access="public" returntype="void">
		<!--- ******************************************************************************** --->
		<cfargument name="argc" type="struct" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		<cfquery name="qry" datasource="#instance.dsn#" username="#instance.username#" password="#instance.password#">
			UPDATE coldboxreader_feed SET
				FeedID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.argc.feedID#">,
				FeedName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.argc.feedName#">,
				FeedURL = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.argc.feedURL#">,
				FeedAuthor = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.argc.feedAuthor#">,
				Description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.argc.description#">,
				ImgURL = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.argc.imgURL#">,
				SiteURL = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.argc.siteURL#">
		</cfquery>
	</cffunction>

	<cffunction name="search" access="public" returntype="query">
		<!--- ******************************************************************************** --->
		<cfargument name="term" type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		<cfquery name="qry" datasource="#instance.dsn#" UserName="#instance.username#" password="#instance.password#">
			SELECT f.FeedID, FeedName, FeedURL, FeedAuthor, Description, ImgURL, SiteURL, f.CreatedOn, f.CreatedBy, u.UserName, Views
				FROM #instance.tableName# f
					INNER JOIN coldboxreader_feed_tags t ON f.FeedID=t.FeedID
					INNER JOIN coldboxreader_users u ON f.CreatedBy = u.UserID
				WHERE tag LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.term#%">
					OR FeedName LIKE  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.term#%">
					OR Description LIKE  <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.term#%">
					OR SiteURL LIKE  <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.term#%">
					OR UserName LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.term#%">
				GROUP BY  f.FeedID, FeedName, FeedURL, FeedAuthor, Description, ImgURL, SiteURL, f.CreatedOn, f.CreatedBy, u.UserName, Views
				ORDER BY f.FeedName DESC
		</cfquery>
		<cfreturn qry>
	</cffunction>

	<!--- ******************************************************************************** --->

	<cffunction name="searchByTag" access="public" returntype="query">
		<!--- ******************************************************************************** --->
		<cfargument name="tag" type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		<cfquery name="qry" datasource="#instance.dsn#" username="#instance.username#" password="#instance.password#">
			SELECT f.FeedID, FeedName, FeedURL, FeedAuthor, Description, ImgURL, SiteURL, f.CreatedOn, f.CreatedBy, u.UserName, Views
				FROM #instance.tableName# f
					INNER JOIN coldboxreader_feed_tags t ON f.FeedID=t.FeedID
					INNER JOIN coldboxreader_users u ON f.CreatedBy = u.UserID
				WHERE tag = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.tag#">
				ORDER BY f.FeedName DESC
		</cfquery>
		<cfreturn qry>
	</cffunction>

	<!--- ******************************************************************************** --->

</cfcomponent>