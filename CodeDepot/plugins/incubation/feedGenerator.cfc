<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Ben Garrett and Luis Majano
Date        :	26/12/2008
Version     :	2 (beta 21Jan09)
License		: 	Apache 2 License
Description :
	This is a feed generator. It is able to output RSS 2.0 feeds.	
	You need to set the following settings in your application (coldbox.xml.cfm)

METHODS:

	- CreateFeed( feedStruct:struct, [ColumnMap:struct] [OutputFile:string] [OutputXML:boolean] ): XML or Boolean
	  
	  This method will create the feed and return it to the caller in XML format.
	  * feedStruct : The properties and items structure.
	  * ColumnMap : You create a structure that will map the RSS elements to your query.
	  * OutputFile : The file path of where to write the feed to.
	  * OutputXML : Boolean (default:false) display generated XML on screen.


	Debugging (these methods can be ignored)

	- getDefaultPropertyMap(): Struct
	  
	  This method creates a structure listing of all the default property maps for dumping.

	- parseColumnMap( columnMap:struct ): Struct
	  
	  This method parses and validates a supplied column map, returning the results for dumping.
	  * columnMap : Column map structure (see below).

INSTRUCTIONS
The properties structure must conform to the following rules:

When you create a feed, you specify the feed content in a combination of a query object and
a properties structure. This plug-in generates the feed XML and returns the results. Using
the OutputXML method this result can either be a Boolean return or a display of the generated
XML code. In addition one can save the XML as a file using the OutputFile method, containing
a path of where to store the XML data. It is best practise to point users to this generated
file and only run this feed plug-in when the XML file needs to be updated with new content.

MANDATORY STRUCTURE PROPERTIES
To create an RSS 2.0 feed you must specify the following metadata fields in a structure. 

 * title : string : The name of the feed.
 * link : string : The URL to the HTML website corresponding to this feed.
 * description : string : Phrase or sentence describing this feed.

 * items : query : A query of all the items to aggregate (only mandatory if you require feed items.)

OPTIONAL PROPERTIES

 * copyright : string : Information on the feed's copyright.
 * language : string : WC3 or Netscape defined language code.
 * managingEditor : string : E-Mail address of the editor.
 * webMaster : string : E-Mail address of the web master.
 * pubDate : any date : Date the items were last updated.
 * lastBuildDate : any date : Date the feed structure last changed.
 * category : multiple arrays : struct
   * tag : string : Feed categorization.
   * domain : string : Taxonomy of the categorization.
 * image : struct
   * url : string : The URL of the image.
   * title : string : Describe the image, used in the ALT property.
   * link : string : The URL of the site, when the feed is rendered, the image is a link to the site.
   * width : numeric : The optional width of the image, maximum of 144.
   * height : numeric : The optional height of the image, maximum of 400.
   * description : string : The optional title description.
 * ttl : numeric : Number of minutes indicating how long a feed can be cached.
 * skipDays : numeric list : A hint for aggregators telling them which days they can skip.
 * skipHours : numeric list : A hint for aggregators telling them which hours they can skip.

OPTIONAL 3RD PARTY (EXTENSIONS) PROPERTIES
 * atomselfLink : string : A URL pointing to this feed.
 * commonslicense : list : A list of URLs pointing to the feed Creative Commons licenses.
 * dcmiterm : struct
   * [term name] : See http://dublincore.org/documents/dcmi-terms/ for a list of term names and their use.
 * itunes : struct
   * block : string : If 'yes' this prevents the entire podcast appearing in the iTunes Podcast directory.
   * category : multiple structures
     * [category for podcasting] : string : Optional sub-category belonging to the category structure.
   * explicit : 'clean','yes','no' : Indicate whether or not your podcast contains explicit material.
   * image : string : A URL pointing to the artwork for your podcast.
   * keywords : list : Up to 12 keywords used in podcast searches.
   * new_feed_url : string : This tag allows you to change the URL where the podcast is located.
   * owner : struct
     * email: string : Contact e-mail for communication specifically about the podcast.
     * name: string : Contact name for communication specifically about the podcast.
   * summary : string : A description of the podcast which can be up to 4000 characters.
   * subtitle: string : A short description of the podcast. Displays best if it is only a few words long.
 * opensearch : struct
   * autodiscovery : string : A URL to an OpenSearch description document via the Atom "link" element.
   * itemsperpage : numeric : The number of search results returned per page.
   * startindex : numeric : The index of the first search result in the current set of search results.
   * totalresults : numeric : The number of search results available for the current search.
 * opensearchQuery : multiple arrays : struct
     * role : 'request','example','related','correction','subset','superset' : Search interpretation.
     * title : string : Describing the search request.
     * totalResults : string : Expected number of results to be found if the search request were made.
     * searchTerms : list : Search keywords.
     * count : string : Number of search results per page desired by the search client..
     * startIndex : string : Index of the first search result desired by the search client.
     * startPage : string : Page number of the set of search results desired by the search client.
     * language : string : Search engine supports search results in the specified language.
     * inputEncoding : string : Search requests encoded with the specified character encoding.
     * outputEncoding : string : Search responses encoded with the specified character encoding.
	
RARELY USED BUT SUPPORTED OPTIONAL PROPERTIES

 * cloud : struct
   * domain : string : URLs of RSS documents that the client seeks to monitor.
   * port : numeric : Client TCP port.
   * path : string : Client remote procedure call path.
   * protocol : string : 'xml-rpc' or 'soap'.
   * registerProcedure : string : Name of the remote procedure the cloud should call.
 * rating : string : PICS rating for the feed.
 * textInput : struct
   * title : string : Label of the Submit button in the text input area.
   * description : string : Explains the text input area.
   * name : string : The name of the text object in the text input area.
   * link : string : The URL of the CGI script that processes text input requests.

QUERIES REQUIRED FIELDS
You must have ONE of following required fields in your query or use the columnMap attribute explained below:

 * title : string : Title of the item.
 * description : string : The item synopsis.

QUERIES OPTIONAL FIELDS
 * author : string : The e-mail address of the author of this item.
 * category_tag : list : Item categorization.
 * category_domain : list : Taxonomy of the categorization.
 * comments : string : The URL to the comments of this item.
 * enclosure_url : list : The URL of the file attachment.
 * enclosure_length : numeric list : Size in bytes of the file attachment.
 * enclosure_type : list : MIME/Type of the file attachment.
 * link : string : URL to the complete item.
 * guid_string : string : A string that uniquely identifies this item.
 * guid_permalink : boolean : Whether the uniquely identifier is a permanent URL or not.
 * pubDate : any date : The date when this item was published.
 * source_title : string : Title of another RSS feed where this item has been republished from.
 * source_url : string : URL to the other RSS feed.

OPTIONAL 3RD PARTY (EXTENSIONS) FIELDS
 * atomselfLink : string : A URL pointing to this item.
 * commonslicense : list : A list of URLs pointing to the item's Creative Commons licenses.
 * content_encoded : string : Offers a means of defining item content with more precision than the description element.
 * dcmiterm_[term name] : See http://dublincore.org/documents/dcmi-terms/ for a list of term names.
 * itunes_author : string : Author of this episode, the content is shown in the Artist column in iTunes.
 * itunes_block : string : Prevent this episode from appearing in the iTunes Podcast directory.
 * itunes_duration : string : Is shown in the time column in iTunes showing the length of this episode.
 * itunes_keywords : list : Up to 12 keywords used in episode searches.
 * itunes_subtitle : string : A short description of the episode. Displays best if it is only a few words long.
 * itunes_summary : string : A description of the episode which can be up to 4000 characters.
 * slash_comments : numeric : Total number of comments.
 * slash_hit_parade : numeric list : A list of the total number of comments for the past 7 days.
 * slash_department : string : Used by SlashDot for one-liner humour.
 * slash_section : string : A simplified, single word replacement for category.


COLUMNMAP
In most cases, a database table uses column names that differ from the column names you must use to create the feed. 
Therefore, you must use the columnmap attribute to map the input query column names to the required column names. To
see a list of the default mappings use the getDefaultPropertyMap() method.

<!--- Get the feed data as a query from the orders table. --->
<cfquery name="getOrders" datasource="cfartgallery"> 
    SELECT * FROM orders 
</cfquery>

<!--- Map the orders column names to the feed query column names. --->
<cfset columnMapStruct = structNew()>
<cfset columnMapStruct.pubDate = "ORDERDATE"> 
<cfset columnMapStruct.description = "CONTENT"> 
<cfset columnMapStruct.title = "CUSTOMERFIRSTNAME"> 
<cfset columnMapStruct.link = "ORDERID">
	
----------------------------------------------------------------------->
<cfcomponent name="feedGenerator" 
			 extends="coldbox.system.plugin"
			 hint="A feed generator plug-in. This plug-in only generates RSS 2.0 feeds."
			 cache="true">

