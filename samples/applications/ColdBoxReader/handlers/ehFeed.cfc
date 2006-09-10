<cfcomponent name="ehUser" extends="coldbox.system.eventhandler">

	<cffunction name="init" access="public" returntype="ehFeed" output="false">
		<cfset super.init()>
		<cfreturn this>
	</cffunction>

	<cffunction name="dspAddFeed" access="public" returntype="void" output="false">
		<cfset var csPlugin = getPlugin("clientstorage")>
		<cfset var obj = "">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehAddFeed = "ehFeed.doAddFeed">
		<cfset rc.xehNewFeed = "ehFeed.dspAddFeed">

		<!--- Feed Validated? --->
		<cfset rc.feedValidated = false>

		<!--- Try to parse feed --->
		<cfif getValue("continue_button","") neq "">
			<!--- Validate Feed --->
			<cfif trim(len(rc.FeedURL)) eq 0 or not getPlugin("fileUtilities").isURL("#rc.FeedURL#")>
				<cfset getPlugin("messagebox").setMessage("error","Please enter a valid Feed URL")>
			<cfelse>
				<cftry>
					<cfset obj = application.cbService.getdao("feed")>
					<!--- Verify Feed in user's feeds --->
					<cfif obj.verifyFeed(rc.feedURL, session.userID)>
						<cfset getPlugin("messagebox").setMessage("warning","The feed you are trying to add is already in your feeds collection. You cannot add it twice.")>
					<cfelse>
						<cfset rc.myFeed = obj.retrieveFeed(rc.feedURL)>
						<cfset rc.feedValidated = true>
					</cfif>
					<cfcatch type="any">
						<cfset getPlugin("logger").logError("Error Parsing Feed", e)>
						<cfset getPlugin("messagebox").setMessage("error", cfcatch.message & "<br>" & cfcatch.detail)>
					</cfcatch>
				</cftry>
			</cfif>
		</cfif>
		<!--- Set view --->
		<cfset setView("vwAddFeed")>
	</cffunction>

	<cffunction name="dspViewFeed" access="public" returntype="void" output="false">
		<cfset var obj = application.cbService.getdao("feed")>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehFeeds = "ehGeneral.dspReader">
		<cfset rc.xehMyFeeds = "ehFeed.dspMyFeeds">
		<cfset rc.xehReload = "ehFeed.dspViewFeed">
		<cfset rc.xehFeedInfo = "ehFeed.dspFeedInfo">
		<cfset rc.xehFeedTags = "ehFeed.dspFeedTags">
		<cfset rc.xehFeedComments = "ehFeed.dspFeedComments">

		<cfset rc.feed = obj.readFeed(rc.feedID,"#GetSetting("ApplicationPath",1)#")>

		<cfset setView("vwViewFeed")>
	</cffunction>

	<cffunction name="dspFeedInfo" access="public" returntype="void" output="false">
		<cfset var obj = application.cbService.getdao("feed")>
		<cfset rc.qryData = obj.getFeedInfo(rc.feedID)>
		<cfset setView("vwFeedInfo")>
	</cffunction>

	<cffunction name="dspFeedTags" access="public" returntype="void" output="false">
		<cfset var obj = application.cbService.getdao("tags")>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehSearchByTag = "ehFeed.doSearchByTag">
		<cfset rc.xehAddTag = "ehFeed.doAddTags">
		<cfset rc.qryData = obj.getFeedTags(rc.feedID)>
		<cfif session.userID neq "">
			<cfif rc.qryData.recordCount gt 0>
				<cfquery name="rc.qryMyTags" dbtype="query">
					SELECT *
						FROM rc.qryData
						WHERE CreatedBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.userid#">
				</cfquery>
			<cfelse>
				<cfset rc.qryMyTags = QueryNew("")>
			</cfif>
		</cfif>
		<cfset setView("vwFeedTags")>
	</cffunction>

	<cffunction name="dspFeedComments" access="public" returntype="void" output="false">
		<cfset var obj = application.cbService.getdao("comments")>
		<cfset rc.qryData = obj.getFeedComments(rc.feedID)>
		<cfset setView("vwFeedComments")>
	</cffunction>

	<cffunction name="dspAllTags" access="public" returntype="void" output="false">
		<cfset var obj = application.cbService.getdao("tags")>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehSearchTag = "ehFeed.doSearchByTag">
		<cfset rc.qryData = obj.getAllTags()>
		<cfset setView("vwAllTags")>
	</cffunction>

	<cffunction name="doAddFeed" access="public" returntype="void" output="false">
		<cfset var obj = "">
		<cftry>
			<cfset obj = application.cbService.getdao("feed")>
			<cfset obj.saveFeed(rc.feedID, rc.feedName, rc.feedURL, rc.FeedAuthor, rc.description, rc.imgURL, rc.siteURL, session.userID)>
			<cfset getPlugin("messagebox").setMessage("info", "The feed: #rc.feedName# has been added successfully")>
			<cfcatch type="any">
				<cfset getPlugin("messagebox").setMessage("error", cfcatch.message & "<br>" & cfcatch.detail)>
				<cfset getPlugin("logger").logError("Error Adding Feed", e)>
				<cfset setNextEvent("ehFeed.dspAddFeed")>
			</cfcatch>
		</cftry>
		<cfset setNextEvent("ehGeneral.dspReader")>
	</cffunction>

	<cffunction name="doAddTags" access="public" returntype="void" output="false">
		<cfset var obj = "">
		<cftry>

			<cfif rc.tags neq "">
				<cfset obj = application.cbService.getdao("tags")>
				<cfset obj.addFeedTags(rc.feedID, rc.tags, session.userID)>
			</cfif>

			<cfcatch type="any">
				<cfset getPlugin("logger").logError("Error Adding Tag", e)>
				<cfset getPlugin("messagebox").setMessage("error", cfcatch.message & "<br>" & cfcatch.detail)>
			</cfcatch>
		</cftry>
		<cfset setNextEvent("ehFeed.dspFeedTags","feedID=#rc.feedID#")>
	</cffunction>

	<cffunction name="doSearchByTag" access="public" returntype="void" output="false">
		<cfset var obj = "">
		<cfset var qryData = "">
		<cftry>
			<cfset obj = application.cbService.getdao("feed")>
			<cfset qryData = obj.searchByTag(rc.tag)>
			<cfset getPlugin("clientStorage").setVar("search_results", qryData)>
			<cfset getPlugin("clientStorage").setVar("search_tag", rc.tag)>
			<cfset getPlugin("clientStorage").setVar("search_term", "")>

			<cfcatch type="any">
				<cfset getPlugin("logger").logError("Error Searching by Tags", e)>
				<cfset getPlugin("messagebox").setMessage("error", cfcatch.message & "<br>" & cfcatch.detail)>
				<cfset setNextEvent()>
			</cfcatch>
		</cftry>
		<cfset setNextEvent("ehFeed.dspSearchResults")>
	</cffunction>

	<cffunction name="doSearchByTerm" access="public" returntype="void" output="false">
		<cfset var obj = "">
		<cfset var plClient = getPlugin("clientStorage")>
		<cftry>
			<cfset term = getValue("searchTerm")>
			<cfset obj = application.cbService.getdao("feed")>
			<cfset plClient.setVar("search_results", duplicate(obj.searchByTerm(rc.searchTerm)))>
			<cfset plClient.setVar("search_tag", "")>
			<cfset plClient.setVar("search_term", rc.searchTerm)>

			<cfcatch type="any">
				<cfset getPlugin("messagebox").setMessage("error", cfcatch.message & "<br>" & cfcatch.detail)>
				<cfset getPlugin("logger").logError("Search by Term", e)>
				<cfset setView("vwMain")>
			</cfcatch>
		</cftry>
		<cfset setNextEvent("ehFeed.dspSearchResults")>
	</cffunction>

	<cffunction name="dspSearchResults" access="public" returntype="void" output="false">
		<cfset var plClient = getPlugin("clientStorage")>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehFeed = "ehFeed.dspViewFeed">
		<cfset rc.xehTags = "ehFeed.dspAllTags">

		<cftry>
			<cfif Not plClient.exists("search_results")>
				<cfthrow message="The search results are not in the client scope.">
			<cfelse>
				<cfset setValue("qryData", plClient.getVar("search_results") )>
				<cfset setValue("tag", plClient.getVar("search_tag") )>
				<cfset setValue("term",plClient.getVar("search_term") )>
			</cfif>

			<cfcatch type="any">
				<cfset setValue("qryData",QueryNew(""))>
				<cfset setValue("tag","")>
				<cfset setValue("term","")>
				<cfset getPlugin("messagebox").setMessage("error", cfcatch.message & "<br>" & cfcatch.detail)>
			</cfcatch>
		</cftry>
		<cfset setView("vwSearchResults")>
	</cffunction>
	
	<cffunction name="dspMyFeeds" access="public" returntype="void" output="false">
		<cfset var obj = application.cbService.getdao("feed")>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehViewFeed = "ehFeed.dspViewFeed">
		<cfset rc.xehShowTags = "ehFeed.dspAllTags">
		<cfset rc.xehShowInfo = "ehGeneral.dspInfo">
		<cfset rc.xehAccountActions = "ehUser.dspAccountActions">
		<!--- Get Feeds --->
		<cfset rc.qryFeeds = obj.getAllMyFeeds(session.userID)>
		<cfset setView("vwMyfeeds")>
	</cffunction>
	
</cfcomponent>