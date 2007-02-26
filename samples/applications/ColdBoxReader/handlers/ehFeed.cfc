<cfcomponent name="ehUser" extends="coldbox.system.eventhandler">

	<cffunction name="dspAddFeed" access="public" returntype="void" output="false">
		<cfargument name="requestContext" type="coldbox.system.beans.requestContext">
		<cfset var csPlugin = getPlugin("clientstorage")>
		<cfset var obj = "">
		<cfset var rc = requestContext.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehAddFeed = "ehFeed.doAddFeed">
		<cfset rc.xehNewFeed = "ehFeed.dspAddFeed">

		<!--- Feed Validated? --->
		<cfset rc.feedValidated = false>
		
		<!--- Try to parse feed --->
		<cfif requestContext.getValue("continue_button","") neq "">
			<!--- Validate Feed --->
			<cfif trim(len(rc.FeedURL)) eq 0 or not getPlugin("fileUtilities").isURL("#rc.FeedURL#")>
				<cfset getPlugin("messagebox").setMessage("error","Please enter a valid Feed URL")>
			<cfelse>
				<cftry>
					<cfset obj = getPlugin("ioc").getBean("feedService")>
					<!--- Verify Feed in user's feeds --->
					<cfif obj.verifyFeed(rc.feedURL, session.oUserBean.getuserID())>
						<cfset getPlugin("messagebox").setMessage("warning","The feed you are trying to add is already in your feeds collection. You cannot add it twice.")>
					<cfelse>
						<cfset rc.myFeed = obj.retrieveFeed(rc.feedURL)>
						<cfset rc.feedValidated = true>
					</cfif>
					<cfcatch type="any">
						<cfset getPlugin("logger").logError("Error Parsing Feed", cfcatch)>
						<cfset getPlugin("messagebox").setMessage("error", cfcatch.message & "<br>" & cfcatch.detail)>
					</cfcatch>
				</cftry>
			</cfif>
		</cfif>
		<!--- Set view --->
		<cfset requestContext.setView("vwAddFeed")>
	</cffunction>

	<cffunction name="dspViewFeed" access="public" returntype="void" output="false">
		<cfargument name="requestContext" type="coldbox.system.beans.requestContext">
		<cfset var obj = getPlugin("ioc").getBean("feedService")>
		<cfset var rc = requestContext.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehFeeds = "ehGeneral.dspReader">
		<cfset rc.xehMyFeeds = "ehFeed.dspMyFeeds">
		<cfset rc.xehReload = "ehFeed.dspViewFeed">
		<cfset rc.xehFeedInfo = "ehFeed.dspFeedInfo">
		<cfset rc.xehFeedTags = "ehFeed.dspFeedTags">
		<cfset rc.xehFeedComments = "ehFeed.dspFeedComments">
		<!--- Get feed --->
		<cfset rc.feed = obj.readFeed(rc.feedID,"#GetSetting("ApplicationPath",1)#")>
		<cfset requestContext.setView("vwViewFeed")>
	</cffunction>

	<cffunction name="dspFeedInfo" access="public" returntype="void" output="false">
		<cfargument name="requestContext" type="coldbox.system.beans.requestContext">
		<cfset var obj = getPlugin("ioc").getBean("feedService")>
		<cfset var rc = requestContext.getCollection()>
		<cfset rc.qryData = obj.getFeedInfo(rc.feedID)>
		<cfset requestContext.setView("vwFeedInfo")>
	</cffunction>

	<cffunction name="dspFeedTags" access="public" returntype="void" output="false">
		<cfargument name="requestContext" type="coldbox.system.beans.requestContext">
		<cfset var obj = getPlugin("ioc").getbean("tagService")>
		<cfset var rc = requestContext.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehSearchByTag = "ehFeed.doSearchByTag">
		<cfset rc.xehAddTag = "ehFeed.doAddTags">
		<cfset rc.qryData = obj.getTags(rc.feedID)>
		<cfif session.oUserBean.getVerified()>
			<cfif rc.qryData.recordCount gt 0>
				<cfset rc.qryMyTags = getPlugin("QueryHelper").filterQuery(rc.qryData,"CreatedBy",session.oUserBean.getUserID(),"cf_sql_varchar")>
			<cfelse>
				<cfset rc.qryMyTags = QueryNew("")>
			</cfif>
		</cfif>
		<cfset requestContext.setView("vwFeedTags")>
	</cffunction>

	<cffunction name="dspAllTags" access="public" returntype="void" output="false">
		<cfargument name="requestContext" type="coldbox.system.beans.requestContext">
		<cfset var obj = getPlugin("ioc").getbean("tagService")>
		<cfset var rc = requestContext.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehSearchTag = "ehFeed.doSearchByTag">
		<cfset rc.qryData = obj.getTags()>
		<cfset requestContext.setView("vwAllTags")>
	</cffunction>

	<cffunction name="doAddFeed" access="public" returntype="void" output="false">
		<cfargument name="requestContext" type="coldbox.system.beans.requestContext">
		<cfset var obj = "">
		<cfset var rc = requestContext.getCollection()>
		<cftry>
			<cfset obj = getPlugin("ioc").getBean("feedService")>
			<cfset obj.saveFeed(rc.feedID, rc.feedName, rc.feedURL, rc.FeedAuthor, rc.description, rc.imgURL, rc.siteURL, session.oUserBean.getuserID())>
			<cfset getPlugin("messagebox").setMessage("info", "The feed: #rc.feedName# has been added successfully")>
			<cfcatch type="any">
				<cfset getPlugin("messagebox").setMessage("error","Error adding Feed:" & cfcatch.message & "<br>" & cfcatch.detail)>
				<cfset getPlugin("logger").logError("Error Adding Feed", cfcatch)>
				<cfset setNextEvent("ehFeed.dspAddFeed")>
			</cfcatch>
		</cftry>
		<cfset setNextEvent("ehGeneral.dspReader")>
	</cffunction>

	<cffunction name="doAddTags" access="public" returntype="void" output="false">
		<cfargument name="requestContext" type="coldbox.system.beans.requestContext">
		<cfset var obj = "">
		<cfset var rc = requestContext.getCollection()>
		<cftry>

			<cfif rc.tags neq "">
				<cfset obj = getPlugin("ioc").getBean("tagService")>
				<cfset obj.addFeedTags(rc.feedID, rc.tags, session.oUserBean.getUserID())>
			</cfif>

			<cfcatch type="any">
				<cfset getPlugin("logger").logError("Error Adding Tag", cfcatch)>
				<cfset getPlugin("messagebox").setMessage("error", cfcatch.message & "<br>" & cfcatch.detail)>
			</cfcatch>
		</cftry>
		<cfset setNextEvent("ehFeed.dspFeedTags","feedID=#rc.feedID#")>
	</cffunction>

	<cffunction name="doSearchByTag" access="public" returntype="void" output="false">
		<cfargument name="requestContext" type="coldbox.system.beans.requestContext">
		<cfset var obj = "">
		<cfset var qryData = "">
		<cfset var rc = requestContext.getCollection()>
		<cftry>
			<cfset obj = getPlugin("ioc").getBean("feedService")>
			<cfset qryData = obj.searchByTag(rc.tag)>
			<cfset getPlugin("clientStorage").setVar("search_results", qryData)>
			<cfset getPlugin("clientStorage").setVar("search_tag", rc.tag)>
			<cfset getPlugin("clientStorage").setVar("search_term", "")>

			<cfcatch type="any">
				<cfset getPlugin("logger").logError("Error Searching by Tags", cfcatch)>
				<cfset getPlugin("messagebox").setMessage("error", cfcatch.message & "<br>" & cfcatch.detail)>
				<cfset setNextEvent()>
			</cfcatch>
		</cftry>
		<cfset setNextEvent("ehFeed.dspSearchResults")>
	</cffunction>

	<cffunction name="doSearchByTerm" access="public" returntype="void" output="false">
		<cfargument name="requestContext" type="coldbox.system.beans.requestContext">
		<cfset var obj = "">
		<cfset var plClient = getPlugin("clientStorage")>
		<cfset var rc = requestContext.getCollection()>
		<cftry>
			<cfset term = requestContext.getValue("searchTerm")>
			<cfset obj = getPlugin("ioc").getBean("feedService")>
			<cfset plClient.setVar("search_results", duplicate(obj.searchByTerm(rc.searchTerm)))>
			<cfset plClient.setVar("search_tag", "")>
			<cfset plClient.setVar("search_term", rc.searchTerm)>

			<cfcatch type="any">
				<cfset getPlugin("messagebox").setMessage("error", cfcatch.message & "<br>" & cfcatch.detail)>
				<cfset getPlugin("logger").logError("Search by Term", cfcatch)>
				<cfset requestContext.setView("vwMain")>
			</cfcatch>
		</cftry>
		<cfset setNextEvent("ehFeed.dspSearchResults")>
	</cffunction>

	<cffunction name="dspSearchResults" access="public" returntype="void" output="false">
		<cfargument name="requestContext" type="coldbox.system.beans.requestContext">
		<cfset var plClient = getPlugin("clientStorage")>
		<cfset var rc = requestContext.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehFeed = "ehFeed.dspViewFeed">
		<cfset rc.xehTags = "ehFeed.dspAllTags">

		<cftry>
			<cfif Not plClient.exists("search_results")>
				<cfthrow message="The search results are not in the client scope.">
			<cfelse>
				<cfset requestContext.setValue("qryData", plClient.getVar("search_results") )>
				<cfset requestContext.setValue("tag", plClient.getVar("search_tag") )>
				<cfset requestContext.setValue("term",plClient.getVar("search_term") )>
			</cfif>

			<cfcatch type="any">
				<cfset requestContext.setValue("qryData",QueryNew(""))>
				<cfset requestContext.setValue("tag","")>
				<cfset requestContext.setValue("term","")>
				<cfset getPlugin("messagebox").setMessage("error", cfcatch.message & "<br>" & cfcatch.detail)>
			</cfcatch>
		</cftry>
		<cfset requestContext.setView("vwSearchResults")>
	</cffunction>
	
	<cffunction name="dspMyFeeds" access="public" returntype="void" output="false">
		<cfargument name="requestContext" type="coldbox.system.beans.requestContext">
		<cfset var obj = getPlugin("ioc").getBean("feedService")>
		<cfset var rc = requestContext.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehViewFeed = "ehFeed.dspViewFeed">
		<cfset rc.xehShowTags = "ehFeed.dspAllTags">
		<cfset rc.xehShowInfo = "ehGeneral.dspInfo">
		<cfset rc.xehAccountActions = "ehUser.dspAccountActions">
		<!--- Get Feeds --->
		<cfset rc.qryFeeds = obj.getAllMyFeeds(session.oUserBean.getuserID())>
		<cfset requestContext.setView("vwMyfeeds")>
	</cffunction>
	
</cfcomponent>