<!---------------------------------------- CONSTRUCTOR --------------------------------------------------->

	<cffunction name="init" access="public" returntype="feedGenerator" output="false" hint="Plug-in Constructor.">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			/* Super */
			super.Init(arguments.controller);
			
			/* Plug-in Properties */
			setpluginName("ColdBox RSS 2.0.10 Feed Generator");
			setpluginVersion("2.0 21Jan09 BETA");
			setpluginDescription("I create Really Simple Syndication (RSS revision 2.0.10) feeds that also allow a variety of popular RSS extensions.");
			
			/* Localised variables */
			/* Dublin Core Metadata Element Set, Version 1.1 */
			instance.DCMITerms = "contributor,coverage,creator,date,description,format,identifier,language,publisher,relation,rights,source,subject,title,type";
			
			/* Apple iTunes Categories Collection */
			instance.ItunesCategories = structNew();
			instance.ItunesCategories["Arts"] = "Design,Fashion & Beauty,Food,Literature,Performing Arts,Visual Arts";
			instance.ItunesCategories["Business"] = "Business News,Careers,Investing,Management & Marketing,Shopping";
			instance.ItunesCategories["Comedy"] = "";
			instance.ItunesCategories["Education"] = "Education Technology,Higher Education,K-12,Language Courses,Training";
			instance.ItunesCategories["Games & Hobbies"] = "Automotive,Aviation,Hobbies,Other Games,Video Games";
			instance.ItunesCategories["Government & Organizations"] = "Local,National,Non-Profit,Regional";
			instance.ItunesCategories["Health"] = "Alternative Health,Fitness & Nutrition,Self-Help,Sexuality";
			instance.ItunesCategories["Kids & Family"] = "";
			instance.ItunesCategories["Music"] = "";
			instance.ItunesCategories["News & Politics"] = "";
			instance.ItunesCategories["Religion & Spirituality"] = "Buddhism,Christianity,Hinduism,Islam,Judaism,Other,Spirituality";
			instance.ItunesCategories["Science & Medicine"] = "Medicine,Natural Sciences,Social Sciences";
			instance.ItunesCategories["Society & Culture"] = "History,Personal Journals,Philosophy,Places & Travel";
			instance.ItunesCategories["Sports & Recreation"] = "Amateur,College & High School,Outdoor,Professional";
			instance.ItunesCategories["Technology"] = "Gadgets,Tech News,Podcasting,Software How-To";
			instance.ItunesCategories["TV & Film"] = "";
			
			/* Validation Values */
			instance.reqItems 	= "title,link,description"; // required rss elements
			instance.valClPro 	= 'xml-rpc,soap'; // allowed rss cloud protocols
			instance.valImgs 		= "png,gif,jpg,jpeg,jpe,jif,jfif,jfi"; // valid image file extensions for rss image
			instance.valImgsMH 	= 400; // maximum image height for rss image
			instance.valImgsMW 	= 144; // maximum image width for rss image
			instance.valITExp 	= "yes,no,clean"; // allowed values for itunes explicit
			instance.valITImg 	= "png,jpg"; // allowed image file extensions for itunes image
			instance.valITkey 	= 12; // maximum list of items for itunes keywords
			instance.valITSum 	= 4000; // maximum characters allowed in itunes summary
			instance.valOSRol		=	"request,example,related,correction,subset,superset"; // allowed opensearch query roles
			instance.valOSTit		=	256; // maxium characters allowed in opensearch query title
			instance.valSkipD		=	"Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday"; // valid days allowed for rss skipDays
			
			/* List of top level domains (used for URL validation) */
			instance.valTLDS		= "AC,AD,AEAERO,AF,AG,AI,AL,AM,AN,AO,AQ,AR,ARPA,AS,ASIA,AT,AU,AW,AX,AZ,BA,BB,BD,BE,BF,BG,BH,BI,BIZ,BJ,BM,BN,BO,BR,BS,BT,BV,BW,BY,BZ,CA,CAT,CC,CD,CF,CG,CH,CI,CK,CL,CM,CN,CO,COM,COOP,CR,CU,CV,CX,CY,CZ,DE,DJ,DK,DM,DO,DZ,EC,EDU,EE,EG,ER,ES,ET,EU,FI,FJ,FK,FM,FO,FR,GA,GB,GD,GE,GF,GG,GH,GI,GL,GM,GN,GOV,GP,GQ,GR,GS,GT,GU,GW,GY,HK,HM,HN,HR,HT,HU,ID,IE,IL,IM,IN,INFO,INT,IO,IQ,IR,IS,IT,JE,JM,JO,JOBS,JP,KE,KG,KH,KI,KM,KN,KP,KR,KW,KY,KZ,LA,LB,LC,LI,LK,LR,LS,LT,LU,LV,LY,MA,MC,MD,ME,MG,MH,MIL,MK,ML,MM,MN,MO,MOBI,MP,MQ,MR,MS,MT,MU,MUSEUM,MV,MW,MX,MY,MZ,NA,NAME,NC,NE,NET,NF,NG,NI,NL,NO,NP,NR,NU,NZ,OM,ORG,PA,PE,PF,PG,PH,PK,PL,PM,PN,PR,PRO,PS,PT,PW,PY,QA,RE,RO,RS,RU,RW,SA,SB,SC,SD,SE,SG,SH,SI,SJ,SK,SL,SM,SN,SO,SR,ST,SU,SV,SY,SZ,TC,TD,TEL,TF,TG,TH,TJ,TK,TL,TM,TN,TO,TP,TR,TRAVEL,TT,TV,TW,TZ,UA,UG,UK,US,UY,UZ,VA,VC,VE,VG,VI,VN,VU,WF,WS,XN--0ZWM56D,XN--11B5BS3A9AJ6G,XN--80AKHBYKNJ4F,XN--9T4B11YI5A,XN--DEBA0AD,XN--G6W251D,XN--HGBK6AJ7F53BBA,XN--HLCJ6AYA9ESC7A,XN--JXALPDLP,XN--KGBECHTV,XN--ZCKZAH,YE,YT,YU,ZA,ZM,ZW";
			
			/* Specification References */
			instance.SpecApple 	= "http://www.apple.com/itunes/whatson/podcasts/specs.html##";
			instance.SpecCFML		= "http://cfquickdocs.com/";
			instance.SpecDcmi		= "http://dublincore.org/documents/dcmi-terms/";
			instance.SpecOS 		= "http://www.opensearch.org/Specifications/OpenSearch/1.1##";
			instance.SpecRss 		= "http://www.rssboard.org/rss-specification";
			instance.SpecRssEC 	= "http://www.rssboard.org/rss-profile##element-channel-";
			instance.SpecRssNS 	= "http://www.rssboard.org/rss-profile##namespace-elements-";
			instance.SpecSlash	= "http://web.resource.org/rss/1.0/modules/slash/";

			/* Return instance */
			return this;
		</cfscript>
	</cffunction>

