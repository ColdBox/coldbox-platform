<cfparam name="username" default="">
<cfparam name="password" default="">
<cfparam name="password2" default="">
<cfparam name="email" default="">

<cfoutput>
<form name="frm" method="post" action="javascript:doFormEvent('ehUser.doCreateAccount','centercontent',document.frm)">
	<p>
		Creating an account allows you to add new feeds and tag existing feeds.
	</p>
	<table>
		<tr>
			<td><b>Username:</b></td>
			<td><input type="text" name="username" value="#username#" /></td>
		</tr>
		<tr>
			<td><b>Password:</b></td>
			<td><input type="password" name="password" value="#password#" /></td>
		</tr>
		<tr>
			<td><b>Retype Password:</b></td>
			<td><input type="password" name="password2" value="#password2#" /></td>
		</tr>
		<tr>
			<td><b>Email:</b></td>
			<td><input type="text" name="email" value="#email#" /></td>
		</tr>
		<tr><td colspan="2">&nbsp;</td></tr>
		<tr>
			<td>&nbsp;</td>
			<td>
				<input type="submit" value="Create Account" />
				<input type="button" value="Go Back" onClick="document.location='index.cfm'" />
			</td>
		</tr>
	</table>
</form>
</cfoutput>