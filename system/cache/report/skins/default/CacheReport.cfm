<cfoutput>		
<!--- Attributes In Use for this skin --->
<cfparam name="attributes.contentReport"	type="boolean" default="true" >
   
<!--- Id & Name --->
<div class="cachebox_debugTitleCell">
  Cache Name
</div>
<div class="cachebox_debugContentCell">
 #cacheProvider.getName()# [class=#getMetadata(cacheProvider).name#]
</div>

<!--- Performance --->
<div class="cachebox_debugTitleCell">
  Performance
</div>
<div class="cachebox_debugContentCell">
 <em>Hit Ratio:</em> #NumberFormat(cacheStats.getCachePerformanceRatio(),"999.99")#%  ==>
 <em>Hits:</em> #cacheStats.getHits()# |
 <em>Misses:</em> #cacheStats.getMisses()# |
 <em>Evictions:</em> #cacheStats.getEvictionCount()# |
 <em>Garbage Collections:</em> #cacheStats.getGarbageCollections()# |
 <em>Object Count: </em> #cacheSize#
</div>

<!--- JVM Memory Stats --->
<div class="cachebox_debugTitleCell">
  JVM Memory Stats
</div>
<div class="cachebox_debugContentCell">
 <em>#NumberFormat((JVMFreeMemory/JVMMaxMemory)*100,"99.99")# % Free </em> |
 <em>Max: </em> #NumberFormat(JVMMaxMemory)# KB
 <em>Total: </em> #NumberFormat(JVMTotalMemory)# KB |
 <em>Free: </em> #NumberFormat(JVMFreeMemory)# KB		 
</div>

<!--- Last Reap --->
<cfif len(cacheStats.getlastReapDatetime())>
	<div class="cachebox_debugTitleCell">
	  Last Reap
	</div>
	<div class="cachebox_debugContentCell">
	 #DateFormat(cacheStats.getlastReapDatetime(),"MMM-DD-YYYY")#
	 #TimeFormat(cacheStats.getlastReapDatetime(),"hh:mm:ss tt")#
	</div>
</cfif>

<!--- Cache Charting ---> 
<cfinclude template="CacheCharting.cfm">

<!--- Cache Configuration --->
<h3>Cache Configuration
	<input type="button" value="Show/Hide" 
		   name="cboxbutton_cacheproperties"
		   style="font-size:10px" 
		   title="View Cache Properties" 
		   onClick="cachebox_toggleDiv('cachebox_cacheConfigurationTable','table')" />
</h3>
<div id="cachebox_cacheConfiguration">
	<table border="0" cellpadding="0" cellspacing="1" class="cachebox_debugTables" id="cachebox_cacheConfigurationTable" style="display:none">
		<thead>
			<tr>
			  	<th width="30%">Property</th>
				<th>Value</th>
			</tr>
		</thead>
		<tbody>
			<cfset x = 1>
			<cfloop collection="#cacheConfig#" item="thisKey">
			<tr <cfif x mod 2 eq 0>class="even"</cfif>>
				<td>#lcase(thisKey)#</td>
				<td>#cacheConfig[thisKey].toString()#</td>
			</tr>
			<cfset x=x+1>
			</cfloop>
		</tbody>
	</table>
</div>

<!--- Content Report --->
<cfif cacheProvider.isReportingEnabled() AND attributes.contentReport>
	<h3>Cache Content Report</h3>

	<!--- Reload Contents --->
	<input type="button" value="Reload Contents" 
		   name="cboxbutton_reloadContents"
		   style="font-size:10px" 
		   title="Reload the contents" 
		   onClick="cachebox_cacheContentReport('#URLBase#','#arguments.cacheName#')" />
		   
	<!--- Expire All Keys --->
	<input type="button" value="Expire All Keys" 
		   name="cboxbutton_expirekeys" id="cboxbutton_expirekeys"
		   style="font-size:10px" 
		   title="Expire all the keys in the cache" 
		   onclick="cachebox_cacheContentCommand('#URLBase#','expirecache', '#arguments.cacheName#')" />

	<!--- Clear All Keys --->
	<input type="button" value="Clear All Keys" 
		   name="cboxbutton_clearkeys" id="cboxbutton_clearkeys"
		   style="font-size:10px" 
		   title="Clear all the keys in the cache" 
		   onclick="cachebox_cacheContentCommand('#URLBase#','clearcache', '#arguments.cacheName#')" />

	<!--- ColdBox Application Commands --->
	<cfif cacheBox.isColdBoxLinked()>
		<!--- Clear All Events --->
		<input type="button" value="Clear All Events" 
			   name="cboxbutton_clearallevents" id="cboxbutton_clearallevents"
			   style="font-size:10px" 
			   title="Remove all the events in the cache" 
			   onclick="cachebox_cacheContentCommand('#URLBase#','clearallevents', '#arguments.cacheName#')" />
		<!--- Clear All Views --->
		<input type="button" value="Clear All Views" 
			   name="cboxbutton_clearallviews" id="cboxbutton_clearallviews"
			   style="font-size:10px" 
			   title="Remove all the views in the cache" 
			   onclick="cachebox_cacheContentCommand('#URLBase#','clearallviews', '#arguments.cacheName#')" />
	</cfif>

	<!--- Loader --->
	<span class="cachebox_redText cachebox_debugContent" id="cachebox_cacheContentReport_loader">Please Wait, Processing...</span>

	<div class="cachebox_cacheContentReport" id="cachebox_cacheContentReport">
		#renderCacheContentReport(arguments.cacheName)#
	</div>
</cfif>
</cfoutput>