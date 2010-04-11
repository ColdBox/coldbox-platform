<cfscript>
out 	= createObject("java","java.lang.StringBuffer").init('');
tab 	= chr(9);
br  	= chr(10);
dq      = chr(34);

objs = [
	"coldbox.system.plugins.AntiSamy",
	"coldbox.system.plugins.ApplicationStorage",
	"coldbox.system.plugins.CFCViewer",
	"coldbox.system.plugins.ClientStorage",
	"coldbox.system.plugins.ClusterStorage",
	"coldbox.system.plugins.CookieStorage",
	"coldbox.system.plugins.DateUtils",
	"coldbox.system.plugins.FileUtils",
	"coldbox.system.plugins.HTMLHelper",
	"coldbox.system.plugins.i18n",
	"coldbox.system.plugins.JavaLoader",
	"coldbox.system.plugins.JVMUtils",
	"coldbox.system.plugins.Logger",
	"coldbox.system.plugins.MailService",
	"coldbox.system.plugins.MessageBox",
	"coldbox.system.plugins.MethodInjector",
	"coldbox.system.plugins.QueryHelper",
	"coldbox.system.plugins.ResourceBundle",
	"coldbox.system.plugins.SessionStorage",
	"coldbox.system.plugins.StringBuffer",
	"coldbox.system.plugins.Timer",
	"coldbox.system.plugins.Validator",
	"coldbox.system.plugins.Webservices",
	"coldbox.system.plugins.Zip",
	"coldbox.system.core.util.conversion.XMLConverter"	
];
fncExclude  = "init";

for( objIndex=1; objIndex lte arrayLen(objs); objIndex++){

title 		= "Exploring the #listLast(objs[objIndex],".")# Plugin";

out.append('
[[Dashboard | << Back to Dashboard ]]

{| align="right"
| __TOC__
|}

= #title# =

');

md = getComponentMetaData( objs[objIndex] );

out.append('
== Overview ==
#md.hint#

');

for(x=1; x lte arrayLen(md.functions); x++){
	if( NOT structKeyExists(md.functions[x],"returntype") ){ md.functions[x].returntype = "any"; }
	if( NOT structKeyExists(md.functions[x],"hint") ){ md.functions[x].hint = ""; }
	if( NOT structKeyExists(md.functions[x],"access") ){ md.functions[x].access = "public"; }

// Exclude certain functions
if( findnocase(fncExclude, md.functions[x].name) or listFindNoCase("private,package",md.functions[x].access) ){ continue; }
	
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
<cfoutput>#out.toString()#</cfoutput>
</textarea>
');

fileWrite(expandPath(".") & "/#listLast(md.name,'.')#.htm", out.toString() );

}
</cfscript>

