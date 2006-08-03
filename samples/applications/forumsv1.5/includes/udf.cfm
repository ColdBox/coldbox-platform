<cfsetting enablecfoutputonly=true>
<!---
	Name         : udf.cfm
	Author       : Raymond Camden 
	Created      : June 01, 2004
	Last Updated : September 15, 2005
	History      : Added ActivateURL (rkc 2/11/05)
				   Added ParagraphFormat2 (rkc 3/28/05)
				   Added call to get rank (rkc 8/28/05)
				   Variety of a few new funcs (rkc 9/15/05)
	Purpose		 : 
--->

<cfscript>
function isLoggedOn() {
	return getAuthUser() neq "";
}
request.udf.isLoggedOn = isLoggedOn;

/**
 * Tests passed value to see if it is a valid e-mail address (supports subdomain nesting and new top-level domains).
 * Update by David Kearns to support '
 * SBrown@xacting.com pointing out regex still wasn't accepting ' correctly.
 * 
 * @param str 	 The string to check. (Required)
 * @return Returns a boolean. 
 * @author Jeff Guillaume (jeff@kazoomis.com) 
 * @version 2, August 15, 2002 
 */
function IsEmail(str) {
//supports new top level tlds
if (REFindNoCase("^['_a-z0-9-]+(\.['_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*\.(([a-z]{2,3})|(aero|coop|info|museum|name))$",str)) return TRUE;
	else return FALSE;
}
request.udf.isEmail = isEmail;

function isValidUsername(str) {
	if(reFindNoCase("[^a-z0-9]",str)) return false;
	return true;
}
request.udf.isValidUsername = isValidUsername;

/**
 * Returns a XHTML compliant string wrapped with properly formatted paragraph tags.
 * 
 * @param string 	 String you want XHTML formatted. 
 * @param attributeString 	 Optional attributes to assign to all opening paragraph tags (i.e. style=""font-family: tahoma""). 
 * @return Returns a string. 
 * @author Jeff Howden (jeff@members.evolt.org) 
 * @version 1.1, January 10, 2002 
 */
function XHTMLParagraphFormat(string) {
  var attributeString = '';
  var returnValue = '';
  
  //added by me to support different line breaks
  string = replace(string, chr(10) & chr(10), chr(13) & chr(10), "all");
  
  if(ArrayLen(arguments) GTE 2) attributeString = ' ' & arguments[2];
  if(Len(Trim(string)))
    returnValue = '<p' & attributeString & '>' & Replace(string, Chr(13) & Chr(10), '</p>' & Chr(13) & Chr(10) & '<p' & attributeString & '>', 'ALL') & '</p>';
  return returnValue;
}

request.udf.XHTMLParagraphFormat = XHTMLParagraphFormat;

/**
 * An &quot;enhanced&quot; version of ParagraphFormat.
 * Added replacement of tab with nonbreaking space char, idea by Mark R Andrachek.
 * Rewrite and multiOS support by Nathan Dintenfas.
 * 
 * @param string 	 The string to format. (Required)
 * @return Returns a string. 
 * @author Ben Forta (ben@forta.com) 
 * @version 3, June 26, 2002 
 */
function ParagraphFormat2(str) {
	//first make Windows style into Unix style
	str = replace(str,chr(13)&chr(10),chr(10),"ALL");
	//now make Macintosh style into Unix style
	str = replace(str,chr(13),chr(10),"ALL");
	//now fix tabs
	str = replace(str,chr(9),"&nbsp;&nbsp;&nbsp;","ALL");
	//now return the text formatted in HTML
	return replace(str,chr(10),"<br />","ALL");
}

request.udf.ParagraphFormat2 = ParagraphFormat2;

/**
 * This function takes URLs in a text string and turns them into links.
 * Version 2 by Lucas Sherwood, lucas@thebitbucket.net.
 * Version 3 Updated to allow for ;
 * 
 * @param string 	 Text to parse. (Required)
 * @param target 	 Optional target for links. Defaults to "". (Optional)
 * @param paragraph 	 Optionally add paragraphFormat to returned string. (Optional)
 * @return Returns a string. 
 * @author Joel Mueller (jmueller@swiftk.com) 
 * @version 3, August 11, 2004 
 */
