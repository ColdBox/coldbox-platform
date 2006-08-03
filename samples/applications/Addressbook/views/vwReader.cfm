<cfset qryFeeds = getValue("qryFeeds")>

<cfquery name="qryTopFeeds" dbtype="query" maxrows="5">
	SELECT *
		FROM qryFeeds
		ORDER BY Views DESC
</cfquery>


<h1>About ColdBoxReader</h1>
<p>
	ColdBoxReader is an application for shared reading of RSS/Atom feeds. Users submit RSS/Atom feeds 
	and provide basic information about the feed, what is it about, who publishes it, etc.
	The new feed is added to a shared pool of feeds for others to read; Other users see the feed information 
	entered by the user who added the feed, and in turn can add comments and tags to it; 
	Feed access is tracked so more popular feeds can bubble up. By combining the view count with tags/categories
	the site can generate a ranking of the most "interesting" feeds for each tag/category.
</p>	

<hr /><br />
	
<p><b>Recently Added:</b>
<cfoutput query="qryFeeds" maxrows="5">
	<div style="line-height:20px;">
		<a href="javascript:doEvent('ehFeed.dspViewFeed','centercontent',{feedID:'#qryFeeds.feedID#'});"><strong>#qryFeeds.feedname#</strong></a>
		<span style="font-size:0.8em;">
			 by #qryFeeds.username# on #dateformat(qryFeeds.createdon,"mmm dd")# #lstimeFormat(qryFeeds.createdOn)#
		</span>
	</div>	
</cfoutput>
</p>


<br /><br />
<p><b>Most Visited:</b>
<cfoutput query="qryTopFeeds" maxrows="5">
	<div style="line-height:20px;">
		[#qryTopFeeds.views#]&nbsp;
		<a href="javascript:doEvent('ehFeed.dspViewFeed','centercontent',{feedID:'#qryTopFeeds.feedID#'});"><strong>#qryTopFeeds.feedname#</strong></a>
		<span style="font-size:0.8em;">
			 by #qryTopFeeds.username# on #dateformat(qryTopFeeds.createdon,"mmm dd")# #lstimeFormat(qryFeeds.createdOn)#
		</span>
	</div>	
</cfoutput>
</p>

<p><br /><br />
<cfif Not StructKeyExists(Session, "userID") or Session.userID eq "">
	To Add a Feed, your must first <a href="javascript:doEvent('ehUser.dspLogin','centercontent',{})"><strong>Sign-in</strong></a> to your account
	or <a href="javascript:doEvent('ehUser.dspSignUp','centercontent',{})"><strong>Create an Account</strong></a>.
	<div id="divLogin"></div>
<cfelse>
	<input type="button" name="btnAdd" value="Add Feed" onclick="doEvent('ehFeed.dspAddFeed','centercontent',{});" />
</cfif>
</p>

<script>
	clearDiv("leftcontent1");
	clearDiv("rightcontent2");
	doEvent("ehFeed.dspAllTags", "rightcontent1", {});
	doEvent("ehUser.dspAccountActions", "divAccountActions", {});
</script>