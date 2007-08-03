<cftry>

<cfparam name="attributes.showAllEnabled" default="true" />

<cfoutput>
	<!--- include pop up calendar and date validation --->
	<cfif listLen(attributes.dateFields)>
		<script language="JavaScript" src="#attributes.tableMgrPath#/js/calendar/calendar.js" type="text/javascript"></script>
		<script language="JavaScript" src="#attributes.tableMgrPath#/js/calendar/calendar-en.js" type="text/javascript"></script>
		<script language="JavaScript" src="#attributes.tableMgrPath#/js/calendar/calendar-setup.js" type="text/javascript"></script>
		<script language="JavaScript" src="#attributes.tableMgrPath#/js/dateFunctions.js" type="text/javascript"></script>
		<link rel="stylesheet" type="text/css" href="#attributes.tableMgrPath#/css/aqua/theme.css"/>
	</cfif>
	<cfinclude template="#attributes.tableMgrPath#/js/searchBuilder.js.cfm" />
	<table align="#attributes.tableAlign#" cellpadding="#attributes.cellPadding#" cellspacing="#attributes.cellSpacing#" border="0" class="searchTable">
	<tbody>
	<form action="#attributes.formAction#" method="#attributes.formMethod#" name="searchForm" onsubmit="checkSearchForm();return false;">
	<input type="hidden" name="#attributes.eventField#" value="#attributes.searchEvent#" />
	<input type="Hidden" name="sortBy" value="#attributes.sortBy#" />
	<input type="Hidden" name="sortDir" value="#attributes.sortDir#" />
	<input type="Hidden" name="groupNumber" value="#attributes.groupNumber#" />
	<input type="Hidden" name="groupSize" value="#attributes.groupSize#" />
	<tr>
		<td valign="middle" width="50">Search In:</td>
		<td valign="middle" width="120">
			<select name="searchField" style="width:120px;" id="searchField" align="absmiddle" onChange="toggleSearchFor();">
				<option value="none">Select A Field</option>
				<cfloop from="1" to="#arrayLen(attributes.columnArray)#" step="1" index="tmpPosition">
					<option value="#attributes.columnArray[tmpPosition].columnField#"<cfif attributes.searchField eq attributes.columnArray[tmpPosition].columnField> selected</cfif>>#attributes.columnArray[tmpPosition].columnAlias#</option>
				</cfloop>
				<cfif attributes.showAllEnabled>
					<option value="showAll"<cfif attributes.searchField eq 'showAll'> selected</cfif>>--- Show All ---</option>
				</cfif>
			</select>
		</td>
		<td valign="middle" align="center">
			<table border="0" cellpadding="0" cellspacing="0" id="searchForTable">
			<tr>
				<td width="70" align="center">Search For:</td>
				<td width="170"><input type="text" style="width:175px;" name="searchFor" id="searchFor" align="absmiddle" value="#attributes.searchFor#"></td>
			</tr>
			</table>
			<cfif listLen(attributes.dateFields)>
				<table border="0" cellpadding="0" cellspacing="0" id="dateTable">
					<tr>
						<td valign="middle" width="35" align="center">From:</td>
						<td valign="middle" width="70"><input type="text" size="10" name="dateFrom" id="dateFrom" value="#attributes.dateFrom#" /></td>
						<td width="20" valign="middle" align="center"><img id="calendar1" src='<cfoutput>#attributes.imagePath#</cfoutput>/calendar.gif' onclick='showCalendar(this, document.searchForm.dateFrom, "mm/dd/yyyy",null,1,-1,-1)' align="absmiddle"></td>
						<td valign="middle" width="20" align="center">To:</td>
						<td valign="middle" width="70"><input type="text" size="10" name="dateTo" id="dateTo" value="#attributes.dateTo#" /></td>
						<td width="20" valign="middle" align="center"><img id="calendar2" src='<cfoutput>#attributes.imagePath#</cfoutput>/calendar.gif' onclick='showCalendar(this, document.searchForm.dateTo, "mm/dd/yyyy",null,1,-1,-1)' align="absmiddle"></td>
					</tr>
				</table>
			</cfif>
			<cfif listLen(attributes.booleanFields)>
				<table border="0" cellpadding="0" cellspacing="0" id="optionTable" class="hideIt">
				<tr>
					<td>Status:&nbsp;</td>
					<td>
						<select name="optionVal" style="width:195px">
							<option value="none">Select a Status</option>
							<option value="1"<cfif listFindNoCase(attributes.booleanFields,attributes.searchField) and attributes.searchFor eq 1> selected</cfif>>#listLast(attributes.booleanMask)#</option>
							<option value="0"<cfif listFindNoCase(attributes.booleanFields,attributes.searchField) and attributes.searchFor eq 0> selected</cfif>>#listFirst(attributes.booleanMask)#</option>
						</select>
					</td>
				</tr>
				</table>
			</cfif>
		</td>
		<td valign="middle" style="padding-bottom:3px;" width="60">
			<input type="submit" value="search" name="search" style="width:60px;">
		</td>
	</tr>
	<cfloop list="#attributes.formFields#" index="tmpFormField" delimiters=",">
		<cfset tmpField = getToken(tmpFormField,1,'=') />
		<cfset tmpVal = getToken(tmpFormField,2,'=') />
		<input type="hidden" name="#tmpField#" value="#tmpVal#" />
	</cfloop>
	</form>
	</table>
</cfoutput>

<script language="javascript">
	toggleSearchFor();
	
	Calendar.setup({
        inputField     :    "dateFrom",
        ifFormat       :    "%m/%d/%Y",
        button         :    "calendar1",
        align          :    "B"
    });
    
    Calendar.setup({
        inputField     :    "dateTo",
        ifFormat       :    "%m/%d/%Y",
        button         :    "calendar2",
        align          :    "B"
    });
</script>

<!--- error handling --->
<cfcatch type="any">
	<style>
		.msgBox{
			font-family: Arial, Helvetica, sans-serif;
			font-size: 11px;
			border:1px dotted #CCCCCC;
			width:350px;
			padding:5px;
		}
	</style>
	<div class="msgBox">
		An Error Occured While Processing Your Request<br>
		<br />
		<cfoutput>
			<strong>Message:</strong><br />#cfcatch.message#<br />
			<strong>Detail:</strong><br />#cfcatch.detail#
		</cfoutput>
		<cfdump var="#cfcatch#">
	</div>
	<cfabort>
</cfcatch>
			
</cftry>