<cfoutput>
	<table class="view">
		<tr class="even">
			<td class="desc">UserType</td>
			<td class="value">#rc.user.getUserType().getName()#</td>
		</tr>
		<tr class="odd">
			<td class="desc">Full Name</td>
			<td class="value">#rc.user.getFullName()#</td>
		</tr>
		<tr class="even">
			<td class="desc">Email</td>
			<td class="value">#rc.user.getEmail()#</td>
		</tr>
		<tr class="odd">
			<td class="desc">Active</td>
			<td class="value">#rc.user.getIsActive()#</td>
		</tr>
		<tr class="even">
			<td class="desc">Password</td>
			<td class="value">#rc.user.getPassword()#</td>
		</tr>
		<tr class="odd">
			<td class="desc">Created on</td>
			<td class="value">#DateFormat(rc.user.getCreatedOn(),"dd-mm-yyy")#</td>
		</tr>
		<tr class="even">
			<td class="desc">Updated on</td>
			<td class="value">#DateFormat(rc.user.getUpdatedOn(),"dd-mm-yyy")#</td>
		</tr>
		<tr>
			<td  colspan="2" class="buttonBar">
			<cfif Event.getValue("xehBack","") NEQ "">
				<input type="button" value="#getResource('general.view.backBtn')#" class="button" onclick="location.href='?event=#rc.xehBack#'">
			</cfif>
			<cfif Event.getValue("xehEdit","") NEQ "">
				<input type="button" value="#getResource('general.view.editBtn')#" class="button" onclick="location.href='?event=#rc.xehEdit#&userId=#rc.user.getUserId()#'">
			</cfif>
			<cfif Event.getValue("xehDelete","") NEQ "">
			<input type="button" value="#getResource('general.view.deleteBtn')#" class="button" onclick="location.href='?event=#rc.xehDelete#&userId=#rc.user.getUserId()#'">
			</cfif>
			</td>
		</tr>
	</table>
</cfoutput>
