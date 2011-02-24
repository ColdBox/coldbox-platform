<cfsetting enablecfoutputonly="true">
<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Template :  debug.cfm
Author 	 :	Luis Majano
Date     :	September 25, 2005
Description :
	Debugging template for the application
----------------------------------------------------------------------->
<cfif getDebuggerConfig().getShowTracerPanel() and arrayLen(getTracers())>
	<cfset TracerArray = getTracers()>
	<cfoutput>
	<div class="fw_titles" onClick="fw_toggle('fw_tracer')">&nbsp;ColdBox Tracer Messages </div>
	<div class="fw_debugContent<cfif getDebuggerConfig().getExpandedTracerPanel()>View</cfif>" id="fw_tracer">
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
	<cfset resetTracers()>
	</cfoutput>
</cfif>
<cfsetting enablecfoutputonly="false">