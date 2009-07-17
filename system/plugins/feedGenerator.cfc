<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Luis Majano
Date        :	02/22/2008
License		: 	Apache 2 License
Description :
	This is a feed generator. It will be able to output rss 2.0 feeds only as of now.	
	You need to set the following settings in your application (coldbox.xml.cfm)

METHODS:

	- CreateFeed( feedStruct:struct, [ColumnMap:struct] [OutputFile:string] ): XML 
	  
	  This method will create the feed and return it to the caller in XML format.
	  * feedStruct : The properties and items structure
	  * ColumnMap : Same as cffeed, you create a structure that will map the rss
	    elements to your query.
	  * OutputFile : The file path of where to write the feed to.


INSTRUCTIONS
The name and properties structures must conform to the following rules (Follows cffeed rules):

When you create a feed, you specify the feed contents in a name structure or in the combination 
of a query object and a properties structure. This plugin generates the feed XML and returns it to the
user, or you can send an OutputFile containing a path, of where to store the XML data.

MANDATORY STRUCTURE PROPERTIES
To create an RSS 2.0 feed you must specify the following metadata fields in a structure. 

 * title : string : The name of the channel
 * link : string : The URL to the HTML website corresponding to this channel
 * description : string : Phrase or sentence describing this channel.
 * items : query : A query of all the items to aggregate.

OPTIONAL PROPERTIES
 * copyright : string
 * language : string (default generated = "en-us")
 * managingEditor : string
 * webMaster : string
 * image : struct
   * url : string : The url of the image
   * title : string : Describe the image, used in the ALT property
   * link : string : The URL of the site, when the channel is rendered, the image is a link to the site.
   * width : numeric : The width of the image
   * height : numeric : The height of the image
   * description : string : The optional title description.

PROPERTIES AUTO-GENERATED
 * lastBuildDate : date
 * pubDate : date
 * generator : string = "#pluginName# #PluginVersion#"

QUERIES REQUIRED FIELDS
You must have the following required fields in your query or use the columnMap attribute explained below:

 * title : string : Title of the item
 * link : string : Link to the item
 * description : string : The item synopsis

QUERIES OPTIONAL FIELDS
 * author : string : The email address of the author of this item.
 * comments : string : The url of the comments for this item
 * enclosure_url : string : The url of the enclosure
 * enclosure_length : numeric : How big the enclosure is
 * enclosure_type : string : The mime/type of the enclosure
 * guid : string : The guid of this item
 * guid_permalink : boolean : Whether this has a permalink or not (defaults to false)
 * pubDate : date : The date when this item was published. (Else, now() is used.)
 
COLUMNMAP
In most cases, a database table uses column names that differ from the column names you must use to create the feed. 
Therefore, you must use the columnmap attribute to map the input query column names to the required column names.

<!--- Get the feed data as a query from the orders table. --->
<cfquery name="getOrders" datasource="cfartgallery"> 
    SELECT * FROM orders 
</cfquery>

<!--- Map the orders column names to the feed query column names. --->
<cfset columnMapStruct = StructNew()>
<cfset columnMapStruct.pubDate = "ORDERDATE"> 
<cfset columnMapStruct.description = "CONTENT"> 
<cfset columnMapStruct.title = "CUSTOMERFIRSTNAME"> 
<cfset columnMapStruct.link = "ORDERID">

----------------------------------------------------------------------->
<cfcomponent name="feedGenerator" 
			 extends="coldbox.system.plugin"
			 hint="A feed generator plugin. This plugin only generates RSS 2.0 feeds."
			 cache="true">

<!---------------------------------------- CONSTRUCTOR --------------------------------------------------->

	<cffunction name="init" access="public" returntype="feedGenerator" output="false" hint="Plugin Constructor.">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			/* Super */
			super.Init(arguments.controller);
			
			/* Plugin Properties */
			setpluginName("ColdBox Feed Generator");
			setpluginVersion("1.0");
			setpluginDescription("I am a Feed generator plugin.");
			
			/* Return instance */
			return this;
		</cfscript>
	</cffunction>

