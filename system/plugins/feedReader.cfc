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
	- feedReader_useCache 		: boolean [default=true] (Use the file cache or not)
	- feedReader_cacheType		: string (ram,file) (Default is ram)
	- feedReader_cacheLocation 	: string (Where to store the file caching, relative to the app or absolute)
	- feedReader_cacheTimeout 	: numeric [default=30] (In minutes, the timeout of the file cache)
	- feedReader_httpTimeout 	: numeric [default=30] (In seconds, the timeout of the cfhttp call)
	
RSS Retrieval Methods:
	- readFeed( feedURL, itemsType[default=query] ) : Retrieve a feed from cfhttp, parse, cache, and return results in query or array format.
	- retrieveFeed( feedURL, itemsType[default=query] ) : Retrieve a feed from cfhttp, parse, and return results in query or array format.
	- parseFeed( xmlDoc, itemsType[default=query] ) : Parse a feed xml document into the normalized struct.
	
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
<cfcomponent name="feedReader" 
			 extends="coldbox.system.plugin"
			 hint="A rss reader plugin. We recommend that when you call the readFeed method, that you use url's as settings. ex: readFeed(getSetting('myFeedURL')).  The settings this plugin uses are the following: feedReader_useCache:boolean [default=true], feedReader_cacheLocation:string, feedReader_cacheTimeout:numeric [default=30 min], feedReader_httpTimeout:numeric [default=30 sec]. If the cacheLocation directory does not exits, the plugin will throw an error. So please remember to create the directory."
			 cache="true">

<!---------------------------------------- CONSTRUCTOR --------------------------------------------------->

	<cffunction name="init" access="public" returntype="feedReader" output="false" hint="Plugin Constructor.">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			var cacheLocation = "";
			var slash = "";
			
			/* Super */
			super.Init(arguments.controller);
			
			/* Plugin Properties */
			setpluginName("feedReader");
			setpluginVersion("1.0");
			setpluginDescription("I am a rss feed reader for rss and atom feeds.");
			
			/* Check if using Cache and set useCache setting */
			if( not settingExists('feedReader_useCache') or not isBoolean(getSetting('feedReader_useCache')) ){
				setUseCache(true);
			}else{
				setUseCache(getSetting('feedReader_useCache'));
			}
			
			/* Setup Caching variables if using it */
			if( getUseCache() ){	
				
				/* ram caching? used by default */
				if( not settingExists('feedReader_cacheType') or not reFindNoCase("^(ram|file)$",getSetting('feedReader_cacheType')) ){
					setCacheType('ram');
				}
				else{
					setCacheType(getSetting('feedReader_cacheType'));
				}
				
				/* file caching? */
				if( getCacheType() eq "file" ){
					/* Cache prefix */
					setCachePrefix('');
					/* File Separator */
					slash = getSetting("OSFileSeparator",true);
					/* Cache Location */
					if( not settingExists('feedReader_cacheLocation') ){
						$throw(message="The Setting feedReader_cacheLocation is missing. Please create it.",type='plugins.feedReader.InvalidSettingException');
					}
					/* Tests if the directory exists: Full Path */
					/* Try to locate the path */
					cacheLocation = locateDirectoryPath(getSetting('feedReader_cacheLocation'));
					/* Validate it */
					if( len(cacheLocation) eq 0 ){
						$throw('The cache location directory could not be found. Please check again. #getSetting('feedReader_cacheLocation')#','','plugins.feedReader.InvalidCacheLocationException');
					}
					/* Set the location */
					setCacheLocation(cacheLocation);
				}//end if cahce eq file
				else{
					/* Ram Cache */
					setCachePrefix('rssreader-');
				}		
				
				/* Cache Timeout */
				if( not settingExists('feedReader_cacheTimeout') ){
					setCacheTimeout(30);
				}
				else{
					setCacheTimeout(getSetting('feedReader_cacheTimeout'));
				}
			}//end else using cache
			
			/* HTTP Timeout */
			if( not settingExists('feedReader_httpTimeout') ){
				sethttpTimeout(30);
			}
			else{
				sethttpTimeout(getSetting('feedReader_httpTimeout'));
			}
			
			/* Set The lock Name */
			setLockName('feedReaderCacheOperation');
			
			/* Return instance */
			return this;
		</cfscript>
	</cffunction>

