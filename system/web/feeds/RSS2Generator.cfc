<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Ben Garrett and Luis Majano
Date        :	18/05/2009
Version     :	2
License		: 	Apache 2 License
	Additional RSS 2 methods for the FeedGenerator plug-in that were separated
	to reduce potential bloat in the plug-in component.

----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.web.feeds.SharedGenerator"
			 hint="Methods belonging to the FeedGenerator plug-in that specifically relate to RSS creation"
			 output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfset variables.instance = createInstances(instance)>

	<cffunction name="init" access="public" returntype="RSS2Generator" output="false">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="createInstances" access="public" returntype="struct" output="false" hint="Variables used for the validation and creation of RSS 2 data">
		<cfargument name="instance" required="true" type="struct" hint="">
		<cfscript>
			instance = variables.instance;
			StructAppend(instance, arguments.instance, 'true');
			/* Validation values */
			instance.cloudProtocols 	= 'xml-rpc,soap'; // allowed rss cloud protocols
			instance.imageExtensions 	= "png,gif,jpg,jpeg,jpe,jif,jfif,jfi"; // valid image file extensions for rss image
			instance.imageHeight 		= 400; // maximum image height for rss image
			instance.imageWidth 		= 144; // maximum image width for rss image
			instance.itunesCategory 	= structNew(); // apple itunes categories collection
			instance.itunesCategory["Arts"] = "Design,Fashion & Beauty,Food,Literature,Performing Arts,Visual Arts";
			instance.itunesCategory["Business"] = "Business News,Careers,Investing,Management & Marketing,Shopping";
			instance.itunesCategory["Comedy"] = "";
			instance.itunesCategory["Education"] = "Education Technology,Higher Education,K-12,Language Courses,Training";
			instance.itunesCategory["Games & Hobbies"] = "Automotive,Aviation,Hobbies,Other Games,Video Games";
			instance.itunesCategory["Government & Organizations"] = "Local,National,Non-Profit,Regional";
			instance.itunesCategory["Health"] = "Alternative Health,Fitness & Nutrition,Self-Help,Sexuality";
			instance.itunesCategory["Kids & Family"] = "";
			instance.itunesCategory["Music"] = "";
			instance.itunesCategory["News & Politics"] = "";
			instance.itunesCategory["Religion & Spirituality"] = "Buddhism,Christianity,Hinduism,Islam,Judaism,Other,Spirituality";
			instance.itunesCategory["Science & Medicine"] = "Medicine,Natural Sciences,Social Sciences";
			instance.itunesCategory["Society & Culture"] = "History,Personal Journals,Philosophy,Places & Travel";
			instance.itunesCategory["Sports & Recreation"] = "Amateur,College & High School,Outdoor,Professional";
			instance.itunesCategory["Technology"] = "Gadgets,Tech News,Podcasting,Software How-To";
			instance.itunesCategory["TV & Film"] = "";
			instance.itunesExplicit		= "yes,no,clean"; // allowed values for itunes explicit
			instance.itunesImage 		= "png,jpg"; // allowed image file extensions for itunes image
			instance.itunesKeywords 	= 12; // maximum list of items for itunes keywords
			instance.itunesSummary 		= 4000; // maximum characters allowed in itunes summary
			instance.requiredItems		= "title,link,description"; // required rss elements
			instance.skipDays			= "Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday"; // valid days allowed for rss skipDays
			return instance;
		</cfscript>
	</cffunction>

