<cfsetting enablecfoutputonly=true>
<!---
	Name         : messages_edit.cfm
	Author       : Raymond Camden 
	Created      : July 5, 2004
	Last Updated : August 27, 2005
	History      : 
	Purpose		 : 
--->
<cfset threads = getValue("threads")>
<cfset users = getValue("users")>
<cfoutput>
<p>
#getPlugin("messagebox").render()#
<form action="#cgi.script_name#?" method="post">
<input type="hidden" name="event" value="ehForums.doSaveMessages">
<input type="hidden" name="id" value="#getValue("id")#">
<table width="100%" cellspacing=0 cellpadding=5 class="adminEditTable">
	<tr valign="top">
		<td align="right"><b>Title:</b></td>
		<td><input type="text" name="title" value="#getvalue("title","")#" size="50"></td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Body:</b></td>
		<td>
		<textarea name="body" cols=50 rows=20>#getvalue("body","")#</textarea>
		</td>
	</tr>

	<tr valign="top">
		<td align="right"><b>Thread:</b></td>
		<td>
			<select name="threadidfk">
			<cfloop query="threads">
			<option value="#id#" <cfif getvalue("threadidfk","") is id>selected</cfif>>#name#</option>
			</cfloop>
			</select>
		</td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Posted:</b></td>
		<td><input type="text" name="posted" value="#getvalue("posted","")#" size="50"></td>
	</tr>
	<tr valign="top">
		<td align="right"><b>User:</b></td>
		<td>
			<select name="useridfk">
			<cfloop query="users">
			<option value="#id#" <cfif getvalue("useridfk","") is id>selected</cfif>>#username#</option>
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