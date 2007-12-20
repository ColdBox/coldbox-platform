<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : recent.cfm
	Author       : Sam Farmer 
	Created      : April 13, 2006
	Last Updated : 
	History      : 
				   
	Purpose		 : Display recent comments
--->

<cfset numComments = 5>
<cfset lenComment = 100>

<cfmodule template="../../tags/podlayout.cfm" title="#getResource("recentcomments")#">
	<cfset getComments = application.blog.getRecentComments(numComments)>
	<cfloop query="getComments">
		<cfset formattedComment = replaceLinks(comment)>
		<cfoutput><a href="#application.blog.makeLink(getComments.entryID)#">#getComments.title#</a><br>
		#getComments.name# said: <cfif len(formattedComment) gt lenComment>#left(formattedComment,lenComment)#...<cfelse>#formattedComment#</cfif>
		<a href="#application.blog.makeLink(getComments.entryID)###c#getComments.id#">more</a><br></cfoutput>
	</cfloop>
	<cfif not getComments.recordCount>
		<cfoutput>#getResource("norecentcomments")#</cfoutput>
	</cfif>

	
</cfmodule>
