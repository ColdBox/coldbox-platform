<cfsilent>
<!-----------------------------------------------------------------------
Template :  BugReport.cfm
Author 	 :	Luis Majano
Date     :	September 25, 2005
Description :
	This is the BugReport template that gets emailed to the administrators

Modification History:
10/13/2005 - Moved reqCollection from session to request.
12/26/2005 - Exception Struct empty check.
06/09/2006 - Updated to coldbox. Changed all isDefined to structKeyExists
----------------------------------------------------------------------->
<!--- ************************************************************* --->
</cfsilent>
<cfoutput>
<style>
<cfinclude template="style.css">
</style>
<table width="600" border="1" cellpadding="0" cellspacing="5" class="fw_errorTables">

  <tr>
    <td colspan="2" class="fw_errorTitles">Bug Report Details </td>
  </tr>
  <tr>
    <td colspan="2" class="fw_errorTablesCells">#Exception.getExtramessage()#</td>
    </tr>
<cfif Exception.getErrorType() eq "Application">
  
  <tr>
    <td width="122" align="right" class="fw_errorTablesTitles">Current Event: </td>
    <td width="463" class="fw_errorTablesCells"><cfif valueExists("event")>#getValue("event")#<cfelse>N/A</cfif></td>
  </tr>
  <tr>
    <td align="right" class="fw_errorTablesTitles">Current Layout: </td>
    <td class="fw_errorTablesCells"><cfif valueExists("currentLayout")>#getValue("currentLayout")#<cfelse>N/A</cfif></td>
  </tr>
  <tr>
    <td align="right" class="fw_errorTablesTitles">Current View: </td>
    <td class="fw_errorTablesCells"><cfif valueExists("currentView")>#getvalue("currentView")#<cfelse>N/A</cfif></td>
  </tr>
