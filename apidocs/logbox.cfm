<cfparam name="url.version" default="0">
<cfparam name="url.path" 	default="#expandPath( "./logbox-APIDocs" )#">
<cfscript>
	docName = "logbox-APIDocs";
	base = expandPath( "/logbox/system" );

	// Create the output directory if it doesn't exist
	if ( !directoryExists( url.path ) ) {
		directoryCreate( url.path );
	}

	docbox 	= new docbox.DocBox( properties = {
		projectTitle 	= "logbox v#url.version#",
		outputDir 		= url.path
	} );
	docbox.generate( source=base, mapping="logbox.system" );
</cfscript>

<!---
<cfzip action="zip" file="#expandPath('.')#/#docname#.zip" source="#expandPath( docName )#" overwrite="true" recurse="yes">
<cffile action="move" source="#expandPath('.')#/#docname#.zip" destination="#url.path#">
--->

<cfoutput>
<h1>Done!</h1>
<a href="#docName#/index.html">Go to Docs!</a>
</cfoutput>