<!---------------------------------------- PUBLIC RSS METHODS --------------------------------------------------->
	
	<cffunction name="createFeed" access="public" returntype="any" hint="Create an RSS 2.0 feed." output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="feedStruct" 	type="struct" required="yes" hint="The structure used to build a feed. Look at docs for more info.">
		<cfargument name="ColumnMap" 	type="struct" default="#structNew()#" hint="The column mapper to use for the items query."/>
		<cfargument name="OutputFile" 	type="string" required="false" hint="The file destination of where to store the generated XML"/>
    <cfargument name="OutputXML"	type="boolean" default="false" hint="Display the XML output on-screen"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var fs = arguments.feedStruct;
			var cm = arguments.ColumnMap;
			var xmlContent = "";
			var xmlCleaned = "";
			var i = 0;
			var j = 0;
			var container = "";
		
			/* Verify our Structure */
			verifyFeed(fs,cm);
			
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
          <cfif structKeyExists(fs,"opensearch")>
						<!--- Optional Open Search 1.1 (draft 3) total results --->
            <cfif structKeyExists(fs.opensearch,"totalresults")><opensearch:totalResults>#RSSFormat(fs.opensearch["totalresults"])#</opensearch:totalResults></cfif>
            <!--- Optional Open Search 1.1 (draft 3) start index --->
            <cfif structKeyExists(fs.opensearch,"startindex")><opensearch:startIndex>#RSSFormat(fs.opensearch["startindex"])#</opensearch:startIndex></cfif>
            <!--- Optional Open Search 1.1 (draft 3) items per page --->
            <cfif structKeyExists(fs.opensearch,"itemsperpage")><opensearch:itemsPerPage>#RSSFormat(fs.opensearch["itemsperpage"])#</opensearch:itemsPerPage></cfif>
            <!--- Optional Open Search 1.1 (draft 3) Atom search link --->
            <cfif structKeyExists(fs.opensearch,"autodiscovery")><atom:link href="#URLFormat(fs.opensearch['autodiscovery'])#" rel="search" type="application/opensearchdescription+xml" title="Content Search"/></cfif>
            <!--- Optional Open Search 1.1 (draft 3) query --->
            <cfif structKeyExists(fs,"opensearchQuery") and isArray(fs.opensearchQuery)>
            <cfloop from="1" to="#arrayLen(fs.opensearchQuery)#" index="i">
            <opensearch:Query 
            role="#RSSFormat(fs.opensearchQuery[i]["role"])#"
            <cfif structKeyExists(fs.opensearchQuery[i],"title")> title="#RSSFormat(fs.opensearchQuery[i]['title'])#"</cfif>
            <cfif structKeyExists(fs.opensearchQuery[i],"totalResults ")> totalResults="#RSSFormat(fs.opensearchQuery[i]['totalResults '])#"</cfif>
            <cfif structKeyExists(fs.opensearchQuery[i],"searchTerms")> searchTerms="#URLFormat(fs.opensearchQuery[i]['searchTerms'])#"</cfif>
            <cfif structKeyExists(fs.opensearchQuery[i],"count")> count="#RSSFormat(fs.opensearchQuery[i]['count'])#"</cfif>
            <cfif structKeyExists(fs.opensearchQuery[i],"startIndex")> startIndex="#RSSFormat(fs.opensearchQuery[i]['startIndex'])#"</cfif>
            <cfif structKeyExists(fs.opensearchQuery[i],"startPage")> startPage="#RSSFormat(fs.opensearchQuery[i]['startPage'])#"</cfif>
            <cfif structKeyExists(fs.opensearchQuery[i],"language")> language="#RSSFormat(fs.opensearchQuery[i]['language'])#"</cfif>
            <cfif structKeyExists(fs.opensearchQuery[i],"inputEncoding")> inputEncoding="#RSSFormat(fs.opensearchQuery[i]['inputEncoding'])#"</cfif>
            <cfif structKeyExists(fs.opensearchQuery[i],"outputEncoding")> outputEncoding="#RSSFormat(fs.opensearchQuery[i]['outputEncoding'])#"</cfif>
            />
            </cfloop>
            </cfif>
          </cfif>
          <!--- Optional category --->
          <cfif structKeyExists(fs,"category") and isArray(fs.category)>
						<cfloop from="1" to="#arrayLen(fs.category)#" index="i">
            	<cfif structKeyExists(fs.category[i],"domain") and structKeyExists(fs.category[i],"tag")>
              	<category domain="#fs.category[i].domain#">#fs.category[i].tag#</category>
              <cfelseif structKeyExists(fs.category[i],"tag")>
              	<category>#fs.category[i].tag#</category>
              </cfif>
            </cfloop>
            <cfset i = 0>
          </cfif>
          <!--- Optional cloud --->
          <cfif structKeyExists(fs,"cloud")>
					<cloud
          	domain="#URLFormat(fs.cloud["domain"])#"
            path="#URLFormat(fs.cloud["path"])#"
            port="#URLFormat(fs.cloud["port"])#"
            protocol="#URLFormat(fs.cloud["protocol"])#"
            registerProcedure="#URLFormat(fs.cloud["registerProcedure"])#"
          />
					</cfif>
       		<!--- Optional Creative Commons license extension --->
          <cfif structKeyExists(fs,"commonslicense")>
          	<cfloop from="1" to="#listLen(fs['commonslicense'])#" index="i">
            <creativeCommons:license>#RSSFormat(listGetAt(fs["commonslicense"],i))#</creativeCommons:license>
            </cfloop>
          </cfif>
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
          	<cfset container = listGetAt(fs['skipDays'],i)>
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
          <cfif structKeyExists(fs,"itunes")>
						<!--- Optional iTunes author --->
            <cfif structKeyExists(fs.itunes,"author")><itunes:author>#RSSFormat(fs.itunes["author"])#</itunes:author></cfif>
            <!--- Optional iTunes block --->
            <cfif structKeyExists(fs.itunes,"block")><itunes:block>#RSSFormat(fs.itunes["block"])#</itunes:block></cfif>
            <!--- Optional iTunes category --->
            <cfif structKeyExists(fs.itunes,"category") and isStruct(fs.itunes.category)>
              <cfloop from="1" to="#structCount(fs.itunes.category)#" index="i">
                <cfset container = listGetAt(structKeyList(fs.itunes.category),i)>
                <cfif listFindNoCase(structKeyList(instance.ItunesCategories),container) and not len(fs.itunes.category[container])>
                  <itunes:category text="#RSSFormat(container)#"/>
                <cfelseif listFindNoCase(structKeyList(instance.ItunesCategories),container) and len(fs.itunes.category[container])>
                  <cfloop from="1" to="#listLen(fs.itunes.category[container])#" index="j">
                    <cfif listFindNoCase(instance.ItunesCategories[container],listGetAt(fs.itunes.category[container],j))> 
                    <itunes:category text="#RSSFormat(container)#">
                      <itunes:category text="#RSSFormat(listGetAt(fs.itunes.category[container],j))#"/>
                    </itunes:category>
                    </cfif>
                  </cfloop>
                </cfif>
              </cfloop>
            </cfif>       
            <!--- Optional iTunes image --->   
            <cfif structKeyExists(fs.itunes,"image")><itunes:image href="#URLFormat(fs.itunes['image'])#"/></cfif>
            <!--- Optional iTunes explicit --->
            <cfif structKeyExists(fs.itunes,"explicit")><itunes:explicit>#RSSFormat(fs.itunes["explicit"])#</itunes:explicit></cfif>
            <!--- Optional iTunes keywords --->
            <cfif structKeyExists(fs.itunes,"keywords")><itunes:keywords>#RSSFormat(fs.itunes["keywords"])#</itunes:keywords></cfif>
            <!--- Optional iTunes new-feed-url --->
            <cfif structKeyExists(fs.itunes,"new_feel_url")><itunes:new_feel_url>#URLFormat(fs.itunes["new_feel_url"])#</itunes:new_feel_url></cfif>
            <!--- Optional iTunes owner --->
            <cfif structKeyExists(fs.itunes,"owner")>
            <itunes:owner>
              <itunes:email>#URLFormat(fs.itunes.owner["email"])#</itunes:email>
              <itunes:name>#URLFormat(fs.itunes.owner["name"])#</itunes:name>
            </itunes:owner>
            </cfif>
            <!--- Optional iTunes subtitle --->
            <cfif structKeyExists(fs.itunes,"subtitle")><itunes:subtitle>#RSSFormat(fs.itunes["subtitle"])#</itunes:subtitle></cfif>
            <!--- Optional iTunes summary --->
            <cfif structKeyExists(fs.itunes,"summary")><itunes:summary>#RSSFormat(fs.itunes["summary"])#</itunes:summary></cfif>
          </cfif>
          <!--- Optional DCMI Metadata terms --->
          <cfif structKeyExists(fs,"dcmiterm") and isStruct(fs.dcmiterm)>
            <cfloop from="1" to="#structCount(fs.dcmiterm)#" index="i">
							<cfset container = listGetAt(structKeyList(fs.dcmiterm),i)>
							<cfif listFindNoCase(instance.DCMITerms,container)>
              	<dc:#container#>#RSSFormat(fs.dcmiterm[container])#</dc:#container#>
              </cfif>
            </cfloop>
          </cfif>          
			    <!--- Optional RSS Items --->
			   	#generateItems(argumentCollection=arguments)#
			</channel>
	  </rss>
		</cfoutput>
		</cfxml>
		
    <!--- Apply XSL Formating to Messy XML Code --->
    <cfset xmlCleaned = XMLTransform(xmlContent,XSLFormat())/>

		<!--- Check for File Output --->
		<cfif structKeyExists(arguments,"OutputFile")>
			<cffile action="write" file="#arguments.OutputFile#" output="#xmlCleaned#" charset="utf-8"/>
		</cfif>	
    
    <!--- Check for On Screen Output --->
    <cfif arguments.OutputXML>
    	<cfcontent variable="#ToBinary(ToBase64(xmlCleaned))#" type="text/xml"/>
    <cfelse>
    	<cfreturn true/>
    </cfif>

	</cffunction>

	<!--- ******************************************************************************** --->

	
