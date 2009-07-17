<cfoutput>
	<h1>Blog</h1>
	
	<a href="#event.buildLink('general.newPost')#">Compose New Post</a>
	
	<cfloop query="rc.posts">
		<div class="blogPost">
			<div class="title"><a href="#event.buildLink('general/viewPost/' & entry_id)#">#rc.posts.title#</a></div>
			<div class="postBody">#entryBody#</div>
			<div class="author">Posted By: #author#</div>
			<div class="date">#dateFormat(time,"medium")# #timeFormat(time,"short")#</div>
			<div class="commentLink"><a href="#event.buildLink('general/viewPost/' & entry_id)#">Leave a Comment</a></div>
		</div>
	</cfloop>
</cfoutput>

