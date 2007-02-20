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


<cfset qGroups = requestContext.getValue("qGroups")>

<cfoutput>
<p>
#getPlugin("messagebox").renderit()#
<form action="#cgi.script_name#?" method="post">
<input type="hidden" name="event" value="#requestContext.getValue("xehUsersSave")#">
<input type="hidden" name="id" value="#requestContext.getValue("id")#">
<table width="100%" cellspacing=0 cellpadding=5 class="adminEditTable">
	<tr valign="top">
		<td align="right"><b>User Name:</b></td>
		<td>
			<cfif requestContext.getValue("id") is not "0">
				<input type="hidden" name="username" value="#requestContext.getValue("username","")#">#requestContext.getValue("username","")#
			<cfelse>
				<input type="text" name="username" value="#requestContext.getValue("username","")#" size="50"></td>
			</cfif>
		</td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Email Address:</b></td>
		<td><input type="text" name="emailaddress" value="#requestContext.getValue("emailaddress","")#" size="50"></td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Password:</b></td>
		<td><input type="text" name="password" value="#requestContext.getValue("password","")#" size="50"></td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Date Created:</b></td>
		<td><input type="text" name="datecreated" value="#requestContext.getValue("datecreated","")#" size="50"></td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Groups:</b></td>
		<td>
		<select name="groups" multiple size="3">
		<cfloop query="qGroups">
		<option value="#group#" <cfif listFindNoCase(requestContext.getValue("groups",""), group)>selected</cfif>>#group#</option>
		</cfloop>
		</select>
		</td>
	</tr>
	<cfif application.settings.requireconfirmation>
	<tr valign="top">
		<td align="right"><b>Confirmed:</b></td>	
		<td><select name="confirmed">
		<option value="0" <cfif not requestContext.getValue("confirmed")>selected</cfif>>No</option>
		<option value="1" <cfif requestContext.getValue("confirmed")>selected</cfif>>Yes</option>
		</select></td>
	</tr>
	</cfif>
	<tr>
		<td>&nbsp;</td>
		<td><input type="submit" name="save" value="Save"> <input type="submit" name="cancel" value="Cancel"></td>
	</tr>
</table>
</form>
</p>
</cfoutput>

<cfsetting enablecfoutputonly=false>