<!---------------------------------------- PRIVATE --------------------------------------------------->
	
	<!--- generateItems --->
	<cffunction name="generateItems" output="false" access="private" returntype="string" hint="Generate the items XML">
		<!--- ******************************************************************************** --->
		<cfargument name="feedStruct" 	type="struct" required="yes" 	hint="The structure used to build a feed. Look at docs for more info.">
		<cfargument name="ColumnMap" 	type="struct" required="false"  hint="The column mapper to use for the items query."/>
		<!--- ******************************************************************************** --->
    <cfscript>
			var i = 0;
			var items = "";
			var itemsXML = "";
			var local = structnew();
			var map = getDefaultPropertyMap();
			var term = "";
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
			/* For some optional variables */
			local = structnew();
			/* Date Tests */
			if( structKeyExists(items, "#map.pubdate#") ){
				if( validateRFC822Date(items[map.pubdate][currentRow]) ) {
					// if pubdate is already a valid RFC822 date, do nothing
					local.pubDate = items[map.pubdate][currentRow];
				}
				else if ( len(items[map.pubdate][currentRow]) ) {
					// convert the given date into a valid RFC822 date
					local.pubDate = generateRFC822Date(items[map.pubdate][currentRow]);
				}
			}
			//else{ local.pubDate = generateRFC822Date(now()); }
			/* PermaLink Tests */
			if( structKeyExists(items,"#map.guid_permalink#") and len(items[map.guid_permalink][currentRow]) ){
				local.guid_permaLink = RSSFormat(items[map.guid_permalink][currentrow]);
			}
			else{ local.guid_permaLink = "false"; }
			/* Enclosure Tests */
			if( structKeyExists(items,"#map.enclosure_url#") ){
				local.enclosure = structnew();
				local.enclosure.url = URLFormat(items[map.enclosure_url][currentrow]);
				/* Length */
				if( structKeyExists(items, "#map.enclosure_length#") ){
					local.enclosure.length = RSSFormat(items[map.enclosure_length][currentrow]);
				}
				else{ local.enclosure.length = ""; }
				/* Type */
				if( structKeyExists(items, "#map.enclosure_type#") ){
					local.enclosure.type = RSSFormat(items[map.enclosure_type][currentrow]);
				}
				else{ local.enclosure.type = ""; }				
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
      <cfif structKeyExists(local,"pubDate") and len(local.pubDate)>
			<pubDate>#local.pubDate#</pubDate>
      </cfif>
			<!--- Optional author --->
			<cfif structKeyExists(items,"#map.author#") and len(items[map.author][currentrow])>
			<author>#RSSFormat(items[map.author][currentrow])#</author>
			</cfif>
			<!--- Optional comments --->
			<cfif structKeyExists(items,"#map.comments#") and len(items[map.comments][currentrow])>
			<comments>#URLFormat(items[map.comments][currentrow])#</comments>
			</cfif>
      <!--- Optional slash section extension --->
			<cfif structKeyExists(items,"#map.slash_section#") and len(items[map.slash_section][currentrow])>
			<slash:section>#RSSFormat(items[map.slash_section][currentrow])#</slash:section>
			</cfif>
      <!--- Optional slash department extension --->
			<cfif structKeyExists(items,"#map.slash_department#") and len(items[map.slash_department][currentrow])>
			<slash:department>#RSSFormat(items[map.slash_department][currentrow])#</slash:department>
			</cfif>
      <!--- Optional slash comments extension --->
			<cfif structKeyExists(items,"#map.slash_comments#") and len(items[map.slash_comments][currentrow])>
			<slash:comments>#RSSFormat(items[map.slash_comments][currentrow])#</slash:comments>
			</cfif>
      <!--- Optional slash hit parade extension --->
			<cfif structKeyExists(items,"#map.slash_hit_parade#") and len(items[map.slash_hit_parade][currentrow])>
			<slash:hit_parade>#RSSFormat(items[map.slash_hit_parade][currentrow])#</slash:hit_parade>
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
			<guid isPermaLink="#RSSFormat(local.guid_permaLink)#">#RSSFormat(items[map.guid_string][currentrow])#</guid>
			</cfif>
      <!--- Optional DCMI Metadata terms --->
      <cfif listContainsNoCase(items.columnList,'dcmiterm_')>
      	<cfloop from="1" to="#listLen(items.columnList)#" index="i">
        	<cfset term = replaceNocase(listGetAt(items.columnList,i),'dcmiterm_','')>
        	<cfif listFindNoCase(instance.dcmiterms,term) and listFindNoCase(items.columnList,'dcmiterm_#term#') and len(items["dcmiterm_#term#"][currentrow]) >
          	<cfset term = listGetAt(instance.dcmiterms,listFindNocase(instance.dcmiterms,term))>
          	<dc:#term#>#RSSFormat(items["dcmiterm_#term#"][currentrow])#</dc:#term#>
          </cfif>
        </cfloop>
      </cfif>
      <!--- Apple iTunes extension --->
      <!--- Optional author --->
			<cfif structKeyExists(items,"#map.itunes_author#") and len(items[map.itunes_author][currentrow])>
			<itunes:author>#RSSFormat(items[map.itunes_author][currentrow])#</itunes:author>
			</cfif>
      <!--- Optional block --->
			<cfif structKeyExists(items,"#map.itunes_block#") and len(items[map.itunes_block][currentrow])>
			<itunes:block>#RSSFormat(items[map.itunes_block][currentrow])#</itunes:block>
			</cfif>
      <!--- Optional duration --->
			<cfif structKeyExists(items,"#map.itunes_duration#") and len(items[map.itunes_duration][currentrow])>
			<itunes:duration>#RSSFormat(items[map.itunes_duration][currentrow])#</itunes:duration>
			</cfif>
      <!--- Optional explicit --->
			<cfif structKeyExists(items,"#map.itunes_explicit#") and len(items[map.itunes_explicit][currentrow])>
			<itunes:explicit>#RSSFormat(items[map.itunes_explicit][currentrow])#</itunes:explicit>
			</cfif>
      <!--- Optional keywords --->
			<cfif structKeyExists(items,"#map.itunes_keywords#") and len(items[map.itunes_keywords][currentrow])>
			<itunes:keywords>#RSSFormat(items[map.itunes_keywords][currentrow])#</itunes:keywords>
			</cfif>
      <!--- Optional subtitle --->
			<cfif structKeyExists(items,"#map.itunes_subtitle#") and len(items[map.itunes_subtitle][currentrow])>
			<itunes:subtitle>#RSSFormat(items[map.itunes_subtitle][currentrow])#</itunes:subtitle>
			</cfif>
      <!--- Optional summary --->
			<cfif structKeyExists(items,"#map.itunes_summary#") and len(items[map.itunes_summary][currentrow])>
			<itunes:summary>#RSSFormat(items[map.itunes_summary][currentrow])#</itunes:summary>
			</cfif>
      <!--- Optional creative commons license extension --->
      <cfif structKeyExists(items,"#map.commonslicense#") and len(items[map.commonslicense][currentrow])>
        <cfloop from="1" to="#listLen(items[map.commonslicense][currentrow])#" index="i">
        <creativeCommons:license>#URLFormat(listGetAt(items[map.commonslicense][currentrow],i))#</creativeCommons:license>
        </cfloop>
      </cfif>
			<!--- Optional enclosure --->
			<cfif structKeyExists(local,"enclosure") and Len(local.enclosure.url)>
      	<cfloop from="1" to="#listLen(local.enclosure.url)#" index="i">
        <cfif i lte listLen(local.enclosure.length) and i lte listLen(local.enclosure.type)>
				<enclosure url="#URLFormat(listGetAt(local.enclosure.url,i))#" length="#RSSFormat(listGetAt(local.enclosure.length,i))#" type="#RSSFormat(listGetAt(local.enclosure.type,i))#"/>
        </cfif>
      	</cfloop>
			</cfif>
		</item>
		</cfoutput>
		</cfsavecontent>

		<cfreturn itemsXML>
	</cffunction>

	<!--- verifyFeed --->
	<cffunction name="verifyFeed" output="false" access="private" returntype="void" hint="Verify the feed structure and append auto-generated properties.">
		<!--- ******************************************************************************** --->
		<cfargument name="feedStruct" type="struct" required="true" hint="The feed structure"/>
    <cfargument name="ColumnMap" 	type="struct" default="#structNew()#" hint="The column mapper to use for the items query."/>
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
			var validStruct = structNew();
			
			/* Verify Mandatory Properties */	
			for( i=1; i lte listLen(instance.reqItems); i=i+1 ){
				if( not listFindNoCase( fsKeys, listGetAt(instance.reqItems,i) ) ){
					invalidItems = listAppend(invalidItems,listGetAt(instance.reqItems,i));
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
			
			/* Verify Properties Values */
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
				for( i=1; i lte listLen(fs.commonslicense); i=i+1 ){
					if ( not validatecommonslicense(listGetAt(fs.commonslicense,i)) ) {
						invalidList = invalidList & "| The #generateNumSuffix(i)# commonslicense element '#listGetAt(fs.commonslicense,i)#' : Is not an valid URL pointing to a Creative Commons license (See <a href='http://creativecommons.org/about/licenses/meet-the-licenses'>http://creativecommons.org/about/licenses/meet-the-licenses</a>)";
					}
				}									 						 
			}
			/* cloud */
			if( structKeyExists(fs, "cloud") and ( not isStruct(fs.cloud) or not structKeyExists(fs.cloud,'domain') or not structKeyExists(fs.cloud,'path') or not structKeyExists(fs.cloud,'port') or not structKeyExists(fs.cloud,'protocol') or not structKeyExists(fs.cloud,'registerProcedure')) ){
					invalidList = invalidList & "| The cloud element must be a structure containing the elements: domain,path,port protocol,registerProcedure (See <a href='#instance.SpecRssEC#cloud'>#instance.SpecRssEC#cloud</a>)";
			}	
			if( structKeyExists(fs, "cloud") and structKeyExists(fs.cloud,"port") and not validateNNInteger(fs.cloud.port) ){
				invalidList = invalidList & "| The cloud attribute port '#fs.cloud.port#' : Must be a whole number, 0 or greater (See <a href='#instance.SpecRssEC#cloud'>#instance.SpecRssEC#cloud</a>)";
			}
			if( structKeyExists(fs, "cloud") and structKeyExists(fs.cloud,"protocol") and not listFindNoCase(instance.valClPro,fs.cloud.protocol) ){
				invalidList = invalidList & "| The cloud attribute protocol '#fs.cloud.protocol#' : Must be either #instance.valClPro# (See <a href='#instance.SpecRssEC#cloud'>#instance.SpecRssEC#cloud</a>)";
			}
			/* dcmi terms */
			if( structKeyExists(fs,"dcmiterm") and isStruct(fs.dcmiterm) ) {
				for( i=1; i lte structCount(fs.dcmiterm); i=i+1 ){
					container_a = listGetAt(structKeyList(fs.dcmiterm),i);
					if( not listFindNoCase(instance.DCMITerms,container_a) ) {
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
						if( not listFindNoCase(instance.valImgs,listLast(fs.image.url,'.')) ){
							invalidList = invalidList & "| The image url element '#fs.image.url#' : Is not a valid image format, only #instance.valImgs# (PNG, GIF or JPEG) allowed (See <a href='#instance.SpecRssEC#image-url'>#instance.SpecRssEC#image-url</a>)";
						}
					}
					if( structKeyExists(fs.image,"link") and not validateURI(fs.image.link) ){
						invalidList = invalidList & "| The image link element '#fs.image.link#' : Is not a valid URI (See <a href='#instance.SpecRssEC#image-link'>#instance.SpecRssEC#image-link</a>)";
					}
					if( structKeyExists(fs.image,"height") and (not isNumeric(fs.image.height) or fs.image.height lt 0 or fs.image.height gt instance.valImgsMH) ){
						invalidList = invalidList & "| The image height element '#fs.image.height#' : Must be a number between 0 and #instance.valImgsMH# (See <a href='#instance.SpecRssEC#image-height'>#instance.SpecRssEC#image-height</a>)";
					}
					if( structKeyExists(fs.image,"width") and (not isNumeric(fs.image.width) or fs.image.width lt 0 or fs.image.width gt instance.valImgsMW) ){
						invalidList = invalidList & "| The image width element '#fs.image.height#' : Must be a number between 0 and #instance.valImgsMW# (See <a href='#instance.SpecRssEC#image-width'>#instance.SpecRssEC#image-width</a>)";
					}
				}
			}
			/* itunes */
			if( structKeyExists(fs,"itunes") ) {
				/* itunes category */
				if( structKeyExists(fs.itunes,"category") and isStruct(fs.itunes.category) ) {
					for(i=1; i lte structCount(fs.itunes.category); i=i+1){
						container_a = listGetAt(structKeyList(fs.itunes.category),i);
						if( not listFindNoCase(structKeyList(instance.ItunesCategories),container_a) ) {
							invalidList = invalidList & "| The iTunes category element containing '#container_a#' : Is not a valid iTunes category (See <a href='#instance.SpecApple#categories'>#instance.SpecApple#categories</a>)";
						}
						else if( not len(instance.ItunesCategories[container_a]) and len(fs.itunes.category[container_a]) ) {
							invalidList = invalidList & "| The iTunes category element containing '#container_a#' : Should not have any subcategories, you listed '#fs.itunes.category[container_a]#' (See <a href='#instance.SpecApple#categories'>#instance.SpecApple#categories</a>)";
						}
						else if( len(instance.ItunesCategories[container_a]) and not len(fs.itunes.category[container_a]) ) {
							invalidList = invalidList & "| The iTunes category element containing '#container_a#' : Needs at least one subcategory '#instance.ItunesCategories[container_a]#' (See <a href='#instance.SpecApple#categories'>#instance.SpecApple#categories</a>)";
						}
						else if( len(fs.itunes.category[container_a]) ) {
							for(j=1; j lte listLen(fs.itunes.category[container_a]); j=j+1){
								if( not listFindNoCase(instance.ItunesCategories[container_a],'#trim(listGetAt(fs.itunes.category[container_a],j))#') ) {
									container_b = listAppend(container_b,trim(listGetAt(fs.itunes.category[container_a],j)));
								}
							}
							if( listLen(container_b) ) {
								container_b = replaceNoCase(container_b,', ',',','all');
								invalidList = invalidList & "| The iTunes category element containing '#container_a#' : Contains the following invalid subcategories '#container_b#' (See <a href='#instance.SpecApple#categories'>#instance.SpecApple#categories</a>)";
							}
						}
					}
				}
				else if( structKeyExists(fs.itunes,"category") and not isStruct(fs.itunes.category) ) {
					invalidList = invalidList & "| The iTunes category element must be a structure container '##structNew()##' : It can not be a text string";
				}
				/* itunes explicit */
				if( structKeyExists(fs.itunes,"explicit") and not yesNoFormat(reFindNoCase('^(#Replace(instance.valITExp,',','|','all')#)$',fs.itunes.explicit))){
					invalidList = invalidList & "| The iTunes explicit element '#fs.itunes.explicit#' : Is not a valid value, only #instance.valITExp# are allowed (See <a href='#instance.SpecApple#explicit'>#instance.SpecApple#explicit</a>)";
				}
				/* itunes image */
				if( structKeyExists(fs.itunes,"image")) {
					if(not validateURL(fs.itunes.image)){
						invalidList = invalidList & "| The iTunes image url element '#fs.itunes.image#' : Is not a valid URL (See <a href='#instance.SpecApple#image'>#instance.SpecApple#image</a>)";
					}
					if(not listFindNoCase(instance.valITImg,listLast(fs.itunes.image,'.'))){
						invalidList = invalidList & "| The iTunes image url element '#fs.itunes.image#' : Is not a valid image format, only #instance.valITImg# are allowed (See <a href='#instance.SpecApple#image'>#instance.SpecApple#image</a>)";
					}
				}
				/* itunes keywords */
				if( structKeyExists(fs.itunes,"keywords") ) {
					if( listLen(fs.itunes.keywords) gt instance.valITkey ) {
						invalidList = invalidList & "| The iTunes keywords element '#fs.itunes.keywords#' : Can only contain a maximum of #instance.valITkey# items, you have #listLen(fs.itunes.keywords)# (See <a href='#instance.SpecApple#keywords'>#instance.SpecApple#keywords</a>)";
					}
					if( find(',,',fs.itunes.keywords) ) {
						invalidList = invalidList & "| The iTunes keywords element '#fs.itunes.keywords#' : Is formatted incorrectly, please remove the cojoined commas (See <a href='#instance.SpecApple#keywords'>#instance.SpecApple#keywords</a>)";
					}
				}
				/* itunes new feed url */
				if( structKeyExists(fs.itunes,"new_feed_url") and not validateURL(fs.itunes.new_feed_url)){
					invalidList = invalidList & "| The iTunes new-feed-url element '#fs.itunes.new_feed_url#' : Is not a valid URL (See <a href='#instance.SpecApple#newfeed'>#instance.SpecApple#newfeed</a>)";
				}
				/* itunes summary */
				if( structKeyExists(fs.itunes,"summary") and (len(fs.itunes.summary) gt instance.valITSum)){
					invalidList = invalidList & "| The iTunes summary element : Can only contain a maximum of #instance.valITSum# characters, you have #len(fs.itunes.summary)# (See <a href='#instance.SpecApple#summary'>#instance.SpecApple#summary</a>)";
				}
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
				/* opensearch autodiscovery */
				if( structKeyExists(fs.opensearch,"autodiscovery") and not validateURL(fs.opensearch.autodiscovery) ) {
					invalidList = invalidList & "| The OpenSearch search-link element (autodiscovery) '#fs.opensearch.autodiscovery#' : Is not a valid URL (See <a href='#instance.SpecOS#Autodiscovery_in_RSS.2FAtom'>#instance.SpecOS#Autodiscovery_in_RSS.2FAtom</a>)";
				}
				/* opensearch query */
				if( structKeyExists(fs,"opensearchQuery") and isArray(fs.opensearchQuery) ) {
					for( i=1; i lte arrayLen(fs.opensearchQuery); i=i+1 ){
						if( structKeyExists(fs.opensearchQuery[i],"role") and not listFindNoCase(instance.valOSRol,fs.opensearchQuery[i].role) ) {
							invalidList = invalidList & "| The #generateNumSuffix(i)# opensearchQuery role attribute '#fs.opensearchQuery[i].role#' : Can only be one of these values #instance.valOSRol# (See <a href='#instance.SpecOS#Local_role_values'>#instance.SpecOS#Local_role_values</a>)";
						}
						if( structKeyExists(fs.opensearchQuery[i],"title") and len(RSSFormat(fs.opensearchQuery[i].title)) gt instance.valOSTit ) {
							invalidList = invalidList & "| The #generateNumSuffix(i)# opensearchQuery title attribute is too long : Can only contain a maximum of #instance.valOSTit# characters, you have #len(RSSFormat(fs.opensearchQuery[i].title))# (See <a href='#instance.SpecOS#The_.22Query.22_element_2'>#instance.SpecOS#The_.22Query.22_element_2</a>)";
						}
						if( structKeyExists(fs.opensearchQuery[i],"totalResults") and not validateNNInteger(fs.opensearchQuery[i].totalResults) ) {
							invalidList = invalidList & "| The #generateNumSuffix(i)# opensearchQuery totalResults attribute '#fs.opensearchQuery[i].totalResults#' : Must be a whole number, 0 or greater (See <a href='#instance.SpecOS#The_.22Query.22_element_2'>#instance.SpecOS#The_.22Query.22_element_2</a>)";
						}
						if( structKeyExists(fs.opensearchQuery[i],"count") and not validateNNInteger(fs.opensearchQuery[i].count) ) {
							invalidList = invalidList & "| The #generateNumSuffix(i)# opensearchQuery count attribute '#fs.opensearchQuery[i].count#' : Must be a whole number, 0 or greater (See <a href='#instance.SpecOS#The_.22Query.22_element_2'>#instance.SpecOS#The_.22Query.22_element_2</a>)";
						}
						if( structKeyExists(fs.opensearchQuery[i],"startIndex") and not isNumeric(fs.opensearchQuery[i].startIndex) ) {
							invalidList = invalidList & "| The #generateNumSuffix(i)# opensearchQuery startIndex attribute '#fs.opensearchQuery[i].startIndex#' : Must be a number (See <a href='#instance.SpecOS#The_.22Query.22_element_2'>#instance.SpecOS#The_.22Query.22_element_2</a>)";
						}
						if( structKeyExists(fs.opensearchQuery[i],"startPage") and not isNumeric(fs.opensearchQuery[i].startPage) ) {
							invalidList = invalidList & "| The #generateNumSuffix(i)# opensearchQuery startPage attribute '#fs.opensearchQuery[i].startPage#' : Must be a number (See <a href='#instance.SpecOS#The_.22Query.22_element_2'>#instance.SpecOS#The_.22Query.22_element_2</a>)";
						}
						if( structKeyExists(fs.opensearchQuery[i],"language") and not validateRFC3066(fs.opensearchQuery[i].language) ) {
							invalidList = invalidList & "| The #generateNumSuffix(i)# opensearchQuery language attribute '#fs.opensearchQuery[i].language#' : Must be a valid XML language id, such as en,en-uk (See <a href='#instance.SpecOS#The_.22Query.22_element_2'>#instance.SpecOS#The_.22Query.22_element_2</a>)";
						}
					}
				}
				
				/* opensearch itemsperpage */
				if( structKeyExists(fs.opensearch,"itemsperpage") and not validateNNInteger(fs.opensearch.itemsperpage)){
					invalidList = invalidList & "| The OpenSearch itemsperpage element '#fs.opensearch.itemsperpage#' : Must be a whole number, 0 or greater (See <a href='#instance.SpecOS#The_.22itemsPerPage.22_element'>#instance.SpecOS#The_.22itemsPerPage.22_element</a>)";
				}
				/* opensearch startindex */
				if( structKeyExists(fs.opensearch,"startindex") and not validateNNInteger(fs.opensearch.startindex)){
					invalidList = invalidList & "| The OpenSearch startindex element '#fs.opensearch.startindex#' : Must be a whole number, 0 or greater (See <a href='#instance.SpecOS#The_.22startIndex.22_element'>#instance.SpecOS#The_.22startIndex.22_element</a>)";
				}
				/* opensearch totalresults */
				if( structKeyExists(fs.opensearch,"totalresults") and not validateNNInteger(fs.opensearch.totalresults)){
					invalidList = invalidList & "| The OpenSearch totalresults element '#fs.opensearch.totalresults#' : Must be a number (See <a href='#instance.SpecOS#The_.22totalResults.22_element'>#instance.SpecOS#The_.22totalResults.22_element</a>)";
				}
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

			/* Append Auto-generated */
			/* generator */
			fs["generator"] = "#getPluginName()# - #GetPluginVersion()#";
			/* docs */
			fs["docs"] = instance.SpecRss;

			/* Items isQuery Validation */
			if( IsDefined("fs.items") ) {
				if( not isQuery(fs.items) ){
					invalidList = invalidList & "| The items element must be a valid query.";
				}
				else {
					invalidList = verifyItems(fs.items,cs,invalidList);
				}
			}
			
			/* Display All Debug/Validation Errors */
			if(len(invalidList)) {
				invalidFeedLL = listLen(invalidList,'|');
				for(i=1;i lte invalidFeedLL;i=i+1) {
					// replace '|' placeholder with the HTML new line tag and error count
					invalidDsp = invalidDsp & "<br />#i#. " & listGetAt(invalidList,1,'|');
					invalidList = ListDeleteAt(invalidList,1,'|');
				}
				// display the error messages
				throw("The generated RSS feed has some problems",invalidDsp,"ColdBox.feedGenerator.InvalidFeedStructure");
			}
		</cfscript>
	</cffunction>
  
	<!--- verifyItems --->
	<cffunction name="verifyItems" output="false" access="private" returntype="string" hint="Verify the feed item data and structure.">
		<!--- ******************************************************************************** --->
		<cfargument name="feedItems" type="query" required="true" hint="The feed items"/>
    <cfargument name="ColumnMap" 	type="struct" default="#structNew()#" hint="The column mapper to use for the items query."/>
    <cfargument name="invalidList" type="string" required="true" hint="Existing collection of debug/validation errors"/>
		<!--- ******************************************************************************** --->
    <cfscript>
				var caught = "";
				var cs = arguments.ColumnMap;
				var fi = arguments.feedItems;
				var i = 0;
				var map = getDefaultPropertyMap();
				invalidList = arguments.invalidList;
				
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
					invalidList = invalidList & "| Item #fi.currentrow# : The Atom self-link element '#fi[map.atomSelfLink][currentrow]#' : Is not a valid URL (See <a href='#instance.SpecRssNS#atom-link'>#instance.SpecRssNS#atom-link</a>)";
				}
				/* category */
				if( structKeyExists(fi,"#map.category_domain#") and len(fi[map.category_domain][currentrow]) ) {
						for(i=1; i lte listLen(fi[map.category_domain][currentrow]); i=i+1){
							if( ( not listGetAt(fi[map.category_domain][currentrow],i) is "-" ) and ( not structKeyExists(fi,"#map.category_tag#") or listLen(fi[map.category_domain][currentrow]) lt i or listGetAt(fi[map.category_domain][currentrow],i) is "-" ) ) {
								invalidList = invalidList & "| Item #fi.currentrow# : The #generateNumSuffix(i)# category domain attribute '#listGetAt(fi[map.category_tag][currentrow],i)#' : Requires a category tag element that cannot be left blank (See <a href='#instance.SpecRssEC#category'>#instance.SpecRssEC#category</a>)";
							}
						}
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
						invalidList = invalidList & "| Item #fi.currentrow# : The #generateNumSuffix(i)# enclosure element : Is missing the length attribute, it cannot be left blank (See <a href='#instance.SpecRssEC#item-enclosure'>#instance.SpecRssEC#item-enclosure</a>)";
						}
						else if ( not validateNNInteger(listGetAt(fi[map.enclosure_length][currentrow],i)) ) {
						invalidList = invalidList & "| Item #fi.currentrow# : The #generateNumSuffix(i)# enclosure attribute length '#listGetAt(fi[map.enclosure_length][currentrow],i)#' : Must be a whole number, 0 or greater (See <a href='#instance.SpecRssEC#item-enclosure'>#instance.SpecRssEC#item-enclosure</a>)";
						}
						// type attribute
						if( i gt listLen(fi[map.enclosure_type][currentrow]) or not len(fi.enclosure_type) ) {
						invalidList = invalidList & "| Item #fi.currentrow# : The #generateNumSuffix(i)# enclosure element : Is missing the type attribute, it cannot be left blank (See <a href='#instance.SpecRssEC#item-enclosure'>#instance.SpecRssEC#item-enclosure</a>)";
						}
						// url attribute
						if( not len(fi[map.enclosure_url][currentrow]) ) {
						invalidList = invalidList & "| Item #fi.currentrow# : The #generateNumSuffix(i)# enclosure element : Is missing the url attribute, it cannot be left blank (See <a href='#instance.SpecRssEC#item-enclosure'>#instance.SpecRssEC#item-enclosure</a>)";
						}
						else if ( not validateURL(listGetAt(fi[map.enclosure_url][currentrow],i)) ) {
						invalidList = invalidList & "| Item #fi.currentrow# : The #generateNumSuffix(i)# enclosure attribute url '#listGetAt(fi[map.enclosure_url][currentrow],i)#' : Is not a valid URL (See <a href='#instance.SpecRssEC#item-enclosure'>#instance.SpecRssEC#item-enclosure</a>)";
						}
					}
				}
				/* guid & permaLink */
				if( structKeyExists(fi,"#map.guid_string#") and len(fi[map.guid_string][currentrow]) ){
					// guid_permaLink value
					if( structKeyExists(fi,"#map.guid_permaLink#") and len(fi.guid_permaLink) and not reFindNoCase('^(true|false)$',fi.guid_permaLink) ) {
						invalidList = invalidList & "| Item #fi.currentrow# : The isPermaLink attribute '#fi[map.guid_permaLink][currentrow]#' of the guid element : Is an invalid value, it can only be true,false (See <a href='#instance.SpecRssEC#item-guid'>#instance.SpecRssEC#item-guid</a>)";
					}
					// guid value when guid_permaLink is true
					else if ( ( not structKeyExists(fi,"#map.guid_permaLink#") or not len(fi[map.guid_permaLink][currentrow]) or fi[map.guid_permaLink][currentrow] ) and not validateURL(fi[map.guid_string][currentrow]) ) {
						invalidList = invalidList & "| Item #fi.currentrow# : The guid element '#fi[map.guid_string][currentrow]#' : Is not a valid URL which is a requirement when isPermaLink attribute is ignored or 'true' (See <a href='#instance.SpecRssEC#item-guid'>#instance.SpecRssEC#item-guid</a>)";
					} 
				}
				/* itunes duration */
				if( structKeyExists(fi,"#map.itunes_duration#") and len(fi[map.itunes_duration][currentrow]) and not validateItunesDuration(fi[map.itunes_duration][currentrow]) ) {
					invalidList = invalidList & "| Item #fi.currentrow# : The iTunes duration element '#fi[map.itunes_duration][currentrow]#' : Is not a valid time, only HH:MM:SS,H:MM:SS,MM:SS,M:SS are allowed (See <a href='#instance.SpecApple#duration'>#instance.SpecApple#duration</a>)";
				}
				/* itunes explicit */
				if( structKeyExists(fi,"#map.itunes_explicit#") and len(fi[map.itunes_explicit][currentrow]) and not yesNoFormat(reFindNoCase('^(#Replace(instance.valITExp,',','|','all')#)$',fi[map.itunes_explicit][currentrow])) ){
					invalidList = invalidList & "| Item #fi.currentrow# : The iTunes explicit element '#fi[map.itunes_explicit][currentrow]#' : Is not a valid value, only #instance.valITExp# are allowed (See <a href='#instance.SpecApple#explicit'>#instance.SpecApple#explicit</a>)";
				}
				/* itunes keywords */
				if( structKeyExists(fi,"#map.itunes_keywords#") and len(fi[map.itunes_keywords][currentrow]) ){
					if( listLen(fi[map.itunes_keywords][currentrow]) gt instance.valITkey ) {
						invalidList = invalidList & "| Item #fi.currentrow# : The iTunes keywords element '#fi[map.itunes_keywords][currentrow]#' : Can only contain a maximum of #instance.valITkey# items, you have #listLen(fi[map.itunes_keywords][currentrow])# (See <a href='#instance.SpecApple#keywords'>#instance.SpecApple#keywords</a>)";
					}
					if( find(',,',fi.itunes_keywords) ) {
						invalidList = invalidList & "| Item #fi.currentrow# : The iTunes keywords element '#fi[map.itunes_keywords][currentrow]#' : Is formatted incorrectly, please remove the cojoined commas (See <a href='#instance.SpecApple#keywords'>#instance.SpecApple#keywords</a>)";
					}
				}
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
				/* slash comments */
				if ( structKeyExists(fi,"#map.slash_comments#") and len(fi[map.slash_comments][currentrow]) and not validateNNInteger(fi[map.slash_comments][currentrow]) ) {
					invalidList = invalidList & "| Item #fi.currentrow# : The slash_comments value '#fi[map.slash_comments][currentrow]#' : Must be a whole number, 0 or greater (See <a href='#instance.SpecSlash#'>#instance.SpecSlash#</a>)";
				}
				/* slash hit_parade */
				if ( structKeyExists(fi,"#map.slash_hit_parade#") and len(fi[map.slash_hit_parade][currentrow]) ) {
					if ( reFindNoCase('(^0-9\,)+', fi[map.slash_hit_parade][currentrow]) or listLen(fi[map.slash_hit_parade][currentrow]) neq 7 ) {
						invalidList = invalidList & "| Item #fi.currentrow# : The slash_comments value '#fi[map.slash_hit_parade][currentrow]#' : Must be a list of 7 numbers, 0 or greater (See <a href='#instance.SpecSlash#'>#instance.SpecSlash#</a>)";
					}
					if ( find(',,',fi.slash_hit_parade) ) {
						invalidList = invalidList & "| Item #fi.currentrow# : The slash_comments value '#fi[map.slash_hit_parade][currentrow]#' : Is formatted incorrectly, please remove the cojoined commas (See <a href='#instance.SpecSlash#'>#instance.SpecSlash#</a>)";
					}
				}
				/* source */
				if( ( not structKeyExists(fi,"#map.source_url#") or not len(fi[map.source_url][currentrow]) ) and structKeyExists(fi,"#map.source_title#") and len(fi[map.source_title][currentrow]) ) {
					invalidList = invalidList & "| Item #fi.currentrow# : The source element (source_title) '#fi[map.source_title][currentrow]#' : Requires a URL attribute (source_url) (See <a href='#instance.SpecRssEC#item-source'>#instance.SpecRssEC#item-source</a>)";
				}
				else if( structKeyExists(fi,"#map.source_url#") and len(fi[map.source_url][currentrow]) and not validateURL(fi[map.source_url][currentrow]) ){
					invalidList = invalidList & "| Item #fi.currentrow# : The URL attribute '#fi[map.source_url][currentrow]#' in the source element : Is not a valid URL (See <a href='#instance.SpecRssEC#item-source'>#instance.SpecRssEC#item-source</a>)";
				}
      </cfscript>
    </cfloop>

    <cfreturn arguments.invalidList>

  </cffunction>
	

