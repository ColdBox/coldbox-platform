<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
A reporting template about exceptions in your ColdBox Apps
----------------------------------------------------------------------->
<cfscript>
	// Detect Session Scope
	sessionScopeExists = true;
	try { structKeyExists( session ,'x' ); }
	catch ( any e ) {
		sessionScopeExists = false;
	}
	try{ thisInetHost = createObject( "java", "java.net.InetAddress" ).getLocalHost().getHostName(); }
	catch( any e ){
		thisInetHost = "localhost";
	}
</cfscript>
<cfoutput>
<!--- Param Form Scope --->
<cfparam name="form" default="#structnew()#">
<!--- StyleSheets --->
<style type="text/css"><cfinclude template="/coldbox/system/includes/css/cbox-debugger.css.cfm"></style>
<div class="cb-container">
	<h1>
		<cfif oException.geterrorCode() neq "" AND oException.getErrorCode() neq 0>
			#oException.getErrorCode()# :
		</cfif>
		Oopsy! Something went wrong!</h1>

	<div class="notice">
		<cfif oException.getExtraMessage() neq "">
		<!--- CUSTOM SET MESSAGE --->
		<h3>#oException.getExtramessage()#</h3>
		</cfif>

		<!--- Event --->
		<strong>Event: </strong><cfif event.getCurrentEvent() neq "">#event.getCurrentEvent()#<cfelse>N/A</cfif>
		<br>
		<strong>Routed URL: </strong><cfif event.getCurrentRoutedURL() neq "">#event.getCurrentRoutedURL()#<cfelse>N/A</cfif>
		<br>
		<strong>Layout: </strong><cfif Event.getCurrentLayout() neq "">#Event.getCurrentLayout()#<cfelse>N/A</cfif> (Module: #event.getCurrentLayoutModule()#)
		<br>
		<strong>View: </strong><cfif Event.getCurrentView() neq "">#Event.getCurrentView()#<cfelse>N/A</cfif>
		<br>
		<strong>Timestamp: </strong>#dateformat(now(), "MM/DD/YYYY")# #timeformat(now(),"hh:MM:SS TT")#

		<hr>

		<!--- ERROR TYPE --->
		<cfif oException.getType() neq "">
			<strong>Type: </strong> #oException.gettype()# <br>
		</cfif>

		<!--- ERROR oExceptionS --->
		<cfif isStruct(oException.getExceptionStruct()) >
			<strong>Messages:</strong>
			#oException.getmessage()#
			<cfif oException.getExtendedINfo() neq "">
			#oException.getExtendedInfo()#<br />
		 	</cfif>
		 	<cfif len(oException.getDetail()) neq 0>
			 	#oException.getDetail()#
			 </cfif>
		</cfif>

	</div>

	<div class="extended">
		<!--- TAG CONTEXT --->
		<h2>Tag Context:</h2>
		<table class="table" align="center" cellspacing="0">
		<cfif ArrayLen( oException.getTagContext() )>
			  <cfset arrayTagContext = oException.getTagContext()>
			  <cfloop from="1" to="#arrayLen(arrayTagContext)#" index="i">
				  <!--- Don't clutter the screen with this information unless it's actually useful --->
			  	  <cfif structKeyExists( arrayTagContext[i], "ID" ) and len( arrayTagContext[i].ID ) and arrayTagContext[i].ID neq "??">
			  <tr >
						<td align="right" class="info">Tag:</td>
					    <td>#arrayTagContext[i].ID#</td>
			  </tr>
				  </cfif>
			   <tr >
					<td align="right" class="info">Template:</td>
				    <td style="color:green;"><strong>#arrayTagContext[i].Template#</strong></td>
				   </tr>
			  	  <cfif structKeyExists( arrayTagContext[i], "codePrintHTML" )>
					  <tr class="tablebreak">
				<td align="right" class="info">LINE:</td>
					    <td>#arrayTagContext[i].codePrintHTML#</td>
			   </tr>
				  <cfelse>
			   <tr class="tablebreak">
						<td align="right" class="info">Line:</td>
					    <td ><strong>#arrayTagContext[i].LINE#</strong></td>
			   </tr>
				  </cfif>
			  </cfloop>
		</cfif>
		</table>

		<h2>Stack Trace:</h2>
		<div class="stacktrace">#processStackTrace( oException.getstackTrace() )#</div>

		<!--- FRAMEWORK SNAPSHOT --->
		<h2>FRAMEWORK SNAPSHOT:</h2>
		<table class="table" align="center">
			<tr>
			   <td align="right" class="info">Bug Date:</td>
			   <td >#dateformat(now(), "MM/DD/YYYY")# #timeformat(now(),"hh:MM:SS TT")#</td>
			 </tr>

			 <tr>
			   <td align="right" class="info">Coldfusion ID: </td>
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
			   <td align="right" class="info">Template Path : </td>
			   <td >#htmlEditFormat(CGI.CF_TEMPLATE_PATH)#</td>
			 </tr>
			  <tr>
			   <td align="right" class="info">Path Info : </td>
			   <td >#htmlEditFormat(CGI.PATH_INFO)#</td>
			 </tr>
			 <tr>
			   <td align="right" class="info"> Host &amp; Server: </td>
			   <td >#htmlEditFormat(cgi.http_host)# #thisInetHost#</td>
			 </tr>
			 <tr>
			   <td align="right" class="info">Query String: </td>
			   <td >#htmlEditFormat(cgi.QUERY_STRING)#</td>
			 </tr>

			<cfif len(cgi.HTTP_REFERER)>
			 <tr>
			   <td align="right" class="info">Referrer:</td>
			   <td >#htmlEditFormat(cgi.HTTP_REFERER)#</td>
			 </tr>
			</cfif>
			<tr>
			   <td align="right" class="info">Browser:</td>
			   <td >#htmlEditFormat(cgi.HTTP_USER_AGENT)#</td>
			</tr>
			<tr>
			   <td align="right" class="info"> Remote Address: </td>
			   <td >#htmlEditFormat(cgi.remote_addr)#</td>
			 </tr>
			 <cfif isStruct(oException.getExceptionStruct()) >

			  <cfif findnocase("database", oException.getType() )>
				  <tr >
					<th colspan="2" >Database oException Information:</th>
				  </tr>
				  <tr >
					<td colspan="2" class="info">NativeErrorCode & SQL State:</td>
				  </tr>
				  <tr>
					<td colspan="2" >#oException.getNativeErrorCode()# : #oException.getSQLState()#</td>
				  </tr>
				  <tr >
					<td colspan="2" class="info">SQL Sent:</td>
				  </tr>
				  <tr>
					<td colspan="2" >#oException.getSQL()#</td>
				  </tr>
				  <tr >
					<td colspan="2" class="info">Database Driver Error Message:</td>
				  </tr>
				  <tr>
					<td colspan="2" >#oException.getqueryError()#</td>
				  </tr>
				  <tr >
					<td colspan="2" class="info">Name-Value Pairs:</td>
				  </tr>
				  <tr>
					<td colspan="2" >#oException.getWhere()#</td>
				  </tr>
			  </cfif>
			</cfif>
			 <tr >
				<th colspan="2" >Form variables:</th>
			 </tr>
			 <cfloop collection="#form#" item="key">
			 	<cfif key neq "fieldnames">
				 <tr>
				   <td align="right" class="info">#htmlEditFormat( key )#:</td>
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
				 <cfloop collection="#session#" item="key">
				 <tr>
				   <td align="right" class="info"> #key#: </td>
				   <td><cfif isSimpleValue( session[ key ] )>#htmlEditFormat( session[ key ] )#<cfelse>#key# <cfdump var="#session[ key ]#"></cfif></td>
				 </tr>
				 </cfloop>
			 <cfelse>
				 <tr>
				   <td align="right" class="info"> N/A </td>
				   <td >Session Scope Not Enabled</td>
				 </tr>
			 </cfif>
			 <tr >
				<th colspan="2" >Cookies:</th>
			 </tr>
			 <cfloop collection="#cookie#" item="key">
			 <tr>
			   <td align="right" class="info"> #key#: </td>
			   <td >#htmlEditFormat( cookie[ key ] )#</td>
			 </tr>
			 </cfloop>

			 <tr>
			   <th colspan="2" >Extra Information Dump </th>
			 </tr>

			 <tr>
			    <td colspan="2" >
			    <cfif isSimpleValue( oException.getExtraInfo() )>
			   		<cfif not len(oException.getExtraInfo())>[N/A]<cfelse>#oException.getExtraInfo()#</cfif>
			   	<cfelse>
			   		<cfdump var="#oException.getExtraInfo()#" expand="false">
				</cfif>
			    </td>
			 </tr>
		</table>
	</div>

</div>
</cfoutput>