</cfif>
  <tr>
    <td align="right" class="fw_errorTablesTitles">Bug Date:</td>
    <td class="fw_errorTablesCells">#dateformat(now(), "MM/DD/YYYY")# #timeformat(now(),"hh:MM:SS TT")#</td>
  </tr>
  <tr>
    <td align="right" class="fw_errorTablesTitles">Coldfusion ID: </td>
    <td class="fw_errorTablesCells"><cfif structkeyExists(session, "cfid")>
		CFID=#session.CFID# ;
		<cfelseif structkeyExists(client,"cfid")>
		CFID=#client.CFID# ;
		</cfif>
		<cfif structkeyExists(session,"CFToken")>
		CFToken=#session.CFToken# ;
		<cfelseif structkeyExists(client,"CFTOken")>
		CFToken=#client.CFToken# ;
		</cfif>
		<cfif structkeyExists(session,"sessionID")>
		JSessionID=#session.sessionID#
		</cfif></td>
  </tr>
  <tr>
    <td align="right" class="fw_errorTablesTitles">Template Path : </td>
    <td class="fw_errorTablesCells">#CGI.CF_TEMPLATE_PATH#</td>
  </tr>
  <tr>
    <td align="right" class="fw_errorTablesTitles"> Host &amp; Server: </td>
    <td class="fw_errorTablesCells">#cgi.http_host# #getPlugin("fileUtilities").getInetHost()#</td>
  </tr>
  <tr>
    <td align="right" class="fw_errorTablesTitles">Query String: </td>
    <td class="fw_errorTablesCells">#cgi.QUERY_STRING#</td>
  </tr>
  <tr>
    <td align="right" class="fw_errorTablesTitles">Referrer:</td>
    <td class="fw_errorTablesCells">#cgi.HTTP_REFERER#</td>
  </tr>
  <tr>
    <td align="right" class="fw_errorTablesTitles">Browser:</td>
    <td class="fw_errorTablesCells">#cgi.HTTP_USER_AGENT#</td>
  </tr>
  <cfif isStruct(Exception.getExceptionStruct()) >
  <tr>
    <td colspan="2" class="fw_errorTitles">Exception Structure </td>
  </tr>
  	  <cfif Exception.getType() neq "">
	  <tr >
		<td colspan="2" class="fw_errorTablesTitles">Error Type & Code:</td>
	  </tr>
	  <tr>
		<td colspan="2" class="fw_errorTablesCells">#Exception.gettype()# : <cfif Exception.geterrorCode() eq "">[N/A]<cfelse>#Exception.getErrorCode()#</cfif></td>
	  </tr>
	  </cfif>
	  <cfif Exception.getExtendedINfo() neq "">
	  <tr >
		<td colspan="2" class="fw_errorTablesTitles">Extended Info:</td>
	  </tr>
	  <tr>
		<td colspan="2" class="fw_errorTablesCells">#Exception.getExtendedInfo()#</td>
	  </tr>
	  </cfif>
	  <tr >
		<td colspan="2" class="fw_errorTablesTitles">Message:</td>
	  </tr>
	  <tr>
		<td colspan="2" class="fw_errorTablesCells">#Exception.getmessage()#</td>
	  </tr>
	  <tr >
		<td colspan="2" class="fw_errorTablesTitles">Detail:</td>
	  </tr>
	  <tr>
		<td colspan="2" class="fw_errorTablesCells">#Exception.getDetail()#</td>
	  </tr>

	  <cfif Exception.getmissingFileName() neq  "">
	  <tr >
		<td colspan="2" class="fw_errorTablesTitles">Missing File Name:</td>
	  </tr>
	  <tr>
		<td colspan="2" class="fw_errorTablesCells">#Exception.getmissingFileName()#</td>
	  </tr>
	  </cfif>

	  <cfif findnocase("database", Exception.getType() )>
	  <tr >
		<td colspan="2" class="fw_errorTitles">Database Exception Information:</td>
	  </tr>
	  <tr >
		<td colspan="2" class="fw_errorTablesTitles">NativeErrorCode & SQL State:</td>
	  </tr>
	  <tr>
		<td colspan="2" class="fw_errorTablesCells">#Exception.getNativeErrorCode()# : #Exception.getSQLState()#</td>
	  </tr>
	  <tr >
		<td colspan="2" class="fw_errorTablesTitles">SQL Sent:</td>
	  </tr>
	  <tr>
		<td colspan="2" class="fw_errorTablesCells">#Exception.getSQL()#</td>
	  </tr>
	  <tr >
		<td colspan="2" class="fw_errorTablesTitles">Database Driver Error Message:</td>
	  </tr>
	  <tr>
		<td colspan="2" class="fw_errorTablesCells">#Exception.getqueryError()#</td>
	  </tr>
	  <tr >
		<td colspan="2" class="fw_errorTablesTitles">Name-Value Pairs:</td>
	  </tr>
	  <tr>
		<td colspan="2" class="fw_errorTablesCells">#Exception.getWhere()#</td>
	  </tr>
	  </cfif>

	  <tr >
		<td colspan="2" class="fw_errorTitles">Stack Trace:</td>
	  </tr>
	  <tr>
		<td colspan="2" class="fw_errorTablesCells">#Exception.getstackTrace()#</td>
	  </tr>

	  <cfif ArrayLen(Exception.getTagContext()) >
	  <cfset arrayTagContext = Exception.getTagContext()>
	  <tr >
		<td colspan="2" class="fw_errorTitles">Tag Context:</td>
	  </tr>
	  <cfloop from="1" to="#arrayLen(arrayTagContext)#" index="i">
	  <tr >
		<td align="right" class="fw_errorTablesTitles">ID:</td>
	    <td class="fw_errorTablesCells"><cfif not structKeyExists(arrayTagContext[i], "ID")>??<cfelse>#arrayTagContext[i].ID#</cfif></td>
	  </tr>

	   <tr >
		<td align="right" class="fw_errorTablesTitles">LINE:</td>
	    <td class="fw_errorTablesCells">#arrayTagContext[i].LINE#</td>
	   </tr>

	   <tr >
		<td align="right" class="fw_errorTablesTitles">Template:</td>
	    <td class="fw_errorTablesCells">#arrayTagContext[i].Template#</td>
	   </tr>
	   <tr >
		<td colspan="2"></td>
	    </tr>
	  </cfloop>
	  </cfif>
  </cfif>

  <tr>
    <td colspan="2" class="fw_errorTitles">Extra Information Dump </td>
  </tr>
  <tr>
    <td colspan="2" class="fw_errorTablesCells">
    <cfif isSimpleValue(Exception.getExtraInfo())>
    	<cfif Exception.getExtraInfo() eq "">[N/A]<cfelse>#Exception.getExtraInfo()#</cfif>
    <cfelse>
	    <cfdump var="#Exception.getExtraInfo()#">
	</cfif>
    </td>
  </tr>

</table>
</cfoutput>