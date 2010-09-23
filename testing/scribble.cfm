<cfset test = "hello:test">
<cfset module = "">
<cfif find(":",test)>
	<cfset module = getToken(test,1, ":")>
</cfif>
<cfoutput>
module= #module#
</cfoutput>