<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Luis Majano
Date        :	02/22/2008
License		: 	Apache 2 License
Description :
	A rss reader plugin with file caching capabilities. This reader supports RSS 1.0, 2.0 and Atom 1.0 only.
	All RSS dates are converted to usable ColdFusion dates, this means that all ISO8601 and RFC822 dates are
	converted to standard coldfusion dates. So you don't have to parse anything more. Just format them
	
	You need to set the following settings in your application (coldbox.xml.cfm)
	
Application Settings:
	- rssReader_useCache 		: boolean [default=true] (Use the file cache or not)
	- rssReader_cacheLocation 	: string (Where to store the file caching, relative to the app or absolute)
	- rssReader_cacheTimeout 	: numeric [default=30] (In minutes, the timeout of the file cache)
	- rssReader_httpTimeout 	: numeric [default=30] (In seconds, the timeout of the cfhttp call)
	
RSS Retrieval Methods:
	- readFeed( feedURL, itemsType[default=query] ) : Retrieve a feed from cfhttp, parse, cache, and return results in query or array format.
	- retrieveFeed( feedURL, itemsType[default=query] ) : Retrieve a feed from cfhttp, parse, and return results in query or array format.

RSS File Caching Methods:
	- flushCache() : Flush/Remove the entire cache
	- getCacheSize() : numeric : How many feeds do we have in the cache.
	- isFeedCached( feedURL ) : boolean : Is this feed cached or not
	- isFeedExpired( feedURL ) : boolean : Is this feed expired in the cache or not
	- expireCachedFeed( feedURL ) : Expire a feed if it exists
	- removeCachedFeed( feedURL ) : boolean : remove a feed from the cache
	- getCachedFeed( feedURL ) : any : Get the object representing the feed
	- setCachedFeed( feedURL, feedStruct ) : Cache the feed	
	
What gets returned on the FeedStructure:

[AUTHOR] - Feed Author
[AUTHOREMAIL] - Author Email
[AUTHORURL] - Author URL
[DATE] - Feed Created Date
[DATEUPDATED] - Feed Updated Date (Normalized ColdFusion Dates)
[DESCRIPTION] - Feed Description (Normalized ColdFusion Dates)
[TITLE] - Feed Title
[IMAGE] - Image Structure
	[LINK] - Image Link
	[TITLE] - Image Title
	[URL] - Image URL
[LINK] - Feed Link
[ITEMS] - Items Array or Query, both contain the following
	[DATE] - Feed Created Date (Normalized ColdFusion Dates)
	[DATEUPDATED] - Feed Updated Date (Normalized ColdFusion Dates)
	[DESCRIPTION] - The content
	[ENCLOSURE] - The enclosure
	[LINK] - The link to the item
	[TITLE] - The title to the item
	

----------------------------------------------------------------------->
<cfcomponent name="rssReader" 
			 extends="coldbox.system.plugin"
			 hint="A rss reader plugin. We recommend that when you call the readFeed method, that you use url's as settings. ex: readFeed(getSetting('myFeedURL')).  The settings this plugin uses are the following: rssReader_useCache:boolean [default=true], rssReader_cacheLocation:string, rssReader_cacheTimeout:numeric [default=30 min], rssReader_httpTimeout:numeric [default=30 sec]. If the cacheLocation directory does not exits, the plugin will throw an error. So please remember to create the directory."
			 cache="true"
			 cacheTimeout="45">

<!---------------------------------------- CONSTRUCTOR --------------------------------------------------->

	<cffunction name="init" access="public" returntype="rssReader" output="false" hint="Plugin Constructor.">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			var cacheLocation = "";
			var slash = "";
			
			/* Super */
			super.Init(arguments.controller);
			
			/* Plugin Properties */
			setpluginName("rssReader");
			setpluginVersion("1.0");
			setpluginDescription("I am a rss feed reader.");
			
			/* Check if using Cache and set useCache setting */
			if( not settingExists('rssReader_useCache') or not isBoolean(getSetting('rssReader_useCache')) ){
				setUseCache(true);
			}else{
				setUseCache(getSetting('rssReader_useCache'));
			}
			
			/* Setup Caching variables if using it */
			if( getUseCache() ){	
				/* File Separator */
				slash = getSetting("OSFileSeparator",true);
				/* Cache Location */
				if( not settingExists('rssReader_cacheLocation') ){
					throw(message="The Setting rssReader_cacheLocation is missing. Please create it.",type='rss.rssReader.InvalidSettingException');
				}
				/* Tests if the directory exists: Full Path */
				if ( directoryExists( getController().getAppRootPath() & getSetting('rssReader_cacheLocation') ) ){
					setCacheLocation( getController().getAppRootPath() & getSetting('rssReader_cacheLocation') );
				}
				if ( directoryExists( getController().getAppRootPath() & slash & getSetting('rssReader_cacheLocation') ) ){
					setCacheLocation( getController().getAppRootPath() & slash & getSetting('rssReader_cacheLocation') );
				}
				else if( directoryExists( ExpandPath(getSetting('rssReader_cacheLocation')) ) ){
					setCacheLocation( ExpandPath(getSetting('rssReader_cacheLocation')) );
				}
				else if( directoryExists(getSetting('rssReader_cacheLocation')) ){
					setCacheLocation( getSetting('rssReader_cacheLocation') );
				}
				else{
					throw('The cache location directory could not be found. Please check again. #getSetting('rssReader_cacheLocation')#','','rss.rssReader.InvalidCacheLocationException');
				}
							
				/* Cache Timeout */
				if( not settingExists('rssReader_cacheTimeout') ){
					setCacheTimeout(30);
				}
				else{
					setCacheTimeout(getSetting('rssReader_cacheTimeout'));
				}
			}//end else using cache
			
			/* HTTP Timeout */
			if( not settingExists('rssReader_httpTimeout') ){
				sethttpTimeout(30);
			}
			else{
				sethttpTimeout(getSetting('rssReader_httpTimeout'));
			}
			
			/* Set The lock Name */
			setLockName('rss.rssReaderCacheOperation');
			
			/* Return instance */
			return this;
		</cfscript>
	</cffunction>

