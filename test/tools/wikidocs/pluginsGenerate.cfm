<cfscript>
tab 	= chr(9);
br  	= chr(10);
dq      = chr(34);

objects = [
	"coldbox.system.plugins.AntiSamy",
	"coldbox.system.plugins.ApplicationStorage",
	"coldbox.system.plugins.BeanFactory",
	"coldbox.system.plugins.BeanFactoryCompat",
	"coldbox.system.plugins.ClientStorage",
	"coldbox.system.plugins.ClusterStorage",
	"coldbox.system.plugins.CookieStorage",
	"coldbox.system.plugins.DateUtils",
	"coldbox.system.plugins.FileUtils",
	"coldbox.system.plugins.HTMLHelper",
	"coldbox.system.plugins.i18n",
	"coldbox.system.plugins.IOC",
	"coldbox.system.plugins.JavaLoader",
	"coldbox.system.plugins.JVMUtils",
	"coldbox.system.plugins.Logger",
	"coldbox.system.plugins.MailService",
	"coldbox.system.plugins.MessageBox",
	"coldbox.system.plugins.QueryHelper",
	"coldbox.system.plugins.ResourceBundle",
	"coldbox.system.plugins.SessionStorage",
	"coldbox.system.plugins.StringBuffer",
	"coldbox.system.plugins.Timer",
	"coldbox.system.plugins.Utilities",
	"coldbox.system.plugins.Validator",
	"coldbox.system.plugins.Webservices",
	"coldbox.system.plugins.Zip",
	"coldbox.system.core.conversion.XMLConverter",
	"coldbox.system.orm.hibernate.BaseORMService"
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

