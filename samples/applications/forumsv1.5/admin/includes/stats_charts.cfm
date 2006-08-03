<!---
	Name         : stats_charts.cfm
	Author       : Raymond Camden 
	Created      : August 30, 2004
	Last Updated : 
	History      : 
	Purpose		 : 
--->

<cfoutput>
<p>
<table class="adminListTable" width="500">
<tr class="adminListHeader">
	<td><b>Number of Forums Per Conference</b></td>
</tr>
<tr>
	<td>
	<cfchart format="flash" chartheight="400" chartwidth="400" seriesplacement="default" 
			 labelformat="number" tipstyle="mouseOver" pieslicestyle="sliced">
		<cfchartseries type="pie">
			<cfloop query="conferences">
			
				<cfset fCount = application.forum.getForums(conferenceid=id).recordCount>
				<cfchartdata item="#name#" value="#fCount#">
			</cfloop>
		</cfchartseries>
	</cfchart>
	</td>
</tr>
</table>
</p>

<p>
<table class="adminListTable" width="500">
<tr class="adminListHeader">
	<td><b>Number of Threads Per Forum</b></td>
</tr>
<tr>
	<td>
	<cfchart format="flash" chartheight="400" chartwidth="400" seriesplacement="default" 
			 labelformat="number" tipstyle="mouseOver" pieslicestyle="sliced">
		<cfchartseries type="pie">
			<cfloop query="forums">			
				<cfset fCount = application.thread.getThreads(forumid=id).recordCount>
				<cfchartdata item="#name#" value="#fCount#">
			</cfloop>
		</cfchartseries>
	</cfchart>
	</td>
</tr>
</table>
</p>

<cfquery name="sortedThreads" dbtype="query">
	select		*
	from		threads
	order by	messagecount desc
</cfquery>

<p>
<table class="adminListTable" width="500">
<tr class="adminListHeader">
	<td colspan="2"><b>Top 10 Threads by Message Count</b></td>
</tr>
<tr>
	<td><b>Thread Name</b></td>
	<td><b>Message Count</b></td>
</tr>
<cfloop query="sortedThreads" endrow="10">
<tr>
	<td>#name#</td>
	<td>#messagecount#
</tr>
</cfloop>
</table>
</p>

<cfquery name="sortedUsers" dbtype="query">
	select		*
	from		users
	order by	postcount desc
</cfquery>

<p>
<table class="adminListTable" width="500">
<tr class="adminListHeader">
	<td colspan="2"><b>Top 10 Users by Post Count</b></td>
</tr>
<tr>
	<td><b>User Name</b></td>
	<td><b>Post Count</b></td>
</tr>
<cfloop query="sortedUsers" endrow="10">
<tr>
	<td>#username#</td>
	<td>#postcount#
</tr>
</cfloop>
</table>
</p>

</cfoutput>


