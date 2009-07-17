<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/31/2007
Description :
	This is a base lightwire utility object.
----------------------------------------------------------------------->
<cfcomponent name="Utility" output="False" hint="A basic utility object for LightWire">

	<!--- PlaceHolder Replacer --->
	<cffunction name="placeHolderReplacer" access="public" returntype="any" hint="PlaceHolder Replacer for strings containing ${} patterns" output="false" >
		<!---************************************************************************************************ --->
		<cfargument name="str" 		required="true" type="any" hint="The string variable to look for replacements">
		<cfargument name="settings" required="true" type="any" hint="The structure of settings to use in replacing">
		<!---************************************************************************************************ --->
		<cfscript>
			var returnString = arguments.str;
			var regex = "\$\{([0-9a-z\-\.\_]+)\}";
			var lookup = 0;
			var varName = 0;
			var varValue = 0;
			/* Loop and Replace */
			while(true){
				/* Search For Pattern */
				lookup = reFindNocase(regex,returnString,1,true);	
				/* Found? */
				if( lookup.pos[1] ){
					/* Get Variable Name From Pattern */
					varName = mid(returnString,lookup.pos[2],lookup.len[2]);
					/* Lookup Value */
					if( structKeyExists(arguments.settings,varname) ){
						varValue = arguments.settings[varname];
					}
					else if( isDefined("arguments.settings.#varName#") ){
						varValue = Evaluate("arguments.settings.#varName#");
					}
					else{
						varValue = "VAR_NOT_FOUND";
					}
					/* Remove PlaceHolder Entirely */
					returnString = removeChars(returnString, lookup.pos[1], lookup.len[1]);
					/* Insert Var Value */
					returnString = insert(varValue, returnString, lookup.pos[1]-1);
				}
				else{
					break;
				}	
			}
			/* Return Parsed String. */
			return returnString;
		</cfscript>
	</cffunction>
	
	<!--- Decode from JSON to CF --->
	<cffunction name="decodeJSON" access="public" returntype="any" output="no" hint="Converts data from JSON to CF format">
		<!--- ************************************************************* --->
		<cfargument name="data" type="string" required="Yes" hint="JSON Packet" />
		<!--- ************************************************************* --->
		<!--- DECLARE VARIABLES --->
		<cfset var ar = ArrayNew(1) />
		<cfset var st = StructNew() />
		<cfset var dataType = "" />
		<cfset var inQuotes = false />
		<cfset var startPos = 1 />
		<cfset var nestingLevel = 0 />
		<cfset var dataSize = 0 />
		<cfset var i = 1 />
		<cfset var skipIncrement = false />
		<cfset var j = 0 />
		<cfset var char = "" />
		<cfset var dataStr = "" />
		<cfset var structVal = "" />
		<cfset var structKey = "" />
		<cfset var colonPos = "" />
		<cfset var qRows = 0 />
		<cfset var qCol = "" />
		<cfset var qData = "" />
		<cfset var curCharIndex = "" />
		<cfset var curChar = "" />
		<cfset var result = "" />
		<cfset var unescapeVals = "\\,\"",\/,\b,\t,\n,\f,\r" />
		<cfset var unescapeToVals = "\,"",/,#Chr(8)#,#Chr(9)#,#Chr(10)#,#Chr(12)#,#Chr(13)#" />
		<cfset var unescapeVals2 = '\,",/,b,t,n,f,r' />
		<cfset var unescapetoVals2 = '\,",/,#Chr(8)#,#Chr(9)#,#Chr(10)#,#Chr(12)#,#Chr(13)#' />
		<cfset var dJSONString = "" />
		<cfset var _data = Trim(arguments.data) />
		<cfset var pos = 0>
		
		<!--- NUMBER --->
		<cfif IsNumeric(_data)>
			<cfreturn _data />
		
		<!--- NULL --->
		<cfelseif _data EQ "null">
			<cfreturn "" />
		
		<!--- BOOLEAN --->
		<cfelseif ListFindNoCase("true,false", _data)>
			<cfreturn _data />
		
		<!--- EMPTY STRING --->
		<cfelseif _data EQ "''" OR _data EQ '""'>
			<cfreturn "" />
		
		<!--- STRING --->
		<cfelseif ReFind('^"[^\\"]*(?:\\.[^\\"]*)*"$', _data) EQ 1 OR ReFind("^'[^\\']*(?:\\.[^\\']*)*'$", _data) EQ 1>
			<cfset _data = mid(_data, 2, Len(_data)-2) />
			<!--- If there are any \b, \t, \n, \f, and \r, do extra processing
				(required because ReplaceList() won't work with those) --->
			<cfif Find("\b", _data) OR Find("\t", _data) OR Find("\n", _data) OR Find("\f", _data) OR Find("\r", _data)>
				<cfset curCharIndex = 0 />
				<cfset curChar =  ""/>
				<cfset dJSONString = createObject("java", "java.lang.StringBuffer").init("") />
				<cfloop condition="true">
					<cfset curCharIndex = curCharIndex + 1 />
					<cfif curCharIndex GT len(_data)>
						<cfbreak />
					<cfelse>
						<cfset curChar = mid(_data, curCharIndex, 1) />
						<cfif curChar EQ "\">
							<cfset curCharIndex = curCharIndex + 1 />
							<cfset curChar = mid(_data, curCharIndex,1) />
							<cfset pos = listFind(unescapeVals2, curChar) />
							<cfif pos>
								<cfset dJSONString.append(ListGetAt(unescapetoVals2, pos)) />
							<cfelse>
								<cfset dJSONString.append("\" & curChar) />
							</cfif>
						<cfelse>
							<cfset dJSONString.append(curChar) />
						</cfif>
					</cfif>
				</cfloop>
				
				<cfreturn dJSONString.toString() />
			<cfelse>
				<cfreturn ReplaceList(_data, unescapeVals, unescapeToVals) />
			</cfif>
		
		<!--- ARRAY, STRUCT, OR QUERY --->
		<cfelseif ( Left(_data, 1) EQ "[" AND Right(_data, 1) EQ "]" )
			OR ( Left(_data, 1) EQ "{" AND Right(_data, 1) EQ "}" )>
			
			<!--- Store the data type we're dealing with --->
			<cfif Left(_data, 1) EQ "[" AND Right(_data, 1) EQ "]">
				<cfset dataType = "array" />
			<cfelseif ReFindNoCase('^\{"recordcount":[0-9]+,"columnlist":"[^"]+","data":\{("[^"]+":\[[^]]*\],?)+\}\}$', _data, 0) EQ 1>
				<cfset dataType = "query" />
			<cfelse>
				<cfset dataType = "struct" />
			</cfif>
			
			<!--- Remove the brackets --->
			<cfset _data = Trim( Mid(_data, 2, Len(_data)-2) ) />
			
			<!--- Deal with empty array/struct --->
			<cfif Len(_data) EQ 0>
				<cfif dataType EQ "array">
					<cfreturn ar />
				<cfelse>
					<cfreturn st />
				</cfif>
			</cfif>
			
			<!--- Loop through the string characters --->
			<cfset dataSize = Len(_data) + 1 />
			<cfloop condition="#i# LTE #dataSize#">
				<cfset skipIncrement = false />
				<!--- Save current character --->
				<cfset char = Mid(_data, i, 1) />
				
				<!--- If char is a quote, switch the quote status --->
				<cfif char EQ '"'>
					<cfset inQuotes = NOT inQuotes />
				<!--- If char is escape character, skip the next character --->
				<cfelseif char EQ "\" AND inQuotes>
					<cfset i = i + 2 />
					<cfset skipIncrement = true />
				<!--- If char is a comma and is not in quotes, or if end of string, deal with data --->
				<cfelseif (char EQ "," AND NOT inQuotes AND nestingLevel EQ 0) OR i EQ Len(_data)+1>
					<cfset dataStr = Mid(_data, startPos, i-startPos) />
					
					<!--- If data type is array, append data to the array --->
					<cfif dataType EQ "array">
						<cfset arrayappend( ar, decode(dataStr) ) />
					<!--- If data type is struct or query... --->
					<cfelseif dataType EQ "struct" OR dataType EQ "query">
						<cfset dataStr = Mid(_data, startPos, i-startPos) />
						<cfset colonPos = Find('":', dataStr) />
						<cfif colonPos>
							<cfset colonPos = colonPos + 1 />	
						<cfelse>
							<cfset colonPos = Find(":", dataStr) />	
						</cfif>
						<cfset structKey = Trim( Mid(dataStr, 1, colonPos-1) ) />
						
						<!--- If needed, remove quotes from keys --->
						<cfif Left(structKey, 1) EQ "'" OR Left(structKey, 1) EQ '"'>
							<cfset structKey = Mid( structKey, 2, Len(structKey)-2 ) />
						</cfif>
						
						<cfset structVal = Mid( dataStr, colonPos+1, Len(dataStr)-colonPos ) />
						
						<!--- If struct, add to the structure --->
						<cfif dataType EQ "struct">
							<cfset StructInsert( st, structKey, decode(structVal) ) />
						
						<!--- If query, build the query --->
						<cfelse>
							<cfif structKey EQ "recordcount">
								<cfset qRows = decode(structVal) />
							<cfelseif structKey EQ "columnlist">
								<cfset st = QueryNew( decode(structVal) ) />
								<cfif qRows>
									<cfset QueryAddRow(st, qRows) />
								</cfif>
							<cfelseif structKey EQ "data">
								<cfset qData = decode(structVal) />
								<cfset ar = StructKeyArray(qData) />
								<cfloop from="1" to="#ArrayLen(ar)#" index="j">
									<cfloop from="1" to="#st.recordcount#" index="qRows">
										<cfset qCol = ar[j] />
										<cfset QuerySetCell(st, qCol, qData[qCol][qRows], qRows) />
									</cfloop>
								</cfloop>
							</cfif>
						</cfif>
					</cfif>
					
					<cfset startPos = i + 1 />
				<!--- If starting a new array or struct, add to nesting level --->
				<cfelseif "{[" CONTAINS char AND NOT inQuotes>
					<cfset nestingLevel = nestingLevel + 1 />
				<!--- If ending an array or struct, subtract from nesting level --->
				<cfelseif "]}" CONTAINS char AND NOT inQuotes>
					<cfset nestingLevel = nestingLevel - 1 />
				</cfif>
				
				<cfif NOT skipIncrement>
					<cfset i = i + 1 />
				</cfif>
			</cfloop>
			
			<!--- Return appropriate value based on data type --->
			<cfif dataType EQ "array">
				<cfreturn ar />
			<cfelse>
				<cfreturn st />
			</cfif>
		
		<!--- INVALID JSON --->
		<cfelse>
			<cfthrow message="Invalid JSON" detail="The document you are trying to decode is not in valid JSON format" />
		</cfif>
	</cffunction>
	
	<!--- Read File --->
	<cffunction name="readFile" access="public" hint="Facade to Read a file's content" returntype="Any" output="false">
		<!--- ************************************************************* --->
		<cfargument name="FileToRead"	 		type="String"  required="yes" 	 hint="The absolute path to the file.">
		<!--- ************************************************************* --->
		<cfset var FileContents = "">
		<cffile action="read" file="#arguments.FileToRead#" variable="FileContents">
		<cfreturn FileContents>
	</cffunction>
	
	<!--- Dump it Facade --->
	<cffunction name="dumpit" access="public" hint="Facade for cfmx dump" returntype="void">
		<cfargument name="var" required="yes" type="any">
		<cfargument name="abort" type="boolean" required="false" default="false"/>
		<cfdump var="#var#"><cfif abort><cfabort></cfif>
	</cffunction>
	
	<!--- Abort Facade --->
	<cffunction name="abortit" access="public" hint="Facade for cfabort" returntype="void" output="false">
		<cfabort>
	</cffunction>
	
	<!--- Rethrow Facade --->
	<cffunction name="rethrowit" access="public" returntype="void" hint="Rethrow facade" output="false" >
		<cfargument name="throwObject" required="true" type="any" hint="The cfcatch object">
		<cfthrow object="#arguments.throwObject#">
	</cffunction>
	
	<!--- Throw Facade --->
	<cffunction name="throwit" access="public" hint="Facade for cfthrow" output="false">
		<!--- ************************************************************* --->
		<cfargument name="message" 	type="string" 	required="yes">
		<cfargument name="detail" 	type="string" 	required="no" default="">
		<cfargument name="type"  	type="string" 	required="no" default="Framework">
		<!--- ************************************************************* --->
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>

</cfcomponent>