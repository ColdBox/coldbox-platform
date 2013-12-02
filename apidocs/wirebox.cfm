<cfparam name="url.version" default="0">
<cfscript>
	version = url.version;
	
	docName = "WireBoxDocs-#version#";
	base = expandPath("/wirebox");
	docs = expandPath(docName);
	colddoc = createObject("component", "ColdDoc").init();
	strategy = createObject("component", "colddoc.strategy.api.HTMLAPIStrategy").init(docs, "ColdBox Platform - WireBox Version #version#");
	colddoc.setStrategy(strategy);

	colddoc.generate(inputSource=base,outputDir=docs,inputMapping="wirebox");
</cfscript>

<cfzip action="zip" file="#expandPath('.')#/#docname#.zip" source="#expandPath(docName)#" overwrite="true" recurse="yes">
<cffile action="copy" source="#expandPath('.')#/#docname#.zip" destination="/Users/lmajano/exports/wirebox-distro">

<cfoutput>
<h1>Done!</h1>
<a href="#docName#/index.html">Go to Docs!</a>
</cfoutput>
