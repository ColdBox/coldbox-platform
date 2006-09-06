<cfset feed = getValue("feed","")>
<cfset feedID = getValue("feedID",0)>

<cfoutput>

<p><img src="images/return.gif"><a href="javascript:doEvent('#getValue("xehFeeds")#','centercontent',{})">Return To Feeds</a></p>

<cfif feed.Image.URL neq "">
	<a href="#feed.Image.Link#">
		<img src="#feed.Image.URL#" border="0" id="RSS_Image"
				title="#feed.Image.Title#"
				alt="#feed.Image.Title#" /></a>
</cfif>

<h2 style="margin-bottom:4px;border-bottom:1px solid black;padding-bottom:3px;">
	<a href="#feed.Link#" target="_blank" id="RSS_Title" style="font-size:16px;font-weight:bold;">#feed.Title#</a>
</h2>

<ul style="margin:0px; padding-left:10px;">
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
				<cfif thisLink neq "">(<a href="#thisLink#" target="_blank">Link</a>)</cfif>
				<div id="#tmpID#" style="display:none;border:1px solid ##cccccc;background-color:##EAEEED;padding:4px;margin-top:5px;">
					#thisContent#
					<br><br>
					<span style="font-size:9px;">#thisPubDate#</span>&nbsp;&nbsp;
					<a href="#thisLink#" target="_blank">Read More...</a>
				</div><br>
			<cfelse>
				<b>#thisTitle#</b>
				<cfif thisLink neq "">(<a href="#thisLink#" target="_blank">Link</a>)</cfif>
			</cfif>
		</li>
	</cfloop>
</ul>

<script>
	doEvent("#getValue("xehFeedInfo")#", "leftcontent1", {feedID:'#feedID#'});
	doEvent("#getValue("xehFeedTags")#", "rightcontent1", {feedID:'#feedID#'});
	doEvent("#getValue("xehFeedComments")#", "rightcontent2", {feedID:'#feedID#'});
</script>
</cfoutput>
