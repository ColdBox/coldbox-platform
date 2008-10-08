<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : addcomment.cfm
	Author       : Raymond Camden
	Created      : February 11, 2003
	Last Updated : April 7, 2006
	History      : Reset history for version 5.0
				 : Lengths allowed for name/email were 100, needed to be 50
	Purpose		 : Adds comments


--->
<!---
<cfif isDefined("url.delete") and isUserInRole("admin")>
	<cfset application.blog.deleteComment(url.delete)>
	<cfset comments = application.blog.getComments(url.id)>
</cfif>
--->

<cfset entry = Event.getValue("entry")>
<cfoutput>
<div class="date">#getResource("comments")#: #entry.title#</div>
<div class="body">
</cfoutput>

<cfif entry.allowcomments>
	<cfoutput><div class="date">#getResource("postyourcomments")#</div>
	#getPlugin("messagebox").renderit()#
	<form action="#application.rootURL#/index.cfm" method="post">
	<input type="hidden" value="#Event.getValue("xehAddComment")#" name="event">
	<input type="hidden" value="#Event.getValue("id")#" name="id">
	<fieldset class="sideBySide">
		<label for="name">#getResource("name")#:</label>
		<input type="text" id="name" name="name" value="#Event.getValue("name","")#">
	</fieldset>
	<fieldset class="sideBySide">
		<label for="email">#getResource("emailaddress")#:</label>
		<input type="text" id="email" name="email" value="#Event.getValue("email","")#">
	</fieldset>
	<fieldset class="sideBySide">
		<label for="website">#getResource("website")#:</label>
		<input type="text" id="website" name="website" value="#Event.getValue("website","")#">
	</fieldset>
	<fieldset>
		<label for="comments">#getResource("comments")#:</label>
		<textarea name="newcomments" id="newcomments" cols=50 rows=10>#Event.getValue("newcomments","")#</textarea>
	</fieldset>
	<cfif application.useCaptcha>
		<cfset variables.captcha = application.captcha.createHashReference() />
		<input type="hidden" name="captchaHash" value="#variables.captcha.hash#" />
		<fieldset class="sideBySide">
		<label for="captchaText">#getResource("captchatext")#:</label>
		<input type="text" name="captchaText" size="6" /><br>
		<img src="#application.blog.getRootURL()#tags/showCaptcha.cfm?hashReference=#variables.captcha.hash#" align="right" vspace="5"/>
		</fieldset>
	</cfif>
	<div style="CLEAR:BOTH"></div>
	<fieldset class="sideBySide">
		<label for="rememberMe">#getResource("remembermyinfo")#:</label>
		<input type="checkbox" class="checkBox" id="rememberMe" name="rememberMe" value="1" <cfif Event.getValue("rememberMe",false)>checked</cfif>>
	</fieldset>
	<fieldset class="sideBySide">
		<label for="subscribe">#getResource("subscribe")#:</label>
		<input type="checkbox" class="checkBox" id="subscribe" name="subscribe" value="1" <cfif Event.getValue("subscribe",false)>checked</cfif>>
	</fieldset>
	<p style="clear:both">#getResource("subscribetext")#</p>
	<fieldset class="formButtons">
		<input type="reset" id="reset" value="#getResource("cancel")#" onClick="window.close()">
		<input type="submit" id="submit" name="addcomment" value="#getResource("post")#">
	</fieldset>
	</form>
	</cfoutput>

<cfelse>

	<cfoutput>
	<p>#getResource("commentsnotallowed")#</p>
	</cfoutput>

</cfif>
</div>
