<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Luis Majano and Ben Garrett
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
	This is not a recommended ColdBox design practise but it will give you a
	quick result while learning how to use this plug-in. In an eventhandler file
	create a new event, maybe call it 'feeddump'. Then add the code, change the
	URL and run the event.
	
	<cfset var rc = event.getCollection()>
	<cfset rc.webfeed = getPlugin("feedReader").retrieveFeed("http://www.example.com/feeds/rss")>
	<cfdump var="#rc.webfeed#">
	<cfabort>

----------------------------------------------------------------------->

<cfcomponent name="FeedReader" 
			 extends="coldbox.system.plugin"
			 hint="A feed reader plug-in. We recommend that when you call the readFeed method, that you use url's as settings. ex: readFeed(getSetting('myFeedURL')). The settings this plug-in uses are the following: FeedReader_useCache:boolean [default=true], FeedReader_cacheLocation:string, FeedReader_cacheTimeout:numeric [default=30 min], FeedReader_httpTimeout:numeric [default=30 sec]. If the cacheLocation directory does not exist, the plug-in will throw an error. So please remember to create the directory."
			 cache="true">

<!---------------------------------------- CONSTRUCTOR --------------------------------------------------->

	<cffunction name="init" access="public" returntype="FeedReader" output="false" hint="Plug-in constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			var cacheLocation = "";
			var slash = "";

			/* Super */
			super.Init(arguments.controller);

			/* Plug-in Properties */
			setpluginName("FeedReader");
			setpluginVersion("2.0");
			setpluginDescription("I am a feed reader for rdf, rss and atom feeds.");
			setpluginAuthor("Ben Garrett");
			setpluginAuthorURL("http://www.coldbox.org");

			/* Check if using cache and set useCache setting */
			if( not settingExists('FeedReader_useCache') or not isBoolean(getSetting('FeedReader_useCache')) ){
				setUseCache(true);
			}else{
				setUseCache(getSetting('FeedReader_useCache'));
			}

			/* Setup caching variables if enabled */
			if( getUseCache() ){	

				/* RAM caching used by default */
				if( not settingExists('FeedReader_cacheType') or not reFindNoCase("^(ram|file)$",getSetting('FeedReader_cacheType')) ){
					setCacheType('ram');
				}
				else{
					setCacheType(getSetting('FeedReader_cacheType'));
				}

				/* File caching */
				if( getCacheType() eq "file" ){
					/* Cache prefix */
					setCachePrefix('');
					/* File separator */
					slash = getSetting("OSFileSeparator",true);
					/* Cache location */
					if( not settingExists('FeedReader_cacheLocation') ){
						throw(message="The setting FeedReader_cacheLocation is missing, please create it.",type='plugins.FeedReader.InvalidSettingException');
					}
					/* Tests if the directory exists: full path */
					/* Try to locate the path */
					cacheLocation = locateDirectoryPath(getSetting('FeedReader_cacheLocation'));
					/* Validate it */
					if( len(cacheLocation) eq 0 ){
						throw('The cache location directory could not be found, please check again. #getSetting('FeedReader_cacheLocation')#','','plugins.FeedReader.InvalidCacheLocationException');
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

<!---------------------------------------- INTERNAL CACHE OPERATIONS --------------------------------------------------->

	<!--- flushCache --->
	<cffunction name="flushCache" output="false" access="public" returntype="void" hint="Flushes the entire file cache by removing all the entries">
		<cfset var qFiles = "">
		<cfset var slash = getSetting("OSFileSeparator",true)>

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

	<!--- How many elements in cache --->
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
				<cfthrow message="The feed does not exist in the cache." type="customPlugins.plugins.FeedReader">
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

	<!--- flushCache --->
	<cffunction name="removeCachedFeed" output="false" access="public" returntype="boolean" hint="Purges a feed from the cache, returns false if feed is not found">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" type="string" required="yes" hint="The url to purge from the cache">
		<!--- ******************************************************************************** --->
		<cfset var results = false>
		<cfset var cacheFile = "">

		<cfif getCacheType() eq "ram">
			<cfreturn getColdboxOCM().clearKey(URLToCacheKey(arguments.feedURL))>
		<cfelse>
			<!--- Cache file --->
			<cfset cacheFile = getCacheLocation() & getSetting("OSFileSeparator",true) & URLToCacheKey(arguments.feedURL)>
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

	<!--- Get Feed From Cache --->
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
			<cfset cacheFile = getCacheLocation() & getSetting("OSFileSeparator",true) & URLToCacheKey(arguments.feedURL)>
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
			<cfset cacheFile = getCacheLocation() & getSetting("OSFileSeparator",true) & cacheKey>
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

<!---------------------------------------- PUBLIC FEED METHODS --------------------------------------------------->

	<cffunction name="readFeed" access="public" returntype="struct" hint="Read a feed sourced from HTTP or from cache. Return a universal structure representation of the feed.">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" 		type="string"  required="yes" hint="The feed url to parse or retrieve from cache">
		<cfargument name="itemsType" 	type="string"  required="false" default="array" hint="The type of the items either query or array, array is used by default"/>
		<cfargument name="maxItems" 	type="numeric" required="false" default="0" hint="The maximum number of entries to retrieve, default is display all"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var FeedStruct = structnew();
			/* Check if using cache */
			if( not getUseCache() ){
				throw("You are trying to use a method that needs caching enabled.","Please look at the plug-in settings or just use the 'retrieveFeed' method.","plugins.FeedReader.InvalidSettingException");
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

	<!--- ******************************************************************************** --->

	<cffunction name="retrieveFeed" access="public" returntype="struct" hint="This method does a cfhttp call on the feed url and returns a universal parsed feed structure. You can use this when you don't want to use the cache facilities.">
		<!--- ******************************************************************************** --->
		<cfargument name="feedURL" 		type="string" required="yes" hint="The url to retrieve the feed from.">
		<cfargument name="itemsType" 	type="string" required="false" default="array" hint="The type of the items either query or array, array is default"/>
		<cfargument name="maxItems" 	type="numeric" required="false" default="0" hint="The max number of entries to retrieve, default is all"/>
		<!--- ******************************************************************************** --->
		<cfset var xmlDoc = "">
		<cfset var feedResult = structnew()>

		<!--- Check for return type --->
		<cfif not reFindnocase("^(query|array)$",arguments.itemsType)>
			<cfset arguments.itemsType = "query">
		</cfif>

		<!--- Replace protocols --->
		<cfset arguments.feedURL = ReplaceNoCase(arguments.feedURL,"feed://","http://")>

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

		<cftry>
			<!--- Attempt to parse the XML document and remove Byte-Order-Mark (BOM) which is not compatible with XMLParse() --->
			<cfset xmlDoc = XMLParse(REReplace(trim(feedResult.FileContent), "^[^<]*", "", "all"))>
			<cfcatch type="Expression">
				<cfthrow type="plugins.FeedReader.FeedParsingException"
						 message="Error parsing the feed into an XML document. Please verify that the feed is correct and valid"
						 detail="The returned cfhttp content is: <pre>#XMLFormat(feedResult.fileContent.toString())#</pre>">
			</cfcatch>
		</cftry>

		<!--- Validate to see if it is a Atom or RSS/RDF feed --->
		<cfif not structKeyExists(xmlDoc,"rss") and not structKeyExists(xmlDoc,"feed") and not structKeyExists(xmlDoc,"rdf:RDF")>
			<cfthrow type="plugins.FeedReader.FeedParsingException"
					 message="Cannot continue parsing the feed since it does not seem to be a valid RSS, RDF or Atom feed. Please verify that the feed is correct and valid"
					 detail="The XML document is: #htmlEditFormat(toString(xmlDoc))#">
		</cfif>

		<!--- Return a universal parsed structure --->
		<cfreturn parseFeed(xmlDoc,arguments.itemsType,arguments.maxItems)>
	</cffunction>

	<!--- ******************************************************************************** --->

	<cffunction name="isDateISO8601" access="public" returntype="boolean" hint="Checks if a date is in ISO8601 format" output="false" >
		<cfargument name="datetime" required="true" type="string" hint="The datetime string to check">
		<cfscript>
			if( REFind("[[:digit:]]T[[:digit:]]", arguments.datetime) )
				return true;
			else
				return false;
		</cfscript>
	</cffunction>

	<!--- ******************************************************************************** --->

	<cffunction name="parseFeed" access="public" returntype="struct" hint="This parses a feed as a XML document and returns the results as a structure of elements">
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
		<cfset var oUtilities = getPlugin("Utilities")>

		<cfscript>
			// check to make sure arguments.xmlDoc is a XML document, not just a URL or path pointing to a feed
			if( not IsXML(arguments.xmlDoc) ) {
				throw('There is a problem with the xmlDoc provided with the parseFeed method, it is not a variable containing a valid xml document','The xmlDoc contains: #htmlEditFormat(toString(arguments.xmlDoc))#','plugins.FeedReader.FeedParsingException');
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
			/* Set the elements */
			feed.author = StructNew();
			feed.author.email = "";
			feed.author.name = "";
			feed.author.url = "";
			feed.category = ArrayNew(1);
			feed.datebuilt = "";
			feed.dateupdated = "";
			feed.description = "";
			feed.image = StructNew();
			feed.image.description = "";
			feed.image.height = "";
			feed.image.icon = "";
			feed.image.link = "";
			feed.image.title = "";
			feed.image.url = "";
			feed.image.width = "";
			feed.language = "";
			feed.rating = "";
			feed.rights = StructNew();
			feed.rights.creativecommons = "";
			feed.rights.copyright = "";
			feed.title = "";
			feed.websiteurl = "";
			/* OpenSearch */
			feed.opensearch = StructNew();
			feed.opensearch.autodiscovery = StructNew();
			feed.opensearch.autodiscovery.url = "";
			feed.opensearch.autodiscovery.title = "";
			feed.opensearch.itemsperpage = "";
			feed.opensearch.startindex = "";
			feed.opensearch.totalresults = "";
			feed.opensearch.query = ArrayNew(1);

			// Get rss/rdf 1 & rss 2
			if(feed.specs.type is "RDF" or feed.specs.type is "RSS") {
				/* Parse items */
				if(feed.specs.type is "RDF") {
					if( not StructKeyExists(xmlDoc.xmlRoot,'item') ) feed.items = parseRSSItems(arrayNew(1),arguments.itemsType,arguments.maxItems);
					else feed.items = parseRSSItems(xmlDoc.xmlRoot.item,arguments.itemsType,arguments.maxItems);
				}
				else if(feed.specs.type is "RSS") {
					if( not StructKeyExists(xmlDoc.xmlRoot.channel,'item') ) feed.items = parseRSSItems(arrayNew(1),arguments.itemsType,arguments.maxItems);
					else feed.items = parseRSSItems(xmlDoc.xmlRoot.channel.item,arguments.itemsType,arguments.maxItems);
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
				feed.DateBuilt = findCreatedDate(xmlDoc.xmlRoot.channel);
				if( isDateISO8601(feed.DateBuilt) ) feed.DateBuilt = oUtilities.parseISO8601(feed.DateBuilt);
				else feed.DateBuilt = oUtilities.parseRFC822(feed.DateBuilt);
				feed.DateUpdated = findUpdatedDate(xmlDoc.xmlRoot.channel);
				if( isDateISO8601(feed.DateUpdated) ) feed.DateUpdated = oUtilities.parseISO8601(feed.DateUpdated);
				else feed.DateUpdated = oUtilities.parseRFC822(feed.DateUpdated);
				// Dubline Core date as dateupdated
				if( StructKeyExists(xmlDoc.xmlRoot.channel,"dc:date") and not len(feed.dateupdated) ) { 
					if( isDateISO8601(feed.dateupdated) ) { feed.dateupdated = oUtilities.parseISO8601(xmlDoc.xmlRoot.channel["dc:date"].xmlText); }
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
				if( not isDefined("xmlDoc.xmlRoot.entry") ) feed.items = parseAtomItems(arrayNew(1),arguments.itemsType,arguments.maxItems);
				else feed.items = parseAtomItems(xmlDoc.xmlRoot.entry,arguments.itemsType,arguments.maxItems);
				/* Author information */
				if(structKeyExists(xmlDoc.xmlRoot,"author")){
					if( structKeyExists(xmlDoc.xmlRoot.author,"name") ) feed.author.name = normalizeAtomTextConstruct(xmlDoc.xmlRoot.author.name);
					if( structKeyExists(xmlDoc.xmlRoot.author,"uri") ) feed.author.url = normalizeAtomTextConstruct(xmlDoc.xmlRoot.author.uri);
					if( structKeyExists(xmlDoc.xmlRoot.author,"email") ) feed.author.email = normalizeAtomTextConstruct(xmlDoc.xmlRoot.author.email);
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
				feed.datebuilt = oUtilities.parseISO8601(findCreatedDate(xmlDoc.xmlRoot));
				feed.dateupdated = oUtilities.parseISO8601(findUpdatedDate(xmlDoc.xmlRoot));
				/* Description */
				if(StructKeyExists(xmlDoc.xmlRoot,"info")) 
					feed.Description =normalizeAtomTextConstruct(xmlDoc.xmlRoot.info);
				else if(StructKeyExists(xmlDoc.xmlRoot,"subtitle")) 
					feed.Description = normalizeAtomTextConstruct(xmlDoc.xmlRoot.subtitle);
				else if(StructKeyExists(xmlDoc.xmlRoot,"tagline")) 
					feed.Description = normalizeAtomTextConstruct(xmlDoc.xmlRoot.tagline);
				/* Image */
				if(StructKeyExists(xmlDoc.xmlRoot,"icon")) feed.image.icon = normalizeAtomTextConstruct(xmlDoc.xmlRoot.icon);
				if(StructKeyExists(xmlDoc.xmlRoot,"logo")) feed.image.url = normalizeAtomTextConstruct(xmlDoc.xmlRoot.logo);
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
				if(StructKeyExists(xmlDoc.xmlRoot,"rights")) feed.rights.copyright = normalizeAtomTextConstruct(xmlDoc.xmlRoot.rights);
				/* Title */
				if(StructKeyExists(xmlDoc.xmlRoot,"title"))	feed.title = normalizeAtomTextConstruct(xmlDoc.xmlRoot.title);
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

<!---------------------------------------- PRIVATE --------------------------------------------------->

	<!--- Parse Atom Items --->
	<cffunction name="parseAtomItems" access="private" returntype="any" hint="Parse the items an return an array of structures" output="false" >
		<!--- ******************************************************************************** --->
		<cfargument name="items" 		type="any" 		required="true" hint="The xml of items">
		<cfargument name="itemsType" 	type="string" 	required="false" default="array" hint="The type of the items either query or array, array is used by default"/>
		<cfargument name="maxItems" 	type="numeric" 	required="false" default="0" hint="The maximum number of entries to retrieve, default is display all"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var x = 1;
			var y = 1;
			var itemLength = arrayLen(arguments.items);
			var itemStruct = StructNew();
			var rtnItems = "";
			var node = "";
			var loop = "";
			var oUtilities = getPlugin("Utilities");

			/* Items length */
			if( arguments.maxItems neq 0 and arguments.maxItems lt itemLength ){
				itemLength = arguments.maxItems;
			}

			/* Correct return items type */
			if( arguments.itemsType eq "array")
				rtnItems = ArrayNew(1);
			else
				rtnItems = QueryNew("attachment,author,body,category,comments,datepublished,dateupdated,id,rights,title,url");
			/* Loop and add to array */
			for(x=1; x lte itemLength; x=x + 1){
				/* new node */
				node = structnew();
				/* Basic node */
				node.attachment = ArrayNew(1);	
				node.author = "";
				node.body = "";
				node.category = ArrayNew(1);
				node.comments = StructNew();
				node.comments.count = "";
				node.comments.hit_parade = "";
				node.comments.url = "";	
				node.datepublished = "";
				node.dateupdated = "";
				node.id = "";
				node.rights = "";
				node.title = "";
				node.url = "";
				/* Author */
				node.author = findAuthor(items[x]);
				/* Attachments (MediaRSS media content) */
				node.attachment = findMediaContent(items[x],node.attachment);
				/* Category */
				node.category = findCategory(items[x],node.category);
				/* Body (MediaRSS description or Atom content/summary) */
				if( structKeyExists(items,"media:group") and structKeyExists(items[x]["media:group"],"media:description") and len(items[x]["media:group"]["media:description"].xmlText) ) node.body = normalizeAtomTextConstruct(items[x]["media:group"]["media:description"]);
				else if( structKeyExists(items[x],"media:description") and len(items[x]["media:description"].xmlText) ) node.body = normalizeAtomTextConstruct(items[x]["media:description"]);
				else if( structKeyExists(items[x],"content") and len(items[x]["content"].xmlText) ) node.body = normalizeAtomTextConstruct(items[x].content);
				else if( structKeyExists(items[x],"summary") and len(items[x]["summary"].xmlText) ) node.body = normalizeAtomTextConstruct(items[x].summary);
				/* Comments (GoogleData API) */
				node.comments = findComments(items[x],node.comments);
				/* Date and updated dates */
				node.datepublished = oUtilities.parseISO8601(findCreatedDate(items[x]));
				node.dateupdated = oUtilities.parseISO8601(findUpdatedDate(items[x]));
				/* Id */
				if( structKeyExists(items[x],"id") ) node.id = normalizeAtomTextConstruct(items[x].id);
				/* Links & attachments */	
				if( structKeyExists(items[x],"link") ){
					for(y=1; y lte arrayLen(items[x].link);y=y+1){
						if ( items[x].link[y].xmlAttributes.rel is "alternate" and StructKeyExists(items[x].link[y].xmlAttributes,'href') ){
							node.url = items[x].link[y].xmlAttributes.href;
						}
						else if ( items[x].link[y].xmlAttributes.rel is "enclosure" and StructKeyExists(items[x].link[y].xmlAttributes,'href')){
							itemStruct = StructNew();
							itemStruct.duration = "";
							itemStruct.mimetype = "";
							itemStruct.filesize = "";
							itemStruct.type = "enclosure";
							itemStruct.url = items[x].link[y].xmlAttributes.href;
							if ( StructKeyExists(items[x].link[y].xmlAttributes,'length') ) itemStruct.filesize = items[x].link[y].xmlAttributes.length;
							if ( StructKeyExists(items[x].link[y].xmlAttributes,'type') ) itemStruct.mimetype = items[x].link[y].xmlAttributes.type;
							ArrayAppend(node.attachment,itemStruct);
						}
					}
				}
				/* Keywords */
				node.keywords = findKeywords(node.category);
				/* Rights */
				if( structKeyExists(items,"media:group") and structKeyExists(items[x]["media:group"],"media:copyright") ) node.rights = normalizeAtomTextConstruct(items[x]["media:group"]["media:copyright"]);
				else if( structKeyExists(items[x],"media:copyright") ) node.rights = normalizeAtomTextConstruct(items[x]["media:copyright"]);
				else if( structKeyExists(items[x],"rights") ) node.rights = normalizeAtomTextConstruct(items[x].rights);
				/* Thumbnail previews */
				node.attachment = findThumbnails(items[x],node.attachment);
				/* Title */
				if( structKeyExists(items,"media:group") and structKeyExists(items[x]["media:group"],"media:title") ) node.title = normalizeAtomTextConstruct(items[x]["media:group"]["media:title"]);
				else if( structKeyExists(items[x],"media:title") ) node.title = normalizeAtomTextConstruct(items[x]["media:title"]);
				else if( structKeyExists(items[x],"title") ) node.title = normalizeAtomTextConstruct(items[x].title);

				if( arguments.itemsType eq "array" ){
					// Append to array
					ArrayAppend(rtnItems,node);
				}
				else{
					QueryAddRow(rtnItems,1);
					if( arrayLen(node.attachment) ) QuerySetCell(rtnItems, "attachment", node.attachment[1].url);
					else QuerySetCell(rtnItems, "attachment", "");
					QuerySetCell(rtnItems, "author", node.author);
					QuerySetCell(rtnItems, "category", findKeywords(node.category));
					QuerySetCell(rtnItems, "comments", node.comments.count);
					QuerySetCell(rtnItems, "body", node.body);
					QuerySetCell(rtnItems, "datepublished", node.datepublished);
					QuerySetCell(rtnItems, "dateupdated", node.dateupdated);
					QuerySetCell(rtnItems, "id", node.id);
					QuerySetCell(rtnItems, "rights", node.rights);
					QuerySetCell(rtnItems, "title", node.title);
					QuerySetCell(rtnItems, "url", node.url);
				}
			}
			/* Return items */
			return rtnItems;
		</cfscript>
	</cffunction>

	<!--- Parse rss/rdf items --->
	<cffunction name="parseRSSItems" access="private" returntype="any" hint="Parse the items an return an array of structures" output="false" >
		<!--- ******************************************************************************** --->
		<cfargument name="items" 		type="any" 		required="true" hint="The xml of items">
		<cfargument name="itemsType" 	type="string" 	required="false" default="array" hint="The type of the items either query or array, array is used by default"/>
		<cfargument name="maxItems" 	type="numeric" 	required="false" default="0" hint="The maximum number of entries to retrieve, default is display all"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var x = 1;
			var itemLength = arrayLen(arguments.items);
			var rtnItems = "";
			var node = "";
			var loop = "";
			var merge = "";
			var oUtilities = getPlugin("Utilities");

			/* Itemslength */
			if( arguments.maxItems neq 0 and arguments.maxItems lt itemLength ){
				itemLength = arguments.maxItems;
			}

			/* Correct return items type */
			if( arguments.itemsType eq "array")
				rtnItems = ArrayNew(1);
			else
				rtnItems = QueryNew("attachment,author,category,comments,body,datepublished,dateupdated,id,rights,title,url");

			/* Loop and add to array */
			for(x=1; x lte itemLength; x=x + 1){
				/* new node */
				node = structnew();
				/* basic node */
				node.attachment = ArrayNew(1);	
				node.author = "";
				node.body = "";	
				node.category = ArrayNew(1);	
				node.comments = StructNew();
				node.comments.count = "";
				node.comments.hit_parade = "";
				node.comments.url = "";
				node.datepublished = "";
				node.dateupdated = "";
				node.id = "";
				node.keywords = "";	
				node.rights = "";	
				node.title = "";	
				node.url = "";

				/* Attachments (MediaRSS media content) */
				node.attachment = findMediaContent(items[x],node.attachment);
				/* Attachments aka enclosures */
				if( structKeyExists(items[x],"enclosure") and structKeyExists(items[x].enclosure.xmlAttributes,"url") ){
					for(y=1; y lte arrayLen(items[x].enclosure);y=y+1){
						if ( StructKeyExists(items[x].enclosure[y].xmlAttributes,'url')){
							itemStruct = StructNew();
							itemStruct.duration = "";
							itemStruct.filesize = "";
							itemStruct.mimetype = "";
							itemStruct.type = "enclosure";
							itemStruct.url = items[x].enclosure[y].xmlAttributes.url;
							if ( StructKeyExists(items[x],"itunes:duration") ) itemStruct.duration = items[x]["itunes:duration"].xmlText;
							if ( StructKeyExists(items[x].enclosure[y].xmlAttributes,'length') ) itemStruct.filesize = items[x].enclosure[y].xmlAttributes.length;
							if ( StructKeyExists(items[x].enclosure[y].xmlAttributes,'type') ) itemStruct.mimetype = items[x].enclosure[y].xmlAttributes.type;
							ArrayAppend(node.attachment,itemStruct);
						}
					}
				}
				/* Author */
				node.author = findAuthor(items[x]);
				/* Body aka description */
				if( structKeyExists(items,"media:group") and structKeyExists(items[x]["media:group"],"media:description") and len(items[x]["media:group"]["media:description"].xmlText) ) node.body = normalizeAtomTextConstruct(items[x]["media:group"]["media:description"]);
				else if( structKeyExists(items[x],"media:description") and len(items[x]["media:description"].xmlText) ) node.body = normalizeAtomTextConstruct(items[x]["media:description"]);
				else if( structKeyExists(items[x],"content:encoded") ) node.body = items[x]["content:encoded"].xmlText;
				else if( structKeyExists(items[x],"description") ) node.body = items[x].description.xmlText;
				else if( structKeyExists(items[x],"dc:description") ) node.body = items[x]["dc:description"].xmlText;
				else if( StructKeyExists(items[x],"itunes:subtitle") ) node.body = items[x]["itunes:subtitle"].xmlText;
				else if( StructKeyExists(items[x],"itunes:summary") ) node.body = items[x]["itunes:summary"].xmlText;
				/* Category */
				node.category = findCategory(items[x],node.category);
				/* Comments */
				if( structKeyExists(items[x],"comments") ) {
					for(y=1; y lte arrayLen(items[x]["comments"]); y=y+1){
						if( structKeyExists(items[x],"slash:comments") and isNumeric(items[x]["slash:comments"][y].xmlText) ) node.comments.count = items[x]["comments"][y].xmlText;
						else node.comments.url = items[x]["comments"][y].xmlText;
					}
				}
				if( structKeyExists(items[x],"slash:comments") ) node.comments.count = items[x]["slash:comments"].xmlText;
				if( structKeyExists(items[x],"slash:hit_parade") ) node.comments.hit_parade = items[x]["slash:hit_parade"].xmlText;
				/* Comments (GoogleData API, overwrites slash comments if there is a clash) */
				node.comments = findComments(items[x],node.comments);
				/* Dates */
				node.datepublished = findCreatedDate(items[x]);
				if( isDateISO8601(node.datepublished) ){ 
					node.datepublished = oUtilities.parseISO8601(node.datepublished);
				}
				else{ 
					node.datepublished = oUtilities.parseRFC822(node.datepublished);
				}
				node.dateupdated = findUpdatedDate(items[x]);
				if( isDateISO8601(node.dateupdated) ){
					node.dateupdated = oUtilities.parseISO8601(node.dateupdated);
				}
				else{
					node.dateupdated = oUtilities.parseRFC822(node.dateupdated);
				}
				// verify dates
				if( len(node.datepublished) neq 0 and len(node.dateupdated) eq 0){
					node.dateupdated = node.datepublished;
				}
				else if( len(node.dateupdated) neq 0 and len(node.datepublished) eq 0){
					node.datepublished = node.dateupdated;
				}
				/* Id */
				if( structKeyExists(items[x],"guid") ) node.id = items[x].guid.xmlText;
				else if( structKeyExists(items[x],"dc:identifier") ) node.id = items[x]["dc:identifier"].xmlText;
				else if( structKeyExists(items[x],"link") ) node.id = items[x].link.xmlText;
				/* Keywords */
				node.keywords = findKeywords(node.category);
				/* Link */
				if ( structKeyExists(items[x],"link") ){
					node.url = items[x].link.xmlText;
				}
				else if ( structKeyExists(items[x],"guid") and (not structKeyExists(items[x].guid.xmlAttributes, "isPermaLink") or items[x].guid.xmlAttributes.isPermaLink) ){
					node.url = items[x].guid.xmlText;
				}
				else if ( structKeyExists(items[x],"source") and structKeyExists(items[x].source.xmlAttributes,"url") ){
					node.url = items[x].source.xmlAttributes.url;
				}
				/* Rights (uses Creative Commons, MRSS or DC extensions) */
				if( structKeyExists(items[x],"creativeCommons:license") and not len(node.rights) ) node.rights = items[x]["creativeCommons:license"].xmlText;
				else if( structKeyExists(items,"media:group") and structKeyExists(items[x]["media:group"],"media:copyright") ) node.rights = normalizeAtomTextConstruct(items[x]["media:group"]["media:copyright"]);
				else if( structKeyExists(items[x],"media:copyright") ) node.rights = normalizeAtomTextConstruct(items[x]["media:copyright"]);
				else if( structKeyExists(items[x],"dc:rights") ) node.rights = items[x]["dc:rights"].xmlText;
				/* Thumbnail previews */
				node.attachment = findThumbnails(items[x],node.attachment);
				/* Title */
				if( structKeyExists(items,"media:group") and structKeyExists(items[x]["media:group"],"media:title") ) node.title = normalizeAtomTextConstruct(items[x]["media:group"]["media:title"]);
				else if( structKeyExists(items[x],"media:title") ) node.title = normalizeAtomTextConstruct(items[x]["media:title"]);
				else if( structKeyExists(items[x],"title") ) node.title = items[x].title.xmlText;
				else if( structKeyExists(items[x],"dc:title") ) node.title = items[x]["dc:title"].xmlText;

				if( arguments.itemsType eq "array" ){
					/* Append to array */
					ArrayAppend(rtnItems,node);
				}

				else{
					QueryAddRow(rtnItems,1);
					if( arrayLen(node.attachment) ) QuerySetCell(rtnItems, "attachment", node.attachment[1].url);
					else QuerySetCell(rtnItems, "attachment", "");
					QuerySetCell(rtnItems, "author", node.author);
					QuerySetCell(rtnItems, "category", findKeywords(node.category));
					QuerySetCell(rtnItems, "category", node.category);
					QuerySetCell(rtnItems, "comments", node.comments.count);
					QuerySetCell(rtnItems, "body", node.body);
					QuerySetCell(rtnItems, "datepublished", node.datepublished);
					QuerySetCell(rtnItems, "dateupdated", node.dateupdated);
					QuerySetCell(rtnItems, "id", node.id);
					QuerySetCell(rtnItems, "rights", node.rights);
					QuerySetCell(rtnItems, "title", node.title);
					QuerySetCell(rtnItems, "url", node.url);
				}

			}//end of for loop 	
		/* Return items */
		return rtnItems;
		</cfscript>
	</cffunction>

	<!--- readCacheDir --->
	<cffunction name="readCacheDir" output="false" access="private" returntype="query" hint="Read the cahe directory using a filter">
		<!--- ******************************************************************************** --->
		<cfargument name="filter" type="string" required="false" default="*" hint="The file filter to use if sent else * is default"/>
		<!--- ******************************************************************************** --->
		<cfset var qFiles = "">
		<!--- Get Directory Listing --->
		<cfdirectory directory="#getCacheLocation()#" action="list" name="qFiles" filter="#arguments.filter#.xml">
		<cfreturn qFiles>
	</cffunction>

	<!--- URL to cache key --->
	<cffunction name="URLToCacheKey" output="false" access="private" returntype="string" hint="Convert a url to a cache key representation">
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

	<!--- Normalize an Atom text construct --->
	<cffunction name="normalizeAtomTextConstruct" access="private" output="false" returntype="string" hint="Send an element and it will return the appropriate text construct">
		<cfargument name="entity" required="true" hint="The XML construct" />
		<cfscript>
			var results = "";
			var x = 1;
			/* Check for type */
			if( structKeyExists(arguments.entity.xmlAttributes,"type") ){
				if( arguments.entity.xmlAttributes.type is "xhtml" ){
					if( not structKeyExists(arguments.entity,"div") ){
						throw("Invalid Atom data: XHTML text construct does not contain a child DIV tag.",'','plugins.FeedReader.InvalidAtomConstruct');	
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
				/* No type just return text */
				results = arguments.entity.xmlText;
			}
			/* Return results */
			return results;
		</cfscript>
	</cffunction>

	<!--- Create User-Agent --->
	<cffunction name="createUserAgent" access="private" output="false" returntype="string" hint="Creates a ColdBox user agent used in HTTP requests">
		<cfscript>
			var ua = "ColdBox/";
			ua = ua & getSetting("version",1); // ColdBox version
			ua = ua & ' (#server.coldfusion.productname# #server.coldfusion.productversion#;#getPlugin('utilities').getOSName()#)'; // CFML engine and operating system
			return ua;
		</cfscript>
	</cffunction>
	
	<!--- Get Author --->
	<cffunction name="findAuthor" access="private" output="false" returntype="string" hint="Parse an item and find an author">
		<!--- ******************************************************************************** --->
		<cfargument name="itemRoot" type="xml" required="true" hint="The item to look in"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var item = arguments.itemRoot;
			var path = "";
			var y = 1;
			if( structKeyExists(item,"media:group") and structKeyExists(item["media:group"],"media:credit") ) path = item["media:group"]["media:credit"];
			else if (structKeyExists(item,"media:credit") ) path = item["media:credit"];
			if( len(path) ){
				for(y=1; y lte arrayLen(path);y=y+1){
					if( isStruct(path[y]) and structKeyExists(path[y],'role') and path[y].role is "author" ) return path[y].xmlText;
					else if( not isStruct(path[y]) and not structKeyExists(path[y],'role') ) return path[y].xmlText;
				}
			}
			else if( structKeyExists(item,"author") and structKeyExists(item.author,"name") ) return normalizeAtomTextConstruct(item.author.name); // atom author
			else if( structKeyExists(item,"dc:creator") ) return item["dc:creator"].xmlText; // dublincore creator
			else if( StructKeyExists(item,"itunes:author") ) return item["itunes:author"].xmlText; // itunes author
			else if( structKeyExists(item,"dc:contributor") ) return item["dc:contributor"].xmlText; // dublincore contributor
			else if( structKeyExists(item,"dc:publisher") ) return item["dc:publisher"].xmlText; // dublincore publisher
			return "";
		</cfscript>
	</cffunction>

	<!--- Get Category --->
	<cffunction name="findCategory" access="private" output="false" returntype="array" hint="Parse an item and find a categories">
		<!--- ******************************************************************************** --->
		<cfargument name="itemRoot" type="xml" required="true" hint="The item to look in"/>
		<cfargument name="categorynode" type="array" required="true" hint="Existing category to merge with categories"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var item = arguments.itemRoot;
			var categoryCol = arguments.categorynode;
			var path = "";
			var y = 1;
			// MediaRSS categories
			if( structKeyExists(item,"media:group") and structKeyExists(item["media:group"],"media:category") ) path = item["media:group"]["media:category"];
			else if (structKeyExists(item,"media:category") ) path = item["media:category"];
			if( len(path) ){
				for(y=1; y lte arrayLen(path);y=y+1){
					itemStruct = StructNew();
					itemStruct.tag = path[y].xmlText;
					if( structKeyExists(path[y].xmlAttributes,'scheme') ) itemStruct.domain = path[y].xmlAttributes.scheme;
					else itemStruct.domain = "http://search.yahoo.com/mrss/category/";
					ArrayAppend(categoryCol,itemStruct);
				}
			}
			path = "";
			// mediarss keywords
			if( structKeyExists(item,"media:group") and structKeyExists(item["media:group"],"media:keywords") ) path = item["media:group"]["media:keywords"];
			else if (structKeyExists(item,"media:keywords") ) path = item["media:keywords"];
			if( len(path) ) {
				for(y=1; y lte arrayLen(path);y=y+1){
					itemStruct = StructNew();
					itemStruct.tag = path[y].xmlText;
					itemStruct.domain = "http://search.yahoo.com/mrss/keywords/";
					ArrayAppend(categoryCol,itemStruct);
				}
			}
			path = "";
			// atom and rss categories
			if(StructKeyExists(item,"category")) path = item.category;
			if( len(path) ){
				for(y=1; y lte arrayLen(path); y=y+1){
					// atom
					if( StructKeyExists(path[y].xmlAttributes,'term') and len(path[y].xmlAttributes.term) ) { 
						itemStruct = StructNew();
						itemStruct.tag = path[y].XMLAttributes.term;
						if(StructKeyExists(path[y].xmlAttributes,'scheme')) itemStruct.domain = path[y].xmlAttributes.scheme;
						else itemStruct.domain = ""; 
					}
					// rss
					else if( len(path[y].xmlText) ) { 
						itemStruct = StructNew();
						itemStruct.tag = path[y].xmlText;
						if(StructKeyExists(path[y].xmlAttributes,'domain')) itemStruct.domain = path[y].xmlAttributes.domain;
						else itemStruct.domain = ""; 
					}
					ArrayAppend(categoryCol,itemStruct);
				}
			}
			path = "";
			// Dublin Core subject being used as a category
			if( structKeyExists(item,"dc:subject") ) path = item["dc:subject"];
			if( len(path) ) {
				for(y=1; y lte arrayLen(path);y=y+1){
					itemStruct = StructNew();
					itemStruct.tag = path[y].xmlText;
					itemStruct.domain = "http://purl.org/dc/elements/1.1/subject";
					ArrayAppend(categoryCol,itemStruct);
				}
			}
			path = "";
			// iTunes Category
			if( structKeyExists(item,"itunes:category") ) path = item["itunes:category"];
			if( len(path) ) {
				for(y=1; y lte arrayLen(path);y=y+1){
					itemStruct = StructNew();
					itemStruct.tag = path[y].xmlText;
					itemStruct.domain = "http://www.apple.com/itunes/whatson/podcasts/specs.html##category";
					ArrayAppend(categoryCol,itemStruct);
				}
			}
			path = "";
			// iTunes Keywords
			if( structKeyExists(item,"itunes:keywords") ) path = item["itunes:keywords"];
			if( len(path) ) {
				for(y=1; y lte arrayLen(path);y=y+1){
					itemStruct = StructNew();
					itemStruct.tag = path[y].xmlText;
					itemStruct.domain = "http://www.apple.com/itunes/whatson/podcasts/specs.html##keywords";
					ArrayAppend(categoryCol,itemStruct);
				}
			}
			path = "";
			return categoryCol;
		</cfscript>
	</cffunction> 

	<!--- Get Comments --->
	<cffunction name="findComments" access="private" output="false" returntype="struct" hint="Parse an item and find comments">
		<!--- ******************************************************************************** --->
		<cfargument name="itemRoot" type="xml" required="true" hint="The item to look in"/>
		<cfargument name="commentsnode" type="struct" required="true" hint="Existing comments structure to be updated"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var item = arguments.itemRoot;
			var itemStruct = arguments.commentsnode;
			var path = "";
			var y = 1;
			// google data api
			if( structKeyExists(item,"gd:comments") and structKeyExists(item["gd:comments"],"gd:feedLink") ){
				path = item["gd:comments"]["gd:feedLink"];
				if( structKeyExists(path.XmlAttributes,'href') ) itemStruct.url = path.XmlAttributes.href;
				if( structKeyExists(path.XmlAttributes,'countHint') ) itemStruct.count = path.XmlAttributes.countHint;
			}
			return itemStruct;
		</cfscript>
	</cffunction>

	<!--- Get MediaRSS Content --->
	<cffunction name="findMediaContent" access="private" output="false" returntype="array" hint="Parse an item and find media content">
		<!--- ******************************************************************************** --->
		<cfargument name="itemRoot" type="xml" required="true" hint="The item to look in"/>
		<cfargument name="attachmentnode" type="array" required="true" hint="Existing attachments to merge with media content"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var item = arguments.itemRoot;
			var itemStruct = StructNew();
			var attachmentCol = arguments.attachmentnode;
			var path = "";
			var y = 1;
			if( structKeyExists(item,"media:group") and structKeyExists(item["media:group"],"media:content") ) path = item["media:group"]["media:content"];
			else if (structKeyExists(item,"media:content") ) path = item["media:content"];
			if( len(path) ){
				for(y=1; y lte arrayLen(path);y=y+1){
					itemStruct = StructNew();
					itemStruct.type = "media";
					if( structKeyExists(path[y].xmlAttributes,'url') ) itemStruct.url = path[y].xmlAttributes.url;
					else itemStruct.url = "";
					if( structKeyExists(path[y].xmlAttributes,'filesize') ) itemStruct.size = path[y].xmlAttributes.filesize;
					else itemStruct.size = "";
					if( structKeyExists(path[y].xmlAttributes,'type') ) itemStruct.mimetype = path[y].xmlAttributes.type;
					else itemStruct.type = "";
					if( structKeyExists(path[y].xmlAttributes,'medium') ) itemStruct.medium = path[y].xmlAttributes.medium;
					else itemStruct.medium = "";
					if( structKeyExists(path[y].xmlAttributes,'isDefault') ) itemStruct.isDefault = path[y].xmlAttributes.isDefault;
					else itemStruct.isDefault = "";
					if( structKeyExists(path[y].xmlAttributes,'height') ) itemStruct.height = path[y].xmlAttributes.height;
					else itemStruct.height = "";
					if( structKeyExists(path[y].xmlAttributes,'width') ) itemStruct.width = path[y].xmlAttributes.width;
					else itemStruct.width = "";
					if( structKeyExists(path[y].xmlAttributes,'duration') ) itemStruct.duration = path[y].xmlAttributes.duration;
					else itemStruct.duration = "";
					ArrayAppend(attachmentCol,itemStruct);
				}
			}
			return attachmentCol;
		</cfscript>
	</cffunction> 

	<!--- Get Created Date --->
	<cffunction name="findCreatedDate" access="private" output="false" returntype="string" hint="Parse the document to find a created date">
		<!--- ******************************************************************************** --->
		<cfargument name="xmlRoot" type="xml" required="true" hint="The XML root to look in"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var createdDate = "";
			// rss 0.92 / 2
			if(StructKeyExists(arguments.xmlRoot,"lastBuildDate")) 
				createdDate = arguments.xmlRoot.lastBuildDate.xmlText;
			// atom 1
			else if(StructKeyExists(arguments.xmlRoot,"updated"))
				createdDate = arguments.xmlRoot.updated.xmlText;	
			return createdDate;
		</cfscript>
	</cffunction>

	<!--- Get Keywords --->
	<cffunction name="findKeywords" access="private" returntype="string" output="false" hint="Parse an item's category array and find keywords">
		<!--- ******************************************************************************** --->
		<cfargument name="categoryRoot" type="array" required="true" hint="The category root to look in"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var catList = "";
			var elem = "";
			var i = "";
			var categories = arguments.categoryRoot;
			var j = "";
			var set = StructNew();
			/* Find category tags whose domain contains either keyword or tag */
			for(j=1; j lte arrayLen(categories);j=j+1){
				if(categories[j].domain contains 'keywords' or categories[j].domain contains 'tag') {
					catList = ListAppend(catList,categories[j].tag);
					catList = ReplaceNocase(catList,', ',',','all');
				}
			}
		</cfscript>
		<!--- Remove duplicate items --->
		<cfloop list="#catList#" index="elem">
			<cfset set[elem] = "">
		</cfloop>
		<!--- Convert the set back to a list --->
		<cfset catList = StructKeyList(set)>
		<cfset catList = ListSort(catList, 'textnocase')/>
		<!--- Return value --->
		<cfreturn catList>
	</cffunction>

	<!--- Get Thumbnail --->
	<cffunction name="findThumbnails" access="private" output="false" returntype="array" hint="Parse an item and find thumbnails">
		<!--- ******************************************************************************** --->
		<cfargument name="itemRoot" type="xml" required="true" hint="The item to look in"/>
		<cfargument name="attachmentnode" type="array" required="true" hint="Existing attachments to merge with thumbnails"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var item = arguments.itemRoot;
			var itemStruct = StructNew();
			var attachmentCol = arguments.attachmentnode;
			var path = "";
			var y = 1;
			if( structKeyExists(item,"media:group") and structKeyExists(item["media:group"],"media:thumbnail") ) path = item["media:group"]["media:thumbnail"];
			else if (structKeyExists(item,"media:thumbnail") ) path = item["media:thumbnail"];
			if( len(path) ) {
				for(y=1; y lte arrayLen(path);y=y+1){
					itemStruct = StructNew();
					if ( StructKeyExists(path[y].xmlAttributes,'height') ) itemStruct.height = path[y].xmlAttributes.height;
					if ( StructKeyExists(path[y].xmlAttributes,'width') ) itemStruct.width = path[y].xmlAttributes.width;
					itemStruct.url = path[y].xmlAttributes.url;
					itemStruct.medium = "image";
					itemStruct.type = "thumbnail";
					ArrayAppend(attachmentCol,itemStruct);
				}
			}
			return attachmentCol;
		</cfscript>
	</cffunction>

	<!--- Get Updated Date --->
	<cffunction name="findUpdatedDate" access="private" output="false" returntype="string" hint="Parse the document and find a updated date">
		<!--- ******************************************************************************** --->
		<cfargument name="xmlRoot" type="xml" required="true" hint="The XML root to look in"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var updatedDate = "";
			// rss .92 / 2
			if(StructKeyExists(arguments.xmlRoot,"pubDate")) 
				updatedDate = arguments.xmlRoot.pubDate.xmlText;
			// dublin core for rdf/rss 1
			else if(StructKeyExists(arguments.xmlRoot,"dc:date"))
				updatedDate = arguments.xmlRoot["dc:date"].xmlText;
			// atom 1
			else if(StructKeyExists(arguments.xmlRoot,"published"))
				updatedDate = arguments.xmlRoot.published.xmlText;
			else if(StructKeyExists(arguments.xmlRoot,"updated"))
				updatedDate = arguments.xmlRoot.updated.xmlText;
			return updatedDate;
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
	<cffunction name="getuseCache" access="public" returntype="boolean" output="false" hint="Whether using file cache or not">
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