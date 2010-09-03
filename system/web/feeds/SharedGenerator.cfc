<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Ben Garrett and Luis Majano
Date        :	18/05/2009
Version     :	2
License		: 	Apache 2 License
	Additional shared methods for the FeedGenerator plug-in that were separated
	to reduce potential bloat in the plug-in component.

----------------------------------------------------------------------->
<cfcomponent hint="Methods belonging to the FeedGenerator plug-in that specifically relate to feed creation" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfset variables.instance = createInstances(structNew())>

	<cffunction name="init" access="public" returntype="SharedGenerator" output="false">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="createInstances" access="public" returntype="struct" output="false" hint="Variables used for the validation and creation of feed data">
		<cfargument name="instance" required="true" type="struct" hint="">
		<cfscript>
			instance = arguments.instance;
			/* Validation values */
			instance.dublinCoreTerms 	= "contributor,coverage,creator,date,description,format,identifier,language,publisher,relation,rights,source,subject,title,type"; // dublin core metadata element set, version 1.1
			instance.opensearchRole		= "request,example,related,correction,subset,superset"; // allowed opensearch query roles
			instance.opensearchTitle	= 256; // maxium characters allowed in opensearch query title
			instance.topLevelDomains	= "AC,AD,AEAERO,AF,AG,AI,AL,AM,AN,AO,AQ,AR,ARPA,AS,ASIA,AT,AU,AW,AX,AZ,BA,BB,BD,BE,BF,BG,BH,BI,BIZ,BJ,BM,BN,BO,BR,BS,BT,BV,BW,BY,BZ,CA,CAT,CC,CD,CF,CG,CH,CI,CK,CL,CM,CN,CO,COM,COOP,CR,CU,CV,CX,CY,CZ,DE,DJ,DK,DM,DO,DZ,EC,EDU,EE,EG,ER,ES,ET,EU,FI,FJ,FK,FM,FO,FR,GA,GB,GD,GE,GF,GG,GH,GI,GL,GM,GN,GOV,GP,GQ,GR,GS,GT,GU,GW,GY,HK,HM,HN,HR,HT,HU,ID,IE,IL,IM,IN,INFO,INT,IO,IQ,IR,IS,IT,JE,JM,JO,JOBS,JP,KE,KG,KH,KI,KM,KN,KP,KR,KW,KY,KZ,LA,LB,LC,LI,LK,LR,LS,LT,LU,LV,LY,MA,MC,MD,ME,MG,MH,MIL,MK,ML,MM,MN,MO,MOBI,MP,MQ,MR,MS,MT,MU,MUSEUM,MV,MW,MX,MY,MZ,NA,NAME,NC,NE,NET,NF,NG,NI,NL,NO,NP,NR,NU,NZ,OM,ORG,PA,PE,PF,PG,PH,PK,PL,PM,PN,PR,PRO,PS,PT,PW,PY,QA,RE,RO,RS,RU,RW,SA,SB,SC,SD,SE,SG,SH,SI,SJ,SK,SL,SM,SN,SO,SR,ST,SU,SV,SY,SZ,TC,TD,TEL,TF,TG,TH,TJ,TK,TL,TM,TN,TO,TP,TR,TRAVEL,TT,TV,TW,TZ,UA,UG,UK,US,UY,UZ,VA,VC,VE,VG,VI,VN,VU,WF,WS,XN--0ZWM56D,XN--11B5BS3A9AJ6G,XN--80AKHBYKNJ4F,XN--9T4B11YI5A,XN--DEBA0AD,XN--G6W251D,XN--HGBK6AJ7F53BBA,XN--HLCJ6AYA9ESC7A,XN--JXALPDLP,XN--KGBECHTV,XN--ZCKZAH,YE,YT,YU,ZA,ZM,ZW"; // List of top level domains (used for URL validation)
			/* Specification references */
			instance.SpecApple 	= "http://www.apple.com/itunes/whatson/podcasts/specs.html##";
			instance.SpecCFML	= "http://cfquickdocs.com/";
			instance.SpecDcmi	= "http://dublincore.org/documents/dcmi-terms/";
			instance.SpecOS 	= "http://www.opensearch.org/Specifications/OpenSearch/1.1##";
			instance.SpecRss 	= "http://www.rssboard.org/rss-specification";
			instance.SpecRssEC 	= "http://www.rssboard.org/rss-profile##element-channel-";
			instance.SpecRssNS 	= "http://www.rssboard.org/rss-profile##namespace-elements-";
			instance.SpecSlash	= "http://web.resource.org/rss/1.0/modules/slash/";
			return instance;
		</cfscript>
	</cffunction>