<!---------------------------------------- INTERNAL CACHE OPERATIONS --------------------------------------------------->
	
	<!--- flushCache --->
	<cffunction name="flushCache" output="false" access="public" returntype="void" hint="Flushes the entire file cache. Removes all entries">
		<cfset var qFiles = "">
		<cfset var slash = getSetting("OSFileSeparator",true)>
		
		<cfif getCacheType() eq "ram">
			<cfset getColdboxOCM().clearByKeySnippet(getCachePrefix)>
		<cfelse>
			<!--- Lock and get Files and Remove. --->		
			<cflock name="#getLockName()#" type="exclusive" timeout="30" throwontimeout="true">
				<cfset qFiles = readCacheDir()>
				<!--- Recursively Delete --->
				<cfloop query="qFiles">
					<!--- Delete File --->
					<cffile action="delete" file="#qFiles.directory##slash##qFiles.name#">
				</cfloop>
			</cflock>
		</cfif>
	</cffunction>
	
	<!--- How many elements in Cache --->
	<cffunction name="getCacheSize" output="false" access="public" returntype="numeric" hint="Returns the number of elements in the cache directory. Only used for file caching.">
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
		
		<cfif getCacheType() eq "ram">
			<cfreturn getColdboxOCM().lookup(URLToCacheKey(arguments.feedURL))>
		<cfelse>
			<!--- Secure Cache Read. --->
			<cflock name="#getLockName()#" type="readonly" timeout="30" throwontimeout="true">
				<!--- Check if feed is in cache. --->
				<cfif readCacheDir(filter=URLToCacheKey(arguments.feedURL)).recordcount neq 0>
					<cfset results = true>
				</cfif>
			</cflock>
		</cfif>
		
		<cfreturn results>
	</cffunction>
	
	<!--- Checks if the feed has expired or not --->
	<cffunction name="isFeedExpired" output="false" access="public" returntype="boolean" hint="Checks if a feed has expired or not. If the feed does not exist, it will throw an error.">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" type="string" required="yes" hint="The url to check if its in the cache.">
		<!--- ******************************************************************************** --->
		<cfset var results = false>
		<cfset var qFile = "">
		
		<cfif getCacheType() eq "ram">
			<cfreturn getColdboxOCM().lookup(URLToCacheKey(arguments.feedURL))>
		<cfelse>
			<!--- Secure Cache Read. --->
			<cflock name="#getLockName()#" type="readonly" timeout="30" throwontimeout="true">
				<!--- Check if feed is in cache. --->
				<cfset qFile = readCacheDir(filter=URLToCacheKey(arguments.feedURL))>			
			</cflock>
			<!--- Exists Check --->
			<cfif qFile.recordcount eq 0>
				<cfthrow message="The feed does not exist in the cache." type="customPlugins.plugins.feedReader">
			</cfif>
			<!--- Timeout Check --->
			<cfif DateDiff("n", qFile.dateLastModified, now()) gt getCacheTimeout()>
				<cfset results = true>					
			</cfif>	
		</cfif>
		
		<cfreturn results>
	</cffunction>
	
	<!--- Checks if the feed has expired or not --->
	<cffunction name="expireCachedFeed" output="false" access="public" returntype="void" hint="If the feed exists and it has expired, it removes it, else nothing.">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" type="string" required="yes" hint="The url to check if its in the cache.">
		<!--- ******************************************************************************** --->
		<cfscript>
			var results = false;
			var qFile = "";
			
			/* only expire if using file cache, ram is done by CB */
			if( getCacheType() eq "file"){
				qFile = readCacheDir(filter=URLToCacheKey(arguments.feedURL));
				/* Exists Check */
				if ( qFile.recordcount gt 0 and DateDiff("n", qFile.dateLastModified, now()) gt getCacheTimeout() ){
					removeCachedFeed(arguments.feedURL);
				}
			}
		</cfscript>
	</cffunction>
	
	<!--- flushCache --->
	<cffunction name="removeCachedFeed" output="false" access="public" returntype="boolean" hint="Purges/removes a feed from the cache, returns false if not in the cache.">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" type="string" required="yes" hint="The url to purge from the cache.">
		<!--- ******************************************************************************** --->
		<cfset var results = false>
		<cfset var cacheFile = "">
		
		<cfif getCacheType() eq "ram">
			<cfreturn getColdboxOCM().clearKey(URLToCacheKey(arguments.feedURL))>
		<cfelse>
			<!--- Cache File --->
			<cfset cacheFile = getCacheLocation() & getSetting("OSFileSeparator",true) & URLToCacheKey(arguments.feedURL)>
			<!--- Lock and get Files and Remove. --->		
			<cflock name="#getLockName()#" type="exclusive" timeout="30" throwontimeout="true">
				<!--- Is feed Cached check --->
				<cfif isFeedCached(arguments.feedURL)>
					<!--- Now remove it. --->
					<cffile action="delete" file="#cacheFile#.xml">
					<cfset results = true>
				</cfif>
			</cflock>
		</cfif>
		
		<cfreturn results>
	</cffunction>
	
	<!--- Get Feed From Cache --->
	<cffunction name="getCachedFeed" output="false" access="public" returntype="any" hint="Get the contents of a feed from the cache, if not found, it returns a blank structure. (This method does NOT timeout or expire the feeds, that is done by the readFeed method ONLY)">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" type="string" required="yes" hint="The url to check if its in the cache.">
		<!--- ******************************************************************************** --->
		<cfset var results = structNew()>
		<cfset var cacheFile = "">
		<cfset var fileIn = "">
		<cfset var objectIn = "">
		<cfif getCacheType() eq "ram">
			<cfset results = getColdboxOCM().get(URLToCacheKey(arguments.feedURL))>
		<cfelse>
			<cfset cacheFile = getCacheLocation() & getSetting("OSFileSeparator",true) & URLToCacheKey(arguments.feedURL)>
			<!--- Secure Cache Read. --->
			<cflock name="#getLockName()#" type="exclusive" timeout="30" throwontimeout="true">
				<cfif isFeedCached(arguments.feedURL)>
					<cfif structKeyExists(server,"railo")>
						<cfset results = evaluate(fileRead('#cacheFile#.xml'))>
					<cfelse>
						<cfset fileIn = CreateObject("java","java.io.FileInputStream").init('#cacheFile#.xml')>
						<cfset objectIn = CreateObject("java","java.io.ObjectInputStream").init(fileIn)>
						<cfset results = objectIn.readObject()>
						<cfset objectIn.close()>
					</cfif>	
				</cfif>
			</cflock>
		</cfif>
		
		<cfreturn results>
	</cffunction>
	
	<!--- Set Feed into the Cache --->
	<cffunction name="setCachedFeed" output="false" access="public" returntype="void" hint="Set a new feed contents into the feed cache.">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" 		type="string" required="yes" hint="The feed url to store in the cache.">
		<cfargument name="feedStruct" 	type="any" 	  required="yes" hint="The contents of the feed to cache">
		<!--- ******************************************************************************** --->
		<cfset var cacheKey = URLToCacheKey(arguments.feedURL)>
		<cfset var cacheFile = "">
		<cfset var fileOut = "">
		<cfset var objectOut = "">
		
		<cfif getCacheType() eq "ram">
			<cfset getColdboxOCM().set(cacheKey, feedStruct, getCacheTimeout())>
		<cfelse>
			<cfset cacheFile = getCacheLocation() & getSetting("OSFileSeparator",true) & cacheKey>
			<!--- Secure Cache Write. --->
			<cflock name="#getLockName()#" type="exclusive" timeout="30" throwontimeout="true">
				<cfif structKeyExists(server,"railo")>
					<cfset fileWrite('#cacheFile#.xml', serialize(arguments.feedStruct))>
				<cfelse>
					<cfset fileOut = CreateObject("java","java.io.FileOutputStream").init('#cacheFile#.xml')>
					<cfset objectOut = CreateObject("java","java.io.ObjectOutputStream").init(fileOut)>
					<cfset objectOut.writeObject(arguments.feedStruct)>
					<cfset objectOut.close()>
				</cfif>
			</cflock>
		</cfif>
	</cffunction>
	
