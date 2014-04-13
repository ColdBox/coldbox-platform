<cfdirectory action="list" directory="#expandPath( './runners' )#" name="qRunners">
	<cfdirectory action="list" directory="#expandPath( './mxunit' )#" name="qMXUnit">
<cfdirectory action="list" directory="#expandPath( './specs' )#" name="qSpecs" filter="*.cfc">

<h2>TestBox Samples & Test Harness</h2>
<p>Below are several sample runners you can execute that will execute tests in the <strong>specs</strong> directory:</p>
<cfoutput>
	<ul>
	<cfloop query="qRunners">
		<li><a href="runners/#qRunners.name#" target="_blank">#qRunners.name#</a></li>
	</cfloop>
	</ul> 	
	
	<p>You can also execute the specs directly:</p>
	
	<ul>
	<cfloop query="qSpecs">
		<cfif !refindnocase( "^\.", qSpecs.name )>
		<li><a href="specs/#qSpecs.name#?method=runRemote" target="_blank">#qSpecs.name#</a></li>
		</cfif>
	</cfloop>
	</ul> 	

	<p>You can also execute MXUnit compatibility runners:</p>

	<ul>
	<cfloop query="qMXUnit">
		<li><a href="mxunit/#qMXUnit.name#" target="_blank">#qMXUnit.name#</a></li>
	</cfloop>
	</ul>
</cfoutput>