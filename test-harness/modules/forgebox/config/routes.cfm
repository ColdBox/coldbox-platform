<cfscript>
	addRoute(pattern="/", handler="manager",action="index", orderby="POPULAR");
	
	with(pattern="/install",handler="manager")
		.addRoute(pattern="/results/:entrySlug", action="installResults")
		.addRoute(pattern="/",action="install")
	.endWith();
	
	addRoute(pattern="/manager/:orderby/:typeSlug?", handler="manager",action="index");
	addRoute(pattern="/:handler/:action?");
</cfscript>