<!------------------------------------------- METHODS ------------------------------------------------>

	<cffunction name="parseColumnMap" output="false" access="public" returntype="struct" hint="Parse and validate a column mapper">
		<!--- ******************************************************************************** --->
		<cfargument name="columnMap" type="struct" required="true" hint="The column map to parse"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var map  = generateDefaultPropertyMap();
			var cmap = arguments.columnMap;
			var key  = "";

			/* start parsing */
			for(key in map){
				if( structKeyExists(cmap,key) ){
					map[key] = cmap[key];
				}	
			}

			return map;
		</cfscript>
	</cffunction>

<!------------------------------------------- DATA FORMATTING ---------------------------------------->

	<!--- Insert oral suffix --->
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

	<!--- Insert thousand separators --->
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

	<!--- Generate a RFC822 date --->
	<cffunction name="generateRFC822Date" output="false" access="private" returntype="string" hint="Generate an RFC8222 Date from a date object that conforms to GMT">
		<cfargument name="targetDate" type="string" required="true" hint="The target date which must be a valid date"/>
		<cfscript>
			var TZ=getTimeZoneInfo();
			var GDT = "";
			var GMTDt = "";
			var GMTTm = "";
			/* Validate we have a real date to work with */
		</cfscript>
		<cfif not isDate(arguments.targetDate)>
			<cfthrow errorcode="SharedGenerator.InvalidDate" message="The date sent in for parsing is not valid" detail="TargetDate: #arguments.targetDate#">
		</cfif>
		<cfscript>
			/* Calculate with offset the GMT DateTime object */
			GDT = dateAdd('s',TZ.utcTotalOffset,arguments.targetDate);
			/* Get date part */
			GMTDt=dateFormat(GDT,'ddd, dd mmm yyyy');
			/* Get time part */
			GMTTm=timeFormat(GDT,'HH:mm:ss');

			/* Return with GMT */
			return "#GMTDt# #GMTTm# GMT";
		</cfscript>	
	</cffunction>

<!------------------------------------------- ELEMENT FORMATTING ------------------------------------->

	<!--- Data as RSS format --->
	<cffunction name="RSSFormat" output="false" access="private" returntype="string" hint="A CFML XMLFormat() tag replacement that converts high characters to XML safe Unicode">
		<cfargument name="string" type="string" required="true" hint="The target string"/>
		<cfscript>
			var CDRegEx = "\<!\[CDATA\[.*?\]\]\>$"; // Regular expression to discover XML CDATA
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
			
			// Replace nasty &nbsp; references
			fmtStr = replaceNoCase(fmtStr,"&nbsp;","","all");
			
			// return Unicoded string
			return fmtStr;
		</cfscript>
	</cffunction>

	<!--- Data as URL format --->
	<cffunction name="URLFormat" output="false" access="private" returntype="string" hint="A CFML XMLFormat() tag replacement that converts URL strings into XML safe, escaped mark-up">
		<cfargument name="string" type="string" required="true" hint="The target string"/>
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

	<!--- XSL whitespace format --->
	<cffunction name="XSLFormat" output="false" access="public" returntype="string" hint="An Extensible Stylesheet (XSL) used to cleanup whitespace within our generated XML code">
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

