<cfcomponent name="feed" extends="dataStore" output="false">
	
	<cffunction name="parseFeed" access="public" returntype="struct">
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
	
	<cffunction name="retrieveFeed" access="public" returntype="struct">
		<!--- ******************************************************************************** --->
		<cfargument name="url" type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var xmlDoc = 0>
		<cfset var feed = "">
		<cfset arguments.url = ReplaceNoCase(arguments.url,"feed://","http://")> 
		
		<cfhttp method="get" url="#arguments.url#" resolveurl="yes" redirect="yes"></cfhttp>
		
		<cfif Not IsXML(cfhttp.FileContent)>
			<cfthrow message="A problem ocurred while processing the requested link [#arguments.url#]. Check that it is a valid RSS or Atom feed.">
		</cfif>
		
		<cfset xmlDoc = XMLParse(cfhttp.FileContent)>
		<cfset feed = parseFeed(xmlDoc)>

		<cfreturn feed>
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
		<cfset var newID = "">
		<cfset var qry = "">
		
		<cfif arguments.feedID eq "">
			<cfset newID = CreateUUID()>
			<cfquery name="qry" datasource="#this.datasource#" username="#this.username#" password="#this.password#">
				INSERT INTO feed (FeedID, FeedName, FeedURL, FeedAuthor, Description, ImgURL, SiteURL, CreatedOn, CreatedBy) 
					VALUES (
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#newID#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.feedName#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.feedURL#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.feedAuthor#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.description#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.imgURL#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteURL#">,
							<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#">
							)
			</cfquery>
		<cfelse>
			<cfset newID = arguments.feedID>
			<cfquery name="qry" datasource="#this.datasource#" username="#this.username#" password="#this.password#">
				UPDATE feed SET
					FeedID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.feedID#">,
					FeedName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.feedName#">,
					FeedURL = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.feedURL#">,
					FeedAuthor = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.feedAuthor#">,
					Description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.description#">,
					ImgURL = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.imgURL#">,
					SiteURL = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteURL#">
			</cfquery>
		</cfif>
		
		<cfreturn newID>
	</cffunction>	
	
	<!--- ******************************************************************************** --->
	
	<cffunction name="getAllFeeds" access="public" returntype="query">
		<cfset var qry = "">
		<cfquery name="qry" datasource="#this.datasource#" username="#this.username#" password="#this.password#">
			SELECT FeedID, FeedName, FeedURL, FeedAuthor, Description, ImgURL, SiteURL, f.CreatedOn, f.CreatedBy, u.UserName,Views
				FROM feed f
					INNER JOIN users u ON f.CreatedBy = u.UserID
				ORDER BY f.CreatedOn DESC
		</cfquery>		
		<cfreturn qry>
	</cffunction>
	
	<!--- ******************************************************************************** --->
	
	<cffunction name="getAllMyFeeds" access="public" returntype="query">
		<!--- ******************************************************************************** --->
		<cfargument name="userID" 	type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		<cfquery name="qry" datasource="#this.datasource#" username="#this.username#" password="#this.password#">
			SELECT FeedID, FeedName, FeedURL, FeedAuthor, Description, ImgURL, SiteURL, f.CreatedOn, f.CreatedBy, u.UserName,Views
				FROM feed f
					INNER JOIN users u ON f.CreatedBy = u.UserID
			   WHERE u.UserID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#">
			   ORDER BY f.CreatedOn DESC
		</cfquery>		
		<cfreturn qry>
	</cffunction>
	
	<!--- ******************************************************************************** --->
	
	<cffunction name="verifyFeed" access="public" returntype="boolean" hint="Verifies a feed by the user.">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" 	type="string" required="yes">
		<cfargument name="authorID" type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		<cfquery name="qry" datasource="#this.datasource#" username="#this.username#" password="#this.password#">
			SELECT FeedID
				FROM feed
			   WHERE FeedURL = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.feedURL#"> AND
			   		 CreatedBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.authorID#">
		</cfquery>
		<cfif qry.recordcount>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
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
		<cfset var cacheValid = "">
		<cfset var cacheDir = "">
		<cfset var cacheFile = "">
		<cfset var stFeed = "">
		<cfset var slash = CreateObject("java","java.lang.System").getProperty("file.separator")>
		
		<!--- get details on requested feed --->
		<cfquery name="qry" datasource="#this.datasource#" username="#this.username#" password="#this.password#">
			SELECT FeedURL
				FROM feed
				WHERE FeedID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.feedID#">
		</cfquery>
		
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
			<cffile action="read" file="#cacheFile#" variable="txtDoc">
			<cfset stFeed = parseFeed(XMLParse(txtDoc))>
			<!--- update stats --->
			<cfquery name="qry" datasource="#this.datasource#" username="#this.username#" password="#this.password#">
				UPDATE feed
					SET Views = Views + 1
				  WHERE FeedID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.feedID#">
			</cfquery>
		<cfelse>
			<cfset stFeed = retrieveFeed(qry.feedURL)>
			<!--- update stats --->
			<cfquery name="qry" datasource="#this.datasource#" username="#this.username#" password="#this.password#">
				UPDATE feed
					SET LastRefreshedOn = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
						Views = Views + 1
				  WHERE FeedID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.feedID#">
			</cfquery>
			<cffile action="write" file="#cacheFile#" output="#toString(stFeed.xmlDocString)#">	
		</cfif>		
		<cfreturn stFeed>
	</cffunction>	
	
	<!--- ******************************************************************************** --->
	
	<cffunction name="getFeedInfo" access="public" returntype="query">
		<!--- ******************************************************************************** --->
		<cfargument name="feedID" type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		<cfquery name="qry" datasource="#this.datasource#" username="#this.username#" password="#this.password#">
			SELECT f.*, u.UserName, u.Email
				FROM feed f, users u
				WHERE f.FeedID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.feedID#"> and
				      f.CreatedBy = u.UserID
		</cfquery>
		<cfreturn qry>
	</cffunction>	
	
	<!--- ******************************************************************************** --->
	
	<cffunction name="searchByTag" access="public" returntype="query">
		<!--- ******************************************************************************** --->
		<cfargument name="tag" type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		<cfquery name="qry" datasource="#this.datasource#" username="#this.username#" password="#this.password#">
			SELECT f.FeedID, FeedName, FeedURL, FeedAuthor, Description, ImgURL, SiteURL, f.CreatedOn, f.CreatedBy, u.UserName, Views
				FROM feed f
					INNER JOIN feed_tags t ON f.FeedID=t.FeedID
					INNER JOIN users u ON f.CreatedBy = u.UserID
				WHERE tag = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.tag#">
				ORDER BY f.FeedName DESC
		</cfquery>
		<cfreturn qry>
	</cffunction>		
	
	<!--- ******************************************************************************** --->
	
	<cffunction name="searchByTerm" access="public" returntype="query">
		<!--- ******************************************************************************** --->
		<cfargument name="term" type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		<cfquery name="qry" datasource="#this.datasource#" UserName="#this.UserName#" password="#this.password#">
			SELECT f.FeedID, FeedName, FeedURL, FeedAuthor, Description, ImgURL, SiteURL, f.CreatedOn, f.CreatedBy, u.UserName, Views
				FROM feed f
					INNER JOIN feed_tags t ON f.FeedID=t.FeedID
					INNER JOIN users u ON f.CreatedBy = u.UserID
				WHERE tag LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.term#%">
					OR FeedName LIKE  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.term#%">
					OR Description LIKE  <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.term#%">
					OR SiteURL LIKE  <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.term#%">
					OR UserName LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.term#%">
				GROUP BY  f.FeedID, FeedName, FeedURL, FeedAuthor, Description, ImgURL, SiteURL, f.CreatedOn, f.CreatedBy, u.UserName, Views
				ORDER BY f.FeedName DESC
		</cfquery>
		<cfreturn qry>
	</cffunction>		
	
	<!--- ******************************************************************************** --->
	
</cfcomponent>