<cfsetting enablecfoutputonly=true>
<!---
	Name         : search.cfm
	Author       : Raymond Camden 
	Created      : July 5, 2004
	Last Updated : October 30, 2005
	History      : Add search log
				   Removed mappings (rkc 8/27/05)
				   Limit search length (rkc 10/30/05)
	Purpose		 : Displays form to search.
--->

<cfoutput>
<p>
<table width="500" cellpadding="6" class="tableDisplay" cellspacing="1" border="0">
	<tr class="tableHeader">
		<td class="tableHeader">Search</td>
	</tr>
	<tr class="tableRowMain">
		<td>
		<form action="#cgi.script_name#?" method="post">
		<input type="hidden" name="event" value="ehForums.doSearch">
			
		<table>
			<tr>
				<td><b>Search Terms:</b></td>
				<td><input type="text" name="searchterms" value="#getValue("searchterms","")#" class="formBox" maxlength="100"></td>
			</tr>
			<tr>
				<td><b>Match:</b></td>
				<td>
				<select name="searchtype" class="formDropDown">
					<option value="phrase" <cfif getValue("searchtype","all") is "phrase">selected</cfif>>Phrase</option>
					<option value="any" <cfif getValue("searchtype","all") is "any">selected</cfif>>Any Word</option>
					<option value="all" <cfif getValue("searchtype","all") is "all">selected</cfif>>All Words</option>
				</select>	
				</td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td align="right"><input type="image" src="images/btn_search.gif" alt="Search" width="59" height="19"></td>
			</tr>
		</table>
		</form>
		</td>
	</tr>
	<cfif valueExists("totalResults")>
	<!--- Get References --->
	<cfset conferences = getValue("conferences")>
	<cfset forums = getValue("forums")>
	<cfset threads = getValue("threads")>
	<cfset messages = getValue("messages")>
	
		<tr class="tableRowMain">
			<td>
				<p>
				<b>Results in Conferences:</b><br>
				<cfif conferences.recordCount>
					<cfloop query="conferences">
					<a href="index.cfm?event=ehForums.dspForums&conferenceid=#id#">#name#</a><br>
					</cfloop>
				<cfelse>
				No matches.
				</cfif>
				</p>
				<p>
				<b>Results in Forums:</b><br>
				<cfif forums.recordCount>
					<cfloop query="forums">
					<a href="index.cfm?event=ehForums.dspThreads&forumid=#id#">#name#</a><br>
					</cfloop>
				<cfelse>
				No matches.
				</cfif>
				</p>
				<p>
				<b>Results in Threads:</b><br>
				<cfif threads.recordCount>
					<cfloop query="threads">
					<a href="index.cfm?event=ehForums.dspMessages&threadid=#id#">#name#</a><br>
					</cfloop>
				<cfelse>
				No matches.
				</cfif>
				</p>
				<p>
				<b>Results in Messages:</b><br>
				<cfif messages.recordCount>
					<cfloop query="messages">
					<a href="index.cfm?event=ehForums.dspMessages&threadid=#threadidfk#">#title#</a><br>
					</cfloop>
				<cfelse>
				No matches.
				</cfif>
				</p>

			</td>
		</tr>
	</cfif>
</table>
</p>
</cfoutput>

<cfsetting enablecfoutputonly=false>
