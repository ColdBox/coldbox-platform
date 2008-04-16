<cfoutput>

	<!--- Setup the panel --->
	<cfsetting showdebugoutput="false">
	<cfparam name="url.frequency" default="20">
	
	<!--- Verify Frequency --->
	<cfif not isNumeric(url.Frequency)>
		<cfset url.frequency = 20>
	</cfif>
	
	<cfif url.frequency gt 0>
	<!--- Meta Tag Refresh --->
	<meta http-equiv="refresh" content="#url.frequency#">
	</cfif>
	
	<!--- Include Header --->
	<cfinclude template="/coldbox/system/includes/debugHeader.cfm">
	
	<div class="fw_debugPanel">
	
	<!--- Start Rendering the Cache panel  --->
	<div class="fw_titles">&gt;&nbsp; ColdBox Execution Profiler Report</div>
	<div class="fw_debugContentView" id="fw_executionprofiler">
	
		<div>
			<strong>Monitor Refresh Frequency (Seconds): </strong>
			<select id="frequency" style="font-size:10px" onChange="fw_pollmonitor('profiler',this.value)">
				<option value="0">Stop Polling</option>
				<cfloop from="10" to="30" index="i" step="5">
				<option value="#i#" <cfif url.frequency eq i>selected</cfif>>#i#</option>
				</cfloop>
			</select>
			<hr>
		</div>
	
		<div class="fw_debugTitleCell">
		  Profilers in stack
		</div>
		<div class="fw_debugContentCell">
		  #profilersCount# / #getDebuggerConfigBean().getmaxPersistentRequestProfilers()#
		</div>
		
		<p>Below you can see the incoming request profilers. Click on the desired profiler to view its execution report.</p>
		<!--- Render Profilers --->
		<cfloop from="#profilersCount#" to="1" step="-1" index="x">
			<cfset local.thisProfiler = profilers[x]>
			<div class="fw_titles" onClick="fw_toggle('fw_executionprofile_#x#')">&gt;&nbsp; #dateformat(local.thisProfiler.datetime,"mm/dd/yyyy")# #timeformat(local.thisProfiler.datetime,"hh:mm:ss.l tt")# (#local.thisProfiler.ip#)</div>
			<div class="fw_debugContent" id="fw_executionprofile_#x#">
			<!--- **************************************************************--->
			<!--- Method Executions --->
			<!--- **************************************************************--->
			<table border="0" align="center" cellpadding="0" cellspacing="1" class="fw_debugTables">
			  <tr>
			  	<th width="13%" align="center" >Timestamp</th>
				<th width="10%" align="center" >Execution Time</th>
				<th >Framework Method</th>
				<th width="75" align="center" >RC Snapshot</th>
			  </tr>
				  <cfloop query="local.thisProfiler.timers">
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
						<td align="center" >
							<cfif rc neq ''><a href="javascript:fw_poprc('fw_poprc_#id#')">View</a><cfelse>...</cfif>
						</td>
					  </tr>
					 <tr id="fw_poprc_#id#" class="hideRC">
					  	<td colspan="4" style="padding:5px;" wrap="true">
						  	<div style="overflow:auto;width:98%; height:150px;padding:5px">
							  #replacenocase(rc,",",chr(10) & chr(13),"all")#
							</div>
						</td>
			  		  </tr>
				  </cfloop>
			</table>
			</div>
		</cfloop>
		
	</div>
	<!--- **************************************************************--->

	</div>
	
	<div align="center" style="margin-top:10px"><input type="button" name="close" value="Close Monitor" onClick="window.close()" style="font-size:10px"></div>
	
</cfoutput>