<cfsetting enablecfoutputonly="true">
<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Template :  debug.cfm
Author 	 :	Luis Majano
Date     :	September 25, 2005
Description :
	Debugging template for the application
----------------------------------------------------------------------->
<cfoutput>
<!--- Public Collection --->
<table border="0" cellpadding="0" cellspacing="1" class="fw_debugTables" width="100%">
  <tr>
  	<th colspan="2">#thisCollectionType# Collection</th>
  </tr>
  <cfloop collection="#thisCollection#" item="vars">
  <cfset varVal = thisCollection[vars]>
  <tr>
	<td align="right" width="15%" class="fw_debugTablesTitles"><strong>#lcase(vars)#:</strong></td>
	<td  class="fw_debugTablesCells">
	<cfif isSimpleValue(varVal) >
		<cfif varVal eq "">
			<span class="fw_redText">N/A</span>
		<cfelse>
			#htmlEditFormat(varVal)#
		</cfif>
	<cfelse>

		<!--- Max Display For Queries  --->
		<cfif isQuery(varVal) and (varVal.recordCount gt getDebuggerConfig().getmaxRCPanelQueryRows())>
			<cfquery name="varVal" dbType="query" maxrows="#getDebuggerConfig().getmaxRCPanelQueryRows()#">
				select * from varVal
			</cfquery>
			<cfdump var="#varVal#" label="Query Truncated to #getDebuggerConfig().getmaxRCPanelQueryRows()# records" expand="false">
		<cfelseif isObject(varVal)>
			<cfdump var="#varVal#" expand="false" top="2">
		<cfelse>
			<cfdump var="#varVal#" expand="false">
		</cfif>

	</cfif>
	</td>
  </tr>
  </cfloop>
</table>
</cfoutput>
<cfsetting enablecfoutputonly="false">