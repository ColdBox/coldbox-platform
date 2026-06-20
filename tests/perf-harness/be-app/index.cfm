<cfsetting enablecfoutputonly="true">
<cfsetting showdebugoutput="false">
<cfscript>
	_forwardURI = getPageContext().getRequest().getAttribute( "javax.servlet.forward.request_uri" )
	if ( !isNull( _forwardURI ) && len( _forwardURI ) ) {
		CGI.PATH_INFO = reReplaceNoCase( _forwardURI, "^/tests/perf-harness/be-app", "" )
	}
</cfscript>
