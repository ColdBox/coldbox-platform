<cfset qryFeeds = getValue("qryData")>
<cfset tag = getValue("tag")>
<cfset term = getValue("term")>

<cfoutput>
	<div style="margin-bottom:10px;">
		<b>Search Results For <span style="text-decoration:underline;">#tag##term#</span>:</b>
	</div>
	
	<cfloop query="qryFeeds">
		<div style="line-height:20px;">
			<a href="javascript:doEvent('ehFeed.dspViewFeed','centercontent',{feedID:'#qryFeeds.feedID#'});"><strong>#qryFeeds.feedname#</strong></a>
			<span style="font-size:0.8em;">
				 by #qryFeeds.username# on #dateformat(qryFeeds.createdon,"mmm dd")# #lstimeFormat(qryFeeds.createdOn)#
			</span>
		</div>	
	</cfloop>
	<cfif qryFeeds.recordCount eq 0>
		<div style="line-height:20px;"><em>No feeds found.</em></div>
	</cfif>
	
	<script>
		doEvent("ehFeed.dspAllTags", "rightcontent1", {});
	</script>
</cfoutput>
