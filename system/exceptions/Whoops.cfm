<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
An enhanced error reporting and debugging tool for ColdBox Framework
----------------------------------------------------------------------->
<cfprocessingdirective pageEncoding="utf-8">
<cfscript>
	local.cbUtil = new coldbox.system.core.util.Util();
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
			event.getCurrentRoutedModule() != "" ? " from the " & event.getCurrentRoutedModule() & " module router." : ""
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
	local.serverInfo = {
		"Template Path"  : CGI.CF_TEMPLATE_PATH,
		"Path Info"      : CGI.PATH_INFO,
		"Host"           : CGI.HTTP_HOST,
		"Server"         : local.thisInetHost,
		"Query String"   : CGI.QUERY_STRING,
		"Referrer"       : CGI.HTTP_REFERER,
		"Browser"        : CGI.HTTP_USER_AGENT,
		"Remote Address" : CGI.REMOTE_ADDR,
		"itemorder"      : [
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
	local.sessionScopeExists = getApplicationMetadata()?.sessionManagement;
	if ( local.sessionScopeExists ) {
		local.fwString = "";
		if ( getApplicationMetadata()?.clientManagement  && isDefined( "client" ) ) {
			if ( structKeyExists( client, "cfid" ) ) fwString &= "CFID=" & client.CFID;
			if ( structKeyExists( client, "CFToken" ) ) fwString &= "<br/>CFToken=" & client.CFToken;
		}
		if ( getApplicationMetadata()?.sessionManagement && isDefined( "session" ) ) {
			if ( structKeyExists( session, "cfid" ) ) fwString &= "CFID=" & session.CFID;
			if ( structKeyExists( session, "CFToken" ) ) fwString &= "<br/>CFToken=" & session.CFToken;
			if ( structKeyExists( session, "sessionID" ) ) fwString &= "<br/>JSessionID=" & session.sessionID;
		}
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
	<!DOCTYPE html>
	<html lang="en">
		<head>
			<meta charset="utf-8">
			<meta name="viewport" content="width=device-width, initial-scale=1.0">
			<meta name="robots" content="noindex, nofollow">
			<title>ColdBox Exception Report - #encodeForHTML(oException.getType())#</title>
			<!--- Alpine.js --->
			<script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
			<!--- Whoops Alpine.js Component --->
			<script src="/coldbox/system/exceptions/js/whoops.js"></script>
			<!--- JavaScript --->
			<script src="/coldbox/system/exceptions/js/eva.min.js"></script>
			<script src="/coldbox/system/exceptions/js/syntaxhighlighter.js"></script>
			<script src="/coldbox/system/exceptions/js/javascript-brush.js"></script>
			<script src="/coldbox/system/exceptions/js/boxlang-brush.js"></script>
			<script src="/coldbox/system/exceptions/js/coldfusion-brush.js"></script>
			<script src="/coldbox/system/exceptions/js/sql-brush.js"></script>
			<!--- CSS --->
			<link type="text/css" rel="stylesheet" href="/coldbox/system/exceptions/css/syntaxhighlighter-theme.css">
			<link type="text/css" rel="stylesheet" href="/coldbox/system/exceptions/css/whoops.css">
		</head>
		<body>
			<div
				class="whoops"
				x-data="whoopsReporter(
					#encodeForHTMLAttribute( local.cbUtil.toJson( local.eventDetails ) )#,
					#encodeForHTMLAttribute( local.cbUtil.toJson( local.serverInfo ) )#,
					#encodeForHTMLAttribute( local.cbUtil.toJson( local.databaseInfo ) )#
				)"
				x-init="init()">

				<!--- Navigation --->
				<div class="whoops__nav">

					<!----------------------------------------------------------------------------------------->
					<!--- Top Left Exception Area --->
					<!----------------------------------------------------------------------------------------->
					<div class="exception">

						<!--- Title Bar --->
						<div class="exception__logo">
							<!--- Logo + Title --->
							<div class="exception__logo-content">
								<img src="/coldbox/system/exceptions/images/coldbox-logo.png" width="40" />
								<span>ColdBox Exception</span>
							</div>
							<!--- Reinit Method --->
							<div class="exception__reinit">
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
										data-tooltip="Reinitialize Framework"
										data-tooltip-location="bottom"
										class="button"
										@click="reinitFramework(#iif( controller.getSetting( "ReinitPassword" ).length(), 'true', 'false' )#)"
										href="##"
									>
										<i data-eva="flash-outline" data-eva-height="14" data-eva-fill="red"></i>
									</a>

								</form>
							</div>
						</div>

						<!--- Timestamp --->
						<h1 class="exception__timestamp" data-tooltip="Exception timestamp">
							<i data-eva="clock-outline" fill="##7fcbe2"></i>
							<span>#dateTimeFormat( now(), "MMM/dd/yyyy HH:mm:ss" )#</span>
						</h1>

						<!--- Exception Type --->
						<h1 class="exception__type" data-tooltip="Exception Type">
							<i data-eva="close-circle-outline" fill="red"></i>
							<span>#trim( eventDetails[ "Error Code" ] & " " & local.exception.type )#</span>
						</h1>

						<!--- Exception Message --->
						<div
							class="exception__message"
							data-tooltip="Copy Error Message"
							data-tooltip-location="bottom"
							id="exceptionMessage"
							role="button"
							tabindex="0"
							aria-label="Copy to clipboard"
							@click="copyToClipboard( 'exceptionMessage' )"
							@keydown.enter="copyToClipboard( 'exceptionMessage' )"
							@keydown.space="copyToClipboard( 'exceptionMessage' )"
						>
							<i
								data-eva="clipboard"
								data-eva-fill="white"
								data-eva-height="16"
								style="cursor: pointer; float: right"
								tabindex="0"
								aria-label="Copy to clipboard"
								role="button"
								data-tooltip="Copy to clipboard"
								data-tooltip-location="left"></i>
							#oException.processMessage( local.exception.message )#
						</div>

					</div>

					<!----------------------------------------------------------------------------------------->
					<!--- Stack Frames --->
					<!----------------------------------------------------------------------------------------->

					<!--- Stack Frames Title --->
					<div class="whoops_stacktrace_panel_info">
						<i data-eva="list-outline" data-eva-height="20" data-eva-fill="white"></i>
						Stack Frame(s)
					</div>

					<!--- Stack Panel --->
					<div class="whoops__stacktrace_panel">
						<ul class="stacktrace__list" role="list" aria-label="Stack trace frames">

							<!--- Root of the site --->
							<!--- TODO: maybe get the app path? --->
							<cfset root = expandPath( "/" )/>

							<cfloop from="1" to="#arrayLen( local.exception.TagContext )#" index="i">
								<cfset instance = local.exception.TagContext[ i ]/>
								<li
									id="stack#stackFrames - i + 1#"
									class="stacktrace"
									:class="{ 'stacktrace--active': activeFrame === 'stack#stackFrames - i + 1#' }"
									role="listitem"
									tabindex="0"
									aria-describedby="frame-#stackFrames - i + 1#-description"
									<!--- Data Members --->
									data-stackframe="stack#stackFrames - i + 1#"
									data-location="#replace( instance.template, root, "" )#"
									data-idelink="#oException.openInEditorURL( event, instance )#"
									data-line="#instance.line#"
									<!--- Alpine Events --->
									@click="changeCodePanel( $event.currentTarget )"
									@keydown.enter="changeCodePanel( $event.currentTarget )"
									@keydown.space="changeCodePanel( $event.currentTarget )"
								>
									<!--- Stack Frame Number --->
									<span class="badge" aria-label="Frame number">#stackFrames - i + 1#</span>

									<!--- Stack Information --->
									<div class="stacktrace__info" id="frame-#stackFrames - i + 1#-description">

										<!--- Location + Line Number --->
										<h3 class="stacktrace__location">#replace( instance.template, root, "" )#:<span class="stacktrace__line-number">#instance.line#</span></h3>

										<!--- Code Print if it exists --->
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

									<!---  Open in editor button--->
									<cfif oException.openInEditorURL( event, instance ) NEQ "">
										<a
											target="_self"
											rel="noreferrer noopener"
											href="#oException.openInEditorURL( event, instance )#"
											class="editorLink__btn"
											data-tooltip="Open in editor"
											data-tooltip-location="left"
											aria-label="Open #replace( instance.template, root, "" )# line #instance.line# in editor"
										>
											<i data-eva="code-download-outline" height="20" aria-hidden="true"></i>
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
					<!--- Code Container with Slider --->
					<!----------------------------------------------------------------------------------------->
					<cfif stackFrames gt 0 AND local.inDebugMode>
						<div class="code-preview-container"
							 :style="codePreviewShow ? 'height: ' + codePreviewHeight + 'px' : 'height: 0px'"
							 x-transition:enter="transition ease-out duration-300"
							 x-transition:enter-start="opacity-0 transform scale-95"
							 x-transition:enter-end="opacity-100 transform scale-100"
							 x-transition:leave="transition ease-in duration-200"
							 x-transition:leave-start="opacity-100 transform scale-100"
							 x-transition:leave-end="opacity-0 transform scale-95"
						>
							<!-- Code Preview Header Bar -->
							<div class="code-preview-header" x-show="codePreviewShow">
								<!--- File Information --->
								<div class="file-info">
									<i data-eva="file-text-outline" data-eva-height="16" data-eva-fill="##7fcbe2"></i>
									<span class="file-path" x-text="currentFilePath || 'Loading...'"></span>
									<span class="line-number" x-show="currentLineNumber > 0" x-text="':' + currentLineNumber"></span>
								</div>

								<!--- File Actions --->
								<div class="file-actions">
									<a
										target="_self"
										rel="noreferrer noopener"
										:href="currentIdeLink"
										data-tooltip="Open in Editor"
										data-tooltip-location="left"
									>
										<i data-eva="code-download-outline" data-eva-height="25" data-eva-fill="##7fcbe2"></i>
									</a>
								</div>
							</div>

							<!--- Code Preview --->
							<div class="code-preview" x-show="codePreviewShow">
								<cfset instance = local.exception.TagContext[ 1 ]/>
								<div id="code-container" style="height: 100%; overflow: auto;"></div>
							</div>

							<!--- Slider Handle - Always Visible --->
							<div class="code-slider-handle"
								 @mousedown="startDrag( $event )"
								 @click="handleSliderClick( $event )"
								 :class="{ 'dragging': isDragging, 'collapsed': !codePreviewShow }"
							>
								<div class="slider-grip">
									<!-- Show expand icon when collapsed, minimize when expanded -->
									<i data-eva="chevron-up-outline" data-eva-height="18" data-eva-fill="white" x-show="codePreviewShow"></i>
									<i data-eva="chevron-down-outline" data-eva-height="18" data-eva-fill="white" x-show="!codePreviewShow"></i>
								</div>
							</div>
						</div>
					</cfif>

					<!----------------------------------------------------------------------------------------->
					<!--- Exception Details --->
					<!----------------------------------------------------------------------------------------->
					<div class="request-info data-table-container">

						<!----------------------------------------------------------------------------------------->
						<!--- Scope Filters --->
						<!----------------------------------------------------------------------------------------->

						<div>
							<h2 class="details-heading">
								<i data-eva="radio-outline" data-eva-height="25" data-eva-fill="##7fcbe2"></i>
								Exception Details
								<div class="control-bar">
									<select
										id="scope-filter"
										@change="filterScopesFromDropdown( $event.target )"
										class="scope-dropdown"
										data-tooltip="Filter by scope"
										data-tooltip-location="bottom"
										aria-label="Filter Scopes"
									>
										<option value="">All</option>
										<option value="application_scope">Application</option>
										<option value="cookies_scope">Cookies</option>
										<option value="database_scope">Database</option>
										<option value="eventdetails">Error Details</option>
										<option value="headers_scope">Headers</option>
										<option value="prc_scope">Private Request Collection (PRC)</option>
										<option value="rc_scope">Request Collection (RC)</option>
										<option value="serverinfo_scope">Server Info</option>
										<option value="session_scope">Session</option>
										<option value="stacktrace_scope">Stacktrace</option>
									</select>
									<!--- Height indicator shows during dragging --->
									<div class="height-indicator" x-show="codePreviewShow && isDragging" x-text="Math.round(codePreviewHeight) + 'px'"></div>
								</div>
							</h2>
						</div>

						<!----------------------------------------------------------------------------------------->
						<!--- Exception Details --->
						<!----------------------------------------------------------------------------------------->
						<cfoutput>
							<div id="request-info-details">
								<div id="stacktrace_scope" class="data-table">
									<label>
										Stacktrace
									</label>

									<!--- Simplified Enhanced Stacktrace Viewer --->
									<div class="stacktrace-enhanced">

										<!--- Stacktrace Controls --->
										<div class="stacktrace-controls" id="stacktrace-controls">
											<div class="stacktrace-control-group">
												<button
													@click="toggleStacktraceView()"
													class="stacktrace-toggle"
													:class="{ 'active': stacktraceData.showRaw }"
												>
													<i data-eva="code-outline" data-eva-height="16" data-eva-fill="currentColor"></i>
													<span x-text="stacktraceData.showRaw ? 'Enhanced View' : 'Raw View'"></span>
												</button>

												<button
													@click="copyToClipboard( 'stacktrace-raw', 'stacktrace-controls' )"
													class="stacktrace-action"
												>
													<i data-eva="copy-outline" data-eva-height="16" data-eva-fill="currentColor"></i>
													Copy
												</button>

												<button
													@click="emailStacktrace()"
													class="stacktrace-action"
													data-tooltip="Email Stacktrace"
													data-tooltip-location="bottom"
												>
													<i data-eva="email-outline" data-eva-height="16" data-eva-fill="currentColor"></i>
													Email
												</button>

												<button
													@click="askAI()"
													class="stacktrace-action stacktrace-action--ai"
													data-tooltip="Ask AI to analyze this error"
													data-tooltip-location="bottom"
												>
													<i data-eva="bulb-outline" data-eva-height="16" data-eva-fill="currentColor"></i>
													Ask AI
												</button>
											</div>

											<!--- Search Box --->
											<div class="stacktrace-search" x-show="!stacktraceData.showRaw">
												<input
													type="text"
													x-model="stacktraceData.searchTerm"
													@input="filterStacktraceFrames()"
													placeholder="Search stacktrace frames..."
													class="stacktrace-search-input"
													data-tooltip="Search through stacktrace frames"
													data-tooltip-location="left">
												<i data-eva="search-outline" data-eva-height="16" data-eva-fill="##7fcbe2"></i>
											</div>
										</div>

										<!--- Enhanced Interactive View --->
										<div x-show="!stacktraceData.showRaw" class="stacktrace-enhanced-view">
											<div class="stacktrace-stats">
												<span class="stat-item">
													<i data-eva="layers-outline" data-eva-height="14" data-eva-fill="##7fcbe2"></i>
													<span x-text="stacktraceData.filteredFrames.length + (stacktraceData.searchTerm && stacktraceData.filteredFrames.length !== stacktraceData.allFrames.length ? ' (filtered from ' + stacktraceData.allFrames.length + ')' : '')"></span> frames
												</span>
											</div>

											<div class="stacktrace-frames">
												<!-- No matches message -->
												<div x-show="stacktraceData.filteredFrames.length === 0 && stacktraceData.searchTerm" class="no-matches">
													<i data-eva="search-outline" data-eva-height="20" data-eva-fill="##7fcbe2"></i>
													<p>No stacktrace frames match your search</p>
													<button @click="clearSearch()" class="clear-search">Clear search</button>
												</div>

												<!-- Stacktrace frames -->
												<template x-for="(frame, index) in stacktraceData.filteredFrames" :key="index">
													<div class="stacktrace-frame" :id="'stacktrace-frame-' + index">
														<div class="frame-header">
															<span class="frame-number" x-text="index + 1"></span>
															<div class="frame-actions">
																<button
																	@click="copyStacktraceFrame( index )"
																	class="frame-action"
																	data-tooltip="Copy this frame"
																	data-tooltip-location="left">
																	<i data-eva="copy-outline" data-eva-height="12" data-eva-fill="currentColor"></i>
																</button>
															</div>
														</div>
														<div class="frame-content" x-html="highlightMatch( frame, stacktraceData.searchTerm )"></div>
													</div>
												</template>
											</div>
										</div>

										<!--- Raw View --->
										<div x-show="stacktraceData.showRaw" class="data-stacktrace">#oException.processStackTrace( oException.getstackTrace() )#</div>
										</div>

										<!--- Hidden raw stacktrace for copying --->
										<div id="stacktrace-raw" style="display: none;">#oException.processStackTrace( oException.getstackTrace() )#</div>
									</div>

								<div id="eventdetails" class="data-table">
									<label>Error Details</label>
									#oException.displayScope( eventDetails )#
								</div>

								<div id="serverinfo_scope" class="data-table">
									<label>Server Info</label>
									#oException.displayScope( serverInfo )#
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
					<!--- Verify if File Exists: Just in case it's a core engine file, else don't add it --->
					<cfif fileExists( thisTagContext.template )>

						<!--- Determine Source Highlighter --->
						<cfset ext = listLast( thisTagContext.template, "." )>
						<cfif listFindNoCase( "bxm,bxs,bx,cfc", ext )>
							<cfset highlighter = "bx">
						<cfelseif listFindNoCase( "cfm", ext )>
							<cfset highlighter = "cf">
						<cfelse>
							<cfset highlighter = "js">
						</cfif>

						<!--- Add spacing for indentation --->
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

						<!--- If we have content, then render it --->
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
			<script>
			document.addEventListener( 'alpine:init', () => {
				// activate icons
				if ( window.eva ) {
					eva.replace();
				}

				// SyntaxHighlighter defaults
				SyntaxHighlighter.defaults[ 'gutter' ] 		= true;
				SyntaxHighlighter.defaults[ 'smart-tabs' ] 	= false;
				SyntaxHighlighter.defaults[ 'tab-size' ]   	=  4;

				<cfif local.exception.type == 'database'>
					setTimeout( () => {
							const selectEl = document.querySelector( '##scope-filter' );
							if ( selectEl ) {
								selectEl.value = 'database_scope';
								selectEl.dispatchEvent( new Event( 'change' ) );
							}

							// Toggle code preview closed for database errors
							const whoopsEl = document.querySelector( '.whoops' );
							if ( whoopsEl && whoopsEl._x_dataStack && whoopsEl._x_dataStack[ 0 ] && typeof whoopsEl._x_dataStack[ 0 ].toggleCodePreview === 'function' ) {
								whoopsEl._x_dataStack[ 0 ].toggleCodePreview();
							}
						}, 800 );
				</cfif>
			});
			</script>
		</body>
	</html>
</cfoutput>