<!---------------------------------------- PUBLIC RSS METHODS --------------------------------------------------->
	
	<cffunction name="createFeed" access="public" returntype="xml" hint="Create an RSS 2.0 feed." output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="feedStruct" 	type="struct" required="yes" hint="The structure used to build a feed. Look at docs for more info.">
		<cfargument name="ColumnMap" 	type="struct" required="false" hint="The column mapper to use for the items query."/>
		<cfargument name="OutputFile" 	type="string" required="false" hint="The file destination of where to store the generated XML"/>
		<!--- ******************************************************************************** --->
		<cfset var fs = arguments.feedStruct>
		<cfset var xmlContent = "">
		
		<cfscript>
			/* Verify our Structure */
			verifyFeed(fs);
		</cfscript>
		
		<!--- Create our Metadata XML --->
		<cfsavecontent variable="xmlContent">
		<cfoutput><?xml version="1.0" encoding="utf-8"?>
		<rss version="2.0">
			 <channel>
			    <title>#xmlFormat(fs["title"])#</title>
			    <link>#xmlFormat(fs["link"])#</link>
			    <description>#xmlFormat(fs["description"])#</description>
			    <language>#fs["language"]#</language>
			    <pubDate>#fs["pubDate"]#</pubDate>
			    <lastBuildDate>#fs["lastBuildDate"]#</lastBuildDate>
			    <generator>#xmlFormat(fs["generator"])#</generator>
			    <managingEditor>#xmlFormat(fs["managingEditor"])#</managingEditor>
			    <webMaster>#xmlFormat(fs["webMaster"])#</webMaster>
			    <cfif structKeyExists(fs,"image")>
			    <image>
			    	<url>#xmlFormat(fs.image["url"])#</url>
			    	<title>#xmlFormat(fs.image["title"])#</title>
			    	<link>#xmlFormat(fs.image["link"])#</link>
			    	<cfif structKeyExists(fs.image,"width")><width>#xmlFormat(fs.image["width"])#</width></cfif>
			    	<cfif structKeyExists(fs.image,"height")><height>#xmlFormat(fs.image["height"])#</height></cfif>
			    	<cfif structKeyExists(fs.image,"description")><description>#xmlFormat(fs.image["description"])#</description></cfif>
			    </image>
			    </cfif>
			    <cfif structKeyExists(fs,"copyright")><copyright>#xmlFormat(fs["copyright"])#</copyright></cfif>
			    <!--- Items --->
			   	#generateItems(argumentCollection=arguments)#
			</channel>
	    </rss>
		</cfoutput>
		</cfsavecontent>

		<!--- Check for File Output --->
		<cfif structKeyExists(arguments,"OutputFile")>
			<cffile action="write" file="#arguments.outputFile#" output="#xmlContent#" charset="utf-8">
		</cfif>		
		
		<!--- Return Content --->
		<cfreturn xmlContent>
	</cffunction>

	<!--- ******************************************************************************** --->

	
