<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Template :  BugReport.cfm
Author 	 :	Luis Majano
Date     :	September 25, 2005
Description :
	This is the BugReport template that gets emailed to the administrators
----------------------------------------------------------------------->
<cfscript>
	// Detect Session Scope
	sessionScopeExists = true; 
	try { structKeyExists(session ,'x'); } catch (any e) { sessionScopeExists = false; }	
</cfscript>
<cfoutput>
<!--- Param Form Scope --->
<cfparam name="form" default="#structnew()#">

<!--- StyleSheets --->
<style type="text/css"><cfinclude template="/coldbox/system/includes/css/cbox-debugger.pack.css"></style>

<div class="fw_errorDiv">
	<h1>Oops! exception Encountered</h1>
	
	<div class="fw_errorNotice">
	<!--- CUSTOM SET MESSAGE --->
	<h3>#exception.getExtramessage()#</h3>
	
	<!--- ERROR TYPE --->
	<cfif exception.getType() neq "">
	<strong>Error Type: </strong> #exception.gettype()# : <cfif exception.geterrorCode() eq "">[N/A]<cfelse>#exception.getErrorCode()#</cfif><br />
	</cfif>
	
	<!--- ERROR exceptionS --->
	<cfif isStruct(exception.getexceptionStruct()) >
		<strong>Error Messages:</strong>
		#exception.getmessage()#<br />
		<cfif exception.getExtendedINfo() neq "">
			#exception.getExtendedInfo()#<br />
	 	</cfif>
	 	<cfif len(exception.getDetail()) neq 0>
		 	#exception.getDetail()#
		 </cfif>
	</cfif>

	</div>
</div>

