<cfoutput>
<h1>Welcome to my test Module</h1>
<cfdump var="#rc.data#">

Plugin Data
<cfdump var="#getMyPlugin(plugin="Simple",module="conventionsTest").getData()#">
</cfoutput>