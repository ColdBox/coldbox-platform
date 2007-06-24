<cfsetting enablecfoutputonly=true>
<!---
	Name         : newthread.cfm
	Author       : Raymond Camden 
	Created      : June 10, 2004
	Last Updated : November 3, 2006
	History      : Support password reminders (rkc 2/18/05)
				   No more notifications (rkc 7/29/05)
				   Removed mappings (rkc 8/27/05)
				   require confirmation changes (rkc 7/12/06)
				   make title work (rkc 8/4/06)
				   handle encryption and auto-focus (rkc 11/3/06)
	Purpose		 : Displays form to add a thread.
--->
<cfoutput>
<p>
<table width="500" cellpadding="6" class="tableDisplay" cellspacing="1" border="0">
	<cfif Event.valueExists("showRequireConfirmation")>
		<tr class="tableHeader">
			<td class="tableHeader">Confirmation Required</td>
		</tr>
		<tr class="tableRowMain">
			<td>
			In order to complete your registration, you must confirm your email
			address. An email has been sent to the address you used during registration.
			Follow the link in the email to complete registration. 
			</td>
		</tr>
	
	<cfelse>
	<tr class="tableHeader">
		<td class="tableHeader">Login</td>
	</tr>
	<tr class="tableRowMain">
		<td>
		Please use the form below to login.
		<cfif Event.getValue("failedLogon",false)>
			<p>
			#getPlugin("messageBox").renderit()#
			</p>
		</cfif>
		</td>
	</tr>
	<tr class="tableRowMain">
		<td>
		<form action="#cgi.script_name#" method="post">
		<input type="hidden" name="event" value="#Event.getValue("xehDoLogin")#">
		<input type="hidden" name="ref" value="#Event.getValue("ref","")#">
		<table>
			<tr>
				<td><b>Username:</b></td>
				<td><input type="text" name="username" class="formBox"></td>
			</tr>
			<tr>
				<td><b>Password:</b></td>
				<td><input type="password" name="password" class="formBox"></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td align="right"><input type="image" src="images/btn_login.gif" alt="Login" width="71" height="19" name="logon"></td>
			</tr>
		</table>
		</form>
		</td>
	</tr>
	<tr class="tableHeader">
		<td class="tableHeader">Register</td>
	</tr>
	<tr class="tableRowMain">
		<td>
		In order to create threads or reply to threads, you must register. All of the
		fields below are required.
		<cfif Event.getValue("failedRegistration",false)>
			<p>
			#getPlugin("messageBox").renderit()#
			</p>
		</cfif>
		</td>
	</tr>
	<tr class="tableRowMain">
		<td>
		<form action="#cgi.script_name#?" method="post">
		<input type="hidden" name="event" value="#Event.getValue("xehRegister")#">
		<table>
			<tr>
				<td><b>Username: </b></td>
				<td><input type="text" name="username_new" value="#Event.getValue("username_new","")#" class="formBox"></td>
			</tr>
			<tr>
				<td><b>Email Address: </b></td>
				<td><input type="text" name="emailaddress" value="#Event.getValue("emailaddress","")#" class="formBox"></td>
			</tr>
			<tr>
				<td><b>Password: </b></td>
				<td><input type="password" name="password_new" class="formBox"></td>
			</tr>
			<tr>
				<td><b>Confirm Password: </b></td>
				<td><input type="password" name="password_new2" class="formBox"></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td align="right"><input type="image" src="images/btn_register.gif" alt="Register" width="71" height="19"></td>
			</tr>
		</table>
		</form>
		</td>
	</tr>
	<cfif application.settings.encryptpasswords>
	<cfelse>
	<tr class="tableHeader">
		<td class="tableHeader">Password Reminder</td>
	</tr>
	<tr class="tableRowMain">
		<td>
		If you cannot remember your password, enter your username in the form below and your login information will be sent to you.
			<cfif Event.getValue("passreminder",false) eq true>
			#getPlugin("messagebox").renderit()#
			</cfif>
		</td>
	</tr>
	<tr class="tableRowMain">
		<td>
		<form action="#cgi.script_name#" method="post">
		<input type="hidden" name="event" value="#Event.getValue("xehPasswordReminder")#">
		<table>
			<tr>
				<td><b>Username:</b></td>
				<td><input type="text" name="username_lookup" class="formBox"></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td align="right"><input type="image" src="images/btn_sendpasswordreminder.gif" alt="Login" width="149" height="19" name="logon"></td>
			</tr>
		</table>
		</form>
		</td>
	</tr>
	</cfif>
	</cfif>
</table>
</p>

<script>
window.onload = function() {document.getElementById("username").focus();}
</script>

</cfoutput>

<cfsetting enablecfoutputonly=false>
