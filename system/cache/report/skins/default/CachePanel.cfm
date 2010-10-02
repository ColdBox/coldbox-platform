<cfoutput>

<!--- CacheBox Panel Accordion --->
<div class="fw_titles" onClick="fw_toggle('fw_cache')">&nbsp;CacheBox Report Monitor</div>
<!--- Panel Content --->
<div class="fw_debugContentView" id="fw_cache">

	<!--- ToolBar --->
	<div style="margin-bottom:5px;">
		
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
	</div>
		
	<!--- CacheBox Info --->
	<div class="fw_debugTitleCell">
	  CacheBox ID
	</div>
	<div class="fw_debugContentCell">
		#cacheBox.getFactoryID()#
	</div>
	<div class="fw_debugTitleCell">
	  Configured Caches
	</div>
	<div class="fw_debugContentCell">
		#arrayToList(cacheBox.getCacheNames())#
	</div>
	<div class="fw_debugTitleCell">
	  Scope Registration
	</div>
	<div class="fw_debugContentCell">
		#cacheBox.getScopeRegistration().toString()#
	</div>		
	<hr />
	
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
	<div id="fw_cacheReport">#renderCacheReport()#</div>

</div>
</cfoutput>