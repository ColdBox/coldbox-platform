<cfsetting enablecfoutputonly=true>
<!---
	Name         : index.cfm
	Author       : Raymond Camden 
	Created      : June 10, 2004
	Last Updated : September 15, 2005
	History      : show msgcount, last msg (rkc 4/6/05)
				   Fixed code that gets # of pages (rkc 4/8/05)
				   Right colspan if no data (rkc 4/15/05)
				   use addToken=false in auto-push (rkc 4/15/05)
				   Remove mappings (rkc 8/27/05)
				   support sorting, fix pages (rkc 9/15/05)
	Purpose		 : Displays conferences
--->
<!--- References --->
<cfset data = getValue("data")>
<cfset pages = getValue("pages")>

<!--- Displays pagination on right side, plus left side buttons for threads --->
<cfmodule template="../tags/pagination.cfm" pages="#pages#" />

<!--- Now display the table. This changes based on what our data is. --->
<cfoutput>
<p>
<table width="100%" cellpadding="6" class="tableDisplay" cellspacing="1" border="0">
	<tr class="tableHeader">
		<td colspan="4" class="tableHeader">Conferences</td>
	</tr>
	<tr class="tableSubHeader">
		<td class="tableSubHeader">#request.udf.headerLink("Name")#</td>
		<td class="tableSubHeader">#request.udf.headerLink("Description")#</td>
		<td class="tableSubHeader">#request.udf.headerLink("Messages","messagecount")#</td>
		<td class="tableSubHeader">#request.udf.headerLink("Last Post","lastpost")#</td>
	</tr>
	<cfif data.recordCount>
		<cfloop query="data" startrow="#(getValue("page")-1)*application.settings.perpage+1#" endrow="#(getValue("page")-1)*application.settings.perpage+application.settings.perpage#">
			<tr class="tableRow#currentRow mod 2#">
				<td><a href="index.cfm?event=#getValue("xehForums")#&conferenceid=#id#">#name#</a></td>
				<td>#description#</td>
				<td>#messagecount#</td>
				<td><a href="index.cfm?event=#getValue("xehMessages")#&threadid=#threadidfk###last">#dateFormat(lastpost,"m/d/yy")# #timeFormat(lastpost,"h:mm tt")#</a></td>
			</tr>
		</cfloop>
	<cfelse>
		<tr class="tableRow1">
			<td colspan="4">Sorry, but there are no conferences available.</td>
		</tr>
	</cfif>
</table>
</p>
</cfoutput>

<cfsetting enablecfoutputonly=false>
