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
<cfoutput query="rc.qryFeeds" maxrows="5">
<div style="line-height:20px;">
	<img src="images/archives.gif">&nbsp;<a href="javascript:doEvent('#Event.getValue("xehViewFeed")#','centercontent',{feedID:'#rc.qryFeeds.feedID#'});"><strong>#rc.qryFeeds.feedname#</strong></a>
	<span style="font-size:0.9em;">
		 by #rc.qryFeeds.username# on #dateformat(rc.qryFeeds.createdon,"mmm dd")# #lstimeFormat(rc.qryFeeds.createdOn)#
	</span>
</div>
</cfoutput>
</p>


<br /><br />
<p><b>Most Visited:</b>
<cfoutput query="rc.qryTopFeeds">
	<div style="line-height:20px;">
		[#rc.qryTopFeeds.views#]&nbsp;
		<img src="images/archives.gif">&nbsp;<a href="javascript:doEvent('#Event.getValue("xehViewFeed")#','centercontent',{feedID:'#rc.qryTopFeeds.feedID#'});"><strong>#rc.qryTopFeeds.feedname#</strong></a>
		<span style="font-size:0.9em;">
			 by #rc.qryTopFeeds.username# on #dateformat(rc.qryTopFeeds.createdon,"mmm dd")# #lstimeFormat(rc.qryFeeds.createdOn)#
		</span>
	</div>
</cfoutput>
</p>

<!--- Setup the Page --->
<cfoutput>
<script>
	clearDiv("leftcontent1");
	clearDiv("rightcontent2");
	doEvent("#Event.getValue("xehShowTags")#", "rightcontent1", {});
	doEvent("#Event.getValue("xehShowInfo")#", "leftcontent1", {});
	doEvent("#Event.getValue("xehAccountActions")#", "divAccountActions", {});
</script>
</cfoutput>