<!---------------------------------------- INTERNAL CACHE OPERATIONS --------------------------------------------------->
	
	<!--- flushCache --->
	<cffunction name="flushCache" output="false" access="public" returntype="void" hint="Flushes the entire file cache. Removes all entries">
		<cfset var qFiles = "">
		<cfset var slash = getSetting("OSFileSeparator",true)>
		
		<!--- Lock and get Files and Remove. --->		
		<cflock name="#getLockName()#" type="exclusive" timeout="30" throwontimeout="true">
			<cfset qFiles = readCacheDir()>
			<!--- Recursively Delete --->
			<cfloop query="qFiles">
				<!--- Delete File --->
				<cffile action="delete" file="#qFiles.directory##slash##qFiles.name#">
			</cfloop>
		</cflock>
	</cffunction>
	
	<!--- How many elements in Cache --->
	<cffunction name="getCacheSize" output="false" access="public" returntype="numeric" hint="Returns the number of elements in the cache directory">
		<cfset var size = 0>
		<cflock name="#getLockName()#" type="readonly" timeout="30" throwontimeout="true">
			<cfset size = readCacheDir().recordcount>
		</cflock>
		<cfreturn size>
	</cffunction>
			
	<!--- Lookup cache element, also timeout if needed --->
	<cffunction name="isFeedCached" output="false" access="public" returntype="boolean" hint="Checks if a feed is cached or not">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" type="string" required="yes" hint="The url to check if its in the cache.">
		<!--- ******************************************************************************** --->
		<cfset var results = false>
		<!--- Secure Cache Read. --->
		<cflock name="#getLockName()#" type="readonly" timeout="30" throwontimeout="true">
			<!--- Check if feed is in cache. --->
			<cfif readCacheDir(filter=URLToCacheKey(arguments.feedURL)).recordcount neq 0>
				<cfset results = true>
			</cfif>
		</cflock>
		<cfreturn results>
	</cffunction>
	
	<!--- Checks if the feed has expired or not --->
	<cffunction name="isFeedExpired" output="false" access="public" returntype="boolean" hint="Checks if a feed has expired or not. If the feed does not exist, it will throw an error.">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" type="string" required="yes" hint="The url to check if its in the cache.">
		<!--- ******************************************************************************** --->
		<cfset var results = false>
		<cfset var qFile = "">
		
		<!--- Secure Cache Read. --->
		<cflock name="#getLockName()#" type="readonly" timeout="30" throwontimeout="true">
			<!--- Check if feed is in cache. --->
			<cfset qFile = readCacheDir(filter=URLToCacheKey(arguments.feedURL))>
			<!--- Exists Check --->
			<cfif qFile.recordcount eq 0>
				<cfthrow message="The feed does not exist in the cache." type="customPlugins.rss.rssReader">
			</cfif>
			<!--- Timeout Check --->
			<cfif DateDiff("n", qFile.dateLastModified, now()) gt getCacheTimeout()>
				<cfset results = true>					
			</cfif>				
		</cflock>
		
		<cfreturn results>
	</cffunction>
	
	<!--- Checks if the feed has expired or not --->
	<cffunction name="expireCachedFeed" output="false" access="public" returntype="void" hint="If the feed exists and it has expired, it removes it, else nothing.">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" type="string" required="yes" hint="The url to check if its in the cache.">
		<!--- ******************************************************************************** --->
		<cfset var results = false>
		<cfset var qFile = "">
		
		<!--- Check if feed is in cache. --->
		<cfset qFile = readCacheDir(filter=URLToCacheKey(arguments.feedURL))>
		<!--- Exists Check --->
		<cfif qFile.recordcount gt 0 and DateDiff("n", qFile.dateLastModified, now()) gt getCacheTimeout()>
			<cfset removeCachedFeed(arguments.feedURL)>		
		</cfif>
	</cffunction>
	
	<!--- flushCache --->
	<cffunction name="removeCachedFeed" output="false" access="public" returntype="boolean" hint="Purges/removes a feed from the cache, returns false if not in the cache.">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" type="string" required="yes" hint="The url to purge from the cache.">
		<!--- ******************************************************************************** --->
		<cfset var results = false>
		<cfset var cacheFile = getCacheLocation() & getSetting("OSFileSeparator",true) & URLToCacheKey(arguments.feedURL)>
		
		<!--- Lock and get Files and Remove. --->		
		<cflock name="#getLockName()#" type="exclusive" timeout="30" throwontimeout="true">
			<!--- Is feed Cached check --->
			<cfif isFeedCached(arguments.feedURL)>
				<!--- Now remove it. --->
				<cffile action="delete" file="#cacheFile#.xml">
				<cfset results = true>
			</cfif>
		</cflock>
		
		<cfreturn results>
	</cffunction>
	
	<!--- Get Feed From Cache --->
	<cffunction name="getCachedFeed" output="false" access="public" returntype="any" hint="Get the contents of a feed from the cache, if not found, it returns a blank structure. (This method does NOT timeout or expire the feeds, that is done by the readFeed method ONLY)">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" type="string" required="yes" hint="The url to check if its in the cache.">
		<!--- ******************************************************************************** --->
		<cfset var results = structNew()>
		<cfset var cacheFile = getCacheLocation() & getSetting("OSFileSeparator",true) & URLToCacheKey(arguments.feedURL)>
		<cfset var fileIn = "">
		<cfset var objectIn = "">
		
		<!--- Secure Cache Read. --->
		<cflock name="#getLockName()#" type="exclusive" timeout="30" throwontimeout="true">
			<cfif isFeedCached(arguments.feedURL)>
				<cfset fileIn = CreateObject("java","java.io.FileInputStream").init('#cacheFile#.xml')>
				<cfset objectIn = CreateObject("java","java.io.ObjectInputStream").init(fileIn)>
				<cfset results = objectIn.readObject()>
				<cfset objectIn.close()>
			</cfif>
		</cflock>
		
		<cfreturn results>
	</cffunction>
	
	<!--- Set Feed into the Cache --->
	<cffunction name="setCachedFeed" output="false" access="public" returntype="void" hint="Set a new feed contents into the feed cache.">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" 		type="string" required="yes" hint="The feed url to store in the cache.">
		<cfargument name="feedStruct" 	type="any" 	  required="yes" hint="The contents of the feed to cache">
		<!--- ******************************************************************************** --->
		<cfset var cacheKey = URLToCacheKey(arguments.feedURL)>
		<cfset var cacheFile = getCacheLocation() & getSetting("OSFileSeparator",true) & cacheKey >
		<cfset var fileOut = "">
		<cfset var objectOut = "">
		
		<!--- Secure Cache Write. --->
		<cflock name="#getLockName()#" type="exclusive" timeout="30" throwontimeout="true">
			<cfset fileOut = CreateObject("java","java.io.FileOutputStream").init('#cacheFile#.xml')>
			<cfset objectOut = CreateObject("java","java.io.ObjectOutputStream").init(fileOut)>
			<cfset objectOut.writeObject(arguments.feedStruct)>
			<cfset objectOut.close()>
		</cflock>
	</cffunction>
	
