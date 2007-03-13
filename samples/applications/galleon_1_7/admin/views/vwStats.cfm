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
<cfoutput>#renderView("includes/gen_stats")#</cfoutput>
<cfoutput>#getPlugin("messagebox").renderit()#</cfoutput>
<cfif Event.getValue("charts")>
	<cfoutput>#renderView("includes/stats_charts")#</cfoutput>
</cfif>


<cfsetting enablecfoutputonly=false>