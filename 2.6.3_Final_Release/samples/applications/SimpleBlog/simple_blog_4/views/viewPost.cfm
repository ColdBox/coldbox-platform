<cfoutput>
	<div class="blogPost" id="singleEntry">
		<div class="title">#rc.oPost.getTitle()#</div>
	
		<div class="postBody">#rc.oPost.getEntryBody()#</div>
		<div class="author">Posted By: #rc.oPost.getauthor()#</div>
		<div class="date">#rc.oPost.gettime()#</div>
	
	
		<div class="postComments">
			<h3>Comments:</h3>
			
			
			<cfloop query="rc.comments">
				<div class="comment">
					<div class="commentBody">#comment#</div>
					<div class="commentTime">#time#</div>
				</div>
			</cfloop>
			<div><h3>Enter your comment:</h3></div>
			<form action="#Event.buildLink('general.doAddComment')#" method="POST">
				<textarea id="commentField" name="commentField" cols="40" rows="8"></textarea>
				<p><input name="submit" id="commentSubmitButton" type="submit" value="Submit Comment">
				<p><input type="hidden" id="id" name="ID" value="#rc.ID#">
			</form>
		</div>
	</div>
</cfoutput>

