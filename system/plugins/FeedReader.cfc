<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Ben Garrett and Luis Majano
Date        :	May/18/2009
License     :	Apache 2 License
Version     :	2
Description :
	A feed reader plug-in with file caching capabilities. This reader supports
	and has been tested with all major revisions of RDF, RSS and Atom feeds.
	
	Feed dates such as those in ISO8601 and RFC882 formats are converted to
	usable ColdFusion dates. So you don't have to parse anything more, just
	format them.
	
	To use this plug-in you should set the following settings in your application
	(coldbox.xml.cfm), unless you are happy with the defaults.
	
Quick and Dirty Feed Dump:
	This is not a recommended ColdBox good design practise but it will give you a
	quick result while learning how to use this plug-in. In an eventhandler file
	create a new event, maybe call it 'feeddump'. Then add the code, change the
	URL and run the event.
	
	<cfset var rc = event.getCollection()>
	<cfset rc.webfeed = getPlugin("FeedReader").retrieveFeed("http://www.example.com/feeds/rss")>
	<cfdump var="#rc.webfeed#">
	<cfabort>

----------------------------------------------------------------------->

<cfcomponent extends="coldbox.system.Plugin"
			 hint="A feed reader plug-in that processes Atom, RDF and RSS formats. The recommended method for general usage is readFeed()."
			 cache="true">

<!---------------------------------------- CONSTRUCTOR --------------------------------------------------->

	<cffunction name="init" access="public" returntype="FeedReader" output="false" hint="Plug-in constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			var cacheLocation = "";
			var slash = "";

			super.init(arguments.controller);

			// Plug-in Properties
			setpluginName("FeedReader");
			setpluginVersion("2.0");
			setpluginDescription("I am a feed reader for rdf, rss and atom feeds.");
			setpluginAuthor("Ben Garrett");
			setpluginAuthorURL("http://www.coldbox.org");

			// Check if using cache and set useCache setting
			if( not settingExists('FeedReader_useCache') or not isBoolean(getSetting('FeedReader_useCache')) ){
				setUseCache(true);
			}else{
				setUseCache(getSetting('FeedReader_useCache'));
			}

			// Setup caching variables if enabled
			if( getUseCache() ){	

				// RAM caching used by default
				if( not settingExists('FeedReader_cacheType') or not reFindNoCase("^(ram|file)$",getSetting('FeedReader_cacheType')) ){
					setCacheType('ram');
				}
				else{
					setCacheType(getSetting('FeedReader_cacheType'));
				}

				// File caching
				if( getCacheType() eq "file" ){
					/* Cache prefix */
					setCachePrefix('');
					/* File separator */
					slash = "/";
					/* Cache location */
					if( not settingExists('FeedReader_cacheLocation') ){
						$throw(message="The setting FeedReader_cacheLocation is missing, please create it.",type='plugins.FeedReader.InvalidSettingException');
					}
					/* Tests if the directory exists: full path */
					/* Try to locate the path */
					cacheLocation = locateDirectoryPath(getSetting('FeedReader_cacheLocation'));
					/* Validate it */
					if( len(cacheLocation) eq 0 ){
						$throw('The cache location directory could not be found, please check again. #getSetting('FeedReader_cacheLocation')#','','plugins.FeedReader.InvalidCacheLocationException');
					}
					/* Set the location */
					setCacheLocation(cacheLocation);
				}//end if cahce eq file
				else{
					/* RAM cache */
					setCachePrefix('rssreader-');
				}
				
				/* Cache timeout */
				if( not settingExists('FeedReader_cacheTimeout') ){
					setCacheTimeout(30);
				}
				else{
					setCacheTimeout(getSetting('FeedReader_cacheTimeout'));
				}
			}//end else using cache

			/* HTTP timeout */
			if( not settingExists('FeedReader_httpTimeout') ){
				sethttpTimeout(30);
			}
			else{
				sethttpTimeout(getSetting('FeedReader_httpTimeout'));
			}

			/* Set the lock name */
			setLockName('FeedReaderCacheOperation');

			/* Return instance */
			return this;
		</cfscript>
	</cffunction>

