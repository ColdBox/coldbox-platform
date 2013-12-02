<cfparam name="url.version" default="0">
<cfscript>
	version = url.version;
	
	docName = "CacheBoxDocs-#version#";
	colddoc = createObject("component", "ColdDoc").init();

	base = expandPath("/cachebox");
	docs = expandPath(docName);

	strategy = createObject("component", "colddoc.strategy.api.HTMLAPIStrategy").init(docs, "ColdBox Platform - CacheBox Version #version#");
	colddoc.setStrategy(strategy);

	colddoc.generate(inputSource=base,outputDir=docs,inputMapping="cachebox");
</cfscript>

<cfzip action="zip" file="#expandPath('.')#/#docname#.zip" source="#expandPath(docName)#" overwrite="true" recurse="yes">
<cffile action="copy" source="#expandPath('.')#/#docname#.zip" destination="/Users/lmajano/exports/cachebox-distro">

<cfoutput>
<h1>Done!</h1>
<a href="#docName#/index.html">Go to Docs!</a>
</cfoutput>
