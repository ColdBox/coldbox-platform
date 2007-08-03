<!---
	Name         : tablemgr.cfm
	Author       : Tom de Manincor 
	Created      : September 13, 2006
	Last Updated : June 4, 2007
	Purpose		 : Dynamic DB Table Manager. 
	Version		 : 0.4.1
--->

<cftry>
<cfparam name="attributes.tableMgrPath" default="/tableMgr/">
	
<cfparam name="attributes.formFields" default="">
<cfparam name="attributes.formAction" default="">
<cfparam name="attributes.formMethod" default="post">
<cfparam name="attributes.eventField" default="event">

<!--- set up parameters --->
<cfif attributes.formMethod eq 'post' and not StructIsEmpty(form)>
	<cfset StructAppend(attributes,form,'yes')>
<cfelseif attributes.formMethod eq 'get' and not StructIsEmpty(url)>
	<cfset StructAppend(attributes,url,'yes')>
</cfif>

<cfparam name="attributes.showAttributes" default="no">
<cfparam name="attributes.showSearchForm" default="true">
<cfparam name="attributes.showResultsTable" default="true">

<cfparam name="attributes.dataSource" default="">
<cfparam name="attributes.tableName" default="">

<cfparam name="attributes.dataQuery" default="">

<cfparam name="attributes.tableColumns" default="">
<cfparam name="attributes.tokenDelimiter" default="|">

<cfparam name="attributes.columnList" default="">
<cfparam name="attributes.tableKey" default="">
<cfparam name="attributes.nullKeyValue" default="">

<cfparam name="attributes.tableAlign" default="center">
<cfparam name="attributes.tableWidth" default="">
<cfparam name="attributes.cellPadding" default="2">
<cfparam name="attributes.cellSpacing" default="0">
<cfparam name="attributes.tableTitle" default="">

<cfparam name="attributes.imagePath" default="/tableMgr/images/">

<cfparam name="attributes.currencyFields" default="">
<cfparam name="attributes.booleanFields" default="">
<cfparam name="attributes.dateFields" default="">
<cfparam name="attributes.timeFields" default="">
<cfparam name="attributes.dateTimeFields" default="">

<cfparam name="attributes.booleanMask" default="NO,YES">
<cfparam name="attributes.dateMask" default="mm/dd/yyyy">
<cfparam name="attributes.timeMask" default="hh:mm tt">

<cfparam name="attributes.searchEvent" default="">
<cfparam name="attributes.addEvent" default="">
<cfparam name="attributes.editEvent" default="">
<cfparam name="attributes.deleteEvent" default="">
<cfparam name="attributes.exportEvent" default="">

<cfparam name="attributes.startRow" default="1" />
<cfparam name="attributes.endRow" default="1" />
<cfparam name="attributes.totalRecords" default="0" />

<cfparam name="attributes.groupBy" default="" />

<cfparam name="attributes.groupNumber" default="1" />
<cfparam name="attributes.groupSize" default="10" />

<cfparam name="attributes.sortBy" default="#attributes.tableKey#" />
<cfparam name="attributes.sortDir" default="desc" />

<cfparam name="attributes.searchField" default="showAll" />
<cfparam name="attributes.searchFor" default="" />

<cfparam name="attributes.dateFrom" default="#DateFormat(now(),attributes.dateMask)#" />
<cfparam name="attributes.dateTo" default="#DateFormat(now(),attributes.dateMask)#" />

<!--- separate column aliases and fields --->
<cfset attributes.columnArray = ArrayNew(1)>
<cfloop list="#attributes.tableColumns#" index="tmpToken">
	<cfset attributes.columnStruct = StructNew()>
	<cfset attributes.columnStruct.columnField = getToken(tmpToken,1,attributes.tokenDelimiter)>
	<cfset attributes.columnStruct.columnAlias = getToken(tmpToken,2,attributes.tokenDelimiter)>
	<cfset attributes.columnStruct.columnWidth = getToken(tmpToken,3,attributes.tokenDelimiter)>
	<cfset attributes.columnStruct.columnAlign = getToken(tmpToken,4,attributes.tokenDelimiter)>
	<cfset attributes.columnStruct.columnLimit = getToken(tmpToken,5,attributes.tokenDelimiter)>
	<cfset ArrayAppend(attributes.columnArray,attributes.columnStruct)>
	<cfset attributes.columnList = listAppend(attributes.columnList,attributes.columnStruct.columnField) >
</cfloop>

