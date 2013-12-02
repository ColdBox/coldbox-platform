<cfparam name="url.version" default="0">
<cfscript>
	version = url.version;
	
	docName = "MockBoxDocs-#version#";
	colddoc = createObject("component", "ColdDoc").init();

	base = expandPath("/mockbox");
	docs = expandPath(docName);

	strategy = createObject("component", "colddoc.strategy.api.HTMLAPIStrategy").init(docs, "MockBox Version #version#");
	colddoc.setStrategy(strategy);

	colddoc.generate(inputSource=base,outputDir=docs,inputMapping="mockbox");
</cfscript>

<cfzip action="zip" file="#expandPath('.')#/#docname#.zip" source="#expandPath(docName)#" overwrite="true" recurse="yes">
<cffile action="move" source="#expandPath('.')#/#docname#.zip" destination="/Users/lmajano/exports/mockbox-distro">

<cfoutput>
<h1>Done!</h1>
<a href="#docName#/index.html">Go to Docs!</a>
</cfoutput>
