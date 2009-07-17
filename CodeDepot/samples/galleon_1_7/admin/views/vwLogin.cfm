<cfsetting enablecfoutputonly=true>
<!---
	Name         : login.cfm
	Author       : Raymond Camden 
	Created      : June 01, 2004
	Last Updated : June 01, 2004
	History      : 
	Purpose		 : 
--->

<cfoutput>
<html>

<head>
<title>Galleon Forums Administrator Login</title>
<link rel=stylesheet type="text/css" href="../stylesheets/style.css">
</head>

<body bgcolor="##CCCCCC" onload="document.login.username.focus()">

<form action="#cgi.script_name#" method="post" name="login" id="login">
#getPlugin("messagebox").renderit()#
<input type="hidden" name="event" value="#Event.getValue("xehLogin")#">
<table height="400" width="100%" >
	<tr align="center" valign="middle"><td>
	
		<table width="400" class="tMain" cellpadding=6>
			<tr class="tHeader">
				<td colspan="2">Please Login</td>
			</tr>
			<tr>
				<td align="right"><b>username:</b></td>
				<td align="left"><input type="text" name="username" size="30"></td>
			</tr>
			<tr>
				<td align="right"><b>password:</b></td>
				<td align="left"><input type="password" name="password" size="30"></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td><input type="submit" name="logon" value="Login"></td>
			</tr>
		</table>
		
	</td></tr>
	
</table>
</form>

</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly=false>