<cfsetting enablecfoutputonly=true>
<!---
	Name         : forums_edit.cfm
	Author       : Raymond Camden 
	Created      : June 01, 2004
	Last Updated : August 27, 2005
	History      : Removed mappings (rkc 8/27/05)
	Purpose		 : 
--->

<!--- get all conferences --->
<cfset conferences = requestContext.getValue("conferences")>

<cfoutput>
<p>
#getPlugin("messagebox").renderit()#
<form action="#cgi.script_name#?" method="post">
<input type="hidden" name="event" value="#requestContext.getValue("xehForumsSave")#">
<input type="hidden" name="id" value="#requestContext.getValue("id")#">
<table width="100%" cellspacing=0 cellpadding=5 class="adminEditTable">
	<tr valign="top">
		<td align="right"><b>Name:</b></td>
		<td><input type="text" name="name" value="#requestContext.getValue("name","")#" size="100"></td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Conference:</b></td>
		<td>
			<select name="conferenceidfk">
			<cfloop query="conferences">
			<option value="#id#" <cfif requestContext.getValue("conferenceidfk","") is id>selected</cfif>>#name#</option>
			</cfloop>
			</select>
		</td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Description:</b></td>
		<td><textarea name="description" rows=6 cols=35 wrap="soft">#requestContext.getValue("description","")#</textarea></td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Read Only:</b></td>
		<td><select name="readonly">
		<option value="1" <cfif requestContext.getValue("readonly")>selected</cfif>>Yes</option>
		<option value="0" <cfif not requestContext.getValue("readonly")>selected</cfif>>No</option>
		</select></td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Active:</b></td>
		<td><select name="active">
		<option value="1" <cfif requestContext.getValue("active")>selected</cfif>>Yes</option>
		<option value="0" <cfif not requestContext.getValue("active")>selected</cfif>>No</option>
		</select></td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Attachments:</b></td>
		<td><select name="attachments">
		<option value="1" <cfif isBoolean(requestContext.getValue("attachments")) and requestContext.getValue("attachments")>selected</cfif>>Yes</option>
		<option value="0" <cfif (isBoolean(requestContext.getValue("attachments")) and not requestContext.getValue("attachments")) or requestContext.getValue("attachments") is "">selected</cfif>>No</option>
		</select></td>
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