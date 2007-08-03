<cfoutput>
<!--- Collection Reference --->


<script language="javascript">
	function confirmDelete(){
	}
</script>

<div align="center" class="mainDiv">
	<div style="font-size:25px;font-weight:bold" align="left">
	Edit User
	</div>

	<div align="left" style="margin-top:10px;border:1px solid black;background:##fffff0;padding:10px">
	 Transfer just retrieved the user information for id: <strong>#rc.id#</strong>. You can now make any updates to the
	 user.
	</div>

	<div style="margin-top:10px;clear:both;" align="center">
		<a class="action silver" href="?event=ehGeneral.dspHome" style="float:left">
			<span>Home</span>
		</a>
		<a class="action" href="?event=ehGeneral.dspUsers" title="List Users" style="float:left">
			<span>List Users</span>
		</a>
		<a class="action" href="?event=ehGeneral.dspAddUser" title="Add User" style="float:left">
			<span>Add User</span>
		</a>
	</div>

	<div style="margin-top:50px;clear:both" align="left">
		<form name="addform" id="addform" action="index.cfm" method="post">
		<input type="hidden" name="event" value="ehGeneral.doUpdate">
		<input type="hidden" name="id" value="#rc.oUser.getID()#">
		<table width="100%" cellpadding="5" cellspacing="1" style="border:1px solid ##cccccc;">

			<tr>
				<td width="20" align="right" bgcolor="##eaeaea"><strong>ID:</strong></td>
				<td width="100">#rc.oUser.getID()#</td>
			</tr>
			<tr>
				<td width="20" align="right" bgcolor="##eaeaea"><strong>Create Date:</strong></td>
				<td width="100">#rc.oUser.getcreate_date()#</td>
			</tr>

			<tr>
				<td width="20" align="right" bgcolor="##eaeaea"><strong>First Name:</strong></td>
				<td width="100"><input type="text" name="fname" id="fname" size="20" value="#rc.oUser.getfname()#"></td>
			</tr>

			<tr>
				<td width="20"  align="right" bgcolor="##eaeaea"><strong>Last Name:</strong></td>
				<td width="100"><input type="text" name="lname" id="lname" size="20" value="#rc.oUser.getlname()#"></td>
			</tr>

			<tr>
				<td width="20"  align="right" bgcolor="##eaeaea"><strong>Email:</strong></td>
				<td width="100"><input type="text" name="email" id="email" size="20" value="#rc.oUser.getemail()#"></td>
			</tr>
		</table>

		<div style="margin-top:20px" align="center" >
			<a class="action silver" href="javascript:document.addform.submit()">
				<span>Update</span>
			</a>
		</div>
	</form>
	</div>

</div>
</cfoutput>