<!---------------------------------------- ACCESSOR/MUTATORS --------------------------------------------------->
	
	<!--- parseColumnMap --->
	<cffunction name="parseColumnMap" output="false" access="public" returntype="struct" hint="Parse and validate a column mapper">
		<!--- ******************************************************************************** --->
		<cfargument name="columnMap" type="struct" required="true" hint="The column map to parse"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var map = getDefaultPropertyMap();
			var cmap = arguments.columnMap;
			var key = "";
			
			/* start parsing */
			for(key in map){
				if( structKeyExists(cmap,key) ){
					map[key] = cmap[key];
				}	
			}			
			
			return map;
		</cfscript>
	</cffunction>
	
	<!--- getDefaultPropertyMap --->
	<cffunction name="getDefaultPropertyMap" output="false" access="public" returntype="struct" hint="Get the default property map">
		<cfscript>
			var i = 0;
			var map = structnew();
			map.atomselfLink = "atomselfLink";
			map.author = "author";
			map.category_domain = "category_domain";
			map.category_tag = "category_tag";
			map.comments = "comments";
			map.commonslicense = "commonslicense";
			map.content_encoded = "content_encoded";
			map.description = "description";
			map.enclosure_url = "enclosure_url";
			map.enclosure_length = "enclosure_length";
			map.enclosure_type = "enclosure_type";
			map.guid_string = "guid_string";
			map.guid_permalink = "guid_permalink";
			map.itunes_author = "itunes_author";
			map.itunes_block = "itunes_block";
			map.itunes_duration = "itunes_duration";
			map.itunes_explicit = "itunes_explicit";
			map.itunes_keywords = "itunes_keywords";
			map.itunes_subtitle = "itunes_subtitle";
			map.itunes_summary = "itunes_summary";
			map.link = "link";
			map.pubdate = "pubdate";
			map.slash_comments = "slash_comments";
			map.slash_department = "slash_department";
			map.slash_hit_parade = "slash_hit_parade";
			map.slash_section = "slash_section";
			map.source_title = "source_title";
			map.source_url = "source_url";
			map.title = "title";
			/* Generate DCMI Terms defaults from instance.DCMITerms */
			for(i=1; i lte listLen(instance.DCMITerms); i=i+1){
				StructInsert(map, Ucase("dcmiterm_#listGetAt(instance.DCMITerms,i)#"), "dcmiterm_#listGetAt(instance.DCMITerms,i)#");
			}
			/* Return map */
			return map;
		</cfscript>
	</cffunction>

