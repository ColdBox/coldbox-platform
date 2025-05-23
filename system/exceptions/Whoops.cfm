<cfprocessingdirective pageEncoding="utf-8">
<cfscript>
	// Local raw exception structure
	local.exception = oException.getExceptionStruct();

	// Detect host
	try {
		local.thisInetHost = createObject( "java", "java.net.InetAddress" ).getLocalHost().getHostName();
	} catch ( any e ) {
		local.thisInetHost = "localhost";
	}

	// Build event details
	local.eventDetails = {
		"Error Code"    : ( oException.getErrorCode() != 0 ) ? oException.getErrorCode() : "",
		"Type"          : oException.gettype(),
		"Extended Info" : ( oException.getExtendedInfo() != "" ) ? oException.getExtendedInfo() : "",
		"Message"       : encodeForHTML( oException.getmessage() ).listChangeDelims( "<br>", chr( 13 ) & chr( 10 ) ),
		"Detail"        : encodeForHTML( oException.getDetail() ).listChangeDelims( "<br>", chr( 13 ) & chr( 10 ) ),
		"Environment"	: controller.getSetting( "environment" ),
		"Event"         : ( event.getCurrentEvent() != "" ) ? event.getCurrentEvent() : "",
		"Route"         : ( event.getCurrentRoute() != "" ) ? event.getCurrentRoute() & (
			event.getCurrentRoutedModule() != "" ? " from the " & event.getCurrentRoutedModule() & "module router." : ""
		) : "",
		"Route Name"       : ( event.getCurrentRouteName() != "" ) ? event.getCurrentRouteName() : "",
		"Routed Module"    : ( event.getCurrentRoutedModule() != "" ) ? event.getCurrentRoutedModule() : "",
		"Routed Namespace" : ( event.getCurrentRoutedNamespace() != "" ) ? event.getCurrentRoutedNamespace() : "",
		"Routed URL"       : ( event.getCurrentRoutedURL() != "" ) ? event.getCurrentRoutedURL() : "",
		"Layout"           : ( Event.getCurrentLayout() != "" ) ? Event.getCurrentLayout() : "",
		"Module"           : event.getCurrentLayoutModule(),
		"View"             : event.getCurrentView(),
		"itemorder"        : [
			"Error Code",
			"Type",
			"Message",
			"Detail",
			"Extended Info",
			"Environment",
			"Event",
			"Route",
			"Route Name",
			"Routed Module",
			"Routed Namespace",
			"Routed URL",
			"Layout",
			"Module",
			"View"
		]
	};

	// Build framework snapshot
	local.frameworkSnapshot = {
		"Coldfusion ID"  : "Session Scope Not Enabled",
		"Template Path"  : CGI.CF_TEMPLATE_PATH,
		"Path Info"      : CGI.PATH_INFO,
		"Host"           : CGI.HTTP_HOST,
		"Server"         : local.thisInetHost,
		"Query String"   : CGI.QUERY_STRING,
		"Referrer"       : CGI.HTTP_REFERER,
		"Browser"        : CGI.HTTP_USER_AGENT,
		"Remote Address" : CGI.REMOTE_ADDR,
		"itemorder"      : [
			"Coldfusion ID",
			"Template Path",
			"Path Info",
			"Host",
			"Server",
			"Query String",
			"Referrer",
			"Browser",
			"Remote Address"
		]
	};

	// Detect Session Scope
	local.sessionScopeExists = getApplicationMetadata().sessionManagement;
	if ( local.sessionScopeExists ) {
		local.fwString = "";
		if ( getApplicationMetadata().clientManagement  && isDefined( "client" ) ) {
			if ( structKeyExists( client, "cfid" ) ) fwString &= "CFID=" & client.CFID;
			if ( structKeyExists( client, "CFToken" ) ) fwString &= "<br/>CFToken=" & client.CFToken;
		}
		if ( getApplicationMetadata().sessionManagement && isDefined( "session" ) ) {
			if ( structKeyExists( session, "cfid" ) ) fwString &= "CFID=" & session.CFID;
			if ( structKeyExists( session, "CFToken" ) ) fwString &= "<br/>CFToken=" & session.CFToken;
			if ( structKeyExists( session, "sessionID" ) ) fwString &= "<br/>JSessionID=" & session.sessionID;
		}
		frameworkSnapshot[ "Coldfusion ID" ] = fwString;
	}

	// Database Info
	local.databaseInfo = {};
	if (
		(
			isStruct( local.exception )
			OR findNoCase( "DatabaseQueryException", getMetadata( local.exception ).getName() )
		) AND findNoCase( "database", oException.getType() )
	) {
		local.databaseInfo = {
			"SQL State"            : oException.getSQLState(),
			"NativeErrorCode"      : oException.getNativeErrorCode(),
			"SQL Sent"             : oException.getSQL(),
			"Driver Error Message" : oException.getqueryError(),
			"Name-Value Pairs"     : oException.getWhere(),
			"Exception Detail"     : local.exception.message,
			"Datasource"     	   : structKeyExists( local.exception, 'datasource' ) ? local.exception.datasource : "",
			"Additional Info"      : structKeyExists( local.exception, 'additional' ) ? local.exception.additional : "",
			"itemorder"      : [
				"Datasource",
				"Name-Value Pairs",
				"SQL Sent",
				"SQL State",
				"NativeErrorCode",
				"Driver Error Message",
				"Exception Detail",
				"Additional Info"
			]
		};
	}

	// Get exception information and mark the safe environment token
	local.stackFrames = arrayLen( local.exception.tagContext );
	local.inDebugMode = controller.inDebugMode();

	// Is this an Ajax Request? If so, present the plain exception templates
	local.requestHeaders = getHTTPRequestData( false ).headers;
	if(
		structKeyExists( local.requestHeaders, "X-Requested-With" )
		&&
		local.requestHeaders[ "X-Requested-With" ] eq "XMLHttpRequest"
	){
		// Debug mode report
		if( local.inDebugMode ){
			include "BugReport.cfm";
		}
		// Production Report
		else {
			writeOutput( "<h1>Whoops was not shown as ColdBox is not in <b>debugMode</b>!</h1>" );
			include "BugReport-Public.cfm";
		}
		return;
	}
