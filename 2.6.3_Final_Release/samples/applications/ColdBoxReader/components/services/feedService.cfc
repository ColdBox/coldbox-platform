<cfcomponent name="feed" extends="baseservice">

	<!--- ******************************************************************************** --->

	<cffunction name="init" access="public" returntype="any" output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="feedDAO" 	required="true" type="any">
		<cfargument name="ModelbasePath" required="true" type="string">
		<cfargument name="feedReader" type="any" required="true" hint=""/>
		<!--- ******************************************************************************** --->
		<cfset instance = structnew()>
		<cfset instance.feedDAO = arguments.feedDAO>
		<cfset instance.modelBasePath = arguments.ModelBasePath>
		<cfset instance.feedReader = arguments.feedreader>
		<cfreturn this />
	</cffunction>

	<!--- ******************************************************************************** --->
	
	<cffunction name="getAllFeeds" access="public" returntype="struct">
		<cfset var results = structNew()>
		<cfset var qry = instance.feedDAO.getAll()>
		<cfset results.qAllFeeds = qry>
		<cfquery name="results.qTopFeeds" dbtype="query" maxrows="8">
			SELECT *
				FROM qry
				ORDER BY Views DESC
		</cfquery>		
		<cfreturn results>
	</cffunction>
	
	<!--- ******************************************************************************** --->
	
	<cffunction name="getAllMyFeeds" access="public" returntype="query">
		<!--- ******************************************************************************** --->
		<cfargument name="userID" 	type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		<cfset qry = instance.feedDAO.getAll(arguments.userID)>
		<cfreturn qry>
	</cffunction>

	<!--- ******************************************************************************** --->
	
	<cffunction name="readFeed" access="public" returntype="struct">
		<!--- ******************************************************************************** --->
		<cfargument name="feedID" type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qFeedInfo = "">
		<cfset var stFeed = "">
		
		<!--- get details on requested feed --->
		<cfset qFeedInfo = instance.feedDAO.getbyID(arguments.feedID)>
		
		<cfset stFeed = retrieveFeed(qFeedInfo.feedURL)>
		
		<cfreturn stFeed>
	</cffunction>

	<!--- ******************************************************************************** --->

	<cffunction name="retrieveFeed" access="public" returntype="struct">
		<!--- ******************************************************************************** --->
		<cfargument name="url" type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var feed = "">

		<cfset feed = instance.feedReader.readFeed(arguments.url)>

		<cfreturn feed>
	</cffunction>

	<!--- ******************************************************************************** --->
	
	<cffunction name="getFeedInfo" access="public" returntype="query">
		<!--- ******************************************************************************** --->
		<cfargument name="feedID" type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		<cfset qry = instance.feedDAO.getFeedInfo(arguments.feedID)>
		<cfreturn qry>
	</cffunction>

	<!--- ******************************************************************************** --->
	
	<cffunction name="verifyFeed" access="public" returntype="boolean">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" 	type="string" required="yes">
		<cfargument name="authorID" type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		<cfset qry = instance.feedDAO.getFeedByUsersURL(arguments.feedURL,arguments.authorID)>
		<cfif qry.recordcount>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<!--- ******************************************************************************** --->

	<cffunction name="saveFeed" access="public" returntype="string">
		<!--- ******************************************************************************** --->
		<cfargument name="feedID" type="string" required="yes">
		<cfargument name="feedName" type="string" required="yes">
		<cfargument name="feedURL" type="string" required="yes">
		<cfargument name="feedAuthor" type="string" required="yes">
		<cfargument name="description" type="string" required="yes">
		<cfargument name="imgURL" type="string" required="yes">
		<cfargument name="siteURL" type="string" required="yes">
		<cfargument name="userID" type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">

		<cfif arguments.feedID eq "">
			<cfset arguments.feedID = CreateUUID()>
			<cfset instance.feedDAO.create(arguments)>
		<cfelse>
			<cfset instance.feedDAO.update(arguments)>
		</cfif>

		<cfreturn arguments.feedID>
	</cffunction>

	<!--- ******************************************************************************** --->

	<cffunction name="searchByTerm" access="public" returntype="query">
		<!--- ******************************************************************************** --->
		<cfargument name="term" type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		<cfset qry = instance.feedDAO.search(arguments.term)>
		<cfreturn qry>
	</cffunction>

	<!--- ******************************************************************************** --->
	
	<cffunction name="searchByTag" access="public" returntype="query">
		<!--- ******************************************************************************** --->
		<cfargument name="tag" type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		<cfset qry = instance.feedDAO.searchByTag(arguments.tag)>
		<cfreturn qry>
	</cffunction>

	<!--- ******************************************************************************** --->

	

<!---------------------------------------- PRIVATE --------------------------------------------------->

</cfcomponent>