<!---------------------------------------- PRIVATE --------------------------------------------------->

  <!--- generateNameSpace --->
	<cffunction name="generateNameSpace" output="false" access="private" returntype="string" hint="Generates the tag namespaces depending on the tags in use">
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
			/* Creative Commons namespace */
			if( listFindNoCase(keys,'commonslicense') ) {
				nameSpace = nameSpace & ' xmlns:creativeCommons="http://backend.userland.com/creativeCommonsRssModule"';
			}
			/* DCMI Metadata Terms namespace */
			if( listContainsNoCase(keys,'dcmiterm') ) {
				nameSpace = nameSpace & ' xmlns:dc="http://purl.org/dc/elements/1.1/"';
			}
			/* iTunes namespace */
			if( listContainsNoCase(keys,'itunes') ) {
				nameSpace = nameSpace & ' xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"';
			}
			/* OpenSearch namespace */
			if( listContainsNoCase(keys,'opensearch') ) {
				nameSpace = nameSpace & ' xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/"';
			}
			/* Slash comments namespace */
			if( listContainsNoCase(keys,'slash') ) {
				nameSpace = nameSpace & ' xmlns:slash="http://purl.org/rss/1.0/modules/slash/"';
			}
			return nameSpace;
		</cfscript>
  </cffunction>
  
  <!--- generateNumSuffix --->
  <cffunction name="generateNumSuffix" output="false" access="private" returntype="string" hint="Attaches an English oral suffix (st,nd,rd,th) to a number">
    <cfargument name="number" required="yes" type="numeric" hint="Integer">
    <cfargument name="seperator" default="," type="string" hint="Seperator character">
    <cfscript>
      var suffix = '';
      var value = '';
      /* convert number to use an oral suffix */
      value = Right(arguments.number,1);
      if((value gte 4 and value lte 9) or value eq 0 or (arguments.number gte 11 and arguments.number lte 13)) {
        suffix = 'th'; // numbers ending with 4,5,6,7,8,9 and numbers that equal to 11,12,13
      }
      else if(value eq 1) {
        suffix = 'st'; // numbers ending with 1 except number 11
      }
      else if(value eq 2) {
        suffix = 'nd'; // numbers ending with 2 except number 12
      }
      else if(value eq 3) {
        suffix = 'rd'; // numbers ending with 3 except number 13
      }
      return generateNum1kSeparator(arguments.number,arguments.seperator) & suffix;
    </cfscript>
  </cffunction>
  
  <!--- generateNum1kSeparator --->
  <cffunction name="generateNum1kSeparator" output="false" access="private" returntype="string" hint="Inserts thousand-seperators into a number">
    <cfargument name="number" required="yes" type="numeric" hint="Integer">
    <cfargument name="seperator" default="," type="string" hint="Seperator character">
    <cfscript>
      var decimal = '';
      var integer = '';
      var returnString = '';
      /* convert number to insert commas */
      decimal = listLast(arguments.number,'.');
      integer = listFirst(arguments.number,'.');
      if(decimal eq integer) { decimal = 0; }
      integer = reReplace(Reverse(integer), "([0-9][0-9][0-9])", "\1#arguments.seperator#");
      integer = reReplace(integer, "#arguments.seperator#$", "");
      integer = reReplace(integer, "#arguments.seperator#([^0-9]+)", "\1");
      if(len(decimal) and decimal neq 0) {
				returnString = Reverse(integer) & '.' & decimal;
      }
      else {
        returnString = Reverse(integer);
      }
      return returnString;
    </cfscript>
  </cffunction>

	<!--- generateRFC822Date --->
	<cffunction name="generateRFC822Date" output="false" access="private" returntype="string" hint="Generate an RFC8222 Date from a date object. Conformed to GMT">
		<cfargument name="targetDate" type="string" required="true" hint="The target Date. Must be a valid date."/>
		<cfscript>
			var TZ=getTimeZoneInfo();
			var GDT = "";
			var GMTDt = "";
			var GMTTm = "";
			/* Validate we have a real date to work with */
			if( not isDate(arguments.targetDate) ){
				throw("The date sent in for parsing is not valid","TargetDate: #arguments.targetDate#","ColdBox.feedGenerator.InvalidDate");
			}
			/* Calculate with offset the GMT DateTime Object */
			GDT = dateAdd('s',TZ.utcTotalOffset,arguments.targetDate);
			/* Get Date Part */
			GMTDt=dateFormat(GDT,'ddd, dd mmm yyyy');
			/* Get Time Part */
			GMTTm=timeFormat(GDT,'HH:mm:ss');
			
			/* Return with GMT */
			return "#GMTDt# #GMTTm# GMT";
		</cfscript>		
	</cffunction>
  
  <!--- Element Validation --->
  
	<cffunction name="validatecommonslicense" output="false" access="private" returntype="boolean" hint="Validate targetString object as a URL pointing to the Creative Commons website">
		<cfargument name="targetString">
    <cfscript>
			var result = yesNoFormat(reFindNoCase('^http://(www\.)?creativecommons.org/licenses/[\w]+',arguments.targetString));
			return result;
		</cfscript>
	</cffunction>
  
  <cffunction name="validateDaysList" output="false" access="private" returntype="struct" hint="Validate list object against the RSS skipDays element requirements">
		<cfargument name="targetList" type="string" required="true" hint="The target List."/>
    <cfscript>
			var daysAllowed = instance.valSkipD;
			var i = 1;
			var iStr = "";
			var result = structNew();
			var sDays = arguments.targetList;
			result["DupeValues"] = "";
			result["InvalidValues"] = "";
			/* Trim whitespace from list values */
			for( i=1; i lte listLen(sDays); i=i+1 ){
				sDays = listSetAt(sDays,i,Trim(listGetAt(sDays,i)));
			}
			/* Loop through list */
			for( i=1; i lte listLen(sDays); i=i+1 ){
				iStr = Trim(listGetAt(sDays,i));
				/* Discover list items that are not numeric or that are numbers less then 0 or greater then 24 */
				if( listFindNoCase(daysAllowed,iStr) is 0 ) {
					result["InvalidValues"] = listAppend(result.InvalidValues,iStr);
				}
				/* Discover list items that already exist in the list */
				if( listValueCount(lCase(sDays),lCase(iStr)) gt 1 ) {
					result["DupeValues"] = listAppend(result.DupeValues,iStr);
				}
			}
			return result;
		</cfscript>
	</cffunction>
  
  <cffunction name="validateHoursList" output="false" access="private" returntype="struct" hint="Validate list object against the RSS skipHours element requirements">
		<cfargument name="targetList" type="string" required="true" hint="The target List."/>
    <cfscript>
			var result = structNew();
			var sHours = arguments.targetList;
			var i = 1;
			var iStr = "";
			result["DupeValues"] = "";
			result["InvalidValues"] = "";
			/* Trim whitespace from list values */
			for(i=1; i lte listLen(sHours); i=i+1){
				sHours = listSetAt(sHours,i,Trim(listGetAt(sHours,i)));
			}
			/* Loop through list */
			for(i=1; i lte listLen(sHours); i=i+1){
				iStr = Trim(listGetAt(sHours,i));
				/* Discover list items that are not numeric or that are numbers less then 0 or greater then 24 */
				if(not isNumeric(iStr) or iStr lt 0 or iStr gt 24) {
					result["InvalidValues"] = listAppend(result.InvalidValues,iStr);
				}
				/* Discover list items that already exist in the list */
				if(listValueCount(lCase(sHours),lCase(iStr)) gt 1) {
					result["DupeValues"] = listAppend(result.DupeValues,iStr);
				}
			}
			return result;
		</cfscript>
	</cffunction>
  
	<cffunction name="validateItunesDuration" output="false" access="private" returntype="boolean" hint="Force iTunes duration formatting">
		<cfargument name="targetTime" type="string" required="true" hint="The target duration Time."/>
    <cfscript>
			var result = yesNoFormat(reFind('^\d?\d?:?\d?\d:\d\d$',arguments.targetTime));
			return result;
		</cfscript>
	</cffunction>
  
  <cffunction name="validatePerson" output="false" access="private" returntype="boolean" hint="Validate string object against the RSS person scheme containing an e-mail and an optional name">
		<cfargument name="targetString" type="string" required="true" hint="The target String."/>
    <cfscript>
			var result = yesNoFormat(reFind('^(\w+\.)*\w+@((((\d{1,2})|(1\d{2})|(2[0-4]\d)|(25[0-5]))\.){3}((\d{1,2})|(1\d{2})|(2[0-4]\d)|(25[0-5]))|(\w+\.)+[A-Za-z]+)( \(.*\))?$', arguments.targetString));
			return result;
		</cfscript>
	</cffunction>

  <cffunction name="validateNNInteger" output="false" access="private" returntype="boolean" hint="Validate number object as a non-negative integer (0,1,2,3..)">
		<cfargument name="targetInt" type="string" required="true" hint="The target Integer."/>
    <cfscript>
			var result = yesNoFormat(reFind('^\d+$',arguments.targetInt));
			return result;
		</cfscript>
	</cffunction>
  
  <cffunction name="validateRFC822Date" output="false" access="private" returntype="boolean" hint="Validate date object against RFC822 'Date and Time Specification'">
  	<cfargument name="targetDate" type="string" required="true" hint="The target Date."/>
		<cfscript>
			var result = yesNoFormat(reFindNoCase('^(Sun|Mon|Tue|Wed|Thu|Fri|Sat)\, [0-3]\d (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) ([1-2][9|0])?\d\d [0-2]\d:[0-5]\d:[0-5]\d (GMT|UT)', arguments.targetDate));
			return result;
		</cfscript>
	</cffunction>
  
	<cffunction name="validateRFC1766" output="false" access="private" returntype="boolean" hint="Validate string object against RFC1766 'Tags for the Identification of Languages'">
		<cfargument name="targetString" type="string" required="true" hint="The target String."/>
		<cfscript>
			var result = yesNoFormat(reFindNoCase('^[a-z]*[a-z][a-z](-[a-z][a-z]*)?$', arguments.targetString));
			return result;
		</cfscript>
	</cffunction>
  
	<cffunction name="validateRFC3066" output="false" access="private" returntype="boolean" hint="RFC3066 'Tags for the Identification of Languages'">
		<cfargument name="targetString" type="string" required="true" hint="The target String."/>
    <cfscript>
			var result = yesNoFormat(REFindNoCase('^([a-z]{2}([a-z]{1,6})?|i|x)(-[:alnum:]{1,8})?', arguments.targetString));
			return result;
		</cfscript>
	</cffunction>
  
	<cffunction name="validateURI" output="false" access="private" returntype="boolean" hint="Validate string object against a HTTP or HTTPS, FTP, news, mailto URI">
		<cfargument name="targetString" type="string" required="true" hint="The target String."/>
		<cfscript>
			var result = yesNoFormat(0);
			if(reFindNoCase('^(https?|ftp|news)://[-\w.]+(:\d+)?(/([\w/_.]*)?)?', arguments.targetString) GT 0 OR reFind('^mailto:(\w+\.)*\w+@((((\d{1,2})|(1\d{2})|(2[0-4]\d)|(25[0-5]))\.){3}((\d{1,2})|(1\d{2})|(2[0-4]\d)|(25[0-5]))|(\w+\.)+[A-Za-z]+)( \(.*\))?$', arguments.targetString) GT 0) {
				result = yesNoFormat(1);
			}
			return result;
		</cfscript>
	</cffunction>
  
	<cffunction name="validateURL" output="false" access="private" returntype="boolean" hint="Validate string object against a URL">
		<cfargument name="targetString" type="string" required="true" hint="The target String."/>
		<cfscript>
			// regexURL based on an expression by Ivan Porto Carrero (http://geekswithblogs.net/casualjim/archive/2005/12/01/61722.aspx)
			// regexIP4 is a result of merging parts of regexURL with an expression by Paul Hayman (http://www.geekzilla.co.uk/view0CBFD9A7-621D-4B0C-9554-91FD48AADC77.htm)
			var result = yesNoFormat(0);
			var topleveldomains = replace(instance.valTLDS,',','|','all');
			var regexURL = "^(?##Protocol)(?:(?:ht|f)tp(?:s?)\:\/\/|~/|/)(?##Username:Password)(?:\w+:\w+@)?(?##Subdomains)(?:(?:[-\w]+\.)+(?##TopLevel Domains)(?:#topleveldomains#))(?##Port)(?::[\d]{1,5})?(?##Directories)(?:(?:(?:/(?:[-\w~!$+|.,=]|%[a-f\d]{2})+)+|/)+|\?|##)?(?##Query)(?:(?:\?(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)(?:&(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)*)*(?##Anchor)(?:##(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)?$";
			var regexURLBackup = "^(?##Protocol)(?:(?:ht|f)tp(?:s?)\:\/\/|~/|/)(?##Username:Password)(?:\w+:\w+@)?(?##Subdomains)(?:(?:[-\w]+\.)+(?##TopLevel Domains)(?:com|org|edu|net|gov|mil|biz|info|mobi|name|aero|jobs|museum|travel|[a-z]{2}))(?##Port)(?::[\d]{1,5})?(?##Directories)(?:(?:(?:/(?:[-\w~!$+|.,=]|%[a-f\d]{2})+)+|/)+|\?|##)?(?##Query)(?:(?:\?(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)(?:&(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)*)*(?##Anchor)(?:##(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)?$";
			var regexIPv4 = "^(?##Protocol)(?:(?:ht|f)tp(?:s?)\:\/\/|~/|/)(?##Address)((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))(?##Port)(?::[\d]{1,5})?(?##Directories)(?:(?:(?:/(?:[-\w~!$+|.,=]|%[a-f\d]{2})+)+|/)+|\?|##)?(?##Query)(?:(?:\?(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)(?:&(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)*)*(?##Anchor)(?:##(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)?$";
			var regexIPv6 = "";
			if( not result ) {
				result = yesNoFormat(reFindNoCase(regexURL, arguments.targetString));
			}
			if( not result ) { 
				result = yesNoFormat(reFindNoCase(regexIPv4, arguments.targetString));
			}
			return result;
		</cfscript>
	</cffunction>
  
  <!--- Element Formatting --->
  
  <cffunction name="RSSFormat" output="false" access="private" returntype="string" hint="An CFML XMLFormat replacement that converts high characters to XML safe Unicode">
  	<cfargument name="string" type="string" required="true" hint=""/>
    <cfscript>
			var CDRegEx = "\<!\[CDATA\[.*?\]\]\>$"; // Regular Expression to discover XML CDATA
			var fmtStr = arguments.string;
			var tmpStr = "";
			var i = 0;
			/* If CDATA section is found do not convert string (http://en.wikipedia.org/wiki/CDATA) */
			if(reFindNoCase(CDRegEx,fmtStr,1,'no') is 1) {}
			/* Otherwise replace all & < > characters with hexadecimal code form XML plain text compatibility */
			else {
				fmtStr = reReplaceNoCase(fmtStr,'(\&)([^##x:alnum:{2,4};].*?)','&##x26;\2','all'); 
				fmtStr = replaceNoCase(fmtStr,'<','&##x3C;','all');
				fmtStr = replaceNoCase(fmtStr,'>','&##x3E;','all');
			}
			/* Replace all high characters (numeric values 127 or greater) with hexadecimal code */
			while(reFind('[^\x00-\x7F]',fmtStr,i,false))
			{
				 i = reFind('[^\x00-\x7F]',fmtStr,i,false); // find the location of a high character
				 tmpStr = '&##x#FormatBaseN(Asc(Mid(fmtStr,i,1)),16)#;'; // obtain a copy of the high character and convert it to hexadecimal code
				 fmtStr = insert(tmpStr,fmtStr,(i)); // insert the hexadecimal code into the string
				 fmtStr = removeChars(fmtStr,i, 1); // removed the old non-hexed character
				 i = i+len(tmpStr); // add the location to the loop count and then loop again from that character position
			}
			/* return Unicoded string */
			return fmtStr;
		</cfscript>
  </cffunction>
	
  <cffunction name="URLFormat" output="false" access="private" returntype="string" hint="A CFML XMLFormat() tag replacement that converts URL strings into XML safe, escaped mark-up">
  	<cfargument name="string" type="string" required="true" hint=""/>
    <cfscript>
			var fmtStr = arguments.string;
			var tmpStr = "";
			var i = 0;
			fmtStr = reReplaceNoCase(fmtStr,'(\&)([^amp|lt|gt|##x:alnum:{2,4};].*?)','&amp;\2','all');
			fmtStr = replaceNoCase(fmtStr,'<','&lt;','all');
			fmtStr = replaceNoCase(fmtStr,'>','&gt;','all');
			/* return escaped mark-up string */
			return fmtStr;
		</cfscript>
  </cffunction>
  
  <cffunction name="XSLFormat" output="no" access="private" returntype="string" hint="An Extensible Stylesheet (XSL) used to cleanup whitespace within our generated XML code">
  	<cfset var xsl = "">
    <cfsavecontent variable="xsl">
    <cfoutput><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
      <xsl:output method="xml" omit-xml-declaration="no" indent="yes" encoding="UTF-8" version="1.0" media-type="text/xml"/>
      <xsl:strip-space elements="*"/>
      <xsl:template match="@*|node()">
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:template>
    </xsl:stylesheet></cfoutput>
    </cfsavecontent>
  	<cfreturn xsl>
  </cffunction>
  
</cfcomponent>