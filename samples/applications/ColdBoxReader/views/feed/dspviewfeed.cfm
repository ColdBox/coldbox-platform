<cfoutput>
<a name="TOP"/>	
<!--- Reload Icon --->
<div style="float:right;margin-right:5px"><a href="##" onClick="doEvent('#Event.getValue("xehReload")#','centercontent',{feedID:'#feedID#'})" title="Refresh Panels"><img src="images/reload_icon.png" border="0" title="Refresh Panels"><a/></div>

<cfif not Event.getValue("myfeeds",false)>
<div><img src="images/orange_arrows_backwards.gif" align="absmiddle"><a href="javascript:doEvent('#Event.getValue("xehFeeds")#','centercontent',{})">Return To Feeds</a></div>
<cfelse>
<div><img src="images/orange_arrows_backwards.gif" align="absmiddle"><a href="javascript:doEvent('#Event.getValue("xehMyFeeds")#','centercontent',{})">Return To My Feeds</a></div>
</cfif>

<h1 style="margin-bottom:4px;border-bottom:1px solid black;padding-bottom:3px;">
	#rc.feed.Title#
</h1>
<p>Click on the article titles to read them.</p>
<ul>
	<cfloop query="rc.feed.items">
		<cfset tmpID = "feed#currentrow#">
		<cfset tmpLinkRead = "javascript:viewContent('#tmpID#','#JSStringFormat(title)#')">
		<li>
			<cfif description neq "">
				<a href="#tmpLinkRead#"><b>#title#</b></a>

				<div id="#tmpID#" class="reader_panel" style="display: none;">			
					<!--- Close Item --->
					<div class="reader_floater">
					<cfif link neq "">
					<img src="images/web_icon.gif" align="absmiddle" border="0">&nbsp;<a href="#link#" target="_blank">Open Article</a>&nbsp;
					</cfif>
					<img src="images/orange_arrows_up.gif" align="absmiddle" border="0"><a href="##" onClick="javascript:viewContent('#tmpID#','#JSStringFormat(title)#')">Close Article</a>
					</div>
					<!--- Publish Date --->
					<div class="reader_toolbar">
						<div style="padding-top:10px;margin-left:5px"><b>Published On:</b> 
						<cfif isDate(dateUpdated)>
						#dateFormat(dateUpdated,"MMM DD, YYYY")# at #TimeFormat(dateUpdated,"hh:mm:ss tt")#
						<cfelse>
						#dateUpdated#
						</cfif>
						<br /><br />
					</div>	
					</div>
					
					<!--- Content --->					
					<div class="reader_content">#description#
					<br><br>
					<img src="images/orange_arrows.gif" border=0 align="absmiddle"><a href="#link#" target="_blank">Read More...</a>
					</div>			
				</div><br>
				
			<cfelse>
				<b>#title#</b>
				<cfif link neq "">(<a href="#link#" target="_blank">Link</a>)</cfif>
			</cfif>
		</li>
	</cfloop>
</ul>

<hr>

<cfif not Event.getValue("myfeeds",false)>
<!--- Return to feeds --->
<div><img src="images/orange_arrows_backwards.gif" align="absmiddle"><a href="javascript:doEvent('#Event.getValue("xehFeeds")#','centercontent',{})">Return To Feeds</a>
<cfelse>
<div><img src="images/orange_arrows_backwards.gif" align="absmiddle"><a href="javascript:doEvent('#Event.getValue("xehMyFeeds")#','centercontent',{})">Return To My Feeds</a></div>
</cfif>
</div>


<script>
	doEvent("#Event.getValue("xehFeedInfo")#", "leftcontent1", {feedID:'#feedID#'});
	doEvent("#Event.getValue("xehFeedTags")#", "rightcontent1", {feedID:'#feedID#'});
	//doEvent("#Event.getValue("xehFeedComments")#", "rightcontent2", {feedID:'#feedID#'});
</script>
</cfoutput>
