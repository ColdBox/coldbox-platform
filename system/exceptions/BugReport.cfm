<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
A reporting template about exceptions in your ColdBox Apps
----------------------------------------------------------------------->
<cfscript>
	// Detect Session Scope
	local.sessionScopeExists = true;
	try { structKeyExists( session ,'x' ); }
	catch ( any e ) {
		local.sessionScopeExists = false;
	}
	try{
		local.thisInetHost = createObject( "java", "java.net.InetAddress" ).getLocalHost().getHostName();
	}
	catch( any e ){
		local.thisInetHost = "localhost";
	}
</cfscript>
<cfoutput>
<!--- Param Form Scope --->
<cfparam name="form" default="#structnew()#">
<!--- StyleSheets --->
<style type="text/css"><cfinclude template="/coldbox/system/exceptions/css/cbox-debugger.css.cfm"></style>
<div class="cb-container">
	<h1>
		<cfif oException.geterrorCode() neq "" AND oException.getErrorCode() neq 0>
			#encodeForHTML( oException.getErrorCode())# :
		</cfif>
		Oopsy! Something went wrong!</h1>

	<div class="extended">

		<cfif oException.getExtraMessage() neq "">
		<h3>#encodeForHTML( oException.getExtramessage() )#</h3>
		</cfif>

		<table class="table" align="center">
			 <tr >
				<th colspan="2" >Error Details:</th>
			 </tr>
			<cfif oException.getType() neq "">
				<tr>
					<td align="right" class="info"><strong>Type: </strong></td>
					<td>#encodeForHTML( oException.gettype() )# </td>
				</tr>
			</cfif>
			<tr>
				<td align="right" class="info"><strong>Message:</strong></td>
				<!--- Using HTMLEditFormat() on purpose so my line breaks aren't encoded! --->
				<td>#HTMLEditFormat( oException.getmessage() ).listChangeDelims( '<br>', chr(13)&chr(10) )#</td>
			</tr>
			<cfif oException.getExtendedInfo() neq "">
				<tr>
					<td align="right" class="info"><strong>Extended Info:</strong></td>
					<td>#encodeForHTML( oException.getExtendedInfo() )#</td>
				</tr>
		 	</cfif>

		 	<cfif len( oException.getDetail() ) neq 0>
				<tr>
					<td align="right" class="info"><strong>Detail:</strong></td>
					<!--- Using HTMLEditFormat() on purpose so my line breaks aren't encoded! --->
					<td>#HTMLEditFormat( oException.getDetail() ).listChangeDelims( '<br>', chr(13)&chr(10) )#</td>
				</tr>
			 </cfif>
			<tr>
				<td align="right" class="info"><strong>Timestamp: </strong></td>
				<td>#dateformat(now(), "mm/dd/yyyy")# #timeformat(now(),"hh:mm:ss tt")#</td>
			</tr>
			 <tr >
				<th colspan="2" >Event Details:</th>
			 </tr>
			<tr>
				<td align="right" class="info"><strong>Event: </strong></td>
				<td><cfif event.getCurrentEvent() neq "">#encodeForHTML( event.getCurrentEvent() )#<cfelse>N/A</cfif></td>
			</tr>
			<tr>
				<td align="right" class="info"><strong>Route: </strong></td>
				<td><cfif event.getCurrentRoute() neq "">#encodeForHTML( event.getCurrentRoute() )#<cfelse>N/A</cfif>
			<cfif event.getCurrentRoutedModule() neq ""> from the "#encodeForHTML( event.getCurrentRoutedModule() )#" module router.</cfif></td>
			</tr>
			<tr>
				<td align="right" class="info"><strong>Route Name: </strong></td>
				<td><cfif event.getCurrentRouteName() neq "">#encodeForHTML( event.getCurrentRouteName() )#<cfelse>N/A</cfif></td>
			</tr>
			<tr>
				<td align="right" class="info"><strong>Routed Module: </strong></td>
				<td><cfif event.getCurrentRoutedModule() neq "">#event.getCurrentRoutedModule()#<cfelse>N/A</cfif></td>
			</tr>
			<tr>
				<td align="right" class="info"><strong>Routed Namespace: </strong></td>
				<td><cfif event.getCurrentRoutedNamespace() neq "">#encodeForHTML( event.getCurrentRoutedNamespace() )#<cfelse>N/A</cfif></td>
			</tr>
			<tr>
				<td align="right" class="info"><strong>Routed URL: </strong></td>
				<td><cfif event.getCurrentRoutedURL() neq "">#encodeForHTML( event.getCurrentRoutedURL() )#<cfelse>N/A</cfif></td>
			</tr>
			<tr>
				<td align="right" class="info"><strong>Layout: </strong></td>
				<td><cfif Event.getCurrentLayout() neq "">#encodeForHTML( Event.getCurrentLayout() )#<cfelse>N/A</cfif> (Module: #encodeForHTML( event.getCurrentLayoutModule() )#)</td>
			</tr>
			<tr>
				<td align="right" class="info"><strong>View: </strong></td>
				<td><cfif Event.getCurrentView() neq "">#encodeForHTML( Event.getCurrentView() )#<cfelse>N/A</cfif></td>
			</tr>
		</table>

	</div>

	<div class="extended">
		<!--- TAG CONTEXT --->
		<h2>Tag Context:</h2>
		<table class="table" align="center" cellspacing="0">
		<cfif ArrayLen( oException.getTagContext() )>
			  <cfset local.arrayTagContext = oException.getTagContext()>
			  <cfloop from="1" to="#arrayLen( local.arrayTagContext )#" index="local.i">
				  <!--- Don't clutter the screen with this information unless it's actually useful --->
			  	  <cfif structKeyExists( local.arrayTagContext[ local.i ], "ID" ) and
			  	  		len( local.arrayTagContext[ local.i ].ID ) and
			  	  		local.arrayTagContext[ local.i ].ID neq "??"
			  	  >
			  <tr >
						<td align="right" class="info">Tag:</td>
					    <td>#encodeForHTML( local.arrayTagContext[ local.i ].ID )#</td>
			  </tr>
				  </cfif>
			   <tr >
					<td align="right" class="info">Template:</td>
				    <td style="color:green;"><strong>#encodeForHTML( local.arrayTagContext[ local.i ].Template )#</strong></td>
				   </tr>
			  	  <cfif structKeyExists( local.arrayTagContext[ local.i ], "codePrintHTML" )>
					  <tr class="tablebreak">
				<td align="right" class="info">LINE:</td>
					<!--- Already encoded for safe HTML output --->
				    <td><pre>#local.arrayTagContext[ local.i ].codePrintHTML#</pre></td>
			   </tr>
				  <cfelse>
			   <tr class="tablebreak">
						<td align="right" class="info">Line:</td>
					    <td ><strong>#encodeForHTML( local.arrayTagContext[ local.i ].LINE )#</strong></td>
			   </tr>
				  </cfif>
			  </cfloop>
		</cfif>
		</table>

		<h2>Stack Trace:</h2>
		<div class="stacktrace">#oException.processStackTrace( oException.getstackTrace() )#</div>

		<!--- FRAMEWORK SNAPSHOT --->
		<h2>FRAMEWORK SNAPSHOT:</h2>
		<table class="table" align="center">
			<tr>
			   <td align="right" class="info">Bug Date:</td>
			   <td >#dateformat(now(), "mm/dd/yyyy")# #timeformat(now(),"hh:mm:ss tt")#</td>
			 </tr>

			 <tr>
			   <td align="right" class="info">Coldfusion ID: </td>
			   <td >
			   	<cfif local.sessionScopeExists>
					<cfif isDefined("session") and structkeyExists(session, "cfid")>
					CFID=#encodeForHTML( session.CFID)# ;
					<cfelseif isDefined("client") and structkeyExists(client,"cfid")>
					CFID=#encodeForHTML( client.CFID )# ;
					</cfif>
					<cfif isDefined("session") and structkeyExists(session,"CFToken")>
					CFToken=#encodeForHTML( session.CFToken )# ;
					<cfelseif isDefined("client") and structkeyExists(client,"CFToken")>
					CFToken=#encodeForHTML( client.CFToken )# ;
					</cfif>
					<cfif isDefined("session") and structkeyExists(session,"sessionID")>
					JSessionID=#encodeForHTML( session.sessionID )#
					</cfif>
			   <cfelse>
			   		Session Scope Not Enabled
			   </cfif>
				</td>
			 </tr>
			 <tr>
			   <td align="right" class="info">Template Path : </td>
			   <td >#encodeForHTML( CGI.CF_TEMPLATE_PATH )#</td>
			 </tr>
			  <tr>
			   <td align="right" class="info">Path Info : </td>
			   <td >#encodeForHTML( CGI.PATH_INFO )#</td>
			 </tr>
			 <tr>
			   <td align="right" class="info"> Host &amp; Server: </td>
			   <td >#encodeForHTML( CGI.HTTP_HOST )# #encodeForHTML( local.thisInetHost )#</td>
			 </tr>
			 <tr>
			   <td align="right" class="info">Query String: </td>
			   <td >#encodeForHTML( CGI.QUERY_STRING )#</td>
			 </tr>

			<cfif len(CGI.HTTP_REFERER)>
			 <tr>
			   <td align="right" class="info">Referrer:</td>
			   <td >#encodeForHTML( CGI.HTTP_REFERER )#</td>
			 </tr>
			</cfif>
			<tr>
			   <td align="right" class="info">Browser:</td>
			   <td >#encodeForHTML( CGI.HTTP_USER_AGENT )#</td>
			</tr>
			<tr>
			   <td align="right" class="info"> Remote Address: </td>
			   <td >#encodeForHTML( CGI.REMOTE_ADDR )#</td>
			 </tr>

			 <cfif
			 	isStruct( oException.getExceptionStruct() )
			 	OR findNoCase( "DatabaseQueryException", getMetadata( oException.getExceptionStruct() ).getName() )
			 >

			  <cfif findnocase( "database", oException.getType() )>
				  <tr >
					<th colspan="2" >Database oException Information:</th>
				  </tr>
				  <tr >
					<td colspan="2" class="info">NativeErrorCode & SQL State:</td>
				  </tr>
				  <tr>
					<td colspan="2" >#encodeForHTML( oException.getNativeErrorCode() )# : #encodeForHTML( oException.getSQLState() )#</td>
				  </tr>
				  <tr >
					<td colspan="2" class="info">SQL Sent:</td>
				  </tr>
				  <tr>
					<td colspan="2" >#encodeForHTML( oException.getSQL() )#</td>
				  </tr>
				  <tr >
					<td colspan="2" class="info">Database Driver Error Message:</td>
				  </tr>
				  <tr>
					<td colspan="2" >#encodeForHTML( oException.getqueryError() )#</td>
				  </tr>
				  <tr >
					<td colspan="2" class="info">Name-Value Pairs:</td>
				  </tr>
				  <tr>
					<td colspan="2" >#encodeForHTML( oException.getWhere() )#</td>
				  </tr>
			  </cfif>
			</cfif>
			 <tr >
				<th colspan="2" >Form variables:</th>
			 </tr>
			 <cfloop collection="#form#" item="key">
			 	<cfif key neq "fieldnames">
				 <tr>
				   <td align="right" class="info">#encodeForHTML(  key )#:</td>
				   <cfif isSimpleValue( form[ key ] )>
				   <td>#encodeForHTML(  form[ key ] )#</td>
				   <cfelse>
				   <td><cfdump var="#form[ key ]#"></td>
				   </cfif>
				 </tr>
			 	</cfif>
			 </cfloop>
			 <tr >
				<th colspan="2" >Session Storage:</th>
			 </tr>
			 <cfif local.sessionScopeExists>
				 <cfloop collection="#session#" item="key">
				 <tr>
				   <td align="right" class="info"> #encodeForHTML( key )#: </td>
				   <td><cfif isSimpleValue( session[ key ] )>#encodeForHTML(  session[ key ] )#<cfelse>#encodeForHTML( key )# <cfdump var="#session[ key ]#"></cfif></td>
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
			   <td align="right" class="info"> #encodeForHTML( key )#: </td>
			   <td >#encodeForHTML( cookie[ key ] )#</td>
			 </tr>
			 </cfloop>

			 <tr>
			   <th colspan="2" >Extra Information Dump </th>
			 </tr>

			 <tr>
			    <td colspan="2" >
			    <cfif isSimpleValue( oException.getExtraInfo() )>
			   		<cfif not len(oException.getExtraInfo())>[N/A]<cfelse>#encodeForHTML( oException.getExtraInfo() )#</cfif>
			   	<cfelse>
			   		<cfdump var="#oException.getExtraInfo()#" expand="false">
				</cfif>
			    </td>
			 </tr>
		</table>
	</div>

</div>
</cfoutput>
