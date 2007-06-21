<cfscript>
FileObj = CreateObject("java","java.io.File").init(JavaCast("String",""));
if(FileObj.isAbsolute()){
	path = "";
}
else{
	path = ExpandPath("");
}
</cfscript>

<cfoutput>
	File Absolute: #FileObj.isAbsolute()# <br /><br />
	Path: #path#</cfoutput>