<!---------------------------------------- PUBLIC RSS METHODS --------------------------------------------------->
	
	<cffunction name="readFeed" access="public" returntype="struct" hint="Read a feed from http or from local cache. Return a universal structure representation of the feed.">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" 		type="string" required="yes" hint="The feed url to parse or retrieve from cache.">
		<cfargument name="itemsType" 	type="string" required="false" default="query" hint="The type of the items either query or Array. Query is by default."/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var FeedStruct = structnew();
			/* Check if using cache */
			if( not getUseCache() ){
				throw("You are tying to use a method that needs caching enabled.","Please look at the plugin's settings or just use the 'retrieveFeed' method.","rss.rssReader.InvalidSettingException");
			}
			/* Check for itemsType */
			if( not reFindnocase("^(query|array)$",arguments.itemsType) ){
				arguments.itemsType = "query";
			}
			
			/* Try to expire a feed, custom reap*/
			expireCachedFeed(arguments.feedURL);
			
			/* Check if its still cached */
			if( isFeedCached(arguments.feedURL) ){
				FeedStruct = getCachedFeed(arguments.feedURL);
			}
			else{
				/* We need to do the entire deal */
				FeedStruct = retrieveFeed(arguments.feedURL,arguments.itemsType);
				/* Set in Cache */
				setCachedFeed(arguments.feedURL,FeedStruct);
			}
			
			/* Return Feed */
			return FeedStruct;
		</cfscript>
	</cffunction>

	<!--- ******************************************************************************** --->

	<cffunction name="retrieveFeed" access="public" returntype="struct" hint="This method does a cfhttp call on the feed url and returns a universal parsed feed structure. You can use this if you don't even want to use the caching facilities.">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" 		type="string" required="yes" hint="The url to retrieve the feed from.">
		<cfargument name="itemsType" 	type="string" required="false" default="query" hint="The type of the items either query or Array. Query is by default."/>
		<!--- ******************************************************************************** --->
		<cfset var xmlDoc = "">
		<cfset var feedResult = structnew()>
		
		<!--- Check for Return Type --->
		<cfif not reFindnocase("^(query|array)$",arguments.itemsType)>
			<cfset arguments.itemsType = "query">
		</cfif>
			
		<!--- Replace protocols --->
		<cfset arguments.feedURL = ReplaceNoCase(arguments.feedURL,"feed://","http://")>

		<!--- Retrieve Feed --->
		<cfhttp method="get" url="#arguments.feedURL#" 
				resolveurl="yes" 
				redirect="yes" 
				timeout="#gethttpTimeout()#" 
				result="feedResult" 
				useragent="Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.0.2) Gecko/20060308 Firefox/1.5.0.2">
			<!--- IIS bug, hack --->
			<cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0">
			<cfhttpparam type="Header" name="TE" value="deflate;q=0">
		</cfhttp>
		
		<cftry>
			<!--- Try to xml parse the document --->
			<cfset xmlDoc = XMLParse(trim(feedResult.FileContent))>
			
			<cfcatch type="any">
				<cfthrow type="rss.rssReader.FeedParsingException"
						 message="Error parsing the feed into an XML document. Please verify that the feed is correct and valid"
						 detail="The returned cfhttp content is: #feedResult.fileContent.toString()#">
			</cfcatch>
		</cftry>
		
		<!--- Validate If its an Atom or RSS feed --->
		<cfif not structKeyExists(xmlDoc,"rss") and not structKeyExists(xmlDoc,"feed")>
			<cfthrow type="rss.rssReader.FeedParsingException"
					 message="Cannot continue parsing the feed since it does not seem to be a valid RSS or ATOM feed. Please verify that the feed is correct and valid"
					 detail="The xmldocument is: #htmlEditFormat(toString(xmlDoc))#">
		</cfif>
		
		<!--- Return a universal parsed structure --->
		<cfreturn parseFeed(xmlDoc,arguments.itemsType)>
	</cffunction>

	<!--- ******************************************************************************** --->

	<cffunction name="isDateISO8601" access="public" returntype="boolean" hint="Checks if a date is in ISO8601 Format" output="false" >
		<cfargument name="datetime" required="true" type="string" hint="The datetime string to check">
		<cfscript>
			if( REFind("[[:digit:]]T[[:digit:]]", arguments.datetime) )
				return true;
			else
				return false;
		</cfscript>
	</cffunction>

