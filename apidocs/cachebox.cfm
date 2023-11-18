<cfparam name="url.version" default="0">
<cfparam name="url.path" 	default="#expandPath( "./CacheBox-APIDocs" )#">
<cfscript>
	docName = "CacheBox-APIDocs";
	base = expandPath( "/cachebox/system" );

	docbox 	= new docbox.DocBox( properties = {
		projectTitle 	= "CacheBox v#url.version#",
		outputDir 		= url.path
	} );
	docbox.generate( source=base, mapping="cachebox.system" );
</cfscript>

<!---
<cfzip action="zip" file="#expandPath('.')#/#docname#.zip" source="#expandPath( docName )#" overwrite="true" recurse="yes">
<cffile action="move" source="#expandPath('.')#/#docname#.zip" destination="#url.path#">
--->

<cfoutput>
<h1>Done!</h1>
<a href="#docName#/index.html">Go to Docs!</a>
</cfoutput>
