<cfparam name="url.version" default="0">
<cfscript>
	version = url.version;
	
	docName = "ContentBoxDocs-#version#";
	colddoc = createObject("component", "ColdDoc").init();

	base = expandPath("/contentbox");
	docs = expandPath(docName);

	strategy = createObject("component", "colddoc.strategy.api.HTMLAPIStrategy").init(docs, "ContentBox #version#");
	colddoc.setStrategy(strategy);

	colddoc.generate(inputSource=base,outputDir=docs,inputMapping="logbox");
</cfscript>

<cfzip action="zip" file="#expandPath('.')#/#docname#.zip" source="#expandPath(docName)#" overwrite="true" recurse="yes">
<cffile action="copy" source="#expandPath('.')#/#docname#.zip" destination="/Users/lmajano/exports/logbox-distro">

<cfoutput>
<h1>Done!</h1>
<a href="#docName#/index.html">Go to Docs!</a>
</cfoutput>
