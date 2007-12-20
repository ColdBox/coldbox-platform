<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : C:\projects\blogcfc5\client\admin\login.cfm
	Author       : Raymond Camden 
	Created      : 04/13/06
	Last Updated : 
	History      : 
--->
<cfoutput>
<form action="#cgi.script_name#?#Event.getValue("qs")#" method="post">
<!--- copy additional fields --->
<cfloop item="field" collection="#form#">
	<!--- the isSimpleValue is probably a bit much.... --->
	<cfif not listFindNoCase("username,password", field) and isSimpleValue(form[field])>
		<input type="hidden" name="#field#" value="#htmleditformat(form[field])#">
	</cfif>
</cfloop>
<table>
	<tr>
		<td><b>#getResource("username")#</b></td>
		<td><input type="text" name="username"></td>
	</tr>
	<tr>
		<td><b>#getResource("password")#</b></td>
		<td><input type="password" name="password"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td><input type="submit" value="#getResource("login")#"></td>
	</tr>
</table>
</form>

<script language="javaScript" TYPE="text/javascript">
<!--
document.forms[0].username.focus();
//-->
</script>
</cfoutput>

<cfsetting enablecfoutputonly=false>