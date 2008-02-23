<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Luis Majano
Date        :	02/22/2008
License		: 	Apache 2 License
Description :
	A rss reader plugin with file caching capabilities

----------------------------------------------------------------------->
<cfcomponent name="rssReader" 
			 extends="coldbox.system.plugin"
			 hint="A rss manager plugin. We recommend that when you call the readFeed method, that you pass use url's as settings. ex: readFeed(getSetting('myFeedURL')).  The settings this plugin uses are the following: rssManager_useCache:boolean [default=true], rssManager_cacheLocation:string, rssManager_cacheTimeout:numeric [default=30 min], rssManager_httpTimeout:numeric [default=30 sec]. If the cacheLocation directory does not exits, the plugin will throw an error. So please remember to create the directory."
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
			setpluginDescription("I am a rss feed manager");
			
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
					throw(message="The Setting rssReader_cacheLocation is missing. Please create it.",type='customPlugins.rss.rssReader');
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
				else{
					throw('The cache location directory could not be found. Please check again. #getSetting('rssReader_cacheLocation')#','','customPlugins.rss.rssReader');
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
		<cfargument name="feedURL" type="string" required="yes" hint="The feed url to parse or retrieve from cache.">
		<!--- ******************************************************************************** --->
		<cfscript>
			var FeedStruct = structnew();
			
			/* Check if using cache */
			if( not getUseCache() ){
				throw("You are tying to use a method that needs caching enabled.","Please look at the plugin's settings or just use the 'retrieveFeed' method.","customPlugins.rss.rssReader");
			}
			
			/* Try to expire a feed, custom reap*/
			expireCachedFeed(arguments.feedURL);
			
			/* Check if its still cached */
			if( isFeedCached(arguments.feedURL) ){
				FeedStruct = getCachedFeed(arguments.feedURL);
			}
			else{
				/* We need to do the entire deal */
				FeedStruct = retrieveFeed(arguments.feedURL);
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
		<cfargument name="feedURL" type="string" required="yes" hint="The url to retrieve the feed from.">
		<!--- ******************************************************************************** --->
		<cfset var xmlDoc = "">
		<cfset var feedResult = structnew()>
		
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
		
		<!--- Try to xml parse the document --->
		<cfset xmlDoc = XMLParse(trim(feedResult.FileContent))>
		
		<!--- Return a universal parsed structure --->
		<cfreturn parseFeed(xmlDoc)>
	</cffunction>

	<!--- ******************************************************************************** --->

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
	
<!---------------------------------------- PRIVATE --------------------------------------------------->

	<cffunction name="parseFeed" access="private" returntype="struct" hint="This parses a feed as an xml doc and returns it as a structure of elements.">
		<!--- ******************************************************************************** --->
		<cfargument name="xmlDoc" type="xml" required="yes" hint="The xmldoc to parse.">
		<!--- ******************************************************************************** --->
		<cfset var feed = StructNew()>
		<cfset var isRSS1 = false>
		<cfset var isRSS2 = false>
		<cfset var isAtom = false>

		<cfscript>
			/* Set the elements */
			feed.title = "";
			feed.link = "";
			feed.description = "";
			feed.date = "";
			feed.image = StructNew();
			feed.image.url = "";
			feed.image.title = "";
			feed.image.link = "##";
			feed.items = ArrayNew(1);
			
			// get feed type
			isRSS1 = StructKeyExists(xmlDoc.xmlRoot,"item");
			isRSS2 = StructKeyExists(xmlDoc.xmlRoot,"channel") and StructKeyExists(xmlDoc.xmlRoot.channel,"item");
			isAtom = StructKeyExists(xmlDoc.xmlRoot,"entry");
			// get Content by Type
			if(isRSS1 or isRSS2) {
				if(isRSS1) feed.items = parseRSSItems(xmlDoc.xmlRoot.item);
				if(isRSS2) feed.items = parseRSSItems(xmlDoc.xmlRoot.channel.item);
				
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
				if(isAtom) feed.items = parseAtomItems(xmlDoc.xmlRoot.entry);
				if(StructKeyExists(xmlDoc.xmlRoot,"title")) feed.Title = xmlDoc.xmlRoot.title.xmlText;
				if(StructKeyExists(xmlDoc.xmlRoot,"link")) feed.Link = xmlDoc.xmlRoot.link.xmlAttributes.href;
				if(StructKeyExists(xmlDoc.xmlRoot,"info")) feed.Description = xmlDoc.xmlRoot.info.xmlText;
				if(StructKeyExists(xmlDoc.xmlRoot,"modified")) feed.Date = xmlDoc.xmlRoot.modified.xmlText;
			}
			
			/* Return the feed struct */
			return feed;
		</cfscript>
	</cffunction>

	<!--- ******************************************************************************** --->
	
	<cffunction name="parseAtomItems" access="private" returntype="array" hint="Parse the items an return an array of structures" output="false" >
		<cfargument name="items" required="true" type="any" hint="The xml of items">
		<cfset var x = 1>
		<cfset var y = 1>
		<cfset var itemLength = arrayLen(arguments.items)>
		<cfset var rtnArray = ArrayNew(1)>
		<cfset var node = "">
		
		<cfscript>
			/* Loop and add to array */
			for(x=1; x lte itemLength; x=x + 1){
				/* new node */
				node = structnew();
				
				/* Get Title */
				if( structKeyExists(items[x],"title") ){
					node.title = items[x].title.xmlText;
				}else{
					node.title = "";
				}
				
				/* Get Link */
				node.link = "";
				node.enclosure = "";
				if( structKeyExists(items[x],"link") ){
					for(y=1; y lte arrayLen(items[x].link);y=y+1){
						if ( items[x].link[y].xmlAttributes.rel is "alternate"){
							node.link = items[x].link[y].xmlAttributes.href;
						}
						else if ( items[x].link[y].xmlAttributes.rel is "enclosure" ){
							node.enclosure = items[x].link[y].xmlAttributes.href;
						}
					}
				}

				/* Description */
				if ( structKeyExists(items[x],"content") ){
					if ( structKeyExists(items[x].content.xmlAttributes,"mode") and items[x].content.xmlAttributes.mode is "xml"){
						node.description = getEmbeddedHTML(items[x].content.xmlChildren);
					}
					else{
						node.description = items[x].content.xmlText;
					}
				}
				else{
					node.description = '';
				}
				
				/* Get Date */
				if( structKeyExists(items[x],"published") ){
					node.pubDate = items[x].published.xmlText; 
				}
				else if ( structKeyExists( items[x], "updated") ){
					node.pubDate = items[x].updated.xmlText;
				}
				else if ( structKeyExists( items[x], "modified") ){
					node.pubDate = items[x].modified.xmlText;
				}
				else{
					node.pubDate = "";
				}
				
				/* Append to Array */
				ArrayAppend(rtnArray,node);
			}//end of for loop 
		
		/* Return array of items */
		return rtnArray;
		</cfscript>
	</cffunction>
	
	<cffunction name="parseRSSItems" access="private" returntype="array" hint="Parse the items an return an array of structures" output="false" >
		<cfargument name="items" required="true" type="any" hint="The xml of items">
		<cfset var x = 1>
		<cfset var itemLength = arrayLen(arguments.items)>
		<cfset var rtnArray = ArrayNew(1)>
		<cfset var node = "">
		
		<cfscript>
			/* Loop and add to array */
			for(x=1; x lte itemLength; x=x + 1){
				/* new node */
				node = structnew();
				
				/* Get Title */
				if( structKeyExists(items[x],"title") ){
					node.title = items[x].title.xmlText;
				}else{
					node.title = "";
				}
				
				/* Get Description */
				if( structKeyExists(items[x],"description") ){
					node.description = items[x].description.xmlText;
				}else{
					node.description = "";
				}
				
				/* Get pubdate */
				if( structKeyExists(items[x],"pubDate") ){
					node.pubDate = items[x].pubDate.xmlText;
				}
				else if( structKeyExists(items[x],"dc:date") ){
					node.pubDate = items[x]["dc:date"].xmlText;
				}else{
					node.pubDate = "";
				}
				
				/* Guid PermaLink or Normal Link */
				node.link = "";
				if ( structKeyExists(items[x],"guid") and (not structKeyExists(items[x].guid.xmlAttributes, "isPermaLink") or items[x].guid.xmlAttributes.isPermaLink) ){
					node.link = items[x].guid.XmlText;
				}
				else if ( structKeyExists(items[x],"link") ){
					node.link = items[x].link.XmlText;
				}
				else if ( structKeyExists(items[x],"source") and structKeyExists(items[x].source.XmlAttributes,"url") ){
					node.link = items[x].source.XmlAttributes.url;
				}
				
				/* Enclosure */
				node.enclosure = "";
				if( structKeyExists(items[x],"enclosure") and structKeyExists(items[x].enclosure.XmlAttributes,"url") ){
					node.enclosure = items[x].enclosure.XmlAttributes.url;
				}
				/* Append to Array */
				ArrayAppend(rtnArray,node);
			}//end of for loop 
		
		/* Return array of items */
		return rtnArray;
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
	
	<!--- Get Embedded HTML --->
	<cffunction name="getEmbeddedHTML" access="private" returnType="string" output="true" hint="Used to get a string from an html embedded xml packet.">
		<!--- ******************************************************************************** --->
		<cfargument name="data" type="array" required="true">
		<!--- ******************************************************************************** --->
		<cfset var str = "">
		<cfset var i = "">
	
		<cfloop index="i" from="1" to="#arrayLen(arguments.data)#">
			<cfset str = str & arguments.data[i].toString()>
		</cfloop>
		
		<cfreturn str>
	</cffunction>

	<!--- GET/SET Lock Name --->
	<cffunction name="getlockName" access="private" returntype="string" output="false" >
		<cfreturn instance.lockName>
	</cffunction>
	<cffunction name="setlockName" access="private" returntype="void" output="false">
		<cfargument name="lockName" type="string" required="true">
		<cfset instance.lockName = arguments.lockName>
	</cffunction>
	
</cfcomponent>