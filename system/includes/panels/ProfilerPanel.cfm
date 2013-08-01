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
<!--- Setup the panel --->
<cfsetting showdebugoutput="false">
<cfparam name="url.frequency" default="0">
<!--- Verify Frequency --->
<cfif not isNumeric(url.Frequency)>
	<cfset url.frequency = 0>
</cfif>
<cfoutput>
<html>
<head>
	<title>ColdBox Execution Profiler Monitor</title>
	<cfif url.frequency gt 0>
	<!--- Meta Tag Refresh --->
	<meta http-equiv="refresh" content="#url.frequency#">
	</cfif>
	<!--- Include Header --->
	<cfinclude template="/coldbox/system/includes/DebugHeader.cfm">
</head>	
<body>
	
	<div class="fw_debugPanel">
	
	<!--- **************************************************************--->
	<!--- TRACER STACK--->
	<!--- **************************************************************--->
	<cfinclude template="/coldbox/system/includes/panels/TracersPanel.cfm">
	
	<!--- Start Rendering the Execution Profiler panel  --->
	<div class="fw_titles">&nbsp;ColdBox Execution Profiler Report</div>
	<div class="fw_debugContentView" id="fw_executionprofiler">
	
		<div>
			<strong>Monitor Refresh Frequency (Seconds): </strong>
			<select id="frequency" style="font-size:10px" onChange="fw_pollmonitor('profiler',this.value,'#URLBase#')">
				<option value="0">No Polling</option>
				<cfloop from="5" to="30" index="i" step="5">
				<option value="#i#" <cfif url.frequency eq i>selected</cfif>>#i# sec</option>
				</cfloop>
			</select>
			<hr>
		</div>
	
		<div class="fw_debugTitleCell">
		  Profilers in stack
		</div>
		<div class="fw_debugContentCell">
		  #profilersCount# / #getDebuggerConfig().getmaxPersistentRequestProfilers()#
		</div>
		
		<p>Below you can see the incoming request profilers. Click on the desired profiler to view its execution report.</p>
		<!--- Render Profilers --->
		<cfloop from="#profilersCount#" to="1" step="-1" index="x">
			<cfset refLocal.thisProfiler = profilers[x]>
			<div class="fw_profilers" onClick="fw_toggle('fw_executionprofile_#x#')">&nbsp;#dateformat(refLocal.thisProfiler.datetime,"mm/dd/yyyy")# #timeformat(refLocal.thisProfiler.datetime,"hh:mm:ss.l tt")# (#refLocal.thisProfiler.ip#)</div>
			<div class="fw_debugContent" id="fw_executionprofile_#x#">
			<!--- **************************************************************--->
			<!--- Method Executions --->
			<!--- **************************************************************--->
			<table border="0" align="center" cellpadding="0" cellspacing="1" class="fw_debugTables">
			  <tr>
			  	<th width="13%" align="center" >Timestamp</th>
				<th width="10%" align="center" >Execution Time</th>
				<th >Framework Method</th>
				<!--- Show RC Snapshots if active --->
				<cfif instance.debuggerConfig.getShowRCSnapshots()>
				<th width="75" align="center" >RC Snapshot</th>
				<th width="75" align="center" >PRC Snapshot</th>
				</cfif>
			  </tr>
				  <cfloop query="refLocal.thisProfiler.timers">
					  <cfif findnocase("rendering", method)>
					  	<cfset color = "fw_redText">
					  <cfelseif findnocase("interception",method)>
					  	<cfset color = "fw_blackText">
					  <cfelseif findnocase("runEvent", method)>
					  	<cfset color = "fw_blueText">
					  <cfelseif findnocase("pre",method) or findnocase("post",method)>
					  	<cfset color = "fw_purpleText">
					  <cfelse>
					  	<cfset color = "fw_greenText">
					  </cfif>
					<tr <cfif currentrow mod 2 eq 0>class="even"</cfif>>
					  	<td align="center" >#TimeFormat(timestamp,"hh:MM:SS.l tt")#</td>
						<td align="center" >#Time# ms</td>
						<td ><span class="#color#">#Method#</span></td>
						<!--- Show RC Snapshots if active --->
						<cfif instance.debuggerConfig.getShowRCSnapshots()>
				 		<td align="center" >
							<cfif len(rc)><a href="javascript:fw_poprc('fw_poprc_#id#')">View</a><cfelse>...</cfif>
						</td>
						<td align="center" >
							<cfif len(prc)><a href="javascript:fw_poprc('fw_popprc_#id#')">View</a><cfelse>...</cfif>
						</td>
						</cfif>
					 </tr>
					<!--- Show RC Snapshots if active --->
					<cfif instance.debuggerConfig.getShowRCSnapshots()>
					<tr id="fw_poprc_#id#" class="hideRC">
					  	<td colspan="5" style="padding:5px;" wrap="true">
						  	<div style="overflow:auto;width:98%; height:150px;padding:5px">
							  #replacenocase(rc,",",chr(10) & chr(13),"all")#
							</div>
						</td>
			  		  </tr>
			  		 <tr id="fw_popprc_#id#" class="hideRC">
				  	    <td colspan="5" style="padding:5px;" wrap="true">
					  	<div style="overflow:auto;width:98%; height:150px;padding:5px">
						  #replacenocase(prc,",",chr(10) & chr(13),"all")#
						</div>
					   </td>
		  		    </tr>
					</cfif>
				  </cfloop>
			</table>
			</div>
		</cfloop>
		
	</div>
	<!--- **************************************************************--->

	</div><!--- End of Debug Panel Div --->
	
	<div align="center" style="margin-top:10px"><input type="button" name="close" value="Close Monitor" onClick="window.close()" style="font-size:10px"></div>
</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="false">