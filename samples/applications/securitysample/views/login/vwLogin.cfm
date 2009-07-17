<form action="?event=ehSecurity.doLogin" method="post">
	<table height="75%" width="100%">
		<tr>
			<td align="center">
				<h1>Admin</h1>
				<table>
					<tr>
						<td><cfoutput>#getResource("user.email")#</cfoutput></td>
						<td><input name="email" type="text" class="textSmall" value="evdlinden@gmail.com"></td>
					</tr>
					<tr>
						<td><cfoutput>#getResource("user.password")#</cfoutput></td>
						<td><input name="password" type="password" class="textSmall" value="ernst"></td>
					</tr>
					<tr>
						<td colspan="2" align="right"><cfoutput><input type="submit" value="#getResource('general.login.loginBtn')#"></cfoutput></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</form>
<form action="?event=ehSecurity.doLogin" method="post">
	<table height="75%" width="100%">
		<tr>
			<td align="center">
				<h1>User</h1>
				<table>
					<tr>
						<td><cfoutput>#getResource("user.email")#</cfoutput></td>
						<td><input name="email" type="text" class="textSmall" value="info@coldboxframework.com"></td>
					</tr>
					<tr>
						<td><cfoutput>#getResource("user.password")#</cfoutput></td>
						<td><input name="password" type="password" class="textSmall" value="luis"></td>
					</tr>
					<tr>
						<td colspan="2" align="right"><cfoutput><input type="submit" value="#getResource('general.login.loginBtn')#"></cfoutput></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</form>