<!------------------------------------------- ELEMENT VALIDATION ------------------------------------->

	<!--- Validate Creative Commons license url --->
	<cffunction name="validatecommonslicense" output="false" access="private" returntype="boolean" hint="Validate targetString object as a URL pointing to the Creative Commons website">
		<cfargument name="targetString" type="string" required="true" hint="The target string"/>
		<cfscript>
			var result = yesNoFormat(reFindNoCase('^http://(www\.)?creativecommons.org/licenses/[\w]+',arguments.targetString));
			return result;
		</cfscript>
	</cffunction>

	<!--- Validate RSS skipdays --->
	<cffunction name="validateDaysList" output="false" access="private" returntype="struct" hint="Validate list object against the RSS skipDays element requirements">
		<cfargument name="targetList" type="string" required="true" hint="The target list"/>
		<cfscript>
			var daysAllowed = instance.skipDays;
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

	<!--- Validate RSS skiphours --->
	<cffunction name="validateHoursList" output="false" access="private" returntype="struct" hint="Validate list object against the RSS skipHours element requirements">
		<cfargument name="targetList" type="string" required="true" hint="The target list"/>
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

	<!--- Validate Itunes Duration --->
	<cffunction name="validateItunesDuration" output="false" access="private" returntype="boolean" hint="Force iTunes duration formatting">
		<cfargument name="targetTime" type="string" required="true" hint="The target duration time"/>
		<cfscript>
			var result = yesNoFormat(reFind('^\d?\d?:?\d?\d:\d\d$',arguments.targetTime));
			return result;
		</cfscript>
	</cffunction>

	<!--- Validate RSS person --->
	<cffunction name="validatePerson" output="false" access="private" returntype="boolean" hint="Validate string object against the RSS person scheme containing an e-mail and an optional name">
		<cfargument name="targetString" type="string" required="true" hint="The target string"/>
		<cfscript>
			var result = yesNoFormat(reFind('^(\w+\.)*\w+@((((\d{1,2})|(1\d{2})|(2[0-4]\d)|(25[0-5]))\.){3}((\d{1,2})|(1\d{2})|(2[0-4]\d)|(25[0-5]))|(\w+\.)+[A-Za-z]+)( \(.*\))?$', arguments.targetString));
			return result;
		</cfscript>
	</cffunction>

	<!--- Validate a non-negative number --->
	<cffunction name="validateNNInteger" output="false" access="private" returntype="boolean" hint="Validate number object as a non-negative integer (0,1,2,3..)">
		<cfargument name="targetInt" type="string" required="true" hint="The target integer"/>
		<cfscript>
			var result = yesNoFormat(reFind('^\d+$',arguments.targetInt));
			return result;
		</cfscript>
	</cffunction>

	<!--- Validate RFC822Date --->
	<cffunction name="validateRFC822Date" output="false" access="private" returntype="boolean" hint="Validate date object against RFC822 'Date and Time Specification'">
		<cfargument name="targetDate" type="string" required="true" hint="The target date."/>
		<cfscript>
			var result = yesNoFormat(reFindNoCase('^(Sun|Mon|Tue|Wed|Thu|Fri|Sat)\, [0-3]\d (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) ([1-2][9|0])?\d\d [0-2]\d:[0-5]\d:[0-5]\d (GMT|UT)', arguments.targetDate));
			return result;
		</cfscript>
	</cffunction>

	<!--- Validate RFC1766 --->
	<cffunction name="validateRFC1766" output="false" access="private" returntype="boolean" hint="Validate string object against RFC1766 'Tags for the Identification of Languages'">
		<cfargument name="targetString" type="string" required="true" hint="The target string."/>
		<cfscript>
			var result = yesNoFormat(reFindNoCase('^[a-z]*[a-z][a-z](-[a-z][a-z]*)?$', arguments.targetString));
			return result;
		</cfscript>
	</cffunction>

	<!--- Validate RFC3066 --->
	<cffunction name="validateRFC3066" output="false" access="private" returntype="boolean" hint="RFC3066 'Tags for the Identification of Languages'">
		<cfargument name="targetString" type="string" required="true" hint="The target string"/>
		<cfscript>
			var result = yesNoFormat(REFindNoCase('^([a-z]{2}([a-z]{1,6})?|i|x)(-[:alnum:]{1,8})?', arguments.targetString));
			return result;
		</cfscript>
	</cffunction>

	<!--- Validate a URI --->
	<cffunction name="validateURI" output="false" access="private" returntype="boolean" hint="Validate string object against a HTTP or HTTPS, FTP, news, mailto URI">
		<cfargument name="targetString" type="string" required="true" hint="The target string"/>
		<cfscript>
			return isValid("URL",arguments.targetString);
		</cfscript>
	</cffunction>

	<!--- Validate a URL --->
	<cffunction name="validateURL" output="false" access="private" returntype="boolean" hint="Validate string object against a URL">
		<cfargument name="targetString" type="string" required="true" hint="The target string"/>
		<cfscript>
			return isValid("URL",arguments.targetString);
		</cfscript>
	</cffunction>

