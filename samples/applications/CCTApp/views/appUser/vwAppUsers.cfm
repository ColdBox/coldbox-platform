<div align="center">
	<cfif not getPlugin("messagebox").isEmpty()>
		<cfoutput>#getPlugin("messagebox").renderit()#</cfoutput>
	</cfif>
</div>

<cfmodule template="../../extensions/tableMgr/tablemgr.cfm"
	tabletitle="AppUsers"
	tableMgrPath="../../extensions/tableMgr"
	imagePath="../../extensions/tableMgr/images"
	formAction="index.cfm"
	formMethod="post"
	eventField="event"
	addEvent="ehAppUser.dspForm"
	editEvent="ehAppUser.dspForm"
	deleteEvent="ehAppUser.doDelete"
	searchEvent="ehAppUser.dspAppUsers"
	dataQuery="#event.getCollection().stAppUsers.results#"
	totalRecords="#event.getCollection().stAppUsers.totalRecords#"
	tableKey="AppUserId"
	dateFields="createdOn,updatedOn"
	booleanFields="isActive"
	tableColumns="createdOn|Created|75,email|Email|200,userName|Username|100,firstName|First Name|150|left,lastName|Last Name|150|left,updatedOn|Updated|75,isActive|Active|50"
	>