<cfsetting enablecfoutputonly=true>
<!---
	Name         : threads_edit.cfm
	Author       : Raymond Camden 
	Created      : June 09, 2004
	Last Updated : August 27, 2005
	History      : Removed mappings, added sticky (rkc 8/27/05)
	Purpose		 : 
--->

<!--- get all forums --->
<cfset forums = Event.getValue("forums")>
<!--- get all users --->
<cfset users = Event.getValue("users")>

<cfoutput>
<p>
#getPlugin("messagebox").renderit()#
<form action="#cgi.script_name#?" method="post">
<input type="hidden" name="event" value="#Event.getValue("xehThreadsSave")#">
<input type="hidden" name="id" value="#Event.getValue("id")#">
<table width="100%" cellspacing=0 cellpadding=5 class="adminEditTable">
	<tr valign="top">
		<td align="right"><b>Name:</b></td>
		<td><input type="text" name="name" value="#Event.getValue("name","")#" size="100"></td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Forum:</b></td>
		<td>
			<select name="forumidfk">
			<cfloop query="forums">
			<option value="#id#" <cfif Event.getValue("forumidfk","") is id>selected</cfif>>#name#</option>
			</cfloop>
			</select>
		</td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Date Created:</b></td>
		<td><input type="text" name="datecreated" value="#Event.getValue("datecreated","")#" size="50"></td>
	</tr>
	<tr valign="top">
		<td align="right"><b>User:</b></td>
		<td>
			<select name="useridfk">
			<cfloop query="users">
			<option value="#id#" <cfif Event.getValue("useridfk","") is id>selected</cfif>>#username#</option>
			</cfloop>
			</select>
		</td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Read Only:</b></td>
		<td><select name="readonly">
		<option value="1" <cfif Event.getValue("readonly", false)>selected</cfif>>Yes</option>
		<option value="0" <cfif not Event.getValue("readonly",false)>selected</cfif>>No</option>
		</select></td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Active:</b></td>
		<td><select name="active">
		<option value="1" <cfif Event.getValue("active",false)>selected</cfif>>Yes</option>
		<option value="0" <cfif not Event.getValue("active",false)>selected</cfif>>No</option>
		</select></td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Sticky:</b></td>
		<td><select name="sticky">
		<option value="1" <cfif isBoolean(Event.getValue("sticky",false)) and Event.getValue("sticky",false)>selected</cfif>>Yes</option>
		<option value="0" <cfif (isBoolean(Event.getValue("sticky",false)) and not Event.getValue("sticky",false)) or not isBoolean(Event.getValue("sticky",false))>selected</cfif>>No</option>
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