<!---------------------------------------- PUBLIC RSS METHODS --------------------------------------------------->
	
	<cffunction name="readFeed" access="public" returntype="struct" hint="Read a feed from http if new or from local cache. Return a universal structure representation of the feed.">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" 		type="string"  required="yes" hint="The feed url to parse or retrieve from cache.">
		<cfargument name="itemsType" 	type="string"  required="false" default="query" hint="The type of the items either query or Array. Query is by default."/>
		<cfargument name="maxItems" 	type="numeric" required="false" default="0" hint="The max number of entries to retrieve, default is all"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var FeedStruct = structnew();
			/* Check if using cache */
			if( not getUseCache() ){
				$throw("You are tying to use a method that needs caching enabled.","Please look at the plugin's settings or just use the 'retrieveFeed' method.","plugins.feedReader.InvalidSettingException");
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
				FeedStruct = retrieveFeed(arguments.feedURL,arguments.itemsType,arguments.maxItems);
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
		<cfargument name="maxItems" 	type="numeric" required="false" default="0" hint="The max number of entries to retrieve, default is all"/>
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
				<cfthrow type="plugins.feedReader.FeedParsingException"
						 message="Error parsing the feed into an XML document. Please verify that the feed is correct and valid"
						 detail="The returned cfhttp content is: #feedResult.fileContent.toString()#">
			</cfcatch>
		</cftry>
		
		<!--- Validate If its an Atom or RSS feed --->
		<cfif not structKeyExists(xmlDoc,"rss") and not structKeyExists(xmlDoc,"feed") and not structKeyExists(xmlDoc,"rdf:RDF")>
			<cfthrow type="plugins.feedReader.FeedParsingException"
					 message="Cannot continue parsing the feed since it does not seem to be a valid RSS or ATOM feed. Please verify that the feed is correct and valid"
					 detail="The xmldocument is: #htmlEditFormat(toString(xmlDoc))#">
		</cfif>
		
		<!--- Return a universal parsed structure --->
		<cfreturn parseFeed(xmlDoc,arguments.itemsType,arguments.maxItems)>
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
	
	<!--- ******************************************************************************** --->

	<cffunction name="parseFeed" access="public" returntype="struct" hint="This parses a feed as an xml doc and returns it as a structure of elements.">
		<!--- ******************************************************************************** --->
		<cfargument name="xmlDoc" 		type="xml" required="yes" hint="The xmldoc to parse and normalize. Must be a coldfusion xml doc object not a string.">
		<cfargument name="itemsType" 	type="string" required="false" default="query" hint="The type of the items either query or Array. Query is by default."/>
		<cfargument name="maxItems" 	type="numeric" required="false" default="0" hint="The max number of entries to retrieve, default is all"/>
		<!--- ******************************************************************************** --->
		<cfset var feed = StructNew()>
		<cfset var isRSS1 = false>
		<cfset var isRSS2 = false>
		<cfset var isAtom = false>
		<cfset var x = 1>
		<cfset var oUtilities = getPlugin("Utilities")>
		
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
				if(isRSS1) feed.items = parseRSSItems(xmlDoc.xmlRoot.item,arguments.itemsType,arguments.maxItems);
				if(isRSS2) feed.items = parseRSSItems(xmlDoc.xmlRoot.channel.item,arguments.itemsType,arguments.maxItems);
				
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
				if( isDateISO8601(feed.Date) ) feed.Date = oUtilities.parseISO8601(feed.Date);
				else feed.Date = oUtilities.parseRFC822(feed.Date);
				feed.DateUpdated = findUpdatedDate(xmlDoc.xmlRoot.channel);
				if( isDateISO8601(feed.DateUpdated) ) feed.DateUpdated = oUtilities.parseISO8601(feed.DateUpdated);
				else feed.DateUpdated = oUtilities.parseRFC822(feed.DateUpdated);
				/* Image */
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"image")) {
					if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"url")) feed.Image.URL = xmlDoc.xmlRoot.channel.image.url.xmlText;
					if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"title")) feed.Image.Title = xmlDoc.xmlRoot.channel.image.title.xmlText;
					if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"link")) feed.Image.Link = xmlDoc.xmlRoot.channel.image.link.xmlText;
				}
			}//end if rss 1 or 2
			else if(isAtom) {
				/* Parse Items */
				feed.items = parseAtomItems(xmlDoc.xmlRoot.entry,arguments.itemsType,arguments.maxItems);
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
				feed.Date = oUtilities.parseISO8601(findCreatedDate(xmlDoc.xmlRoot));
				feed.DateUpdated = oUtilities.parseISO8601(findUpdatedDate(xmlDoc.xmlRoot));
			}
			/* Return the feed struct */
			return feed;
		</cfscript>
	</cffunction>
	
