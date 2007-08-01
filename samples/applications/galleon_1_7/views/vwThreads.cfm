<cfsetting enablecfoutputonly=true>
<!---
	Name         : threads.cfm
	Author       : Raymond Camden 
	Created      : June 10, 2004
	Last Updated : August 4, 2006
	History      : Support for uuid (rkc 1/27/05)
				   Fixed code that gets # of pages (rkc 4/8/05)
				   Stupid typo (rkc 4/11/05)
				   Removed mappings, sticky (rkc 8/27/05)
				   sorting, page fix, link to last (rkc 9/15/05)
				   show last user (rkc 7/12/06)
				   fix title (rkc 8/4/06)
	Purpose		 : Displays threads for a forum
--->

<!--- Get References --->
<cfset data = Event.getValue("data")>
<!--- Displays pagination on right side, plus left side buttons for threads --->
<cfmodule template="../tags/pagination.cfm" pages="#Event.getValue("pages")#" mode="threads" />

<!--- Now display the table. This changes based on what our data is. --->
<cfoutput>
<p>
<table width="100%" cellpadding="6" class="tableDisplay" cellspacing="1" border="0">
	<tr class="tableHeader">
		<td colspan="5" class="tableHeader">Forum: #request.forum.name#</td>
	</tr>
	<tr class="tableSubHeader">
		<td class="tableSubHeader">#headerLink("Thread","name")#</td>
		<td class="tableSubHeader">#headerLink("Originator","username")#</td>
		<td class="tableSubHeader">#headerLink("Replies","messagecount")#</td>
		<td class="tableSubHeader">#headerLink("Last Post","lastpost")#</td>
		<td class="tableSubHeader">#headerLink("Read Only","readonly")#</td>
	</tr>
	<cfif data.recordCount>
		<cfloop query="data" startrow="#(rc.page-1)*application.settings.perpage+1#" endrow="#(rc.page-1)*application.settings.perpage+application.settings.perpage#">
			<!---
				I add this because it is possible for a thread to have 0 posts.
			--->
			<cfset mcount = max(0, messagecount-1)>
			<tr class="tableRow#currentRow mod 2#">
				<td><cfif isBoolean(sticky) and sticky><b>[Sticky]</b></cfif> <a href="index.cfm?event=#Event.getValue("xehMessages")#&threadid=#id#">#name#</a></td>
				<td>#username#</td>
				<td>#mcount#</td>
				<td>
				<cfif len(lastuseridfk)>
				<cfset uinfo = cachedUserInfo(username=lastuseridfk,userid=true)>
				<a href="index.cfm?event=#Event.getValue("xehMessages")#&threadid=#id###last">#dateFormat(lastpost,"m/d/yy")# #timeFormat(lastpost,"h:mm tt")# by #uinfo.username#</a>
				<cfelse>&nbsp;</cfif>			
				</td>
				<td>#yesNoFormat(readonly)#</td>
			</tr>
		</cfloop>
	<cfelse>
		<tr class="tableRow1">
			<td colspan="5">Sorry, but there are no threads available for this forum.</td>
		</tr>
	</cfif>
</table>
</p>
</cfoutput>

<cfsetting enablecfoutputonly=false>
