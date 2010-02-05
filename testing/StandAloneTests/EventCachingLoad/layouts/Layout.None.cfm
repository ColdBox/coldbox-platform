<cfsetting showdebugoutput="false">
<cfset event.showdebugpanel("false")>
<cfset WriteOutput(getPlugin("messageBox").renderit())>
<cfoutput>#renderView()#</cfoutput>