<!---------------------------------------- INTERNAL CACHE OPERATIONS ------------------------------------->

	<!--- Flush all cache --->
	<cffunction name="flushCache" output="false" access="public" returntype="void" hint="Flushes the entire file cache by removing all the entries">
		<cfset var qFiles = "">
		<cfset var slash = "/">

		<cfif getCacheType() eq "ram">
			<cfset getColdboxOCM().clearByKeySnippet(getCachePrefix)>
		<cfelse>
			<!--- Lock, retrieve files and remove --->		
			<cflock name="#getLockName()#" type="exclusive" timeout="30" throwontimeout="true">
				<cfset qFiles = readCacheDir()>
				<!--- Recursively delete --->
				<cfloop query="qFiles">
					<!--- Delete file --->
					<cffile action="delete" file="#qFiles.directory##slash##qFiles.name#">
				</cfloop>
			</cflock>
		</cfif>
	</cffunction>

	<!--- How many elements in cache? --->
	<cffunction name="getCacheSize" output="false" access="public" returntype="numeric" hint="Returns the number of elements in the cache directory (only used for file caching)">
		<cfset var size = 0>
		<cflock name="#getLockName()#" type="readonly" timeout="30" throwontimeout="true">
			<cfset size = readCacheDir().recordcount>
		</cflock>
		<cfreturn size>
	</cffunction>

	<!--- Lookup cache element, also timeout if needed --->
	<cffunction name="isFeedCached" output="false" access="public" returntype="boolean" hint="Checks if a feed is cached or not">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" type="string" required="yes" hint="The url to check if its in the cache">
		<!--- ******************************************************************************** --->
		<cfset var results = false>
		
		<cfif getCacheType() eq "ram">
			<cfreturn getColdboxOCM().lookup(URLToCacheKey(arguments.feedURL))>
		<cfelse>
			<!--- Secure cache read --->
			<cflock name="#getLockName()#" type="readonly" timeout="30" throwontimeout="true">
				<!--- Check if feed is in cache --->
				<cfif readCacheDir(filter=URLToCacheKey(arguments.feedURL)).recordcount neq 0>
					<cfset results = true>
				</cfif>
			</cflock>
		</cfif>
		
		<cfreturn results>
	</cffunction>

	<!--- Checks if the feed has expired or not --->
	<cffunction name="isFeedExpired" output="false" access="public" returntype="boolean" hint="Checks if a feed has expired or not. If the feed does not exist an error will be thrown.">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" type="string" required="yes" hint="The url to check if its in the cache">
		<!--- ******************************************************************************** --->
		<cfset var results = false>
		<cfset var qFile = "">

		<cfif getCacheType() eq "ram">
			<cfreturn getColdboxOCM().lookup(URLToCacheKey(arguments.feedURL))>
		<cfelse>
			<!--- Secure cache read --->
			<cflock name="#getLockName()#" type="readonly" timeout="30" throwontimeout="true">
				<!--- Check if feed is in cache --->
				<cfset qFile = readCacheDir(filter=URLToCacheKey(arguments.feedURL))>			
			</cflock>
			<!--- Exists check --->
			<cfif qFile.recordcount eq 0>
				<cfthrow message="The feed does not exist in the cache." type="FeedReader.FeedDoesNotExistInTheCache">
			</cfif>
			<!--- Timeout check --->
			<cfif DateDiff("n", qFile.dateLastModified, now()) gt getCacheTimeout()>
				<cfset results = true>					
			</cfif>	
		</cfif>

		<cfreturn results>
	</cffunction>

	<!--- Checks if the feed has expired or not --->
	<cffunction name="expireCachedFeed" output="false" access="public" returntype="void" hint="If the feed exists and it has expired, it removes it other it does nothing">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" type="string" required="yes" hint="The url to check if its in the cache">
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

	<!--- Flush feed from cache --->
	<cffunction name="removeCachedFeed" output="false" access="public" returntype="boolean" hint="Purges a feed from the cache, returns false if feed is not found">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" type="string" required="yes" hint="The url to purge from the cache">
		<!--- ******************************************************************************** --->
		<cfset var results = false>
		<cfset var cacheFile = "">

		<cfif getCacheType() eq "ram">
			<cfreturn getColdboxOCM().clear(URLToCacheKey(arguments.feedURL))>
		<cfelse>
			<!--- Cache file --->
			<cfset cacheFile = getCacheLocation() & "/" & URLToCacheKey(arguments.feedURL)>
			<!--- Lock, get files and remove --->		
			<cflock name="#getLockName()#" type="exclusive" timeout="30" throwontimeout="true">
				<!--- Is feed cached check --->
				<cfif isFeedCached(arguments.feedURL)>
					<!--- Now remove it --->
					<cffile action="delete" file="#cacheFile#.xml">
					<cfset results = true>
				</cfif>
			</cflock>
		</cfif>

		<cfreturn results>
	</cffunction>

	<!--- Get feed from cache --->
	<cffunction name="getCachedFeed" output="false" access="public" returntype="any" hint="Get the feed content from the cache, if missing a blank structure is returned. This method does NOT timeout or expire the feeds that is only done by the readFeed method.">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" type="string" required="yes" hint="The url to check if its in the cache">
		<!--- ******************************************************************************** --->
		<cfset var results = structNew()>
		<cfset var cacheFile = "">
		<cfset var fileIn = "">
		<cfset var objectIn = "">
		<cfif getCacheType() eq "ram">
			<cfset results = getColdboxOCM().get(URLToCacheKey(arguments.feedURL))>
		<cfelse>
			<cfset cacheFile = getCacheLocation() & "/" & URLToCacheKey(arguments.feedURL)>
			<!--- Secure cache read --->
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

	<!--- Copy feed to the cache --->
	<cffunction name="setCachedFeed" output="false" access="public" returntype="void" hint="Copy feed content into the cache">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" 		type="string" required="yes" hint="The feed url to store in the cache">
		<cfargument name="feedStruct" 	type="any" 	  required="yes" hint="The content of the feed to cache">
		<!--- ******************************************************************************** --->
		<cfset var cacheKey = URLToCacheKey(arguments.feedURL)>
		<cfset var cacheFile = "">
		<cfset var fileOut = "">
		<cfset var objectOut = "">

		<cfif getCacheType() eq "ram">
			<cfset getColdboxOCM().set(cacheKey, feedStruct, getCacheTimeout())>
		<cfelse>
			<cfset cacheFile = getCacheLocation() & "/" & cacheKey>
			<!--- Secure cache write --->
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

