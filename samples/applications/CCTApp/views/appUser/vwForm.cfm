<cfset rc = event.getCollection()>

<cfif not getPlugin("messagebox").isEmpty()>
	<cfoutput>#getPlugin("messagebox").renderit()#</cfoutput>
</cfif>

<div class="formContainer">
<cfoutput>
	<table cellpadding="2" cellspacing="0" border="0" class="formTable" align="center">
	<form name="editForm" action="#cgi.SCRIPT_NAME#" method="post">
	<input type="Hidden" name="event" value="ehAppUser.doUpdate" />
	<input type="Hidden" name="appUserId" value="#rc.oAppUser.getAppUserId()#" />
	<tr>
		<td colspan="2" class="formHeader">
			<strong>ACCOUNT</strong>
		</td>
	</tr>
	<tr>
		<td width="100">
			Username:
		</td>
		<td>
			<input type="text" name="userName" value="#rc.oAppUser.getUsername()#" class="formFieldRequired" />
		</td>
	</tr>
	<tr>
		<td>
			First Name:
		</td>
		<td>
			<input type="text" name="firstName" value="#rc.oAppUser.getFirstName()#" class="formFieldRequired" />
		</td>
	</tr>
	<tr>
		<td>
			Last Name:
		</td>
		<td>
			<input type="text" name="lastName" value="#rc.oAppUser.getLastName()#" class="formFieldRequired" />
		</td>
	</tr>
	<tr>
		<td>
			Email:
		</td>
		<td>
			<input type="text" name="email" value="#rc.oAppUser.getEmail()#" class="formFieldRequired" />
		</td>
	</tr>
	<tr>
		<td>
			Active:
		</td>
		<td>
			<input type="checkbox" name="isActive" value="1" <cfif rc.oAppUser.getIsActive()>checked="true"</cfif> />
		</td>
	</tr>
	<tr>
		<td colspan="2" class="formHeader" style="border-top:none;">PASSWORD</td>
	</tr>
	<tr>
		<td>
			New Password:
		</td>
		<td>
			<input type="password" name="newPassword" value="" />
		</td>
	</tr>
	<tr>
		<td>
			Confirm Password:
		</td>
		<td>
			<input type="password" name="confirmPassword" value="" />
		</td>
	</tr>
	<tr class="formFooter">
		<td>
			<input type="button" name="cancel" value="Cancel" onclick="history.back();" />
		</td>
		<td align="right">
			<input type="submit" value="Submit" />
		</td>
	</tr>
	</form>
	</table>
</cfoutput>
</div>
<div align="center" style="width:100%;">
	- Shaded Fields Are Required
</div>