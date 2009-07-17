<cfsetting enablecfoutputonly=true>
<!---
	Name         : message_edit.cfm
	Author       : Raymond Camden
	Created      : July 6, 2004
	Last Updated : November 14, 2006
	History      : Removed mappings (rkc 8/29/05)
				 : title+cfcatch change (rkc 8/4/06)
				 : attachment support (rkc 11/3/06)
				 : fix bug if attachments turned off (rkc 11/14/06)
	Purpose		 : Allows moderators/admins to edit post.
--->

<cfoutput>
<p>
<table width="500" cellpadding="6" class="tableDisplay" cellspacing="1" border="0">
	<tr class="tableHeader">
		<td class="tableHeader">Edit Post</td>
	</tr>
	<cfif Event.valueExists("posterrors")>
	<tr class="tableRowMain">
		<td>
		#getPlugin("messagebox").renderit()#
		</td>
	</tr>
	</cfif>
	<tr class="tableRowMain">
		<td>
		<form action="#cgi.script_name#" method="post" enctype="multipart/form-data">
		<input type="hidden" name="event" value="#Event.getValue("xehMessagePost")#">
		<input type="hidden" name="id" value="#Event.getValue("id")#">
		<table>
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
			<cfif isBoolean(request.forum.attachments) and request.forum.attachments>
				<tr valign="top">
					<td><b>Attach File:</b></td>
					<td>
					<input type="file" name="attachment">
					<cfif len(rc.oldattachment)>
					<input type="hidden" name="oldattachment" value="#rc.oldattachment#">
					<input type="hidden" name="filename" value="#rc.filename#">
					<br>
					File already attached: #rc.oldattachment#<br>
					<input type="checkbox" name="removefile"> Remove Attachment
					</cfif>
					</td>
				</tr>
			</cfif>
			<tr>
				<td>&nbsp;</td>
				<td align="right"><input type="image" src="images/btn_update.gif" alt="Update" title="Update" width="59" height="19" name="post"></td>
			</tr>
		</table>
		</form>
		</td>
	</tr>
</table>
</p>
</cfoutput>

<cfsetting enablecfoutputonly=false>
