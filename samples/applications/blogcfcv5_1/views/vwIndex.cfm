<cfmodule template="../tags/scopecache.cfm" cachename="#application.applicationname#" scope="application" disabled="#getvalue("disabled")#" timeout="#application.timeout#">

<!--- Reference to Articles --->
<cfset articles = getValue("articles")>

<cfset lastDate = "">
<cfset allowTB = application.blog.getProperty("allowtrackbacks")>
<cfset maxEntries = application.blog.getProperty("maxEntries") />
<cfoutput query="articles" startrow="#getValue("startrow")#" maxrows="#maxEntries#">
	<div class="entry<cfif articles.currentRow EQ articles.recordCount>Last</cfif>">
	<cfif allowTB>
		<!--- output this rdf for auto discovery of trackback links --->
		<!--
		<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns##"
             xmlns:dc="http://purl.org/dc/elements/1.1/"
             xmlns:trackback="http://madskills.com/public/xml/rss/module/trackback/">
	    <rdf:Description
	        rdf:about="#application.blog.makeLink(id)#"
	        dc:identifier="#application.blog.makeLink(id)#"
	        dc:title="#title#"
	        trackback:ping="#application.rooturl#/?event=ehBlog.dspTrackback&id=#id#" />
	    </rdf:RDF>
		-->
	</cfif>

	<h1><a href="#application.blog.makeLink(id)#">#title#</a></h1>

	<div class="byline">#getResource("postedat")# : #application.localeUtils.dateLocaleFormat(posted)# #application.localeUtils.timeLocaleFormat(posted)#
	<cfif len(name)>| #getResource("postedby")# : #name#</cfif><br />
	#getResource("relatedcategories")#:
	<cfloop index="x" from=1 to="#listLen(categoryNames)#">
	<a href="#application.blog.makeCategoryLink(listGetAt(categoryIDs,x))#">#listGetAt(categoryNames,x)#</a><cfif x is not listLen(categoryNames)>,</cfif>
	</cfloop>
	</div>

	<div class="body">
	#application.blog.renderEntry(body,false,enclosure)#
	<cfif len(morebody) and getValue("mode") is not "entry">
	<p align="right">
	<a href="#application.blog.makeLink(id)###more">[#getResource("more")#]</a>
	</p>
	<cfelse>
	<span id="more"></span>
	#application.blog.renderEntry(morebody)#
	</cfif>

	</div>

	<div class="byline">
	<cfif allowcomments or commentCount neq ""><a href="#application.blog.makeLink(id)###comments">#getResource("comments")# (<cfif commentCount is "">0<cfelse>#commentCount#</cfif>)</a> | </cfif>
	<cfif allowTB><a href="#application.blog.makeLink(id)###trackbacks">Trackbacks (<cfif trackbackCount is "">0<cfelse>#trackbackCount#</cfif>)</a> | </cfif>
	<cfif application.isColdFusionMX7><a href="#application.rooturl#/?event=ehBlog.dspPrint&id=#id#" rel="nofollow">#getResource("print")#</a> | </cfif>
	<a href="#application.rooturl#/?event=ehBlog.dspSend&id=#id#" rel="nofollow">#getResource("send")#</a> |
	<cfif len(enclosure)><a href="#application.rooturl#/enclosures/#urlEncodedFormat(getFileFromPath(enclosure))#">#getResource("download")#</a> | </cfif>
    <!--- RBB 11/02/2005: Added del.icio.us and Technorati links --->
   	<a href="http://del.icio.us/post?url=#application.blog.makeLink(id)#&title=#URLEncodedFormat("#application.blog.getProperty('blogTitle')#:#title#")#">del.icio.us</a>
    | <a href="http://www.technorati.com/cosmos/links.html?url=#application.blog.makeLink(id)#">#getResource("linkingblogs")#</a>
	</div>

	<cfif articles.recordCount is 1>

		<cfset qRelatedBlogEntries = application.blog.getRelatedBlogEntries(entryId=id,bDislayFutureLinks=true) />

		<cfif qRelatedBlogEntries.recordCount>
			<div id="relatedentries">
			<p>
			<div class="relatedentriesHeader">#getResource("relatedblogentries")#</div>
			</p>

 				<ul id="relatedEntriesList">
			<cfloop query="qRelatedBlogEntries">
			<li><a href="#application.blog.makeLink(entryId=qRelatedBlogEntries.id)#">#qRelatedBlogEntries.title#</a> (#application.localeUtils.dateLocaleFormat(posted)#)</li>
			</cfloop>
	  		</ul>
	  		</div>
		</cfif>

		<cfif allowTB>
			<cfset trackbacks = application.blog.getTrackBacks(id)>
			<div id="trackbacks">
			<div class="trackbackHeader">TrackBacks</div>

			<cfif trackbacks.recordCount>

				<cfoutput>
				<div class="trackbackBody addTrackbackLink">
				[<a href="javaScript:launchTrackback('#id#')">#getResource("addtrackback")#</a>]
				</div>
				</cfoutput>

				<cfloop query="trackbacks">
					<div class="trackback<cfif currentRow mod 2>Alt</cfif>">
					<div class="trackbackBody">
					<a href="#postURL#" target="_new" rel="nofollow" class="tbLink">#title#</a><br>
					#paragraphFormat2(excerpt)#
					</div>
					<div class="trackbackByLine">#getResource("trackedby")# #blogname# | #getResource("trackedon")# #application.localeUtils.dateLocaleFormat(created,"short")# #application.localeUtils.timeLocaleFormat(created)#</div>
					</div>
				</cfloop>
			<cfelse>
			<div class="body">#getResource("notrackbacks")#</div>
			</cfif>
			<p>
			<div class="body">
			#getResource("trackbackurl")#<br>
			#application.rooturl#/?event=ehBlog.dspTrackback&#id#
			</div>
			</p>
			<div class="trackbackBody addTrackbackLink">
				[<a href="javaScript:launchTrackback('#id#')">#getResource("addtrackback")#</a>]
			</div>
			</div>
		</cfif>
		<div id="comments">
		<div class="commentHeader">#getResource("comments")#</div>
		<cfset comments = application.blog.getComments(id)>
		<cfif comments.recordCount>

			<cfif allowComments>
				<cfoutput>
				<div class="trackbackBody addCommentLink">
				[<a href="javaScript:launchComment('#id#')">#getResource("addcomment")#</a>]
				</div>
				</cfoutput>
			</cfif>

			<cfset entryid = id>
			<cfloop query="comments">
			<div id="c#id#" class="comment<cfif currentRow mod 2>Alt</cfif>">
				<div class="commentBody">#paragraphFormat2(replaceLinks(comment))#</div>
				<div class="commentByLine">
				<a href="#application.blog.makeLink(entryid)###c#id#">##</a> #getResource("postedby")# <cfif len(comments.website)><a href="#comments.website#" rel="nofollow">#name#</a><cfelse>#name#</cfif>
				| #application.localeUtils.dateLocaleFormat(posted,"short")# #application.localeUtils.timeLocaleFormat(posted)#
				</div>
			</div>
			</cfloop>

			<cfif allowComments>
				<cfoutput>
				<div class="trackbackBody addCommentLink">
				[<a href="javaScript:launchComment('#id#')">#getResource("addcomment")#</a>]
				</div>
				</cfoutput>
			</cfif>

		<cfelseif not allowcomments>
			<div class="body">#getResource("commentsnotallowed")#</div>
		<cfelse>
			<div class="trackbackBody addCommentLink">
         <p style="text-align:left">#getResource("nocomments")#</p>
			[<a href="javaScript:launchComment('#id#')">#getResource("addcomment")#</a>]
			</div>
		</cfif>
</div>
	</cfif>
</div>
</cfoutput>

<cfif articles.recordCount is 0>

	<cfoutput><div class="body">#getResource("sorry")#</div></cfoutput>
	<div class="body">
	<cfif getValue("mode") is "">
		<cfoutput>#getResource("noentries")#</cfoutput>
	<cfelse>
		<cfoutput>#getResource("noentriesforcriteria")#</cfoutput>
	</cfif>
	</div>

<cfelseif articles.recordCount gt getValue("startRow") + application.maxEntries>

	<!--- get path if not /index.cfm --->
	<cfset path = replace(cgi.path_info, "/index.cfm", "")>

	<!--- clean out startrow from query string --->
	<cfset qs = cgi.query_string>
	<cfset qs = reReplaceNoCase(qs, "&*startrow=[0-9]+", "")>
	<cfset qs = qs & "&startRow=" & ( getValue("startRow") + application.maxEntries)>

	<cfif valueExists("search") and len(trim(getvalue("search")))>
		<cfset qs = qs & "&search=#htmlEditFormat(getValue("search"))#">
	</cfif>

	<cfoutput>
	<p align="right">
	<a href="#application.rooturl#/index.cfm#path#?#qs#">#getResource("moreentries")#</a>
	</p>
	</cfoutput>

</cfif>

</cfmodule>
