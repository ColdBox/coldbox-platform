<cfsetting enablecfoutputonly=true>
<!---
	Name         : gen_stats.cfm
	Author       : Raymond Camden
	Created      : August 28, 2005
	Last Updated :
	History      :
	Purpose		 : general stats used both on home page and stats
--->

<!--- Run event for get stats --->
<cfset runEvent("ehForums.doGetStats")>
<!--- Set References --->
<cfset conferences = getValue("conferences")>
<cfset forums = getValue("forums")>
<cfset threads = getValue("threads")>
<cfset users = getValue("users")>
<cfset messages = getValue("messages")>

<cfoutput>
<p>
<table class="adminListTable" width="500">
<tr class="adminListHeader">
	<td colspan="2"><b>General Stats</b></td>
</tr>
<tr>
	<td><b>Number of Conferences:</b></td>
	<td>#conferences.recordCount#</td>
</tr>
<tr>
	<td><b>Number of Forums:</b></td>
	<td>#forums.recordCount#</td>
</tr>
<tr>
	<td><b>Number of Threads:</b></td>
	<td>#threads.recordCount#</td>
</tr>
<tr>
	<td><b>Number of Messages:</b></td>
	<td>#messages.recordCount#</td>
</tr>
<tr>
	<td><b>First Post:</b></td>
	<td>#dateFormat(getValue("getMinPost").earliestPost, "m/d/yy")# #timeFormat(getValue("getMinPost").earliestPost, "h:mm tt")#</td>
</tr>
<tr>
	<td><b>Last Post:</b></td>
	<td>#dateFormat(getValue("getMaxPost").lastPost, "m/d/yy")# #timeFormat(getValue("getMaxPost").lastPost, "h:mm tt")#</td>
</tr>
<tr>
	<td><b>Number of Users:</b></td>
	<td>#users.recordCount#</td>
</tr>

</table>
</p>
</cfoutput>

<cfsetting enablecfoutputonly=false>