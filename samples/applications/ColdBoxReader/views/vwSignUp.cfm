<cfparam name="username" default="">
<cfparam name="password" default="">
<cfparam name="password2" default="">
<cfparam name="email" default="">

<cfoutput>
<h1>Create your very own ColdBox Reader Account</h1>

<form name="frm" method="post" action="javascript:doFormEvent('#Event.getValue("xehCreate")#','centercontent',document.frm)">
	<p>
		Creating an account allows you to add new feeds and tag existing feeds. All passwords are encrypted.
	</p>
	<table>
		<tr>
			<td><b>Username:</b></td>
			<td><input type="text" name="username" value="#username#" size="30" /></td>
		</tr>
		<tr>
			<td><b>Password:</b></td>
			<td><input type="password" name="password" value="#password#" size="30"/></td>
		</tr>
		<tr>
			<td><b>Retype Password:</b></td>
			<td><input type="password" name="password2" value="#password2#" size="30"/></td>
		</tr>
		<tr>
			<td><b>Email:</b></td>
			<td><input type="text" name="email" value="#email#" size="30"/></td>
		</tr>
		<tr><td colspan="2">&nbsp;</td></tr>
		<tr>
			<td>&nbsp;</td>
			<td>
				<input type="button" value="Go Back" onClick="document.location='index.cfm'" />
				<input type="submit" value="Create Account" />
			</td>
		</tr>
	</table>
</form>
</cfoutput>