<!------------------------------------------- FEED EXTENSIONS ---------------------------------------->
	
	<!--- Extensions Mapping --->
	<cffunction name="generateExtensionPropertyMap" output="false" access="public" returntype="struct" hint="Generates the extensions default property map">
		<cfscript>
			var i = 0;
			var map = structnew();
			map.commonslicense = "commonslicense";
			map.itunes_author = "itunes_author";
			map.itunes_block = "itunes_block";
			map.itunes_duration = "itunes_duration";
			map.itunes_explicit = "itunes_explicit";
			map.itunes_keywords = "itunes_keywords";
			map.itunes_subtitle = "itunes_subtitle";
			map.itunes_summary = "itunes_summary";
			map.slash_comments = "slash_comments";
			map.slash_department = "slash_department";
			map.slash_hit_parade = "slash_hit_parade";
			map.slash_section = "slash_section";
			/* Generate DCMI Terms defaults from instance.dublinCoreTerms */
			for(i=1; i lte listLen(instance.dublinCoreTerms); i=i+1){
				StructInsert(map, Ucase("dcmiterm_#listGetAt(instance.dublinCoreTerms,i)#"), "dcmiterm_#listGetAt(instance.dublinCoreTerms,i)#");
			}
			/* Return map */
			return map;
		</cfscript>
	</cffunction>
	
	<!--- Extensions Namespaces --->
	<cffunction name="generateExtensionNameSpace" output="false" access="private" returntype="string" hint="Generates the XML namespaces for feed extensions depending on the tags in use">
		<cfargument name="keys" type="string" required="true" hint="A list of distinct column and structures keys"/>
		<cfscript>
			var nameSpace = '';
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
	
	<!--- Apple iTunes --->
	<!--- Generate Channel --->
	<cffunction name="itunesGenChannel" output="false" access="public" returntype="string" hint="Generate Apple iTunes extension channel XML">
		<cfargument name="fs" type="struct" required="true" hint="The structure used to build a feed"/>
		<cfset var returnedXML = "">
		<cfset var container = "">
		<cfset var i = 1>
		<cfset var j = 1>
		<cfsavecontent variable="returnedXML">
			<cfoutput>
			<!--- Optional iTunes author --->
			<cfif structKeyExists(fs.itunes,"author")><itunes:author>#RSSFormat(fs.itunes["author"])#</itunes:author></cfif>
			<!--- Optional iTunes block --->
			<cfif structKeyExists(fs.itunes,"block")><itunes:block>#RSSFormat(fs.itunes["block"])#</itunes:block></cfif>
			<!--- Optional iTunes category --->
			<cfif structKeyExists(fs.itunes,"category") and isStruct(fs.itunes.category)>
				<cfloop from="1" to="#structCount(fs.itunes.category)#" index="i">
					<cfset container = listGetAt(structKeyList(fs.itunes.category),i)>
					<cfif listFindNoCase(structKeyList(instance.itunesCategory),container) and not len(fs.itunes.category[container])>
						<itunes:category text="#RSSFormat(container)#"/>
					<cfelseif listFindNoCase(structKeyList(instance.itunesCategory),container) and len(fs.itunes.category[container])>
						<cfloop from="1" to="#listLen(fs.itunes.category[container])#" index="j">
							<cfif listFindNoCase(instance.itunesCategory[container],listGetAt(fs.itunes.category[container],j))> 
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
		</cfoutput>
		</cfsavecontent>
		<cfreturn returnedXML>
	</cffunction>
	<!--- Validate Channel --->
	<cffunction name="itunesValChannel" output="false" access="public" returntype="string" hint="Validate Apple iTunes extension channel element">
		<cfargument name="fs" type="struct" required="true" hint="The structure used to build a feed"/>
		<cfscript>
			var invalidList = "";
			var container_a = "";
			var container_b = "";
			var i 			= 1;
			var j 			= 1;
			/* itunes category */
			if( structKeyExists(fs.itunes,"category") and isStruct(fs.itunes.category) ) {
				for(i=1; i lte structCount(fs.itunes.category); i=i+1){
					container_a = listGetAt(structKeyList(fs.itunes.category),i);
					if( not listFindNoCase(structKeyList(instance.itunesCategory),container_a) ) {
						invalidList = invalidList & "| The iTunes category element containing '#container_a#' : Is not a valid iTunes category (See <a href='#instance.SpecApple#categories'>#instance.SpecApple#categories</a>)";
					}
					else if( not len(instance.itunesCategory[container_a]) and len(fs.itunes.category[container_a]) ) {
						invalidList = invalidList & "| The iTunes category element containing '#container_a#' : Should not have any subcategories, you listed '#fs.itunes.category[container_a]#' (See <a href='#instance.SpecApple#categories'>#instance.SpecApple#categories</a>)";
					}
					else if( len(instance.itunesCategory[container_a]) and not len(fs.itunes.category[container_a]) ) {
						invalidList = invalidList & "| The iTunes category element containing '#container_a#' : Needs at least one subcategory '#instance.itunesCategory[container_a]#' (See <a href='#instance.SpecApple#categories'>#instance.SpecApple#categories</a>)";
					}
					else if( len(fs.itunes.category[container_a]) ) {
						for(j=1; j lte listLen(fs.itunes.category[container_a]); j=j+1){
							if( not listFindNoCase(instance.itunesCategory[container_a],'#trim(listGetAt(fs.itunes.category[container_a],j))#') ) {
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
			if( structKeyExists(fs.itunes,"explicit") and not yesNoFormat(reFindNoCase('^(#Replace(instance.itunesExplicit,',','|','all')#)$',fs.itunes.explicit))){
				invalidList = invalidList & "| The iTunes explicit element '#fs.itunes.explicit#' : Is not a valid value, only #instance.itunesExplicit# are allowed (See <a href='#instance.SpecApple#explicit'>#instance.SpecApple#explicit</a>)";
			}
			/* itunes image */
			if( structKeyExists(fs.itunes,"image")) {
				if(not validateURL(fs.itunes.image)){
					invalidList = invalidList & "| The iTunes image url element '#fs.itunes.image#' : Is not a valid URL (See <a href='#instance.SpecApple#image'>#instance.SpecApple#image</a>)";
				}
				if(not listFindNoCase(instance.itunesImage,listLast(fs.itunes.image,'.'))){
					invalidList = invalidList & "| The iTunes image url element '#fs.itunes.image#' : Is not a valid image format, only #instance.itunesImage# are allowed (See <a href='#instance.SpecApple#image'>#instance.SpecApple#image</a>)";
				}
			}
			/* itunes keywords */
			if( structKeyExists(fs.itunes,"keywords") ) {
				if( listLen(fs.itunes.keywords) gt instance.itunesKeywords ) {
					invalidList = invalidList & "| The iTunes keywords element '#fs.itunes.keywords#' : Can only contain a maximum of #instance.itunesKeywords# items, you have #listLen(fs.itunes.keywords)# (See <a href='#instance.SpecApple#keywords'>#instance.SpecApple#keywords</a>)";
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
			if( structKeyExists(fs.itunes,"summary") and (len(fs.itunes.summary) gt instance.itunesSummary)){
				invalidList = invalidList & "| The iTunes summary element : Can only contain a maximum of #instance.itunesSummary# characters, you have #len(fs.itunes.summary)# (See <a href='#instance.SpecApple#summary'>#instance.SpecApple#summary</a>)";
			}
			return invalidList;
		</cfscript>
	</cffunction>
	<!--- Generate Item --->	
	<cffunction name="itunesGenItem" output="false" access="public" returntype="string" hint="Generate Apple iTunes extension item XML">
		<cfargument name="items" type="query" required="true" hint="The feed items"/>
		<cfargument name="map" type="struct" required="true" hint="The column mapper to map items to queries"/>
		<cfargument name="currentrow" type="numeric" required="true" hint="Current item number"/>
		<cfset var returnedXML = "">
		<cfsavecontent variable="returnedXML">
		<cfoutput>
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
		</cfoutput>
		</cfsavecontent>
		<cfreturn returnedXML>
	</cffunction>
	<!--- Validate Item --->
	<cffunction name="ituneseValItem" output="false" access="public" returntype="string" hint="Validate Apple iTunes extension item element">
		<cfargument name="fi" type="query" required="true" hint="The feed items"/>
		<cfargument name="map" type="struct" required="true" hint="The column mapper to map items to queries"/>
		<cfargument name="currentrow" type="numeric" required="true" hint="Current item number"/>
		<cfscript>
			var invalidList = "";
			/* itunes duration */
			if( structKeyExists(fi,"#map.itunes_duration#") and len(fi[map.itunes_duration][currentrow]) and not validateItunesDuration(fi[map.itunes_duration][currentrow]) ) {
				invalidList = invalidList & "| Item #fi.currentrow# : The iTunes duration (itunes_duration) element '#fi[map.itunes_duration][currentrow]#' : Is not a valid time, only HH:MM:SS,H:MM:SS,MM:SS,M:SS are allowed (See <a href='#instance.SpecApple#duration'>#instance.SpecApple#duration</a>)";
			}
			/* itunes explicit */
			if( structKeyExists(fi,"#map.itunes_explicit#") and len(fi[map.itunes_explicit][currentrow]) and not yesNoFormat(reFindNoCase('^(#Replace(instance.itunesExplicit,',','|','all')#)$',fi[map.itunes_explicit][currentrow])) ){
				invalidList = invalidList & "| Item #fi.currentrow# : The iTunes explicit (itunes_explicit) element '#fi[map.itunes_explicit][currentrow]#' : Is not a valid value, only #instance.itunesExplicit# are allowed (See <a href='#instance.SpecApple#explicit'>#instance.SpecApple#explicit</a>)";
			}
			/* itunes keywords */
			if( structKeyExists(fi,"#map.itunes_keywords#") and len(fi[map.itunes_keywords][currentrow]) ){
				if( listLen(fi[map.itunes_keywords][currentrow]) gt instance.itunesKeywords ) {
					invalidList = invalidList & "| Item #fi.currentrow# : The iTunes keywords (itunes_keywords) element '#fi[map.itunes_keywords][currentrow]#' : Can only contain a maximum of #instance.itunesKeywords# items, you have #listLen(fi[map.itunes_keywords][currentrow])# (See <a href='#instance.SpecApple#keywords'>#instance.SpecApple#keywords</a>)";
				}
				if( find(',,',fi.itunes_keywords) ) {
					invalidList = invalidList & "| Item #fi.currentrow# : The iTunes keywords (itunes_keywords) element '#fi[map.itunes_keywords][currentrow]#' : Is formatted incorrectly, please remove the cojoined commas (See <a href='#instance.SpecApple#keywords'>#instance.SpecApple#keywords</a>)";
				}
			}
			return invalidList;
		</cfscript>
	</cffunction>

	<!--- Creative Commons License --->
	<!--- Generate Channel --->
	<cffunction name="cclicenseGenChannel" output="false" access="public" returntype="string" hint="Generate Creative Commons extension channel XML">
		<cfargument name="fs" type="struct" required="true" hint="The structure used to build a feed"/>
		<cfset var returnedXML = "">
		<cfset var i		   = 1>
		<cfsavecontent variable="returnedXML">
		<cfloop from="1" to="#listLen(fs['commonslicense'])#" index="i">
			<cfoutput><creativeCommons:license>#RSSFormat(listGetAt(fs["commonslicense"],i))#</creativeCommons:license></cfoutput>
		</cfloop>
		</cfsavecontent>
		<cfreturn returnedXML>
	</cffunction>
	<!--- Validate Channel --->
	<cffunction name="cclicenseValChannel" output="false" access="public" returntype="string" hint="Validate Creative Commons extension channel element">
		<cfargument name="fs" type="struct" required="true" hint="The structure used to build a feed"/>
		<cfscript>
			var invalidList = "";
			var i 			= 1;
			for( i=1; i lte listLen(fs.commonslicense); i=i+1 ){
				if ( not validatecommonslicense(listGetAt(fs.commonslicense,i)) ) {
					invalidList = invalidList & "| The #generateNumSuffix(i)# commonslicense element '#listGetAt(fs.commonslicense,i)#' : Is not an valid URL pointing to a Creative Commons license (See <a href='http://creativecommons.org/about/licenses/meet-the-licenses'>http://creativecommons.org/about/licenses/meet-the-licenses</a>)";
				}
			}
			return invalidList;
		</cfscript>
	</cffunction>
	<!--- Generate Item --->
	<cffunction name="cclicenseGenItem" output="false" access="public" returntype="string" hint="Generate Creative Commons extension item XML">
		<cfargument name="items" type="query" required="true" hint="The feed items"/>
		<cfargument name="map" type="struct" required="true" hint="The column mapper to map items to queries"/>
		<cfargument name="currentrow" type="numeric" required="true" hint="Current item number"/>
		<cfset var returnedXML = "">
		<cfset var i		   = 1>
		<cfsavecontent variable="returnedXML">
		<cfloop from="1" to="#listLen(items[map.commonslicense][currentrow])#" index="i">
			<cfoutput><creativeCommons:license>#URLFormat(listGetAt(items[map.commonslicense][currentrow],i))#</creativeCommons:license></cfoutput>
		</cfloop>
		</cfsavecontent>
		<cfreturn returnedXML>
	</cffunction>
	<!--- Validate Item --->
	<cffunction name="cclicenseValItem" output="false" access="public" returntype="string" hint="Validate Creative Commons extension item element">
		<cfargument name="fi" type="query" required="true" hint="The feed items"/>
		<cfargument name="map" type="struct" required="true" hint="The column mapper to map items to queries"/>
		<cfargument name="currentrow" type="numeric" required="true" hint="Current item number"/>
		<cfscript>
			var invalidList = "";
			var i 			= 1;
			for( i=1; i lte listLen(fi[map.commonslicense][currentrow]); i=i+1 ){
				if ( not validatecommonslicense(listGetAt(fi[map.commonslicense][currentrow],i)) ) {
					invalidList = invalidList & "| The #generateNumSuffix(i)# commonslicense element in item #currentrow# '#listGetAt(fi[map.commonslicense][currentrow],i)#' : Is not an valid URL pointing to a Creative Commons license (See <a href='http://creativecommons.org/about/licenses/meet-the-licenses'>http://creativecommons.org/about/licenses/meet-the-licenses</a>)";
				}
			}
			return invalidList;
		</cfscript>
	</cffunction>

	<!--- DCMI Metadata terms --->
	<!--- Generate Channel --->
	<cffunction name="dcmtGenChannel" output="false" access="public" returntype="string" hint="Generate DCMI Metadata terms extension channel XML">
		<cfargument name="fs" type="struct" required="true" hint="The structure used to build a feed"/>
		<cfset var returnedXML = "">
		<cfset var container   = "">
		<cfset var i 		   = 1>
		<cfsavecontent variable="returnedXML">
		<cfloop from="1" to="#structCount(fs.dcmiterm)#" index="i">
			<cfset container = listGetAt(structKeyList(fs.dcmiterm),i)>
			<cfif listFindNoCase(instance.dublinCoreTerms,container)><cfoutput><dc:#container#>#RSSFormat(fs.dcmiterm[container])#</dc:#container#></cfoutput></cfif>
		</cfloop>
		</cfsavecontent>
		<cfreturn returnedXML>
	</cffunction>
	<!--- Generate Item --->
	<cffunction name="dcmtGenItem" output="false" access="public" returntype="string" hint="Generate DCMI Metadata terms extension item XML">
		<cfargument name="items" type="query" required="true" hint="The feed items"/>
		<cfargument name="map" type="struct" required="true" hint="The column mapper to map items to queries"/>
		<cfargument name="currentrow" type="numeric" required="true" hint="Current item number"/>
		<cfset var returnedXML = "">
		<cfset var term 	   = "">
		<cfset var i 		   = 1>
		<cfsavecontent variable="returnedXML">
		<cfloop from="1" to="#listLen(items.columnList)#" index="i">
			<cfset term = replaceNocase(listGetAt(items.columnList,i),'dcmiterm_','')>
			<cfif listFindNoCase(instance.dublinCoreTerms,term) and listFindNoCase(items.columnList,'dcmiterm_#term#') and len(items["dcmiterm_#term#"][currentrow]) >
				<cfset term = listGetAt(instance.dublinCoreTerms,listFindNocase(instance.dublinCoreTerms,term))>
				<cfoutput><dc:#term#>#RSSFormat(items["dcmiterm_#term#"][currentrow])#</dc:#term#></cfoutput>
			</cfif>
		</cfloop>
		</cfsavecontent>
		<cfreturn returnedXML>
	</cffunction>	

	<!--- OpenSearch 1.1 --->
	<!--- Generate Channel --->
	<cffunction name="opensearchGenChannel" output="false" access="public" returntype="string" hint="Generate OpenSearch extension channel XML">
		<cfargument name="fs" type="struct" required="true" hint="The structure used to build a feed"/>
		<cfset var returnedXML = "">
		<cfset var i		   = 1>
		<cfsavecontent variable="returnedXML">
			<cfoutput>
			<!--- Optional OpenSearch 1.1 (draft 3) total results --->
			<cfif structKeyExists(fs.opensearch,"totalresults")><opensearch:totalResults>#RSSFormat(fs.opensearch["totalresults"])#</opensearch:totalResults></cfif>
			<!--- Optional OpenSearch 1.1 (draft 3) start index --->
			<cfif structKeyExists(fs.opensearch,"startindex")><opensearch:startIndex>#RSSFormat(fs.opensearch["startindex"])#</opensearch:startIndex></cfif>
			<!--- Optional OpenSearch 1.1 (draft 3) items per page --->
			<cfif structKeyExists(fs.opensearch,"itemsperpage")><opensearch:itemsPerPage>#RSSFormat(fs.opensearch["itemsperpage"])#</opensearch:itemsPerPage></cfif>
			<!--- Optional OpenSearch 1.1 (draft 3) Atom search link --->
			<cfif structKeyExists(fs.opensearch,"autodiscovery")><atom:link href="#URLFormat(fs.opensearch['autodiscovery'])#" rel="search" type="application/opensearchdescription+xml" title="Content Search"/></cfif>
			<!--- Optional OpenSearch 1.1 (draft 3) query --->
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
			</cfoutput>
		</cfsavecontent>
		<cfreturn returnedXML>
	</cffunction>
	<!--- Validate Channel --->
	<cffunction name="opensearchValChannel" output="false" access="public" returntype="string" hint="Validate OpenSearch extension channel elements">
		<cfargument name="fs" type="struct" required="true" hint="The structure used to build a feed"/>
		<cfscript>
			var invalidList = "";
			var i 		    = 1;
			
			/* opensearch autodiscovery */
			if( structKeyExists(fs.opensearch,"autodiscovery") and not validateURL(fs.opensearch.autodiscovery) ) {
				invalidList = invalidList & "| The OpenSearch search-link element (autodiscovery) '#fs.opensearch.autodiscovery#' : Is not a valid URL (See <a href='#instance.SpecOS#Autodiscovery_in_RSS.2FAtom'>#instance.SpecOS#Autodiscovery_in_RSS.2FAtom</a>)";
			}
			/* opensearch query */
			if( structKeyExists(fs,"opensearchQuery") and isArray(fs.opensearchQuery) ) {
				for( i=1; i lte arrayLen(fs.opensearchQuery); i=i+1 ){
					if( structKeyExists(fs.opensearchQuery[i],"role") and not listFindNoCase(instance.opensearchRole,fs.opensearchQuery[i].role) ) {
						invalidList = invalidList & "| The #generateNumSuffix(i)# opensearchQuery role attribute '#fs.opensearchQuery[i].role#' : Can only be one of these values #instance.opensearchRole# (See <a href='#instance.SpecOS#Local_role_values'>#instance.SpecOS#Local_role_values</a>)";
					}
					if( structKeyExists(fs.opensearchQuery[i],"title") and len(RSSFormat(fs.opensearchQuery[i].title)) gt instance.opensearchTitle ) {
						invalidList = invalidList & "| The #generateNumSuffix(i)# opensearchQuery title attribute is too long : Can only contain a maximum of #instance.opensearchTitle# characters, you have #len(RSSFormat(fs.opensearchQuery[i].title))# (See <a href='#instance.SpecOS#The_.22Query.22_element_2'>#instance.SpecOS#The_.22Query.22_element_2</a>)";
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
			return invalidList;
		</cfscript>
	</cffunction>

	<!--- Slash --->
	<!--- Generate Item --->
	<cffunction name="slashGenItem" output="false" access="public" returntype="string" hint="Generate Slash extension channel XML">
		<cfargument name="items" type="query" required="true" hint="The feed items"/>
		<cfargument name="map" type="struct" required="true" hint="The column mapper to map items to queries"/>
		<cfargument name="currentrow" type="numeric" required="true" hint="Current item number"/>
		<cfset var returnedXML = "">
		<cfsavecontent variable="returnedXML">
		<cfoutput>
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
		</cfoutput>
		</cfsavecontent>
		<cfreturn returnedXML>
	</cffunction>
	<!--- Validate Item --->
	<cffunction name="slashValItem" output="false" access="public" returntype="string" hint="Validate Slash extension item element">
		<cfargument name="fi" type="query" required="true" hint="The feed items"/>
		<cfargument name="map" type="struct" required="true" hint="The column mapper to map items to queries"/>
		<cfargument name="currentrow" type="numeric" required="true" hint="Current item number"/>
		<cfscript>
			var invalidList = "";
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
			return invalidList;
		</cfscript>
	</cffunction>

</cfcomponent>