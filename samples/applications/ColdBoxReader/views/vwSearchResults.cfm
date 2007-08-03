<cfset qryFeeds = Event.getValue("qryData")>
<cfset tag = Event.getValue("tag")>
<cfset term = Event.getValue("term")>

<cfoutput>
<h1>Keyword Search Results:</h1>	
<hr>
<br>
	
	<div style="margin-bottom:10px;">
		<b>Search Terms: <span style="text-decoration:underline;">#tag##term#</span></b>
	</div>
	
	<ul>
	<cfloop query="qryFeeds">
		<li><div style="line-height:20px;">
			<a href="javascript:doEvent('#Event.getValue("xehFeed")#','centercontent',{feedID:'#qryFeeds.feedID#'});"><strong>#qryFeeds.feedname#</strong></a>
			<span style="font-size:0.9em;">
				 by #qryFeeds.username# on #dateformat(qryFeeds.createdon,"mmm dd")# at #lstimeFormat(qryFeeds.createdOn)#
			</span>
		</div>	
		</li>
	</cfloop>
	</ul>
	
	<cfif qryFeeds.recordCount eq 0>
		<div style="line-height:20px;"><em>No feeds found.</em></div>
	</cfif>
	
	<br>
	<hr>
	<img src="images/orange_arrows.gif" align="absmiddle">Showing #qryFeeds.RecordCount# results.
	<br>
	<script>
		doEvent("#Event.getValue("xehTags")#", "rightcontent1", {});
	</script>
</cfoutput>
