<cfparam name="url.version" default="0">
<cfscript>
	version = url.version;
	
	docName = "ColdBoxDocs-#version#";
	colddoc = createObject("component", "ColdDoc").init();

	base = expandPath("/coldbox/system");
	docs = expandPath(docName);

	strategy = createObject("component", "colddoc.strategy.api.HTMLAPIStrategy").init(docs, "ColdBox Platform Version #version#");
	colddoc.setStrategy(strategy);

	colddoc.generate(inputSource=base,outputDir=docs,inputMapping="coldbox.system");
</cfscript>

<cfzip action="zip" file="#expandPath('.')#/#docname#.zip" source="#expandPath(docName)#" overwrite="true" recurse="yes">
<cffile action="copy" source="#expandPath('.')#/#docname#.zip" destination="/Users/lmajano/exports/coldbox">

<cfoutput>
<h1>Done!</h1>
<a href="#docName#/index.html">Go to Docs!</a>
</cfoutput>
