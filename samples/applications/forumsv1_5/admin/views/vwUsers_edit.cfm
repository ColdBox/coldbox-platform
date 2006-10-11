<cfsetting enablecfoutputonly=true>
<!---
	Name         : users_edit.cfm
	Author       : Raymond Camden 
	Created      : July 5, 2004
	Last Updated : August 27, 2005
	History      : Fixed bugs related to sendnotifications change (rkc 8/3/05)
				   Removed mappings (rkc 8/27/05)
	Purpose		 : 
--->


<cfset qGroups = getValue("qGroups")>

<cfoutput>
<p>
#getPlugin("messagebox").renderit()#
<form action="#cgi.script_name#?" method="post">
<input type="hidden" name="event" value="#getValue("xehUsersSave")#">
<input type="hidden" name="id" value="#getValue("id")#">
<table width="100%" cellspacing=0 cellpadding=5 class="adminEditTable">
	<tr valign="top">
		<td align="right"><b>User Name:</b></td>
		<td>
			<cfif getValue("id") is not "0">
				<input type="hidden" name="username" value="#getValue("username","")#">#getValue("username","")#
			<cfelse>
				<input type="text" name="username" value="#getValue("username","")#" size="50"></td>
			</cfif>
		</td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Email Address:</b></td>
		<td><input type="text" name="emailaddress" value="#getValue("emailaddress","")#" size="50"></td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Password:</b></td>
		<td><input type="text" name="password" value="#getValue("password","")#" size="50"></td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Date Created:</b></td>
		<td><input type="text" name="datecreated" value="#getValue("datecreated","")#" size="50"></td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Groups:</b></td>
		<td>
		<select name="groups" multiple size="3">
		<cfloop query="qGroups">
		<option value="#group#" <cfif listFindNoCase(getValue("groups",""), group)>selected</cfif>>#group#</option>
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