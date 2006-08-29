<cfsetting enablecfoutputonly=true>
<!---
	Name         : stats.cfm
	Author       : Raymond Camden 
	Created      : July 5, 2004
	Last Updated : August 30, 2005
	History      : Removed mappings, abstracted stats (rkc 8/27/05)
				   Moved out charts for BD (rkc 8/30/05)
	Purpose		 : 
--->

<cfinclude template="../includes/gen_stats.cfm">
<cfoutput>#getPlugin("messagebox").render()#</cfoutput>
<cfif getValue("charts")>
	<cfinclude template="../includes/stats_charts.cfm">
</cfif>


<cfsetting enablecfoutputonly=false>