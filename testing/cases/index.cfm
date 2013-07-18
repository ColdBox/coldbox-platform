<cfparam name="url.path" default="/">
<cfset rootPath = getDirectoryFromPath( getCurrentTemplatePath() )>
<cfdirectory action="list" directory="#rootPath & url.path#" name="qResults" sort="asc" >
<cfset embedPath = replaceNoCase( rootPath & url.path, rootPath, "" )>

<cfoutput>
<h1>#embedPath#</h1>
<cfif len( url.path )>
	<a href="">< Back</a><br><hr>
</cfif>
<cfloop query="qResults">
	
	<cfif qResults.type eq "Dir">
		<a href="index.cfm?path=/#qResults.name#">#qResults.name#</a><br/>
	<cfelseif listLast( qresults.name, ".") eq "cfm">
		<a href="#qResults.name#">#qResults.name#</a><br/>
	<cfelseif listLast( qresults.name, ".") eq "cfc" and findNoCase( "Test", qResults.name )>
		<a href="#qResults.name#?method=runTestRemote">#qResults.name#</a><br/>
	<cfelse>
		#qResults.name#<br/>
	</cfif>
		
</cfloop>

<hr>
<small>root: #rootPath#</small><br/>
<small>path: #url.path#</small>

</cfoutput>
