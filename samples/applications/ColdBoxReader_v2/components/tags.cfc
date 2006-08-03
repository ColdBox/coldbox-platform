<cfcomponent extends="dataStore">
	<cffunction name="getAllTags" access="public" returntype="query">
		<cfquery name="qry" datasource="#this.datasource#" username="#this.username#" password="#this.password#">
			SELECT Tag, COUNT(*) AS TagCount
				FROM feed_tags
				GROUP BY Tag
				ORDER BY tag
		</cfquery>
		<cfreturn qry>
	</cffunction>


	<cffunction name="getFeedTags" access="public" returntype="query">
		<cfargument name="feedID" type="string" required="yes">
		<cfquery name="qry" datasource="#this.datasource#" username="#this.username#" password="#this.password#">
			SELECT *
				FROM feed_tags
				WHERE feedID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.feedID#">
				ORDER BY tag
		</cfquery>
		<cfreturn qry>
	</cffunction>
	
	
	<cffunction name="addFeedTags" access="public">
		<cfargument name="feedID" type="string" required="yes">
		<cfargument name="tags" type="string" required="yes">
		<cfargument name="userID" type="string" required="yes">

		<cfset arguments.tags = Replace(arguments.tags," ",",","ALL")>
		<cfset aTags = ListToArray(arguments.tags)>
		
		<cfloop from="1" to="#ArrayLen(aTags)#" index="i">
			<cfset newID = CreateUUID()>
			<cfquery name="qry" datasource="#this.datasource#" username="#this.username#" password="#this.password#">
				INSERT INTO feed_tags (feed_tagID, feedID, tag, CreatedBy, CreatedOn)
					VALUES (
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#newID#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.feedID#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#aTags[i]#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#">,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
					)
			</cfquery>		
		</cfloop>
	</cffunction>
	
</cfcomponent>