<!--- internal sql engine --->
<cfif len(attributes.dataSource) and len(attributes.tableName) and not len(attributes.dataQuery)>
	<cfoutput>
		<cfsavecontent variable="attributes.tableSQL">
			SELECT <cfif len(attributes.columnList)>#attributes.columnList#<cfelse>*</cfif>
			FROM #attributes.tableName#
			<cfif len(attributes.searchField) and attributes.searchField neq 'showAll' and len(attributes.searchFor) and not listFindNoCase(attributes.searchField,attributes.dateFields)>
				WHERE #attributes.searchField# like '#attributes.searchFor#%'
			<cfelseif attributes.searchField neq 'showAll' and listFindNoCase(attributes.searchField,attributes.dateFields)>
				WHERE #attributes.searchField# BETWEEN '#DateFormat(attributes.dateFrom,attributes.dateMask)#' AND '#DateFormat(attributes.dateTo,attributes.dateMask)#'
			</cfif>
			<cfif len(attributes.groupBy)>GROUP BY #attributes.groupBy#</cfif>
			ORDER BY #attributes.sortBy# #attributes.sortDir#
		</cfsavecontent>
	</cfoutput>

	<cfquery datasource="#attributes.dataSource#" name="attributes.dataQuery">
		#PreserveSingleQuotes(attributes.tableSQL)#
	</cfquery>   
</cfif>

<!--- check for valid data --->
<cfif not isDefined('attributes.dataQuery.columnList')>
	<cfthrow message="No Table Data - Invalid Query">
</cfif>

<!--- column header setup --->
<cfif not len(attributes.columnList)>
	<cfset attributes.columnList = attributes.dataQuery.columnList>
</cfif>
<cfset attributes.columnCount = listLen(attributes.columnList) + 1>

<!--- pagination setup --->
<cfif attributes.totalRecords eq 0 and attributes.groupSize gt 0>
	<cfset attributes.maxPages = Ceiling( attributes.dataQuery.recordCount / attributes.groupSize )>
	<cfset attributes.totalRecords = attributes.dataQuery.recordCount />
	<cfif attributes.dataQuery.recordCount gt 0>
		<cfset attributes.startRow = attributes.groupSize * (attributes.groupNumber - 1) + 1>
		<cfset attributes.endRow = attributes.startRow + attributes.groupSize - 1>
		<cfif attributes.endRow gt attributes.dataQuery.recordCount>
			<cfset attributes.endRow = attributes.dataQuery.recordCount>
		</cfif>
	</cfif>
<cfelse>
	<cfset attributes.maxPages = Ceiling( attributes.totalRecords / attributes.groupSize ) />
	
	<cfset attributes.startRow = 1 />
	<cfset attributes.endRow = attributes.groupSize />
	<cfif attributes.endRow gt attributes.dataQuery.recordCount>
		<cfset attributes.endRow = attributes.dataQuery.recordCount>
	</cfif>
</cfif>
<div class="tableMgrContainer">
<cfif attributes.showSearchForm>
	<cfinclude template="searchBuilder.cfm" />
</cfif>

<cfif attributes.showResultsTable>
<!--- javascript --->
<cfinclude template="#attributes.tableMgrPath#/js/tableMgr.js.cfm" />
<link rel="stylesheet" type="text/css" href="<cfoutput>#attributes.tableMgrPath#</cfoutput>/css/tableMgr.css"/>

