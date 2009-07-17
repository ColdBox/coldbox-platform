<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : unsubscribe.cfm
	Author       : Raymond Camden 
	Created      : October 20, 2004
	Last Updated : July 21, 2005
	History      : Removed mapping (3/20/05)
				   Adding cfsetting, procdirective (rkc 7/21/05)
	Purpose		 : Allows you to unsubscribe
--->


<cfoutput>
<div class="date">#getResource("unsubscribe")#</div>
</cfoutput>

<cfif Event.valueExists("commentID")>
	<cfif Event.getValue("result")>
		<cfoutput>
		<p>#getResource("unsubscribesuccess")#</p>
		</cfoutput>
	<cfelse>
		<cfoutput>
		<p>#getResource("unsubscribefailure")#</p>
		</cfoutput>
	</cfif>

<cfelseif Event.valueExists("token")>
	
	<cfif Event.getValue("result")>
		<cfoutput>
		<p>#getResource("unsubscribeblogsuccess")#</p>
		</cfoutput>
	<cfelse>
		<cfoutput>
		<p>#getResource("unsubscribeblogfailure")#</p>
		</cfoutput>
	</cfif>

</cfif>

<cfoutput><p><a href="#application.blog.getProperty("blogurl")#">#getResource("returntoblog")#</a></p></cfoutput>

<cfsetting enablecfoutputonly=false>	