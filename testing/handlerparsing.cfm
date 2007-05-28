<cffunction name="ripExtension" access="private" returntype="string" output="false">
	<cfargument name="filename" type="string" required="true">
	<cfreturn reReplace(arguments.filename,"\.[^.]*$","")>
</cffunction>


<cfset HandlerPath = expandPath("../src/handlers")>
<cfset HandlerInvocationPath = "coldbox">
<cfdirectory action="list" recurse="true" directory="#expandPath("../src/handlers")#" name="listing" filter="*.cfc">

<cfdump var="#listing#">
<cfset Handlers = ArrayNew(1)>
<cfloop query="listing">
	<cfset listing.directory = replacenocase(replacenocase(listing.directory,HandlerPath,"","all"),"/",".","all") & ".">
	<cfset listing.name = ripExtension(listing.name)>
	<cfset arrayappend(handlers, listing.directory & listing.name)>
	
</cfloop>
<cfdump Var="#listing#">
<cfdump Var="#handlers#">