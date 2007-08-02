<script language="JavaScript" type="text/javascript">
	function formAction(pAction,pKey)
	{			
		if(pAction == 'edit')
		{
			<cfoutput>document.tableForm.#attributes.eventField#.value = '#attributes.editEvent#</cfoutput>';	
		}
		else if(pAction == 'delete')
		{
			<cfoutput>document.tableForm.#attributes.eventField#.value = '#attributes.deleteEvent#</cfoutput>';
		}
		else if(pAction == 'add')
		{
			<cfoutput>document.tableForm.#attributes.eventField#.value = '#attributes.addEvent#</cfoutput>';
		}
		else if(pAction == 'export')
		{
			<cfoutput>document.tableForm.#attributes.eventField#.value = '#attributes.exportEvent#</cfoutput>';
		}
		else if(pAction == 'list')
		{
			<cfoutput>document.tableForm.#attributes.eventField#.value = '#attributes.searchEvent#</cfoutput>';
		}
		document.tableForm.<cfoutput>#attributes.tableKey#</cfoutput>.value = pKey;
		document.tableForm.submit();
	}
	
	function gotoPage(pgNum)
	{
		document.tableForm.groupNumber.value = pgNum;
		formAction('list','#attributes.nullKeyValue#');
	}
	
	function changeGroupSize(newSize)
	{
		if(newSize > 0){
			document.tableForm.groupNumber.value = 1;
			document.tableForm.groupSize.value = newSize;
			formAction('list','#attributes.nullKeyValue#');
		}else{
			alert('Please Enter a Valid Group Size');
		}
		
	}
	
	function sortTable(pSortField)
	{			
		if((pSortField == document.tableForm.sortBy.value) && (document.tableForm.sortDir.value == 'desc'))
		{
			document.tableForm.sortDir.value = 'asc'	
		}
		else if ((pSortField == document.tableForm.sortBy.value) && (document.tableForm.sortDir.value == 'asc'))
		{
			document.tableForm.sortDir.value = 'desc'	
		}
		document.tableForm.sortBy.value=pSortField;
		formAction('list','#attributes.nullKeyValue#');
	}
</script>