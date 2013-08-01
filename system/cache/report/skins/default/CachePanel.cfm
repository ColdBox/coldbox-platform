<cfoutput>
<cfparam name="url.frequency" default="0">
<cfif url.frequency neq 0>
<script type="text/javascript">
setTimeout("location.reload(true);",#url.frequency*1000#);
</script>
</cfif>
<!--- CacheBox Panel Accordion --->
<div class="cachebox_titles" onClick="cachebox_toggle('cachebox_cache')">&nbsp;CacheBox Monitor</div>
<!--- Panel Content --->
<div class="cachebox_debugContent<cfif attributes.expandedPanel OR url.cbox_cacheMonitor>View</cfif>" id="cachebox_cache">

	<!--- ToolBar --->
	<div style="margin-bottom:5px;">
		
		<!--- Show Monitor or Not --->
		<cfif attributes.enableMonitor>
		
			<!--- Refresh Monitor --->
			<strong>Refresh Monitor: </strong>
			<select id="frequency" style="font-size:10px" onChange="cachebox_pollmonitor('cache',this.value,'#URLBase#')" title="Refresh Frequency">
				<option value="0">No Polling</option>
				<cfloop from="5" to="30" index="i" step="5">
				<option value="#i#" <cfif url.frequency eq i>selected='selected'</cfif>>#i# sec</option>
				</cfloop>
			</select>
			
			<cfif NOT url.cbox_cacheMonitor>
				<!--- Button: Open Cache Monitor --->
				<input type="button" value="Open Cache Monitor" name="cachemonitor" style="font-size:10px" 
					   title="Open the cache monitor in a new window." 
					   onClick="cachebox_pollmonitor('cache',0,'#URLBase#',true)">
			</cfif>
		</cfif>
				
		<!--- Button: CacheBox ExpireAll --->
		<input type="button" value="CacheBox ExpireAll()" 
		   name="cboxbutton_cacheBoxExpireAll" id="cboxbutton_cacheBoxExpireAll"
		   style="font-size:10px" 
		   title="Tell CacheBox to run an expireAll() on all caches" 
		   onclick="cachebox_cacheBoxCommand('#URLBase#','cacheBoxExpireAll', this.id)" />
		<!--- Button: CacheBox Reap All --->
		<input type="button" value="CacheBox ReapAll()" 
		   name="cboxbutton_cacheBoxReapAll" id="cboxbutton_cacheBoxReapAll"
		   style="font-size:10px" 
		   title="Tell CacheBox to run an reapAll() on all caches" 
		   onclick="cachebox_cacheBoxCommand('#URLBase#','cacheBoxReapAll', this.id)" />
		   			  
		<!--- Loader --->
		<span class="cachebox_redText cachebox_debugContent" id="cachebox_cachebox_toolbar_loader">Loading...</span>	
	</div>
		
	<!--- CacheBox Info --->
	<div class="cachebox_debugTitleCell">
	  CacheBox ID
	</div>
	<div class="cachebox_debugContentCell">
		#cacheBox.getFactoryID()#
	</div>
	<div class="cachebox_debugTitleCell">
	  Configured Caches
	</div>
	<div class="cachebox_debugContentCell">
		#arrayToList(cacheBox.getCacheNames())#
	</div>
	<div class="cachebox_debugTitleCell">
	  Scope Registration
	</div>
	<div class="cachebox_debugContentCell">
		#cacheBox.getScopeRegistration().toString()#
	</div>		
	<hr />
	
	<!--- Cache Report Switcher --->
	<h3>Performance Report For 
		<select name="cachebox_cachebox_selector" id="cachebox_cachebox_selector" 
				style="font-size:9px;"
				title="Choose a cache from the list to generate the report"
				onChange="cachebox_cacheReport('#URLBase#',this.value)">
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
			   onClick="cachebox_cacheReport('#URLBase#',document.getElementById('cachebox_cachebox_selector').value)" />  
	
		<span class="cachebox_redText cachebox_debugContent" id="cachebox_cachebox_selector_loading">Loading...</span>	   
	</h3>
		
	<!--- Named Cache Report --->
	<div id="cachebox_cacheReport">#renderCacheReport()#</div>

</div>
</cfoutput>