<cfoutput>
<h1>#Event.getValue("welcomeMessage")#</h1>
<h5>You are running #getSetting("codename",1)# #getSetting("version",1)# (#getsetting("suffix",1)#)</h5>
<h1>RC Scope dump</h1>
<cfdump var="#rc#">
</cfoutput>