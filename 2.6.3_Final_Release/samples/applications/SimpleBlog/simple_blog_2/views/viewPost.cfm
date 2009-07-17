<cfoutput>
	<div class="blogPost">
		<div class="title">#rc.oPost.getTitle()#</div>
	
		<div class="postBody">#rc.oPost.getEntryBody()#</div>
		<div class="author">Posted By: #rc.oPost.getauthor()#</div>
		<div class="date">#rc.oPost.gettime()#</div>
	
	
		<div class="postComments">
			<h3>Comments:</h3>
			
			
			<cfloop query="rc.comments">
				<div class="comment">
					<div class="commentBody">#comment#</div>
					<div class="commentTime">#dateFormat(time,"medium")# #timeFormat(time,"short")#</div>
				</div>
			</cfloop>
			<div><h3>Enter your comment:</h3></div>
			<cfform action="#Event.buildLink('general.doAddComment')#" method="POST">
				<cftextarea name="commentField" cols="40" rows="8"></cftextarea>
				<p><cfinput name="submit" type="submit" value="Submit Comment">
				<p><input type="hidden" name="ID" value="#rc.ID#">
			</cfform>
		</div>
	</div>
</cfoutput>

