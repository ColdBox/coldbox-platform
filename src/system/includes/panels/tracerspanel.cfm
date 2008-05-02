<cfsetting enablecfoutputonly="true">
<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Template :  debug.cfm
Author 	 :	Luis Majano
Date     :	September 25, 2005
Description :
	Debugging template for the application
----------------------------------------------------------------------->
<cfif getDebuggerConfigBean().getShowTracerPanel() and controller.getPlugin("sessionstorage").exists("fw_tracerStack")>
	<cfset TracerArray = controller.getPlugin("sessionstorage").getVar("fw_tracerStack")>
	<cfoutput>
	<div class="fw_titles" onClick="fw_toggle('fw_tracer')">&gt;&nbsp; Tracer Messages </div>
	<div class="fw_debugContent<cfif getDebuggerConfigBean().getExpandedTracerPanel()>View</cfif>" id="fw_tracer">
		<cfloop from="1" to="#arrayLen(TracerArray)#" index="i">
			<div class="fw_tracerMessage">
				
				<!--- Message --->
				<strong>Message:</strong><br>
				#TracerArray[i].message#<br>
				
				<!--- Extra Information --->
				<cfif not isSimpleValue(TracerArray[i].extrainfo)>
					<strong>ExtraInformation:<br></strong>
					<cfdump var="#TracerArray[i].extrainfo#">
				<cfelseif TracerArray[i].extrainfo neq "">
					<strong>ExtraInformation:<br></strong>
					#TracerArray[i].extrainfo#
				</cfif>
				
			</div>
		</cfloop>
	</div>
	<!--- Rendered, now Remove --->
	<cfset controller.getPlugin("sessionstorage").deleteVar("fw_tracerStack")>
	</cfoutput>
</cfif>
<cfsetting enablecfoutputonly="false">