<div style="display:block;width:775px;text-align:right;margin-bottom:15px;">
<cfoutput>
<a href="?event=#rc.xehEdit#" class="action">#getResource("user.newuser")#</a>
</cfoutput>
</div>
<table cellpadding="3" class="list">
	<cfoutput>
	<tr>
		<th>#getResource("user.fullName")#</th>
		<th>#getResource("user.email")#</th>
		<th>#getResource("user.createdOn")#</th>
		<th>#getResource("user.updatedOn")#</th>
		<th class="action">#getResource("general.list.action")#</th>
	</tr>
	</cfoutput>
	<cfoutput query="rc.users">
	<cfset styleClass = iif(rc.users.currentrow MOD 2, DE('odd'),DE('even'))>	
	<tr class="#styleClass#" 
		onclick="location.href='?event=#rc.xehView#&userId=#userId#'"
		onmouseover="this.className='hover'"
		onmouseout="this.className='#styleClass#'">
		<td>#firstName# #lastName#</td>
		<td>#email#</td>
		<td>#DateFormat(createdOn,"dd mmm yyy")#</td>
		<td>#DateFormat(updatedOn,"dd mmm yyy")#</td>
		<td><a href="?event=#rc.xehEdit#&userId=#userId#" class="action">#getResource("general.list.editLink")#</a>&nbsp;<a href="?event=#rc.xehDelete#&userId=#userId#" class="action">#getResource("general.list.deleteLink")#</a></td>
	</tr>
	</cfoutput>
</table>