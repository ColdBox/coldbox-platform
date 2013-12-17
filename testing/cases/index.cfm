<!--- SETUP YOUR ROOT PATH RIGHT HERE FOR THE BROWSER --->
<cfset rootPath = expandPath( "/coldbox/testing/cases" )>

<cfparam name="url.path" default="/">
<cfset url.path = urlDecode( url.path )>


<!--- Run Tests Action?--->
<cfif structKeyExists( url, "action")>

	<cfset appMapping = replacenocase( rootPath, replace( expandPath( "/" ), "\", "/", "all" ), "" )>
	<cfset appmapping = replace( appMapping & reReplace( url.path, "^(/|\\)", "" ), "/", ".", "all" )>

	<cfif url.action eq "runMXUnit">
		<cfset results = new mxunit.runner.DirectoryTestSuite()
			.run( directory="#URLDecode( rootPath & "/" & url.path )#", componentPath=appMapping, refreshcache=true )>	
		<cfoutput>#results.getResultsOutput()#</cfoutput>
	<cfelse>
		<cfset results = new coldbox.system.testing.TestBox( directory=appMapping )>	
		<cfoutput>#results.run()#</cfoutput>
	</cfif>
	
	<cfabort>
	
</cfif>

<cfdirectory action="list" directory="#rootPath & url.path#" name="qResults" sort="asc" >
<cfset embedPath = reReplaceNoCase( replaceNoCase( rootPath & url.path, rootPath, "" ), "^/", "" ) & "/">
	
<cfoutput>
<h1>Test Browser: #embedPath#</h1>

<cfif url.path neq "/">
	<a href="index.cfm?#url.path#">< Back</a><br><hr>
</cfif>

<cfloop query="qResults">
	<cfif refind( "^\.", qResults.name )>
		<cfcontinue>
	</cfif>
	<cfset dirPath = URLEncodedFormat( ( url.path neq '/' ? '#url.path#/' : '/' ) & qResults.name )>
	<cfif qResults.type eq "Dir">
		+<a href="index.cfm?path=#dirPath#">#qResults.name#</a><br/>
	<cfelseif listLast( qresults.name, ".") eq "cfm">
		<a href="#qResults.name#" target="_blank">#qResults.name#</a><br/>
	<cfelseif listLast( qresults.name, ".") eq "cfc" and findNoCase( "Test", qResults.name )>
		<a href="#embedPath & qResults.name#?method=runTestRemote" target="_blank"><button type="button">MXUnit</button></a>
		<a href="#embedPath & qResults.name#?method=runRemote" target="_blank"><button type="button">TestBox</button></a>
		#qResults.name#<br/>
	<cfelse>
		#qResults.name#<br/>
	</cfif>
		
</cfloop>

<hr>
<a href="index.cfm?action=runMXUnit&path=#URLEncodedFormat( url.path )#" target="_blank"><button type="button">Run MXUnit Directory Runner</button></a>
<a href="index.cfm?action=runTestBox&path=#URLEncodedFormat( url.path )#" target="_blank"><button type="button">Run TestBox Directory Runner</button></a>
<br>
<small>Root: #rootPath#</small>
<!---
<small>root: #rootPath#</small><br/>
<small>path: #url.path#</small><br/>
<small>embedPath: #embedPath#</small>
--->
</cfoutput>
