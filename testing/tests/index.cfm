<cfdirectory name="qTests" action="list" directory="#expandPath("./")#" filter="*.cfm">

<h1>ColdBox Unit Folder Tests</h1>

<table style="font-size:13px;" cellpadding="5" cellspacing="1" border="1">
<cfoutput query="qTests">
	<cfif name neq "index.cfm">
	<tr>
		<td>#name#</td>
		<td>[<a href="#name#" target="results">Run</a>]</td>
	</tr>
	</cfif>
</cfoutput>
</table>

<iframe name="results" src="" width="100%" height="500"></iframe>