<!---------------------------------------- PUBLIC FEED METHODS ------------------------------------------->

	<cffunction name="readFeed" access="public" returntype="struct" hint="Read a feed sourced from HTTP or from cache. Return a universal structure representation of the feed." output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" 		type="string"  required="yes" hint="The feed url to parse or retrieve from cache">
		<cfargument name="itemsType" 	type="string"  required="false" default="array" hint="The type of the items either query or array, array is used by default"/>
		<cfargument name="maxItems" 	type="numeric" required="false" default="0" hint="The maximum number of entries to retrieve, default is display all"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var FeedStruct = structnew();
			/* Check if using cache */
			if( not getUseCache() ){
				$throw("You are trying to use a method that needs caching enabled.","Please look at the plug-in settings or just use the 'retrieveFeed' method.","plugins.FeedReader.InvalidSettingException");
			}
			/* Check for itemsType */
			if( not reFindnocase("^(query|array)$",arguments.itemsType) ){
				arguments.itemsType = "array";
			}

			/* Try to expire a feed, custom reap */
			expireCachedFeed(arguments.feedURL);
			/* Check if its still cached */
			if( isFeedCached(arguments.feedURL) ){
				FeedStruct = getCachedFeed(arguments.feedURL);
			}
			else{
				/* We need to do the entire deal */
				FeedStruct = retrieveFeed(arguments.feedURL,arguments.itemsType,arguments.maxItems);
				/* Set in cache */
				setCachedFeed(arguments.feedURL,FeedStruct);
			}

			/* Return feed */
			return FeedStruct;
		</cfscript>
	</cffunction>

	<cffunction name="retrieveFeed" access="public" returntype="struct" hint="This method does a cfhttp call on the feed url and returns a universal parsed feed structure. You can use this when you don't want to use the cache facilities." output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" 		type="string" required="yes" hint="The url to retrieve the feed from.">
		<cfargument name="itemsType" 	type="string" required="false" default="array" hint="The type of the items either query or array, array is default"/>
		<cfargument name="maxItems" 	type="numeric" required="false" default="0" hint="The max number of entries to retrieve, default is all"/>
		<!--- ******************************************************************************** --->
		<cfset var feed = structnew()>
		<cfset var i = 0>
		<cfset var j = 0>
		<cfset var feedCombArr = arrayNew(1)>
		<cfset var url = "">
		<cfset var xmlDoc = "">

		<!--- Check for return type --->
		<cfif not reFindnocase("^(query|array)$",arguments.itemsType)>
			<cfset arguments.itemsType = "query">
		</cfif>

		<!--- Replace protocols --->
		<cfset arguments.feedURL = ReplaceNoCase(arguments.feedURL,"feed://","http://")>

		<!--- Download feeds and (if required) combine the data into a master feed --->
		<cfloop list="#arguments.feedURL#" delimiters="," index="url">
			<cfscript>
				// increase i value for array number
				i=i+1;
				// download feed
				xmlDoc = downloadFeed(url);
				/* parse feed when there are multiple urls to process */
				if(ListLen(arguments.feedURL) gt 1) {
					// process the downloaded feed
					feedCombArr[i] = parseFeed(xmlDoc,arguments.itemsType,arguments.maxItems,true);
					// merge downloaded feed into master feed
					if(i lte 1) {
						// this is the feed to process, so by default it becomes the master feed
						feed.category = feedCombArr[i].category;
						feed.datebuilt = feedCombArr[i].datebuilt;
						feed.dateupdated = feedCombArr[i].dateupdated;
						feed.description = "This is a custom, merged feed which combines the following sources: " & feedCombArr[i].title;
						feed.specs.extensions = feedCombArr[i].specs.extensions;
						feed.specs.namespace = feedCombArr[i].specs.namespace;
						feed.specs.type = feedCombArr[i].specs.type;
						feed.specs.version = feedCombArr[i].specs.version;
						feed.title = feedCombArr[i].title;
						feed.websiteurl = feedCombArr[i].websiteurl;
						if( arguments.itemsType eq "array" ) feed.items = feedCombArr[i].items;
						else feed.items = feedCombArr[i].items;
					}
					else {
						// this is the 2nd or greater feed processed, so we have to combine the feed data with the master feed
						// category appending and resorting
						for (j=1;j lte ArrayLen(feedCombArr[i].category);j=j+1) {
								ArrayAppend(feed.category,feedCombArr[i].category[j]);
							}
							feed.category = createObject('component','coldbox.system.web.feeds.FeedReader').arrayOfStructsSort(feed.category,'tag');
						// datebuilt, here we only update the most recent date
						try { if(DateCompare(feedCombArr[i].datebuilt,feed.datebuilt) is 1) feed.datebuilt = feedCombArr[i].datebuilt; }
                        catch(Any e) { if(IsDate(feedCombArr[i].datebuilt)) feed.datebuilt = feedCombArr[i].datebuilt; }
						// dateupdated, here we only update the most recent date
						try { if(DateCompare(feedCombArr[i].datebuilt,feed.dateupdated) is 1) feed.dateupdated = feedCombArr[i].dateupdated; }
                        catch(Any e) { if(IsDate(feedCombArr[i].dateupdated)) feed.dateupdated = feedCombArr[i].dateupdated; }
						// the rest are more simple to merge
						feed.description = listAppend(feed.description," #feedCombArr[i].title#");
						feed.specs.extensions = listAppend(feed.specs.extensions,feedCombArr[i].specs.extensions);
						structAppend(feed.specs.namespace,feedCombArr[i].specs.namespace,false);
						feed.specs.type = listAppend(feed.specs.type,feedCombArr[i].specs.type);
						feed.specs.version = listAppend(feed.specs.version,feedCombArr[i].specs.version);
						feed.title = feed.title & " + " & feedCombArr[i].title;
						feed.websiteurl = listAppend(feed.websiteurl,feedCombArr[i].websiteurl);
						// when arguments itemType is 'array', combine the feed items with the master feed, reorder item array and trim the length to argument maxItems
						if( arguments.itemsType eq "array" ) {
							// append new feed items to master items
							for (j=1;j lte ArrayLen(feedCombArr[i].items);j=j+1) {
								ArrayAppend(feed.items,feedCombArr[i].items[j]);
							}
							// reorder master items
							feed.items = createObject('component','coldbox.system.web.feeds.FeedReader').arrayOfStructsSort(feed.items,'datepublished');
							// trim item length to arguments maxItems
							for (j=arguments.maxItems;j lt ArrayLen(feed.items);j=arguments.maxItems) {
								ArrayDeleteAt(feed.items,arguments.maxItems+1);
							}
						}
						// when arguments itemType is 'query', ...
						else {
							// append new feed items to master items
							feed.items = getPlugin("QueryHelper").doQueryAppend(feed.items,feedCombArr[i].items);
							// reorder and trim the master items
							feed.items = createObject('component','coldbox.system.web.feeds.FeedReader').querySortandTrim(feed.items,arguments.maxItems,'datepublished','desc');
						}
					}
					// set blanks for missing feed data where there could be conflicts
					feed.author.email = "";
					feed.author.name = "";
					feed.author.url = "";
					feed.image.description = "";
					feed.image.height = "";
					feed.image.icon = "";
					feed.image.link = "";
					feed.image.title = "";
					feed.image.url = "";
					feed.image.width = "";
					feed.language = "";
					feed.opensearch = StructNew();
					feed.rating = "";
					feed.rights.copyright = "";
					feed.rights.creativecommonds = "";	
					feed.specs.generator = "Multiple feeds combined";
					feed.specs.url = "";
				}
				/* parse feed when there is only a single url to process (a much quicker process) */
				else feed = parseFeed(xmlDoc,arguments.itemsType,arguments.maxItems,false);
			</cfscript>
		</cfloop>

		<!--- Return a universal parsed structure --->
		<cfreturn feed>
	</cffunction>

	<cffunction name="parseFeed" access="public" returntype="struct" hint="This parses a feed as a XML document and returns the results as a structure of elements" output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="xmlDoc" 		type="xml" required="yes" hint="The XML document (saved as a ColdFusion object) to parse and normalize">
		<cfargument name="itemsType" 	type="string" required="false" default="array" hint="The type of the items either query or array, array is used by default"/>
		<cfargument name="maxItems" 	type="numeric" required="false" default="0" hint="The maximum number of entries to retrieve, default is display all"/>
		<!--- ******************************************************************************** --->
		<cfset var feed = StructNew()>
		<cfset var x = 1>
		<cfset var loop = "">
		<cfset var merge = "">
		<cfset var xmlrootkey = "">
		<cfset var oUtilities = getPlugin("DateUtils")>
		<cfset var extras = createObject('component','coldbox.system.web.feeds.FeedReader').init(controller)>

		<cfscript>
			// check to make sure arguments.xmlDoc is a XML document, not just a URL or path pointing to a feed
			if( not IsXML(arguments.xmlDoc) ) {
				$throw('There is a problem with the xmlDoc provided with the parseFeed method, it is not a variable containing a valid xml document','The xmlDoc contains: #htmlEditFormat(toString(arguments.xmlDoc))#','plugins.FeedReader.FeedParsingException');
			}
			// set feed type structure
			feed.specs = StructNew();
			feed.specs.extensions = "";
			feed.specs.generator = "";
			feed.specs.namespace = StructNew();
			feed.specs.type = "";
			feed.specs.url = "";
			feed.specs.version = "";
			// get feed type
			if( structKeyExists(xmlDoc,"rdf:RDF") ) { feed.specs.type = "RDF"; }
			else if( structKeyExists(xmlDoc,"version") or structKeyExists(xmlDoc,"rss") ) { feed.specs.type = "RSS"; }
			else if( structKeyExists(xmlDoc,"feed") ) { feed.specs.type = "Atom"; }
			// get feed namespaces (including feed extensions) and feed numeric version
			if( structKeyExists(xmlDoc.xmlRoot,"xmlAttributes") ) { 
				feed.specs.namespace = xmlDoc.xmlRoot.xmlAttributes;
				if( structKeyExists(xmlDoc.xmlRoot.xmlAttributes,"xmlns") ) { 
					if( feed.specs.type is "RDF" and left(xmlDoc.xmlRoot.xmlAttributes.xmlns,20) is 'http://purl.org/rss/' ) {
						feed.specs.version = listGetAt(xmlDoc.xmlRoot.xmlAttributes.xmlns,4,'/');
					}
				}
				if( structKeyExists(xmlDoc.xmlRoot.xmlAttributes,"version") ) { 
					feed.specs.version = xmlDoc.xmlRoot.xmlAttributes.version;
				}
				else if( structKeyExists(xmlDoc.xmlRoot.xmlAttributes,"xmlns") and xmlDoc.xmlRoot.xmlAttributes.xmlns contains "http://www.w3.org/2005/Atom" ) {
					feed.specs.version = "1.0";
				}
			}
			// obtain and list supported feed extensions
			if( listFindNoCase(StructKeyList(feed.specs.namespace),'xmlns:atom') ) {
				feed.specs.extensions = feed.specs.extensions & ", Atom";
				if( feed.specs.namespace["xmlns:atom"] contains "http://www.w3.org/2005/Atom" ) feed.specs.extensions = feed.specs.extensions & " 1.0";
			}
			if( listFindNoCase(StructKeyList(feed.specs.namespace),'xmlns:content') ) {
				feed.specs.extensions = feed.specs.extensions & ", Content RSS Module";
				if( feed.specs.namespace["xmlns:content"] contains "http://purl.org/rss/1.0/modules/content" ) feed.specs.extensions = feed.specs.extensions & " 2.01";
			}
			if( listFindNoCase(StructKeyList(feed.specs.namespace),'xmlns:creativeCommons') ) {
				feed.specs.extensions = feed.specs.extensions & ", Creative Commons RSS Module";
			}
			if( listFindNoCase(StructKeyList(feed.specs.namespace),'xmlns:dc') ) {
				feed.specs.extensions = feed.specs.extensions & ", Dublin Core ";
				if( feed.specs.namespace["xmlns:dc"] contains "http://purl.org/rss/1.0/modules/dc" ) feed.specs.extensions = feed.specs.extensions & " RSS Module 1.4.1";
				if( feed.specs.namespace["xmlns:dc"] contains "http://purl.org/dc/elements/1.1" ) feed.specs.extensions = feed.specs.extensions & " Element Set 1.1";
			}
			if( listFindNoCase(StructKeyList(feed.specs.namespace),'xmlns:itunes') ) {
				feed.specs.extensions = feed.specs.extensions & ", Apple iTunes Podcast";
				if( feed.specs.namespace["xmlns:itunes"] contains "http://www.itunes.com/dtds/podcast-1.0.dtd" ) feed.specs.extensions = feed.specs.extensions & " 1.0";
			}
			if( listFindNoCase(StructKeyList(feed.specs.namespace),'xmlns:media') ) {
				if( feed.specs.namespace["xmlns:media"] contains "http://search.yahoo.com/mrss" ) {
					feed.specs.extensions = feed.specs.extensions & ", Media RSS";
					feed.specs.extensions = feed.specs.extensions & " 1.1";
				}
			}
			if( listFindNoCase(StructKeyList(feed.specs.namespace),'xmlns:gd') ) {
				feed.specs.extensions = feed.specs.extensions & ", Google Data API";
				if( feed.specs.namespace["xmlns:gd"] contains "http://schemas.google.com/g/2005" ) feed.specs.extensions = feed.specs.extensions & " 2.0";
			}
			if( listFindNoCase(StructKeyList(feed.specs.namespace),'xmlns:openSearch') ) {
				feed.specs.extensions = feed.specs.extensions & ", OpenSearch";
				if( feed.specs.namespace["xmlns:openSearch"] contains "http://a9.com/-/spec/opensearch/1.0"
					or feed.specs.namespace["xmlns:openSearch"] contains "http://a9.com/-/spec/opensearchrss/1.0") feed.specs.extensions = feed.specs.extensions & " 1.0";
				if( feed.specs.namespace["xmlns:openSearch"] contains "http://a9.com/-/spec/opensearch/1.1"
					or feed.specs.namespace["xmlns:openSearch"] contains "http://a9.com/-/spec/opensearchrss/1.1") feed.specs.extensions = feed.specs.extensions & " 1.1";
			}
			if( listFindNoCase(StructKeyList(feed.specs.namespace),'xmlns:slash') ) {
				feed.specs.extensions = feed.specs.extensions & ", Slash RSS Module";
				if( feed.specs.namespace["xmlns:slash"] contains "http://purl.org/rss/1.0/modules/slash" ) feed.specs.extensions = feed.specs.extensions & " 0.4";
			}
			if( left(feed.specs.extensions,2) is ", " ) feed.specs.extensions = ListDeleteAt("##" & feed.specs.extensions,1);
			// Get rss namespace
			if( StructKeyExists(xmlDoc.xmlRoot,"channel") ) {
				if( structKeyExists(xmlDoc.xmlRoot.channel,"docs") ) { feed.specs.namespace.xmlns = xmlDoc.xmlRoot.channel.docs.xmlText; }
			}
			// Get feed generator
			if( StructKeyExists(xmlDoc.xmlRoot,"channel") ) {
				if( structKeyExists(xmlDoc.xmlRoot.channel,"generator") ) { feed.specs.generator = xmlDoc.xmlRoot.channel.generator.xmlText; }
			}
			else if( StructKeyExists(xmlDoc.xmlRoot,"generator") and len(xmlDoc.xmlRoot.generator.xmlText) ) {
				feed.specs.generator = xmlDoc.xmlRoot.generator.xmlText;
				if( StructKeyExists(xmlDoc.xmlRoot.generator.xmlAttributes,"version") ) feed.specs.generator = feed.specs.generator & ' #xmlDoc.xmlRoot.generator.xmlAttributes.version#';
				if( StructKeyExists(xmlDoc.xmlRoot.generator.xmlAttributes,"uri") ) feed.specs.generator = feed.specs.generator & ' (#xmlDoc.xmlRoot.generator.xmlAttributes.uri#)';
			}
			// Setup some extra feed structure keys
			feed = extras.parseVariablesSet(feed);
			// Get rss/rdf 1 & rss 2
			if(feed.specs.type is "RDF" or feed.specs.type is "RSS") {
				/* Parse items */
				if(feed.specs.type is "RDF") {
					if( not StructKeyExists(xmlDoc.xmlRoot,'item') ) feed.items = extras.parseRSSItems(arrayNew(1),arguments.itemsType,arguments.maxItems);
					else feed.items = extras.parseRSSItems(xmlDoc.xmlRoot.item,arguments.itemsType,arguments.maxItems);
				}
				else if(feed.specs.type is "RSS") {
					if( not StructKeyExists(xmlDoc.xmlRoot.channel,'item') ) feed.items = extras.parseRSSItems(arrayNew(1),arguments.itemsType,arguments.maxItems);
					else feed.items = extras.parseRSSItems(xmlDoc.xmlRoot.channel.item,arguments.itemsType,arguments.maxItems);
				}
				/* Author info */
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"managingEditor"))
					feed.author.name = xmlDoc.xmlRoot.channel.managingEditor.xmlText;
				else if(StructKeyExists(xmlDoc.xmlRoot.channel,"webMaster"))
					feed.author.name = xmlDoc.xmlRoot.channel.webMaster.xmlText;
				/* Author email */
				if( find("@",feed.author.name) ) {
					feed.author.email = ListGetAt(feed.author.name,1,' ');
					// regexpression matching only works in CFML8 compatible engines
					if( ListFindNoCase(StructKeyList(GetFunctionList()),'REMatchNoCase') and ArrayLen(REMatchNoCase('( \(.*\))?$', feed.author.name)) ) {
						feed.author.name = REMatchNoCase('( \(.*\))?$', feed.author.name);
						feed.author.name = ReReplace(feed.author.name[1],'\(|\)','','all');
					}
				}
				// Apple iTunes author
				if( StructKeyExists(xmlDoc.xmlRoot.channel,"itunes:author") ) feed.author.name = xmlDoc.xmlRoot.channel["itunes:author"].xmlText;
				// Dublin Core creator as author
				if( StructKeyExists(xmlDoc.xmlRoot.channel,"dc:creator") ) {
					if( not len(feed.author.name) and not find("@",xmlDoc.xmlRoot.channel["dc:creator"].xmlText) ) feed.author.name = xmlDoc.xmlRoot.channel["dc:creator"].xmlText;
					else if( not len(feed.author.email) and StructKeyExists(xmlDoc.xmlRoot.channel,"dc:creator") and find("@",xmlDoc.xmlRoot.channel["dc:creator"].xmlText) ) feed.author.email = xmlDoc.xmlRoot.channel["dc:creator"].xmlText;
				}
				/* Category */
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"category")){
					for(x=1; x lte arrayLen(xmlDoc.xmlRoot.channel.category); x=x+1){
						loop = xmlDoc.xmlRoot.channel.category[x];
						if( len(loop.xmlText) ) { 
							feed.category[x] = StructNew();
							feed.category[x].tag = loop.xmlText;
							if(StructKeyExists(loop.xmlAttributes,'domain')) feed.category[x].domain = loop.xmlAttributes.domain;
						}
					}
				}
				// Dublin Core subject as category
				if( StructKeyExists(xmlDoc.xmlRoot.channel,"dc:subject") and not arrayLen(feed.category) ) {
					loop = xmlDoc.xmlRoot.channel["dc:subject"].xmlText;
					for(x=1; x lte listLen(loop); x=x+1){
						feed.category[x] = StructNew();
						feed.category[x].tag = listGetAt(loop,x);
					}
				}
				// Apple iTunes category
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"itunes:category")){
					for(x=1; x lte arrayLen(xmlDoc.xmlRoot.channel["itunes:category"]); x=x+1){
						loop = xmlDoc.xmlRoot.channel["itunes:category"][x];
						if( len(loop.xmlAttributes.text) ) { 
							feed.category[x] = StructNew();
							feed.category[x].tag = loop.XMLAttributes.text;
							feed.category[x].domain = "itunes category";
						}
					}
				}
				// Apple iTunes keywords as category
				if( StructKeyExists(xmlDoc.xmlRoot.channel,"itunes:keywords") ) {
					arrayAppend(feed.category, StructNew());
					x = arrayLen(feed.category);
					feed.category[x].tag = xmlDoc.xmlRoot.channel["itunes:keywords"].xmlText;
					feed.category[x].domain = "itunes keywords";
				}
				/* Copyright */
				if( StructKeyExists(xmlDoc.xmlRoot.channel,"copyright") ) feed.rights.copyright = xmlDoc.xmlRoot.channel.copyright.xmlText;
				else if( StructKeyExists(xmlDoc.xmlRoot.channel,"dc:rights") ) feed.rights.copyright = xmlDoc.xmlRoot.channel["dc:rights"].xmlText;
				if( StructKeyExists(xmlDoc.xmlRoot.channel,"creativeCommons:license") ) feed.rights.creativecommons = xmlDoc.xmlRoot.channel["creativeCommons:license"].xmlText;
				/* Date built & date updated */
				feed.DateBuilt = extras.findCreatedDate(xmlDoc.xmlRoot.channel);
				if( extras.isDateISO8601(feed.DateBuilt) ) feed.DateBuilt = oUtilities.parseISO8601(feed.DateBuilt);
				else feed.DateBuilt = oUtilities.parseRFC822(feed.DateBuilt);
				feed.DateUpdated = extras.findUpdatedDate(xmlDoc.xmlRoot.channel);
				if( extras.isDateISO8601(feed.DateUpdated) ) feed.DateUpdated = oUtilities.parseISO8601(feed.DateUpdated);
				else feed.DateUpdated = oUtilities.parseRFC822(feed.DateUpdated);
				// Dubline Core date as dateupdated
				if( StructKeyExists(xmlDoc.xmlRoot.channel,"dc:date") and not len(feed.dateupdated) ) { 
					if( extras.isDateISO8601(feed.dateupdated) ) { feed.dateupdated = oUtilities.parseISO8601(xmlDoc.xmlRoot.channel["dc:date"].xmlText); }
					else { feed.dateupdated = oUtilities.parseRFC822(xmlDoc.xmlRoot.channel["dc:date"].xmlText); }
				}
				/* Description */
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"description")) feed.Description = xmlDoc.xmlRoot.channel.description.xmlText;
				else if( StructKeyExists(xmlDoc.xmlRoot.channel,"dc:description") ) feed.description = xmlDoc.xmlRoot.channel["dc:description"].xmlText;
				else if( StructKeyExists(xmlDoc.xmlRoot.channel,"itunes:subtitle") ) feed.description = xmlDoc.xmlRoot.channel["itunes:subtitle"].xmlText;
				else if( StructKeyExists(xmlDoc.xmlRoot.channel,"itunes:summary") ) feed.description = xmlDoc.xmlRoot.channel["itunes:summary"].xmlText;
				/* Image */
				if(StructKeyExists(xmlDoc.xmlRoot,"image") and feed.specs.type is "RDF") {
					if(StructKeyExists(xmlDoc.xmlRoot.image,"link")) feed.Image.Link = xmlDoc.xmlRoot.image.link.xmlText;
					if(StructKeyExists(xmlDoc.xmlRoot.image,"title")) feed.Image.Title = xmlDoc.xmlRoot.image.title.xmlText;
					if(StructKeyExists(xmlDoc.xmlRoot.image,"url")) feed.Image.Url = xmlDoc.xmlRoot.image.url.xmlText;
				}
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"image") and feed.specs.type is "RSS") {
					if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"description")) feed.Image.Description = xmlDoc.xmlRoot.channel.image.description.xmlText;
					if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"height")) feed.Image.Height = xmlDoc.xmlRoot.channel.image.height.xmlText;
					if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"link")) feed.Image.Link = xmlDoc.xmlRoot.channel.image.link.xmlText;
					if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"title")) feed.Image.Title = xmlDoc.xmlRoot.channel.image.title.xmlText;
					if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"url")) feed.Image.Url = xmlDoc.xmlRoot.channel.image.url.xmlText;
					if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"width")) feed.Image.Width = xmlDoc.xmlRoot.channel.image.width.xmlText;				
				}
				// Apple iTunes image
				try {	if( not len(feed.image.url) and StructKeyExists(xmlDoc.xmlRoot.channel["itunes:image"].xmlAttributes,'href') ) feed.image.url = xmlDoc.xmlRoot.channel["itunes:image"].xmlAttributes.href;	} catch(Any ex) {}
				/* Language */
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"language")) feed.language = xmlDoc.xmlRoot.channel.language.xmlText;
				else if( StructKeyExists(xmlDoc.xmlRoot.channel,"dc:language") ) feed.language = xmlDoc.xmlRoot.channel["dc:language"].xmlText;
				/* Link */
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"link") ) feed.websiteurl = xmlDoc.xmlRoot.channel["link"].xmlText;
				/* Rating */
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"rating")) feed.rating = xmlDoc.xmlRoot.channel.rating.xmlText;
				else if( StructKeyExists(xmlDoc.xmlRoot.channel,"itunes:explicit") ) feed.rating = "explicit - #xmlDoc.xmlRoot.channel["itunes:explicit"].xmlText#";
				/* Title */
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"title")) feed.Title = xmlDoc.xmlRoot.channel.title.xmlText;
				else if( StructKeyExists(xmlDoc.xmlRoot.channel,"dc:title") ) feed.title = xmlDoc.xmlRoot.channel["dc:title"].xmlText;
				/* Atom as a RSS extension */
				if( ArrayLen(StructFindKey(feed.specs.namespace,'xmlns:atom')) and StructKeyExists(xmlDoc.xmlRoot.channel,"atom:link") ) {
					for(x=1; x lte arrayLen(xmlDoc.xmlRoot.channel["link"]); x=x+1){
						loop = xmlDoc.xmlRoot.channel["link"][x];
						if( StructKeyExists(loop,'xmlAttributes') and StructKeyExists(loop.xmlAttributes,'rel') and len(loop.xmlAttributes.rel) ) {
							// OpenSearch autodiscovery
							if(
								 StructKeyExists(xmlDoc.xmlRoot.channel,"opensearch:Query") 
								 and loop.xmlAttributes.rel is "search"
								 and StructKeyExists(loop.xmlAttributes,'type')
								 and loop.xmlAttributes.type is "application/opensearchdescription+xml"
								 and StructKeyExists(loop.xmlAttributes,'href')
								 ) {
									feed.opensearch.autodiscovery.url = loop.xmlAttributes.href;
									if(StructKeyExists(loop.xmlAttributes,'title')) feed.opensearch.autodiscovery.title = loop.xmlAttributes.title;
								}
							// RSS self identifier
							if(
								 loop.xmlAttributes.rel is "self"
								 and loop.xmlAttributes.type is "application/rss+xml"
								 and StructKeyExists(loop.xmlAttributes,'href')
								 ) {
									feed.specs.url = loop.xmlAttributes.href;
							}
						}
						else if( not len(feed.websiteurl) and len(loop.xmlText) ) feed.websiteurl = loop.xmlText;
					}
				}
			}//end if rss 1 or 2
			else if(feed.specs.type is "Atom") {
				/* Parse items */
				if( not structKeyExists(xmlDoc.xmlRoot,"entry") ) feed.items = extras.parseAtomItems(arrayNew(1),arguments.itemsType,arguments.maxItems);
				else feed.items = extras.parseAtomItems(xmlDoc.xmlRoot.entry,arguments.itemsType,arguments.maxItems);
				/* Author information */
				if(structKeyExists(xmlDoc.xmlRoot,"author")){
					if( structKeyExists(xmlDoc.xmlRoot.author,"name") ) feed.author.name = extras.normalizeAtomTextConstruct(xmlDoc.xmlRoot.author.name);
					if( structKeyExists(xmlDoc.xmlRoot.author,"uri") ) feed.author.url = extras.normalizeAtomTextConstruct(xmlDoc.xmlRoot.author.uri);
					if( structKeyExists(xmlDoc.xmlRoot.author,"email") ) feed.author.email = extras.normalizeAtomTextConstruct(xmlDoc.xmlRoot.author.email);
				}	
				/* Category */
				if(StructKeyExists(xmlDoc.xmlRoot,"category")){
					for(x=1; x lte arrayLen(xmlDoc.xmlRoot.category); x=x+1){
						loop = xmlDoc.xmlRoot.category[x];
						if( StructKeyExists(loop.xmlAttributes,'term') and len(loop.xmlAttributes.term) ) { 
							feed.category[x] = StructNew();
							feed.category[x].tag = loop.XMLAttributes.term;
							if(StructKeyExists(loop.xmlAttributes,'scheme')) feed.category[x].domain = loop.xmlAttributes.scheme;
						}
					}
				}
				/* Date */
				feed.datebuilt = oUtilities.parseISO8601(extras.findCreatedDate(xmlDoc.xmlRoot));
				feed.dateupdated = oUtilities.parseISO8601(extras.findUpdatedDate(xmlDoc.xmlRoot));
				/* Description */
				if(StructKeyExists(xmlDoc.xmlRoot,"info")) 
					feed.Description = extras.normalizeAtomTextConstruct(xmlDoc.xmlRoot.info);
				else if(StructKeyExists(xmlDoc.xmlRoot,"subtitle")) 
					feed.Description = extras.normalizeAtomTextConstruct(xmlDoc.xmlRoot.subtitle);
				else if(StructKeyExists(xmlDoc.xmlRoot,"tagline")) 
					feed.Description = extras.normalizeAtomTextConstruct(xmlDoc.xmlRoot.tagline);
				/* Image */
				if(StructKeyExists(xmlDoc.xmlRoot,"icon")) feed.image.icon = extras.normalizeAtomTextConstruct(xmlDoc.xmlRoot.icon);
				if(StructKeyExists(xmlDoc.xmlRoot,"logo")) feed.image.url = extras.normalizeAtomTextConstruct(xmlDoc.xmlRoot.logo);
				/* Links */
				if(StructKeyExists(xmlDoc.xmlRoot,"link")){
					for(x=1; x lte arrayLen(xmlDoc.xmlRoot.link); x=x+1){
						loop = xmlDoc.xmlRoot.link[x];
						if( StructKeyExists(loop.XMLAttributes,'rel') and StructKeyExists(loop.XMLAttributes,'href') ) {
							if( loop.xmlAttributes.rel is "alternate" ) feed.websiteurl = loop.xmlAttributes.href;
							if( loop.xmlAttributes.rel is "self" ) feed.specs.url = loop.xmlAttributes.href;
							if( StructKeyExists(xmlDoc.xmlRoot,"opensearch:Query") and loop.xmlAttributes.rel is "search" ) {
									feed.opensearch.autodiscovery.url = loop.xmlAttributes.href;
									if(StructKeyExists(loop.xmlAttributes,'title')) feed.opensearch.autodiscovery.title = loop.xmlAttributes.title;
							}
						}
					}
				}
				/* Rights */
				if(StructKeyExists(xmlDoc.xmlRoot,"rights")) feed.rights.copyright = extras.normalizeAtomTextConstruct(xmlDoc.xmlRoot.rights);
				/* Title */
				if(StructKeyExists(xmlDoc.xmlRoot,"title"))	feed.title = extras.normalizeAtomTextConstruct(xmlDoc.xmlRoot.title);
			}
			//end if atom
			//shared extensions
			/* OpenSearch 1.0 & 1.1 */
			if( not ArrayLen(StructFindKey(feed.specs.namespace,'xmlns:opensearch')) ) feed.opensearch = StructNew();	
			else {
				if(feed.specs.type is "Atom") xmlrootkey = 'xmlDoc.xmlRoot';
				else xmlrootkey = 'xmlDoc.xmlRoot.channel';
				// OS 1.0
				if( StructKeyExists(evaluate(xmlrootkey),"opensearch:itemsperpage") ) feed.opensearch.itemsperpage = evaluate('#xmlrootkey#["openSearch:itemsperpage"].xmlText');
				if( StructKeyExists(evaluate(xmlrootkey),"opensearch:startindex") ) feed.opensearch.startindex = evaluate('#xmlrootkey#["openSearch:startindex"].xmlText');
				if( StructKeyExists(evaluate(xmlrootkey),"opensearch:totalresults") ) feed.opensearch.totalresults = evaluate('#xmlrootkey#["openSearch:totalresults"].xmlText');
				// OS 1.1
				if(StructKeyExists(evaluate(xmlrootkey),"opensearch:Query")) {
					for(x=1; x lte arrayLen(evaluate('#xmlrootkey#["opensearch:Query"]')); x=x+1){
						loop = evaluate('#xmlrootkey#["opensearch:Query"][#x#]');
						if( StructKeyExists(loop,'xmlAttributes') and StructKeyExists(loop.xmlAttributes,'role') and len(loop.xmlAttributes.role) ) {
							feed.opensearch.query[x] = StructNew();
							feed.opensearch.query[x].role = loop.xmlAttributes.role;
							if( StructKeyExists(loop.xmlAttributes,'totalResults') ) feed.opensearch.query[x].totalResults = loop.xmlAttributes.totalResults;
							if( StructKeyExists(loop.xmlAttributes,'searchTerms') ) feed.opensearch.query[x].searchTerms = loop.xmlAttributes.searchTerms;
							if( StructKeyExists(loop.xmlAttributes,'count') ) feed.opensearch.query[x].count = loop.xmlAttributes.count;
							if( StructKeyExists(loop.xmlAttributes,'startIndex') ) feed.opensearch.query[x].startIndex = loop.xmlAttributes.startIndex;
							if( StructKeyExists(loop.xmlAttributes,'startPage') ) feed.opensearch.query[x].startPage = loop.xmlAttributes.startPage;
							if( StructKeyExists(loop.xmlAttributes,'language') ) feed.opensearch.query[x].language = loop.xmlAttributes.language;
							if( StructKeyExists(loop.xmlAttributes,'inputEncoding') ) feed.opensearch.query[x].inputEncoding = loop.xmlAttributes.inputEncoding;
							if( StructKeyExists(loop.xmlAttributes,'outputEncoding') ) feed.opensearch.query[x].outputEncoding = loop.xmlAttributes.outputEncoding;
						}
					}
				}
			}
			//end shared extensions
			//return the feed struct
			return feed;
		</cfscript>
	</cffunction>

