<cfset user = Event.getValue("user")>
<cfset userTypes = Event.getValue("userTypes")>

<cfoutput>
<form action="?event=#Event.getValue('xehSave')#" method="post">
</cfoutput>
	<table class="edit">
		<tr class="even">
			<td class="desc"><cfoutput>#getResource("userType.userType")#</cfoutput></td>
			<td class="value">
			<select name="userTypeId">
			<cfoutput query="userTypes">
				<cfset isUserTypeSelected = iif(user.getUserType().getUserTypeId() eq userTypes.userTypeId,DE('selected'),DE(''))>
				<option value="#userTypeId#" #isUserTypeSelected#>#userTypes.name#</option>
			</cfoutput>
			</select>		
			</td>
		</tr>
		<cfoutput>
		<tr class="odd">
			<td class="desc">#getResource("user.firstName")#</td>
			<td class="value"><input type="text" name="firstName" value="#user.getFirstName()#" class="text" /></td>
		</tr>
		<tr class="even">
			<td class="desc">#getResource("user.lastName")#</td>
			<td class="value"><input type="text" name="lastName" value="#user.getLastName()#" class="text" /></td>
		</tr>
		<tr class="odd">
			<td class="desc">#getResource("user.email")#</td>
			<td class="value"><input type="text" name="email" value="#user.getEmail()#" class="text" /></td>
		</tr>
		<tr class="even">
			<td class="desc">#getResource("user.isActive")#</td>
			<td class="value">
			<cfset isActiveChecked = iif(user.getIsActive(),DE('checked'),DE(''))>
			<input type="checkbox" name="isActive" value="1" #isActiveChecked# />		
			</td>
		</tr>
		<tr class="odd">
			<td class="desc">#getResource("user.password")#</td>
			<td class="value"><input type="password" name="newPassword" value="" class="text" /></td>
		</tr>
		<tr class="even">
			<td class="desc">#getResource("user.confirmPassword")#</td>
			<td class="value"><input type="password" name="confirmPassword" value="" class="text" /></td>
		</tr>
		<tr>
			<td colspan="2" class="buttonBar">
			<cfif Event.getValue("xehBack","") NEQ "">
				<input type="button" value="#getResource('general.edit.backBtn')#" class="button" onclick="location.href='?event=#Event.getValue("xehBack")#'">
			</cfif>			
				<input type="submit" value="#getResource('general.edit.saveBtn')#" class="button">
			</td>
		</tr>
	</table>
	<!--- Needed for update --->
	<input type="hidden" name="userId" value="#user.getUserId()#">
	</cfoutput>
</form>