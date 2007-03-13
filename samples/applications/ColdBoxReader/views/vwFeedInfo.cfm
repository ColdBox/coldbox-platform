<cfset qryData = Event.getValue("qryData")>
<cfset feedID = Event.getValue("feedID")>
<cfoutput query="qryData">
	<div class="nicebox">
		<h5 style="margin-bottom:2px;"><a href="#siteURL#" target="_blank">#FeedName#</a></h5>
		<div style="font-size:0.9em;margin-bottom:8px;">
		<img src="images/orange_arrows.gif" align="absmiddle">Added by <a href="mailto:#email#" title="#email#">#username#</a>
		</div>
	
	
	<cfif ImgURL neq "">
	<div style="margin-bottom: 10px"><img src="#ImgURL#" width="150"></div>
	</cfif>
	
	<b>Added On:</b><br />
	#lsdateFormat(createdOn)# at #lsTimeFormat(createdOn)#<br /><br />
	
	<b>Description:</b><br>
	#description#
	
	<br><br><b>Total Views:</b> #views#

	<br /><br /><a href="#FeedURL#" target="_blank"><img src="images/xml.gif" alt="XML Feed" border=0 /></a>

	</div>
</cfoutput>
