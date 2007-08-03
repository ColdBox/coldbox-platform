<script language="javascript" type="text/javascript">
function checkSearchForm()
{
	var searchField = document.searchForm.searchField.value;
	<cfoutput>	
		var formAction = document.searchForm.#attributes.eventField#.value;
		var searchAction = '#attributes.searchEvent#';
	</cfoutput>
	
	<cfif listLen(attributes.dateFields)>
		var dateTo = document.searchForm.dateTo.value;
		var dateFrom = document.searchForm.dateFrom.value;
	</cfif>
	
	if (formAction == searchAction)
	{
		if (searchField == "none")
		{
		alert('Please Select A Search Field');
		}
		<cfif listLen(attributes.dateFields)>
			else if ((<cfloop list="#attributes.dateFields#" index="tmpField">(searchField == "<cfoutput>#tmpField#</cfoutput>") || </cfloop>(false)) && ((dateFrom == '') || (dateTo == '')) )
			{
			alert('Please Enter Both Dates');
			}
			else if ((<cfloop list="#attributes.dateFields#" index="tmpField">(searchField == "<cfoutput>#tmpField#</cfoutput>") || </cfloop>(false)) && (isDate(dateFrom,'M/d/yyyy') == false) && (isDate(dateFrom,'M/d/yyyy') == false))
			{
			alert('Please Check Your Date Format - M/D/YYYY');
			}
			else if (((<cfloop list="#attributes.dateFields#" index="tmpField">(searchField == "<cfoutput>#tmpField#</cfoutput>") || </cfloop>(false))) && (compareDates(dateFrom,'M/d/yyyy',dateTo,'M/d/yyyy') == 1))
			{
			alert('Please Check Your Date Order');
			}
		</cfif>
		else if (((<cfloop list="#attributes.booleanFields#" index="tmpField">(searchField == "<cfoutput>#tmpField#</cfoutput>") || </cfloop>(false))) && (document.searchForm.optionVal.value == 'none'))
		{
		alert('Please Select A Status');
		}
		else if (((<cfloop list="#attributes.booleanFields#" index="tmpField">(searchField != "<cfoutput>#tmpField#</cfoutput>") && </cfloop>(true))) && ((<cfloop list="#attributes.dateFields#" index="tmpField">(searchField != "<cfoutput>#tmpField#</cfoutput>") && </cfloop>(true))) && (searchField != "showAll") && (document.searchForm.searchFor.value == ""))
		{
		alert('Please Enter Something To Search For');
		}
		else
		{		
			if ((<cfloop list="#attributes.booleanFields#" index="tmpField">(searchField == "<cfoutput>#tmpField#</cfoutput>") || </cfloop>(false)))
			{
				document.searchForm.searchFor.value = document.searchForm.optionVal.value;
			}
			document.searchForm.groupNumber.value = 1;
			document.searchForm.submit();
		}
	}
	else
	{	
		document.searchForm.groupNumber.value = 1;
		document.searchForm.submit();
	}
}

function toggleSearchFor()
{
	var tmpVar = document.searchForm.searchField.value;
	<cfif listLen(attributes.dateFields)>
		if (<cfloop list="#attributes.dateFields#" index="tmpField">(tmpVar == '<cfoutput>#tmpField#</cfoutput>') || </cfloop>(false))
		{
			<cfif listLen(attributes.booleanFields)>document.getElementById('optionTable').className = 'hideIt';</cfif>
			document.getElementById('searchForTable').className = 'hideIt';
			document.getElementById('dateTable').className = 'showIt';
		}
	<cfelse>
		if (false){}
	</cfif>
	<cfif listLen(attributes.booleanFields)>
		else if (<cfloop list="#attributes.booleanFields#" index="tmpField">(tmpVar == '<cfoutput>#tmpField#</cfoutput>') || </cfloop>(false))
		{
			<cfif listLen(attributes.dateFields)>document.getElementById('dateTable').className = 'hideIt';</cfif>
			document.getElementById('searchForTable').className = 'hideIt';
			document.getElementById('optionTable').className = 'showIt';
		}
	</cfif>
		else
		{
			<cfif listFindNoCase(attributes.booleanFields,attributes.searchField)>document.searchForm.searchFor.value = '';</cfif>
			<cfif listLen(attributes.booleanFields)>document.getElementById('optionTable').className = 'hideIt';</cfif>
			<cfif listLen(attributes.dateFields)>document.getElementById('dateTable').className = 'hideIt';</cfif>
			document.getElementById('searchForTable').className = 'showIt';
		}
}
</script>