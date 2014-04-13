<cfsetting showdebugoutput="false">
<cfset event.showdebugpanel("false")>
<cfset WriteOutput(getPlugin("MessageBox").renderit())>
<cfoutput>#renderView()#</cfoutput>
