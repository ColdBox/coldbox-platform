<cfcomponent name="comments">
	
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
	
	<cffunction name="getFeedComments" access="public" returntype="query">
		<!--- ******************************************************************************** --->
		<cfargument name="feedID" type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		<cfquery name="qry" datasource="#instance.dsn#" username="#instance.username#" password="#instance.password#">
			SELECT *
				FROM feed_comments
				WHERE FeedID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.feedID#">
				ORDER BY CreatedOn DESC
		</cfquery>

		<cfreturn qry>
	</cffunction>
	
	<!--- ******************************************************************************** --->
	
</cfcomponent>