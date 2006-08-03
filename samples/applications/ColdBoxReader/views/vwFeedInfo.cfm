<cfset qryData = getValue("qryData")>
<cfset feedID = getValue("feedID")>
<cfoutput query="qryData">
	<h2 style="margin-bottom:2px;"><a href="#siteURL#">#FeedName#</a></h2>
	<div style="font-size:0.8em;margin-bottom:8px;">
		Added by #username# on #lsdateFormat(createdOn)#
	</div>

	<b>Description:</b><br>
	#description#
	
	<br><br><b>Total Views:</b> #views#
	
	<br /><br /><a href="#siteURL#" target="_blank"><img src="images/xml.gif" alt="XML Feed" border=0 /></a>
</cfoutput>