<!------------------------------------------- GENERATE METHODS -------------------------------------->

	<!--- Generate channel --->	
	<cffunction name="generateChannel" output="false" access="public" returntype="string" hint="Generate the RSS channel as XML">
		<!--- ******************************************************************************** --->
		<cfargument name="feedStruct" 	type="struct" required="yes" hint="The structure used to build a feed"/>
		<cfargument name="ColumnMap" 	type="struct" default="#structNew()#" hint="The column mapper to wire items to queries"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var fs = arguments.feedStruct;
			var cm = arguments.ColumnMap;
			var xmlContent = "";
			var xmlCleaned = "";
			var i = 0;
			var j = 0;
			var container = "";
		</cfscript>
		
		<!--- Create our Metadata XML --->
		<cfxml variable="xmlContent">
		<cfoutput><?xml version="1.0" encoding="utf-8"?>
		<rss #generateNameSpace(cm,fs)#>
		<channel>
		<!--- Optional Atom link --->
		<cfif structKeyExists(fs,"atomSelfLink")><atom:link href="#URLFormat(fs['atomSelfLink'])#" rel="self" type="application/rss+xml"/></cfif>
		<!--- Required RSS tags, description, link, title --->
		<description>#RSSFormat(fs["description"],true)#</description>
		<link>#URLFormat(fs["link"])#</link>
		<title>#RSSFormat(fs["title"])#</title>
		<!--- Optional OpenSearch --->
		<cfif structKeyExists(fs,"opensearch")>#opensearchGenChannel(fs)#</cfif>
		<!--- Optional category --->
		<cfif structKeyExists(fs,"category") and isArray(fs.category)>
			<cfloop from="1" to="#arrayLen(fs.category)#" index="i">
			<cfif structKeyExists(fs.category[i],"domain") and structKeyExists(fs.category[i],"tag")>
				<category domain="#fs.category[i].domain#">#fs.category[i].tag#</category>
			<cfelseif structKeyExists(fs.category[i],"tag")>
				<category>#fs.category[i].tag#</category>
			</cfif>
			</cfloop>
			<cfset i = 0/>
		</cfif>
		<!--- Optional cloud --->
		<cfif structKeyExists(fs,"cloud")>
			<cloud 
			domain="#URLFormat(fs.cloud["domain"])#"
			path="#URLFormat(fs.cloud["path"])#"
			port="#URLFormat(fs.cloud["port"])#"
			protocol="#URLFormat(fs.cloud["protocol"])#"
			registerProcedure="#URLFormat(fs.cloud["registerProcedure"])#" />
		</cfif>
		<!--- Optional Creative Commons license extension --->
		<cfif structKeyExists(fs,"commonslicense")>#cclicenseGenChannel(fs)#</cfif>
		<!--- Optional copyright --->
		<cfif structKeyExists(fs,"copyright")><copyright>#RSSFormat(fs["copyright"])#</copyright></cfif>
		<!--- Auto-generated docs, generator --->
		<docs>#URLFormat(fs["docs"])#</docs>
		<generator>#RSSFormat(fs["generator"])#</generator>
		<!--- Optional image --->
		<cfif structKeyExists(fs,"image")>
			<image>
				<url>#URLFormat(fs.image["url"])#</url>
				<title>#RSSFormat(fs.image["title"])#</title>
				<link>#URLFormat(fs.image["link"])#</link>
				<cfif structKeyExists(fs.image,"width")><width>#RSSFormat(fs.image["width"])#</width></cfif>
				<cfif structKeyExists(fs.image,"height")><height>#RSSFormat(fs.image["height"])#</height></cfif>
				<cfif structKeyExists(fs.image,"description")><description>#RSSFormat(fs.image["description"])#</description></cfif>
			</image>
		</cfif>
		<!--- Optional language --->
		<cfif structKeyExists(fs,"language")><language>#RSSFormat(fs["language"])#</language></cfif>
		<!--- Optional lastBuildDate --->
		<cfif structKeyExists(fs,"lastBuildDate")><lastBuildDate>#RSSFormat(fs["lastBuildDate"])#</lastBuildDate></cfif>
		<!--- Optional managingEditor --->
		<cfif structKeyExists(fs,"managingEditor")><managingEditor>#RSSFormat(fs["managingEditor"])#</managingEditor></cfif>
		<!--- Optional pubDate --->
		<cfif structKeyExists(fs,"pubDate")><pubDate>#RSSFormat(fs["pubDate"])#</pubDate></cfif>
		<!--- Optional rating --->
		<cfif structKeyExists(fs,"rating")><rating>#RSSFormat(fs["rating"])#</rating></cfif>
		<!--- Optional skipDays --->
		<cfif structKeyExists(fs,"skipDays")>
			<skipDays>
			<cfloop from="1" to="#listLen(fs['skipDays'])#" index="i">
				<cfset container = listGetAt(fs['skipDays'],i)/>
				<day>#RSSFormat("#uCase(left(container,1))##lCase(Right(container,Len(container)-1))#")#</day>
			</cfloop>
			</skipDays>
		</cfif>
		<!--- Optional skipHours --->
		<cfif structKeyExists(fs,"skipHours")>
			<skipHours>
			<cfloop from="1" to="#listLen(fs['skipHours'])#" index="i">
				<hour>#RSSFormat(listGetAt(fs['skipHours'],i))#</hour>
			</cfloop>
			</skipHours>
		</cfif>
		<!--- Optional textInput --->
		<cfif structKeyExists(fs,"textInput")>
			<textInput>
				<description>#RSSFormat(fs.textInput["description"])#</description>
				<link>#URLFormat(fs.textInput["link"])#</link>
				<name>#RSSFormat(fs.textInput["name"])#</name>
				<title>#RSSFormat(fs.textInput["title"])#</title>
			</textInput>
		</cfif>
		<!--- Optional ttl (time to live) --->
		<cfif structKeyExists(fs,"ttl")><ttl>#RSSFormat(fs["ttl"])#</ttl></cfif>
		<!--- Optional webMaster --->
		<cfif structKeyExists(fs,"webMaster")><webMaster>#RSSFormat(fs["webMaster"])#</webMaster></cfif>
		<!--- Optional Apple iTunes --->
		<cfif structKeyExists(fs,"itunes")>#itunesGenChannel(fs)#</cfif>
		<!--- Optional DCMI Metadata terms --->
		<cfif structKeyExists(fs,"dcmiterm") and isStruct(fs.dcmiterm)>#dcmtGenChannel(fs)#</cfif>
		<!--- Optional RSS Items --->
		#generateItems(argumentCollection=arguments)#
		</channel>
		</rss></cfoutput></cfxml>

		<cfreturn xmlContent>
	</cffunction>

	<!--- Generate default mapping --->
	<cffunction name="generateDefaultPropertyMap" output="false" access="public" returntype="struct" hint="Generates the default property map">
		<cfscript>
			var i = 0;
			var map = structnew();
			map.atomselfLink = "atomselfLink";
			map.author = "author";
			map.category_domain = "category_domain";
			map.category_tag = "category_tag";
			map.comments = "comments";
			map.content_encoded = "content_encoded";
			map.description = "description";
			map.enclosure_url = "enclosure_url";
			map.enclosure_length = "enclosure_length";
			map.enclosure_type = "enclosure_type";
			map.guid_string = "guid_string";
			map.guid_permalink = "guid_permalink";
			map.link = "link";
			map.pubdate = "pubdate";
			map.source_title = "source_title";
			map.source_url = "source_url";
			map.title = "title";
			StructAppend(map, generateExtensionPropertyMap());
			/* Return map */
			return map;
		</cfscript>
	</cffunction>

	<!--- Generate items --->
	<cffunction name="generateItems" output="false" access="public" returntype="string" hint="Generate the RSS items as XML">
		<!--- ******************************************************************************** --->
		<cfargument name="feedStruct" 	type="struct" required="yes" 	hint="The structure used to build a feed">
		<cfargument name="ColumnMap" 	type="struct" required="false"  hint="The column mapper to map items to queries"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var i = 0;
			var items = "";
			var itemsXML = "";
			var refLocal = structnew();
			var map = generateDefaultPropertyMap();
		</cfscript>

		<!--- Check that the feed items exist otherwise no items will be displayed --->
		<cfif not structKeyExists(arguments.feedStruct, "items")>
			<cfreturn "">
		<cfelse>
			<cfset items = arguments.feedStruct.items>
		</cfif>

		<!--- Do we have to override our map? --->
		<cfif structKeyExists(arguments, "ColumnMap")>
			<cfset map = parseColumnMap(arguments.ColumnMap)>
		</cfif>

		<!--- Generate XML --->
		<cfsavecontent variable="itemsXML">
		<cfoutput query="items">
		<cfscript>
			// For some optional variable
			refLocal = structnew();
			// Date tests
			if( structKeyExists(items, "#map.pubdate#") ){
				if( validateRFC822Date(items[map.pubdate][currentRow]) ) {
					// if pubdate is already a valid RFC822 date, do nothing
					refLocal.pubDate = items[map.pubdate][currentRow];
				}
				else if ( len(items[map.pubdate][currentRow]) ) {
					// convert the given date into a valid RFC822 date
					refLocal.pubDate = generateRFC822Date(items[map.pubdate][currentRow]);
				}
			}
			// PermaLink tests
			if( structKeyExists(items,"#map.guid_permalink#") and len(items[map.guid_permalink][currentRow]) ){
				refLocal.guid_permaLink = RSSFormat(items[map.guid_permalink][currentrow]);
			}
			else{ refLocal.guid_permaLink = "false"; }
			// Enclosure tests
			if( structKeyExists(items,"#map.enclosure_url#") ){
				refLocal.enclosure = structnew();
				refLocal.enclosure.url = URLFormat(items[map.enclosure_url][currentrow]);
				/* Length */
				if( structKeyExists(items, "#map.enclosure_length#") ){
					refLocal.enclosure.length = RSSFormat(items[map.enclosure_length][currentrow]);
				}
				else{ refLocal.enclosure.length = ""; }
				/* Type */
				if( structKeyExists(items, "#map.enclosure_type#") ){
					refLocal.enclosure.type = RSSFormat(items[map.enclosure_type][currentrow]);
				}
				else{ refLocal.enclosure.type = ""; }
			} //end of enclosure setup.
		</cfscript>
		<item>
		<!--- Required title (if no description) --->
		<cfif structKeyExists(items,"#map.title#") and len(items[map.title][currentrow]) and len(items[map.title][currentrow])>
			<title>#RSSFormat(items[map.title][currentrow])#</title>
		</cfif>
		<!--- Required description (if no title) --->
		<cfif structKeyExists(items,"#map.description#") and len(items[map.description][currentrow]) and len(items[map.description][currentrow])>
			<description>#RSSFormat(items[map.description][currentrow])#</description>
		</cfif>
		<!--- Optional content encoding extension (needs to go before description) --->    
		<cfif structKeyExists(items,"#map.content_encoded#") and len(items[map.content_encoded][currentrow])>
			<content:encoded>#RSSFormat(items[map.content_encoded][currentrow])#</content:encoded>
		</cfif>
		<!--- Optional link --->
		<cfif structKeyExists(items,"#map.link#") and len(items[map.link][currentrow])>
			<link>#URLFormat(items[map.link][currentrow])#</link>
		</cfif>
		<!--- Optional atom link --->
		<cfif structKeyExists(items,"#map.atomselfLink#") and len(items[map.atomselfLink][currentrow])>
			<atom:link href="#URLFormat(items[map.atomSelfLink][currentrow])#" rel="self" type="application/rss+xml"/>
		</cfif>
		<!--- Optional pubDate --->
		<cfif structKeyExists(refLocal,"pubDate") and len(refLocal.pubDate)>
			<pubDate>#refLocal.pubDate#</pubDate>
		</cfif>
		<!--- Optional author --->
		<cfif structKeyExists(items,"#map.author#") and len(items[map.author][currentrow])>
			<author>#RSSFormat(items[map.author][currentrow])#</author>
		</cfif>
		<!--- Optional comments --->
		<cfif structKeyExists(items,"#map.comments#") and len(items[map.comments][currentrow])>
			<comments>#URLFormat(items[map.comments][currentrow])#</comments>
		</cfif>
		<!--- Optional slash extension --->
		<cfif listContainsNoCase(items.columnList,'slash_')>
			#slashGenItem(items,map,currentrow)#
		</cfif>
		<!--- Optional source --->
		<cfif structKeyExists(items,"#map.source_url#") and len(items[map.source_url][currentrow])>
			<cfif structKeyExists(items,"#map.source_title#")>
				<source url="#URLFormat(items[map.source_url][currentrow])#">#RSSFormat(items[map.source_title][currentrow])#</source>
			<cfelse>
				<source url="#URLFormat(items[map.source_url][currentrow])#"/>
			</cfif>
		</cfif>
		<!--- Optional category --->
		<cfif structKeyExists(items,"#map.category_tag#") and len(items[map.category_tag][currentrow])>
			<cfloop from="1" to="#listLen(items[map.category_tag][currentrow])#" index="i">
				<cftry>
					<cfif listGetAt(items[map.category_domain][currentrow],i) neq "-">
						<category domain="#RSSFormat(listGetAt(items[map.category_domain][currentrow],i))#">#RSSFormat(listGetAt(items[map.category_tag][currentrow],i))#</category>
					<cfelse>
						<category>#RSSFormat(listGetAt(items[map.category_tag][currentrow],i))#</category>
					</cfif>
				<cfcatch>
					<category>#RSSFormat(listGetAt(items[map.category_tag][currentrow],i))#</category>
				</cfcatch>
				</cftry>
			</cfloop>
		</cfif>
		<!--- Optional guid --->
		<cfif structKeyExists(items,"#map.guid_string#") and len(items[map.guid_string][currentrow])>
			<guid isPermaLink="#RSSFormat(refLocal.guid_permaLink)#">#RSSFormat(items[map.guid_string][currentrow])#</guid>
		</cfif>
		<!--- Optional DCMI Metadata terms --->
		<cfif listContainsNoCase(items.columnList,'dcmiterm_')>
			#dcmtGenItem(items,map,currentrow)#
		</cfif>
		<!--- Apple iTunes extension --->
		<cfif listContainsNoCase(items.columnList,'itunes_')>
			#itunesGenItem(items,map,currentrow)#
		</cfif>
		<!--- Optional creative commons license extension --->
		<cfif structKeyExists(items,"#map.commonslicense#") and len(items[map.commonslicense][currentrow])>
			#cclicenseGenItem(items,map,currentrow)#
		</cfif>
		<!--- Optional enclosure --->
		<cfif structKeyExists(refLocal,"enclosure") and Len(refLocal.enclosure.url)>
			<cfloop from="1" to="#listLen(refLocal.enclosure.url)#" index="i">
				<cfif i lte listLen(refLocal.enclosure.length) and i lte listLen(refLocal.enclosure.type)>
					<enclosure url="#URLFormat(listGetAt(refLocal.enclosure.url,i))#" length="#RSSFormat(listGetAt(refLocal.enclosure.length,i))#" type="#RSSFormat(listGetAt(refLocal.enclosure.type,i))#"/>
				</cfif>
			</cfloop>
		</cfif>
		</item>
		</cfoutput>
		</cfsavecontent>

		<cfreturn itemsXML>
	</cffunction>

	<!--- Generate namespace --->
	<cffunction name="generateNameSpace" output="false" access="private" returntype="string" hint="Generates the XML namespaces depending on the tags in use">
		<cfargument name="columnMap" type="struct" required="true" hint="The column map structure"/>
		<cfargument name="feedStruct" type="struct" required="true" hint="The feed structure"/>
		<cfscript>
			var keys = structKeyList(arguments.feedStruct);
			var nameSpace = 'version="2.0"'; // rss version
			// Merge columnMap keys with feedStruct keys
			keys = listAppend(keys,structKeyList(arguments.columnMap));
			// Merge feedStruct.items with feedStruct keys
			if( structKeyExists(arguments.feedStruct,'items') ) {
				keys = listAppend(keys,arguments.feedStruct.items.columnList);
			}
			/* Atom syndication format namespace */
			if( listFindNoCase(keys,'atomselfLink') or listFindNoCase(keys,'opensearch.autodiscovery') ) {
				nameSpace = nameSpace & ' xmlns:atom="http://www.w3.org/2005/Atom"';
			}
			/* Content namespace */
			if( listFindNoCase(keys,'content_encoded') ) {
				nameSpace = nameSpace & ' xmlns:content="http://purl.org/rss/1.0/modules/content/"';
			}
			/* Add RSS extensions namespaces */
			nameSpace = nameSpace & generateExtensionNameSpace(keys);
			return nameSpace;
		</cfscript>
	</cffunction>

