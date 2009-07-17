<cfparam name="username" default="">
<cfparam name="password" default="">

<cfoutput>
	<h1>Login To Your ColdBox Reader Account</h1>
<form name="frm" method="post" action="javascript:doFormEvent('#Event.getValue("xehLogin")#','centercontent',document.frm)">
	<p>
		Sign in to your account to add new feeds and tag existing feeds.
	</p>
	<table>
		<tr>
			<td><b>Username:</b></td>
			<td><input type="text" name="username" value="#username#" size="20" /></td>
		</tr>
		<tr>
			<td><b>Password:</b></td>
			<td><input type="password" name="password" value="#password#" size="20" /></td>
		</tr>
		<tr><td colspan="2">&nbsp;</td></tr>
		<tr>
			<td>&nbsp;</td>
			<td>
				<input type="button" value="Go Back" onClick="document.location='index.cfm'" />
				<input type="submit" value="Log In" />
			</td>
		</tr>
	</table>
</form>
</cfoutput>