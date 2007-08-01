<cfsetting enablecfoutputonly=true>
<!---
	Name         : newpost.cfm
	Author       : Raymond Camden 
	Created      : June 10, 2004
	Last Updated : November 6, 2006
	History      : Maxlength on title (rkc 8/30/04)
				   Support for UUID (rkc 1/27/05)
				   Now only does new threads (rkc 3/28/05)
				   Subscribe (rkc 7/29/05)
				   Refresh user cache on post (rkc 8/3/05)
				   Removed mappings (rkc 8/27/05)
				   Simple size change (rkc 7/27/06)				   
				   title fix (rkc 8/4/06)
				   attachment support (rkc 11/3/06)
				   error if attachments disabled (rkc 11/6/06)
	Purpose		 : Displays form to add a thread.
--->

<cfoutput>
<p>
<table width="500" cellpadding="6" class="tableDisplay" cellspacing="1" border="0">
	<tr class="tableHeader">
		<td class="tableHeader">New Post</td>
	</tr>
	<cfif Event.valueExists("posterrors") or not getPlugin("messagebox").isEmpty()>
	<tr class="tableRowMain">
		<td>
		#getPlugin("messagebox").renderit()#
		</td>
	</tr>
	</cfif>
	<tr class="tableRowMain">
		<td>
		<form action="#cgi.script_name#" method="post" enctype="multipart/form-data">
		<input type="hidden" name="event" value="#Event.getValue("xehNewTopic")#">
		<input type="hidden" name="forumid" value="#Event.getValue("forumid")#">
		<table>
			<cfif not Event.getValue("blockedAttempt")>
				<tr>
					<td><b>Title: </b></td>
					<td><input type="text" name="post_title" value="#Event.getValue("post_title")#" class="formBox"></td>
				</tr>
				<tr>
					<td colspan="2"><b>Body: </b><br>
					<p>
					#application.message.renderHelp()#
					</p>
					<textarea name="body" cols="50" rows="20">#Event.getValue("body")#</textarea></td>
				</tr>
				<tr>
					<td><b>Subscribe to Thread: </b></td>
					<td><select name="subscribe">
					<option value="true" <cfif Event.getValue("subscribe")>selected</cfif>>Yes</option>
					<option value="false" <cfif not Event.getValue("subscribe")>selected</cfif>>No</option>
					</select></td>
				</tr>	
				<cfif isBoolean(request.forum.attachments) and request.forum.attachments>
				<tr>
					<td><b>Attach File:</b></td>
					<td>
					<input type="file" name="attachment">
					<cfif len(rc.oldattachment)>
					<input type="hidden" name="oldattachment" value="#rc.oldattachment#">
					<input type="hidden" name="filename" value="#rc.filename#">
					<br>
					File already attached: #rc.oldattachment#
					</cfif>
					</td>
				</tr>
				</cfif>			
				<tr>
					<td>&nbsp;</td>
					<td align="right"><input type="image" src="images/btn_new_topic.gif" alt="New Topic" title="New Topic" width="71" height="19" name="post"></td>
				</tr>
			<cfelse>
				<tr>
					<td><b>Sorry, but this area is readonly.</b></td>
				</tr>
			</cfif>
		</table>
		</form>
		</td>
	</tr>
</table>
</p>
</cfoutput>

<cfsetting enablecfoutputonly=false>
