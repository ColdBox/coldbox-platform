<cfcomponent name="feed" extends="baseservice">

	<!--- ******************************************************************************** --->

	<cffunction name="init" access="public" returntype="any" output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="feedDAO" 	required="true" type="any">
		<cfargument name="ModelbasePath" required="true" type="string">
		<!--- ******************************************************************************** --->
		<cfset instance = structnew()>
		<cfset instance.feedDAO = arguments.feedDAO>
		<cfset instance.modelBasePath = arguments.ModelBasePath>
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
		<cfargument name="dirURL" type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		<cfset var qryDir = "">
		<cfset var txtDoc = "">
		<cfset var cacheValid = false>
		<cfset var cacheDir = "">
		<cfset var cacheFile = "">
		<cfset var stFeed = "">
		<cfset var slash = CreateObject("java","java.lang.System").getProperty("file.separator")>
		
		<!--- get details on requested feed --->
		<cfset qry = instance.feedDAO.getbyID(arguments.feedID)>

		<!--- Check if feed is on cache --->
		<cfset cacheValid = false>
		<cfset cacheDir = "#arguments.dirURL##slash#cache">
		<cfset cacheFile = cacheDir & slash  & arguments.feedID & ".xml">

		<!--- if there is a cache then check if it is less than 30 minutes old --->
		<cfif fileExists(cacheFile)>
			<cfdirectory action="list" directory="#cacheDir#" name="qryDir" filter="#arguments.feedID#.xml">
			<cfif DateDiff("n", qryDir.dateLastModified, now()) lt 30>
				<cfset cacheValid = true>
			</cfif>
		</cfif>
		<!--- if cached data is valid, get it from there, otherwise, get from web --->
		<cfif cacheValid>
			<cflock name="cacheOperation" timeout="100" type="readonly">
				<cffile action="read" file="#cacheFile#" variable="txtDoc">
			</cflock>
			<cfset stFeed = parseFeed(XMLParse(txtDoc))>
			<!--- update stats --->
			<cfset instance.feedDAO.updateFeedStat(arguments.feedID)>
		<cfelse>
			<cfset stFeed = retrieveFeed(qry.feedURL)>
			<!--- update stats --->
			<cfset instance.feedDAO.updateFeedStat(arguments.feedID,true)>
			<cflock name="cacheOperation" timeout="100" type="readonly">
				<cffile action="write" file="#cacheFile#" output="#toString(stFeed.xmlDocString)#">
			</cflock>
		</cfif>
		<cfreturn stFeed>
	</cffunction>

	<!--- ******************************************************************************** --->

	<cffunction name="retrieveFeed" access="public" returntype="struct">
		<!--- ******************************************************************************** --->
		<cfargument name="url" type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var xmlDoc = 0>
		<cfset var feed = "">
		<cfset arguments.url = ReplaceNoCase(arguments.url,"feed://","http://")>

		<cfhttp method="get" url="#arguments.url#" resolveurl="yes" redirect="yes">
			<cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0">
			<cfhttpparam type="Header" name="TE" value="deflate;q=0">
		</cfhttp>

		<cfset xmlDoc = XMLParse(trim(cfhttp.FileContent))>
		<cfset feed = parseFeed(xmlDoc)>

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

	<cffunction name="parseFeed" access="private" returntype="struct">
		<!--- ******************************************************************************** --->
		<cfargument name="xmlDoc" type="xml" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var feed = StructNew()>
		<cfset var isRSS1 = false>
		<cfset var isRSS2 = false>
		<cfset var isAtom = false>

		<cfscript>
			feed.title = "";
			feed.link = "";
			feed.description = "";
			feed.date = "";
			feed.image = StructNew();
			feed.image.url = "";
			feed.image.title = "";
			feed.image.link = "##";
			feed.items = ArrayNew(1);
			feed.xmlDocString = toString(arguments.xmlDoc);

			// get feed type
			isRSS1 = StructKeyExists(xmlDoc.xmlRoot,"item");
			isRSS2 = StructKeyExists(xmlDoc.xmlRoot,"channel") and StructKeyExists(xmlDoc.xmlRoot.channel,"item");
			isAtom = StructKeyExists(xmlDoc.xmlRoot,"entry");

			// get title
			if(isRSS1 or isRSS2) {
				if(isRSS1) feed.items = xmlDoc.xmlRoot.item;
				if(isRSS2) feed.items = xmlDoc.xmlRoot.channel.item;

				if(StructKeyExists(xmlDoc.xmlRoot.channel,"title")) feed.Title = xmlDoc.xmlRoot.channel.title.xmlText;
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"link")) feed.Link = xmlDoc.xmlRoot.channel.link.xmlText;
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"description")) feed.Description = xmlDoc.xmlRoot.channel.description.xmlText;
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"lastBuildDate")) feed.Date = xmlDoc.xmlRoot.channel.lastBuildDate.xmlText;
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"image")) {
					if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"url")) feed.Image.URL = xmlDoc.xmlRoot.channel.image.url.xmlText;
					if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"title")) feed.Image.Title = xmlDoc.xmlRoot.channel.image.title.xmlText;
					if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"link")) feed.Image.Link = xmlDoc.xmlRoot.channel.image.link.xmlText;
				}
			}
			if(isAtom) {
				if(isAtom) feed.items = xmlDoc.xmlRoot.entry;
				if(StructKeyExists(xmlDoc.xmlRoot,"title")) feed.Title = xmlDoc.xmlRoot.title.xmlText;
				if(StructKeyExists(xmlDoc.xmlRoot,"link")) feed.Link = xmlDoc.xmlRoot.link.xmlAttributes.href;
				if(StructKeyExists(xmlDoc.xmlRoot,"info")) feed.Description = xmlDoc.xmlRoot.info.xmlText;
				if(StructKeyExists(xmlDoc.xmlRoot,"modified")) feed.Date = xmlDoc.xmlRoot.modified.xmlText;
			}
		</cfscript>
		<cfreturn feed>
	</cffunction>

	<!--- ******************************************************************************** --->
</cfcomponent>