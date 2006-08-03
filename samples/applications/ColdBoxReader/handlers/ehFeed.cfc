<cfcomponent name="ehUser" extends="coldboxSamples.system.eventhandler">
	<cffunction name="init" access="public" returntype="ehFeed">
		<cfargument name="controller" required="yes" hint="The reference to the framework controller">	
		<cfset super.init(arguments.controller)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="dspAddFeed" access="public">
		<cfset setView("vwAddFeed")>
	</cffunction>
	
	<cffunction name="dspViewFeed" access="public">
		<cfset feedID = getValue("feedID")>
		<cfset obj = createObject("component","#getSetting("AppCFMXMapping")#.components.feed")>
		<cfset myFeed = obj.readFeed(feedID,"#GetSetting("ApplicationPath",1)#")>
		<cfset setValue("feed",myFeed)>
		<cfset setValue("feedID",feedID)>
		<cfset setView("vwViewFeed")>
	</cffunction>	

	<cffunction name="dspFeedInfo" access="public">
		<cfset feedID = getValue("feedID")>
		<cfset obj = createObject("component","#getSetting("AppCFMXMapping")#.components.feed")>
		<cfset qryData = obj.getFeedInfo(feedID)>
		<cfset setValue("qryData",qryData)>
		<cfset setValue("feedID",feedID)>
		<cfset setView("vwFeedInfo")>
	</cffunction>	

	<cffunction name="dspFeedTags" access="public">
		<cfset feedID = getValue("feedID")>
		<cfset obj = createObject("component","#getSetting("AppCFMXMapping")#.components.tags")>
		<cfset qryData = obj.getFeedTags(feedID)>
		<cfset setValue("qryData",qryData)>
		<cfset setValue("feedID",feedID)>
		<cfset setView("vwFeedTags")>
	</cffunction>

	<cffunction name="dspFeedComments" access="public">
		<cfset feedID = getValue("feedID")>
		<cfset obj = createObject("component","#getSetting("AppCFMXMapping")#.components.comments")>
		<cfset qryData = obj.getFeedComments(feedID)>
		<cfset setValue("qryData",qryData)>
		<cfset setValue("feedID",feedID)>
		<cfset setView("vwFeedComments")>
	</cffunction>
	
	<cffunction name="dspAllTags" access="public">
		<cfset obj = createObject("component","#getSetting("AppCFMXMapping")#.components.tags")>
		<cfset qryData = obj.getAllTags()>
		<cfset setValue("qryData",qryData)>
		<cfset setView("vwAllTags")>
	</cffunction>

	<cffunction name="dspSearchResults" access="public">
		<cftry>
			<cfset plClient = getPlugin("clientStorage")>
			
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
				
	<cffunction name="doParseFeed" access="public">
		<cftry>
			<cfset feedURL = getValue("feedURL","")>
			<cfset obj = createObject("component","#getSetting("AppCFMXMapping")#.components.feed")>
			<cfset myFeed = obj.retrieveFeed(feedURL)>
			
			<cfset setValue("feedName", myFeed.title)>
			<cfset setValue("feedURL", feedURL)>
			<cfset setValue("feedAuthor", "")>
			<cfset setValue("description", myFeed.description)>
			<cfset setValue("imgURL", myFeed.image.url)>
			<cfset setValue("siteURL", myFeed.link)>

			<cfcatch type="any">
				<cfset getPlugin("messagebox").setMessage("error", cfcatch.message & "<br>" & cfcatch.detail)>
				<cfset setView("vwAddFeed")>
			</cfcatch>
		</cftry>
		<cfset setView("vwAddFeed")>
	</cffunction>	

	<cffunction name="doAddFeed" access="public">
		<cftry>
			<cfset feedID = getValue("feedID")>
			<cfset feedName = getValue("feedName")>
			<cfset feedURL = getValue("feedURL")>
			<cfset feedAuthor = getValue("feedAuthor")>
			<cfset description = getValue("description")>
			<cfset imgURL = getValue("imgURL")>
			<cfset siteURL = getValue("siteURL")>		

			<cfset obj = createObject("component","#getSetting("AppCFMXMapping")#.components.feed")>
			<cfset obj.saveFeed(feedID, feedName, feedURL, feedAuthor, description, imgURL, siteURL, session.userID)>

			<cfcatch type="any">
				<cfset getPlugin("messagebox").setMessage("error", cfcatch.message & "<br>" & cfcatch.detail)>
				<cfset setView("vwAddFeed")>
			</cfcatch>
		</cftry>
		<cfset setNextEvent("ehGeneral.dspReader")>
	</cffunction>	

	<cffunction name="doAddTags" access="public">
		<cftry>
			<cfset feedID = getValue("feedID")>
			<cfset tags = getValue("tags")>

			<cfif tags neq "">
				<cfset obj = createObject("component","#getSetting("AppCFMXMapping")#.components.tags")>
				<cfset obj.addFeedTags(feedID, tags, session.userID)>
			</cfif>

			<cfcatch type="any">
				<cfset getPlugin("messagebox").setMessage("error", cfcatch.message & "<br>" & cfcatch.detail)>
			</cfcatch>
		</cftry>
		<cfset setNextEvent("ehFeed.dspFeedTags","feedID=#feedID#")>
	</cffunction>	

	<cffunction name="doSearchByTag" access="public">
		<cftry>
			<cfset tag = getValue("tag")>
			<cfset obj = createObject("component","#getSetting("AppCFMXMapping")#.components.feed")>
			<cfset qryData = obj.searchByTag(tag)>
			<cfset getPlugin("clientStorage").setVar("search_results", qryData)>
			<cfset getPlugin("clientStorage").setVar("search_tag", tag)>
			<cfset getPlugin("clientStorage").setVar("search_term", "")>
			
			<cfcatch type="any">
				<cfset getPlugin("messagebox").setMessage("error", cfcatch.message & "<br>" & cfcatch.detail)>
				<cfset setView("vwMain")>
			</cfcatch>
		</cftry>
		<cfset setNextEvent("ehFeed.dspSearchResults")>
	</cffunction>		
	
	<cffunction name="doSearchByTerm" access="public">
		<cftry>
			<cfset term = getValue("searchTerm")>
			<cfset obj = createObject("component","#getSetting("AppCFMXMapping")#.components.feed")>
			<cfset qryData = obj.searchByTerm(term)>
			<cfset plClient = getPlugin("clientStorage")>
			<cfset plClient.setVar("search_results", duplicate(qryData))>
			<cfset plClient.setVar("search_tag", "")>
			<cfset plClient.setVar("search_term", term)>
		
			<cfcatch type="any">
				<cfset getPlugin("messagebox").setMessage("error", cfcatch.message & "<br>" & cfcatch.detail)>
				<cfset setView("vwMain")>
			</cfcatch>
		</cftry>
		<cfset setNextEvent("ehFeed.dspSearchResults")>
	</cffunction>			
	
</cfcomponent>