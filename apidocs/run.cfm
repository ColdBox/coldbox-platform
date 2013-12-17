<!---
Let's generate our default HTML documentation on myself: 
 --->
<cfscript>
	colddoc = createObject("component", "ColdDoc").init();

	strategy = createObject("component", "colddoc.strategy.api.HTMLAPIStrategy").init(expandPath("./docs"), "ColdDoc 1.0 Alpha");
	colddoc.setStrategy(strategy);

	colddoc.generate(expandPath("/colddoc"), "colddoc");
</cfscript>

<h1>Done!</h1>

<a href="docs">Documentation</a>
