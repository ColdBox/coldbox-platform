<style>
.errorTables{
	font-size: 13px;
	font-family: Arial,Helvetica,sans-serif;
	border:2px solid #000000;
	width: 98%;
}
.errorTables th{
	background-color: #A1D918;
	color:#000000;
	font-weight: bold;
	padding:5px 5px 5px 5px;
}
.errorTables td{
	font-size: 10px;
	background-color: #ffffff;
	border:1px dotted #999999;
	padding: 5px 5px 5px 5px;
}

</style>
<cfoutput>
<table border="1" cellpadding="0" cellspacing="3" class="errorTables" align="center">

	<tr>
	  <th colspan="2" >Custom Bug Report Details </th>
	</tr>
	
	<tr>
	  <td colspan="2"><h2>#exceptionBean.getExtramessage()#</h2></td>
	</tr>

	<cfif exceptionBean.getErrorType() eq "Application">
		<tr>
		  <td width="75" align="right" class="errorTablesTitles">Current Event: </td>
		  <td width="463" ><cfif Event.getCurrentEvent() neq "">#Event.getCurrentEvent()#<cfelse>N/A</cfif></td>
		</tr>
		<tr>
		  <td align="right" class="errorTablesTitles">Current Layout: </td>
		  <td ><cfif Event.getCurrentLayout() neq "">#Event.getCurrentLayout()#<cfelse>N/A</cfif></td>
		</tr>
		<tr>
		  <td align="right" class="errorTablesTitles">Current View: </td>
		  <td ><cfif Event.getCurrentView() neq "">#Event.getCurrentView()#<cfelse>N/A</cfif></td>
		</tr>
	</cfif>

	 <tr>
	   <td align="right" class="errorTablesTitles">Bug Date:</td>
	   <td >#dateformat(now(), "MM/DD/YYYY")# #timeformat(now(),"hh:MM:SS TT")#</td>
	 </tr>
	 
	 <tr>
	   <td align="right" class="errorTablesTitles">Coldfusion ID: </td>
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
	   <td align="right" class="errorTablesTitles">Template Path : </td>
	   <td >#CGI.CF_TEMPLATE_PATH#</td>
	 </tr>
	 <tr>
	   <td align="right" class="errorTablesTitles"> Host &amp; Server: </td>
	   <td >#cgi.http_host# #controller.getPlugin("Utilities").getInetHost()#</td>
	 </tr>
	 <tr>
	   <td align="right" class="errorTablesTitles">Query String: </td>
	   <td >#cgi.QUERY_STRING#</td>
	 </tr>
	
	<cfif len(cgi.HTTP_REFERER) neq 0>
	 <tr>
	   <td align="right" class="errorTablesTitles">Referrer:</td>
	   <td >#cgi.HTTP_REFERER#</td>
	 </tr>
	</cfif>
	
	 <cfif isStruct(exceptionBean.getExceptionStruct()) >
	 <tr>
	   <th colspan="2" >Exception Structure </th>
	 </tr>
	 
	 <cfif exceptionBean.getType() neq "">
		  <tr >
			<td colspan="2" class="errorTablesTitles">Error Type & Code:</td>
		  </tr>
		  <tr>
			<td colspan="2" >#exceptionBean.gettype()# : <cfif exceptionBean.geterrorCode() eq "">[N/A]<cfelse>#exceptionBean.getErrorCode()#</cfif></td>
		  </tr>
	 </cfif>
	 
	 <cfif exceptionBean.getExtendedINfo() neq "">
		  <tr >
			<td colspan="2" class="errorTablesTitles">Extended Info:</td>
		  </tr>
		  <tr>
			<td colspan="2" >#exceptionBean.getExtendedInfo()#</td>
		  </tr>
	 </cfif>
	
	  <tr >
		<td colspan="2" class="errorTablesTitles">Message:</td>
	  </tr>
	  <tr>
		<td colspan="2" >#exceptionBean.getmessage()#</td>
	  </tr>
	
	  <cfif len(exceptionBean.getDetail()) neq 0>
		  <tr >
			<td colspan="2" class="errorTablesTitles">Detail:</td>
		  </tr>
		  <tr>
			<td colspan="2" >#exceptionBean.getDetail()#</td>
		  </tr>
	  </cfif>
	
	  <cfif exceptionBean.getmissingFileName() neq  "">
		  <tr >
			<td colspan="2" class="errorTablesTitles">Missing File Name:</td>
		  </tr>
		  <tr>
			<td colspan="2" >#exceptionBean.getmissingFileName()#</td>
		  </tr>
	  </cfif>
	
	  <cfif findnocase("database", exceptionBean.getType() )>
		  <tr >
			<th colspan="2" >Database Exception Information:</th>
		  </tr>
		  <tr >
			<td colspan="2" class="errorTablesTitles">NativeErrorCode & SQL State:</td>
		  </tr>
		  <tr>
			<td colspan="2" >#exceptionBean.getNativeErrorCode()# : #exceptionBean.getSQLState()#</td>
		  </tr>
		  <tr >
			<td colspan="2" class="errorTablesTitles">SQL Sent:</td>
		  </tr>
		  <tr>
			<td colspan="2" >#exceptionBean.getSQL()#</td>
		  </tr>
		  <tr >
			<td colspan="2" class="errorTablesTitles">Database Driver Error Message:</td>
		  </tr>
		  <tr>
			<td colspan="2" >#exceptionBean.getqueryError()#</td>
		  </tr>
		  <tr >
			<td colspan="2" class="errorTablesTitles">Name-Value Pairs:</td>
		  </tr>
		  <tr>
			<td colspan="2" >#exceptionBean.getWhere()#</td>
		  </tr>
	  </cfif>
	  
	  </cfif>

</table>
</cfoutput>