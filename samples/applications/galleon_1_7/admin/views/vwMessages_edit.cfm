<cfsetting enablecfoutputonly=true>
<!---
	Name         : messages_edit.cfm
	Author       : Raymond Camden 
	Created      : July 5, 2004
	Last Updated : August 27, 2005
	History      : 
	Purpose		 : 
--->
<cfset threads = requestContext.getValue("threads")>
<cfset users = requestContext.getValue("users")>
<cfoutput>
<p>
#getPlugin("messagebox").renderit()#
<form action="#cgi.script_name#?" method="post">
<input type="hidden" name="event" value="#requestContext.getValue("xehMessagesSave")#">
<input type="hidden" name="id" value="#requestContext.getValue("id")#">
<table width="100%" cellspacing=0 cellpadding=5 class="adminEditTable">
	<tr valign="top">
		<td align="right"><b>Title:</b></td>
		<td><input type="text" name="title" value="#requestContext.getValue("title","")#" size="100"></td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Body:</b></td>
		<td>
		<textarea name="body" cols=50 rows=20>#requestContext.getValue("body","")#</textarea>
		</td>
	</tr>
	<cfif requestContext.valueExists("attachment") and len(requestContext.getValue("attachment"))>
	<tr valign="top">
		<td align="right"><b>Attachment:</b></td>
		<td><a href="index.cfm?event=#requestContext.getValue("xehAttachment")#&id=#requestContext.getValue('id')#">#requestContext.getValue("attachment")#</a>
		<br><input type="checkbox" name="removefile">Remove File</a></td>
	</tr>
	</cfif>
	<tr valign="top">
		<td align="right"><b>Thread:</b></td>
		<td>
			<select name="threadidfk">
			<cfloop query="threads">
			<option value="#id#" <cfif requestContext.getValue("threadidfk","") is id>selected</cfif>>#name#</option>
			</cfloop>
			</select>
		</td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Posted:</b></td>
		<td><input type="text" name="posted" value="#requestContext.getValue("posted","")#" size="50"></td>
	</tr>
	<tr valign="top">
		<td align="right"><b>User:</b></td>
		<td>
			<select name="useridfk">
			<cfloop query="users">
			<option value="#id#" <cfif requestContext.getValue("useridfk","") is id>selected</cfif>>#username#</option>
			</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td><input type="submit" name="save" value="Save"> <input type="submit" name="cancel" value="Cancel"></td>
	</tr>
</table>
</form>
</p>
</cfoutput>

<cfsetting enablecfoutputonly=false>