<!------------------------------------------- VERIFICATION METHODS ---------------------------------->

	<!--- verifyItems --->
	<cffunction name="verifyItems" output="false" access="private" returntype="string" hint="Verify the feed item data and structure">
		<!--- ******************************************************************************** --->
		<cfargument name="feedItems" type="query" required="true" hint="The feed items"/>
		<cfargument name="ColumnMap" 	type="struct" default="#structNew()#"  hint="The column mapper to map items to queries"/>
		<cfargument name="invalidList" type="string" required="true" hint="Existing collection of debug/validation errors"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var caught = "";
			var cs = arguments.ColumnMap;
			var fi = arguments.feedItems;
			var i = 0;
			var map = generateDefaultPropertyMap();
			
			/* Map columns to data */
			if( structKeyExists(arguments, "ColumnMap") ) {
				map = parseColumnMap(arguments.ColumnMap);
			}

			/* Varify Structures */
			/* category */
			if( listContainsNoCase(fi.columnList,'enclosure_') ) {
				try {	len(fi.enclosure_length);	} catch(any excpt) { caught = listAppend(caught,"length"); }
				try {	len(fi.enclosure_type);	} catch(any excpt) { caught = listAppend(caught,"type"); }
				try {	len(fi.enclosure_url);	} catch(any excpt) { caught = listAppend(caught,"url"); }
				// loop through items not in caught
				if( len(caught) ) {
					invalidList = invalidList & "| Items : The enclosure element : Requires all three attributes be used length,type,url. You're missing '#caught#' (See <a href='#instance.SpecRssEC#item-enclosure'>#instance.SpecRssEC#item-enclosure</a>)";
				}
				caught = "";
			}
		</cfscript>
		<cfloop query="fi">
			<cfscript>
				/* requirement for description or title */
				if( ( not structKeyExists(fi,"#map.title#") and not structKeyExists(fi,"#map.description#") ) or ( structKeyExists(fi,"#map.title#") and structKeyExists(fi,"#map.description#") and not len(fi[map.title][currentrow]) and not len(fi[map.description][currentrow]) ) ){
					invalidList = invalidList & "| Item #fi.currentrow# : This item needs either a 'title' or a 'description' element and the element cannot be left blank (See <a href='#instance.SpecRssEC#item'>#instance.SpecRssEC#item</a>)";
				}
				/* author */
				if( structKeyExists(fi,"#map.author#") and len(fi[map.author][currentrow]) and not validatePerson(fi[map.author][currentrow]) ){
					invalidList = invalidList & "| Item #fi.currentrow# : The author element '#fi[map.author][currentrow]#' : Is not a valid RSS person (See <a href='#instance.SpecRssEC#item-author'>#instance.SpecRssEC#item-author</a>)";
				}
				/* atom self link */
				if( structKeyExists(fi,"#map.atomSelfLink#") and len(fi[map.atomSelfLink][currentrow]) and not validateURL(fi[map.atomSelfLink][currentrow]) ) {
					invalidList = invalidList & "| Item #fi.currentrow# : The Atom self-link (atomselfLink) element '#fi[map.atomSelfLink][currentrow]#' : Is not a valid URL (See <a href='#instance.SpecRssNS#atom-link'>#instance.SpecRssNS#atom-link</a>)";
				}
				/* category */
				if( structKeyExists(fi,"#map.category_domain#") and len(fi[map.category_domain][currentrow]) ) {
						for(i=1; i lte listLen(fi[map.category_domain][currentrow]); i=i+1){
							if( ( not listGetAt(fi[map.category_domain][currentrow],i) is "-" ) and ( not structKeyExists(fi,"#map.category_tag#") or listLen(fi[map.category_domain][currentrow]) lt i or listGetAt(fi[map.category_domain][currentrow],i) is "-" ) ) {
								invalidList = invalidList & "| Item #fi.currentrow# : The #generateNumSuffix(i)# category domain (category_domain) attribute '#listGetAt(fi[map.category_tag][currentrow],i)#' : Requires a category tag (category_tag) element that cannot be left blank (See <a href='#instance.SpecRssEC#category'>#instance.SpecRssEC#category</a>)";
							}
						}
					}
				/* creative commons */
				if( structKeyExists(fi,"#map.commonslicense#") and len(fi[map.commonslicense][currentrow]) ){
					invalidList = invalidList & cclicenseValItem(fi,map,currentrow);
				}
				/* comments */
				if( structKeyExists(fi,"#map.comments#") and len(fi[map.comments][currentrow]) and not validateURL(fi[map.comments][currentrow]) ){
					invalidList = invalidList & "| Item #fi.currentrow# : The comments element '#fi[map.category_tag][comments]#' : Is not a valid URL (See <a href='#instance.SpecRssEC#item-comments'>#instance.SpecRssEC#item-comments</a>)";
				}
				/* enclosure */
				if( not structKeyExists(fi,"#map.enclosure_url#") or ( not len(fi[map.enclosure_length][currentrow]) and not len(fi[map.enclosure_type][currentrow]) and not len(fi[map.enclosure_url][currentrow]) ) ) {}
				else {
					for(i=1; i lte listLen(fi[map.enclosure_url][currentrow]); i=i+1){
						// length attribute
						if( i gt listLen(fi[map.enclosure_length][currentrow]) or not len(listGetAt(fi[map.enclosure_length][currentrow],i) ) ) {
						invalidList = invalidList & "| Item #fi.currentrow# : The #generateNumSuffix(i)# enclosure element : Is missing the length (enclosure_length) attribute, it cannot be left blank (See <a href='#instance.SpecRssEC#item-enclosure'>#instance.SpecRssEC#item-enclosure</a>)";
						}
						else if ( not validateNNInteger(listGetAt(fi[map.enclosure_length][currentrow],i)) ) {
						invalidList = invalidList & "| Item #fi.currentrow# : The #generateNumSuffix(i)# enclosure attribute length (enclosure_length) '#listGetAt(fi[map.enclosure_length][currentrow],i)#' : Must be a whole number, 0 or greater (See <a href='#instance.SpecRssEC#item-enclosure'>#instance.SpecRssEC#item-enclosure</a>)";
						}
						// type attribute
						if( i gt listLen(fi[map.enclosure_type][currentrow]) or not len(fi.enclosure_type) ) {
						invalidList = invalidList & "| Item #fi.currentrow# : The #generateNumSuffix(i)# enclosure element : Is missing the type (enclosure_type) attribute, it cannot be left blank (See <a href='#instance.SpecRssEC#item-enclosure'>#instance.SpecRssEC#item-enclosure</a>)";
						}
						// url attribute
						if( not len(fi[map.enclosure_url][currentrow]) ) {
						invalidList = invalidList & "| Item #fi.currentrow# : The #generateNumSuffix(i)# enclosure element : Is missing the url (enclosure_url) attribute, it cannot be left blank (See <a href='#instance.SpecRssEC#item-enclosure'>#instance.SpecRssEC#item-enclosure</a>)";
						}
						else if ( not validateURL(listGetAt(fi[map.enclosure_url][currentrow],i)) ) {
						invalidList = invalidList & "| Item #fi.currentrow# : The #generateNumSuffix(i)# enclosure url (enclosure_url) attribute '#listGetAt(fi[map.enclosure_url][currentrow],i)#' : Is not a valid URL (See <a href='#instance.SpecRssEC#item-enclosure'>#instance.SpecRssEC#item-enclosure</a>)";
						}
					}
				}
				/* guid & permaLink */
				if( structKeyExists(fi,"#map.guid_string#") and len(fi[map.guid_string][currentrow]) ){
					// guid_permaLink value
					if( structKeyExists(fi,"#map.guid_permaLink#") and len(fi.guid_permaLink) and not reFindNoCase('^(true|false)$',fi.guid_permaLink) ) {
						invalidList = invalidList & "| Item #fi.currentrow# : The isPermaLink (guid_permalink) attribute '#fi[map.guid_permaLink][currentrow]#' of the guid element : Is an invalid value, it can only be true,false (See <a href='#instance.SpecRssEC#item-guid'>#instance.SpecRssEC#item-guid</a>)";
					}
					// guid value when guid_permaLink is true
					else if ( ( not structKeyExists(fi,"#map.guid_permaLink#") or not len(fi[map.guid_permaLink][currentrow]) or fi[map.guid_permaLink][currentrow] ) and not validateURL(fi[map.guid_string][currentrow]) ) {
						invalidList = invalidList & "| Item #fi.currentrow# : The guid (guid_string) element '#fi[map.guid_string][currentrow]#' : Is not a valid URL which is a requirement when isPermaLink (guid_permalink) attribute is ignored or 'true' (See <a href='#instance.SpecRssEC#item-guid'>#instance.SpecRssEC#item-guid</a>)";
					} 
				}
				/* apple itunes */
				invalidList = invalidList & ituneseValItem(fi,map,currentrow);
				/* link */
				if( structKeyExists(fi,"#map.link#") and len(fi[map.link][currentrow]) and not validateURL(fi[map.link][currentrow]) ){
					invalidList = invalidList & "| Item #fi.currentrow# : The link element '#fi[map.link][currentrow]#' : Is not a valid URL (See <a href='#instance.SpecRssEC#item-link'>#instance.SpecRssEC#item-link</a>)";
				}
				/* pubDate */
				if( structKeyExists(fi,"#map.pubDate#") and len(fi[map.pubDate][currentrow]) ) {
					try {
					ParseDateTime(fi[map.pubDate][currentrow]);
				} catch(any excpt) {
						invalidList = invalidList & "| Item #fi.currentrow# : The pubDate element '#fi[map.pubDate][currentrow]#' : Cannot be converted into a date (See <a href='#instance.SpecCFML#ParseDateTime'>#instance.SpecCFML#ParseDateTime</a>)";
					}
				}
				/* slash */
				if ( structKeyExists(fi,"#map.slash_comments#")  or structKeyExists(fi,"#map.slash_hit_parade#") ) {
					invalidList = invalidList & slashValItem(fi,map,currentrow);
				}
				/* source */
				if( ( not structKeyExists(fi,"#map.source_url#") or not len(fi[map.source_url][currentrow]) ) and structKeyExists(fi,"#map.source_title#") and len(fi[map.source_title][currentrow]) ) {
					invalidList = invalidList & "| Item #fi.currentrow# : The source (source_title) element '#fi[map.source_title][currentrow]#' : Requires a URL attribute (source_url) (See <a href='#instance.SpecRssEC#item-source'>#instance.SpecRssEC#item-source</a>)";
				}
				else if( structKeyExists(fi,"#map.source_url#") and len(fi[map.source_url][currentrow]) and not validateURL(fi[map.source_url][currentrow]) ){
					invalidList = invalidList & "| Item #fi.currentrow# : The URL (source_url) attribute '#fi[map.source_url][currentrow]#' in the source element : Is not a valid URL (See <a href='#instance.SpecRssEC#item-source'>#instance.SpecRssEC#item-source</a>)";
				}
			</cfscript>
		</cfloop>
	
		<cfreturn invalidList>
	</cffunction>

	<!--- verifyFeed --->
	<cffunction name="verifyFeed" output="false" access="public" returntype="void" hint="Verify the RSS 2 feed structure and append auto-generated properties">
		<!--- ******************************************************************************** --->
		<cfargument name="feedStruct" 	type="struct" required="yes" 	hint="The structure used to build a feed">
		<cfargument name="ColumnMap" 	type="struct" default="#structNew()#"  hint="The column mapper to map items to queries"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var container_a = "";
			var container_b = "";
			var cs = arguments.ColumnMap;
			var fs = arguments.feedStruct;
			var fsKeys = structKeyList(arguments.feedStruct);
			var i = 1;
			var invalidDsp = "";
			var invalidItems = "";
			var invalidList = "";
			var j = 1;
			var throwErr = false;
			var validStruct = structNew();
			var invalidFeedLL = "";

			/* Verify mandatory properties */
			for( i=1; i lte listLen(instance.requiredItems); i=i+1 ){
				if( not listFindNoCase( fsKeys, listGetAt(instance.requiredItems,i) ) ){
					invalidItems = listAppend(invalidItems,listGetAt(instance.requiredItems,i));
				}
			}
			if( listLen(invalidItems) gte 2 ) {
				invalidList = invalidList & "| The mandatory keys: #invalidItems# were not found in the structure";
			}
			else if( listLen(invalidItems) eq 1 ) {
				invalidList = invalidList & "| The mandatory key: #invalidItems# was not found in the structure";
			}
			
			/* Disable Debug/Verify Feed Structure and Item Values */
			if( not structKeyExists(fs,'debug') or not isBoolean(fs.debug) or fs.debug ) {
			
			/* Verify properties values */
			/* atom self link */
			if( structKeyExists(fs,"atomSelfLink") and not validateURL(fs.atomSelfLink) ) {
				invalidList = invalidList & "| The Atom self-link element '#fs.atomSelfLink#' : Is not a valid URL (See <a href='#instance.SpecRssNS#atom-link'>#instance.SpecRssNS#atom-link</a>)";
			}
			/* category */
			if( structKeyExists(fs,"category") and isArray(fs.category) ) {
				for( i=1; i lte arrayLen(fs.category); i=i+1 ){
					if( structKeyExists(fs.category[i],"domain") and ( not structKeyExists(fs.category[i],"tag") or not len(fs.category[i].tag) ) ) {
						invalidList = invalidList & "| The #generateNumSuffix(i)# category domain attribute '#fs.category[i].domain#' : Requires a category tag element that cannot be left blank (See <a href='#instance.SpecRssEC#category'>#instance.SpecRssEC#category</a>)";
					}
				}
			}
			/* creative commons license */
			if( structKeyExists(fs,"commonslicense") ) {
				invalidList = invalidList & cclicenseValChannel(fs);
			}		
			/* cloud */
			if( structKeyExists(fs, "cloud") and ( not isStruct(fs.cloud) or not structKeyExists(fs.cloud,'domain') or not structKeyExists(fs.cloud,'path') or not structKeyExists(fs.cloud,'port') or not structKeyExists(fs.cloud,'protocol') or not structKeyExists(fs.cloud,'registerProcedure')) ){
					invalidList = invalidList & "| The cloud element must be a structure containing the elements: domain,path,port protocol,registerProcedure (See <a href='#instance.SpecRssEC#cloud'>#instance.SpecRssEC#cloud</a>)";
			}	
			if( structKeyExists(fs, "cloud") and structKeyExists(fs.cloud,"port") and not validateNNInteger(fs.cloud.port) ){
				invalidList = invalidList & "| The cloud attribute port '#fs.cloud.port#' : Must be a whole number, 0 or greater (See <a href='#instance.SpecRssEC#cloud'>#instance.SpecRssEC#cloud</a>)";
			}
			if( structKeyExists(fs, "cloud") and structKeyExists(fs.cloud,"protocol") and not listFindNoCase(instance.cloudProtocols,fs.cloud.protocol) ){
				invalidList = invalidList & "| The cloud attribute protocol '#fs.cloud.protocol#' : Must be either #instance.cloudProtocols# (See <a href='#instance.SpecRssEC#cloud'>#instance.SpecRssEC#cloud</a>)";
			}
			/* dcmi terms */
			if( structKeyExists(fs,"dcmiterm") and isStruct(fs.dcmiterm) ) {
				for( i=1; i lte structCount(fs.dcmiterm); i=i+1 ){
					container_a = listGetAt(structKeyList(fs.dcmiterm),i);
					if( not listFindNoCase(instance.dublinCoreTerms,container_a) ) {
						invalidList = invalidList & "| The DCMI element (dcmiterm) containing '#container_a#' : Is not a valid DCMI Term (See <a href='#instance.SpecDcmi#'>#instance.SpecDcmi#</a>)";
					}
				}
			}
			else if( structKeyExists(fs,"dcmiterm") and not isStruct(fs.dcmiterm) ) {
				invalidList = invalidList & "| The DCMI element (dcmiterm) must be a structure container '##structNew()##' : It can not be a text string";
			}
			/* image */
			if( structKeyExists(fs, "image") ){
				if( not isStruct(fs.image) or not structKeyExists(fs.image,'url') or not structKeyExists(fs.image,'title') or not structKeyExists(fs.image,'link') ){
					invalidList = invalidList & "| The image element must be a structure containing the elements: url,title,link (See <a href='#instance.SpecRssEC#image'>#instance.SpecRssEC#image</a>)";
				}
				else {
					if( structKeyExists(fs.image,"url") ){
						if( not validateURL(fs.image.url) ){
							invalidList = invalidList & "| The image url element '#fs.image.url#' : Is not a valid URL (See <a href='#instance.SpecRssEC#image-url'>#instance.SpecRssEC#image-url</a>)";
						}
						if( not listFindNoCase(instance.imageExtensions,listLast(fs.image.url,'.')) ){
							invalidList = invalidList & "| The image url element '#fs.image.url#' : Is not a valid image format, only #instance.imageExtensions# (PNG, GIF or JPEG) allowed (See <a href='#instance.SpecRssEC#image-url'>#instance.SpecRssEC#image-url</a>)";
						}
					}
					if( structKeyExists(fs.image,"link") and not validateURI(fs.image.link) ){
						invalidList = invalidList & "| The image link element '#fs.image.link#' : Is not a valid URI (See <a href='#instance.SpecRssEC#image-link'>#instance.SpecRssEC#image-link</a>)";
					}
					if( structKeyExists(fs.image,"height") and (not isNumeric(fs.image.height) or fs.image.height lt 0 or fs.image.height gt instance.imageHeight) ){
						invalidList = invalidList & "| The image height element '#fs.image.height#' : Must be a number between 0 and #instance.imageHeight# (See <a href='#instance.SpecRssEC#image-height'>#instance.SpecRssEC#image-height</a>)";
					}
					if( structKeyExists(fs.image,"width") and (not isNumeric(fs.image.width) or fs.image.width lt 0 or fs.image.width gt instance.imageWidth) ){
						invalidList = invalidList & "| The image width element '#fs.image.height#' : Must be a number between 0 and #instance.imageWidth# (See <a href='#instance.SpecRssEC#image-width'>#instance.SpecRssEC#image-width</a>)";
					}
				}
			}
			/* itunes */
			if( structKeyExists(fs,"itunes") ) { 
				invalidList = invalidList & itunesValChannel(fs);
			}
			/* language */
			if( structKeyExists(fs,"language") and not validateRFC1766(fs.language)){
				invalidList = invalidList & "| The language element '#fs.language#' : Is not a valid RSS language code (See <a href='#instance.SpecRssEC#language'>#instance.SpecRssEC#language</a>)";
			}
			/* link */
			if( structKeyExists(fs,"link") and not validateURL(fs.link)){
				invalidList = invalidList & "| The link element '#fs.link#' : Is not a valid URL (See <a href='#instance.SpecRssEC#link'>#instance.SpecRssEC#link</a>)";
			}
			/* managingEditor */
			if( structKeyExists(fs,"managingEditor") and not validatePerson(fs.managingEditor)){
				invalidList = invalidList & "| The managingEditor element '#fs.managingEditor#' : Is not a valid RSS person (See <a href='#instance.SpecRssEC#managingeditor'>#instance.SpecRssEC#managingeditor</a>)";
			}
			/* opensearch */
			if( structKeyExists(fs,"opensearch") ) {
				invalidList = invalidList & opensearchValChannel(fs);
			}
			/* skipDays */
			if( structKeyExists(fs,"skipDays")){
				validStruct = validateDaysList(fs.skipDays);
				if(len(validStruct.InvalidValues)) {
					invalidList = invalidList & "| The following list values '#validStruct.InvalidValues#' in the skipDays element : Must be full days of the week, ie Sunday,Saturday (See <a href='#instance.SpecRssEC#skipdays'>#instance.SpecRssEC#skipdays</a>)";
				}
				if(len(validStruct.DupeValues)) {
					invalidList = invalidList & "| The following list values '#validStruct.DupeValues#' are duplicates in the skipDays element : Duplicate values are not allowed (See <a href='#instance.SpecRssEC#skipdays'>#instance.SpecRssEC#skipdays</a>)";
				}
				if(find(',,',fs.skipDays)) {
					invalidList = invalidList & "| The skipDays element '#fs.skipDays#' : Is formatted incorrectly, please remove the cojoined commas (See <a href='#instance.SpecRssEC#skipdays'>#instance.SpecRssEC#skipdays</a>)";
				}
			}
			/* skipHours */
			if( structKeyExists(fs,"skipHours")){
				validStruct = validateHoursList(fs.skipHours);
				if(len(validStruct.InvalidValues)) {
					invalidList = invalidList & "| The following list values '#validStruct.InvalidValues#' in the skipHours element : Must be numbers between the ranges of 0 - 24 (See <a href='#instance.SpecRssEC#skiphours'>#instance.SpecRssEC#skiphours</a>)";
				}
				if(len(validStruct.DupeValues)) {
					invalidList = invalidList & "| The following list values '#validStruct.DupeValues#' are duplicates in the skipHours element : Duplicate values are not allowed (See <a href='#instance.SpecRssEC#skiphours'>#instance.SpecRssEC#skiphours</a>)";
				}
				if(find(',,',fs.skipHours)) {
					invalidList = invalidList & "| The skipDays element '#fs.skipHours#' : Is formatted incorrectly, please remove the cojoined commas (See <a href='#instance.SpecRssEC#skiphours'>#instance.SpecRssEC#skiphours</a>)";
				}
			}
			/* textInput */
			if( structKeyExists(fs, "textInput") ) {
				if( not isStruct(fs.textInput) or not structKeyExists(fs.textInput,'description') or not structKeyExists(fs.textInput,'link') or not structKeyExists(fs.textInput,'name') or not structKeyExists(fs.textInput,'title')) {
					invalidList = invalidList & "| The textInput element must be a structure containing the elements: description,link,name,title (See <a href='#instance.SpecRssEC#textinput'>#instance.SpecRssEC#textinput</a>)";	}
				if(not len(fs.textInput.name)) {
					invalidList = invalidList & "| The textInput element 'name' can not be left as an empty value (See <a href='#instance.SpecRssEC#textinput-name'>#instance.SpecRssEC#textinput-name</a>)";
				}
				if( reFindNoCase('[^a-z0-9\-\:\.\_]+', fs.textInput.name) ) {
					invalidList = invalidList & "| The textInput element 'name' value '#fs.textInput.name#' contains invalid characters : Only these characters are allowed :-._ in addition to alphanumerics (See <a href='#instance.SpecRssEC#textinput-name'>#instance.SpecRssEC#textinput-name</a>)";
				}
				if( structKeyExists(fs.textInput,"link") and not validateURL(fs.textInput.link)){
					invalidList = invalidList & "| The textInput element 'link' '#fs.textInput.link#' : Is not a valid URL (See <a href='#instance.SpecRssEC#textinput-link'>#instance.SpecRssEC#textinput-link</a>)";
				}
			}
			/* time to live */
			if( structKeyExists(fs,"ttl") and not validateNNInteger(fs.ttl)){
				invalidList = invalidList & "| The TTL element '#fs.ttl#' : Must be a positive, non-decimal number representing minutes (See <a href='#instance.SpecRssEC#ttl'>#instance.SpecRssEC#ttl</a>)";
			}
			/* webMaster */
			if( structKeyExists(fs,"webMaster") and not validatePerson(fs.webMaster)){
				invalidList = invalidList & "| The webMaster element '#fs.webMaster#' : Is not a valid RSS person (See <a href='#instance.SpecRssEC#webmaster'>#instance.SpecRssEC#webmaster</a>)";
			}
			}// completed debugging and validating

			/* Conversions */
			/* lastBuildDate */
			if( structKeyExists(fs,"lastBuildDate") ) {
				if(validateRFC822Date(fs.lastBuildDate)) {
					// if lastBuildDate is already a valid RFC822 date, do nothing
				}
				else {
					// convert the given date into a valid RFC822 date
					fs["lastBuildDate"] = generateRFC822Date(fs.lastBuildDate);
				}
			}
			/* pubDate */
			if( structKeyExists(fs,"pubDate") ) {
				if(validateRFC822Date(fs.pubDate)) {
					// if pubDate is already a valid RFC822 date, do nothing
				}
				else {
					// convert the given date into a valid RFC822 date
					fs["pubDate"] = generateRFC822Date(fs.pubDate);
				}
			}

			/* Append auto-generated data */
			/* docs */
			fs["docs"] = instance.SpecRss;

			/* Items isQuery validation */
			if( structKeyExists(fs,"items") ) {
				if( not isQuery(fs.items) ){
					invalidList = invalidList & "| The items element must be a valid query.";
				}
				else {
					invalidList = verifyItems(fs.items,cs,invalidList);
				}
			}

			/* Display all debug/validation errors */
			if(len(invalidList)) {
				invalidFeedLL = listLen(invalidList,'|');
				for(i=1;i lte invalidFeedLL;i=i+1) {
					// replace '|' placeholder with the HTML new line tag and error count
					invalidDsp = invalidDsp & "<br />#i#. " & listGetAt(invalidList,1,'|');
					invalidList = ListDeleteAt(invalidList,1,'|');
				}
				// display the error messages
				throwErr = true;
			}
		</cfscript>
		<cfif throwErr>
			<cfthrow type="RSS2Generator.InvalidFeedStructure" message="The generated RSS feed has some problems which makes it incomplete"  detail="#invalidDsp#">
		</cfif>
	</cffunction>

</cfcomponent>