<!---------------------------------------- PRIVATE METHODS ----------------------------------------------->

	<!--- Read cache directory --->
	<cffunction name="readCacheDir" access="private" output="false" returntype="query" hint="Read the cache directory using a filter">
		<!--- ******************************************************************************** --->
		<cfargument name="filter" type="string" required="false" default="*" hint="The file filter to use if sent else * is default"/>
		<!--- ******************************************************************************** --->
		<cfset var qFiles = "">
		<!--- Get Directory Listing --->
		<cfdirectory directory="#getCacheLocation()#" action="list" name="qFiles" filter="#arguments.filter#.xml">
		<cfreturn qFiles>
	</cffunction>

	<!--- URL to cache key --->
	<cffunction name="URLToCacheKey" access="private" output="false" returntype="string" hint="Convert a url to a cache key representation">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" type="string" required="yes" hint="The feed url to parse or retrieve from cache">
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

	<!--- Create user-agent --->
	<cffunction name="createUserAgent" access="package" output="false" returntype="string" hint="Creates a ColdBox user agent used in HTTP requests">
		<cfscript>
			var ua = "ColdBox/";
			ua = ua & getSetting("version",1); // ColdBox version
			ua = ua & ' (#server.coldfusion.productname# #server.coldfusion.productversion#;#getPlugin('JVMUtils').getOSName()#)'; // CFML engine and operating system
			return ua;
		</cfscript>
	</cffunction>
	
	<cffunction name="downloadFeed" access="package" output="false" returntype="string" hint="">
		<cfargument name="feedURL" 	type="string" required="yes" hint="The url to retrieve the feed from.">
		<cfset var feedResult = structNew()>
		<cfset var xmlDoc = "">
		<!--- Retrieve feed --->
		<cfhttp method="get" url="#arguments.feedURL#" 
			charset="utf-8"
				resolveurl="yes" 
				redirect="yes" 
				timeout="#gethttpTimeout()#" 
				result="feedResult" 
				useragent="#createUserAgent()#">
			<!--- HTTP compression algorithm decompress --->
			<cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0">
			<cfhttpparam type="Header" name="TE" value="deflate;q=0">
		</cfhttp>
		<!--- for these error messages, allow support for multiple feeds, ie to output the feed that is generating the error rather than just assume it is the first one --->
		<cftry>
			<!--- Attempt to parse the XML document and remove Byte-Order-Mark (BOM) which is not compatible with XMLParse() --->
			<cfset xmlDoc = XMLParse(REReplace(trim(feedResult.FileContent), "^[^<]*", "", "all"))>
			<cfcatch type="Expression">
				<cfthrow type="FeedReader.FeedParsingException"
						 message="Error parsing the feed into an XML document. Please verify that the feed is correct and valid"
						 detail="The returned cfhttp content belonging to (#arguments.feedURL#) : <pre>#XMLFormat(feedResult.fileContent.toString())#</pre>">
			</cfcatch>
		</cftry>

		<!--- Validate to see if it is a Atom or RSS/RDF feed --->
		<cfif not structKeyExists(xmlDoc,"rss") and not structKeyExists(xmlDoc,"feed") and not structKeyExists(xmlDoc,"rdf:RDF")>
			<cfthrow type="FeedReader.FeedParsingException"
					 message="Cannot continue parsing the feed since it does not seem to be a valid RSS, RDF or Atom feed. Please verify that the feed is correct and valid"
					 detail="The XML document belonging to (#arguments.feedURL#) : #htmlEditFormat(toString(xmlDoc))#">
		</cfif>
		
		<!--- Return downloaded feed as a structure --->
		<cfreturn xmlDoc/>
	</cffunction>

	<!--- GET/SET lock name --->
	<cffunction name="getlockName" access="private" returntype="string" output="false" >
		<cfreturn instance.lockName>
	</cffunction>
	<cffunction name="setlockName" access="private" returntype="void" output="false">
		<cfargument name="lockName" type="string" required="true">
		<cfset instance.lockName = arguments.lockName>
	</cffunction>