<!---------------------------------------- PRIVATE --------------------------------------------------->
	
	<!--- Parse Atom Items --->
	<cffunction name="parseAtomItems" access="private" returntype="any" hint="Parse the items an return an array of structures" output="false" >
		<!--- ******************************************************************************** --->
		<cfargument name="items" 		type="any" 		required="true" hint="The xml of items">
		<cfargument name="itemsType" 	type="string" 	required="false" default="query" hint="The type of the items either query or Array. Query is by default."/>
		<cfargument name="maxItems" 	type="numeric" 	required="false" default="0" hint="The max number of entries to retrieve, default is all"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var x = 1;
			var y = 1;
			var itemLength = arrayLen(arguments.items);
			var rtnItems = "";
			var node = "";
			var oUtilities = getPlugin("Utilities");
			
			/* Items Length */
			if( arguments.maxItems neq 0 and arguments.maxItems lt itemLength ){
				itemLength = arguments.maxItems;
			}
			
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
				node.Date = oUtilities.parseISO8601(findCreatedDate(items[x]));
				node.DateUpdated = oUtilities.parseISO8601(findUpdatedDate(items[x]));
				/* Verify Dates and make sure both dates are filled up. */
				if( len(node.Date) neq 0 and len(node.DateUpdated) eq 0){
					node.DateUpdated = node.Date;
				}
				else if( len(node.DateUpdated) neq 0 and len(node.Date) eq 0){
					node.Date = node.DateUpdated;
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
		<cfargument name="items" 		type="any" 		required="true" hint="The xml of items">
		<cfargument name="itemsType" 	type="string" 	required="false" default="query" hint="The type of the items either query or Array. Query is by default."/>
		<cfargument name="maxItems" 	type="numeric" 	required="false" default="0" hint="The max number of entries to retrieve, default is all"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var x = 1;
			var itemLength = arrayLen(arguments.items);
			var rtnItems = "";
			var node = "";
			var oUtilities = getPlugin("Utilities");
			
			/* Items Length */
			if( arguments.maxItems neq 0 and arguments.maxItems lt itemLength ){
				itemLength = arguments.maxItems;
			}
			
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
				if( isDateISO8601(node.Date) ){ 
					node.Date = oUtilities.parseISO8601(node.Date);
				}
				else{ 
					node.Date = oUtilities.parseRFC822(node.Date);
				}
				node.DateUpdated = findUpdatedDate(items[x]);
				if( isDateISO8601(node.DateUpdated) ){
					node.DateUpdated = oUtilities.parseISO8601(node.DateUpdated);
				}
				else{
					node.DateUpdated = oUtilities.parseRFC822(node.DateUpdated);
				}
				/* Verify Dates and make sure both dates are filled up. */
				if( len(node.Date) neq 0 and len(node.DateUpdated) eq 0){
					node.DateUpdated = node.Date;
				}
				else if( len(node.DateUpdated) neq 0 and len(node.Date) eq 0){
					node.Date = node.DateUpdated;
				}				
				
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
			var key = hash( lcase(trim(arguments.feedURL)) );
			if( getCacheType() eq "ram"){
				return getCachePrefix() & key;
			}else{
				return key;
			}
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
				if( arguments.entity.xmlAttributes.type is "xhtml" ){
					if( not structKeyExists(arguments.entity,"div") ){
						$throw("Invalid Atom: XHTML Text construct does not contain a child div.",'','plugins.feedReader.InvalidAtomConstruct');	
					}
					for(x=1;x lte ArrayLen(arguments.entity.xmlChildren);x=x+1){
						results = results & arguments.entity.xmlChildren[x].toString();
					}
				}
				else{
					results = arguments.entity.xmlText;
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
	
	<!--- Get/Set cache Type --->
	<cffunction name="getcacheType" access="public" returntype="string" output="false">
		<cfreturn instance.cacheType>
	</cffunction>
	<cffunction name="setcacheType" access="public" returntype="void" output="false">
		<cfargument name="cacheType" type="string" required="true">
		<cfset instance.cacheType = arguments.cacheType>
	</cffunction>
	
	<!--- Get/set cache prefix. --->
	<cffunction name="getcachePrefix" access="public" returntype="string" output="false">
		<cfreturn instance.cachePrefix>
	</cffunction>
	<cffunction name="setcachePrefix" access="public" returntype="void" output="false">
		<cfargument name="cachePrefix" type="string" required="true">
		<cfset instance.cachePrefix = arguments.cachePrefix>
	</cffunction>
		
</cfcomponent>