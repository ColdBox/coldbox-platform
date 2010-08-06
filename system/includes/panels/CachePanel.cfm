<cfoutput>
	<!--- If CacheMonitor render the polling code --->
	<cfif isMonitor>
		<cfsetting showdebugoutput="false">
		<html>
		<head>
			<title>CacheBox Monitor</title>
			<cfif url.frequency gt 0>
			<!--- Meta Tag Refresh --->
			<meta http-equiv="refresh" content="#url.frequency#">
			</cfif>
			<!--- Include Header --->
			<cfinclude template="/coldbox/system/includes/DebugHeader.cfm">
		</head>
		<body>
		<!--- Start of Debug Panel Div --->
		<div class="fw_debugPanel">
	</cfif>

	<!--- CacheBox Panel Accordion --->
	<div class="fw_titles" onClick="fw_toggle('fw_cache')">&nbsp;CacheBox</div>
	<cfif isMonitor>
		<div class="fw_debugContentView" id="fw_cache">
	<cfelse>
		<div class="fw_debugContent<cfif getDebuggerConfig().getExpandedCachePanel()>View</cfif>" id="fw_cache">
	</cfif>
		
		<!--- ToolBar --->
		<div style="margin-bottom:5px;">
			<cfif NOT isMonitor>
				<!--- Button: Open Cache Monitor --->
				<input type="button" value="Open Cache Monitor" name="cachemonitor" style="font-size:10px" 
					   title="Open the cache monitor in a new window." 
					   onClick="window.open('#URLBase#?debugpanel=cache','cachemonitor','status=1,toolbar=0,location=0,resizable=1,scrollbars=1,height=750,width=850')">
				
			<cfelse>
				<!--- Refresh Monitor --->
				<strong>Refresh Monitor: </strong>
				<select id="frequency" style="font-size:10px" onChange="fw_pollmonitor('cache',this.value,'#URLBase#')" title="Refresh Frequency">
					<option value="0">No Polling</option>
					<cfloop from="5" to="30" index="i" step="5">
					<option value="#i#" <cfif url.frequency eq i>selected</cfif>>#i# sec</option>
					</cfloop>
				</select>
			</cfif>
			<cfif isObject( controller.getCacheBox() )>
			<!--- Button: CacheBox ExpireAll --->
			<input type="button" value="CacheBox ExpireAll()" 
			   name="cboxbutton_cacheBoxExpireAll" id="cboxbutton_cacheBoxExpireAll"
			   style="font-size:10px" 
			   title="Tell CacheBox to run an expireAll() on all caches" 
			   onclick="fw_cacheBoxCommand('#URLBase#','cacheBoxExpireAll', this.id)" />
			<!--- Button: CacheBox Reap All --->
			<input type="button" value="CacheBox ReapAll()" 
			   name="cboxbutton_cacheBoxReapAll" id="cboxbutton_cacheBoxReapAll"
			   style="font-size:10px" 
			   title="Tell CacheBox to run an reapAll() on all caches" 
			   onclick="fw_cacheBoxCommand('#URLBase#','cacheBoxReapAll', this.id)" />
			   			  
			<!--- Loader --->
			<span class="fw_redText fw_debugContent" id="fw_cachebox_toolbar_loader">Loading...</span>
			</cfif>			
		</div>
			
		<cfif isObject( controller.getCacheBox() )>
			<!--- CacheBox Info --->
			<div class="fw_debugTitleCell">
			  CacheBox ID
			</div>
			<div class="fw_debugContentCell">
				#controller.getCacheBox().getFactoryID()#
			</div>
			<div class="fw_debugTitleCell">
			  Configured Caches
			</div>
			<div class="fw_debugContentCell">
				#arrayToList(controller.getCacheBox().getCacheNames())#
			</div>
			<div class="fw_debugTitleCell">
			  Scope Registration
			</div>
			<div class="fw_debugContentCell">
				#controller.getCacheBox().getScopeRegistration().toString()#
			</div>		
			<hr />
		</cfif>
			
		<!--- Cache Report Switcher --->
		<h3>Performance Report For 
		<select name="fw_cachebox_selector" id="fw_cachebox_selector" 
				style="font-size:9px;"
				title="Choose a cache from the list to generate the report"
				onChange="fw_cacheReport('#URLBase#',this.value)">
			<cfloop from="1" to="#arrayLen(cacheNames)#" index="x">
				<option value="#cacheNames[x]#" <cfif cacheNames[x] eq "default">selected="selected"</cfif>>#cacheNames[x]#</option>
			</cfloop>
		</select>
		Cache
		<!--- Reload Contents --->
		<input type="button" value="Regenerate Report" 
			   name="cboxbutton_cachebox_regenerateReport"
			   style="font-size:10px" 
			   title="Regenerate Report" 
			   onClick="fw_cacheReport('#URLBase#',document.getElementById('fw_cachebox_selector').value)" />  
   
		<span class="fw_redText fw_debugContent" id="fw_cachebox_selector_loading">Loading...</span>	   
  		</h3>
			
		<!--- Named Cache Report --->
		<div id="fw_cacheReport">
			#renderCacheReport()#
		</div>
		
	</div>
	<!--- **************************************************************--->

	<!--- If in CacheMonitor mode, render the close monitor buttons --->
	<cfif isMonitor>
		</div>
		<!--- End debug Panel --->
		<div align="center" style="margin-top:10px"><input type="button" name="close" value="Close Monitor" onClick="window.close()" style="font-size:10px"></div>
		</body>
		</html>
	</cfif>

</cfoutput>