<!---------------------------------------- PRIVATE --------------------------------------------------->

	<cffunction name="parseFeed" access="private" returntype="struct" hint="This parses a feed as an xml doc and returns it as a structure of elements.">
		<!--- ******************************************************************************** --->
		<cfargument name="xmlDoc" type="xml" required="yes" hint="The xmldoc to parse.">
		<cfargument name="itemsType" 	type="string" required="false" default="query" hint="The type of the items either query or Array. Query is by default."/>
		<!--- ******************************************************************************** --->
		<cfset var feed = StructNew()>
		<cfset var isRSS1 = false>
		<cfset var isRSS2 = false>
		<cfset var isAtom = false>
		<cfset var x = 1>

		<cfscript>
			/* Set the elements */
			feed.title = "";
			feed.description = "";
			feed.link = "";
			feed.author = "";
			feed.authoremail = "";
			feed.authorurl = "";
			feed.date = "";
			feed.dateupdated = "";
			/* RSS image. */
			feed.image = StructNew();
			feed.image.url = "";
			feed.image.title = "";
			feed.image.link = "##";
					
			// get feed type
			isRSS1 = StructKeyExists(xmlDoc.xmlRoot,"item");
			isRSS2 = StructKeyExists(xmlDoc.xmlRoot,"channel") and StructKeyExists(xmlDoc.xmlRoot.channel,"item");
			isAtom = StructKeyExists(xmlDoc.xmlRoot,"entry");
			
			// get Content by Type
			if(isRSS1 or isRSS2) {
				/* Parse Items */
				if(isRSS1) feed.items = parseRSSItems(xmlDoc.xmlRoot.item,arguments.itemsType);
				if(isRSS2) feed.items = parseRSSItems(xmlDoc.xmlRoot.channel.item,arguments.itemsType);
				
				/* Parse Title */
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"title")) feed.Title = xmlDoc.xmlRoot.channel.title.xmlText;
				/* Parse Description */
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"description")) feed.Description = xmlDoc.xmlRoot.channel.description.xmlText;
				/* Link */
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"link")) feed.Link = xmlDoc.xmlRoot.channel.link.xmlText;
				/* Author Info */
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"webMaster"))
					feed.author = xmlDoc.xmlRoot.channel.webMaster.xmlText;
				else if(StructKeyExists(xmlDoc.xmlRoot.channel,"managingEditor"))
					feed.author = xmlDoc.xmlRoot.channel.managingEditor.xmlText;
				/* Author Email */			
				if( find("@",feed.author) ) feed.authorEmail = feed.author;
				/* Date & Date Updated */
				feed.Date = findCreatedDate(xmlDoc.xmlRoot.channel);
				if( isDateISO8601(feed.Date) ) feed.Date = parseISO8601(feed.Date);
				else feed.Date = parseRFC822(feed.Date);
				feed.DateUpdated = findUpdatedDate(xmlDoc.xmlRoot.channel);
				if( isDateISO8601(feed.DateUpdated) ) feed.DateUpdated = parseISO8601(feed.DateUpdated);
				else feed.DateUpdated = parseRFC822(feed.DateUpdated);
				/* Image */
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"image")) {
					if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"url")) feed.Image.URL = xmlDoc.xmlRoot.channel.image.url.xmlText;
					if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"title")) feed.Image.Title = xmlDoc.xmlRoot.channel.image.title.xmlText;
					if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"link")) feed.Image.Link = xmlDoc.xmlRoot.channel.image.link.xmlText;
				}
			}//end if rss 1 or 2
			else if(isAtom) {
				/* Parse Items */
				feed.items = parseAtomItems(xmlDoc.xmlRoot.entry,arguments.itemsType);
				/* Title */
				if(StructKeyExists(xmlDoc.xmlRoot,"title"))	feed.Title = normalizeAtomTextConstruct(xmlDoc.xmlRoot.title);				
				/* Feed Description */
				if(StructKeyExists(xmlDoc.xmlRoot,"info")) 
					feed.Description =normalizeAtomTextConstruct(xmlDoc.xmlRoot.info);
				else if(StructKeyExists(xmlDoc.xmlRoot,"subtitle")) 
					feed.Description = normalizeAtomTextConstruct(xmlDoc.xmlRoot.subtitle);
				else if(StructKeyExists(xmlDoc.xmlRoot,"tagline")) 
					feed.Description = normalizeAtomTextConstruct(xmlDoc.xmlRoot.tagline);
				/* Link, we only want rel=alternate */
				if(StructKeyExists(xmlDoc.xmlRoot,"link")){
					for(x=1; x lte arrayLen(xmlDoc.xmlRoot.link); x=x+1){
						if( xmlDoc.xmlRoot.link[x].XMLAttributes.rel is "alternate")
							feed.Link = xmlDoc.xmlRoot.link[x].xmlAttributes.href;
					}
				}
				/* Author Information */
				if(structKeyExists(xmlDoc.xmlRoot,"author")){
					if( structKeyExists(xmlDoc.xmlRoot.author,"name") ) feed.author = xmlDoc.xmlRoot.author.name.xmlText;
					if( structKeyExists(xmlDoc.xmlRoot.author,"uri") ) feed.authorURL = xmlDoc.xmlRoot.author.uri.xmlText;
					if( structKeyExists(xmlDoc.xmlRoot.author,"email") ) feed.authorEmail = xmlDoc.xmlRoot.author.email.xmlText;
				}	
				/* Feed Date */
				feed.Date = parseISO8601(findCreatedDate(xmlDoc.xmlRoot));
				feed.DateUpdated = parseISO8601(findUpdatedDate(xmlDoc.xmlRoot));
			}
			/* Return the feed struct */
			return feed;
		</cfscript>
	</cffunction>

	<!--- ******************************************************************************** --->
	
	<!--- Parse Atom Items --->
	<cffunction name="parseAtomItems" access="private" returntype="any" hint="Parse the items an return an array of structures" output="false" >
		<!--- ******************************************************************************** --->
		<cfargument name="items" required="true" type="any" hint="The xml of items">
		<cfargument name="itemsType" 	type="string" required="false" default="query" hint="The type of the items either query or Array. Query is by default."/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var x = 1;
			var y = 1;
			var itemLength = arrayLen(arguments.items);
			var rtnItems = "";
			var node = "";
			
			/* Correct Return Items Type*/
			if( arguments.itemsType eq "array")
				rtnItems = ArrayNew(1);
			else
				rtnItems = QueryNew("Title,Description,Link,Date,DateUpdated,Enclosure");
			
			/* Loop and add to array */
			for(x=1; x lte itemLength; x=x + 1){
				/* new node */
				node = structnew();
				/* Basic Node */
				node.title = "";
				node.link = "";
				node.enclosure = "";	
				node.description = "";
				node.date = "";	
				node.DateUpdated = "";
				/* Get Title */
				if( structKeyExists(items[x],"title") ) node.title = normalizeAtomTextConstruct(items[x].title);
				/* Description, prefers content over summary */
				if ( structKeyExists(items[x],"content") ) 
					node.description = normalizeAtomTextConstruct(items[x].content);
				else if( structKeyExists(items[x],"summary") ){
					node.description = normalizeAtomTextConstruct(items[x].summary);
				}
				/* Get Links */	
				if( structKeyExists(items[x],"link") ){
					for(y=1; y lte arrayLen(items[x].link);y=y+1){
						if ( items[x].link[y].xmlAttributes.rel is "alternate"){
							node.link = items[x].link[y].xmlAttributes.href;
						}
						else if ( items[x].link[y].xmlAttributes.rel is "enclosure" ){
							node.enclosure = items[x].link[y].xmlAttributes.href;
						}
					}//end for loop of links
				}//if there are any links.
				/* Date and Updated Dates */
				node.Date = parseISO8601(findCreatedDate(items[x]));
				node.DateUpdated = parseISO8601(findUpdatedDate(items[x]));
				
				if( arguments.itemsType eq "array" ){
					/* Append to Array */
					ArrayAppend(rtnItems,node);
				}
				else{
					QueryAddRow(rtnItems,1);
					QuerySetCell(rtnItems, "Title", node.Title);
					QuerySetCell(rtnItems, "Description", node.Description);
					QuerySetCell(rtnItems, "Link", node.Link);
					QuerySetCell(rtnItems, "Date", node.date);
					QuerySetCell(rtnItems, "DateUpdated", node.dateUpdated);
					QuerySetCell(rtnItems, "Enclosure", node.Enclosure);
				}
			}//end of for loop 
		
		/* Return items */
		return rtnItems;
		</cfscript>
	</cffunction>
	
	<!--- Parse rss items --->
	<cffunction name="parseRSSItems" access="private" returntype="any" hint="Parse the items an return an array of structures" output="false" >
		<!--- ******************************************************************************** --->
		<cfargument name="items" required="true" type="any" hint="The xml of items">
		<cfargument name="itemsType" 	type="string" required="false" default="query" hint="The type of the items either query or Array. Query is by default."/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var x = 1;
			var itemLength = arrayLen(arguments.items);
			var rtnItems = "";
			var node = "";
			
			/* Correct Return Items Type*/
			if( arguments.itemsType eq "array")
				rtnItems = ArrayNew(1);
			else
				rtnItems = QueryNew("Title,Description,Link,Date,DateUpdated,Enclosure");
				
			/* Loop and add to array */
			for(x=1; x lte itemLength; x=x + 1){
				/* new node */
				node = structnew();
				
				/* Basic Node */
				node.title = "";
				node.description = "";
				node.link = "";
				node.date = "";	
				node.DateUpdated = "";
				node.enclosure = "";	
				
				/* Get Title */
				if( structKeyExists(items[x],"title") ) node.title = items[x].title.xmlText;
				/* Get Description */
				if( structKeyExists(items[x],"description") ) node.description = items[x].description.xmlText;
				/* Get Link */
				if ( structKeyExists(items[x],"guid") and (not structKeyExists(items[x].guid.xmlAttributes, "isPermaLink") or items[x].guid.xmlAttributes.isPermaLink) ){
					node.link = items[x].guid.XmlText;
				}
				else if ( structKeyExists(items[x],"link") ){
					node.link = items[x].link.XmlText;
				}
				else if ( structKeyExists(items[x],"source") and structKeyExists(items[x].source.XmlAttributes,"url") ){
					node.link = items[x].source.XmlAttributes.url;
				}
				/* Date and Updated Dates */
				node.Date = findCreatedDate(items[x]);
				if( isDateISO8601(node.Date) ) node.Date = parseISO8601(node.Date);
				else node.Date = parseRFC822(node.Date);
				node.DateUpdated = findUpdatedDate(items[x]);
				if( isDateISO8601(node.DateUpdated) ) node.DateUpdated = parseISO8601(node.DateUpdated);
				else node.DateUpdated = parseRFC822(node.DateUpdated);
				
				
				/* Enclosure */
				if( structKeyExists(items[x],"enclosure") and structKeyExists(items[x].enclosure.XmlAttributes,"url") ){
					node.enclosure = items[x].enclosure.XmlAttributes.url;
				}
				
				if( arguments.itemsType eq "array" ){
					/* Append to Array */
					ArrayAppend(rtnItems,node);
				}
				else{
					QueryAddRow(rtnItems,1);
					QuerySetCell(rtnItems, "Title", node.Title);
					QuerySetCell(rtnItems, "Description", node.Description);
					QuerySetCell(rtnItems, "Link", node.Link);
					QuerySetCell(rtnItems, "Date", node.Date);
					QuerySetCell(rtnItems, "DateUpdated", node.DateUpdated);
					QuerySetCell(rtnItems, "Enclosure", node.Enclosure);
				}
						
			}//end of for loop 	
		/* Return items */
		return rtnItems;
		</cfscript>
	</cffunction>
	
	<!--- readCacheDir --->
	<cffunction name="readCacheDir" output="false" access="private" returntype="query" hint="Read the cahe directory using a filter.">
		<!--- ******************************************************************************** --->
		<cfargument name="filter" type="string" required="false" default="*" hint="The file filter to use if sent, else * is default"/>
		<!--- ******************************************************************************** --->
		<cfset var qFiles = "">
		<!--- Get Directory Listing --->
		<cfdirectory directory="#getCacheLocation()#" action="list" name="qFiles" filter="#arguments.filter#.xml">
		<cfreturn qFiles>
	</cffunction>
	
	<!--- URL to cache Key --->
	<cffunction name="URLToCacheKey" output="false" access="private" returntype="string" hint="Convert a url to a cache key representation">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" type="string" required="yes" hint="The feed url to parse or retrieve from cache.">
		<!--- ******************************************************************************** --->
		<cfscript>
			return hash( lcase(trim(arguments.feedURL)) );
		</cfscript>
	</cffunction>
	
	<!--- Normalize an Atom Text Construct --->
	<cffunction name="normalizeAtomTextConstruct" access="private" output="false" returntype="string" hint="Send an element and it will return the appropriate text construct.">
  		<cfargument name="entity" required="true" hint="The xml construct" />
		<cfscript>
			var results = "";
			var x = 1;
			/* Check for type */
			if( structKeyExists(arguments.entity.xmlAttributes,"type") ){
				if( arguments.entity.xmlAttributes.type is "html" or arguments.entity.xmlAttributes.type is "text"){
					results = arguments.entity.xmlText;
				}
				else if( arguments.entity.xmlAttributes.type is "xhtml" ){
					if( not structKeyExists(arguments.entity,"div") ){
						throw("Invalid Atom: XHTML Text construct does not contain a child div.",'','rss.rssReader.InvalidAtomConstruct');	
					}
					for(x=1;x lte ArrayLen(arguments.entity.xmlChildren);x=x+1){
						results = results & arguments.entity.xmlChildren[x].toString();
					}
				}
			}//end type exists
			else{
				/* No type, just return text */
				results = arguments.entity.xmlText;
			}
			/* Return results */
			return results;
		</cfscript>
	</cffunction>
	
	
	<!--- Get Created Date --->
	<cffunction name="findCreatedDate" access="private" output="false" returntype="string" hint="Parse the doc and find a created date">
		<!--- ******************************************************************************** --->
		<cfargument name="xmlRoot" type="xml" required="true" hint="The xml root to look in"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var updatedDate = "";
			if(StructKeyExists(arguments.xmlRoot,"lastBuildDate")) 
				updatedDate = arguments.xmlRoot.lastBuildDate.xmlText;
			else if(StructKeyExists(arguments.xmlRoot,"modified"))
				updatedDate = arguments.xmlRoot.modified.xmlText;
			else if(StructKeyExists(arguments.xmlRoot,"updated"))
				updatedDate = arguments.xmlRoot.updated.xmlText;	
			return updatedDate;
		</cfscript>
	</cffunction>
	
	<!--- Get Updated Date --->
	<cffunction name="findUpdatedDate" access="private" output="false" returntype="string" hint="Parse the doc and find a updated date">
		<!--- ******************************************************************************** --->
		<cfargument name="xmlRoot" type="xml" required="true" hint="The xml root to look in"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var createdDate = "";
			if(StructKeyExists(arguments.xmlRoot,"pubDate")) 
				createdDate = arguments.xmlRoot.pubDate.xmlText;
			else if(StructKeyExists(arguments.xmlRoot,"dc:date"))
				createdDate = arguments.xmlRoot["dc:date"].xmlText;
			else if(StructKeyExists(arguments.xmlRoot,"issued"))
				createdDate = arguments.xmlRoot.issued.xmlText;
			else if(StructKeyExists(arguments.xmlRoot,"created"))
				createdDate = arguments.xmlRoot.created.xmlText;
			else if(StructKeyExists(arguments.xmlRoot,"published"))
				createdDate = arguments.xmlRoot.published.xmlText;	
			return createdDate;
		</cfscript>
	</cffunction>
	
	<!--- Parse ISO8601 Dates --->
	<cffunction name="parseISO8601" access="private" output="false" returntype="string" hint="Parse a UTC or iso8601 date to a normal CF datetime object">
		<!--- ******************************************************************************** --->
		<cfargument name="datetime" type="string" required="true" hint="The datetime string to convert"/>
		<!--- ******************************************************************************** --->
		<cfset var returnDate = arguments.datetime>
		<cfset var datebits = structnew()>
		<cfset var roundedSeconds = "00">
		<cfset var wddxPacket = "">
		
		<!--- Date Bits Initialization --->
		<cfset datebits.main = returnDate>
		<cfset datebits.offset = "">
		
		<!--- Parse if its an ISO Date --->
		<cfif REFind("[[:digit:]]T[[:digit:]]", datebits.main)>
			<cfscript>
			/* Test for Z */
			if( datebits.main contains "Z" ){
				/* Set Offset to 0 and replace the Z with nothing. */
				datebits.offset = "+00:00";
				datebits.main = replace(arguments.datetime, "Z", "", "ONE");
			}			
			/* test for containz + */
			else if( datebits.main contains "+"){
				/* Split offset and remove it from main datetime */
				datebits.offset = "+" & ListLast(datebits.main,"+");
				datebits.main = replace(datebits.main,datebits.offset,"","ONE");
			}				
			else{
				/* Split negative offset and remove it from main datetime */
				datebits.offset = "-" & ListLast(datebits.main,"-");
				datebits.main = replace(datebits.main,datebits.offset,"","ONE");
			}
			/* If no seconds, add them */
			if( listLen(datebits.main, ":") lt 3){
				datebits.main = datebits.main & ":00";
			}	
			/* If it has fractional seconds, round it up. BIG DEAL!! */
			roundedSeconds = numberFormat(round(listLast(datebits.main,":")),"00");
			datebits.main =	listSetAt(datebits.main, listLen(datebits.main,":"), roundedSeconds,":");
			/* Append All */
			datebits.main = datebits.main & datebits.offset;
			
			/* Wddx hack to get a datetime object */
			wddxPacket = "<wddxPacket version='1.0'><header/><data><dateTime>#datebits.main#</dateTime></data></wddxPacket>";
			</cfscript>
			<!--- WDDX Hack --->
			<cfwddx action="wddx2cfml" input="#wddxPacket#" output="wddxPacket" />
			<cfset returnDate = DateConvert("local2utc", wddxPacket) />
		</cfif>	
			
		<!--- Return the date --->
		<cfreturn returnDate>
	</cffunction>
	
	<!--- Parse ISO8601 Dates --->
	<cffunction name="parseRFC822" access="private" output="false" returntype="string" hint="Parse RFC822 dates, returns empty string if not a valid date.">
		<!--- ******************************************************************************** --->
		<cfargument name="datetime" type="string" required="true" hint="The datetime string to convert"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var formatter = CreateObject("java", "java.text.SimpleDateFormat").init("EEE, dd MMM yyyy HH:mm:ss Z");
			var parsePosition = CreateObject("java", "java.text.ParsePosition").init(0);
			var results = arguments.datetime;	
					
			/* Parse the date */
			if( len(arguments.datetime) neq 0 )
				results = formatter.parse(arguments.datetime, parsePosition);
			
			/* Null Check */
			if( isDefined("results") ){
				return results;
			}else
				return arguments.datetime;
		</cfscript>
	</cffunction>
	
	<!--- GET/SET Lock Name --->
	<cffunction name="getlockName" access="private" returntype="string" output="false" >
		<cfreturn instance.lockName>
	</cffunction>
	<cffunction name="setlockName" access="private" returntype="void" output="false">
		<cfargument name="lockName" type="string" required="true">
		<cfset instance.lockName = arguments.lockName>
	</cffunction>

