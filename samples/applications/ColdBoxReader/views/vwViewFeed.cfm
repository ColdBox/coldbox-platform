<cfset feed = Context.getValue("feed","")>
<cfset feedID = Context.getValue("feedID",0)>

<cfoutput>
<a name="TOP"/>	
	
<!--- Reload Icon --->
<div style="float:right;margin-right:5px"><a href="##" onClick="doEvent('#Context.getValue("xehReload")#','centercontent',{feedID:'#feedID#'})" title="Refresh Panels"><img src="images/reload_icon.png" border="0" title="Refresh Panels"><a/></div>

<cfif not Context.getValue("myfeeds",false)>
<div><img src="images/orange_arrows_backwards.gif" align="absmiddle"><a href="javascript:doEvent('#Context.getValue("xehFeeds")#','centercontent',{})">Return To Feeds</a></div>
<cfelse>
<div><img src="images/orange_arrows_backwards.gif" align="absmiddle"><a href="javascript:doEvent('#Context.getValue("xehMyFeeds")#','centercontent',{})">Return To My Feeds</a></div>
</cfif>

<h1 style="margin-bottom:4px;border-bottom:1px solid black;padding-bottom:3px;">
	#feed.Title#
</h1>
<p>Click on the article titles to read them.</p>
<ul>
	<cfloop from="1" to="#ArrayLen(feed.items)#" index="i">
		<cfset thisLink = feed.items[i].link.xmlText>
		<cfset thisTitle = feed.items[i].title.xmlText>
		<cfset thisContent = "">
		<cfif StructKeyExists(feed.items[i],"content")>
			<cfset thisContent = feed.items[i].content.xmlText>
		</cfif>
		<cfif thisContent eq "" and StructKeyExists(feed.items[i],"description")>
			<cfset thisContent = feed.items[i].description.xmlText>
		</cfif>
		<cfset thisPubDate = "">
		<cfif StructKeyExists(feed.items[i],"pubDate")>
			<cfset thisPubDate = feed.items[i].pubDate.xmlText>
		</cfif>

		<cfset tmpID = "feed#i#">
		<li>
			<cfif thisContent neq "">
				<cfset tmpLinkRead = "javascript:viewContent('#tmpID#','#JSStringFormat(thisTitle)#')">
				<a href="#tmpLinkRead#"><b>#thisTitle#</b></a>

				<div id="#tmpID#" class="reader_panel" style="display: none;">			
					<!--- Close Item --->
					<div class="reader_floater">
					<cfif thisLink neq "">
					<img src="images/web_icon.gif" align="absmiddle" border="0">&nbsp;<a href="#thisLink#" target="_blank">Open Article</a>&nbsp;
					</cfif>
					<img src="images/orange_arrows_up.gif" align="absmiddle" border="0"><a href="##" onClick="javascript:viewContent('#tmpID#','#JSStringFormat(thisTitle)#')">Close Article</a>
					</div>
					<!--- Publish Date --->
					<div class="reader_toolbar">
						<div style="padding-top:10px;margin-left:5px"><b>Published On:</b> 
						<cfif isDate(thisPubDate)>
						#dateFormat(thisPubDate,"MMM DD, YYYY")# at #TimeFormat(thisPubDate,"hh:mm:ss tt")#
						<cfelse>
						#thisPubDate#
						</cfif>
						<br /><br />
					</div>	
					</div>
					
					<!--- Content --->					
					<div class="reader_content">#thisContent#
					<br><br>
					<img src="images/orange_arrows.gif" border=0 align="absmiddle"><a href="#thisLink#" target="_blank">Read More...</a>
					</div>			
				</div><br>
				
			<cfelse>
				<b>#thisTitle#</b>
				<cfif thisLink neq "">(<a href="#thisLink#" target="_blank">Link</a>)</cfif>
			</cfif>
		</li>
	</cfloop>
</ul>

<hr>

<cfif not Context.getValue("myfeeds",false)>
<!--- Return to feeds --->
<div><img src="images/orange_arrows_backwards.gif" align="absmiddle"><a href="javascript:doEvent('#Context.getValue("xehFeeds")#','centercontent',{})">Return To Feeds</a>
<cfelse>
<div><img src="images/orange_arrows_backwards.gif" align="absmiddle"><a href="javascript:doEvent('#Context.getValue("xehMyFeeds")#','centercontent',{})">Return To My Feeds</a></div>
</cfif>
</div>


<script>
	doEvent("#Context.getValue("xehFeedInfo")#", "leftcontent1", {feedID:'#feedID#'});
	doEvent("#Context.getValue("xehFeedTags")#", "rightcontent1", {feedID:'#feedID#'});
	//doEvent("#Context.getValue("xehFeedComments")#", "rightcontent2", {feedID:'#feedID#'});
</script>
</cfoutput>
