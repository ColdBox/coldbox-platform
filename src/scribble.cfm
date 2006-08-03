<cfscript>
function get(Filename){
return reReplace(arguments.Filename,"\.[^.]*$","");
}
</cfscript>
<cfset name = "pio.txt.luis">

<cfoutput>#get(name)#</cfoutput>

