<cfparam name="username" default="">
<cfparam name="password" default="">

<cfoutput>
<form name="frm" method="post" action="javascript:doFormEvent('#getValue("xehLogin")#','centercontent',document.frm)">
	<p>
		Sign in to your account to add new feeds and tag existing feeds.
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