<!---------------------------------------- ACCESSOR/MUTATORS --------------------------------------------------->

	<!--- Cache tTimeout --->
	<cffunction name="getcacheTimeout" access="public" returntype="numeric" output="false" hint="The cache timeout in minutes">
		<cfreturn instance.cacheTimeout>
	</cffunction>
	<cffunction name="setcacheTimeout" access="public" returntype="void" output="false" hint="Set the cache timeout in minutes">
		<cfargument name="cacheTimeout" type="numeric" required="true">
		<cfset instance.cacheTimeout = arguments.cacheTimeout>
	</cffunction>

	<!--- Cache location --->
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

	<!--- Use cache? --->
	<cffunction name="getuseCache" access="public" returntype="boolean" output="false" hint="Whether using file cache or not">
		<cfreturn instance.useCache>
	</cffunction>
	<cffunction name="setuseCache" access="public" returntype="void" output="false" hint="Set whether to use file caching or not">
		<cfargument name="useCache" type="boolean" required="true">
		<cfset instance.useCache = arguments.useCache>
	</cffunction>

	<!--- GET/SET cache type --->
	<cffunction name="getcacheType" access="public" returntype="string" output="false">
		<cfreturn instance.cacheType>
	</cffunction>
	<cffunction name="setcacheType" access="public" returntype="void" output="false">
		<cfargument name="cacheType" type="string" required="true">
		<cfset instance.cacheType = arguments.cacheType>
	</cffunction>

	<!--- GET/SET cache prefix. --->
	<cffunction name="getcachePrefix" access="public" returntype="string" output="false">
		<cfreturn instance.cachePrefix>
	</cffunction>
	<cffunction name="setcachePrefix" access="public" returntype="void" output="false">
		<cfargument name="cachePrefix" type="string" required="true">
		<cfset instance.cachePrefix = arguments.cachePrefix>
	</cffunction>

</cfcomponent>