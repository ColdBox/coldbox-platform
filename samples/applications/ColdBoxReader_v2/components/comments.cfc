<cfcomponent extends="dataStore">
	<cffunction name="getFeedComments" access="public" returntype="query">
		<cfargument name="feedID" type="string" required="yes">

		<cfquery name="qry" datasource="#this.datasource#" username="#this.username#" password="#this.password#">
			SELECT *
				FROM feed_comments
				WHERE FeedID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.feedID#">
				ORDER BY CreatedOn DESC
		</cfquery>

		<cfreturn qry>
	</cffunction>
</cfcomponent>