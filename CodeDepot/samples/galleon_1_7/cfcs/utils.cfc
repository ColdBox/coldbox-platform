<cfcomponent displayName="Utils" hint="Set of common methods.">
	<!---
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
	--->
	<cffunction name="activeURL" access="public" returnType="string" output="false">
	<cfargument name="string" type="string" required="true">
	<cfscript>
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
	</cfscript>
	</cffunction>

<!--- 
Copyright for coloredCode function. Also note that Jeff Coughlin made some mods to this as well.
=============================================================
	Utility:	ColdFusion ColoredCode v3.2
	Author:		Dain Anderson
	Email:		webmaster@cfcomet.com
	Revised:	June 7, 2001
	Download:	http://www.cfcomet.com/cfcomet/utilities/
============================================================= 
--->
	<cffunction name="coloredCode" output="false" returnType="string" access="public"
			   hint="Colors code">
		<cfargument name="dataString" type="string" required="true">
		<cfargument name="class" type="string" required="true">

		<cfset var data = trim(arguments.dataString) />
		<cfset var eof = 0>
		<cfset var bof = 1>
		<cfset var match = "">
		<cfset var orig = "">
		<cfset var chunk = "">

		<cfscript>
		/* Convert special characters so they do not get interpreted literally; italicize and boldface */
		data = REReplaceNoCase(data, '&([[:alpha:]]{2,});', '�strong��em�&amp;\1;�/em��/strong�', 'ALL');
	
		/* Convert many standalone (not within quotes) numbers to blue, ie. myValue = 0 */
		data = REReplaceNoCase(data, "(gt|lt|eq|is|,|\(|\))([[:space:]]?[0-9]{1,})", "\1�span style='color: ##0000ff'�\2�/span�", "ALL");
	
		/* Convert normal tags to navy blue */
		data = REReplaceNoCase(data, "<(/?)((!d|b|c(e|i|od|om)|d|e|f(r|o)|h|i|k|l|m|n|o|p|q|r|s|t(e|i|t)|u|v|w|x)[^>]*)>", "�span style='color: ##000080'�<\1\2>�/span�", "ALL");
	
		/* Convert all table-related tags to teal */
		data = REReplaceNoCase(data, "<(/?)(t(a|r|d|b|f|h)([^>]*)|c(ap|ol)([^>]*))>", "�span style='color: ##008080'�<\1\2>�/span�", "ALL");
	
		/* Convert all form-related tags to orange */
		data = REReplaceNoCase(data, "<(/?)((bu|f(i|or)|i(n|s)|l(a|e)|se|op|te)([^>]*))>", "�span style='color: ##ff8000'�<\1\2>�/span�", "ALL");
	
		/* Convert all tags starting with 'a' to green, since the others aren't used much and we get a speed gain */
		data = REReplaceNoCase(data, "<(/?)(a[^>]*)>", "�span style='color: ##008000'�<\1\2>�/span�", "ALL");
	
		/* Convert all image and style tags to purple */
		data = REReplaceNoCase(data, "<(/?)((im[^>]*)|(sty[^>]*))>", "�span style='color: ##800080'�<\1\2>�/span�", "ALL");
	
		/* Convert all ColdFusion, SCRIPT and WDDX tags to maroon */
		data = REReplaceNoCase(data, "<(/?)((cf[^>]*)|(sc[^>]*)|(wddx[^>]*))>", "�span style='color: ##800000'�<\1\2>�/span�", "ALL");
	
		/* Convert all inline "//" comments to gray (revised) */
		data = REReplaceNoCase(data, "([^:/]\/{2,2})([^[:cntrl:]]+)($|[[:cntrl:]])", "�span style='color: ##808080'��em�\1\2�/em��/span�", "ALL");
	
		/* Convert all multi-line script comments to gray */
		data = REReplaceNoCase(data, "(\/\*[^\*]*\*\/)", "�span style='color: ##808080'��em�\1�/em��/span�", "ALL");
	
		/* Convert all HTML and ColdFusion comments to gray */	
		/* The next 10 lines of code can be replaced with the commented-out line following them, if you do care whether HTML and CFML 
		   comments contain colored markup. */

		while(NOT EOF) {
			Match = REFindNoCase("<!--" & "-?([^-]*)-?-->", data, BOF, True);
			if (Match.pos[1]) {
				Orig = Mid(data, Match.pos[1], Match.len[1]);
				Chunk = REReplaceNoCase(Orig, "�(/?[^�]*)�", "", "ALL");
				BOF = ((Match.pos[1] + Len(Chunk)) + 38); // 38 is the length of the SPAN tags in the next line
				data = Replace(data, Orig, "�span style='color: ##808080'��em�#Chunk#�/em��/span�");
			} else EOF = 1;
		}


		/* Convert all quoted values to blue */
		data = REReplaceNoCase(data, """([^""]*)""", "�span style=""color: ##0000ff""�""\1""�/span�", "all");

		/* Convert left containers to their ASCII equivalent */
		data = REReplaceNoCase(data, "<", "&lt;", "ALL");

		/* Convert right containers to their ASCII equivalent */
		data = REReplaceNoCase(data, ">", "&gt;", "ALL");

		/* Revert all pseudo-containers back to their real values to be interpreted literally (revised) */
		data = REReplaceNoCase(data, "�([^�]*)�", "<\1>", "ALL");

		/* ***New Feature*** Convert all FILE and UNC paths to active links (i.e, file:///, \\server\, c:\myfile.cfm) */
		data = REReplaceNoCase(data, "(((file:///)|([a-z]:\\)|(\\\\[[:alpha:]]))+(\.?[[:alnum:]\/=^@*|:~`+$%?_##& -])+)", "<a target=""_blank"" href=""\1"">\1</a>", "ALL");

		/* Convert all URLs to active links (revised) */
		data = REReplaceNoCase(data, "([[:alnum:]]*://[[:alnum:]\@-]*(\.[[:alnum:]][[:alnum:]-]*[[:alnum:]]\.)?[[:alnum:]]{2,}(\.?[[:alnum:]\/=^@*|:~`+$%?_##&-])+)", "<a target=""_blank"" href=""\1"">\1</a>", "ALL");

		/* Convert all email addresses to active mailto's (revised) */
		data = REReplaceNoCase(data, "(([[:alnum:]][[:alnum:]_.-]*)?[[:alnum:]]@[[:alnum:]][[:alnum:].-]*\.[[:alpha:]]{2,})", "<a href=""mailto:\1"">\1</a>", "ALL");
		</cfscript>

		<!--- mod by ray --->
		<!--- change line breaks at end to <br /> --->
		<cfset data = replace(data,chr(13),"<br />","all") />
		<!--- replace tab with 3 spaces --->
		<cfset data = replace(data,chr(9),"&nbsp;&nbsp;&nbsp;","all") />
		<cfset data = "<div class=""#arguments.class#"">" & data &  "</div>" />
		
		<cfreturn data>
	</cffunction>
	
	<cffunction name="logSearch" returnType="void" output="false" access="public" hint="Logs a search request">
		<cfargument name="searchTerms" type="string" required="true">
		<cfargument name="dsn" type="string" required="true">
		<cfargument name="tableprefix" type="string" required="true">
		
		<cfquery datasource="#arguments.dsn#">
			insert into #arguments.tableprefix#search_log(searchterms, datesearched)
			values(<cfqueryparam cfsqltype="cf_sql_varchar" value="#left(arguments.searchTerms, 255)#">,
			       <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">)
		</cfquery>
		
	</cffunction>
	
	<cffunction name="isUserInAnyRole2" access="public" returnType="boolean" output="false"
				hint="isUserInRole only does AND checks. This method allows for OR checks.">
		
		<cfargument name="rolelist" type="string" required="true">
		<cfset var role = "">
		
		<cfloop index="role" list="#rolelist#">
			<cfif isUserInRole(role)>
				<cfreturn true>
			</cfif>
		</cfloop>
		
		<cfreturn false>
		
	</cffunction>
	
	<!---
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
	--->
	<cffunction name="paragraphFormat2" access="public" returnType="string" output="false">
		<cfargument name="str" type="string" required="true">
		<cfscript>
		//first make Windows style into Unix style
		str = replace(str,chr(13)&chr(10),chr(10),"ALL");
		//now make Macintosh style into Unix style
		str = replace(str,chr(13),chr(10),"ALL");
		//now fix tabs
		str = replace(str,chr(9),"&nbsp;&nbsp;&nbsp;","ALL");
		//now return the text formatted in HTML
		return replace(str,chr(10),"<br />","ALL");
		</cfscript>
	</cffunction>
	
	<cffunction name="queryToStruct" access="public" returnType="struct" output="false"
				hint="Transforms a query to a struct.">
		<cfargument name="theQuery" type="query" required="true">
		<cfset var s = structNew()>
		<cfset var q ="">
		
		<cfloop index="q" list="#theQuery.columnList#">
			<cfset s[q] = theQuery[q][1]>
		</cfloop>
		
		<cfreturn s>
		
	</cffunction>
	
	<cffunction name="searchSafe" access="public" returnType="string" output="false"
				hint="Removes any non a-z, 0-9 characters.">
		<cfargument name="string" type="string" required="true">
		
		<cfreturn reReplace(arguments.string,"[^a-zA-Z0-9[:space:]]+","","all")>
	</cffunction>
	
	<cffunction name="throw" access="public" returnType="void" output="false"
				hint="Handles exception throwing.">
				
		<cfargument name="type" type="string" required="true">		
		<cfargument name="message" type="string" required="true">
		
		<cfthrow type="#arguments.type#" message="#arguments.message#">
		
	</cffunction>

</cfcomponent>