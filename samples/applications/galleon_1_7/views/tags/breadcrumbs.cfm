<cfsetting enablecfoutputonly=true>
<!---
	Name         : breadcrumbs.cfm
	Author       : Raymond Camden 
	Created      : June 10, 2004
	Last Updated : June 10, 2004
	History      : 
	Purpose		 : Used by the main page template to generate a bread crumb. 
--->

<cfoutput>
<div class="topMenu">
<a href="index.cfm">Home</a>
<cfif isDefined("request.conference")>
	&gt; <a href="index.cfm?event=#Event.getValue("xehForums")#&conferenceid=#request.conference.id#">#request.conference.name#</a>
</cfif>
<cfif isDefined("request.forum")>
	&gt; <a href="index.cfm?event=#Event.getValue("xehThreads")#&forumid=#request.forum.id#">#request.forum.name#</a>
</cfif>
<cfif isDefined("request.thread")>
	&gt; <a href="index.cfm?event=#Event.getValue("xehMessages")#&threadid=#request.thread.id#">#request.thread.name#</a>
</cfif>
</div>
<br>
</cfoutput>

<cfsetting enablecfoutputonly=false>

<cfexit method="EXITTAG">