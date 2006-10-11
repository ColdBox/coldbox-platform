<cfsetting enablecfoutputonly=true>
<!---
	Name         : newpost.cfm
	Author       : Raymond Camden 
	Created      : June 10, 2004
	Last Updated : August 27, 2005
	History      : Maxlength on title (rkc 8/30/04)
				   Support for UUID (rkc 1/27/05)
				   Now only does new threads (rkc 3/28/05)
				   Subscribe (rkc 7/29/05)
				   Refresh user cache on post (rkc 8/3/05)
				   Removed mappings (rkc 8/27/05)
	Purpose		 : Displays form to add a thread.
--->

<cfoutput>
<p>
<table width="500" cellpadding="6" class="tableDisplay" cellspacing="1" border="0">
	<tr class="tableHeader">
		<td class="tableHeader">New Post</td>
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
		<input type="hidden" name="event" value="#getValue("xehNewTopic")#">
		<input type="hidden" name="forumid" value="#getvalue("forumid")#">
		<table>
			<cfif not getValue("blockedAttempt")>
				<tr>
					<td><b>Title: </b></td>
					<td><input type="text" name="post_title" value="#getValue("post_title","")#" class="formBox" maxlength="50"></td>
				</tr>
				<tr>
					<td colspan="2"><b>Body: </b><br>
					<textarea name="body" cols="50" rows="20">#getValue("body","")#</textarea></td>
				</tr>
				<tr>
					<td><b>Subscribe to Thread: </b></td>
					<td><select name="subscribe">
					<option value="true" <cfif getValue("subscribe",true)>selected</cfif>>Yes</option>
					<option value="false" <cfif not getValue("subscribe",true)>selected</cfif>>No</option>
					</select></td>
				</tr>				
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
