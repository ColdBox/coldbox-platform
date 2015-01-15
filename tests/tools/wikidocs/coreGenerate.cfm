<cfscript>
tab 	= chr(9);
br  	= chr(10);
dq      = chr(34);

objects = [
	"coldbox.system.core.dynamic.BeanPopulator"
];
fncExclude  = "init,onMissingMethod";

for( idx=1; idx lte arrayLen(objects); idx++){
	out   = createObject("java","java.lang.StringBuffer").init('');
	md    = getComponentMetaData( objects[idx] );
	title = "Exploring the #listLast(md.name,".")# Plugin";

out.append('
[[Dashboard | << Back to Dashboard ]]

{| align="right"
| __TOC__
|}

= #title# =

');


out.append('
== Overview ==
#md.hint#

');

	for(x=1; x lte arrayLen(md.functions); x++){
		if( NOT structKeyExists(md.functions[x],"returntype") ){ md.functions[x].returntype = "any"; }
		if( NOT structKeyExists(md.functions[x],"hint") ){ md.functions[x].hint = ""; }
		if( NOT structKeyExists(md.functions[x],"access") ){ md.functions[x].access = "public"; }

		// Exclude certain functions
		if( listFindNoCase(fncExclude, md.functions[x].name) or listFindNoCase("private,package",md.functions[x].access) ){ continue; }
			
out.append("
== #md.functions[x].name# ==
#md.functions[x].hint#

=== Returns ===
* This function returns ''#md.functions[x].returnType#''

");

		// Are arguments defined
		if( arrayLen(md.functions[x].parameters) ){
			
out.append("
=== Arguments ===

{| cellpadding=#dq#5#dq#, class=#dq#tablelisting#dq#
! '''Key''' !! '''Type'''  !! '''Required''' !! '''Default''' !! '''Description''' 
|-");
	
	// Parameters
	for( y=1; y lte arrayLen(md.functions[x].parameters); y++){
		if(NOT structKeyExists(md.functions[x].parameters[y],"required") ){	md.functions[x].parameters[y].required = false;	}
		if(NOT structKeyExists(md.functions[x].parameters[y],"hint") ){	md.functions[x].parameters[y].hint = "";	}
		if(NOT structKeyExists(md.functions[x].parameters[y],"type") ){	md.functions[x].parameters[y].type = "any";	}
		if(NOT structKeyExists(md.functions[x].parameters[y],"default") ){	md.functions[x].parameters[y]["default"] = "---"; }
		
out.append('
| #md.functions[x].parameters[y].name# || #md.functions[x].parameters[y].type# || #yesNoFormat(md.functions[x].parameters[y].required)# || #md.functions[x].parameters[y].default# || #md.functions[x].parameters[y].hint#');

		if( y lt arrayLen(md.functions[x].parameters) ){
	
out.append('
|-');
	
		}// end of no more parameters
	
	}// end for loop of params
	
out.append('
|}
');
}

out.append("
=== Examples ===
");

}// end if Arguments defined


writeOutput('
<textarea rows="30" cols="160">
#out.toString()#
</textarea>
');

fileWrite(expandPath(".") & "/docs/#listLast(md.name,'.')#.htm", out.toString() );

}
</cfscript>