</cfscript>
<cfoutput>
	<html>
		<head>
			<title>ColdBox Whoops! An error occurred!</title>
			<script src="/coldbox/system/exceptions/js/eva.min.js"></script>
			<script src="/coldbox/system/exceptions/js/syntaxhighlighter.js"></script>
			<script src="/coldbox/system/exceptions/js/javascript-brush.js"></script>
			<script src="/coldbox/system/exceptions/js/coldfusion-brush.js"></script>
			<script src="/coldbox/system/exceptions/js/sql-brush.js"></script>
			<link type="text/css" rel="stylesheet" href="/coldbox/system/exceptions/css/syntaxhighlighter-theme.css">
			<link type="text/css" rel="stylesheet" href="/coldbox/system/exceptions/css/whoops.css">
			<script>
				SyntaxHighlighter.defaults[ 'gutter' ] 		= true;
				SyntaxHighlighter.defaults[ 'smart-tabs' ] 	= false;
				SyntaxHighlighter.defaults[ 'tab-size' ]   	=  4;

				//SyntaxHighlighter.all();
			</script>
		</head>
		<body>
			<div class="whoops">

				<div class="whoops__nav">

					<!----------------------------------------------------------------------------------------->
					<!--- Top Left Exception Area --->
					<!----------------------------------------------------------------------------------------->
					<div class="exception">

						<div class="exception__logo">
							<img src="/coldbox/system/exceptions/images/coldbox-logo.png" width="40" />
							<span>ColdBox Exception</span>
							<form
								name="reinitForm"
								id="reinitForm"
								action="#event.buildLink(
									to : event.getCurrentRoutedURL(),
									queryString : cgi.QUERY_STRING,
									translate : false
								)#"
								method="POST"
							>
								<input
									type="hidden"
									name="fwreinit"
									id="fwreinit"
									value="">
								<a
									title="Reinitialize the framework and reload the page"
									class="button"
									href="javascript:reinitframework( #iif( controller.getSetting( "ReinitPassword" ).length(), 'true', 'false' )# )"
								>
									<i data-eva="flash-outline" data-eva-height="14" data-eva-fill="red"></i>
								</a>

							</form>
						</div>

						<h1 class="exception__timestamp" title="Time of exception">
							<i data-eva="clock-outline" fill="##7fcbe2"></i>
							<span>#dateTimeFormat( now(), "mm/dd/yyyy hh:nn tt" )#</span>
						</h1>

						<h1 class="exception__type" title="Error Code and Exception Type">
							<i data-eva="close-circle-outline" fill="red"></i>
							<span>#trim( eventDetails[ "Error Code" ] & " " & local.exception.type )#</span>
						</h1>

						<div
							class="exception__message"
							title="Exception Message - Click to copy"
							id="exceptionMessage"
						>
							<i
								onclick="copyToClipboard( 'exceptionMessage' )"
								data-eva="clipboard"
								data-eva-fill="white"
								data-eva-height="16"
								style="cursor: pointer; float: right"></i>

							#oException.processMessage( local.exception.message )#
						</div>

					</div>

					<!----------------------------------------------------------------------------------------->
					<!--- Stack Frames --->
					<!----------------------------------------------------------------------------------------->

					<div class="whoops_stacktrace_panel_info">Stack Frame(s): #stackFrames#</div>
					<div class="whoops__stacktrace_panel">
						<ul class="stacktrace__list">
							<cfset root = expandPath( "/" )/>
							<cfloop from="1" to="#arrayLen( local.exception.TagContext )#" index="i">
								<cfset instance = local.exception.TagContext[ i ]/>
								<!--- <cfdump var="#instance#"> --->
								<li
									id   ="stack#stackFrames - i + 1#"
									class="stacktrace <cfif i EQ 1>stacktrace--active</cfif>"
								>
									<span class="badge">#stackFrames - i + 1#</span>
									<div class="stacktrace__info">
										<h3 class="stacktrace__location">
											#replace( instance.template, root, "" )#:<span class="stacktrace__line-number">#instance.line#</span>
										</h3>

										<cfif structKeyExists( instance, "codePrintPlain" ) && local.inDebugMode>
											<cfset codesnippet = instance.codePrintPlain>
											<cfset codesnippet = reReplace( codesnippet, "\n\t", " ", "All" )>
											<cfset codesnippet = encodeForHTML( codesnippet )>
											<cfset codesnippet = reReplace(
												codesnippet,
												"([0-9]+:)",
												"#chr( 10 )#\1",
												"All"
											)>
											<cfset splitLines = listToArray( codesnippet, "#chr( 10 )#" )>
											<h4 class="stacktrace__code" style="margin-top:-10px;">
												<cfloop array="#splitLines#" index="codeline">
													#oException.stringLimit( codeline, 60 )#<br>
												</cfloop>
											</h4>
										</cfif>
									</div>

									<cfif oException.openInEditorURL( event, instance ) NEQ "">
										<a
											target="_self"
											rel   ="noreferrer noopener"
											href  ="#oException.openInEditorURL( event, instance )#"
											class ="editorLink__btn"
											title="Open in Editor"
										>
											<i data-eva="code-download-outline" height="20"></i>
										</a>
									</cfif>

								</li>
							</cfloop>
						</ul>
					</div>
				</div>


				<!----------------------------------------------------------------------------------------->
				<!--- Details Pane --->
				<!----------------------------------------------------------------------------------------->
				<div class="whoops__detail">

					<!----------------------------------------------------------------------------------------->
					<!--- Code Container --->
					<!----------------------------------------------------------------------------------------->
					<cfif stackFrames gt 0 AND local.inDebugMode>
						<div class="code-preview">
							<cfset instance = local.exception.TagContext[ 1 ]/>
							<div id="code-container"></div>
						</div>
					</cfif>

					<!----------------------------------------------------------------------------------------->
					<!--- Exception Details --->
					<!----------------------------------------------------------------------------------------->
					<div class="request-info data-table-container">

						<!----------------------------------------------------------------------------------------->
						<!--- Slide UP Button --->
						<!----------------------------------------------------------------------------------------->

						<cfif stackFrames gt 0 AND local.inDebugMode>
							<div class="slideup_row">
								<a href="javascript:void(0);" onclick="toggleCodePreview()" class="button button-icononly">
									<i id="codetoggle-up" data-eva="arrowhead-up-outline"></i>
									<i id="codetoggle-down" class="hidden" data-eva="arrowhead-down-outline"></i>
								</a>
							</div>
						</cfif>

						<!----------------------------------------------------------------------------------------->
						<!--- Scope Filters --->
						<!----------------------------------------------------------------------------------------->

						<div>
							<h2 class="details-heading">
								Exception Details
							</h2>
							<div class="data-filter" title="Filter Scopes">
								<i data-eva="funnel-outline" fill="white"></i>
								<a class="button all active"				href="javascript:void(0);" onclick="filterScopes( this, '' );">All</a>
								<a class="button eventdetails" 				href="javascript:void(0);" onclick="filterScopes( this, 'eventdetails' );">Error Details</a>
								<a class="button frameworksnapshot_scope" 	href="javascript:void(0);" onclick="filterScopes( this, 'frameworksnapshot_scope' );">Framework Snapshot</a>
								<a class="button database_scope" 			href="javascript:void(0);" onclick="filterScopes( this, 'database_scope' );">Database</a>
								<a class="button rc_scope" 					href="javascript:void(0);" onclick="filterScopes( this, 'rc_scope' );">RC</a>
								<a class="button prc_scope" 				href="javascript:void(0);" onclick="filterScopes( this, 'prc_scope' );">PRC</a>
								<a class="button headers_scope" 			href="javascript:void(0);" onclick="filterScopes( this, 'headers_scope' );">Headers</a>
								<a class="button session_scope" 			href="javascript:void(0);" onclick="filterScopes( this, 'session_scope' );">Session</a>
								<a class="button application_scope" 		href="javascript:void(0);" onclick="filterScopes( this, 'application_scope' );">Application</a>
								<a class="button cookies_scope" 			href="javascript:void(0);" onclick="filterScopes( this, 'cookies_scope' );">Cookies</a>
								<a class="button stacktrace_scope" 			href="javascript:void(0);" onclick="filterScopes( this, 'stacktrace_scope' );">Raw Stack Trace</a>
							</div>
						</div>

						<!----------------------------------------------------------------------------------------->
						<!--- Exception Details --->
						<!----------------------------------------------------------------------------------------->
						<cfoutput>
							<div id="request-info-details">
								<div id="eventdetails" class="data-table">
									<label>Error Details</label>
									#oException.displayScope( eventDetails )#
								</div>

								<div id="frameworksnapshot_scope" class="data-table">
									<label>Framework Snapshot</label>
									#oException.displayScope( frameworkSnapshot )#
								</div>

								<div id="database_scope" class="data-table">
									<label>Database</label>
									#oException.displayScope( databaseInfo )#
								</div>

								<div id="rc_scope" class="data-table">
									<label>RC</label>
									#oException.displayScope( rc )#
								</div>

								<div id="prc_scope" class="data-table">
									<label>PRC</label>
									#oException.displayScope( prc )#
								</div>

								<div id="headers_scope" class="data-table">
									<label>Headers</label>
									#oException.displayScope( local.requestHeaders )#
								</div>

								<div id="session_scope" class="data-table">
									<label>Session</label>
									<cftry>
										#oException.displayScope( session )#
										<cfcatch>
											<em>No Session</em>
										</cfcatch>
									</cftry>
								</div>

								<div id="application_scope" class="data-table">
									<label>Application</label>
									#oException.displayScope( application )#
								</div>

								<div id="cookies_scope" class="data-table">
									<label>Cookies</label>
									#oException.displayScope( cookie )#
								</div>

								<div id="stacktrace_scope" class="data-table">
									<label title="Copy to clipboard">
										Raw Stack Trace
										<i
											onclick="copyToClipboard( 'rawStacktrace' )"
											data-eva="clipboard"
											data-eva-fill="white"
											data-eva-height="16"
											style="cursor: pointer"></i>
									</label>

									<div id="rawStacktrace" class="data-stacktrace">#oException.processStackTrace( oException.getstackTrace() )#</div>
								</div>
							</div>
						</cfoutput>
					</div>
				</div>
			</div>

			<!----------------------------------------------------------------------------------------->
			<!--- Global File Getters + Source --->
			<!----------------------------------------------------------------------------------------->

			<!--- Make sure we are in Development only --->
			<cfif local.inDebugMode>
				<cfset stackRenderings = {}>
				<cfloop array="#local.exception.tagContext#" item="thisTagContext" index="i">
					<!--- Verify if File Exists: Just in case it's a core CFML engine file, else don't add it --->
					<cfif fileExists( thisTagContext.template )>
						<!--- Determine Source Highlighter --->
						<cfset highlighter = ( listFindNoCase( "cfm,bxm", listLast( thisTagContext.template, "." ) ) ? "cf" : "js" )/>
						<cfset spacing = "#chr( 20 )##chr( 20 )##chr( 20 )##chr( 20 )#">
						<!--- Output code only once per instance found --->
						<cfset filecontent = []>
						<!--- Replace spaces with space charaters for correct indentation --->
						<cfloop file="#thisTagContext.template#" index="line">
							<cfset findInitalSpaces = reFind( "^[\s\t]+", line, 0, true, "All" )>
							<cfif trim( line ) is not "" and arrayLen( findInitalSpaces )>
								<cfset trimmedline = right( line, len( line ) - findInitalSpaces[ 1 ].len[ 1 ] )>
								<cfset arrayAppend(
									filecontent,
									"#repeatString( spacing, findInitalSpaces[ 1 ].len[ 1 ] )##trimmedline#"
								)>
							<cfelse>
								<cfset arrayAppend( filecontent, "#chr( 20 )##line#" )>
							</cfif>
						</cfloop>
						<cfif NOT structKeyExists( stackRenderings, thisTagContext.template )>
							<script
								id="stackframe-#hash( thisTagContext.template )#"
								type="text"
								async
							><![CDATA[#arrayToList( filecontent, "#chr( 13 )##chr( 10 )#" )#]]></script>
							<cfset stackRenderings[ thisTagContext.template ] = true>
						</cfif>

						<!--- Pre source holder --->
						<pre
							id="stack#stackFrames - i + 1#-code"
							data-highlight-line="#thisTagContext.line#"
							data-template-id="#hash( thisTagContext.template )#"
							data-template-rendered="false"
							style="display: none;"
						>
							<script
								id="stack#stackFrames - i + 1#-script"
								type="text"
								class="brush:#highlighter#; highlight: [#thisTagContext.line#];"
								async
							><![CDATA[]]></script>
						</pre>
					</cfif>
				</cfloop>
			</cfif>

			<!----------------------------------------------------------------------------------------->
			<!--- End JS Scripts --->
			<!----------------------------------------------------------------------------------------->
			<script src="/coldbox/system/exceptions/js/whoops.js"></script>
			<script>
				// activate icons
				eva.replace();

				SyntaxHighlighter.highlight('brush:sql');
				<cfif local.exception.type == 'database'>
					var buttonEl = document.querySelector(".button.database_scope");
					filterScopes( buttonEl, 'database_scope' );
					toggleCodePreview();
				</cfif>
			</script>
		</body>
	</html>
</cfoutput>
