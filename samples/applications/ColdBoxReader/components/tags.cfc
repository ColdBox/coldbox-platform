<cfcomponent name="tags">
	
	<!--- ******************************************************************************** --->
	
	<cffunction name="init" access="public" returntype="any" output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="dsnBean" required="true" type="any">
		<!--- ******************************************************************************** --->
		<cfset instance = structnew()>
		<cfset instance.dsn = arguments.dsnBean.getName()>
		<cfset instance.username = arguments.dsnBean.getUsername()>
		<cfset instance.password = arguments.dsnBean.getPassword()>
		<cfreturn this />
	</cffunction>
	
	<!--- ******************************************************************************** --->
	
	<cffunction name="getAllTags" access="public" returntype="query">
		<cfset var qry = "">
		<cfquery name="qry" datasource="#instance.dsn#" username="#instance.username#" password="#instance.password#">
			SELECT Tag, COUNT(*) AS TagCount
				FROM feed_tags
				GROUP BY Tag
				ORDER BY tag
		</cfquery>
		<cfreturn qry>
	</cffunction>

	<!--- ******************************************************************************** --->

	<cffunction name="getFeedTags" access="public" returntype="query">
		<!--- ******************************************************************************** --->
		<cfargument name="feedID" type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		<cfquery name="qry" datasource="#instance.dsn#" username="#instance.username#" password="#instance.password#">
			SELECT *
				FROM feed_tags
				WHERE feedID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.feedID#">
				ORDER BY tag
		</cfquery>
		<cfreturn qry>
	</cffunction>
	
	<!--- ******************************************************************************** --->
	
	<cffunction name="addFeedTags" access="public" returntype="void">
		<!--- ******************************************************************************** --->
		<cfargument name="feedID" type="string" required="yes">
		<cfargument name="tags" type="string" required="yes">
		<cfargument name="userID" type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		<cfset var aTags = "">
		<cfset var newID = "">
		<cfset arguments.tags = Replace(arguments.tags," ",",","ALL")>
		<cfset aTags = ListToArray(arguments.tags)>
		
		<cfloop from="1" to="#ArrayLen(aTags)#" index="i">
			<cfset newID = CreateUUID()>
			<cfquery name="qry" datasource="#instance.dsn#" username="#instance.username#" password="#instance.password#">
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
	
	<!--- ******************************************************************************** --->

</cfcomponent>