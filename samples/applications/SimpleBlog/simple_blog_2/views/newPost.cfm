<cfform action="#event.buildLink('general.doNewPost')#" method="POST"	name="newPostForm" validate>
	<h1>New Post</h1>
	
	<p>Title:<br/>
	<cfinput name="title" type="text" required="true" validateat="onSubmit" maxlength="100" size="50" message="Please enter a title for your post." />
	
	<p><cftextarea name="entryBody" required="true" validateat="onSubmit" id="postField" message="You didn't write anything in your post!" richtext="yes" width="800" height="300"></cftextarea>
	
	<p>Author's Name:<br/>
	<cfinput type="text" name="author" required="true" validateat="onSubmit" size="50" message="Please enter your name">

	<p><input type="submit" value="Post It!">
</cfform>