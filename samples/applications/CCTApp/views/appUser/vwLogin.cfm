<cfoutput>
<form name="loginform" action="#cgi.SCRIPT_NAME#" method="post">
<input type="hidden" name="event" value="ehAppUser.doLogin">
<table align="center" cellpadding="0" cellspacing="0">
<!--- ColdBox messages box if errors --->
<cfif not getPlugin("messagebox").isEmpty()>
	<tr>
		<td>#getPlugin("messagebox").renderit()#<br /></td>
	</tr>
</cfif>
<!--- Login Form --->
<tr>
	<td>
		<table cellpadding="2" cellspacing="0" border="0" class="formTable" align="center">
		<tr>
			<td colspan="2" class="formHeader">
				<strong>LOGIN</strong>
			</td>
		</tr>
		<tr>
			<td><strong>Username:</strong></td>
			<td><input name="username" type="text" id="username" value="#Event.getValue("username","")#"></td>
		</tr>
		<tr>
			<td><strong>Password:</strong></td>
			<td><input name="password" type="password" id="password" /></td>
		</tr>
		<tr class="formFooter">
			<td colspan="2" align="right"><input type="submit" name="Submit" value="Login" /></td>
		</tr>
		</table>
	</td>
</tr>
</table>
</form>
</cfoutput>