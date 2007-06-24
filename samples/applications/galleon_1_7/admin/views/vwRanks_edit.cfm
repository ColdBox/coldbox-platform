<cfsetting enablecfoutputonly=true>
<!---
	Name         : ranks_edit.cfm
	Author       : Raymond Camden 
	Created      : August 28, 2005
	Last Updated : 
	History      : 
	Purpose		 : 
--->

<cfoutput>
<p>
#getPlugin("messagebox").renderit()#
<form action="#cgi.script_name#?" method="post">
<input type="hidden" name="event" value="#Event.getValue("xehRanksSave")#">
<input type="hidden" name="id" value="#Event.getValue("id")#">
<table width="100%" cellspacing=0 cellpadding=5 class="adminEditTable">
	<tr valign="top">
		<td align="right"><b>Name:</b></td>
		<td><input type="text" name="name" value="#Event.getValue("name","")#" size="50"></td>
	</tr>
	<tr valign="top">
		<td align="right"><b>Minimum Number of Posts:</b></td>
		<td><input type="text" name="minposts" value="#Event.getValue("minposts","")#" size="50"></td>
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