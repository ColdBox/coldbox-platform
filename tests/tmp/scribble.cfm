<cfdirectory
	action   ="list"
	directory="#expandPath( "/test-harness/models" )#"
	filter   ="*.cfc"
	recurse  ="true"
	listinfo ="name"
	name     ="qObjects"
>

<cfdump var="#qObjects#">