<!---------------------------------------- ACCESSOR/MUTATORS --------------------------------------------------->

	<!--- Cache Timeout --->
	<cffunction name="getcacheTimeout" access="public" returntype="numeric" output="false" hint="The cache timeout in minutes">
		<cfreturn instance.cacheTimeout>
	</cffunction>
	<cffunction name="setcacheTimeout" access="public" returntype="void" output="false" hint="Set the cache timeout in minutes">
		<cfargument name="cacheTimeout" type="numeric" required="true">
		<cfset instance.cacheTimeout = arguments.cacheTimeout>
	</cffunction>

	<!--- Cache Location --->
	<cffunction name="getcacheLocation" access="public" returntype="string" output="false" hint="The cache location (absolute path)">
		<cfreturn instance.cacheLocation>
	</cffunction>
	<cffunction name="setcacheLocation" access="public" returntype="void" output="false" hint="The cache location (absolute path)">
		<cfargument name="cacheLocation" type="string" required="true">
		<cfset instance.cacheLocation = arguments.cacheLocation>
	</cffunction>
	
	<!--- The http timeout --->
	<cffunction name="gethttpTimeout" access="public" returntype="numeric" output="false" hint="The http timeout in seconds">
		<cfreturn instance.httpTimeout>
	</cffunction>
	<cffunction name="sethttpTimeout" access="public" returntype="void" output="false" hint="Set the http timeout in seconds">
		<cfargument name="httpTimeout" type="numeric" required="true">
		<cfset instance.httpTimeout = arguments.httpTimeout>
	</cffunction>

	<!--- using Cache --->
	<cffunction name="getuseCache" access="public" returntype="boolean" output="false" hint="Whether using file cache or not.">
		<cfreturn instance.useCache>
	</cffunction>
	<cffunction name="setuseCache" access="public" returntype="void" output="false" hint="Set whether to use file caching or not">
		<cfargument name="useCache" type="boolean" required="true">
		<cfset instance.useCache = arguments.useCache>
	</cffunction>
		
</cfcomponent>