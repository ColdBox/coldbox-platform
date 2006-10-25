<cfsetting enablecfoutputonly=true>
<!---
	Name         : message_edit.cfm
	Author       : Raymond Camden 
	Created      : July 6, 2004
	Last Updated : August 29, 2005
	History      : Removed mappings (rkc 8/29/05)
	Purpose		 : Allows moderators/admins to edit post.
--->

<cfoutput>
<p>
<table width="500" cellpadding="6" class="tableDisplay" cellspacing="1" border="0">
	<tr class="tableHeader">
		<td class="tableHeader">Edit Post</td>
	</tr>
	<cfif valueExists("posterrors")>
	<tr class="tableRowMain">
		<td>
		#getPlugin("messagebox").renderit()#
		</td>
	</tr>
	</cfif>
	<tr class="tableRowMain">
		<td>
		<form action="#cgi.script_name#" method="post">
		<input type="hidden" name="event" value="#getValue("xehMessagePost")#">
		<input type="hidden" name="id" value="#getvalue("id")#">
		<table>
			<tr>
				<td><b>Title: </b></td>
				<td><input type="text" name="post_title" value="#getValue("post_title")#" class="formBox" maxlength="50"></td>
			</tr>
			<tr>
				<td colspan="2"><b>Body: </b><br>
				<textarea name="body" cols="50" rows="20">#getValue("body")#</textarea></td>
			</tr>
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
