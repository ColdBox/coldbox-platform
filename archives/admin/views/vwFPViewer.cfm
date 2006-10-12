<cfif getValue("cfdoctype") eq "pdf">
	<cfset ext = "pdf">
<cfelse>
	<cfset ext = "swf">
</cfif>
<cfheader name="Content-Disposition" value="inline; filename=print.#ext#">
<cfdocument format="#getValue("cfdoctype")#" pagetype="letter">
	<cfif getValue("usePreTag",false)>
	<cfoutput><pre>#getValue("fpcontent")#</pre></cfoutput>
	<cfelse>
	<cfoutput>#getValue("fpcontent")#</cfoutput>
	</cfif>
</cfdocument>