<cfsetting enablecfoutputonly="true">
<cfset event = application.cbController.getRequestService().getContext()>
<cfif structisEmpty(event.getRenderData())>
	<cfoutput>FW Startup Time: #request.fwLoadTIme# ms   #request.fwLoadTime/1000# s<br></cfoutput>
	
	<cfdump var="#application.cbcontroller.getConfigSettings()#" label="App Config Settings" expand="false">
	<cfdump var="#application.cbcontroller.getColdboxSettings()#" label="App Config Settings" expand="false">
</cfif>
<cfsetting enablecfoutputonly="false">