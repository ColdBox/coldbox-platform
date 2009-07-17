<cfoutput>

<script language="javascript">
	function confirmDelete(){
		if (confirm("Do you really want to delete the selected user(s)?")){
			document.delform.submit();
		}
	}
</script>

<div align="center" class="mainDiv">
	<div style="font-size:25px;font-weight:bold" align="left">
	User Listing
	</div>

	<div align="left" style="margin-top:10px;border:1px solid black;background:##fffff0;padding:10px">
	 Transfer just retrieved the user's listing and I am rendering them below.
	</div>

	<!--- render and cache menu --->
	#renderView('tags/menu',true,10)#

	<div style="margin-top:50px;clear:both" align="left">
	<form name="delform" id="delform" action="#event.buildLink('users.doDelete')#" method="post">
		<table width="100%" cellpadding="5" cellspacing="1" style="border:1px solid ##cccccc;font-size:11px">
			<tr style="color:white;background:##004080;font-weight:bold;text-align:center">
				<td width="20">&nbsp;</td>
				<td width="100">ID</td>
				<td>First Name</td>
				<td>Last Name</td>
				<td>Email</td>
				<td width="50">Create Date</td>
			</tr>
			<cfloop query="rc.users">
			<tr style="background:##eaeaea">
				<td><input type="checkbox" name="idlist" id="idlist" value="#id#"></td>
				<td><a href="#event.buildLink('users.dspEditUser.' & id)#">#id#</a></td>
				<td>#fname#</td>
				<td>#lname#</td>
				<td>#email#</td>
				<td>#dateformat(create_date,"MM/DD/YYYY")#</td>
			</tr>
			</cfloop>
		</table>
		<a class="action" href="javascript:confirmDelete()" title="Remove User" style="float:left">
			<span>Remove User(s)</span>
		</a>
	</form>
	</div>

</div>
</cfoutput>