function ActivateURL(string) {
	var nextMatch = 1;
	var objMatch = "";
	var outstring = "";
	var thisURL = "";
	var thisLink = "";
	var	target = IIf(arrayLen(arguments) gte 2, "arguments[2]", DE(""));
	var paragraph = IIf(arrayLen(arguments) gte 3, "arguments[3]", DE("false"));
	
	do {
		objMatch = REFindNoCase("(((https?:|ftp:|gopher:)\/\/)|(www\.|ftp\.))[-[:alnum:]\?%,\.\/&##!;@:=\+~_]+[A-Za-z0-9\/]", string, nextMatch, true);
		if (objMatch.pos[1] GT nextMatch OR objMatch.pos[1] EQ nextMatch) {
			outString = outString & Mid(String, nextMatch, objMatch.pos[1] - nextMatch);
		} else {
			outString = outString & Mid(String, nextMatch, Len(string));
		}
		nextMatch = objMatch.pos[1] + objMatch.len[1];
		if (ArrayLen(objMatch.pos) GT 1) {
			// If the preceding character is an @, assume this is an e-mail address
			// (for addresses like admin@ftp.cdrom.com)
			if (Compare(Mid(String, Max(objMatch.pos[1] - 1, 1), 1), "@") NEQ 0) {
				thisURL = Mid(String, objMatch.pos[1], objMatch.len[1]);
				thisLink = "<A HREF=""";
				switch (LCase(Mid(String, objMatch.pos[2], objMatch.len[2]))) {
					case "www.": {
						thisLink = thisLink & "http://";
						break;
					}
					case "ftp.": {
						thisLink = thisLink & "ftp://";
						break;
					}
				}
				thisLink = thisLink & thisURL & """";
				if (Len(Target) GT 0) {
					thisLink = thisLink & " TARGET=""" & Target & """";
				}
				thisLink = thisLink & ">" & thisURL & "</A>";
				outString = outString & thisLink;
				// String = Replace(String, thisURL, thisLink);
				// nextMatch = nextMatch + Len(thisURL);
			} else {
				outString = outString & Mid(String, objMatch.pos[1], objMatch.len[1]);
			}
		}
	} while (nextMatch GT 0);
		
	// Now turn e-mail addresses into mailto: links.
	outString = REReplace(outString, "([[:alnum:]_\.\-]+@([[:alnum:]_\.\-]+\.)+[[:alpha:]]{2,4})", "<A HREF=""mailto:\1"">\1</A>", "ALL");
		
	if (paragraph) {
		outString = ParagraphFormat(outString);
	}
	return outString;
}
request.udf.activateURL = activateURL;

/*
 This function returns asc or desc, depending on if the current dir matches col
*/
function dir(col) {
	if(valueExists("sort") and getValue("sort") is col and valueExists("sortdir") and getValue("sortdir") is "asc") return "desc";
	return "asc";
}
request.udf.dir = dir;

function headerLink(col) {
	var str = "";
	var colname = arguments.col;
	var qs = cgi.query_string;
	
	if(arrayLen(arguments) gte 2) colname = arguments[2];
	
	// can't be too safe
	if(not valueExists("sort")) setValue("sort", "");
	if(not valueExists("sortdir")) setValue("sortdir", "");
	
	//clean qs
	qs = reReplaceNoCase(qs, "&*sort=[^&]*","");
	qs = reReplaceNoCase(qs, "&*sortdir=[^&]*","");
	qs = reReplaceNoCase(qs, "&*page=[^&]*","");
	qs = reReplaceNoCase(qs, "&*logout=[^&]*","");
	qs = reReplaceNoCase(qs, "&{2,}","");
	if(len(qs)) qs = qs & "&";
	
	if(getValue("sort") is colname) str = str & "[";
	str = str & "<a href=""#cgi.script_name#?#qs#sort=#urlEncodedFormat(colname)#&sortdir=" & request.udf.dir(colname) & """>#col#</a>";
	if(getValue("sort") is colname) str = str & "]";
	return str;
}
request.udf.headerLink = headerLink;
</cfscript>

<!--- provides a cached way to get user info --->
<cffunction name="cachedUserInfo" returnType="struct" output="false">
	<cfargument name="username" type="string" required="true">
	<cfargument name="usecache" type="boolean" required="false" default="true">
	
	<cfset var userInfo = "">
	
	<cfif not isDefined("application.userCache")>
		<cfset application.userCache = structNew()>
		<cfset application.userCache_created = now()>
	</cfif>
	
	<cfif dateDiff("h",application.userCache_created,now()) gte 2>
		<cfset structClear(application.userCache)>
		<cfset application.userCache_created = now()>
	</cfif>

	<cfif structKeyExists(application.userCache, arguments.username) and arguments.usecache>
		<cfreturn duplicate(application.userCache[arguments.username])>
	</cfif>
	
	<cfset userInfo = application.user.getUser(arguments.username)>
	<!--- Get a rank for their posts --->
	<cfset userInfo.rank = application.rank.getHighestRank(userInfo.postCount)>
	
	<cfset application.userCache[arguments.username] = userInfo>
	<cfreturn userInfo>
	
</cffunction>
<cfset request.udf.cachedUserInfo = cachedUserInfo>

<cffunction name="querySort" returnType="query" output="false">
	<cfargument name="query" type="query" required="true">
	<cfargument name="column" type="string" required="true">
	<cfargument name="direction" type="string" required="true">
	<cfset var result = "">
	<cfset var stickyStr = "sticky ">
	
	<cfif findNoCase("sticky", query.columnlist)>
		<cfset stickyStr = stickyStr & "desc,">
	<cfelse>
		<cfset stickyStr = "">
	</cfif>
	
	<cfif not listFindNoCase(query.columnList, column)>
		<cfreturn query>
	</cfif>
	
	<cfquery name="result" dbtype="query">
	select		*
	from		arguments.query
	order by 	#stickyStr# #arguments.column# #arguments.direction#
	</cfquery>
	
	<cfreturn result>
</cffunction>
<cfset request.udf.querySort = querySort>
	
<cfsetting enablecfoutputonly=false>