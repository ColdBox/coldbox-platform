<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Luis Majano and Ben Garrett
Date        :	02/22/2008
License     :	Apache 2 License
Version     :	2 (Alpha-21Jan09)
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
	- feedReader_compatibility	: boolean [default=false] (FeedStructure uses version 1 naming conventions)
	
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
****INCOMPLETE LIST*****
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
						throw(message="The Setting feedReader_cacheLocation is missing. Please create it.",type='plugins.feedReader.InvalidSettingException');
					}
					/* Tests if the directory exists: Full Path */
					/* Try to locate the path */
					cacheLocation = locateDirectoryPath(getSetting('feedReader_cacheLocation'));
					/* Validate it */
					if( len(cacheLocation) eq 0 ){
						throw('The cache location directory could not be found. Please check again. #getSetting('feedReader_cacheLocation')#','','plugins.feedReader.InvalidCacheLocationException');
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
			
			/* Backwards Compatibility with feedReader 1 */
			if( not settingExists('feedReader_compatibility') or not isBoolean(getSetting('feedReader_compatibility')) ){
				setcompatibility(false);
			}else{
				setcompatibility(getSetting('feedReader_compatibility'));
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
				throw("You are tying to use a method that needs caching enabled.","Please look at the plugin's settings or just use the 'retrieveFeed' method.","plugins.feedReader.InvalidSettingException");
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
		<cfset var x = 1>
    <cfset var loop = "">
    <cfset var merge = "">
    <cfset var xmlrootkey = "">
		<cfset var oUtilities = getPlugin("Utilities")>

		<cfscript>
			feed.a0 = xmlDoc;
			
			// get feed type structure		
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
			// obtain and list known/supported feed extensions
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
			// get rss namespace
			if( StructKeyExists(xmlDoc.xmlRoot,"channel") ) {
				if( structKeyExists(xmlDoc.xmlRoot.channel,"docs") ) { feed.specs.namespace.xmlns = xmlDoc.xmlRoot.channel.docs.xmlText; }
			}
			// get feed generator
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
			feed.websiteurl = "";
			feed.rating = "";
			feed.rights = StructNew();
			feed.rights.creativecommons = "";
			feed.rights.copyright = "";
			feed.title = "";
			/* OpenSearch */
			feed.opensearch = StructNew();
			feed.opensearch.autodiscovery = StructNew();
			feed.opensearch.autodiscovery.url = "";
			feed.opensearch.autodiscovery.title = "";
			feed.opensearch.itemsperpage = "";
			feed.opensearch.startindex = "";
			feed.opensearch.totalresults = "";
			feed.opensearch.query = ArrayNew(1);

			// get rss/rdf 1 & rss 2
			if(feed.specs.type is "RDF" or feed.specs.type is "RSS") {
				/* Parse Items */
				if(feed.specs.type is "RDF") feed.items = parseRSSItems(xmlDoc.xmlRoot.item,arguments.itemsType,arguments.maxItems);
				if(feed.specs.type is "RSS") feed.items = parseRSSItems(xmlDoc.xmlRoot.channel.item,arguments.itemsType,arguments.maxItems);
				/* Author Info */
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"managingEditor"))
					feed.author.name = xmlDoc.xmlRoot.channel.managingEditor.xmlText;
				else if(StructKeyExists(xmlDoc.xmlRoot.channel,"webMaster"))
					feed.author.name = xmlDoc.xmlRoot.channel.webMaster.xmlText;
				/* Author Email */
				if( find("@",feed.author.name) ) {
					feed.author.email = ListGetAt(feed.author.name,1,' ');
					// regexpression matching only works in CFML8 compatible engines
					if( GetFunctionList() contains 'REMatchNoCase' and ArrayLen(REMatchNoCase('( \(.*\))?$', feed.author.name)) ) {
						feed.author.name = REMatchNoCase('( \(.*\))?$', feed.author.name);
						feed.author.name = ReReplace(feed.author.name[1],'\(|\)','','all');
					}
				}
				/* Category */
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"category")){
					for(x=1; x lte arrayLen(xmlDoc.xmlRoot.channel.category); x=x+1){
						loop = xmlDoc.xmlRoot.channel.category[x];
						if( len(loop.XMLText) ) { 
							feed.category[x] = StructNew();
							feed.category[x].tag = loop.XMLText;
							if(StructKeyExists(loop.xmlAttributes,'domain')) feed.category[x].domain = loop.xmlAttributes.domain;
						}
					}
				}
				/* Copyright */
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"copyright")) feed.rights.copyright = xmlDoc.xmlRoot.channel.copyright.xmlText;
				/* Date built & Date updated */
				feed.DateBuilt = findCreatedDate(xmlDoc.xmlRoot.channel);
				if( isDateISO8601(feed.DateBuilt) ) feed.DateBuilt = oUtilities.parseISO8601(feed.DateBuilt);
				else feed.DateBuilt = oUtilities.parseRFC822(feed.DateBuilt);
				feed.DateUpdated = findUpdatedDate(xmlDoc.xmlRoot.channel);
				if( isDateISO8601(feed.DateUpdated) ) feed.DateUpdated = oUtilities.parseISO8601(feed.DateUpdated);
				else feed.DateUpdated = oUtilities.parseRFC822(feed.DateUpdated);
				/* Description */
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"description")) feed.Description = xmlDoc.xmlRoot.channel.description.xmlText;
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
				/* Language */
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"language")) feed.language = xmlDoc.xmlRoot.channel.language.xmlText;
				/* Link */
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"link")) feed.websiteurl = xmlDoc.xmlRoot.channel.link.xmlText;
				/* Rating */
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"rating")) feed.rating = xmlDoc.xmlRoot.channel.rating.xmlText;
				/* Title */
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"title")) feed.Title = xmlDoc.xmlRoot.channel.title.xmlText;
				/* Dublin Core Metadata extension */
				if( StructKeyExists(xmlDoc.xmlRoot.channel,"dc:creator") ) {
					if( not len(feed.author.name) and not find("@",xmlDoc.xmlRoot.channel["dc:creator"].xmlText) ) feed.author.name = xmlDoc.xmlRoot.channel["dc:creator"].xmlText;
					else if( not len(feed.author.email) and StructKeyExists(xmlDoc.xmlRoot.channel,"dc:creator") and find("@",xmlDoc.xmlRoot.channel["dc:creator"].xmlText) ) feed.author.email = xmlDoc.xmlRoot.channel["dc:creator"].xmlText;
				}
				if( StructKeyExists(xmlDoc.xmlRoot.channel,"dc:date") and not len(feed.dateupdated) ) { 
					if( isDateISO8601(feed.dateupdated) ) { feed.dateupdated = oUtilities.parseISO8601(xmlDoc.xmlRoot.channel["dc:date"].xmlText); }
					else { feed.dateupdated = oUtilities.parseRFC822(xmlDoc.xmlRoot.channel["dc:date"].xmlText); }
				}
				if( StructKeyExists(xmlDoc.xmlRoot.channel,"dc:description") and not len(feed.description) ) feed.description = xmlDoc.xmlRoot.channel["dc:description"].xmlText;
				if( StructKeyExists(xmlDoc.xmlRoot.channel,"dc:language") and not len(feed.language) ) feed.language = xmlDoc.xmlRoot.channel["dc:language"].xmlText;
				if( StructKeyExists(xmlDoc.xmlRoot.channel,"dc:rights") and not len(feed.rights.copyright) ) feed.rights.copyright = xmlDoc.xmlRoot.channel["dc:rights"].xmlText;
				if( StructKeyExists(xmlDoc.xmlRoot.channel,"dc:subject") and not arrayLen(feed.category) ) {
					loop = xmlDoc.xmlRoot.channel["dc:subject"].xmlText;
					for(x=1; x lte listLen(loop); x=x+1){
						feed.category[x] = StructNew();
						feed.category[x].tag = listGetAt(loop,x);
					}					
				}
				if( StructKeyExists(xmlDoc.xmlRoot.channel,"dc:title") and not len(feed.title) ) feed.title = xmlDoc.xmlRoot.channel["dc:title"].xmlText;
				/* Apple iTunes extension */
				if( ArrayLen(StructFindKey(feed.specs.namespace,'xmlns:itunes')) ) {
					// author
					if( StructKeyExists(xmlDoc.xmlRoot.channel,"itunes:author") ) feed.author.name = xmlDoc.xmlRoot.channel["itunes:author"].xmlText;
					// category
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
					// explicit
					if( StructKeyExists(xmlDoc.xmlRoot.channel,"itunes:explicit") ) feed.rating = "explicit - #xmlDoc.xmlRoot.channel["itunes:explicit"].xmlText#";
					// image
					try {
					if( not len(feed.image.url) and StructKeyExists(xmlDoc.xmlRoot.channel["itunes:image"].xmlAttributes,'href') ) feed.image.url = xmlDoc.xmlRoot.channel["itunes:image"].xmlAttributes.href;
					} catch(Any ex) {}
					// keywords
					if( StructKeyExists(xmlDoc.xmlRoot.channel,"itunes:keywords") ) {
						arrayAppend(feed.category, StructNew());
						x = arrayLen(feed.category);
						feed.category[x].tag = xmlDoc.xmlRoot.channel["itunes:keywords"].xmlText;
						feed.category[x].domain = "itunes keywords";
					}
					if( not len(feed.description) ) {
						if( StructKeyExists(xmlDoc.xmlRoot.channel,"itunes:subtitle") ) feed.description = xmlDoc.xmlRoot.channel["itunes:subtitle"].xmlText;
						if( StructKeyExists(xmlDoc.xmlRoot.channel,"itunes:summary") ) feed.description = xmlDoc.xmlRoot.channel["itunes:summary"].xmlText;
					}
				}
				/* Atom as an RSS extension */
				if( ArrayLen(StructFindKey(feed.specs.namespace,'xmlns:atom')) and StructKeyExists(xmlDoc.xmlRoot.channel,"atom:link") ) {
					for(x=1; x lte arrayLen(xmlDoc.xmlRoot.channel["atom:link"]); x=x+1){
						loop = xmlDoc.xmlRoot.channel["atom:link"][x];
						if( StructKeyExists(loop,'xmlAttributes') and StructKeyExists(loop.xmlAttributes,'rel') and len(loop.xmlAttributes.rel) ) {
							// OpenSearch Autodiscovery
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
								 loop.xmlAttributes.rel is "search"
								 and StructKeyExists(loop.xmlAttributes,'self')
								 and loop.xmlAttributes.type is "application/rss+xml"
								 and StructKeyExists(loop.xmlAttributes,'href')
								 ) {
									feed.specs.url = loop.xmlAttributes.href;
							}
						}
					}
				}				
			}//end if rss 1 or 2
			else if(feed.specs.type is "Atom") {
				/* Parse Items */
				feed.items = parseAtomItems(xmlDoc.xmlRoot.entry,arguments.itemsType,arguments.maxItems);
				/* Author Information */
				if(structKeyExists(xmlDoc.xmlRoot,"author")){
					if( structKeyExists(xmlDoc.xmlRoot.author,"name") ) feed.author.name = xmlDoc.xmlRoot.author.name.xmlText;
					if( structKeyExists(xmlDoc.xmlRoot.author,"uri") ) feed.author.url = xmlDoc.xmlRoot.author.uri.xmlText;
					if( structKeyExists(xmlDoc.xmlRoot.author,"email") ) feed.author.email = xmlDoc.xmlRoot.author.email.xmlText;
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
				if(StructKeyExists(xmlDoc.xmlRoot,"icon")) feed.image.icon = xmlDoc.xmlRoot.icon.xmlText;
				if(StructKeyExists(xmlDoc.xmlRoot,"logo")) feed.image.url = xmlDoc.xmlRoot.logo.xmlText;
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
				if(StructKeyExists(xmlDoc.xmlRoot,"rights")) feed.rights.copyright = xmlDoc.xmlRoot.rights.xmlText;
				/* Title */
				if(StructKeyExists(xmlDoc.xmlRoot,"title"))	feed.title = normalizeAtomTextConstruct(xmlDoc.xmlRoot.title);
			}
			// shared extensions
			/* OpenSearch 1.0 & 1.1 extensions */
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
			/* rdf/rss/atom tags feedReader version 1  backwards compatibility */
			if( getcompatibility() ) {
				if( not len(feed.image.link) ) feed.image.link = "##";
				feed.authoremail = feed.author.email;
				feed.authorurl = feed.author.url;
				feed.author = feed.author.name;
				feed.date = feed.dateupdated;
				feed.link = feed.websiteurl;
				StructDelete(feed, "dateupdated");
				StructDelete(feed, "websiteurl");
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
				else if ( structKeyExists(items[x],"source") and structKeyExists(items[x].source.xmlAttributes,"url") ){
					node.link = items[x].source.xmlAttributes.url;
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
				if( structKeyExists(items[x],"enclosure") and structKeyExists(items[x].enclosure.xmlAttributes,"url") ){
					node.enclosure = items[x].enclosure.xmlAttributes.url;
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
						throw("Invalid Atom: XHTML Text construct does not contain a child div.",'','plugins.feedReader.InvalidAtomConstruct');	
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
	
	<!--- Get Updated Date --->
	<cffunction name="findUpdatedDate" access="private" output="false" returntype="string" hint="Parse the doc and find a updated date">
		<!--- ******************************************************************************** --->
		<cfargument name="xmlRoot" type="xml" required="true" hint="The xml root to look in"/>
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
  
	<!--- Backwards compatibility mode --->
	<cffunction name="getcompatibility" access="public" returntype="boolean" output="false" hint="Whether to output in version 1 compatibility mode">
		<cfreturn instance.compatibility>
	</cffunction>
	<cffunction name="setcompatibility" access="public" returntype="void" output="false" hint="Set version 1 compatibility mode">
		<cfargument name="compatibility" type="boolean" required="true">
		<cfset instance.compatibility = arguments.compatibility>
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