<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : Stats
	Author       : Raymond Camden 
	Created      : November 19, 2004
	Last Updated : May 17, 2006
	History      : reset for 5.0
				 : gettopviews didnt filter by blog. gettotalviews added (rkc 7/17/06)
	Purpose		 : Stats
--->
	<!--- References --->
	<cfset getTotalEntries = Event.getValue("getTotalEntries")>
	<cfset getTotalSubscribers = Event.getValue("getTotalSubscribers")>
	<cfset getTotalViews = Event.getValue("getTotalViews")>
	<cfset getTopViews = Event.getValue("getTopViews")>
	<cfset last30 = Event.getValue("last30")>
	<cfset getTotalComments = Event.getValue("getTotalComments")>
	<cfset getTotalTrackbacks = Event.getValue("getTotalTrackbacks")>
	<cfset getCategoryCount = Event.getValue("getCategoryCount")>
	<cfset topCommentedEntries = Event.getValue("topCommentedEntries")>
	<cfset topCommentedCategories = Event.getValue("topCommentedCategories")>
	<cfset topTrackbackedEntries = Event.getValue("topTrackbackedEntries")>
	<cfset topSearchTerms = Event.getValue("topSearchTerms")>
	
	<cfset averageCommentsPerEntry = 0>	
	<cfif getTotalEntries.totalEntries>
		<cfset dur = dateDiff("d",getTotalEntries.firstEntry, now())>
		<cfset averageCommentsPerEntry = getTotalComments.totalComments / getTotalEntries.totalEntries>
	</cfif>
	
	<cfoutput>
	<div class="date"><b>#getResource("contents")#</b></div>
	<div class="body">
	<a href="##generalstats">#getResource("generalstats")#</a><br>
	<a href="##topviews">#getResource("topviews")#</a><br>
	<a href="##categorystats">#getResource("categorystats")#</a><br>
	<a href="##topentriesbycomments">#getResource("topentriesbycomments")#</a><br>
	<a href="##topcategoriesbycomments">#getResource("topcategoriesbycomments")#</a><br>
	<cfif application.blog.getProperty("allowtrackbacks")><a href="##topentriesbytrackbacks">#getResource("topentriesbytrackbacks")#</a><br></cfif>
	<a href="##topsearchterms">#getResource("topsearchterms")#</a><br>
	</div>
	
	<p />
	
	<div class="date"><a name="generalstats"></a><b>#getResource("generalstats")#</b></div>
	<div class="body">
	<table border="1" width="100%">
		<tr>
			<td><b>#getResource("totalnumentries")#:</b></td>
			<td>#getTotalEntries.totalEntries#</td>
		</tr>
		<tr>
			<td><b>#getResource("last30")#:</b></td>
			<td>#last30.totalEntries#</td>
		</tr>
		<tr>
			<td><b>#getResource("last30avg")#:</b></td>
			<td><cfif last30.totalentries gt 0>#numberFormat(last30.totalEntries/30,"999.99")#<cfelse>&nbsp;</cfif></td>
		</tr>				
		<tr>
			<td><b>#getResource("firstentry")#:</b></td>
			<td><cfif len(getTotalEntries.firstEntry)>#dateFormat(getTotalEntries.firstEntry,"mm/dd/yy")#<cfelse>&nbsp;</cfif></td>
		</tr>
		<tr>
			<td><b>#getResource("lastentry")#:</b></td>
			<td><cfif len(getTotalEntries.lastEntry)>#dateFormat(getTotalEntries.lastEntry,"mm/dd/yy")#<cfelse>&nbsp;</cfif></td>
		</tr>
		<tr>
			<td><b>#getResource("bloggingfor")#:</b></td>
			<td><cfif isDefined("dur")>#dur# #getResource("days")#<cfelse>&nbsp;</cfif></td>
		</tr>
		<tr>
			<td><b>#getResource("totalcomments")#:</b></td>
			<td>#getTotalComments.totalComments#</td>
		</tr>
		<tr>
			<td><b>#getResource("avgcommentsperentry")#:</b></td>
			<td>#numberFormat(averageCommentsPerEntry,"999.99")#</td>
		</tr>
		<cfif application.blog.getProperty("allowtrackbacks")>
		<!--- RBB: 1/20/06: Added total trackbacks --->
		<tr>
			<td><b>#getResource("totaltrackbacks")#:</b></td>
			<td>#getTotalTrackbacks.totalTrackbacks#</td>
		</tr>		
		</cfif>
		<tr>
			<td><b>#getResource("totalviews")#:</b></td>
			<td>#getTotalViews.total#</td>
		</tr>
		<tr>
			<td><b>#getResource("totalsubscribers")#:</b></td>
			<td>#getTotalSubscribers.totalsubscribers#</td>
		</tr>
		
	</table>
	</div>

	<p />
	
	<div class="date"><a name="topviews"></a><b>#getResource("topviews")#</b></div>
	<div class="body">
	<table border="1" width="100%">
		<cfloop query="getTopViews">
		<tr>
			<td><b><a href="#application.blog.makeLink(id)#" rel="nofollow">#title#</a></b></td>
			<td>#views#</td>
		</tr>
		</cfloop>
	</table>
	</div>
	
	<p />
	
	<div class="date"><a name="categorystats"></a><b>#getResource("categorystats")#</b></div>
	<div class="body">
	<table border="1" width="100%">
		<cfloop query="getCategoryCount">
		<tr>
			<td>#categoryname#</td>
			<td>#total#</td>
		</tr>
		</cfloop>
	</table>
	</div>
	
	<p />
	
	<div class="date"><a name="topentriesbycomments"></a><b>#getResource("topentriesbycomments")#</b></div>
	<div class="body">
	<table border="1" width="100%">
		<cfloop query="topCommentedEntries">
		<tr>
			<td><b><a href="#application.blog.makeLink(id)#" rel="nofollow">#title#</a></b></td>
			<td>#commentCount#</td>
		</tr>
		</cfloop>
	</table>
	</div>
	
	<p />
	
	<div class="date"><a name="topcategoriesbycomments"></a><b>#getResource("topcategoriesbycomments")#</b></div>
	<div class="body">
	<table border="1" width="100%">
		<cfloop query="topCommentedCategories">
			<!--- 
				This is ugly code.
				I want to find the avg number of posts
				per entry for this category.
			--->
			<cfquery name="getTotalForThisCat" dbtype="query">
				select	total
				from	getCategoryCount
				where	categoryid = '#categoryid#'
			</cfquery>
			<cfset avg = commentCount / getTotalForThisCat.total>
			<cfset avg = numberFormat(avg,"___.___")>
			<tr>
				<td><b><a href="index.cfm?mode=cat&catid=#categoryid#" rel="nofollow">#categoryname#</a></b></td>
				<td>#commentCount# (#getResource("avgcommentperentry")#: #avg#)</td>
			</tr>
		</cfloop>
	</table>
	</div>

	<p />
	
	<cfif application.blog.getProperty("allowtrackbacks")>
	<!--- RBB 1/20/2006: Added top entriex by trackbacks --->
	<div class="date"><a name="topentriesbytrackbacks"></a><b>#getResource("topentriesbytrackbacks")#</b></div>
	<div class="body">
	<table border="1" width="100%">
		<cfloop query="topTrackbackedEntries">
		<tr>
			<td><b><a href="#application.blog.makeLink(id)#" rel="nofollow">#title#</a></b></td>
			<td>#trackbackCount#</td>
		</tr>
		</cfloop>
	</table>
	</div>
	
	<p />
	</cfif>
	
	<div class="date"><a name="topsearchterms"></a><b>#getResource("topsearchterms")#</b></div>
	<div class="body">
	<table border="1" width="100%">
		<cfloop query="topSearchTerms">
		<tr>
			<td><b><a href="#application.rooturl#/index.cfm?mode=search&search=#urlEncodedFormat(searchterm)#" rel="nofollow">#searchterm#</a></b></td>
			<td>#total#</td>
		</tr>
		</cfloop>
	</table>
	</div>
	
	</cfoutput>


<cfsetting enablecfoutputonly=false>