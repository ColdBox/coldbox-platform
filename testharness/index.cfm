<cfsetting enablecfoutputonly="true">
<cfset event = application.cbController.getRequestService().getContext()>
<cfif structisEmpty(event.getRenderData())>
	<cfoutput>FW Startup Time: #request.fwLoadTIme# ms   #request.fwLoadTime/1000# s<br></cfoutput>
</cfif>
<cfsetting enablecfoutputonly="false">