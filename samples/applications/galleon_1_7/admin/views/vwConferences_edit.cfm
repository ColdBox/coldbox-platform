<cfsetting enablecfoutputonly=true>
<!---
	Name         : conferences_edit.cfm
	Author       : Raymond Camden 
	Created      : June 01, 2004
	Last Updated : August 27, 2005
	History      : Removed mappings (rkc 8/27/05)
	Purpose		 : 
--->
<cfoutput>
<p>
#getPlugin("messagebox").renderit()#
<form action="#cgi.script_name#?" method="post">
<input type="hidden" name="event" value="#Event.getValue("xehSaveConference")#">
<input type="hidden" name="id" value="#Event.getValue("id")#">
<table width="100%" cellspacing=0 cellpadding=5 class="adminEditTable">
	<tr valign="top">
		<td align="right"><b>Name:</b></td>
		<td><input type="text" name="name" value="#Event.getValue("name","")#" size="100"></td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Description:</b></td>
		<td><textarea name="description" rows=6 cols=35 wrap="soft">#Event.getValue("description","")#</textarea></td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Active:</b></td>
		<td><select name="active">
		<option value="1" <cfif Event.getValue("active","No")>selected</cfif>>Yes</option>
		<option value="0" <cfif not Event.getValue("active","No")>selected</cfif>>No</option>
		</select></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td><input type="submit" name="save" value="Save"> 
		    <input type="submit" name="cancel" value="Cancel"></td>
	</tr>
</table>
</form>
</p>
</cfoutput>

<cfsetting enablecfoutputonly=false>