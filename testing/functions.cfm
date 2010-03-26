<cfset h = getComponentMetadata("coldbox.system.plugins.HTMLHelper")>

<cfoutput>
<cfloop array="#h.functions#" index="fnc">
	<cfif fnc.name neq "init">
	#fnc.name#() : <cfif structKeyExists(fnc,"hint")> #fnc.hint#</cfif>
	<br/>
	</cfif>
</cfloop>
</cfoutput>