<!--- main table --->
<cfoutput>
	<cfif attributes.totalRecords eq 0>
		<table align="#attributes.tableAlign#" cellpadding="#attributes.cellPadding#" cellspacing="#attributes.cellSpacing#" border="0" class="resultsTable">
		<tbody>
		<tr>
			<td colspan="#attributes.columnCount#" align="right">
				<div id="tableTitle" style="float:left;">#attributes.tableTitle#</div>
				No results found with search criteria.
			</td>
		</tr>
	<cfelseif attributes.totalRecords gt 0>
		<table align="#attributes.tableAlign#" cellpadding="#attributes.cellPadding#" cellspacing="#attributes.cellSpacing#" border="0" class="resultsTable" width="#attributes.tableWidth#">
		<tbody>
		<tr>
			<td colspan="#attributes.columnCount#" align="right">
				<div id="tableTitle" style="float:left;">#attributes.tableTitle#</div>
				#attributes.totalRecords# results found.
			</td>
		</tr>
	</cfif>
	<tr>
		<td colspan="#attributes.columnCount#">
			<!--- feature table --->
			<table cellpadding="#attributes.cellPadding#" cellspacing="#attributes.cellSpacing#" border="0" width="100%" class="featureTable">
				<tr>
					<cfif len(attributes.addEvent)>
						<td width="16" valign="middle"><a href="##" onClick="formAction('add','#attributes.nullKeyValue#');"><img title="Add" src="#attributes.imagePath#/add.gif" border="0" width="16" height="16" alt="Add"></a></td>
						<td width="80" valign="middle"><a href="##" onClick="formAction('add','#attributes.nullKeyValue#');">Add New Record</a></td>
					</cfif>
					<cfif attributes.dataQuery.recordCount gt 0>
						<cfif len(attributes.exportEvent)>
							<td width="20"  align="center">/</td>
							<td width="16" valign="middle"><a href="##" onClick="formAction('export','#attributes.nullKeyValue#');"><img title="Export" src="#attributes.imagePath#/export.gif" border="0" width="16" height="16" align="absmiddle" alt="Export"></a></td>
							<td width="80" valign="middle"><a href="##" onClick="formAction('export','#attributes.nullKeyValue#');">Export To Excel</a></td>
						</cfif>
						<td valign="middle" align="right"></td>
					<cfelse>
						<td valign="middle"></td>
					</cfif>
					<td valign="middle" align="right">Per Page:</td>
					<td valign="middle" align="right" width="50">
						<select name="selectGroupSize" onchange="changeGroupSize(this.value);" >
							<option value="1" <cfif attributes.groupSize eq 1>selected</cfif>>1</option>
							<option value="10" <cfif attributes.groupSize eq 10>selected</cfif>>10</option>
							<option value="25" <cfif attributes.groupSize eq 25>selected</cfif>>25</option>
							<option value="50" <cfif attributes.groupSize eq 50>selected</cfif>>50</option>
							<option value="100" <cfif attributes.groupSize eq 100>selected</cfif>>100</option>
							<option value="#attributes.totalRecords#" <cfif attributes.groupSize eq attributes.totalRecords>selected</cfif>>ALL</option>
						</select>
					</td>
				</tr>
			</table>
			<!--- end feature table --->
		</td>
	</tr>
	<tr>
		<cfloop from="1" to="#ArrayLen(attributes.columnArray)#" index="tmpPosition">
			<cfset cellWidth = (attributes.columnArray[tmpPosition].columnWidth)>
			<th valign="middle" <cfif IsNumeric(cellWidth)>width="#cellWidth#"</cfif>>									
				<cfif len(attributes.sortDir) and attributes.sortBy eq attributes.columnArray[tmpPosition].columnField>
				<div style="float:right;">
					<a href="##" onclick="sortTable('#lcase(attributes.columnArray[tmpPosition].columnField)#');return false;"><img title="Sort" src="#attributes.imagePath#/arrow_#attributes.sortDir#.gif" border="0" width="8" height="7"></a>
				</div>
				</cfif>
				<a href="##" onclick="sortTable('#lcase(attributes.columnArray[tmpPosition].columnField)#');return false;">#attributes.columnArray[tmpPosition].columnAlias#</a>
			</th>
		</cfloop>
		<th valign="middle" align="center" width="50">	
			Options
		</th>
	</tr>
	<cfif attributes.totalRecords gt 0>
		<cfloop query="attributes.dataQuery" startrow="#attributes.startRow#" endrow="#attributes.endRow#">
			<tr bgcolor="#IIF( currentRow mod 2 eq 0, DE("DEDEDE"), DE("FFFFFF"))#">
				<cfloop from="1" to="#ArrayLen(attributes.columnArray)#" index="tmpPosition">
					<cfset cellField = (attributes.columnArray[tmpPosition].columnField)>
					<cfset cellVal = evaluate(attributes.columnArray[tmpPosition].columnField)>
					<cfset cellWidth = (attributes.columnArray[tmpPosition].columnWidth)>
					<cfset cellAlign = (attributes.columnArray[tmpPosition].columnAlign)>
					<cfset cellLimit = (attributes.columnArray[tmpPosition].columnLimit)>
					<td valign="middle" <cfif len(cellAlign)>align="#cellAlign#"<cfelse>align="center"</cfif> <cfif IsNumeric(cellWidth)>width="#cellWidth#"</cfif>>		
						<cfif len(cellLimit) and cellLimit><div style="width:#cellLimit#px;overflow:hidden;"></cfif>
						<cfif listLen(attributes.dateFields) and listFindNoCase(attributes.dateFields,cellField)>
							#DateFormat(cellVal,attributes.dateMask)#
						<cfelseif listLen(attributes.timeFields) and listFindNoCase(attributes.timeFields,cellField)>
							#TimeFormat(cellVal,attributes.timeMask)#
						<cfelseif listLen(attributes.dateTimeFields) and listFindNoCase(attributes.dateTimeFields,cellField)>
							#DateFormat(cellVal,attributes.dateMask)# - #TimeFormat(cellVal,attributes.timeMask)#
						<cfelseif listLen(attributes.currencyFields) and listFindNoCase(attributes.currencyFields,cellField)>
							#DollarFormat(cellVal)#
						<cfelseif listLen(attributes.booleanFields) and listFindNoCase(attributes.booleanFields,cellField)>
							<cfif isBoolean(cellVal)>
								<cfif cellVal>
									#ListLast(attributes.booleanMask)#
								<cfelse>
									#ListFirst(attributes.booleanMask)#
								</cfif>
							<cfelse>
								<cfif len(cellVal)>
									#ListLast(attributes.booleanMask)#
								<cfelse>
									#ListFirst(attributes.booleanMask)#
								</cfif>
							</cfif>
						<cfelse>
							#cellVal#
						</cfif>
						<cfif len(cellLimit) and cellLimit></div></cfif>
					</td>
				</cfloop>
				<td valign="middle" align="center">
					<cfif len(attributes.editEvent)><a href="##" onClick="formAction('edit','#evaluate(attributes.tableKey)#');"><img title="Edit" width="16" height="16" src="#attributes.imagePath#/edit.gif" border="0" align="absmiddle" alt="Edit"></a></cfif>
					<cfif len(attributes.deleteEvent)><a href="##" onClick="if (confirm('Delete - Are you sure?')) formAction('delete','#evaluate(attributes.tableKey)#');"><img title="Delete" width="16" height="16" src="#attributes.imagePath#/delete.gif" border="0" align="absmiddle" alt="Delete"></cfif>
				</td>			
			</tr>
		</cfloop>
	</cfif>
	<tr>
		<td colspan="#attributes.columnCount#" height="3"></td>
	</tr>
	<cfif attributes.maxPages gt 1>
	<tr>
		<td colspan="#attributes.columnCount#" align="center">
			<!--- pagination table --->
			<cfoutput>
				<table cellspacing="0" cellpadding="0" border="0" class="pageTable">
				<tbody>
				<tr>
					<td width="16" valign="middle">
						<cfif attributes.groupNumber gt 1>
							<a href="##" onclick="gotoPage(#attributes.groupNumber - 1#);">
								<img title="Previous" src="#attributes.imagePath#/arrow_left.gif" width="16" height="16" border="0" align="absmiddle" alt="Previous">
							</a>
						</cfif>
					</td>
					<td>
						<table cellspacing="2" cellpadding="2" border="0">
							<tr>
								<cfloop from="1" to="#attributes.maxPages#" index="groupNumber_idx">
									<td align="center" valign="middle">
										<cfif groupNumber_idx eq attributes.groupNumber>
											[#groupNumber_idx#]
										<cfelse>
											<a href="##" onclick="gotoPage(#groupNumber_idx#);">
												<strong>#groupNumber_idx#</dtrong>
											</a>
										</cfif>
									</td>
									<cfif groupNumber_idx mod 20 eq 0>
										</tr>
										<tr>
									</cfif>
								</cfloop>
							</tr>
						</table>
					</td>
					<td width="16" valign="middle" align="right">
						<cfif attributes.maxPages gt attributes.groupNumber>
							<a href="##" onclick="gotoPage(#attributes.groupNumber + 1#);">
								<img title="Next" src="#attributes.imagePath#/arrow_right.gif" width="16" height="16" border="0" align="absmiddle" alt="Next">
							</a>
						</cfif>
					</td>
				</tr>
				</tbody>
				</table>
			</cfoutput>
		</td>
	</tr>
	</cfif>
	</tbody>
</table>
</cfoutput>
<!--- end main table --->


<!--- end pagination table --->
</div>
<cfoutput>
	<form action="#attributes.formAction#" method="#attributes.formMethod#" name="tableForm">
		<input type="hidden" name="#attributes.tableKey#" value="" />
		<input type="hidden" name="#attributes.eventField#" value="#attributes.searchEvent#" />
		<input type="hidden" name="sortBy" value="#lcase(attributes.sortBy)#" />
		<input type="hidden" name="sortDir" value="#attributes.sortDir#" />
		<input type="hidden" name="groupNumber" value="#attributes.groupNumber#" />
		<input type="hidden" name="groupSize" value="#attributes.groupSize#" />
		<input type="hidden" name="searchField" value="#attributes.searchField#" />
		<input type="hidden" name="searchFor" value="#attributes.searchFor#" />
		<input type="hidden" name="dateFrom" value="#attributes.dateFrom#" />
		<input type="hidden" name="dateTo" value="#attributes.dateTo#" />
	<cfloop list="#attributes.formFields#" index="tmpFormField" delimiters=",">
		<cfset tmpField = getToken(tmpFormField,1,'=') />
		<cfset tmpVal = getToken(tmpFormField,2,'=') />
		<input type="hidden" name="#tmpField#" value="#tmpVal#" />
	</cfloop>
	</form>
</cfoutput>
</cfif>

<cfif attributes.showAttributes>
	<cfdump var="#attributes#">
</cfif>

<!--- error handling --->
<cfcatch type="any">
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