<cfset qryFeeds = Context.getValue("qryFeeds")>

<h1>My ColdBox Reader Feeds:</h1>
<p>
	Below are your current added feeds. Click on their names to open their articles.
</p>

<hr /><br />

<p><b>My Feeds:</b>
<cfoutput query="qryFeeds">
<div style="line-height:20px;">
	<img src="images/archives.gif">&nbsp;<a href="javascript:doEvent('#Context.getValue("xehViewFeed")#','centercontent',{feedID:'#qryFeeds.feedID#',myfeeds:'true'});"><strong>#qryFeeds.feedname#</strong></a>
	<span style="font-size:0.9em;">
		 by #qryFeeds.username# on #dateformat(qryFeeds.createdon,"mmm dd")# #lstimeFormat(qryFeeds.createdOn)#
	</span>
</div>
</cfoutput>
</p>

<br><br>
<!--- Setup the Page --->
<cfoutput>
<script>
	clearDiv("leftcontent1");
	clearDiv("rightcontent2");
	doEvent("#Context.getValue("xehShowTags")#", "rightcontent1", {});
	doEvent("#Context.getValue("xehShowInfo")#", "leftcontent1", {});
	doEvent("#Context.getValue("xehAccountActions")#", "divAccountActions", {});
</script>
</cfoutput>