<!---------------------------------------- PRIVATE --------------------------------------------------->
	
	<!--- generateItems --->
	<cffunction name="generateItems" output="false" access="public" returntype="string" hint="Generate the items XML">
		<!--- ******************************************************************************** --->
		<cfargument name="feedStruct" 	type="struct" required="yes" 	hint="The structure used to build a feed. Look at docs for more info.">
		<cfargument name="ColumnMap" 	type="struct" required="false"  hint="The column mapper to use for the items query."/>
		<!--- ******************************************************************************** --->
		<cfset var itemsXML = "">
		<cfset var items = arguments.feedStruct.items>
		<cfset var refLocal = structnew()>
		<cfset var map = getDefaultPropertyMap()>
		
		<!--- do we have to override our map --->
		<cfif structKeyExists(arguments, "ColumnMap")>
			<cfset map = parseColumnMap(arguments.ColumnMap)>
		</cfif>
		
		<!--- Generate XML --->
		<cfsavecontent variable="itemsXML">
		<cfoutput query="items">
		<cfscript>
			/* For some optional variables */
			refLocal = structnew();
			/* Date Tests */
			if( structKeyExists(items, "#map.pubdate#") ){
				refLocal.pubDate = generateRFC822Date(items[map.pubdate][currentRow]);
			}
			else{ refLocal.pubDate = generateRFC822Date(now()); }
			/* PermaLink Tests */
			if( structKeyExists(items,"#map.guid_permalink#") ){
				refLocal.permalink = xmlFormat(items[map.guid_permalink][currentrow]);
			}
			else{ refLocal.permalink = false; }
			/* Enclosure tests */
			if( structKeyExists(items,"#map.enclosure_url#") ){
				refLocal.enclosure = structnew();
				refLocal.enclosure.url = xmlFormat(items[map.enclosure_url][currentrow]);
				/* Length */
				if( structKeyExists(items, "#map.enclosure_length#") ){
					refLocal.enclosure.length = xmlFormat(items[map.enclosure_length][currentrow]);
				}
				else{ refLocal.enclosure.length = ""; }
				/* Type */
				if( structKeyExists(items, "#map.enclosure_type#") ){
					refLocal.enclosure.type = xmlFormat(items[map.enclosure_type][currentrow]);
				}
				else{ refLocal.enclosure.type = ""; }				
			} //end of enclosure setup.
		</cfscript>
		<item>
			<title>#xmlFormat(items[map.title][currentrow])#</title>
			<description>#xmlFormat(items[map.description][currentrow])#</description>
			<link>#xmlFormat(items[map.link][currentrow])#</link>
			<pubDate>#refLocal.pubDate#</pubDate>
			<!--- Optional author --->
			<cfif structKeyExists(items,"#map.author#")>
			<author>#xmlFormat(items[map.author][currentrow])#</author>
			</cfif>
			<!--- Optional Comments --->
			<cfif structKeyExists(items,"#map.comments#")>
			<comments>#xmlFormat(items[map.comments][currentrow])#</comments>
			</cfif>
			<!--- Optional guid --->
			<cfif structKeyExists(items,"#map.guid#")>
			<guid isPermaLink="#refLocal.permaLink#">#xmlFormat(items[map.guid][currentrow])#</guid>
			</cfif>
			<!--- Optional Enclosure --->
			<cfif structKeyExists(refLocal,"enclosure")>
			<enclosure url="#refLocal.enclosure.url#" length="#refLocal.enclosure.length#" type="#refLocal.enclosure.type#"></enclosure>
			</cfif>			
		</item>
		</cfoutput>
		</cfsavecontent>
		
		<cfreturn itemsXML>
	</cffunction>

	<!--- verifyFeed --->
	<cffunction name="verifyFeed" output="false" access="public" returntype="void" hint="Verify the feed structure and append auto-generated properties.">
		<!--- ******************************************************************************** --->
		<cfargument name="feedStruct" type="struct" required="true" hint="The feed structure"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var fsKeys = structKeyList(arguments.feedStruct);
			var mandatoryItems = "title,link,description,items";
			var dtNow = now();
			var x = 1;
			
			/* Verify Mandatory Properties */	
			for(x=1; x lte listlen(mandatoryItems); x=x+1){
				if( not listfindnocase( fsKeys, listGetAt(mandatoryItems,x) ) ){
					$throw("Invalid feed structure found.",
						  "The mandatory key: #listGetAt(mandatoryItems,x)# was not found in the structure",
						  "ColdBox.plugins.feedGenerator.InvalidFeedStructure");
				}
			}
			
			/* Append AutoGenerated Keys */
			arguments.feedStruct["lastBuildDate"] = generateRFC822Date(dtNow);
			arguments.feedStruct["pubDate"] = generateRFC822Date(dtNow);
			arguments.feedStruct["generator"] = "#getPluginName()# - #GetPluginVersion()#";
			
			/* Verify Optional Properties */
			if( not structKeyExists(arguments.feedStruct,"language") ){
				arguments.feedStruct["language"] = "en-us";
			}
			if( not structKeyExists(arguments.feedStruct,"managingEditor") ){
				arguments.feedStruct["managingEditor"] = "";
			}
			if( not structKeyExists(arguments.feedStruct,"webMaster") ){
				arguments.feedStruct["webMaster"] = "";
			}
			
			/* Image Element Validation */
			if( structKeyExists(arguments.feedStruct, "image") ){
				if( not isStruct(arguments.feedStruct.image) ){
					$throw("Invalid image element.","The image element must be a structure containing the elements: url,title and link","ColdBox.feedGenerator.InvalidFeedStructure");
				}
				if( not structKeyExists(arguments.feedStruct.image,"url") ){
					arguments.feedStruct.image["url"] = "";
				}
				if( not structKeyExists(arguments.feedStruct.image,"title") ){
					arguments.feedStruct.image["title"] = "";
				}
				if( not structKeyExists(arguments.feedStruct.image,"link") ){
					arguments.feedStruct.image["link"] = "";
				}
			}
			/* Query validation */
			if( not isQuery(arguments.feedStruct.items) ){
				$throw("Invalid items query","The items element must be a valid query.","ColdBox.feedGenerator.InvalidFeedStructure");
			}			
		</cfscript>
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
			var map = structnew();
			map.title = "title";
			map.link = "link";
			map.description = "description";
			map.author = "author";
			map.comments = "comments";
			map.enclosure_url = "enclosure_url";
			map.enclosure_length = "enclosure_length";
			map.enclosure_type = "enclosure_type";
			map.guid = "guid";
			map.guid_permalink = "guid_permalink";
			map.pubdate = "pubdate";
			return map;
		</cfscript>
	</cffunction>

<!---------------------------------------- PRIVATE --------------------------------------------------->


	<!--- generateRFC822Date --->
	<cffunction name="generateRFC822Date" output="false" access="private" returntype="string" hint="Generate an RFC8222 Date from a date object. Conformed to GMT">
		<!--- ******************************************************************************** --->
		<cfargument name="targetDate" type="string" required="true" hint="The target Date. Must be a valid date."/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var TZ=getTimeZoneInfo();
			var GDT = "";
			var GMTDt = "";
			var GMTTm = "";
			/* Validate we have a real date to work with */
			if( not isDate(arguments.targetDate) ){
				$throw("The date sent in for parsing is not valid","TargetDate: #arguments.targetDate#","ColdBox.feedGenerator.InvalidDate");
			}
			/* Calculate with offset the GMT DateTime Object */
			GDT = dateAdd('s',TZ.utcTotalOffset,arguments.targetDate);
			/* Get Date Part */
			GMTDt=DateFormat(GDT,'ddd, dd mmm yyyy');
			/* Get Time Part */
			GMTTm=TimeFormat(GDT,'HH:mm:ss');
			
			/* Return with GMT */
			return "#GMTDt# #GMTTm# GMT";
		</cfscript>		
	</cffunction>
		
</cfcomponent>