<table border="0" cellpadding="0" cellspacing="3" class="fw_errorTables" align="center">

	<!--- TAG CONTEXT --->
	<cfif ArrayLen(exception.getTagContext()) >
		  <cfset arrayTagContext = exception.getTagContext()>
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
		   <tr class="fw_errorTablesBreak">
			<td align="right" class="fw_errorTablesTitles">Template:</td>
		    <td >#arrayTagContext[i].Template#</td>
		   </tr>
		  </cfloop>
	</cfif>
	 
	<tr>
	   <th colspan="2" >Framework Snapshot</th>
	</tr>
	 
	<cfif exception.getErrorType() eq "Application">
		<tr>
		  <td width="75" align="right" class="fw_errorTablesTitles">Current Event: </td>
		  <td width="463" ><cfif Event.getCurrentEvent() neq "">#Event.getCurrentEvent()#<cfelse>N/A</cfif></td>
		</tr>
		<tr>
		  <td align="right" class="fw_errorTablesTitles">Current Layout: </td>
		  <td >
		  	<cfif Event.getCurrentLayout() neq "">#Event.getCurrentLayout()#<cfelse>N/A</cfif>
		  	(Module: #event.getCurrentLayoutModule()#)
		  </td>
		</tr>
		<tr>
		  <td align="right" class="fw_errorTablesTitles">Current View: </td>
		  <td ><cfif Event.getCurrentView() neq "">#Event.getCurrentView()#<cfelse>N/A</cfif></td>
		</tr>
	</cfif>

	 <tr>
	   <td align="right" class="fw_errorTablesTitles">Bug Date:</td>
	   <td >#dateformat(now(), "MM/DD/YYYY")# #timeformat(now(),"hh:MM:SS TT")#</td>
	 </tr>
	 
	 <tr>
	   <td align="right" class="fw_errorTablesTitles">Coldfusion ID: </td>
	   <td >
	   	<cfif sessionScopeExists>
			<cfif isDefined("session") and structkeyExists(session, "cfid")>
			CFID=#session.CFID# ;
			<cfelseif isDefined("client") and structkeyExists(client,"cfid")>
			CFID=#client.CFID# ;
			</cfif>
			<cfif isDefined("session") and structkeyExists(session,"CFToken")>
			CFToken=#session.CFToken# ;
			<cfelseif isDefined("client") and structkeyExists(client,"CFToken")>
			CFToken=#client.CFToken# ;
			</cfif>
			<cfif isDefined("session") and structkeyExists(session,"sessionID")>
			JSessionID=#session.sessionID#
			</cfif>
	   <cfelse>
	   		Session Scope Not Enabled
	   </cfif>
		</td>
	 </tr>
	 <tr>
	   <td align="right" class="fw_errorTablesTitles">Template Path : </td>
	   <td >#htmlEditFormat(CGI.CF_TEMPLATE_PATH)#</td>
	 </tr>
	  <tr>
	   <td align="right" class="fw_errorTablesTitles">Path Info : </td>
	   <td >#htmlEditFormat(CGI.PATH_INFO)#</td>
	 </tr>
	 <tr>
	   <td align="right" class="fw_errorTablesTitles"> Host &amp; Server: </td>
	   <td >#htmlEditFormat(cgi.http_host)# #controller.getPlugin("JVMUtils").getInetHost()#</td>
	 </tr>
	 <tr>
	   <td align="right" class="fw_errorTablesTitles">Query String: </td>
	   <td >#htmlEditFormat(cgi.QUERY_STRING)#</td>
	 </tr>
	
	<cfif len(cgi.HTTP_REFERER)>
	 <tr>
	   <td align="right" class="fw_errorTablesTitles">Referrer:</td>
	   <td >#htmlEditFormat(cgi.HTTP_REFERER)#</td>
	 </tr>
	</cfif>
	<tr>
	   <td align="right" class="fw_errorTablesTitles">Browser:</td>
	   <td >#htmlEditFormat(cgi.HTTP_USER_AGENT)#</td>
	</tr>
	<tr>
	   <td align="right" class="fw_errorTablesTitles"> Remote Address: </td>
	   <td >#htmlEditFormat(cgi.remote_addr)#</td>
	 </tr>
	 <cfif isStruct(exception.getexceptionStruct()) >
	 
	  <cfif exception.getmissingFileName() neq  "">
		  <tr>
		   <th colspan="2" >Missing Include exception</th>
		  </tr>
		  <tr >
			<td colspan="2" class="fw_errorTablesTitles">Missing File Name:</td>
		  </tr>
		  <tr>
			<td colspan="2" >#exception.getmissingFileName()#</td>
		  </tr>
	  </cfif>
	
	  <cfif findnocase("database", exception.getType() )>
		  <tr >
			<th colspan="2" >Database exception Information:</th>
		  </tr>
		  <tr >
			<td colspan="2" class="fw_errorTablesTitles">NativeErrorCode & SQL State:</td>
		  </tr>
		  <tr>
			<td colspan="2" >#exception.getNativeErrorCode()# : #exception.getSQLState()#</td>
		  </tr>
		  <tr >
			<td colspan="2" class="fw_errorTablesTitles">SQL Sent:</td>
		  </tr>
		  <tr>
			<td colspan="2" >#exception.getSQL()#</td>
		  </tr>
		  <tr >
			<td colspan="2" class="fw_errorTablesTitles">Database Driver Error Message:</td>
		  </tr>
		  <tr>
			<td colspan="2" >#exception.getqueryError()#</td>
		  </tr>
		  <tr >
			<td colspan="2" class="fw_errorTablesTitles">Name-Value Pairs:</td>
		  </tr>
		  <tr>
			<td colspan="2" >#exception.getWhere()#</td>
		  </tr>
	  </cfif>
	</cfif>
	 <tr >
		<th colspan="2" >Form variables:</th>
	 </tr>
	 <cfloop collection="#form#" item="key">
	 	<cfif key neq "fieldnames">
		 <tr>
		   <td align="right" class="fw_errorTablesTitles">#htmlEditFormat( key )#:</td>
		   <cfif isSimpleValue( form[ key ] )>
		   <td>#htmlEditFormat( form[ key ] )#</td>
		   <cfelse>
		   <td><cfdump var="#form[ key ]#"></td>
		   </cfif>
		 </tr>
	 	</cfif>
	 </cfloop>
	 <tr >
		<th colspan="2" >Session Storage:</th>
	 </tr>
	 <cfif sessionScopeExists>
	 	 <cfset sessioncbstorage = controller.getPlugin('SessionStorage').getStorage()>
		 <cfloop collection="#sessioncbstorage#" item="key">
		 <tr>
		   <td align="right" class="fw_errorTablesTitles"> #key#: </td>
		   <td><cfif isSimpleValue( sessioncbstorage[ key ] )>#htmlEditFormat( sessioncbstorage[ key ] )#<cfelse>#key# <cfdump var="#sessioncbstorage[ key ]#"></cfif></td>
		 </tr>
		 </cfloop>
	 <cfelse>
		 <tr>
		   <td align="right" class="fw_errorTablesTitles"> N/A </td>
		   <td >Session Scope Not Enabled</td>
		 </tr>	 	
	 </cfif>
	 <tr >
		<th colspan="2" >Cookies:</th>
	 </tr>
	 <cfloop collection="#cookie#" item="key">
	 <tr>
	   <td align="right" class="fw_errorTablesTitles"> #key#: </td>
	   <td >#htmlEditFormat( cookie[ key ] )#</td>
	 </tr>
	 </cfloop>
	 
	 <tr >
		<th colspan="2" >Stack Trace:</th>
	 </tr>
	 <tr>
		<td colspan="2" >
			<div class="fw_stacktrace"><pre>#exception.getstackTrace()#</pre></div>
		</td>
	 </tr>
	 	
	 <tr>
	   <th colspan="2" >Extra Information Dump </th>
	 </tr>
	
	 <tr>
	    <td colspan="2" >
	    <cfif isSimpleValue( exception.getExtraInfo() )>
	   		<cfif not len(exception.getExtraInfo())>[N/A]<cfelse>#exception.getExtraInfo()#</cfif>
	   	<cfelse>
	   		<cfdump var="#exception.getExtraInfo()#" expand="false">
		</cfif>
	    </td>
	 </tr>

</table>
</cfoutput>