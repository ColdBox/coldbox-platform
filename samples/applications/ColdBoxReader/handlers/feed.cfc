<cfcomponent name="user" extends="coldbox.system.eventhandler" output="false" autowire="true">
	
	<!--- Dependency Injections --->
	<cfproperty name="tagService"  type="ioc" scope="instance" />
	<cfproperty name="feedService" type="ioc" scope="instance" />
	
	<cffunction name="dspAddFeed" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		<cfset var obj = "">
		<cfset var rc = Event.getCollection()>
		
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehAddFeed = "feed.doAddFeed">
		<cfset rc.xehNewFeed = "feed.dspAddFeed">

		<!--- Feed Validated? --->
		<cfset rc.feedValidated = false>
		
		<!--- Try to parse feed --->
		<cfif Event.getValue("continue_button","") neq "">
			<!--- Validate Feed --->
			<cfif trim(len(rc.FeedURL)) eq 0 or not getPlugin("Utilities").isURL(rc.FeedURL)>
				<cfset getPlugin("messagebox").setMessage("error","Please enter a valid Feed URL")>
			<cfelse>
				<cftry>
					<!--- Verify Feed in user's feeds --->
					<cfif getFeedService().verifyFeed(rc.feedURL, rc.oUserBean.getuserID())>
						<cfset getPlugin("messagebox").setMessage("warning","The feed you are trying to add is already in your feeds collection. You cannot add it twice.")>
					<cfelse>
						<cfset rc.myFeed = getFeedService().retrieveFeed(rc.feedURL)>
						<cfset rc.feedValidated = true>
					</cfif>
					<cfcatch type="any">
						<cfset getPlugin("logger").logError("Error Parsing Feed", cfcatch)>
						<cfset getPlugin("messagebox").setMessage("error", cfcatch.message & "<br>" & cfcatch.detail)>
					</cfcatch>
				</cftry>
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="dspViewFeed" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		<cfset var rc = Event.getCollection()>
		
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehfeeds = "general.dspReader">
		<cfset rc.xehMyFeeds = "feed.dspMyFeeds">
		<cfset rc.xehReload = "feed.dspViewFeed">
		<cfset rc.xehfeedInfo = "feed.dspFeedInfo">
		<cfset rc.xehfeedTags = "feed.dspFeedTags">
		<cfset rc.xehfeedComments = "feed.dspFeedComments">
		
		<!--- Get feed --->
		<cfset rc.feed = getFeedService().readFeed(rc.feedID)>
	</cffunction>

	<cffunction name="dspFeedInfo" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		<cfset var rc = Event.getCollection()>
		
		<cfset rc.qryData = getFeedService().getFeedInfo(rc.feedID)>
	</cffunction>

	<cffunction name="dspFeedTags" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		<cfset var obj = getTagService()>
		<cfset var rc = Event.getCollection()>
		
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehSearchByTag = "feed.doSearchByTag">
		<cfset rc.xehAddTag = "feed.doAddTags">
		<cfset rc.qryData = obj.getTags(rc.feedID)>
		<cfif rc.oUserBean.getVerified()>
			<cfif rc.qryData.recordCount gt 0>
				<cfset rc.qryMyTags = getPlugin("QueryHelper").filterQuery(rc.qryData,"CreatedBy",rc.oUserBean.getUserID(),"cf_sql_varchar")>
			<cfelse>
				<cfset rc.qryMyTags = QueryNew("")>
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="dspAllTags" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		<cfset var obj = getTagService()>
		<cfset var rc = Event.getCollection()>
		
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehSearchTag = "feed.doSearchByTag">
		<cfset rc.qryData = obj.getTags()>
	</cffunction>

	<cffunction name="doAddFeed" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		<cfset var obj = "">
		<cfset var rc = Event.getCollection()>
		<cftry>
			<cfset obj = getFeedService()>
			<cfset obj.saveFeed(rc.feedID, rc.feedName, rc.feedURL, rc.FeedAuthor, rc.description, rc.imgURL, rc.siteURL, rc.oUserBean.getuserID())>
			<cfset getPlugin("messagebox").setMessage("info", "The feed: #rc.feedName# has been added successfully")>
			<cfcatch type="any">
				<cfset getPlugin("messagebox").setMessage("error","Error adding Feed:" & cfcatch.message & "<br>" & cfcatch.detail)>
				<cfset getPlugin("logger").logError("Error Adding Feed", cfcatch)>
				<cfset setNextEvent("feed.dspAddFeed")>
			</cfcatch>
		</cftry>
		<cfset setNextEvent("general.dspReader")>
	</cffunction>

	<cffunction name="doAddTags" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		<cfset var obj = "">
		<cfset var rc = Event.getCollection()>
		<cftry>

			<cfif rc.tags neq "">
				<cfset obj = getTagService()>
				<cfset obj.addFeedTags(rc.feedID, rc.tags, rc.oUserBean.getUserID())>
			</cfif>

			<cfcatch type="any">
				<cfset getPlugin("logger").logError("Error Adding Tag", cfcatch)>
				<cfset getPlugin("messagebox").setMessage("error", cfcatch.message & "<br>" & cfcatch.detail)>
			</cfcatch>
		</cftry>
		<cfset setNextEvent("feed.dspFeedTags","feedID=#rc.feedID#")>
	</cffunction>

	<cffunction name="doSearchByTag" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		<cfset var qryData = "">
		<cfset var rc = Event.getCollection()>
		<cfset var sessionstorage = getPlugin("sessionstorage")>
		
		<cftry>
			
			<cfset qryData = getFeedService().searchByTag(rc.tag)>
			
			<cfset sessionstorage.setVar("search_results", qryData)>
			<cfset sessionstorage.setVar("search_tag", rc.tag)>
			<cfset sessionstorage.setVar("search_term", "")>	
				
			<cfset setNextEvent("feed.dspSearchResults")>

			<cfcatch type="any">
				<cfset getPlugin("logger").logError("Error Searching by Tags", cfcatch)>
				<cfset getPlugin("messagebox").setMessage("error", cfcatch.message & "<br>" & cfcatch.detail)>
				<cfset setNextEvent()>
			</cfcatch>
		</cftry>		
	</cffunction>

	<cffunction name="doSearchByTerm" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		<cfset var obj = "">
		<cfset var sessionstorage = getPlugin("sessionstorage")>
		<cfset var rc = Event.getCollection()>
		<cftry>
			<cfset term = Event.getValue("searchTerm")>
			<cfset obj = getFeedService()>
			<cfset sessionstorage.setVar("search_results", duplicate(obj.searchByTerm(rc.searchTerm)))>
			<cfset sessionstorage.setVar("search_tag", "")>
			<cfset sessionstorage.setVar("search_term", rc.searchTerm)>

			<cfcatch type="any">
				<cfset getPlugin("messagebox").setMessage("error", cfcatch.message & "<br>" & cfcatch.detail)>
				<cfset getPlugin("logger").logError("Search by Term", cfcatch)>
				<cfset Event.setView("vwMain")>
			</cfcatch>
		</cftry>
		<cfset setNextEvent("feed.dspSearchResults")>
	</cffunction>

	<cffunction name="dspSearchResults" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		<cfset var sessionstorage = getPlugin("sessionstorage")>
		<cfset var rc = Event.getCollection()>
		
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehfeed = "feed.dspViewFeed">
		<cfset rc.xehTags = "feed.dspAllTags">

		<cftry>
			<cfif Not sessionstorage.exists("search_results")>
				<cfthrow message="The search results are not in the client scope.">
			<cfelse>
				<cfset Event.setValue("qryData", sessionstorage.getVar("search_results") )>
				<cfset Event.setValue("tag", sessionstorage.getVar("search_tag") )>
				<cfset Event.setValue("term",sessionstorage.getVar("search_term") )>
			</cfif>

			<cfcatch type="any">
				<cfset Event.setValue("qryData",QueryNew(""))>
				<cfset Event.setValue("tag","")>
				<cfset Event.setValue("term","")>
				<cfset getPlugin("messagebox").setMessage("error", cfcatch.message & "<br>" & cfcatch.detail)>
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="dspMyFeeds" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		<cfset var obj = getFeedService()>
		<cfset var rc = Event.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehViewFeed = "feed.dspViewFeed">
		<cfset rc.xehShowTags = "feed.dspAllTags">
		<cfset rc.xehShowInfo = "general.dspInfo">
		<cfset rc.xehAccountActions = "user.dspAccountActions">
		
		<!--- Get Feeds --->
		<cfset rc.qryFeeds = obj.getAllMyFeeds(rc.oUserBean.getuserID())>
	</cffunction>


<!------------------------------------------ DEPENDENCIES -------------------------------------->
	
	<!--- tag service --->
	<cffunction name="gettagService" access="private" output="false" returntype="any" hint="Get tagService">
		<cfreturn instance.tagService/>
	</cffunction>
	
	<!--- feedService --->
	<cffunction name="getfeedService" access="private" output="false" returntype="any" hint="Get feedService">
		<cfreturn instance.feedService/>
	</cffunction>	
	
</cfcomponent>