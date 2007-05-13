<cfsilent>
<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

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
</cfsilent>
<cfoutput>
<style>
<cfinclude template="style.css">
</style>
<table border="1" cellpadding="0" cellspacing="3" class="fw_errorTables" align="center">

  <tr>
    <th colspan="2" >ColdBox Bug Report Details </th>
  </tr>

  <tr>
    <td colspan="2"><h2>#Exception.getExtramessage()#</h2></td>
  </tr>

<cfif Exception.getErrorType() eq "Application">

  <tr>
    <td width="75" align="right" class="fw_errorTablesTitles">Current Event: </td>
    <td width="463" ><cfif Event.valueExists("event")>#Event.getValue("event")#<cfelse>N/A</cfif></td>
  </tr>
  <tr>
    <td align="right" class="fw_errorTablesTitles">Current Layout: </td>
    <td ><cfif Event.valueExists("currentLayout")>#Event.getValue("currentLayout")#<cfelse>N/A</cfif></td>
  </tr>
  <tr>
    <td align="right" class="fw_errorTablesTitles">Current View: </td>
    <td ><cfif Event.valueExists("currentView")>#Event.getValue("currentView")#<cfelse>N/A</cfif></td>
  </tr>
</cfif>
  <tr>
    <td align="right" class="fw_errorTablesTitles">Bug Date:</td>
    <td >#dateformat(now(), "MM/DD/YYYY")# #timeformat(now(),"hh:MM:SS TT")#</td>
  </tr>
  <tr>
    <td align="right" class="fw_errorTablesTitles">Coldfusion ID: </td>
    <td ><cfif structkeyExists(session, "cfid")>
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
    <td >#CGI.CF_TEMPLATE_PATH#</td>
  </tr>
  <tr>
    <td align="right" class="fw_errorTablesTitles"> Host &amp; Server: </td>
    <td >#cgi.http_host# #controller.getPlugin("fileUtilities").getInetHost()#</td>
  </tr>
  <tr>
    <td align="right" class="fw_errorTablesTitles">Query String: </td>
    <td >#cgi.QUERY_STRING#</td>
  </tr>
  <cfif len(cgi.HTTP_REFERER) neq 0>
  <tr>
    <td align="right" class="fw_errorTablesTitles">Referrer:</td>
    <td >#cgi.HTTP_REFERER#</td>
  </tr>
 </cfif>
  <tr>
    <td align="right" class="fw_errorTablesTitles">Browser:</td>
    <td >#cgi.HTTP_USER_AGENT#</td>
  </tr>

  <cfif isStruct(Exception.getExceptionStruct()) >
  <tr>
    <th colspan="2" >Exception Structure </th>
  </tr>
  	  <cfif Exception.getType() neq "">
	  <tr >
		<td colspan="2" class="fw_errorTablesTitles">Error Type & Code:</td>
	  </tr>
	  <tr>
		<td colspan="2" >#Exception.gettype()# : <cfif Exception.geterrorCode() eq "">[N/A]<cfelse>#Exception.getErrorCode()#</cfif></td>
	  </tr>
	  </cfif>
	  <cfif Exception.getExtendedINfo() neq "">
	  <tr >
		<td colspan="2" class="fw_errorTablesTitles">Extended Info:</td>
	  </tr>
	  <tr>
		<td colspan="2" >#Exception.getExtendedInfo()#</td>
	  </tr>
	  </cfif>
	  <tr >
		<td colspan="2" class="fw_errorTablesTitles">Message:</td>
	  </tr>
	  <tr>
		<td colspan="2" >#Exception.getmessage()#</td>
	  </tr>

	  <cfif len(exception.getDetail()) neq 0>
	  <tr >
		<td colspan="2" class="fw_errorTablesTitles">Detail:</td>
	  </tr>
	  <tr>
		<td colspan="2" >#Exception.getDetail()#</td>
	  </tr>
	  </cfif>

	  <cfif Exception.getmissingFileName() neq  "">
	  <tr >
		<td colspan="2" class="fw_errorTablesTitles">Missing File Name:</td>
	  </tr>
	  <tr>
		<td colspan="2" >#Exception.getmissingFileName()#</td>
	  </tr>
	  </cfif>

	  <cfif findnocase("database", Exception.getType() )>
	  <tr >
		<th colspan="2" >Database Exception Information:</th>
	  </tr>
	  <tr >
		<td colspan="2" class="fw_errorTablesTitles">NativeErrorCode & SQL State:</td>
	  </tr>
	  <tr>
		<td colspan="2" >#Exception.getNativeErrorCode()# : #Exception.getSQLState()#</td>
	  </tr>
	  <tr >
		<td colspan="2" class="fw_errorTablesTitles">SQL Sent:</td>
	  </tr>
	  <tr>
		<td colspan="2" >#Exception.getSQL()#</td>
	  </tr>
	  <tr >
		<td colspan="2" class="fw_errorTablesTitles">Database Driver Error Message:</td>
	  </tr>
	  <tr>
		<td colspan="2" >#Exception.getqueryError()#</td>
	  </tr>
	  <tr >
		<td colspan="2" class="fw_errorTablesTitles">Name-Value Pairs:</td>
	  </tr>
	  <tr>
		<td colspan="2" >#Exception.getWhere()#</td>
	  </tr>
	  </cfif>

	  <tr >
		<th colspan="2" >Stack Trace:</th>
	  </tr>
	  <tr>
		<td colspan="2" >
			<div class="fw_stacktrace"><pre>#Exception.getstackTrace()#</pre></div>
		</td>
	  </tr>

	  <cfif ArrayLen(Exception.getTagContext()) >
	  <cfset arrayTagContext = Exception.getTagContext()>
	  <tr >
		<th colspan="2" >Tag Context:</th>
	  </tr>
	  <cfloop from="1" to="#arrayLen(arrayTagContext)#" index="i">
	  <tr >
		<td align="right" class="fw_errorTablesTitles">ID:</td>
	    <td ><cfif not structKeyExists(arrayTagContext[i], "ID")>??<cfelse>#arrayTagContext[i].ID#</cfif></td>
	  </tr>

	   <tr >
		<td align="right" class="fw_errorTablesTitles">LINE:</td>
	    <td >#arrayTagContext[i].LINE#</td>
	   </tr>

	   <tr >
		<td align="right" class="fw_errorTablesTitles">Template:</td>
	    <td >#arrayTagContext[i].Template#</td>
	   </tr>
	   <tr >
		<td colspan="2"></td>
	    </tr>
	  </cfloop>
	  </cfif>
  </cfif>

  <tr>
    <th colspan="2" >Extra Information Dump </th>
  </tr>

  <tr>
    <td colspan="2" >
    <cfif isSimpleValue(Exception.getExtraInfo())>
    	<cfif Exception.getExtraInfo() eq "">[N/A]<cfelse>#Exception.getExtraInfo()#</cfif>
    <cfelse>
	    <cfdump var="#Exception.getExtraInfo()#">
	</cfif>
    </td>
  </tr>

</table>
</cfoutput>